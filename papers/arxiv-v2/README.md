# TINA arXiv v2 working draft

This is a local revision draft of [arXiv:2609.06351v1](https://arxiv.org/html/2609.06351v1), prepared September 26, 2026. It has not been submitted or published as v2.

- [Read the current v2-h draft](tina-v2-h.pdf) (31 pages: 25 through references, followed by Appendices A-D on pages 26-31).
- [Earlier v2-g paper](tina-v2-g.pdf) and [companion](tina-v2-g-companion.pdf).
- [Earlier v2-f paper](tina-v2-f.pdf) and [companion](tina-v2-f-companion.pdf).
- [Earlier v2-e paper](tina-v2-e.pdf) and [companion](tina-v2-e-companion.pdf).
- [Earlier v2-d paper](tina-v2-d.pdf), [supplement](tina-v2-d-supplement.pdf), and [companion](tina-v2-d-companion.pdf).
- [Mathematical companion](tina-v2-h-companion.pdf) (8 pages: toolkit, glossary, timing diagram, and marginal-rate illustration).
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

Revision e incorporates the compact technical supplement into the main PDF after the references: Appendix A (aggregate-coupling calculations), Appendix B (canonical spatial omission), and Appendix C (numerical reproducibility). References and links use ordinary appendix numbering. The mathematical companion remains separate. Subsequent explanatory edits add a two-sensor crossover example immediately after the introduction's opening paragraph, an edge-server example after Eq. (54), a sensor-reading explanation after Theorem 4, and a shorter common-rate limitation in Section 8. Revision f reduces Section 6 to three question-led illustrations: the local-global crossover, the scalar radius tradeoff, and decision relevance on a fixed ring. Original Figures 2, 3, and 5 are now Figures 1, 2, and 3; Appendix C covers only these illustrations. All theorem statements, proofs, analytical results, and the Section 3.4 shared-resource example are preserved. Existing numerical scripts and data remain unchanged; no supplement was added. Revision g simplifies Section 5 around the captured fraction G(r) and the physical-unit radius formula, retaining Proposition 2, Lemma 3, Theorem 4, single-crossing conditions, and comparative statics. The countable-observation detail and integral proof of monotonicity in the decision-relevance length appear in Appendix B. Revision h brings Theorem 3 forward, explains the innovation and local-policy derivations, and moves projection machinery into Appendix D of the same PDF. It shortens the introduction and discussion, unifies stationary covariance notation, and updates the companion links. The title-page date remains September 2026.

## Build and verify

From the repository root, with Python, NumPy, and a TeX installation containing `pdflatex`, `bibtex`, and `IEEEtran.bst`:

```powershell
python papers/arxiv-v2/build.py
python papers/arxiv-v2/verify_revision.py
python -m unittest discover -s tests -v
```

The build writes the two current revision-h PDFs above, with intermediate files in `build/`. It never overwrites `tina-v2-a.pdf` `tina-v2-b.pdf`, or any revision-c, revision-d, revision-e, revision-f, or revision-g PDF. The source closure is `main.tex`, `technical-appendices.tex`, `companion.tex`, `appendices.tex`, `references.bib`, and `figures/*.pdf`. Repeated LaTeX passes resolve linked references between the paper and companion using `xr-hyper`; keep them together when downloading. To regenerate the two explanatory figures in the companion, run `python papers/arxiv-v2/make_clarity_figures.py` (requires Matplotlib and NumPy). The verification script writes `verification.json` and refreshes `changes-from-v1.diff`; it reads the archived numerical results without overwriting them. The root repository build continues to target v1.

## Completed checks

- Targeted graph restoration in revision h: restored original Figure 6 as current Figure 4, following the decision-relevance figure, with a short Section 6.4 and Appendix C reproduction details. The manuscript grows by one page through references and one appendix page. Original figure bytes, existing figures, abstract, contributions, related work, theorem statements, and proofs are preserved. The OU equation remains in Section 3.2. `python scripts/verify_graph_restoration.py` reproduces the original experiment in scratch space: all 121 radius rows and 84 sweep rows agree with the archive to at most 2.34e-15, all graph inputs match, and an independent residual-error calculation validates conditioning. Reference optimal radii remain 2, 2, 3, and 2. See `../../submissions/arxiv-v2/graph-restoration-verification.json`. The original numerical code and archives are unchanged.

- Revision h: compiled and visually inspected all 29 manuscript pages and 8 companion pages. References and citations resolve without duplicate labels or overfull boxes. Theorem 3 now leads Section 4; Appendix D retains the projection proof and coupled normal equations. Theorems 2 and 4 and Section 6 match revision g verbatim. Earlier PDFs and numerical assets remain unchanged.

- Revision g: resolved cross-references, retained result numbering, unchanged numerical figure assets, preserved earlier PDFs, and inspected Section 5 and the Appendix B proof. Sections 1-4 are unchanged except the notation table and companion link target; Sections 6-8 are unchanged in source.

- Revision f: direct source comparisons confirm unchanged theorem, lemma, proposition, corollary, and proof blocks, and unchanged Appendices A-B. The retained figure assets match their archived bytes; the PDF has exactly three numerical figures in the requested order. Earlier independent reviews remain historical records of their respective drafts.
- The earlier revisions passed all 25 existing repository tests. These check the shared numerical implementation and v1 package integrity; the separate v2 verification script checks this revision's source and numerical identities.
- A complete indicator-basis optimization of a non-Gaussian finite-state team with non-diagonal Q and a nonzero mean verifies the composition law to approximately `7.55e-15` absolute regret error.
- The old and new canonical omission expressions agree to `1.11e-16`. Direct scalar minimization reproduces all 4,896 archived Experiment 4 grid optima; the closed form agrees with the archived theory to `2.22e-16`.
- The current PDFs compile without unresolved references or citations, duplicate labels, or overfull boxes. Rendered pages and cross-document link destinations were checked.

The graph-restoration audit reruns only Experiment 6 in scratch space; the publication figure is reused unchanged. Earlier simplification passes did not regenerate experiments. The initial simplification produced 39 pages; the clarity pass produced 52 pages. Revision d retains the 32-page paper and reduces the supplement from 7 to 5 pages. The 52-page PDF remains available in commit `25185a8` at its historical path `papers/arxiv-v2/tina-v2.pdf`.

The current source and build target remain revision h at the author's explicit request for this targeted restoration; its pre-restoration PDF is retained in commit `751902f`. Earlier lettered PDFs remain preserved.
