# Changes from arXiv v1

The revision is confined to `papers/arxiv-v2/`. The exact manuscript diff is in `changes-from-v1.diff`; the independent review is in `INDEPENDENT_REVIEW.md`.

## Mathematical simplification

| Location | Change requested in simplifyTINA.md |
| --- | --- |
| Section 2.2 | Fresh-local and stale-global are current/delayed snapshots. The illustrative hybrid uses two snapshots. The radius endpoints now agree by definition, with zero local delay and a finite connected graph for the global endpoint. |
| Section 3.1 | Merge benchmark and general-predictability subsections. Define both loss shares by regret ratios. Replace common-information proposition with a sentence and general crossover theorem with an observation. Remove the nested-history monotonicity argument; specify the Markov and mean-square mixing conditions. |
| Section 3.2 | Introduce the centered decision and innovation split (new Lemma 2). Prove stale-global regret by eliminating the predictable error. Explain the stationary non-Gaussian AR(1) extension. |
| Section 3.3 | Keep the crossover result and proof, updating its reference to the unnumbered observation. |
| Section 3.4 | Preserve the aggregate-coupling formulas; use independence of current local snapshots in the local-policy proof. |
| Section 4 | Remove history information sets, the snapshot-history sufficiency lemma, centered-subspace machinery, and time-shift operators. Keep the covariance, snapshot family, spatial omission definitions, endpoints, and decision-relevance discussion. Prove composition by the same innovation split and agentwise rescaling. |
| Section 5.1 | Merge the radius family and marginal-balance treatment. Retain exact integer-hop comparisons and the temporal/spatial decomposition. Demote marginal balance to Proposition 2; state its interior necessary condition and condense the conditional uniqueness/comparative-statics discussion. |
| Section 5.2 | Merge canonical model and optimal-radius analysis. Replace exterior covariance integration with the spatial OU tail self-similarity argument (Lemma 3). Compute the omission constant from covariance and variance. Derive the unique radius by one derivative; retain the arbitrary-eta0 formula and capped version. Keep the positivity threshold, four comparative statics, integral argument, and three-length interpretation; add the two asymptotic interpretations with the positive-radius qualification. |
| Section 6.1 | Move the graph-Laplacian covariance model here. Use the existing snapshot calculations and retain numerical values and figures. |
| Section 8 | Update result references, distinguish an interior marginal condition from a global optimum, and replace history/Gaussianity scope claims with the snapshot/common-innovation assumptions. |

The pointwise infinite-line regret convention is retained in the canonical model. The finite cap restricts observation radius on the infinite line; it is explicitly distinguished from a finite graph whose diameter provides complete information.

## Necessary consistency edits

- Title-page date: updated to September 2026 at the author's request after review; mathematical content is unchanged.
- Introduction: add a single snapshot clarification where the three architectures are introduced.
- Abstract: qualify the temporal law by affine decisions and a common-rate Gauss-Markov environment; qualify marginal balance as an interior-optimum condition. No abstract rewrite.
- Open-loop regret and numerical methodology: remove two redundant expectations because the established Q-weighted L2 norm already includes expectation.
- Decision-relevant smoothness: explicitly retain the cost metric Q alongside K in the ingredient summary.
- Update mathematical cross-references. Stable LaTeX labels are retained where possible, including two labels whose prefixes reflect their former theorem/proposition type.

The last three precision changes were checked by the independent reviewer. The original related-work text, bibliography entries, figures, numerical values, and unrelated narrative were not rewritten.

## Result numbering after simplification (before the clarity pass)

| v1 | v2 |
| --- | --- |
| Lemma 1: fixed-architecture projection | Lemma 1, unchanged |
| Proposition 1: common-information projection | Sentence in Section 3.1 |
| Theorem 1: generic crossover | Observation, Eq. (39) |
| New innovation split | Lemma 2, Eq. (47) |
| Theorem 2: stale-global regret | Theorem 1 |
| Theorem 3: fresh-local/stale-global crossover | Theorem 2 |
| Proposition 2: aggregate coupling | Proposition 1 |
| Lemma 2: snapshot-history sufficiency | Removed |
| Theorem 4: composition | Theorem 3 |
| Proposition 3: nested information | Short remark in Section 5.1 |
| Theorem 5: marginal balance | Proposition 2 |
| Proposition 4: generic exponential radius | Eqs. (113)-(114), within Theorem 4 proof |
| Proposition 5: canonical omission | Lemma 3 |
| Theorem 6: canonical radius | Theorem 4 |

