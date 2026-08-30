"""Build the paper from an isolated, explicitly declared source closure."""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIGURES = [
    "fig7_1_temporal_scaling.pdf",
    "fig7_2_local_global_phase.pdf",
    "fig7_3_radius_regret.pdf",
    "fig7_4_radius_phase.pdf",
    "fig7_5_decision_relevance.pdf",
    "fig7_6_general_graphs.pdf",
]


def run(command: list[str], cwd: Path) -> None:
    completed = subprocess.run(command, cwd=cwd, text=True,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if completed.returncode:
        print(completed.stdout)
        raise SystemExit(completed.returncode)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "output/pdf/tina.pdf")
    args = parser.parse_args()
    for tool in ("pdflatex", "bibtex"):
        if shutil.which(tool) is None:
            raise SystemExit(f"required TeX tool not found: {tool}")

    audit = subprocess.run([sys.executable, str(ROOT / "scripts/audit_sources.py")])
    if audit.returncode:
        return audit.returncode

    scratch = ROOT / "tmp/pdfs"
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="tina-build-", dir=scratch) as name:
        build = Path(name)
        (build / "figures").mkdir()
        shutil.copy2(ROOT / "main.tex", build / "main.tex")
        shutil.copy2(ROOT / "references.bib", build / "references.bib")
        for figure in FIGURES:
            shutil.copy2(ROOT / "figures" / figure, build / "figures" / figure)

        latex = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
                 "-file-line-error", "-jobname=tina", "main.tex"]
        run(latex, build)
        run(["bibtex", "tina"], build)
        run(latex, build)
        run(latex, build)

        log = (build / "tina.log").read_text(encoding="utf-8", errors="replace")
        fatal_patterns = [
            r"LaTeX Warning: There were undefined references",
            r"LaTeX Warning: Citation .* undefined",
            r"multiply-defined labels",
        ]
        for pattern in fatal_patterns:
            if re.search(pattern, log, re.I):
                raise SystemExit(f"build rejected because log matched: {pattern}")

        destination = args.output.resolve()
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(build / "tina.pdf", destination)
        shutil.copy2(build / "tina.pdf", ROOT / "tina.pdf")
        print(f"built {destination}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
