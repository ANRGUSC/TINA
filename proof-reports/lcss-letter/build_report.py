#!/usr/bin/env python3
"""Compile the canonical expanded L-CSS submission report."""
from pathlib import Path
import subprocess
ROOT = Path(__file__).resolve().parent
NAME = "TINA_LCSS_Submission_Lamport_Report"
out = ROOT / "output"
out.mkdir(exist_ok=True)
for _ in range(2):
    subprocess.run(["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
                    "-output-directory", str(out), str(ROOT / (NAME + ".tex"))], cwd=ROOT, check=True)
(ROOT / (NAME + ".pdf")).write_bytes((out / (NAME + ".pdf")).read_bytes())
