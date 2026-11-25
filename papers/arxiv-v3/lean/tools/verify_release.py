"""Build the v3 Lean project, run multi-kernel comparator replay, and publish verification.json."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

import ledger


EXPECTED_KERNELS = [
    ("lean", "Lean default kernel accepts the solution"),
    ("leanchecker-paranoid", "Lean paranoid kernel accepts the solution"),
    ("lean4lean", "lean4lean kernel accepts the solution"),
    ("nanoda", "nanoda kernel accepts the solution"),
    ("con-leche", "con-leche kernel accepts the solution"),
    ("con-ron", "con-ron kernel accepts the solution"),
]


def run_comparator(root, no_sandbox=False):
    """Run `lake comparator --paranoid` and return the ordered list of accepted kernels."""
    cmd = ["lake", "comparator", "--config", "comparator.json", "--paranoid"]
    if no_sandbox:
        cmd.append("--inadvisably-no-sandbox")
    proc = subprocess.Popen(
        cmd,
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    lines = []
    assert proc.stdout is not None
    for line in proc.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
        lines.append(line)
    rc = proc.wait()
    output = "".join(lines)
    if rc != 0:
        raise ValueError(f"`{' '.join(cmd)}` exited with status {rc}.")
    if "Your solution is okay!" not in output:
        raise ValueError("`lake comparator` did not report acceptance (`Your solution is okay!`).")
    kernels_passed = [name for name, marker in EXPECTED_KERNELS if marker in output]
    missing = [name for name, _ in EXPECTED_KERNELS if name not in kernels_passed]
    if missing:
        raise ValueError(f"`lake comparator --paranoid` did not report acceptance from kernels: {', '.join(missing)}")
    return kernels_passed


def verify(output, no_sandbox=False):
    root = ledger.ROOT
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
    if commit != os.environ["GITHUB_SHA"]:
        raise ValueError("The checked-out source differs from the requested GitHub commit.")
    db = ledger.connect()
    check_errors, check_warnings = ledger.run_check(db)
    if check_errors:
        raise ValueError(
            "The Lean ledger invariant and Gate-2 policy check failed:\n"
            + "\n".join(check_errors)
        )
    assembly, plan = ledger.assembly_plan(db)
    if not plan or assembly != ledger.ASSEMBLY.read_text(encoding="utf-8"):
        raise ValueError("Assembly.lean must compose the selected proof attempts in the ledger.")

    chal_txt, sol_txt, cfg_txt, expected_chal_sha = ledger.comparator_spec(db)
    if (ledger.CHALLENGE_LEAN.read_text(encoding="utf-8") != chal_txt
            or ledger.SOLUTION_LEAN.read_text(encoding="utf-8") != sol_txt
            or ledger.COMPARATOR_JSON.read_text(encoding="utf-8") != cfg_txt):
        raise ValueError("Comparator spec files do not match the deterministic ledger generator.")
    challenge_sha256 = hashlib.sha256(ledger.CHALLENGE_LEAN.read_bytes()).hexdigest()
    if challenge_sha256 != expected_chal_sha:
        raise ValueError("comparator/Challenge.lean SHA-256 mismatch.")

    # The GitHub job starts with a clean checkout and caches only dependencies.
    if (root / ".lake/build/lib/lean/TinaV2").exists():
        raise ValueError("Verification needs a clean build of the project's Lean modules.")
    subprocess.run(["lake", "build", "TinaV2"], cwd=root, check=True)
    db.execute("UPDATE assembled SET axioms=NULL, standard=NULL, checked=NULL")
    non_vacuity = {}
    if ledger.audit_selected(db, [], nonvacuity_out=non_vacuity):
        raise ValueError("The Lean proof audit failed.")
    expected_wits = {w for w, _ in ledger.NONVACUITY_WITNESSES}
    if set(non_vacuity) != expected_wits:
        raise ValueError("A non-vacuity witness theorem is missing its verification record.")
    for wit, row in non_vacuity.items():
        if not (set(row["axioms"]) <= ledger.STANDARD_AXIOMS):
            raise ValueError(f"{wit}: non-vacuity witness uses non-standard axioms {row['axioms']}")

    kernels_passed = run_comparator(root, no_sandbox=no_sandbox)

    claims = {}
    for row in db.execute("""
        SELECT f.claim_id, f.lean_decl, a.id, s.axioms, s.standard
        FROM v_formalization f JOIN attempts a ON a.formalization_id=f.id
        JOIN assembled s ON s.attempt_id=a.id AND s.claim_id=f.claim_id
        WHERE a.selected=1 AND a.status='proved'
    """):
        claim = row["claim_id"]
        attempt, assumptions = plan[claim]
        if attempt != row["id"] or assumptions or row["standard"] != 1:
            raise ValueError(f"{claim}: expected a fully assembled, axiom-audited theorem")
        short = row["lean_decl"].split(".")[-2]
        claims[claim] = {"theorem": f"TinaV2.Assembly.{short}", "attempt": attempt,
                         "axioms": row["axioms"].split(", ") if row["axioms"] else []}
    if set(claims) != set(plan):
        raise ValueError("A selected theorem is missing its verification record.")
    covered_nv = {c for row in non_vacuity.values() for c in row["claims"]}
    missing_nv = sorted(set(claims) - covered_nv)
    if missing_nv:
        raise ValueError(f"Non-vacuity witnesses do not cover assembled claim(s): {', '.join(missing_nv)}")
    nv_coverage = {"covered": len(set(claims) & covered_nv), "total": len(claims)}

    lean = subprocess.check_output(["lake", "env", "lean", "--version"], cwd=root, text=True).strip()
    run = (f"{os.environ['GITHUB_SERVER_URL']}/{os.environ['GITHUB_REPOSITORY']}/actions/runs/"
           f"{os.environ['GITHUB_RUN_ID']}/attempts/{os.environ['GITHUB_RUN_ATTEMPT']}")
    checked = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    record = {
        "commit": commit,
        "checked": checked,
        "lean": lean,
        "run": run,
        "check_warnings": check_warnings,
        "challenge_sha256": challenge_sha256,
        "comparator_passed": True,
        "kernels_passed": kernels_passed,
        "claims": claims,
        "non_vacuity": non_vacuity,
        "non_vacuity_coverage": nv_coverage,
    }
    output.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as summary:
        print("## arXiv v3 Lean verification\n", file=summary)
        print(f"Checked {checked} at `{commit}` using {lean}.\n", file=summary)
        print(f"Ledger invariant and Gate-2 static policy check passed (`0` errors, "
              f"`{len(check_warnings)}` warnings).\n", file=summary)
        if check_warnings:
            print("Warnings:\n", file=summary)
            for w in check_warnings:
                print(f"- {w}", file=summary)
            print(file=summary)
        print("### Gate-3 comparator & multi-kernel replay\n", file=summary)
        print(f"- `comparator/Challenge.lean` SHA-256: `{challenge_sha256}`", file=summary)
        print("- `lake comparator --paranoid`: **passed**", file=summary)
        print(f"- Independent kernels passed ({len(kernels_passed)}): "
              + ", ".join(f"`{k}`" for k in kernels_passed) + "\n", file=summary)
        print(f"Lean rebuilt the project and checked {len(claims)} assembled theorems and "
              f"{len(non_vacuity)} non-vacuity witness theorems "
              f"({nv_coverage['covered']}/{nv_coverage['total']} claims covered across Tiers A–D). "
              "Every theorem is a kernel `.thmInfo` using only standard axioms with no `sorryAx` dependency.\n",
              file=summary)
        print("| Claim | Theorem | Transitive axioms |\n|---|---|---|", file=summary)
        for claim, row in claims.items():
            print(f"| {claim} | `{row['theorem']}` | {', '.join(row['axioms']) or 'None'} |", file=summary)
        print("\n### Non-vacuity witnesses\n", file=summary)
        print("| Witness theorem | Claims covered | Transitive axioms |\n|---|---|---|", file=summary)
        for wit, row in non_vacuity.items():
            print(f"| `{wit}` | {', '.join(row['claims'])} | {', '.join(row['axioms']) or 'None'} |",
                  file=summary)


if __name__ == "__main__":
    verify(Path(sys.argv[1]))
