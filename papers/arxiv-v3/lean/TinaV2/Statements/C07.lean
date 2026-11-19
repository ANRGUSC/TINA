import TinaV2.Defs

/-! # C7: Spatio-temporal composition

Paper: main-v2.tex Theorem (spatiotemporal_composition), Eq. (regret_composition_unnormalized). -/

namespace TinaV2.C07

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `R(𝒜_{r,τ}) = (1 − a²) R_∞ + a² R(𝒜_{r,0})`, `a = e^{−τ/T}`, at epoch `t`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (r : ℕ∞),
    TemporalAssumption μ θ T t τ →
    M.R μ r (θ (t - τ)) (θ t)
      = (1 - exp (-τ / T) ^ 2) * M.Rinf μ (θ t) + exp (-τ / T) ^ 2 * M.R μ r (θ t) (θ t)

end TinaV2.C07
