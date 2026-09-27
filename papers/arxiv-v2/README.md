# TINA arXiv v2 working draft

This is a local revision draft of [arXiv:2609.06351v1](https://arxiv.org/html/2609.06351v1), prepared September 26, 2026. It has not been submitted or published as v2.

- [Read the draft](tina-v2.pdf) (52 pages including the new toolkit and glossary; baseline: 44 pages).
- [Edit the LaTeX source](main.tex).
- [Read the independent clarity-pass review](CLARITY_REVIEW.md) or the [earlier simplification review](INDEPENDENT_REVIEW.md).
- [Review the scoped change log](CHANGELOG.md) or [exact source diff](changes-from-v1.diff).
- [Read the numerical verification record](verification.json).
- [Clarity instructions](clarity-notes.md), copied unchanged from the root `clarifyTINA2.md`.
- [Original simplification instructions](simplification-notes.md), copied unchanged from the root `simplifyTINA.md`.

The baseline is `../full/main.tex`, which is byte-identical to `../../submissions/arxiv/source/main.tex`. Its SHA256 is `9476b7a7a155a79076c818b20bd6362b77990e4e24d6cccdf0e9df743bf44238`. The original manuscript and submission folder were not modified.

Edits follow the mathematical simplification plan, the subsequent clarity instructions, and their consequential changes. Existing prose outside that scope is retained. Title, authors, related-work prose, bibliography, all six original figures, and all reported numerical values are preserved. The clarity pass adds expanded explanations and proofs, an assumptions table, two explanatory figures, and toolkit and glossary appendices. The title-page date is September 2026, updated at the author's request.

## Build and verify

From the repository root, with Python, NumPy, and a TeX installation containing `pdflatex`, `bibtex`, and `IEEEtran.bst`:

```powershell
python papers/arxiv-v2/build.py
python papers/arxiv-v2/verify_revision.py
python -m unittest discover -s tests -v
```

The build writes only to this folder, with intermediate files in `build/`. The source closure is `main.tex`, `appendices.tex`, `references.bib`, and `figures/*.pdf`. To regenerate the two new explanatory figures, run `python papers/arxiv-v2/make_clarity_figures.py` (requires Matplotlib and NumPy). The verification script writes `verification.json` and refreshes `changes-from-v1.diff`; it reads the existing archived numerical results without overwriting them. The root repository build continues to target v1.

## Completed checks

- Independent review checked the simplification and clarity passes, including the expanded proofs, assumptions, equal-rate integral case, and appendix mathematics. Targeted wording and reference findings were resolved; final source hashes are recorded in the clarity review and `verification.json`.
- All 25 existing repository tests passed. These check the shared numerical implementation and v1 package integrity; the separate v2 verification script checks this revision's source and numerical identities.
- A complete indicator-basis optimization of a non-Gaussian finite-state team with non-diagonal Q and a nonzero mean verifies the composition law to approximately `7.55e-15` absolute regret error.
- The old and new canonical omission expressions agree to `1.11e-16`. Direct scalar minimization reproduces all 4,896 archived Experiment 4 grid optima; the closed form agrees with the archived theory to `2.22e-16`.
- The final LaTeX log has no warnings, undefined references/citations, duplicate labels, or overfull boxes. All 52 PDF pages were rendered and visually inspected at overview scale, including the new figures, assumptions table, expanded proofs, toolkit, and glossary.

No numerical experiments were regenerated. The initial simplification produced 39 pages; the requested explanations, expanded proofs, and appendices bring this clarity revision to 52 pages.
