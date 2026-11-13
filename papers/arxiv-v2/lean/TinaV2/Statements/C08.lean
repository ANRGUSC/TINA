import TinaV2.Defs

/-! # C8: Exact stale-global regret

Paper: main-alt.tex Corollary (OU_stale_regret), Eq. (OU_exact_regret). -/

namespace TinaV2.C08

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `R_glob(τ) = (1 − e^{−2τ/T}) R_∞`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ),
    TemporalAssumption μ θ T t τ →
    M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t)

end TinaV2.C08
