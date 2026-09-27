# TINA arXiv v2 working draft

This is a local revision draft of [arXiv:2609.06351v1](https://arxiv.org/html/2609.06351v1), prepared September 26, 2026. It has not been submitted or published as v2.

- [Read the current v2-b draft](tina-v2-b.pdf) (32 pages including references; main text ends on page 29).
- [Supplementary proofs and numerical details](tina-v2-b-supplement.pdf) (7 pages).
- [Mathematical companion](tina-v2-b-companion.pdf) (8 pages: toolkit, glossary, timing diagram, assumptions table, and marginal-rate illustration).
- [Earlier v2-a PDF](tina-v2-a.pdf) (39 pages, recovered unchanged from commit `8c41a50`).
- [Edit the LaTeX source](main.tex).
- [Read the shortening review](SHORTENING_REVIEW.md), the [historical clarity-pass review](CLARITY_REVIEW.md), or the [earlier simplification review](INDEPENDENT_REVIEW.md).
- [Review the scoped change log](CHANGELOG.md) or [exact source diff](changes-from-v1.diff).
- [Read the numerical verification record](verification.json).
- [Current revision instructions](revise-v2b.md).
- [Clarity instructions](clarity-notes.md), copied unchanged from the root `clarifyTINA2.md`.
- [Original simplification instructions](simplification-notes.md), copied unchanged from the root `simplifyTINA.md`.

The baseline is `../full/main.tex`, which is byte-identical to `../../submissions/arxiv/source/main.tex`. Its SHA256 is `9476b7a7a155a79076c818b20bd6362b77990e4e24d6cccdf0e9df743bf44238`. The original manuscript and submission folder were not modified.

The current revision follows `revise-v2b.md`: retain Sections 1–8 and the established notation, shorten setup and proof arithmetic, and separate the teaching material. Section 3 begins on page 7 and the local–global crossover theorem appears on page 10. All nine numbered lemmas, propositions, and theorems, the coupled normal-equation corollary, and all six experiments remain in the paper. Detailed aggregate-coupling arithmetic, the canonical variance integral, and numerical diagnostics are in the supplement; the toolkit and glossary are in the companion. Title, authors, abstract, related-work prose, bibliography, and the six original figure files are preserved. The title-page date remains September 2026.

## Build and verify

From the repository root, with Python, NumPy, and a TeX installation containing `pdflatex`, `bibtex`, and `IEEEtran.bst`:

```powershell
python papers/arxiv-v2/build.py
python papers/arxiv-v2/verify_revision.py
python -m unittest discover -s tests -v
```

The build writes the three current PDFs above, with intermediate files in `build/`. It never overwrites `tina-v2-a.pdf`. The source closure is `main.tex`, `supplement.tex`, `supplement-body.tex`, `companion.tex`, `appendices.tex`, `references.bib`, and `figures/*.pdf`. Repeated LaTeX passes resolve linked references between the three PDFs using `xr-hyper`; keep them together when downloading. To regenerate the two explanatory figures in the companion, run `python papers/arxiv-v2/make_clarity_figures.py` (requires Matplotlib and NumPy). The verification script writes `verification.json` and refreshes `changes-from-v1.diff`; it reads the archived numerical results without overwriting them. The root repository build continues to target v1.

## Completed checks

- Independent review checked the shortened proofs, retained assumptions and results, numerical fidelity, and cross-document references. Earlier reviews remain as historical records of their respective drafts.
- All 25 existing repository tests passed. These check the shared numerical implementation and v1 package integrity; the separate v2 verification script checks this revision's source and numerical identities.
- A complete indicator-basis optimization of a non-Gaussian finite-state team with non-diagonal Q and a nonzero mean verifies the composition law to approximately `7.55e-15` absolute regret error.
- The old and new canonical omission expressions agree to `1.11e-16`. Direct scalar minimization reproduces all 4,896 archived Experiment 4 grid optima; the closed form agrees with the archived theory to `2.22e-16`.
- The three PDFs compile without unresolved references or citations, duplicate labels, or overfull boxes. Rendered pages and cross-document link destinations were checked.

No numerical experiments were regenerated. The initial simplification produced 39 pages; the clarity pass produced 52 pages. This shortening pass produces a 32-page paper with supporting material separate. The 52-page PDF remains available in commit `25185a8` at its historical path `papers/arxiv-v2/tina-v2.pdf`.
