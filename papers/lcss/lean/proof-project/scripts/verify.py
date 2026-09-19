#!/usr/bin/env python3
"""Verify the pinned proof project, replay the kernel, and extract the local proof DAG.

Default verification includes fresh leanchecker replay. --extract-only only
regenerates JSON from previously checked, hash-matched evidence; it is NOT a
new proof, build, or replay result. No third-party Python packages are needed.
"""
import argparse
import datetime
import graphlib
import hashlib
import json
import re
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
ROOTS = ["LCSS.theorem1", "LCSS.theorem2", "LCSS.theorem1_arithmetic",
         "LCSS.theorem2_time_integrated_lower_bounds",
         "LCSS.theorem2_physical_attainment",
         "LCSS.FiniteGaussianWitness.finite_ou_witness",
         "LCSS.theorem2_raw_physical_attainment",
         "LCSS.InclusiveRawStrategy.expected_horizon_lower_bound",
         "LCSS.theorem2_inclusive_lower_bounds",
         "LCSS.theorem2_inclusive_physical_attainment",
         "LCSS.full_model_witness", "LCSS.theorem1_ou", "LCSS.theorem2_ou_physical_attainment"]


def check(condition, message):
    if not condition:
        raise RuntimeError(message)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(command, log, results):
    print("Running:", " ".join(command), flush=True)
    start = time.monotonic()
    with (ROOT / "evidence" / log).open("w") as out:
        result = subprocess.run(command, cwd=ROOT, stdout=out, stderr=subprocess.STDOUT)
    results.append({"command": command, "log": "evidence/" + log,
                    "exit_code": result.returncode, "seconds": round(time.monotonic() - start, 3)})
    check(result.returncode == 0, f"Command failed; see evidence/{log}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--clean", action="store_true", help="rebuild all local modules from source")
    parser.add_argument("--extract-only", action="store_true", help="regenerate DAG from hash-matched existing evidence")
    parser.add_argument("--preflight", action="store_true", help="build, audit and check the DAG without fresh replay; not full verification")
    args = parser.parse_args()
    check(not (args.preflight and args.extract_only), "--preflight and --extract-only are mutually exclusive")
    check(not (args.clean and args.extract_only), "--clean and --extract-only are mutually exclusive")
    (ROOT / "evidence").mkdir(exist_ok=True)
    sources = [ROOT / "LCSS.lean", *sorted((ROOT / "LCSS").glob("*.lean"))]
    vendor_sources = sorted((ROOT / "vendor").rglob("*.lean"))
    proof_hashes = {p.relative_to(ROOT).as_posix(): sha(p) for p in [*sources, *vendor_sources]}
    vendor_manifest = json.loads((ROOT / "vendor/UPSTREAM.json").read_text())
    check({p.relative_to(ROOT / "vendor").as_posix() for p in vendor_sources} ==
          {v["source"] for v in vendor_manifest["modules"].values()}, "Vendor inventory drift")
    for row in vendor_manifest["modules"].values():
        check(sha(ROOT / "vendor" / row["source"]) == row["ported_sha256"],
              f"Vendor source drift: {row['source']}")
    contract = json.loads((ROOT / "contracts/review-contract.lock.json").read_text())
    for name, digest in contract["files_sha256"].items():
        check(sha(ROOT / name) == digest, f"Review-contract drift: {name}; review the change and deliberately re-freeze the contract")
    check(contract["review_status"] == "pending_independent_review", "Unexpected review status: do not manufacture reviewer approval")

    forbidden = re.compile(r"\b(sorry|admit|axiom|native_decide|ofReduceBool|trustCompiler|skipKernelTC|unsafe|implemented_by|extern)\b|\+native")
    custom = re.compile(r"(?m)^\s*(?:local\s+|scoped\s+)?(?:macro|syntax|elab|notation|infix[lr]?|prefix|postfix|instance)\b|\b(addDecl|addAndCompile|setEnv|run_cmd|evalExpr|Lean\.ofReduce)\b")
    # Audit.lean is a separately hash-locked, read-only metadata extractor.
    for path in [*sources, ROOT / "Sanity.lean"]:
        content = path.read_text()
        check(not forbidden.search(content), f"Forbidden proof machinery in {path.name}")
        check(not custom.search(content), f"Unexpected metaprogramming/notation/instance in {path.name}")
    for path in sources[1:]:
        check("set_option autoImplicit false" in path.read_text(), f"Implicit-variable guard missing: {path.name}")

    # Upstream instance declarations are legitimate, separately provenance-locked code.
    for path in vendor_sources:
        check(not forbidden.search(path.read_text()), f"Forbidden proof machinery in vendor source: {path}")

    results = []
    if not args.extract_only:
        lake = shutil.which("lake") or str(Path.home() / ".elan/bin/lake")
        if args.clean:
            shutil.rmtree(ROOT / ".lake/build", ignore_errors=True)
        run([lake, "build"], "build.log", results)
        run([lake, "env", "lean", "--version"], "lean-version.log", results)
        check("819816b2e0a3bf405af45ae5c7af2491d8f5bee6" in
              (ROOT / "evidence/lean-version.log").read_text(), "Compiler commit differs from proof contract")
        dependencies = []
        manifest = json.loads((ROOT / "lake-manifest.json").read_text())
        for p in manifest["packages"]:
            cwd = ROOT / manifest["packagesDir"] / p["name"]
            rev = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=cwd, text=True).strip()
            dirty = subprocess.check_output(["git", "status", "--porcelain", "--untracked-files=no"], cwd=cwd, text=True)
            check(rev == p["rev"], f"Dependency revision mismatch: {p['name']}")
            check(not dirty, f"Tracked dependency edits: {p['name']}")
            dependencies.append({"name": p["name"], "revision": rev, "tracked_clean": True})
        (ROOT / "evidence/dependency-pins.json").write_text(json.dumps(dependencies, indent=2) + "\n")
        run([lake, "env", "lean", "Audit.lean"], "axioms.log", results)
        run([lake, "env", "lean", "Sanity.lean"], "sanity.log", results)
        if not args.preflight:
            run([lake, "env", "leanchecker", "--fresh", "LCSS"], "leanchecker-fresh.log", results)
        evidence = {
            "checked_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "mode": "preflight_no_fresh_replay" if args.preflight else "full_verification", "local_clean_rebuild": args.clean,
            "fresh_replay": not args.preflight, "independent_checker": False, "comparator": False,
            "dependency_source_rebuild": False, "independent_human_review": False,
            "commands": results, "source_sha256": proof_hashes,
            "contract_sha256": sha(ROOT / "contracts/review-contract.lock.json"),
            "raw_dependencies_sha256": sha(ROOT / "evidence/lean-dependencies.json"),
            "vendor_dependencies_sha256": sha(ROOT / "evidence/vendor-dependencies.json")}
    else:
        evidence = json.loads((ROOT / "evidence/verification.json").read_text())
        check(evidence["source_sha256"] == proof_hashes, "Stale dependency extraction: sources differ")
        check(evidence["raw_dependencies_sha256"] == sha(ROOT / "evidence/lean-dependencies.json"), "Changed raw dependency evidence")
        check(evidence["vendor_dependencies_sha256"] == sha(ROOT / "evidence/vendor-dependencies.json"), "Changed vendor dependency evidence")
        check(evidence["contract_sha256"] == sha(ROOT / "contracts/review-contract.lock.json"), "Changed contract since verification")

    declarations = {}
    for path in sources:
        relative = path.relative_to(ROOT).as_posix()
        namespace = []
        for line_no, line in enumerate(path.read_text().splitlines(), 1):
            match = re.match(r"^namespace (\w+)", line)
            if match:
                namespace.append(match[1])
            match = re.match(r"^end (\w+)", line)
            if match:
                check(namespace.pop() == match[1], f"Namespace mismatch in {relative}")
            match = re.match(r"^(?:@\[[^]]+\]\s*)?(theorem|lemma|def|abbrev|structure)\s+(\w+)", line)
            if match:
                name = ".".join(namespace + [match[2]])
                check(name not in declarations, f"Duplicate source declaration: {name}")
                declarations[name] = {"file": relative, "line": line_no, "source_kind": match[1]}

    rows = json.loads((ROOT / "evidence/lean-dependencies.json").read_text())
    vendor_rows = json.loads((ROOT / "evidence/vendor-dependencies.json").read_text())
    vendor_raw = {row["name"]: row for row in vendor_rows}
    raw = {row["name"]: row for row in rows}
    check(set(declarations) <= set(raw), "Source declaration missing from elaborated root environment")
    for row in [*rows, *vendor_rows]:
        check(row["kind"] != "axiom", f"Local axiom: {row['name']}")
        check(set(row["axioms"]) <= ALLOWED, f"Unapproved transitive axiom: {row['name']}")
    for root, expected in contract["root_types"].items():
        check(raw[root]["type"] == expected, f"Exported theorem type drift: {root}")

    def owner(name):
        normal = re.sub(r"^_private\.LCSS\.\w+\.\d+\.", "", name)
        return max((n for n in declarations if normal == n or normal.startswith(n + ".")), key=len, default=None)

    vendor_modules = set(vendor_manifest["modules"])
    vendor_owner = {row["name"]: row["module"] for row in vendor_rows}
    check(set(vendor_owner.values()) <= vendor_modules, "Audited vendor module outside inventory")
    graph = {name: set() for name in [*declarations, *sorted(vendor_modules)]}
    externals = {name: set() for name in declarations}
    generated = {name: [] for name in declarations}
    for row in rows:
        name = owner(row["name"])
        check(name is not None, f"Unassigned generated constant: {row['name']}")
        generated[name].append(row["name"])
        for dep in row["direct_constants"]:
            target = owner(dep)
            if target is None:
                externals[name].add(dep)
                if dep in vendor_owner:
                    graph[name].add(vendor_owner[dep])
            elif target != name:
                graph[name].add(target)
    for row in vendor_rows:
        for dep in row["direct_constants"]:
            target = vendor_owner.get(dep)
            if target and target != row["module"]:
                graph[row["module"]].add(target)
    order = list(graphlib.TopologicalSorter(graph).static_order())
    closures = {}
    for root in ROOTS:
        reachable = set()
        def visit(name):
            if name in reachable:
                return
            reachable.add(name)
            for dep in graph[name]:
                visit(dep)
        visit(root)
        closures[root] = reachable
    required = {
        "LCSS.theorem1_arithmetic": ["LCSS.SensorModel.arithmeticJH_eq", "LCSS.SensorModel.posterior_arithmetic_condVar"],
        "LCSS.theorem2_time_integrated_lower_bounds": [
            "LCSS.expected_integrated_loss", "LCSS.PaperComponents.receivedInfo_le",
            "LCSS.PaperComponents.fresh_localInfo_le", "LCSS.PhysicalSchedule.trace",
            "LCSS.ScheduledPolicy.toControls", "LCSS.ScheduledStrategy.accumulatedLoss_eq",
            "LCSS.lintegral_translate_Ioc", "LCSS.lintegral_Ioc_chain"],
        "LCSS.theorem2_physical_attainment": [
            "LCSS.theorem2_time_integrated_lower_bounds",
            "LCSS.PhysicalSchedule.strictCount_phase", "LCSS.PhysicalSchedule.strictCount_initial",
            "LCSS.PhysicalSchedule.none_trace", "LCSS.PhysicalSchedule.periodic_trace",
            "LCSS.ScheduledPolicy.canonical", "LCSS.ScheduledPolicy.canonical_controls_cost",
            "LCSS.ScheduledPolicy.canonical_loss_measurable",
            "LCSS.ScheduledStrategy.canonical", "LCSS.ScheduledStrategy.canonical_average",
            "LCSS.ScheduledStrategy.noRefresh_cost", "LCSS.ScheduledStrategy.periodic_cost",
            "LCSS.CanonicalLossRegularity", "LCSS.expected_integrated_loss"],
        "LCSS.theorem2_raw_physical_attainment": [
            "LCSS.RawRealization", "LCSS.RawRealization.Y_eq", "LCSS.RawRealization.message_eq",
            "LCSS.RawRealization.local_eq", "LCSS.RawRealization.hybrid_eq",
            "LCSS.real_version_limit", "LCSS.stronglyMeasurable_aeHistory_version",
            "LCSS.informationSpace_aeHistory", "LCSS.aeHistory_iSup_comap",
            "LCSS.RawRealization.receivedInfo_informationSpace",
            "LCSS.RawScheduledPolicy.toLp", "LCSS.RawScheduledPolicy.canonical",
            "LCSS.RawScheduledPolicy.canonicalAction_joint", "LCSS.RawRealization.realizedLoss_joint",
            "LCSS.RawRealization.expected_realizedLoss", "LCSS.expected_integrated_loss",
            "LCSS.PhysicalSchedule.lintegral_phases", "LCSS.RawScheduledStrategy.expected_horizon_cost",
            "LCSS.RawScheduledStrategy.timeAverage_eq", "LCSS.RawScheduledStrategy.canonical_average",
            "LCSS.theorem2_raw_lower_bounds", "LCSS.ScheduledPolicy.toControls",
            "LCSS.ScheduledPolicy.canonical_controls_cost",
            "LCSS.RawScheduledStrategy.noRefresh_cost", "LCSS.RawScheduledStrategy.periodic_cost"]}
    required["LCSS.InclusiveRawStrategy.expected_horizon_lower_bound"] = [
        "LCSS.InclusiveRawPolicy.toStrict_integrated_loss", "LCSS.InclusiveRawStrategy.toStrict",
        "LCSS.RawScheduledStrategy.expected_horizon_cost", "LCSS.RefreshControls.cost_lower_bound"]
    endpoint_bridges = [
        "LCSS.PhysicalSchedule.receivedBy", "LCSS.PhysicalSchedule.receptionTimes_countable",
        "LCSS.PhysicalSchedule.receivedBy_eq_receivedBefore", "LCSS.PhysicalSchedule.ae_not_reception",
        "LCSS.PhysicalSchedule.ae_not_reception_phase", "LCSS.InclusiveRawPolicy.toStrict",
        "LCSS.InclusiveRawPolicy.toStrict_loss_phase_ae", "LCSS.InclusiveRawPolicy.toStrict_integrated_loss",
        "LCSS.InclusiveRawStrategy.toStrict", "LCSS.InclusiveRawStrategy.toStrict_timeAverage",
        "LCSS.InclusiveRawStrategy.toStrict_timeUpperCost", "LCSS.theorem2_raw_lower_bounds"]
    required["LCSS.theorem2_inclusive_lower_bounds"] = endpoint_bridges
    required["LCSS.theorem2_inclusive_physical_attainment"] = endpoint_bridges + [
        "LCSS.RawScheduledPolicy.toInclusive", "LCSS.RawRealization.receivedInfo_mono",
        "LCSS.PhysicalSchedule.receivedBefore_subset_receivedBy",
        "LCSS.RawScheduledStrategy.toInclusive", "LCSS.theorem2_inclusive_lower_bounds",
        "LCSS.RawScheduledStrategy.noRefresh_cost", "LCSS.RawScheduledStrategy.periodic_cost"]
    required["LCSS.full_model_witness"] = [
        "LCSS.OUProcess.value", "LCSS.OUProcess.gaussian", "LCSS.OUProcess.covariance",
        "LCSS.IndependentOU.raw_all_independent", "LCSS.IndependentOU.components",
        "LCSS.IndependentOU.realization", "LCSS.IndependentOU.component_eq",
        "LCSS.IndependentOU.model", "LCSS.IndependentOU.raw_joint",
        "BrownianMotion.Gaussian.BrownianMotion", "BrownianMotion.Gaussian.ProjectiveLimit",
        "KolmogorovExtension4.KolmogorovExtension"]
    required["LCSS.theorem1_ou"] = ["LCSS.theorem1", "LCSS.IndependentOU.model"]
    required["LCSS.theorem2_ou_physical_attainment"] = [
        "LCSS.theorem2_inclusive_physical_attainment", "LCSS.IndependentOU.realization",
        "LCSS.IndependentOU.components", "LCSS.IndependentOU.model",
        "LCSS.OUProcess.gaussian", "LCSS.OUProcess.covariance"]
    for root, deps in required.items():
        check(set(deps) <= closures[root], f"Required correspondence bridge unused by {root}: {set(deps)-closures[root]}")
    raw_closure = closures["LCSS.theorem2_raw_physical_attainment"]
    check("LCSS.CanonicalLossRegularity" not in raw_closure,
          "Raw attainment unexpectedly depends on quotient representative regularity")
    check("LCSS.theorem2_physical_attainment" not in raw_closure,
          "Raw attainment unexpectedly depends on the old conditional attainment root")
    for root in ["LCSS.theorem2_inclusive_lower_bounds", "LCSS.theorem2_inclusive_physical_attainment",
                 "LCSS.InclusiveRawStrategy.expected_horizon_lower_bound", "LCSS.theorem2_ou_physical_attainment"]:
        check("LCSS.CanonicalLossRegularity" not in closures[root], "Endpoint root depends on quotient regularity")
        check("LCSS.theorem2_physical_attainment" not in closures[root], "Endpoint root uses old conditional attainment")
    nodes = []
    for name in sorted(declarations):
        row = raw[name]
        nodes.append({"id": name, **declarations[name], "module": row["module"], "type": row["type"],
                      "proof_status": "kernel_checked" if evidence["fresh_replay"] else "compiled_without_fresh_replay", "semantic_status": "see_audit_not_independently_approved",
                      "used_by_roots": [r for r in ROOTS if name in closures[r]],
                      "axioms": sorted({a for n in generated[name] for a in raw[n]["axioms"]}),
                      "depends_on": sorted(graph[name]), "external_constants": sorted(externals[name]),
                      "kernel_constants_in_group": sorted(generated[name])})
    for mod in sorted(vendor_modules):
        group = [row for row in vendor_rows if row["module"] == mod]
        nodes.append({"id": mod, "file": "vendor/" + vendor_manifest["modules"][mod]["source"],
                      "line": 1, "source_kind": "vendor_module_group", "module": mod,
                      "proof_status": "kernel_checked" if evidence["fresh_replay"] else "compiled_without_fresh_replay",
                      "semantic_status": "upstream_port_same_author_review",
                      "used_by_roots": [root for root in ROOTS if mod in closures[root]],
                      "axioms": sorted({a for row in group for a in row["axioms"]}),
                      "depends_on": sorted(graph[mod]),
                      "generated_constants": sorted(row["name"] for row in group),
                      "external_constants": sorted({dep for row in group for dep in row["direct_constants"] if dep not in vendor_owner})})
    # Inspect actual transitive constants, in addition to grouped source/module DAG paths.
    all_raw = raw | vendor_raw
    def constant_closure(root):
        todo = [root]; seen = set()
        while todo:
            name = todo.pop()
            if name in seen: continue
            seen.add(name)
            if name in all_raw: todo.extend(all_raw[name]["direct_constants"])
        return seen
    model_constants = constant_closure("LCSS.full_model_witness")
    vendor_required = {"ProbabilityTheory.brownian", "ProbabilityTheory.gaussianLimit",
                       "ProbabilityTheory.isGaussianProcess_brownian", "ProbabilityTheory.covariance_brownian",
                       "ProbabilityTheory.continuous_brownian", "ProbabilityTheory.iIndepFun.process_congr",
                       "MeasureTheory.projectiveLimit", "MeasureTheory.isProjectiveLimit_projectiveLimit"}
    check(vendor_required <= model_constants, f"Model construction constant path missing: {vendor_required-model_constants}")
    report = {
        "schema_version": 6, "main_theorems": ROOTS,
        "status": "declared_proofs_checked_paper_correspondence_partial" if evidence["fresh_replay"] else "preflight_only_no_fresh_replay",
        "generation_mode": "extract_only_no_new_verification" if args.extract_only else evidence["mode"],
        "paper_commit": "96909b3b63d2ad6921fa499e55cb3a01365e5fdf", "paper_path": "papers/lcss/main.tex",
        "lean_toolchain": (ROOT / "lean-toolchain").read_text().strip(),
        "mathlib_commit": "0df444a360eaa60ab8c11dca51a86af692955474",
        "method": {
            "extraction": "Lean ConstantInfo.getUsedConstantsAsSet, types and proof bodies",
            "grouping": "LCSS generated constants grouped by source declaration; vendor constants grouped by module. Intra-group edges omitted. Vendor raw constant dependencies are separately exported.",
            "edges": "A depends_on B means A's group references B's group; not a transitive reduction.",
            "external_boundary": "Selected BrownianMotion/KolmogorovExtension4 modules expanded and audited in evidence/vendor-dependencies.json. Lean/mathlib constants remain an external boundary, transitively axiom-audited.",
            "raw_evidence": "evidence/lean-dependencies.json", "source_locator": "Names/lines checked against elaborated environment."},
        "semantic_limits": [
            "Original theorem2 proves attainment/optimality in the abstract RefreshStrategy class.",
            "New time-integrated theorem proves lower bounds for ScheduledStrategy with explicit regularity, independent seed, one path, no pre-zero sends, and strict reception convention.",
            "Physical attaining strategies and exact costs are now constructed conditional on explicit CanonicalLossRegularity. No attainment or cost equality is assumed.",
            "C1: raw physical attainment is proved from jointly measurable raw primitives and fixed-time agreement with PaperComponents; arbitrary L2 coercions need no joint measurability.",
            "Raw histories preserve the admissible L2 information space by ambient-null augmentation, without simultaneous equality over uncountable time.",
            "C2: every non-strict raw strategy has a strict counterpart with equal integrated loss for every horizon, seed and outcome; finite-horizon lower bounds and non-strict physical attained optimality are proved. C3 supplies an explicit all-real-time independent Gaussian/OU model and jointly measurable raw realization; no supplied model premise remains in the instantiated roots.",
            "The proofs construct PaperModel, PaperComponents and RawRealization on a common probability space. No SDE/Ito equivalence or separate distributional-stationarity theorem is claimed.",
            "Frozen contract is same-author and post-proof; independent review, Comparator, and independent checker are pending."],
        "audit": {"sorry_count": 0, "local_axiom_count": 0,
                  "main_theorem_axioms": {r: sorted(raw[r]["axioms"]) for r in ROOTS},
                  "all_project_axioms": sorted({a for r in rows for a in r["axioms"]}),
                  "all_vendor_axioms": sorted({a for r in vendor_rows for a in r["axioms"]}),
                  "vendor_kernel_constant_count": len(vendor_rows), "vendor_module_count": len(vendor_modules),
                  "vendor_required_constant_paths": sorted(vendor_required),
                  "kernel_constant_count": len(rows), "source_declaration_count": len(declarations),
                  "edge_count": sum(len(x) for x in graph.values()),
                  "main_theorem_dependency_counts_including_self": {r: len(closures[r]) for r in ROOTS},
                  "required_bridge_closures": required, "acyclic": True,
                  "inclusive_roots_exclude_quotient_regularity": True,
                  "raw_root_excludes_quotient_regularity": True,
                  "fresh_replay": evidence["fresh_replay"], "independent_checker": False},
        "topological_order_dependencies_first": order, "source_sha256": proof_hashes, "nodes": nodes}
    (ROOT / "proof-dag.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    if not args.extract_only:
        (ROOT / ("evidence/preflight.json" if args.preflight else "evidence/verification.json")).write_text(json.dumps(evidence, indent=2) + "\n")
    print(json.dumps(report["audit"], indent=2), flush=True)
    if args.preflight:
        print("PASS: preflight only; fresh replay and full verification still required.")
        return
    print("PASS: dependency extraction only; no new verification." if args.extract_only else
          "PASS: contract, source pins, clean dependency revisions, build, regressions, axioms, fresh replay and DAG. Semantic review remains partial.")


if __name__ == "__main__":
    main()
