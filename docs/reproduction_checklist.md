# Clean-room reproduction checklist

1. Clone the tagged release and verify that `main.tex`, `references.bib`, and
   six files under `figures/` are present.
2. Create a Python 3.12 virtual environment and install
   `requirements-lock.txt`.
3. Run `python -m unittest discover -s tests -v`.
4. Run `python numerics/experiments/run_all.py --output-root tmp/reproduction
   --no-paper-copy`.
5. Compare headline values in
   `tmp/reproduction/results/metadata/reference_run.json` with the archived
   metadata and check the tolerances in `docs/numerical_method.md`.
6. Run `python scripts/audit_sources.py` to verify the citation keys and the
   complete local TeX input closure.
7. Run `python scripts/build_paper.py`; the isolated build must produce
   `output/pdf/tina.pdf` without undefined citations or references.
8. Render and inspect every PDF page, paying particular attention to equations,
   floats, page breaks, bibliography URLs, and embedded fonts.

Expected runtime is roughly one minute for the numerical suite, plus the TeX
build. Exact PDF byte identity across platforms is not expected because TeX
and PDF metadata can differ; numerical CSV values and the documented headline
tolerances are the comparison targets.
