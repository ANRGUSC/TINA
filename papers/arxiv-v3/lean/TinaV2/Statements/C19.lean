import TinaV2.Defs

/-! # C19: Optimal synchronized-snapshot radius in the canonical model

Paper: main-v2.tex Theorem (canonical_optimal_radius), Eqs. (canonical_optimal_radius), (positive_radius_condition).

`Statement` is about the field model of claim C17. `AlgebraicStatement` is the
earlier formalization (C19/f1), about the gain function only; it is kept
because attempt C19/a1 proves it. -/

namespace TinaV2.C19

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the canonical field with `σ ≠ 0`, the tracking loss with `q > 0` and
`τ(r) = r/v`, `v > 0`: at every location and time, the regret `R(r, r/v)` of the
radius-`r` snapshot is smallest at
`r⋆ = (ℓ_c/2)[log((ℓ_c+vT)/(ℓ_c+2ℓ_s))]_+` and strictly larger at every other
radius `r ≥ 0`; and `r⋆ > 0 ⟺ vT > 2ℓ_s`. -/
def Statement : Prop :=
  ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → ℝ → Ω → ℝ) (σ ℓs T ℓc q v : ℝ),
    CanonicalField μ θ σ ℓs T → σ ≠ 0 → 0 < ℓc → 0 < q → 0 < v →
    ∀ (z t : ℝ),
      let R : ℝ → ℝ := fun r => lineR μ q θ ℓc r (r / v) z t
      let rstar := canonRadius ℓc ℓs v T
      (∀ r, 0 ≤ r → r ≠ rstar → R rstar < R r) ∧
      (0 < rstar ↔ 2 * ℓs < v * T)

/-- Formalization C19/f1, superseded by `Statement`. Algebraic form only: with the canonical omission curve
`η(r) = η₀ e^{−2r/ℓ_c}`, `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`, and `τ(r) = r/v`, the unique
maximizer of `G` over `r ≥ 0` is `r⋆ = (ℓ_c/2)[log((ℓ_c+vT)/(ℓ_c+2ℓ_s))]_+`, and
`r⋆ > 0 ⟺ vT > 2ℓ_s`. It does not mention the field. -/
def AlgebraicStatement : Prop :=
  ∀ (ℓc ℓs v T : ℝ), 0 < ℓc → 0 < ℓs → 0 < v → 0 < T →
    let η0 := ℓc / (ℓc + 2 * ℓs)
    let G : ℝ → ℝ := gain (fun r => η0 * exp (-2 * r / ℓc)) (fun r => r / v) T
    let rstar := canonRadius ℓc ℓs v T
    (∀ r, 0 ≤ r → r ≠ rstar → G r < G rstar) ∧
    (0 < rstar ↔ 2 * ℓs < v * T)

end TinaV2.C19
