# Numerical section review and revision plan

Review scope: the numerical section in `main.tex`, all six experiment drivers,
shared numerical routines, configurations, archived results, and figures.
The implementation is concentrated in `numerics/experiments/run_all.py`;
the six named drivers are entry points into that module.

## Findings

- The section needs an explicit progression from temporal and crossover checks,
  through continuous scalar radius examples, to exact finite-graph conditioning.
  Each subsection should identify its question, evidence, takeaway, and scope.
- Figure 2 overlays tiny Monte Carlo crosses with same-colored filled theory
  markers. Its logarithmic coupling axis also excludes the sampled zero-coupling
  endpoint without explanation. The empirical threshold is inferred from sampled
  local and open-loop losses using the temporal law, not from a simulated sweep
  of stale-global policies. Uncertainty and residuals should make that distinction
  assessable.
- `aggregate_eta_local` returns the explained fraction, whereas the manuscript's
  eta denotes the omitted fraction. The stored `eta_local` column is consequently
  misleading even though the threshold formula uses the correct complement.
- Experiment 3 samples scalar Gaussian errors with variances supplied by the
  decomposition. This checks the loss calculation, not an independently simulated
  spatial field. Its capped example retains positive omission at the cap, so
  calling that endpoint global is incorrect.
- Figure 4's numerical/theoretical scatter lies almost on equality, obscuring
  rather than communicating error. Its heatmap does not distinguish the exactly
  local region clearly from small positive radii. The search range is chosen using
  the closed form, although it is constant over the current sweep; it should be
  specified independently. Ordinary grid errors occur throughout the positive
  region; only zero/positive classification disagreements are near the threshold.
- Experiment 5 overlays state correlation and action omission under an omission
  axis label. These are different statistics. Its Monte Carlo check normalizes by
  a sampled denominator and archives only maximum errors, limiting auditability.
- Figure 6 has overlapping panel labels, hides coincident graph curves, and joins
  sparse integer optima with lines that can be mistaken for fractional optima or
  measured transition locations. Exact graph sweeps need interpretation limited
  to the sampled cases.
- The standalone TeX extracts are stale relative to `main.tex`. Settings and
  provenance claims also exceed what is actually archived in some experiments.

## Planned commit sequence

1. Record this review and plan before implementation.
2. Correct estimators, numerical diagnostics, uncertainty/provenance, and figure
   generation. Add focused checks for statistical and mathematical changes.
3. Revise the manuscript section and reproduction documentation; synchronize
   standalone extracts with the canonical manuscript.
4. Regenerate results and figures, run the full suite and source audit, build the
   paper, and visually inspect the revised figures and numerical-section pages.

Implementation is delegated where practical to Luna agents at maximum reasoning
effort. The primary agent reviews changes and numerical evidence before committing.
No theoretical claims outside the numerical section are changed unless a directly
related correction is necessary and supported by the review.

## Validation criteria

- Preserve or explicitly explain changes in all headline values and fixed seeds.
- Compare covariance regret with sampled quadratic loss using the correct team
  policy and normalize uncertainty consistently.
- Check the aggregate omission against direct matrix regret, including zero
  coupling, and account for paired samples in inferred-boundary uncertainty.
- Use an independently configured radius grid; report error in grid-step units
  and distinguish classification disagreements from optimization error.
- Verify full-neighborhood omission, nested-radius monotonicity, and archived
  finite-graph minima and neighboring regret differences.
- Inspect figures at manuscript size, verify all manuscript numbers against the
  regenerated data, and compile without undefined references or citations.
