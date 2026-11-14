import TinaV2.Defs

/-! # C19.b: Comparative statics of the canonical radius

Paper: main-alt.tex Theorem (canonical_optimal_radius), items 1-4. -/

namespace TinaV2.C19b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- From a point in the interior regime `vT > 2ℓ_s`, `r⋆` increases strictly
with `T`, with `v` and with `ℓ_c`, and decreases strictly with `ℓ_s`. -/
def Statement : Prop :=
  ∀ (ℓc ℓs v T : ℝ), 0 < ℓc → 0 < ℓs → 0 < v → 0 < T → 2 * ℓs < v * T →
    (∀ T', T < T' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v T') ∧
    (∀ v', v < v' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v' T) ∧
    (∀ ℓs', ℓs < ℓs' → canonRadius ℓc ℓs' v T < canonRadius ℓc ℓs v T) ∧
    (∀ ℓc', ℓc < ℓc' → canonRadius ℓc ℓs v T < canonRadius ℓc' ℓs v T)

end TinaV2.C19b
