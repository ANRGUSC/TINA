import TinaV2.Defs
import TinaV2.Statements

/-! # Comparator Challenge Specification

Generated deterministically by `python3 tools/ledger.py comparator-spec`.
Do not edit by hand.

Imports only the frozen `TinaV2.Defs` and `TinaV2.Statements` modules.
Each stub below states the exact theorem that `comparator/Solution.lean` must
prove under `lake comparator` using only `{propext, Quot.sound, Classical.choice}`.
Kept outside `TinaV2/` so the Gate-2 zero-`sorry` scan on `TinaV2/` stays
strictly unconditional. -/

namespace TinaV2.Comparator

/-- C1: Fixed-architecture quadratic projection -/
theorem C01 : TinaV2.C01.Statement := by sorry

/-- C1.b: Q-orthogonality and Pythagorean form -/
theorem C01b : TinaV2.C01b.Statement := by sorry

/-- C1.c: Information inclusion -/
theorem C01c : TinaV2.C01c.Statement := by sorry

/-- C2: Coupled conditional normal equations -/
theorem C02 : TinaV2.C02.Statement := by sorry

/-- C3: Common information: vector conditional mean is optimal -/
theorem C03 : TinaV2.C03.Statement := by sorry

/-- C3.b: Degenerate normalization R_inf = 0 -/
theorem C03b : TinaV2.C03b.Statement := by sorry

/-- C4.b: Stationary AR(1) satisfies the prediction rule -/
theorem C04b : TinaV2.C04b.Statement := by sorry

/-- C4.c: Stationary Gaussian OU satisfies the prediction rule -/
theorem C04c : TinaV2.C04c.Statement := by sorry

/-- C5: Quadratic cost and completing the square -/
theorem C05 : TinaV2.C05.Statement := by sorry

/-- C5.b: Centering the affine model is without loss -/
theorem C05b : TinaV2.C05b.Statement := by sorry

/-- C6.b: No-information loss formula -/
theorem C06b : TinaV2.C06b.Statement := by sorry

/-- C6.c: Omission share is in [0,1], nonincreasing, zero at the diameter -/
theorem C06c : TinaV2.C06c.Statement := by sorry

/-- C7: Spatio-temporal composition -/
theorem C07 : TinaV2.C07.Statement := by sorry

/-- C7.b: Normalized composition law -/
theorem C07b : TinaV2.C07b.Statement := by sorry

/-- C8: Exact stale-global regret -/
theorem C08 : TinaV2.C08.Statement := by sorry

/-- C8.c: Small-delay expansion and large-delay limit -/
theorem C08c : TinaV2.C08c.Statement := by sorry

/-- C9: Unequal-rate formula for a complete old snapshot -/
theorem C09 : TinaV2.C09.Statement := by sorry

/-- C10: Fresh-local versus stale-global crossover -/
theorem C10 : TinaV2.C10.Statement := by sorry

/-- C10.b: Zero threshold at eta_S(0) = 0 and a single crossing -/
theorem C10b : TinaV2.C10b.Statement := by sorry

/-- C11: Two-sensor example -/
theorem C11 : TinaV2.C11.Statement := by sorry

/-- C12: Local explainability under aggregate coupling -/
theorem C12 : TinaV2.C12.Statement := by sorry

/-- C13: Explicit aggregate-coupling threshold -/
theorem C13 : TinaV2.C13.Statement := by sorry

/-- C13.b: Large-n limit of the threshold -/
theorem C13b : TinaV2.C13b.Statement := by sorry

/-- C13.c: Threshold behaviour in the coupling strength -/
theorem C13c : TinaV2.C13c.Statement := by sorry

/-- C14: Radius objective and one-more-hop criterion -/
theorem C14 : TinaV2.C14.Statement := by sorry

/-- C15: Continuous marginal-balance characterization -/
theorem C15 : TinaV2.C15.Statement := by sorry

/-- C15.b: Single-crossing gives the unique optimum -/
theorem C15b : TinaV2.C15b.Statement := by sorry

/-- C15.c: Comparative statics in T and latency scale -/
theorem C15c : TinaV2.C15c.Statement := by sorry

/-- C16: Optimal radius for exponential omission -/
theorem C16 : TinaV2.C16.Statement := by sorry

/-- C17.b: Composition law holds in the continuum model -/
theorem C17b : TinaV2.C17b.Statement := by sorry

/-- C18: Exponential omission by self-similarity -/
theorem C18 : TinaV2.C18.Statement := by sorry

/-- C19: Optimal synchronized-snapshot radius in the canonical model -/
theorem C19 : TinaV2.C19.Statement := by sorry

/-- C19.b: Comparative statics of the canonical radius -/
theorem C19b : TinaV2.C19b.Statement := by sorry

/-- C20: Large decision-range limit -/
theorem C20 : TinaV2.C20.Statement := by sorry

end TinaV2.Comparator
