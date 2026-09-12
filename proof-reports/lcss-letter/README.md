# Lamport review of the TINA delayed-pooling letter

**Publication status:** This is an L-CSS submission manuscript. It has not been accepted for publication.


## Interactive reading guide

[Read the guide](https://anrgusc.github.io/TINA/lcss-letter/) for step-by-step
notation, claims, proofs, and worked calculations, with adjustable text size.
[Guide source and manuscript revision](../../explainers/lcss-letter/README.md).


This package reviews the current six-page letter, *Too Late to Coordinate:
When Local Information Beats Global Sharing*, by Scott Moeller
and Bhaskar Krishnamachari. It does not audit the broader arXiv manuscript.

The report concludes that all seven formal results follow under the stated
assumptions. The forward verdict is PASS and the reverse verdict is FOLLOWS.
No critical, major, or minor proof issue remains unresolved. This is a model-assisted
mathematical audit, not a proof-assistant or kernel-checked formalization.

## Read the report

- `TINA_Paper1_Lamport_Report.pdf`: complete report.
- `TINA_Paper1_Lamport_Report.tex`: standalone LaTeX source, with no external images.
- Part I: fixed theorem contracts, source inventory, hierarchical rendering,
  mapping ledger, and review boundary.
- Part II: forward verdict, detailed mathematical calculations, numerical checks,
  every-step ledger, and unresolved-obligation and repair assessments.
- Part III: conclusion-first AND dependency graph, every-node table, and verdict.

The reviewed manuscript is included unchanged in `source/`. Its exact file hashes are recorded in `review_manifest.json`.

Prepared for [ANRGUSC/TINA](https://github.com/ANRGUSC/TINA). The package can be placed in `proof-reports/lcss-letter/` while preserving its directory structure. The report source is standalone and needs no external images.

## Build the standalone report

With a standard TeX Live installation:

```bash
pdflatex -interaction=nonstopmode -halt-on-error TINA_Paper1_Lamport_Report.tex
pdflatex -interaction=nonstopmode -halt-on-error TINA_Paper1_Lamport_Report.tex
```

## Reproduce the independent numerical checks

The script uses Python 3, NumPy, and SciPy. Versions used for this report were
NumPy 2.3.5 and SciPy 1.17.0. The seed is fixed in the script.

```bash
python3 check_audit.py
```

It solves 48 continuous-time Gaussian-team systems, including unequal sensor
variances and extra old/intermediate observations, plus 18 Gaussian AR(1)
systems with all intermediate local readings. It checks the full-history
covariance identity directly and 200 finite-horizon independent refresh
schedules. Full results are in `audit_checks.json`. These computations corroborate
finite-dimensional consequences; they do not substitute for the analytic proofs.

## Inspect the audit records

- `frozen_conversion.json`: exact source spans, fixed contracts, all 73 rendered
  steps, legal dependencies, and source mappings.
- `forward_ledger.json`: checked justifications and statuses for every step.
- `reverse_graph.json`: all 96 conclusion-reachable nodes and their primary
  AND routes, with shared background and earlier results.
- `audit_data.py`, `build_report.py`, and `report_template.tex`: report-generation
  sources. Run the builder in this directory after creating `output/` if desired.
  It protects an existing conversion record from silent changes. Its graph checks validate dependency order, scope, cycle freedom, and bottom-up closure of the recorded judgments. The forward
  justifications and reverse-edge judgments are mathematical review records;
  the builder checks their structure and generates their presentation.
- `review_manifest.json`: audit date, manuscript title, plugin revision, and exact input hashes.
- `qa_summary.json`: document-level checks for page bounds and TeX warnings.
- `qa_report.py` and `package_report.py`: document checks and packaging scripts.

## Method provenance

The three WWresearch Lamport Proof skills were read and applied in order:
`convert-lamport`, `forward-lamport`, and `reverse-lamport`.

Repository: https://github.com/WWresearch/lamport-proof

Pinned commit: `c5466f44d6ef0fff983ad67a46bc54e39858826f`.

The exact three skill instructions and their MIT license are included in
`plugin/`.

Theorem 1 is reviewed through its direct full-history Gaussian projection and
normal-equation proof. The report also checks the unequal-variance projection,
all formal endpoint and scheduling results, and eight derived or model-boundary
claims. The latter are identified separately from the seven formal graph roots.

Source TeX SHA-256:
`ca4063836ef506a56fbee54ab850a67499d70fc5a1de8f5c4f8077a1794f8db5`

Source PDF SHA-256:
`211b1eae40836b0136d35ea59f6678e5b88df1efa8d01bd100a2ee1f229bf0ef`

Frozen conversion SHA-256:
`a599596db88f9006726337403f992a6d8c033239f7c44a940aa86637d8daf165`

