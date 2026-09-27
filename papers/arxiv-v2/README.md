# TINA arXiv v2 working draft

This is a local revision draft of [arXiv:2609.06351v1](https://arxiv.org/html/2609.06351v1), prepared September 26, 2026. It has not been submitted or published as v2.

- [Read the current v2-e draft](tina-v2-e.pdf) (37 pages: 32 through references, followed by Appendices A-C on pages 33-37).
- [Earlier v2-d paper](tina-v2-d.pdf), [supplement](tina-v2-d-supplement.pdf), and [companion](tina-v2-d-companion.pdf).
- [Mathematical companion](tina-v2-e-companion.pdf) (8 pages: toolkit, glossary, timing diagram, and marginal-rate illustration).
- [Earlier v2-c PDF](tina-v2-c.pdf) (32 pages), with its [supplement](tina-v2-c-supplement.pdf) and [companion](tina-v2-c-companion.pdf).
- [Earlier v2-b PDF](tina-v2-b.pdf) (52 pages, restored unchanged from commit `25185a8`).
- [Earlier v2-a PDF](tina-v2-a.pdf) (39 pages, recovered unchanged from commit `8c41a50`).
- [Edit the LaTeX source](main.tex).
- [Read the revision-d review](REVISION_D_REVIEW.md).
- [Read the shortening review](SHORTENING_REVIEW.md), the [historical clarity-pass review](CLARITY_REVIEW.md), or the [earlier simplification review](INDEPENDENT_REVIEW.md).
- [Review the scoped change log](CHANGELOG.md) or [exact source diff](changes-from-v1.diff).
- [Read the numerical verification record](verification.json).
- [Revision-e integration record](REVISION_E_REVIEW.md); [revision-d instructions](revs-v2-c.md).
- [Clarity instructions](clarity-notes.md), copied unchanged from the root `clarifyTINA2.md`.
- [Original simplification instructions](simplification-notes.md), copied unchanged from the root `simplifyTINA.md`.

The baseline is `../full/main.tex`, which is byte-identical to `../../submissions/arxiv/source/main.tex`. Its SHA256 is `9476b7a7a155a79076c818b20bd6362b77990e4e24d6cccdf0e9df743bf44238`. The original manuscript and submission folder were not modified.

Revision e incorporates the compact technical supplement into the main PDF after the references: Appendix A (aggregate-coupling calculations), Appendix B (canonical spatial omission), and Appendix C (numerical reproducibility). References and links use ordinary appendix numbering. The mathematical companion remains separate. Mathematical content, proofs, numerical results, and figures are preserved from d; edits are restricted to integration, numbering, and document-role wording. The title-page date remains September 2026.

## Build and verify

From the repository root, with Python, NumPy, and a TeX installation containing `pdflatex`, `bibtex`, and `IEEEtran.bst`:

```powershell
python papers/arxiv-v2/build.py
python papers/arxiv-v2/verify_revision.py
python -m unittest discover -s tests -v
```

The build writes the two current revision-e PDFs above, with intermediate files in `build/`. It never overwrites `tina-v2-a.pdf` `tina-v2-b.pdf`, or any revision-c or revision-d PDF. The source closure is `main.tex`, `technical-appendices.tex`, `companion.tex`, `appendices.tex`, `references.bib`, and `figures/*.pdf`. Repeated LaTeX passes resolve linked references between the paper and companion using `xr-hyper`; keep them together when downloading. To regenerate the two explanatory figures in the companion, run `python papers/arxiv-v2/make_clarity_figures.py` (requires Matplotlib and NumPy). The verification script writes `verification.json` and refreshes `changes-from-v1.diff`; it reads the archived numerical results without overwriting them. The root repository build continues to target v1.

## Completed checks

- Independent review checked the shortened proofs, retained assumptions and results, numerical fidelity, and cross-document references. Earlier reviews remain as historical records of their respective drafts.
- All 25 existing repository tests passed. These check the shared numerical implementation and v1 package integrity; the separate v2 verification script checks this revision's source and numerical identities.
- A complete indicator-basis optimization of a non-Gaussian finite-state team with non-diagonal Q and a nonzero mean verifies the composition law to approximately `7.55e-15` absolute regret error.
- The old and new canonical omission expressions agree to `1.11e-16`. Direct scalar minimization reproduces all 4,896 archived Experiment 4 grid optima; the closed form agrees with the archived theory to `2.22e-16`.
- The current PDFs compile without unresolved references or citations, duplicate labels, or overfull boxes. Rendered pages and cross-document link destinations were checked.

No numerical experiments were regenerated. The initial simplification produced 39 pages; the clarity pass produced 52 pages. Revision d retains the 32-page paper and reduces the supplement from 7 to 5 pages. The 52-page PDF remains available in commit `25185a8` at its historical path `papers/arxiv-v2/tina-v2.pdf`.

Each substantive future revision should use a new letter, preserving the earlier PDFs. The current source and build target are revision e. All earlier PDFs remain preserved.