Corollary 1 and Remark 1 are retained. There are now nine numbered lemmas, propositions, and theorems, as proposed in the notes. Existing shared numerical documentation and scripts continue to describe v1; this folder supplies the v2 numbering map without rewriting the baseline reproduction package.

## Review and validation

The independent reviewer found no theorem-level error and approved the final targeted fixes. The final source hash and numerical checks are recorded in `verification.json`. The initial simplification PDF had 39 pages, compared with 44 in the baseline; the subsequent clarity revision has 52 pages. The existing typesetting and unaffected wording were retained rather than changing layout to meet the notes' approximate page estimates.


## Clarity pass (September 26, 2026)

Applied `clarifyTINA2.md` within the existing mathematical structure. The verbatim instructions are archived in `clarity-notes.md`; independent findings and their resolution are in `CLARITY_REVIEW.md`.

- Sections 2--5: applied all 42 inline recommendations (2-A--B, 3-A--T, 4-A--H, 5-A--L), expanding the projection, innovation, aggregate, composition, omission, and optimal-radius derivations and their interpretations.
- Added the Section 3 roadmap, snapshot timing diagram, assumptions table, and Section 5 marginal-rate illustration. Added entries to the notation table and replaced brittle numeric cross-references with labels.
- Added Appendix A, Mathematical Toolkit (seven subsections), and Appendix B, Glossary. All result proofs remain in the main text.
- Preserved theorem conclusions, original numerical results, bibliography, related-work prose, and the six original figures. The prior simplification's unified snapshot and innovation treatment remains intact.
- Qualified the explanatory notes where needed: stationarity and fixed one-time distributions; affine Gaussian conditional means; singular Gaussian covariance; equal inverse-length limits; continuous field versions; spatial-only versus temporal assumptions; null modes versus useful observations; finite caps versus finite graphs; necessary versus sufficient optimality conditions.
- Added reproducible vector-figure generation and appendix-aware build and verification. Equation and figure numbering now reflects the new material; the earlier map above records the simplification stage only.

Validation: independent mathematical review; all 25 repository tests; revision-specific numerical identities and 4,896 archived grid comparisons; a 52-page build without warnings, undefined references, or overfull boxes; visual inspection of the rendered PDF. No experiments were regenerated.


## Shorter continuous refinement (`revise-v2b.md`)

The active paper is now `tina-v2-b.pdf`; `tina-v2-a.pdf` preserves the recovered 39-page earlier draft. The current paper is 32 pages including references, with main text ending on page 29. Section 3 begins on page 7, and its general local?global crossover theorem appears on page 10. The 52-page pre-shortening draft remains in commit `25185a8`.

- Preserved Sections 1?8, the early large-system threshold, established notation, all nine numbered principal results, and the normal-equation corollary. The abstract, title, authors, related-work prose, bibliography, and original experiment figures are unchanged.
- Section 2: consolidated graph, state, action, cost, and regret definitions; retained the projection lemma, its proof, and coupled conditional normal equations. Removed repeated model interpretations and moved basic projection explanations to the companion.
- Section 3: retained the OU SDE and transition, short innovation lemma, stale-global regret, crossover, and aggregate-coupling example. Kept the independence/normal-equation argument for the local policy; moved expanded matrix arithmetic to Supplement S1.
- Section 4: kept composition in place with the innovation/rescaling/stationarity proof and one explained-share equivalent. Retained decision relevance as its main explanatory home.
- Section 5: retained marginal balance and its derivative proof, spatial tail self-similarity, omission constant, radius theorem, threshold, comparative statics, cap distinction, and limiting interpretations. Moved the expanded covariance integral to Supplement S2.
- Section 6: retained all six experiments and the six original figure assets. Combined the radius-curve and regime-map discussion, shortened methodology, and moved detailed settings and grid-error diagnostics to Supplement S3.
- Section 7: retained verbatim prose. Section 8: consolidated repeated decision-relevance and static-team explanations while retaining limitations and extensions.
- Separate mathematical companion: preserved the toolkit and glossary, plus the timing diagram, assumptions table, and marginal-rate illustration. Added the factor-of-one-half and constant-policy explanation moved out of the main paper.
- Built a three-document source package with resolved, linked external references. The PDF filenames follow the author's a/b naming; the earlier a PDF is checked against its original committed bytes.

Review corrections clarify sufficient information in a hybrid architecture, strict monotonicity for uniqueness, the covariance normalization, and the companion's mixing entry. These do not change the stated results. See `SHORTENING_REVIEW.md` and `verification.json` for the final independent review and validation.
