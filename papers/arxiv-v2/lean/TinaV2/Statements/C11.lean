import TinaV2.Defs

/-! # C11: Two-sensor example

Paper: main-alt.tex, paragraph "A two-sensor example". -/

namespace TinaV2.C11

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Signals `X`, `Y`: independent processes, mean zero, variance `σ²`,
stationary, each with `E[X_t | X_{t−τ}] = e^{−τ/T} X_{t−τ}`. Target
`Z_t = (X_t + Y_t)/2`.
1. From `X_t` alone the best estimate is `X_t/2`, with error `σ²/4`.
2. From both old readings the best estimate is `e^{−τ/T} Z_{t−τ}`, with error
   `(σ²/2)(1 − e^{−2τ/T})`.
3. The fresh reading wins exactly when `τ > T log 2 / 2`. -/
def Statement : Prop :=
  ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X Y : ℝ → Ω → ℝ) (σ T t τ : ℝ),
    0 < σ → 0 < T → 0 ≤ τ →
    (∀ s, Measurable (X s)) → (∀ s, Measurable (Y s)) →
    (∀ s, MemLp (X s) 2 μ) → (∀ s, MemLp (Y s) 2 μ) →
    (∀ s, ∫ ω, X s ω ∂μ = 0 ∧ ∫ ω, X s ω ^ 2 ∂μ = σ ^ 2) →
    (∀ s, ∫ ω, Y s ω ∂μ = 0 ∧ ∫ ω, Y s ω ^ 2 ∂μ = σ ^ 2) →
    IndepFun (fun ω (s : ℝ) => X s ω) (fun ω (s : ℝ) => Y s ω) μ →
    (∀ s s', IdentDistrib (X s) (X s') μ μ) → (∀ s s', IdentDistrib (Y s) (Y s') μ μ) →
    condExp (MeasurableSpace.comap (X (t - τ)) inferInstance) μ (X t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * X (t - τ) ω) →
    condExp (MeasurableSpace.comap (Y (t - τ)) inferInstance) μ (Y t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * Y (t - τ) ω) →
    let Z : ℝ → Ω → ℝ := fun s ω => (X s ω + Y s ω) / 2
    (bestMSE μ (Z t) (X t) = σ ^ 2 / 4 ∧
      ∫ ω, (Z t ω - X t ω / 2) ^ 2 ∂μ = σ ^ 2 / 4) ∧
    (bestMSE μ (Z t) (fun ω => (X (t - τ) ω, Y (t - τ) ω))
        = σ ^ 2 / 2 * (1 - exp (-2 * τ / T)) ∧
      ∫ ω, (Z t ω - exp (-τ / T) * Z (t - τ) ω) ^ 2 ∂μ
        = σ ^ 2 / 2 * (1 - exp (-2 * τ / T))) ∧
    (σ ^ 2 / 4 < σ ^ 2 / 2 * (1 - exp (-2 * τ / T)) ↔ T * log 2 / 2 < τ)

end TinaV2.C11
