# TINA arXiv v2 working draft

This is a local revision draft of [arXiv:2609.06351v1](https://arxiv.org/html/2609.06351v1), prepared September 26, 2026. It has not been submitted or published as v2.

- [Read the draft](tina-v2.pdf) (39 pages; baseline: 44 pages).
- [Edit the LaTeX source](main.tex).
- [Read the independent mathematical and clarity review](INDEPENDENT_REVIEW.md).
- [Review the scoped change log](CHANGELOG.md) or [exact source diff](changes-from-v1.diff).
- [Read the numerical verification record](verification.json).
- [Original simplification instructions](simplification-notes.md), copied unchanged from the root `simplifyTINA.md`.

The baseline is `../full/main.tex`, which is byte-identical to `../../submissions/arxiv/source/main.tex`. Its SHA256 is `9476b7a7a155a79076c818b20bd6362b77990e4e24d6cccdf0e9df743bf44238`. The original manuscript and submission folder were not modified.

Edits follow the mathematical simplification plan and its consequential changes. Existing prose outside that scope is retained. Title, authors, formatting, related-work section, bibliography, all six figures, and all reported numerical values are preserved. The title-page date is September 2026, updated at the author's request.

## Build and verify

From the repository root, with Python, NumPy, and a TeX installation containing `pdflatex`, `bibtex`, and `IEEEtran.bst`:

```powershell
python papers/arxiv-v2/build.py
python papers/arxiv-v2/verify_revision.py
python -m unittest discover -s tests -v
```

The build writes only to this folder, with intermediate files in `build/`. The source closure is `main.tex`, `references.bib`, and `figures/*.pdf`. The verification script writes `verification.json` and refreshes `changes-from-v1.diff`; it reads the existing archived numerical results without overwriting them. The root repository build continues to target v1.

## Completed checks

- Independent agent reviewed the complete manuscript, checked the revised proofs analytically, and verified the three small follow-up fixes. A subsequent author-requested title-date update is the only manuscript change since that review; the current hash is in `verification.json`.
- All 25 existing repository tests passed. These check the shared numerical implementation and v1 package integrity; the separate v2 verification script checks this revision's source and numerical identities.
- A complete indicator-basis optimization of a non-Gaussian finite-state team with non-diagonal Q and a nonzero mean verifies the composition law to approximately `7.55e-15` absolute regret error.
- The old and new canonical omission expressions agree to `1.11e-16`. Direct scalar minimization reproduces all 4,896 archived Experiment 4 grid optima; the closed form agrees with the archived theory to `2.22e-16`.
- The final LaTeX log has no warnings, undefined references/citations, duplicate labels, or overfull boxes. All 39 PDF pages were rendered and visually inspected at overview scale, with detailed inspection of the new innovation, composition, and canonical proofs.

No numerical experiments were regenerated. The original layout was retained, so the mathematical simplification reduces the full PDF by five pages rather than attaining the notes' approximate nine-page reduction target.
