# Clean-room reproduction checklist

1. Clone the tagged release and verify that `main.tex`, `references.bib`, and
   the six `figures/fig7_*.pdf` files are present.
2. Create a Python 3.12 virtual environment (the final reference run used
   Python 3.12.12) and install `requirements-lock.txt`.
3. Run the full unit suite:

   ```bash
   python -m unittest discover -s tests -v
   ```

   This includes independent composition/canonical-field checks, paired
   crossover and radius-grid diagnostics, predictor-shape and OU zero-delay
   checks, and the artifact-integrity checks.

4. Run a clean numerical reproduction without overwriting archived outputs or
   top-level figures:

   ```bash
   python numerics/experiments/run_all.py --output-root tmp/reproduction --no-paper-copy
   ```

5. Compare the six experiment metadata files and
   `reference_run.json` under `tmp/reproduction/results/metadata` with the
   archived metadata.  Exact timestamps, runtime, platform strings, and PDF
   bytes may differ; compare the documented headline tolerances and the fixed
   seeds/configurations.
6. Inspect the generated processed tables:

   - Experiment 2 has separate `eta_omitted` and `eta_captured` fields,
     paired boundary standard errors/95% intervals, and a zero-coupling
     boundary at zero.
   - Experiment 3 reports scalar innovation means/intervals; its broad case is
     a radius cap with positive residual omission, not a global endpoint.
   - Experiment 4 uses the same 0--4 radius grid and 0.0016 step at every
     parameter point; check radius error in grid-step units separately from
     zero/positive classification mismatches.
   - Experiment 5 uses an analytical per-operator normalizer; check every row
     of `exp05_mc_checks.csv` against the four-standard-error smoke rule.
   - Experiment 6 records one exact integer-radius curve per graph instance,
     the graph seed, and available one-hop regret gaps for each sampled sweep.

7. Run `python scripts/audit_sources.py` to verify citation keys and the local
   TeX input closure. Run `python scripts/sync_numerical_latex.py --check` to
   verify that standalone extracts match `main.tex`; after a manuscript edit,
   omit `--check` to refresh them. Manuscript figure PDFs must be byte-for-byte
   copies of their archived counterparts under `numerics/figures/pdf`.
8. Run `python scripts/build_paper.py`; the isolated build should produce
   `output/pdf/tina.pdf` without undefined citations or references.
9. Render and inspect every PDF page and each generated figure at manuscript
   size.  Check the Figure 2 crosses/intervals/residual panel, the Figure 4
   gray zero region and grid-error histogram, the separated Figure 5 state
   correlation context, and the distinct integer markers in Figure 6.  Also
   inspect equations, float placement, page breaks, bibliography URLs, and
   embedded fonts.

The numerical archive contains selected audit arrays and graph/system inputs,
not every random draw.  Exact PDF byte identity across platforms is not
expected because TeX and PDF metadata can differ; numerical CSV values,
metadata diagnostics, and the documented headline tolerances are the
comparison targets.
