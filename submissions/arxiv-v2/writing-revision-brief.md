# TINA alternative: writing and exposition revision brief

Implement the targeted revisions below in `submissions/arxiv-v2/main-alt.tex` and `submissions/arxiv-v2/technical-appendices-alt.tex`. Review the companion only where terminology or cross-references are affected.

This brief derives from the writing audit of commit `284a0e02dd0b1017d87fcd5837a1b68cd09b7e3b`. Page numbers refer to its 32-page `tina-v2-alt.pdf`; use section names and equation labels to locate passages after pagination changes. Finding numbers are retained for correspondence with the audit.

Keep the current abstract unchanged. Preserve theorem statements, assumptions, proofs, equations, experiments, numerical interpretations, citations, and figures except for the specific notation corrections requested below. This is a focused exposition pass, not a general shortening or restructuring of the paper. Leave revision h unchanged.

## 1. Qualify the final design advice

**Priority:** High. **Location:** Section 7, “Design implication,” p. 21; compare Section 4.1, p. 10.

The current conclusion says:

> expand information scope as long as the marginal decision value of broader information exceeds the predictive value lost in obtaining it.

Although described as a heuristic, this sounds like a procedure that stops at the first unfavorable increment. Section 4.1 correctly states that stopping at the first decline requires unimodality and that general graphs require comparison of all admissible radii.

**Required change:** Attach the single-crossing qualification to the marginal advice and give the general finite-graph rule separately. Preserve the marginal intuition and the exhaustive-search requirement.

Suggested wording:

> Under the single-crossing condition, the best radius balances the marginal gain in decision information against the loss from delay. On a general finite graph, compare composed regret over all admissible radii.

Ensure the wording remains consistent with endpoint optima; marginal equality applies to an interior optimum.

## 2. Add a short radius-first preview

**Location:** End of the introduction.

Add a short radius-first preview at the end of the introduction: choose a radius by balancing captured decision information against age; the line model supplies the explicit omission curve.

Limit this item to that preview. Retain the current section order, theorem order, contribution list, and placement of the coupling calculation.

## 4. Consolidate the synchronized-snapshot explanation

**Priority:** Medium. **Locations:** Introduction, Section 2.2, Section 4.1, and Section 7.

The replacement of fresh nearby readings by older readings is explained repeatedly. Section 4.1 currently includes:

> To form a synchronized snapshot, the agent uses an older reading from the nearby sensor too. This is why widening the snapshot can hurt.

The example is useful, but the restriction has already been introduced in the abstract, introduction, Figure 1, and Section 2.2.

**Required change: Consolidate the explanation in its natural locations:**

- Leave the abstract unchanged.
- Retain Figure 1 and its explanation of propagation and common-time readings.
- Keep the complete observation definition and information-inclusion argument in Section 2.2.
- Replace the repeated nearby-sensor example in Section 4.1 with one sentence connecting the scope/age tradeoff to the earlier definition, then proceed with the radius criterion.
- Keep a concise reminder in Section 7 without teaching the same example again.

Preserve the substantive distinction: adding usable observations without discarding existing ones cannot increase optimal cost. Do not imply that mixed-age or history-based architectures are covered by the synchronized-snapshot result.

## 5. Use a consistent name for the no-information baseline

**Priority:** Medium. **Locations:** Section 4.1 and numerical text/captions.

Section 4.1 introduces the phrase:

> Define the fraction of open-loop loss eliminated by the snapshot as ...

The body has already defined the same quantity as no-information loss. “Open-loop” may suggest a new control-theoretic concept to the intended reader.

**Required change:** Prefer “no-information loss” consistently in the main narrative and relevant captions. If “open-loop” is retained, explicitly define it as a synonym at first use. Keep the symbol `R_\infty` and its mathematical definition unchanged. Align the companion glossary if necessary.

## 6. Correct small notation inconsistencies

**Priority:** Medium. **Locations:** Section 4.3, p. 12, and Appendix D, p. 32.

### Interval observations

Equation (34), labeled `eq:canonical_radius_observation`, defines `\mathcal O_r`. The new conditional-mean display instead uses plain `O_r` on both sides.

**Required change:** Use `\mathcal O_r` consistently in that display. The observation and conditioning meaning remain unchanged.

### Per-hop delay

Appendix D uses `a` for the per-hop delay coefficient in `exp(-2ar/T)`. The main composition proof uses `a=exp(-\tau/T)` for the prediction factor.

