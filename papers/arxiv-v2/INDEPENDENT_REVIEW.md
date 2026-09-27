# Independent mathematical and clarity review

Reviewed September 26, 2026. Source: `papers/arxiv-v2/main.tex`, read in full, with `simplifyTINA.md` and `papers/full/main.tex` as the scope and baseline references. Applied the writing-guide skill and its theory-paper and mathematical-exposition guidance, including the structural anti-slop audit. This review did not edit the manuscript or rely on the revision agent's reasoning.

## Verdict

No theorem-level mathematical error found. The revised proofs preserve the intended results while removing the history and shift-operator machinery. The core simplification is successful. There is one inherited qualification issue in the abstract and two minor notation/clarity issues below. None calls for a broad rewrite or rerunning the numerical experiments.

## Findings

1. **Medium, qualification issue; inherited from v1.** The abstract, lines 54–56, says that common exponential decorrelation yields the crossover threshold. Exponential state decorrelation alone does not supply the conditional-mean innovation structure, and even a Gaussian OU state does not give the stated temporal factor for nonlinear full-information decisions. For example, for a scalar stationary Gaussian OU state, a centered target proportional to `theta^2 - E[theta^2]` has normalized prediction error `1 - exp(-4 tau/T)`, not `1 - exp(-2 tau/T)`. The body correctly assumes affine decisions. A small qualification such as “For affine full-information decisions in a common-rate Gauss–Markov environment” would make the abstract agree with the theorem. Source labels: abstract; `eq:OU_process`, `eq:affine_b`, `thm:OU_stale_regret`. This is a targeted statement correction, not an abstract rewrite.

2. **Low, notation consistency; inherited from v1 and directly relevant to the new unified proof.** `eq:q_inner_product` defines the Q norm to include expectation. The outer expectation in `eq:Rinf_general` and the numerical-methodology regret display is therefore redundant. It is mathematically harmless because the inner norm is already deterministic, but suggests a different, pointwise convention to readers. Remove those two outer expectations, preserving the established L2 norm convention. The new innovation lemma and composition proof already use the convention correctly. Source labels: `eq:q_inner_product`, `eq:Rinf_general`, `subsec:numerical-methodology`.

3. **Low, optional precision; inherited diagram retained during simplification.** The three-ingredient display in decision-relevant smoothness lists state statistics, decision sensitivity, and information geometry, but the regret fraction also depends on Q even with K fixed. This is clear elsewhere in the manuscript. If this display is intended as an exhaustive summary, “decision sensitivity and cost geometry” would be more complete. For example, independent unit-variance states, local observations, fixed K with rows `(1,1)` and `(0,1)`, and `Q=diag(q1,q2)` give a local omission fraction `q1/(2q1+q2)`. Source labels: `eq:three_spatial_ingredients`, `eq:projection_regret`. This is optional clarity, not a defect in any proof.

## Independent proof checks

- **Projection and conditional normal equations.** The admissible product of componentwise L2 measurable spaces is closed, and Q positive definite gives an equivalent Hilbert norm. Completing the square yields the factor one-half correctly. Coupled normal equations correctly distinguish a general static team from componentwise conditional expectations.
- **Centering and innovation split.** Constants are admissible, so translation by the mean preserves the optimization domain. Conditional mean zero annihilates the Q cross term for deterministic Q, including off-diagonal action coupling. Stationarity gives innovation energy `(1-exp(-2 rho)) 2 R_inf`; no covariance calculation or Gaussian assumption is needed for that step.
- **Global snapshot and crossover.** The predictable centered action is implementable globally. The trace expression and the strict crossover inequality are correct, including zero omission, full omission, zero delay, and finite-delay qualifications.
- **Non-Gaussian extension.** A stationary scalar-coefficient AR(1) with independent mean-zero square-integrable innovations supplies the required conditional innovation structure at every integer lag. The stated replacement by `a^k` is correct. The generality paragraph retains stationarity and does not claim that covariance factorization alone suffices.
- **Markov monotonicity.** For `s1 < s2 < t`, the Markov property gives `E[X_t | theta_s1] = E[E[X_t | theta_s2] | theta_s1]`. Conditional Jensen contracts the Q norm, so older snapshots cannot have greater explained energy. The manuscript correctly avoids an invalid nested-snapshot argument.
- **Mixing limit.** The stated L2 conditional-prediction convergence is sufficient. Strong mixing supplies it here: bounded target truncations have conditional-expectation L1 convergence, boundedness upgrades this to L2, and L2 contraction controls truncation error. No extra fourth-moment assumption is needed.
- **Aggregate coupling.** Independent current local states make cross-agent conditional policy means constant. The mean equations force zero means, yielding `theta_i/(q+gamma)`. The regret expressions follow from the eigenvalues q and `q+n gamma` and the local achieved improvement `n sigma^2/[2(q+gamma)]`. All omission, threshold, and large-n formulas agree. Independent numerical substitutions checked this algebra.
- **Composition.** Rescaling by the nonzero finite-delay scalar maps the admissible space onto itself agent by agent. Stationarity identifies the old-time approximation problem with the zero-delay problem. The result applies to coupled Q and does not introduce an invalid componentwise conditioning step. At graph diameter the spatial omission is zero, recovering the global law.
- **Marginal balance.** The derivative, logarithmic one-hop comparison, zero-explained-share qualification, boundary cases, and single-crossing conditions are correct. The comparative statics are appropriately conditional on the marginal-gain order, rather than asserted for arbitrary covariance changes.
- **Self-similarity.** The stationary spatial Gaussian OU process has independent left and right exterior innovations given the observed segment. Each tail depends on the segment through its adjacent boundary value, and Gaussianity makes the conditional tail variance independent of that value. Reflection symmetry supplies the factor two. The argument includes radius zero without a missing middle contribution.
- **Canonical constants.** Independently splitting the double integral into quadrants gives a same-sign quadrant integral `1/[kappa(kappa+lambda)]` and an opposite-sign quadrant integral `1/(kappa+lambda)^2`. These give the displayed target variance, covariance, and omission constant exactly. Numerical substitutions independently checked the resulting formulas.
- **Optimal radius.** The derivative bracket is strictly decreasing with negative limit. The zero-slope boundary at radius zero still has a unique optimum because the derivative is negative thereafter. The arbitrary-eta0 formula, finite cap, canonical positivity threshold, all four comparative statics, and positive-regime long/short decision-range approximations are correct. The cap is explicitly distinguished from a finite graph with complete information at diameter.
- **Numerical section.** The reported calculations remain consistent with the snapshot definitions. The distinctions between a scalar loss check, exact Gaussian conditional variances with Q=I, a capped line model, and integer-radius finite graphs are preserved. I did not rerun simulations or re-audit archived data.

