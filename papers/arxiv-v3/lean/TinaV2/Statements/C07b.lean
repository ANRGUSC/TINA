import TinaV2.Defs

/-! # C7.b: Normalized composition law

Paper: main-v3.tex lines 391-396, Eq. (regret_composition_normalized). -/

namespace TinaV2.C07b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For `R_∞ > 0`: `1 − R(𝒜_{r,τ})/R_∞ = e^{−2τ/T} [1 − η_S(r)]`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (r : ℕ∞),
    TemporalAssumption μ θ T t τ → 0 < M.Rinf μ (θ t) →
    1 - M.R μ r (θ (t - τ)) (θ t) / M.Rinf μ (θ t)
      = exp (-2 * τ / T) * (1 - M.etaS μ r (θ t))

end TinaV2.C07b
