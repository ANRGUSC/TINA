# Numerical method specification

## Scope and estimand

All six experiments use an exogenous common-rate Gaussian-affine environment;
actions never alter later states.  For an affine full-information decision
`x* = Q^{-1} B theta = K theta`, the architecture regret is one half of the
mean squared action error in the `Q` metric:

```text
R(A) = 1/2 E[(x* - u_A*)' Q (x* - u_A*)].
```

Linear systems are solved with `numpy.linalg.solve`; no explicit matrix inverse
is used.  Pointwise Monte Carlo estimates use the per-draw quadratic losses and
report a normal 95% interval, `mean +/- 1.96 * sample_SE`.  Experiment 2 uses
the same draws for fresh-local and open-loop losses, so its inferred-boundary
interval is a paired delta-method interval that retains the cross-covariance of
those losses.

## Solver used by each experiment

1. **Temporal scaling.** For each `rho = tau/T`, `exact_ou_pair` draws a
   stationary pair `(theta_(t-tau), theta_t)` with marginal covariance
   `Sigma_S`, autoregressive coefficient `a = exp(-rho)`, and innovation
   covariance `(1-a^2) Sigma_S`.  There is no trajectory burn-in or time-step
   approximation.  Because every agent observes the same delayed global state,
   the joint conditional expectation is team-optimal, including for non-diagonal
   `Q`.  The four deterministic systems are A (`n=8`, identity `Sigma,Q`,
   seeded dense `B`), B (`n=20`, Toeplitz `Sigma`, seeded SPD `Q` and dense
   `B`), C (`n=50`, ring-Laplacian covariance and `Q=I+0.12L`), and D
   (`n=32`, seeded geometric-graph covariance and seeded SPD `Q`).  The raw
   archive keeps the three configured trial slices and a separate system-matrix
   archive; it is not an archive of every random draw.
2. **Local/global crossover.** For `Q = q I + gamma 11'`, the exact fresh-local
   rule is `u_i = theta_i/(q+gamma)`, from the coupled conditional normal
   equations.  For each setting, fresh-local and open-loop losses are computed
   on the same current-state draws.  The empirical boundary is inferred from
   the OU law,
   `rho_hat = 1/2 log(Rinf_hat/(Rinf_hat - Rloc_hat))`, rather than by directly
   simulating stale-global policies and locating a switch.  The processed
   `eta_omitted` field is the fresh-local omission share; `eta_captured` is
   stored separately.  The zero-coupling setting has boundary zero and is
   evaluated even though positive-coupling curves use a logarithmic axis.
   Writing the paired sample means as `(o, l)`, the delta-method gradient is
   `g = (-l/(2*o*(o-l)), 1/(2*(o-l)))`. With the sample covariance `C` of
   the paired per-draw losses and sample count `N`, the boundary standard error
   is `sqrt(g' C g / N)`. A nonpositive sampled `o-l` is rejected rather than
   clipped into a purported finite boundary and confidence interval.
3. **Radius regret.** The canonical scalar temporal and residual-spatial
   variances are evaluated directly on the configured 1,001-point grid.  For
   each radius, independent standard-normal scalar errors are scaled by those
   two prescribed variances and added before squaring.  This checks the loss
   decomposition and its Monte Carlo estimator; it is not an independent
   simulation of a spatial field or graph conditional distribution.  The broad
   regime is capped at `D/ell_c=2`; since its prescribed `eta_S(D)` remains
   positive, the cap is not identified with global information.
4. **Radius scaling.** Each of the 4,896 parameter points is minimized by
   direct scalar evaluation of the normalized composition formula on one fixed,
   independently configured radius grid `r = 0,...,4` with 2,501 points and
   spacing `0.0016`.  The closed form is used only as a comparison with the
   grid result.  Radius errors are recorded in absolute units and in grid
   steps; zero/positive classification disagreements are recorded separately
   from ordinary positive-radius grid error.  The configured transition
   tolerance is `1e-12` in `vT/ell_c - 2*(ell_s/ell_c)`.
5. **Decision relevance.** A single 64-node ring covariance is held fixed while
   the row-`l2`-normalized exponential decision operator changes over
   `ell_c = 0.7, 2, 6`.  With `Q=I`, exact Gaussian conditioning gives each
   decision-weighted omission curve.  Raw state correlation is calculated as a
   separate statistic from the same fixed covariance.  Monte Carlo checks use
   an analytical `Rinf` normalizer for each operator, not a sampled denominator,
   and archive per-check means, standard errors, intervals, and absolute errors.
   The automated smoke check accepts each check when its absolute error is at
   most four estimated standard errors plus `1e-12`; this is deliberately a
   broader implementation check than the displayed 95% intervals.
6. **General graphs.** For one 64-node path, ring, and grid and one fixed-seed
   64-node random-geometric graph, exact Gaussian conditional variances are
   evaluated at every admissible integer radius.  Each graph covariance is
   `Sigma_S = (kappa_s^2 I + L_G)^(-nu)`, scaled to average marginal variance
   one.  No exponential omission curve is fitted and no graph ensemble average
   is taken.  The exact integer minimum, neighboring regret gaps, monotonicity
   diagnostic, graph seed, and covariance diagnostics are archived for the
   reference instance.

## Numerical safeguards and acceptance thresholds

- Covariances are symmetrized before eigenvalue diagnostics.  A covariance
  passes the PSD check when its minimum eigenvalue is at least `-1e-9`.
- The OU sampler uses Cholesky on the positive-definite reference covariances
  without diagonal jitter. Scalar conditional variances are floored at zero
  after subtraction to suppress small negative roundoff residuals.
- The largest reference covariance condition number is approximately `152.4`;
  every reference covariance passes the PSD check.
- Experiment 1 maximum normalized error must not exceed `0.02`.
- Experiment 2 maximum inferred-boundary error must not exceed `0.007`.
- Experiment 3 maximum scalar Monte Carlo error must not exceed `0.025`.
- Experiment 4 maximum closed-form/grid error must not exceed the recorded grid
  step, apart from the separately reported zero/positive threshold cases.
- Experiment 5 uses the four-standard-error smoke threshold described above;
  the maximum absolute error and its estimated standard error remain visible in
  the processed checks and metadata rather than being hidden by a fixed bound.
- Experiment 6 checks nonincreasing `eta_S(r)` and records the regret at the
  integer optimum and the available one-hop neighbors.

The reference metadata records seeds, sample counts, configurations, runtime,
Python/platform details, dependency versions, covariance diagnostics, and
headline errors.  The focused unit tests also independently (i) form a joint
past/current covariance and compare a delayed-neighborhood policy error with
the composition law, (ii) verify the corrected omission/captured estimators,
paired crossover uncertainty, and fixed-radius diagnostics, (iii) verify
cross-covariance predictor shapes and zero-delay OU sampling without jitter,
and (iv) refine a discretized canonical field mesh (`0.1`, `0.05`, `0.025`)
whose conditional omission converges to the closed form (final maximum error
below `3.5e-4`).
