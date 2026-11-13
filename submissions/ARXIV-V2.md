# Current arXiv submission

`arxiv-v2/` contains the active v2 paper's submission sources and ready-to-use outputs:

- `main-v2.tex`: the single top-level document.
- `technical-appendices-v2.tex`: proofs and numerical reproduction details,
  included in the same paper.
- `references.bib` and `main-v2.bbl`: bibliography source and generated bibliography.
- `figures/`: exactly the six PDF figures used by the paper.
- `tina-v2.pdf`: compiled paper for reading, excluded from the upload ZIP.
- `tina-v2-source.zip`: source-only upload package.

From the repository root, run:

```powershell
python scripts/build_arxiv_v2.py
```

This uses an isolated temporary directory, checks LaTeX warnings, rebuilds
the paper and optional companion, and writes
`output/arxiv/tina-v2-source.zip`, with a copy in `arxiv-v2/`. The compiled paper
is written to both `output/pdf/tina-v2.pdf` and `arxiv-v2/tina-v2.pdf`.
The ZIP excludes the compiled
paper PDF and all companion, archive, and development material. Select
`main-v2.tex` as the top-level file and pdfLaTeX when submitting the ZIP.
The included `.bbl` matches that default job name. A local build also needs
BibTeX and `IEEEtran.bst` to regenerate it.

The optional mathematical companion is preserved in `arxiv-v2-companion/`.
It is not required to compile the submission: all technical proofs remain
in the paper. Revision h and development records are preserved in
`../archive/arxiv-v2-development/`, with a hash-checked relocation manifest.
Numerical code and data remain at their existing paths in `../numerics/`.
