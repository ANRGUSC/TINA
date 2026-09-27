# Independent review of the shortened v2-b

Reviewed September 26, 2026 against `revise-v2b.md` and the clarity version at commit `25185a8`. Read the shortened main manuscript, the supplementary proofs and numerical details, and the mathematical companion. This review did not edit manuscript sources. It continues the earlier independent mathematical reviews while assessing the new shortening and separation of documents.

## Verdict

The shortening preserves the mathematical results and the paper's progression. The main text retains enough proof detail for a mathematically comfortable reader to follow the argument without the instructional companion. The detailed aggregate arithmetic, canonical covariance integration, numerical diagnostics, and background material are appropriately separated. No theorem-level mathematical error was found.

All three lemmas, four theorems, two propositions, and the conditional-normal-equations corollary retain their labels and roles. Sections 1–8 remain in their original order. The inspected main PDF has 32 pages including references; Section 3 starts on page 7, and the local–global crossover appears on page 10. This satisfies the note's priority of bringing the initial mathematical payoff forward. The separate proof/numerical supplement and companion have 7 and 8 pages respectively.

## Targeted findings and fixes

1. **Medium, mathematical qualification, resolved during review.** The shortened hybrid paragraph originally claimed that it contains stale-global information “only if” the summary preserves the full delayed state. The current local observation can complement a noninvertible summary: for time-constant two-component states, each agent's own value together with their sum reconstructs the full state. The revision agent changed this to a sufficient condition and stated that an arbitrary summary need not suffice. This preserves the intended comparison without an incorrect necessity claim.

2. **Low, uniqueness qualification, resolved during review.** The sufficient single-crossing condition initially said merely “decreasing” spatial marginal gain. Restoring “strictly decreasing” makes the claimed strict decrease of the difference and uniqueness explicit; weak decrease alone allows a plateau of optima.

3. **Low, extraction splice, resolved during review.** The supplementary numerical covariance paragraph initially read “For example, The graph covariance ...” after removal of its duplicated equation. The revision agent repaired the sentence.

4. **Low, precision/context checks sent to the revision agent.** In the main numerical methodology, explicitly say the covariance is scaled to average marginal variance one, because the immediately preceding noun is the graph Laplacian. In the companion glossary, say strong mixing is a sufficient condition for the temporal limit, rather than saying the shortened main text uses it; the main text now states the conditional-prediction convergence criterion directly. The supplement's “consequences following Lemma 1” locator can also refer more directly to the orthogonality paragraph that remains there. These edits do not change any result.

The revision agent also corrected an unsquared-distance interpretation of regret and removed an adjacent repetition of the common temporal decay assumption. The retained formula defines regret correctly as one-half the squared Q-distance.

## Mathematical preservation checks

- **Model and projection:** The compressed setup retains the action/state dimensions, measurable state-to-objective map, square integrability of the target, integrability of the additive cost, deterministic positive-definite Q, unconstrained actions, and exogenous information. Combining the cost and regret definitions does not change them. The closed-subspace proof and coupled normal equations remain in the main text. The warning against agentwise conditional means for coupled Q is retained.
- **Temporal law and crossover:** Centering, the conditional-mean-zero innovation, orthogonality, and stationarity all remain explicit. The short innovation proof correctly obtains its norm from the zero-policy case. The stale-global proof restores the mean in the optimal action and retains the trace identity. The non-Gaussian scalar AR(1) extension remains. The strict crossover and omission endpoints remain correct. Removing the expanded stochastic-calculus explanation changes no assumption.
- **Aggregate example:** The main proof retains the decisive independence and mean-equation steps, forcing `Q mu = 0` and hence zero means. The displayed norm/trace identities correctly yield the retained regret, omission, threshold, and large-system formulas. The supplement preserves the supporting rank-one inverse arithmetic. No local-policy result was replaced by an invalid conditional-mean shortcut.
- **Composition:** Rescaling preserves each agent's measurability; the finite-delay factor is nonzero. Stationarity identifies the old-time minimization with zero-delay regret. The main theorem keeps its unnormalized form and the explained-share product. The removal of a redundant third displayed variant does not change the result. The extension beyond Gaussianity and the coupled-Q qualification remain.
- **Radius optimization:** The one-hop criterion and its positive-explained-share logarithmic version remain, including the zero-share fallback. The general marginal-balance proposition retains differentiability, monotonicity, and `eta_S < 1`; its derivative proof is correct. Strict single-crossing and endpoint cases remain. The canonical optimizer retains the arbitrary-eta0 expression, cap, positivity threshold, and all four comparative statics. The cap is still distinguished from the finite-graph diameter endpoint.
- **Canonical omission:** The compact proof retains the conditional-variance ratio, spatial Markov boundary property, independent exterior tails, translation, and reflection arguments. The conditional tail variance is independent of the observation value in the stated Gaussian setting. The argument includes radius zero. Conversion from inverse lengths to lengths is correct: covariance equals `sigma^2 ell_s/(ell_c+ell_s)`, and target variance equals `sigma^2 ell_s(ell_c+2 ell_s)/(2(ell_c+ell_s)^2)`. The supplement preserves the full integral evaluation, including the equal-inverse-length limit previously checked independently.
- **Instructional material:** The companion retains the Gaussian singular-covariance qualification, affine conditional mean, Gaussian mean-square-integral interpretation, stationary AR assumptions, and distinction between graph spectral covariance and a GMRF on the original graph. Moving the assumptions table does not remove assumptions from the actual theorem statements. The table still correctly separates the purely spatial omission lemma from the temporal radius theorem.

