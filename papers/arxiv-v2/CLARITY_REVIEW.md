# Independent review of clarity additions

Reviewed September 26, 2026 against `clarifyTINA2.md`, the previously reviewed v2, the changed main-text passages, and the complete new `appendices.tex`. This is a new review, separate from the historical `INDEPENDENT_REVIEW.md`. The reviewer did not edit the manuscript or rely on the revision agent's derivations. The writing-guide mathematical and reader-order checks were applied within the requested clarification scope.

## Initial verdict

No changed-result or theorem-level mathematical error was found. The additional derivation steps preserve the earlier results and expose the centering, orthogonality, variance, and optimization arguments correctly. The issues below are narrow qualification or insertion issues; none calls for a broad rewrite.

## Targeted findings sent to the revision agent

1. **Low, mathematical wording, needs correction.** The paragraph “Generality of the composition law” says the jointly Gaussian conditional mean is “linear.” In general it is affine; it is linear after centering. Appendix A.3 already states this correctly. Use the same qualification in the main paragraph. Source: following `thm:spatiotemporal_composition`.

2. **Low, insertion/reference artifacts.** The first inspected source replaced the literal `(1)` in AR(1) with `eq:intro_coupling`, both in the main non-Gaussian extension and Appendix A.4. It also replaced the three consequence numbers `(1)`, `(2)`, `(3)` after the canonical theorem with unrelated equation references. These were reported early; the ongoing revision has already removed the AR and consequence-heading artifacts. The composition proof's `Section~ref{sec:fresh_local_global}.2` should use the actual subsection label `subsec:OU_model`.

3. **Low, sentence assembly.** The nesting explanation inserted between `eq:radius_architecture_nested` and `eq:eta_S_monotone` leaves a standalone lowercase “and therefore” following a complete paragraph. Join the argument or remove the dangling connector. The first inspected mixing-limit sentence also used semicolons to bracket its “precisely, if ...” clause; this should be an ordinary conditional sentence. The latter has been corrected during the ongoing revision.

4. **Low, reader-order clarity.** The paragraph explaining uncountably generated observations precedes the canonical field and observation definitions. Move it immediately after `eq:canonical_radius_observation`, where the reader has met both the field and the observation interval. Its substance is sound when a continuous version of the Gaussian field is used; saying “admits a continuous version, which we use” is the precise formulation.

## Mathematical checks

