import TinaV2.Statements
import TinaV2.Routine.Regret

/-! # C8, attempt A1: mirrors paper proof C8/p1

Paper: `main-v2.tex`, proof of Corollary (OU_stale_regret), lines 463-464. The
paper's proof is one step. The composition theorem C7 enters as the hypothesis
`hC7 : C07.Statement`. -/

namespace TinaV2.C08.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

/-- Step 1 (main-v2.tex 463-464). "With a complete fresh snapshot the desired
action is feasible, so `R(𝒜_{r,0}) = 0` in Eq. (regret_composition_unnormalized)."
The complete snapshot is radius `⊤`: every agent sees every state coordinate. -/
theorem s1_feasible_substitute (hC7 : C07.Statement) {ι κ α Ω : Type} [Fintype ι] [Fintype κ]
    [Fintype α] [MeasurableSpace Ω] (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (hA : TemporalAssumption μ θ T t τ) :
    M.R μ ⊤ (θ t) (θ t) = 0 ∧
      M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t) := by
  -- the desired action `x⋆ = K θ_t` is feasible: each agent sees all of `θ_t`
  have hfeas : M.R μ ⊤ (θ t) (θ t) = 0 := by
    let g : Rule M.actor fun i => M.Scope ⊤ i → ℝ :=
      fun c o => ∑ k, M.K c k * o ⟨k, (le_top : M.G.edist (M.actor c) (M.owner k) ≤ ⊤)⟩
    have hu : jointAction g (M.obs ⊤ (θ t)) = M.target (θ t) := by
      funext ω c
      simp [g, jointAction, Model.obs, Model.view, Model.target, mulVec, dotProduct]
    have hg : Admissible μ (M.obs ⊤ (θ t)) g :=
      ⟨fun c => Finset.measurable_sum _ fun k _ => (measurable_pi_apply _).const_mul _, by
        rw [hu]
        exact M.memLp_target (hA.stationary.memLp t)⟩
    refine le_antisymm ?_ (regret_nonneg μ M.Q_posDef _ _)
    have hle := regret_le μ M.Q_posDef (M.target (θ t)) (M.obs ⊤ (θ t)) hg
    rw [hu] at hle
    simpa [Model.R, excessCost, quad] using hle
  -- substitute in the composition law
  refine ⟨hfeas, ?_⟩
  have hsq : exp (-τ / T) ^ 2 = exp (-2 * τ / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  have h := hC7 M μ θ T t τ ⊤ hA
  rw [hfeas, hsq] at h
  rw [Model.Rglob, h]
  ring

/-- Corollary (OU_stale_regret), Eq. (OU_exact_regret). -/
theorem main (hC7 : C07.Statement) : C08.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA
  exact (s1_feasible_substitute hC7 M μ θ T t τ hA).2

end TinaV2.C08.A1
