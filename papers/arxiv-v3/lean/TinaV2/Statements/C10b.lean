import TinaV2.Defs

/-! # C10.b: Zero threshold at `η_S(0) = 0`, and a single crossing

Paper: main-v3.tex, the two sentences after Theorem (local_global_crossover),
lines 516-519. -/

namespace TinaV2.C10b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- With `R_∞ > 0`. If `η_S(0) = 0`: `R_loc = 0`, and every positive delay gives
`R_loc < R_glob(τ)`. If `0 < η_S(0) < 1`: the threshold `ρ⋆` is positive;
stale-global is strictly better when `τ/T < ρ⋆`, the regrets are equal when
`τ/T = ρ⋆`, and fresh-local is strictly better when `τ/T > ρ⋆`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ),
    TemporalAssumption μ θ T t τ → 0 < M.Rinf μ (θ t) →
    let η0 := M.etaS μ 0 (θ t)
    (η0 = 0 →
      M.Rloc μ (θ t) = 0 ∧
      (0 < τ → M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t))) ∧
    (0 < η0 → η0 < 1 →
      0 < rhoStar η0 ∧
      (τ / T < rhoStar η0 → M.Rglob μ (θ (t - τ)) (θ t) < M.Rloc μ (θ t)) ∧
      (τ / T = rhoStar η0 → M.Rloc μ (θ t) = M.Rglob μ (θ (t - τ)) (θ t)) ∧
      (rhoStar η0 < τ / T → M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t)))

end TinaV2.C10b
