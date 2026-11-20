"""Select and publish the original Lean run for a Pages release."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import urllib.request


BUILD_INFO = "https://anrgusc.github.io/TINA/arxiv-v3/lean/progress/build-info.json"
PROJECT = "papers/arxiv-v3/lean"
# Include new proof inputs by default. Only reader assets and documentation
# are independent of the Lean build and ledger audit.
INPUTS = [PROJECT, ".github/workflows/verify-arxiv-v3-lean.yml",
          f":(exclude){PROJECT}/progress/**", f":(exclude){PROJECT}/tools/reader_passages.py",
          f":(exclude,glob){PROJECT}/*.md"]


def same_inputs(verified, release):
    for sha in (verified, release):
        if not re.fullmatch(r"[0-9a-f]{40}", sha):
            raise ValueError("Expected a full Git commit ID")
    result = subprocess.run(["git", "diff", "--quiet", verified, release, "--", *INPUTS])
    if result.returncode > 1 or result.returncode < 0:
        raise ValueError("Cannot compare the two proof source trees")
    return result.returncode == 0


def reusable_record(release):
    # The published copy remains available after workflow artifacts expire.
    with urllib.request.urlopen(BUILD_INFO, timeout=15) as response:
        record = json.load(response)["verification"]
    if not same_inputs(record["commit"], release):
        print("Proof inputs changed; requesting a new Lean run.")
        return None
    repo = os.environ["GITHUB_REPOSITORY"]
    pattern = rf"https://github\.com/{re.escape(repo)}/actions/runs/(\d+)/attempts/(\d+)"
    match = re.fullmatch(pattern, record["run"])
    if not match or not record["claims"]:
        raise ValueError("Incomplete published verification record")
    run_id, attempt = match.groups()
    endpoint = f"repos/{repo}/actions/runs/{run_id}/attempts/{attempt}"
    run = json.loads(subprocess.check_output(["gh", "api", endpoint]))
    if (run["head_sha"] != record["commit"] or run["conclusion"] != "success"
        or run["head_branch"] != "main" or run["event"] not in {"push", "workflow_dispatch"}
        or run["path"] not in {".github/workflows/publish-reading-guide.yml",
                               ".github/workflows/verify-arxiv-v3-lean.yml"}):
        raise ValueError("The record does not identify a successful main-branch verification run")
    print(f"Reusing {record['run']} from verified commit {record['commit']}.")
    return record


def select_record(release):
    try:
        record = reusable_record(release)
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as exc:
        print(f"Prior verification unavailable ({exc}); requesting a new Lean run.")
        record = None
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as out:
        print("reused=" + ("true" if record else "false"), file=out)
        if record:
            print("record=" + json.dumps(record, separators=(",", ":")), file=out)


def attach_record(release, site_path, record_path):
    site = json.loads(site_path.read_text(encoding="utf-8"))
    record = json.loads(record_path.read_text(encoding="utf-8"))
    if site["commit"] != release or not same_inputs(record["commit"], release):
        raise ValueError("Cannot publish a verification record for different Lean inputs")
    site["verification"] = record
    site["verification_match"] = {"site_commit": release, "verified_commit": record["commit"]}
    site_path.write_text(json.dumps(site, indent=1), encoding="utf-8")


if __name__ == "__main__":
    release = os.environ["GITHUB_SHA"]
    if sys.argv[1:] == ["select"]:
        select_record(release)
    elif len(sys.argv) == 4 and sys.argv[1] == "attach":
        attach_record(release, Path(sys.argv[2]), Path(sys.argv[3]))
    else:
        sys.exit("Usage: pages_lean_record.py select | attach BUILD_INFO RECORD")