## Clarity and scope audit

The main derivation now follows a coherent reader order: architecture regret, benchmark snapshots, innovation split, composition, marginal balance, then the canonical model. Centering and the L2 convention are introduced before use in the revised proofs. The Gaussianity qualification in the self-similarity proof is important and is present. The canonical constants are evaluated only after the exponential radius dependence is established, making the self-similarity argument visible.

Some repeated scope and prior-work positioning remains in the inherited introduction, related work, and discussion. It is not a new problem caused by the simplification and does not justify expanding this revision into a general prose rewrite. The abstract remains readable; only the narrow mathematical qualification identified above is recommended. No em-dash matches were found in the active LaTeX source.

The simplification checklist is substantively implemented: snapshots replace histories; the generic crossover becomes an observation; one innovation lemma serves both temporal laws; the snapshot-history proof and shift operator are removed; the graph covariance moves to the numerical methodology; and the canonical omission and radius arguments use self-similarity and direct calculus. The remaining steps for the main agent are final source/build checks and verification of any selected small fixes.

## Final verification request

Please send the final targeted edits back to this reviewer for verification. The current verdict is mathematical approval of the revised core, with the abstract qualification and minor consistency points above recorded separately.

## Final verification and resolved findings

Rechecked the final targeted edits on September 26, 2026. All three findings above are **resolved**; the original findings are retained as review history.

- The abstract now explicitly restricts the threshold claim to affine full-information decisions in a common-rate Gauss–Markov environment. This agrees with the theorem hypotheses.
- The open-loop regret and numerical-methodology displays now use the established Q-weighted L2 norm without a redundant outer expectation.
- The decision-relevant smoothness paragraph explicitly includes the cost metric Q, and its display includes cost geometry.

These changes are narrow mathematical qualifications and consistency corrections. They preserve the revised proofs, results, numerical values, and simplification scope. No further mathematical or clarity fix is required by this review.

The final source SHA256, independently read from `papers/arxiv-v2/main.tex`, is:

`1d9709e000600c5cca332945c889f17e28d936219c089b2aa65da69438da7ae8`

This matches `reviewed_source_sha256` in `verification.json`. I inspected that verification record: it reports finite-state non-Gaussian coupled-Q composition checks with maximum regret discrepancy approximately `7.55e-15`, v1/v2 canonical omission agreement to `1.11e-16`, agreement with archived canonical theory to `2.22e-16`, and direct-grid reproduction for all 4,896 archived Experiment 4 parameter points. These are the main agent's recorded computational checks, supplementary to this review's independent analytical checks; I did not rerun that script.

**Final verdict: approved mathematically and for the requested simplification-focused refinement. All review findings are resolved.** Final build and visual PDF checks remain the responsibility of the main revision workflow.

## Subsequent metadata update (recorded by the revision agent)

At the author's request, the title-page date was changed from August 2026 to September 2026 after this review. The date line was also saved with a normalized line ending. Mathematical content is unchanged. The updated source hash is `f15a18cc0b12021f01d57da58e5f6c11f43e43a6693b75cabbdb96271f3ed337`.
