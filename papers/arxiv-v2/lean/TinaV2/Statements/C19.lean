import TinaV2.Defs

/-! # C19: Optimal synchronized-snapshot radius in the canonical model (algebraic form)

Paper: main-v2.tex Theorem (canonical_optimal_radius), Eqs. (canonical_optimal_radius), (positive_radius_condition). -/

namespace TinaV2.C19

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Algebraic form only: with the canonical omission curve
`η(r) = η₀ e^{−2r/ℓ_c}`, `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`, and `τ(r) = r/v`, the unique
maximizer of `G` over `r ≥ 0` is `r⋆ = (ℓ_c/2)[log((ℓ_c+vT)/(ℓ_c+2ℓ_s))]_+`, and
`r⋆ > 0 ⟺ vT > 2ℓ_s`. That this `G` is the regret gain of the canonical field
model is C18 and C17.b (tier D, finding F1) and is not part of this statement. -/
def Statement : Prop :=
  ∀ (ℓc ℓs v T : ℝ), 0 < ℓc → 0 < ℓs → 0 < v → 0 < T →
    let η0 := ℓc / (ℓc + 2 * ℓs)
    let G : ℝ → ℝ := gain (fun r => η0 * exp (-2 * r / ℓc)) (fun r => r / v) T
    let rstar := canonRadius ℓc ℓs v T
    (∀ r, 0 ≤ r → r ≠ rstar → G r < G rstar) ∧
    (0 < rstar ↔ 2 * ℓs < v * T)

end TinaV2.C19
