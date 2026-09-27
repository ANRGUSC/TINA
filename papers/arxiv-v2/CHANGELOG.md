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

## Result numbering

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

The independent reviewer found no theorem-level error and approved the final targeted fixes. The final source hash and numerical checks are recorded in `verification.json`. The compiled PDF has 39 pages, compared with 44 in the baseline. The existing typesetting and unaffected wording were retained rather than changing layout to meet the notes' approximate page estimates.
