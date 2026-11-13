import TinaV2.Defs

/-! # C8.b: Optimal stale-global action

Paper: main-alt.tex, sentence after Corollary (OU_stale_regret). -/

namespace TinaV2.C08b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- The action `a K θ_{t−τ}` is produced by an admissible rule of the complete
old snapshot and attains `R_glob(τ)`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ),
    TemporalAssumption μ θ T t τ →
    ∃ g : Rule M.actor (fun i => M.Scope ⊤ i → ℝ),
      Admissible μ (M.obs ⊤ (θ (t - τ))) g ∧
      (∀ ω, jointAction g (M.obs ⊤ (θ (t - τ))) ω = exp (-τ / T) • M.target (θ (t - τ)) ω) ∧
      excessCost μ M.Q (M.target (θ t)) (jointAction g (M.obs ⊤ (θ (t - τ))))
        = M.Rglob μ (θ (t - τ)) (θ t)

end TinaV2.C08b
