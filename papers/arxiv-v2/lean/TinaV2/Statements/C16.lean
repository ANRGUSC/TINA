import TinaV2.Defs

/-! # C16: Optimal radius for exponential omission

Paper: main-alt.tex Proposition (generic_exponential_radius), Eq. (generic_exponential_rstar). -/

namespace TinaV2.C16

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `η(r) = η₀ e^{−2r/ℓ_c}`, `τ(r) = r/v`. Over `r ≥ 0` the unique maximizer of
`G` is `r⋆ = (ℓ_c/2)[log(η₀(1 + vT/ℓ_c))]_+`; `r⋆ > 0` exactly when
`η₀(1 + vT/ℓ_c) > 1`; with a cap `D` the unique maximizer on `[0, D]` is
`min{D, r⋆}`. -/
def Statement : Prop :=
  ∀ (η0 ℓc v T : ℝ), 0 < η0 → η0 < 1 → 0 < ℓc → 0 < v → 0 < T →
    let G : ℝ → ℝ := gain (fun r => η0 * exp (-2 * r / ℓc)) (fun r => r / v) T
    let rstar := expRadius η0 ℓc v T
    (∀ r, 0 ≤ r → r ≠ rstar → G r < G rstar) ∧
    (0 < rstar ↔ 1 < η0 * (1 + v * T / ℓc)) ∧
    (∀ D, 0 ≤ D → ∀ r ∈ Icc 0 D, r ≠ min D rstar → G r < G (min D rstar))

end TinaV2.C16
