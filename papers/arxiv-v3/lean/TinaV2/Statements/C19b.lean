import TinaV2.Defs

/-! # C19.b: Comparative statics of the canonical radius

Paper: main-v3.tex Theorem (canonical_optimal_radius), items 1-4 (lines 916-921).

Formalization C19.b/f2: item 3 compares two points that are both in the interior
regime (disposition F11.1). C19.b/f1 let the larger `ℓ_s` leave the regime. -/

namespace TinaV2.C19b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- From a point in the interior regime `vT > 2ℓ_s`, `r⋆` increases strictly
with `T`, with `v` and with `ℓ_c`, and decreases strictly with `ℓ_s` as long
as the larger `ℓ_s` is still in the regime. (A larger `T` or `v` stays in the
regime, and `ℓ_c` does not enter the condition.) -/
def Statement : Prop :=
  ∀ (ℓc ℓs v T : ℝ), 0 < ℓc → 0 < ℓs → 0 < v → 0 < T → 2 * ℓs < v * T →
    (∀ T', T < T' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v T') ∧
    (∀ v', v < v' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v' T) ∧
    (∀ ℓs', ℓs < ℓs' → 2 * ℓs' < v * T → canonRadius ℓc ℓs' v T < canonRadius ℓc ℓs v T) ∧
    (∀ ℓc', ℓc < ℓc' → canonRadius ℓc ℓs v T < canonRadius ℓc' ℓs v T)

end TinaV2.C19b
