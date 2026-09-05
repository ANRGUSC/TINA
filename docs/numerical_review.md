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

## Completed review and validation

The original six-experiment suite reproduced the archived tables to rounding
precision on macOS with the locked Python dependencies. The threshold and
radius formulas were correct; the principal problems were interpretation,
estimator labeling, uncertainty reporting, and figure design.

Three Luna agents at maximum reasoning effort implemented the crossover/radius
figures, the remaining simulation diagnostics, and the manuscript/docs changes.
The primary reviewer checked their code and figures, requested corrections to
statistical guards, classification tolerance, plot scales and layouts, and
reviewed the final integration. Independent tests were added for direct joint
past/current Gaussian conditioning and a refined discretization of the canonical
field. The unused multi-target Gaussian predictor also had an orientation bug;
its correction does not change the original experiment results.

The final numerical run took 17.6 seconds with Python 3.12.12, NumPy 2.4.3,
SciPy 1.17.1, Matplotlib 3.10.8, NetworkX 3.6.1, and PyYAML 6.0.3. Results:

| Check | Verified result |
|---|---|
| Temporal pairs | Maximum normalized error 0.0155370; RMSE 0.00470524 |
| Inferred crossover | Mean absolute error 0.00110566; maximum 0.00557228; paired uncertainty archived |
| Scalar radius regimes | Grid optima 0, 0.626, 2; interior marginal gap 0.000477128 |
| Canonical radius sweep | 4,896 points; mean error 0.000224786; maximum 0.000800052, or 0.500032 grid steps |
| Zero/positive classification | Five disagreements; largest continuous optimum among them 0.000734123, below the first positive grid point 0.0016 |
| Decision relevance | Optima remain 1, 2, 5 hops; all 12 Monte Carlo checks within 1.362 estimated SEs after a roundoff floor at full observation |
| Noncanonical graphs | Optima remain 2, 2, 3, 2 hops; omission curves nonincreasing; full-neighborhood omission below 1e-12 |

Experiment 5's maximum absolute Monte Carlo error changes from 0.0003124 to
0.00239216 because its correlated sampled denominator has been replaced with
the exact normalizer. The corresponding standard error is 0.00319841; the
covariance curves and architectural optima are unchanged. This estimator change
is reported explicitly, and the acceptance check now uses four estimated SEs
plus a 1e-12 floor rather than the old estimator-specific absolute threshold.

All 25 unit/integrity tests pass, including exact PDF-copy checks and a new
check preventing stale standalone TeX extracts. The six experiments were run
in full; all stated optima, grid errors, and neighboring-regret differences
were checked against the regenerated tables. Source auditing passed for all
49 citations and six figures. The isolated pdflatex/BibTeX build produced the
44-page `tina.pdf` without undefined citations or references. All 39 fonts are
embedded. The revised numerical-section pages (29--35) and all six figures
were visually inspected at manuscript scale.

Figure 4's heatmap alone is rasterized at 350 dpi to remove PDF cell seams;
text, curves, and contours remain vector elements. Manuscript figure PDFs are
exact copies of the archived PDFs, avoiding small layout changes caused by
saving the same constrained-layout figure repeatedly. Historical `fig7_*`
filenames are retained even though LaTeX currently numbers the section as 6.

The revisions do not broaden the numerical evidence beyond the specified
Gaussian model and graph instances. The canonical grid sweep remains a scalar
consistency check, and the Experiment 3 sampling remains a scalar variance
check; these limits are now explicit in the manuscript.
