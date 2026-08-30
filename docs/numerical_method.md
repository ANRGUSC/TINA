# Numerical method specification

All six experiments use an exogenous common-rate Gaussian-affine environment;
actions never alter later states. The target action is `x* = Q^{-1}B theta`,
computed with linear solves. Regret is one half of the mean squared action error
in the `Q` metric. Confidence intervals are normal 95% intervals formed as
`mean +/- 1.96 * sample_standard_deviation / sqrt(samples)`.

## Solver used by each experiment

1. **Temporal scaling.** Exact stationary OU pairs are sampled with
   `a = exp(-tau/T)` and innovation covariance `(1-a^2) Sigma`. Because all
   agents share the delayed global snapshot, the team solution is the joint
   vector conditional expectation. Four deterministic systems are generated:
   A has `n=8`, identity `Sigma,Q`, and seeded dense `B`; B has `n=20`, Toeplitz
   `Sigma_ij=0.65^|i-j|`, seeded SPD `Q`, and seeded dense `B`; C has `n=50`, a
   ring graph covariance, `Q=I+0.12L`, and row-normalized exponential graph
   kernel `B`; D has `n=32`, a seeded geometric graph covariance, seeded SPD
   `Q`, and a row-normalized exponential graph kernel `B`.
2. **Local/global crossover.** For `Q=I+gamma 11'`, the exact fresh-local rule
   is `u_i=theta_i/(1+gamma)`, as obtained from the coupled conditional normal
   equations. The stale-global boundary is inferred independently from sampled
   open-loop and local regrets and compared with the finite-`n` formula.
3. **Radius regret.** The canonical scalar temporal and spatial regret terms are
   evaluated directly. Independent standard-normal draws check their sum.
4. **Radius scaling.** Each parameter point is minimized over the declared
   2,501-point radius grid and compared with the closed-form continuous radius.
5. **Decision relevance.** A fixed 64-node ring covariance is held constant as
   the decision operator changes. Since `Q=I`, per-agent Gaussian conditional
   expectations are exact. Each conditional coefficient vector is obtained by
   solving its observed covariance system.
6. **General graphs.** Exact Gaussian conditional variances are evaluated on
   path, ring, grid, and seeded random-geometric graphs. No exponential omission
   curve is fitted; the exact integer-radius minimum is reported.

## Numerical safeguards and acceptance thresholds

- No explicit matrix inverse is used in the numerical implementation.
- Covariances are symmetrized before eigenvalue diagnostics.
- A covariance passes the PSD check when its minimum eigenvalue is at least
  `-1e-9`; every reference covariance passes.
- The largest reference covariance condition number is 152.4.
- Experiment 1 maximum normalized error must not exceed 0.02.
- Experiment 2 maximum boundary error must not exceed 0.007.
- Experiment 3 maximum Monte Carlo error must not exceed 0.025.
- Experiment 4 closed-form/grid error must not exceed one recorded grid step,
  apart from numerically tied points at the zero-radius threshold.
- Experiment 5 maximum conditional-regret Monte Carlo error must not exceed
  `5e-4`.

The reference output metadata records the seed, sample count, configuration,
runtime, Python/platform details, dependency versions, covariance diagnostics,
and headline errors. Boundary classification treats radii below `1e-8` as zero.
