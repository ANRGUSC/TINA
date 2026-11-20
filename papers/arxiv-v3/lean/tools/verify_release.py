"""Build the v3 Lean project and publish the axiom audit for this CI checkout."""
import datetime
import json
import os
from pathlib import Path
import subprocess
import sys

import ledger


def verify(output):
    root = ledger.ROOT
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
    if commit != os.environ["GITHUB_SHA"]:
        raise ValueError("The checked-out source differs from the requested GitHub commit.")
    db = ledger.connect()
    assembly, plan = ledger.assembly_plan(db)
    if not plan or assembly != ledger.ASSEMBLY.read_text(encoding="utf-8"):
        raise ValueError("Assembly.lean must compose the selected proof attempts in the ledger.")

    # The GitHub job starts with a clean checkout and caches only dependencies.
    if (root / ".lake/build/lib/lean/TinaV2").exists():
        raise ValueError("Verification needs a clean build of the project's Lean modules.")
    subprocess.run(["lake", "build", "TinaV2"], cwd=root, check=True)
    db.execute("UPDATE assembled SET axioms=NULL, standard=NULL, checked=NULL")
    if ledger.audit_selected(db, []):
        raise ValueError("The Lean proof audit failed.")

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

    lean = subprocess.check_output(["lake", "env", "lean", "--version"], cwd=root, text=True).strip()
    run = (f"{os.environ['GITHUB_SERVER_URL']}/{os.environ['GITHUB_REPOSITORY']}/actions/runs/"
           f"{os.environ['GITHUB_RUN_ID']}/attempts/{os.environ['GITHUB_RUN_ATTEMPT']}")
    checked = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    record = {"commit": commit, "checked": checked, "lean": lean, "run": run, "claims": claims}
    output.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as summary:
        print("## arXiv v3 Lean verification\n", file=summary)
        print(f"Checked {checked} at `{commit}` using {lean}.\n", file=summary)
        print(f"Lean rebuilt the project and checked {len(claims)} assembled theorems. "
              "Every theorem uses only standard axioms and has no `sorryAx` dependency.\n", file=summary)
        print("| Claim | Theorem | Transitive axioms |\n|---|---|---|", file=summary)
        for claim, row in claims.items():
            print(f"| {claim} | `{row['theorem']}` | {', '.join(row['axioms']) or 'None'} |", file=summary)


if __name__ == "__main__":
    verify(Path(sys.argv[1]))
