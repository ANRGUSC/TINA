# Revision d review

Applied `revs-v2-c.md` on September 27, 2026. Final package: main paper 32 pages, supplement 5 pages, mathematical companion 8 pages.

## Scope and independent review

The independent reviewer checked the assumptions table, compressed reproducibility section, and cross-document references against revision c and the numerical implementation. No unresolved correctness or clarity issues remain. Two review suggestions were incorporated: distinguish Experiment 2's sampled boundary estimator from analytical normalization, and reference the two normalized variance components explicitly in Experiment 3.

All nine main proofs and ten formal result environments remain unchanged from c. Supplement S1 and S2, the main numerical-results section, related work, and the original figures and bibliography are unchanged. The table moved from the companion to the main paper; the companion now points to it. No experiments were rerun.

## Verification

- `verify_revision.py` passes source/reference checks, the non-Gaussian coupled-team enumeration, canonical omission equivalence, and all 4,896 archived scalar-grid checks.
- LaTeX builds all three documents without undefined references/citations, duplicate labels, or overfull boxes.
- All 80 external PDF destinations resolve to the corresponding revision-d documents.
- All 45 pages were rendered and visually inspected, including the assumptions table and compressed S3. The local Poppler executable crashed; rendering used PyMuPDF.
- All earlier a/b/c PDFs retain their pre-edit SHA256 hashes, recorded in `preserved-pdfs.json`.

Reviewed source SHA256 hashes:

| Source | SHA256 |
|---|---|
| main.tex | `4ff6920afb45bebf68d332c7f0dc230f27d3125c37eba4cf04b35c0c6c5025c7` |
| supplement-body.tex | `a28e9542adc7c7023bab7077f04e6798041358df829401b2a620c501ec17152e` |
| appendices.tex | `b80e55ed826d68cc4700ba207c5c119d342c072e5eb6eead390e556dbd012692` |
