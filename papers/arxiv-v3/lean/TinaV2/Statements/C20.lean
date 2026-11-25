import TinaV2.Defs

/-! # C20: Large decision-range limit

Paper: main-v3.tex lines 951-954, paragraph before Section "Numerical Illustrations". -/

namespace TinaV2.C20

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- With `vT > 2ℓ_s` fixed, `r⋆ → (vT − 2ℓ_s)/2` as `ℓ_c → ∞`. -/
def Statement : Prop :=
  ∀ (ℓs v T : ℝ), 0 < ℓs → 0 < v → 0 < T → 2 * ℓs < v * T →
    Tendsto (fun ℓc => canonRadius ℓc ℓs v T) atTop (𝓝 ((v * T - 2 * ℓs) / 2))

end TinaV2.C20