- **Assumptions table:** The spatial omission lemma is correctly separated from the temporal optimal-radius theorem. It requires the stationary spatial Gaussian exponential field and exponential kernel, but no temporal common-rate dynamics or latency law. The final radius theorem uses the temporal structure and linear delay as well. Fixed-epoch projection and aggregate-coupling algebra do not require stationarity; the table correctly labels that distinction. The aggregate row includes independence, zero means, and equal variance. The caption explains that non-Gaussian rows describe the stated proof extensions rather than silently changing the Gaussian theorem statements.
- **Projection additions:** The Pythagorean regret identity holds for uncentered policies as written. The open-loop orthogonal decomposition and all factors of two are correct. Common information gives ordinary conditional expectation for deterministic positive-definite Q, including off-diagonal Q. Different component information still requires the joint team solution.
- **Temporal proofs:** The tower-property cross term is integrable under the square-integrability assumptions and vanishes correctly. Stationarity gives the innovation norm. The uncentered stale-global policy is correctly restored. The trace simplification is correct. The non-Gaussian AR(1) example retains square integrability and independence of past innovations. The Markov prediction-error explanation is correct and does not assume nested snapshots. The one-threshold discussion now correctly fixes the one-time distribution and handles omission shares zero and one separately.
- **Aggregate algebra:** Sherman–Morrison, the trace, the local policy norm, the regret subtraction, the threshold numerator, and the large-system limit all agree with the previous results. The intuition now correctly refers to zero means of the optimal rules, rather than inferring zero policy means merely from zero state means.
- **Composition:** The replacement proof preserves agentwise measurability under rescaling, uses the nonzero finite-delay factor, and invokes stationarity for the correct old-time prediction problem. The explained-share product and the Q-dependent team qualification are correct.
- **Marginal balance:** The logarithm is restricted to positive explained share. The zero-share one-hop case is handled without an undefined logarithm. The sign of the derivative, first-order necessity, strict single-crossing cases, and comparative-statics directions are correct. The cap remains a bound on observation radius on an infinite field and does not acquire the finite-graph zero-omission endpoint.
- **Self-similarity:** Conditional variance is deterministic here because both target and observations belong to the joint Gaussian family. Boundary sufficiency, conditional independence of exterior tails, translation and reflection invariance, and the radius-zero case are correct. The beta notation avoids the previous conflict with the graph covariance parameter.
- **Integral and equal-rate case:** For `u >= 0`, the three pieces of the inner integral are respectively `exp(-beta_s u)/(beta_c+beta_s)`, `[exp(-beta_c u)-exp(-beta_s u)]/(beta_s-beta_c)`, and `exp(-beta_c u)/(beta_c+beta_s)`. Their displayed subsequent integrals are correct. At `beta_c=beta_s=b`, the middle piece is `u exp(-b u)` and its weighted integral is `1/(4b^2)`. Thus the target variance is `3 sigma^2/8`, covariance with the local value is `sigma^2/2`, and omission at zero radius is `1/3`, agreeing with all final formulas. The cancellation is valid at equal rates by the stated limiting interpretation.
- **Optimization explanations:** The equation for the stationary point, positivity threshold, four comparative statics, integral representation, and two asymptotic regimes preserve the existing formulas. The positive-radius qualification is retained where needed.
- **Appendix qualifications:** Gaussian conditioning treats singular observation covariance with a Moore–Penrose inverse on its support; the scalar correlation formula requires nonzero variances. Gaussian linear functionals are described as mean-square limits. Innovation independence is justified through Brownian increments. GMRF precision statements require nonsingular covariance, and the graph spectral covariance is correctly distinguished from a Markov field on the original graph for arbitrary powers. The stationary AR example specifies the stability and moment assumptions. Matrix identities and calculus facts check out. The marginal-rate explanation distinguishes the temporal negative log-derivative.
- **Glossary:** The definitions generally match their main-text uses, and the entry for marginal balance correctly calls it necessary at an interior differentiable optimum. The main agent is converting remaining hardcoded theorem links to labels. No additional result is introduced by the toolkit or glossary.

## Scope and remaining verification

The requested teaching additions, notation fixes, explicit proofs, timing diagram, marginal-rate illustration, toolkit, and glossary are within the scope of `clarifyTINA2.md`. The user explicitly requested fuller explanations, so restoring detailed algebra here is compatible with the earlier simplification: the argument remains unified, and histories and shift operators have not returned. The optional frequency-domain derivation is unnecessary.

This review checks source mathematics and clarity. The main revision workflow remains responsible for final equation wrapping, table widths, figure rendering, bibliography/build checks, and PDF inspection. A final verification entry will record the resolved findings and final source hashes after the targeted fixes.

## Final verification

Rechecked the final source after the targeted corrections. **All four findings are resolved.** The main text now correctly calls Gaussian conditional means affine, uses the named OU subsection reference, joins the nesting argument cleanly, and states the mixing limit in a grammatical conditional sentence. Both AR(1) references and all three consequence numbers are literal text again; glossary theorem pointers use labels. The countable-dense observation explanation now follows the observation definition and explicitly selects a continuous version of the field.

The final corrections do not alter the mathematical results, their assumptions, or the reviewed derivations. **Final verdict: approved for the requested clarity revision, with no unresolved mathematical or targeted clarity issue.** This verdict covers source mathematics and the reviewed explanatory additions. The main revision workflow separately reports a successful 52-page PDF build and handles visual checks.

Independently read SHA256 hashes of the verified sources:

- `papers/arxiv-v2/main.tex`: `a8ecfe896618a70e66e0ca85885cbb70de4fa572ca42f7d18d1a2db9a1ad55c7`
- `papers/arxiv-v2/appendices.tex`: `489caf35de757c0cc4f680d122743443326c65f34a7b639ac2dd204535ee08d8`

Final packaging removed only trailing whitespace from three source lines after this review. The resulting `main.tex` SHA256 is `8379ead8f0973a6e81e43820f61de6b167b9b05efa69ad037c10df8c001865fd`; no text or mathematical content changed.
