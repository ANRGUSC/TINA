import TinaV2.Defs

/-! # C8.c: Small-delay expansion and large-delay limit

Paper: main-v3.tex lines 468-471, sentences after Corollary (OU_stale_regret). -/

namespace TinaV2.C08c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `R_glob` is zero at zero delay, equals `2(τ/T)R_∞ + o(τ/T)` as `τ ↓ 0`, and
tends to `R_∞` as `τ → ∞`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ),
    (∀ τ, 0 ≤ τ → TemporalAssumption μ θ T t τ) →
    M.Rglob μ (θ t) (θ t) = 0 ∧
    (fun τ => M.Rglob μ (θ (t - τ)) (θ t) - 2 * (τ / T) * M.Rinf μ (θ t))
      =o[𝓝[≥] 0] (fun τ => τ / T) ∧
    Tendsto (fun τ => M.Rglob μ (θ (t - τ)) (θ t)) atTop (𝓝 (M.Rinf μ (θ t)))

end TinaV2.C08c
