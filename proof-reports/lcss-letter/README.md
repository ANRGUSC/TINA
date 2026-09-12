# Expanded Lamport review of the six-page L-CSS submission

**Scope:** This report reviews *Too Late to Coordinate: When Local Information Beats Global Sharing*, by Scott Moeller and Bhaskar Krishnamachari, the **six-page L-CSS submission**. It does not review the broader TINA arXiv manuscript.

**Publication status:** Submitted for review; not yet accepted for publication.

## Read the report

- [Expanded report PDF](TINA_LCSS_Submission_Lamport_Report.pdf)
- [Standalone LaTeX source](TINA_LCSS_Submission_Lamport_Report.tex)
- [Six-page submission PDF](../../submissions/lcss/lcss-paper.pdf)
- [Interactive reading guide](https://anrgusc.github.io/TINA/lcss-letter/)

All 73 original proof claims now have supporting calculations and explanations immediately beneath them. The report covers all seven formal results, all 35 numbered equations, and the additional analytic claims. The team optimality lemma's worked derivation is on pages 6–8. Source mappings and supplementary numerical checks follow the proofs.

The expanded arguments support the stated results under the model's assumptions. This is a model-assisted mathematical review, not a proof-assistant certificate.

## Reviewed source

The exact reviewed manuscript is preserved in `source/`, with hashes in `review_manifest.json`. The submission PDF linked above differs from that snapshot only by three vertical-spacing adjustments; text, formulas, claims, and proofs are unchanged. The report is specific to this letter.

## Build and check

With TeX Live installed:

```bash
python3 build_report.py
python3 qa_report.py
```

The canonical standalone `.tex` is the report source. The builder compiles it twice and updates the adjacent PDF. QA requires PyMuPDF. To compile directly, run `pdflatex TINA_LCSS_Submission_Lamport_Report.tex` twice.

## Reproduce the numerical checks

```bash
python3 check_audit.py
```

The script requires NumPy and SciPy. It checks 48 continuous-time Gaussian-team systems, 18 discrete-time systems, and 200 independent refresh schedules. The expanded report reran these checks successfully. Full results are in `audit_checks.json`. They corroborate finite-dimensional consequences; the written proofs establish the full-history and all-schedules claims.

`python3 package_report.py` creates a ZIP containing the current report and supporting records.

## Supporting records and method

- `frozen_conversion.json`, `forward_ledger.json`, and `reverse_graph.json` preserve the original source mapping and audit records. Their claim IDs remain useful locators; their references to the earlier K-L/K-H calculation layout are historical. The current expanded derivations and review conclusions are in the report linked above.
- `review_manifest.json` records manuscript identity and current report hashes.
- `qa_summary.json` records checks on the current PDF.
- `plugin/` preserves the WWresearch Lamport Proof instructions and license used for the original review.

Method: [WWresearch/lamport-proof](https://github.com/WWresearch/lamport-proof), pinned revision `c5466f44d6ef0fff983ad67a46bc54e39858826f`.