## Numerical and document checks

The six original experiment figure PDFs and `references.bib` are byte-identical to commit `25185a8`. The shortened numerical discussion preserves the reported settings and outcomes: temporal-law deviations, paired crossover estimates, scalar radius minima, the 4,896-point canonical sweep, fixed-covariance decision-relevance results, and four finite-graph optima. Detailed grid errors and conditioning diagnostics are preserved in the supplement. The distinction between scalar checks and graph/field calculations remains explicit; the capped scalar example is not relabeled as full global information. No experiment was independently rerun for this review.

All source `ref` and `eqref` targets resolve across the three documents. An independent PDF inspection found no unresolved `??` references. Cross-document links are PDF `GoToR` actions to sibling PDFs, with named destinations; every referenced remote destination exists in its target PDF. Main-paper links reach supplementary Sections S1–S3; supplementary and companion references point back to the main-paper equation/result destinations. Keeping all three PDFs together preserves these relative links. Internal companion section references and external main-paper references retain their separate destinations.

Reader order remains coherent: the initial comparison is established before the composition theorem, which remains in Section 4; scope is then optimized in Section 5. Established notation is preserved, with no new `s(r)` substitution. Supporting documents introduce their relationship to the main paper. The main workflow is separately adjusting figure placement and performing final visual checks; this review does not claim to have visually inspected every PDF page.

## Final-source verification

Pending the final small precision edits and figure-placement pass. The core mathematical review is approved; final hashes and the resolution status of item 4 will be appended after the revision agent provides the final source state.

### Final resolved verdict

Independently rechecked the final source state. **All findings above are resolved.** The hybrid condition is sufficient, strict spatial marginal decrease is explicit, covariance normalization has the correct antecedent, the mixing glossary entry states a sufficient condition, and the supplementary proof points to the retained orthogonality identity. The companion's marginal-rate illustration now has a self-contained introduction.

**Final verdict: approved for the requested conservative shortening. No unresolved mathematical or targeted clarity issue remains.** The final source changes preserve the reviewed results. Final PDF rebuilding and visual QA are handled by the main revision workflow; this review's earlier source-reference and PDF-destination checks passed for the three-document package.

SHA256 hashes independently read from the verified sources:

- `main.tex`: `3314bfaa5326b6ead1c0e84b9c1074a8a67b065f3cc5ee89ca2f1ea75666e7dd`
- `appendices.tex`: `6fceb142a9d82f31c94f9821edb99ece70ed8f663af0944ac35e72826643e5e5`
- `supplement-body.tex`: `eee59823c7837fa0e785f54f412c3449c2f0e9f427f4d41b0be83bcf14ab365d`
- `supplement.tex`: `c37f05889839bfd2444ecbe0a2c6d3055126d796eef8428b2296ae016dda6b56`
- `companion.tex`: `853ec2a8f91870120d0dac33132fb7bdd70baa267334cae468f5bc56e6276de8`
