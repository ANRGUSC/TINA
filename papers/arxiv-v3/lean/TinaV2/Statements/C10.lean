import TinaV2.Defs

/-! # C10: Fresh-local versus stale-global crossover

Paper: main-v3.tex Theorem (local_global_crossover), Eq. (OU_crossover). -/

namespace TinaV2.C10

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- With `R_∞ > 0`. If `η_S(0) < 1`: `R_loc < R_glob(τ)` exactly when
`τ/T > ρ⋆`, and `R_loc = R_glob(τ)` exactly when `τ/T = ρ⋆` (so below the
threshold stale-global is strictly better). If `η_S(0) = 1`: no finite delay
gives `R_loc < R_glob(τ)`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ),
    TemporalAssumption μ θ T t τ → 0 < M.Rinf μ (θ t) →
    let η0 := M.etaS μ 0 (θ t)
    (η0 < 1 →
      (M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t) ↔ rhoStar η0 < τ / T) ∧
      (τ / T = rhoStar η0 ↔ M.Rloc μ (θ t) = M.Rglob μ (θ (t - τ)) (θ t))) ∧
    (η0 = 1 → ¬ M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t))

end TinaV2.C10