**Required change:** Give the per-hop delay coefficient a distinct symbol in Appendix D, updating its reference setting and sweep consistently. Explain its meaning where introduced. Repository configuration keys need not change; map a key to the manuscript symbol if needed. Do not change parameter values or numerical code.

The generic-action `x` versus observation-based-action `u` distinction is lower priority: if it needs a bridge, explain it once rather than renaming actions throughout the paper.

## 7. Lead related work with the closest comparisons

**Priority:** Medium. **Locations:** Sections 6.1–6.3, pp. 17–19.

The direct Marschak–Radner marginal-condition comparison closes Section 6.1. Jiang and Zhou and Munari et al. appear at the end of Section 6.3, after more general history. These comparisons are present and substantive, but their placement makes the reader work to discover the paper's precise relationship to prior work.

**Required change:** Lead the relevant subsections with the closest comparisons, then group the remaining literature by the question it answers. Reduce author-by-author enumeration and repeated explanations of the exogenous-state distinction.

Preserve:

- The precise Marschak–Radner chapter and equation locators and the attribution of the decomposition, marginal condition, and group-information example.
- The substantive Ballotta comparison.
- The Jiang–Zhou and Munari comparisons.
- The distinctions among dynamic feedback, remote estimation, and synchronized team decisions.
- Existing citations and substantive comparisons; regrouping is not authorization to drop literature.

State the contribution positively as the decision-target-dependent neighborhood-radius calculation and finite-graph comparison. Do not suggest that scope-dependent latency itself is new. No independent novelty claim or additional literature search is required by this item.

## 8. Remove restoration history from the reproducibility appendix

**Priority:** Low. **Location:** Appendix D, finite noncanonical graphs, p. 32.

Representative passages:

> The original Experiment 6 uses ...

> The restored figure reuses the original PDF bytes.

**Required change:** Describe the final experiment directly. Delete the figure-restoration sentence from the manuscript. Preserve experiment identifiers, seeds, archive paths, verification commands, and all reproduction details. Keep byte-preservation or restoration history in the repository report if useful.

An experiment identifier is legitimate reproducibility information; do not remove it merely because it reflects the repository's numbering.

## 9. Interpret the two spatial length scales

**Priority:** Low. **Location:** Theorem 3 and its interpretation, p. 13.

The theorem lists the comparative statics. The correlation-length threshold and broad-decision limit already have useful interpretations.

**Required change:** Add at most one concise explanation of the contrast: longer state correlations let a local reading predict farther-away state, whereas broader decision weights make remote states matter more to the target. Tie this interpretation to the canonical model.

Do not repeat every comparative static or create a second theorem summary.

## 10. Split the mixed-purpose paragraph in Appendix A

**Priority:** Low. **Location:** “Common information and degenerate normalization,” p. 27.

The paragraph moves through common-information optimality, nonlinear targets, convergence with delay, Markov monotonicity, the best constant action, and the case `R_\infty=0`.

**Required change:** Separate it into short paragraphs with descriptive leads for:

1. Common-information optimality.
2. Delayed common snapshots.
3. Degenerate normalization.

Preserve every assumption and result. Keep these details in the appendix; do not move projection machinery into the main narrative.

## Implementation and verification

1. Apply only the revisions above. Keep the abstract unchanged and item 2 limited to the requested preview.
2. Preserve the worked `0.35T` crossover, whole-old-state conditional-mean assumption, coupled-policy rescaling argument, all boundary cases, the canonical omission derivation, and the distinction between an observation cap and a graph diameter.
3. Preserve all six figures and their numerical interpretations, including the fixed-ring `1, 2, 5` hop result and the four finite-graph examples.
4. Rebuild with `python submissions/arxiv-v2/build-alt.py`, including the companion's external references.
5. Run `python submissions/arxiv-v2/verify-alt.py`. Its related-work check currently encodes the exact `rev2.md` replacements; update that structure-specific check transparently for the authorized reorganization. Retain substantive figure, data, mathematical, and bibliography-preservation checks.
6. Check equation, theorem, figure, appendix, and citation references. Inspect the changed PDF pages for layout problems.
7. Report the completed changes, actual page counts, and any unresolved issues. A manuscript implementation or commit is not part of preparing this brief; follow the author's subsequent authorization for those steps.

Desired result: direct, reader-aware exposition with one clear home for each important scope distinction, precise attribution, and no loss of technical content.
