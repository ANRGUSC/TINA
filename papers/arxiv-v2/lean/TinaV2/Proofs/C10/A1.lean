import TinaV2.Statements

/-! # C10, attempt A1: mirrors paper proof C10/p1

Paper: `main-v2.tex`, proof of Theorem (local_global_crossover), lines 499-500.
The stale-global corollary C8 enters as the hypothesis `hC8 : C08.Statement`.

Finding F4: the paper's proof covers the range `η_S(0) < 1` only. The clause
"if `η_S(0) = 1`, no finite delay gives a strict local advantage" has no
sentence in the proof; here it is one line in `main`, read off step 1. -/

namespace TinaV2.C10.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (main-v2.tex 499-500). "Divide the two regrets by `R_∞`: the
comparison is `η_S(0) < 1 − e^{−2τ/T}`", together with the same for equality. -/
theorem s1_comparison (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t)) :
    (M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t)
        ↔ M.etaS μ 0 (θ t) < 1 - exp (-2 * τ / T)) ∧
      (M.Rloc μ (θ t) = M.Rglob μ (θ (t - τ)) (θ t)
        ↔ M.etaS μ 0 (θ t) = 1 - exp (-2 * τ / T)) := by
  have hloc : M.Rloc μ (θ t) = M.etaS μ 0 (θ t) * M.Rinf μ (θ t) := by
    rw [Model.etaS, Model.Rloc, div_mul_cancel₀ _ hR.ne']
  rw [hloc, hC8 M μ θ T t τ hA]
  exact ⟨mul_lt_mul_iff_left₀ hR, mul_left_inj' hR.ne'⟩

/-- Step 2 (main-v2.tex 500). "Rearranging gives the threshold and equality
case": for `η_S(0) < 1`, the comparison of step 1 is `τ/T > ρ⋆`, and `τ/T = ρ⋆`
gives equal regret. -/
theorem s2_rearrange (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t))
    (hη : M.etaS μ 0 (θ t) < 1) :
    (M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t) ↔ rhoStar (M.etaS μ 0 (θ t)) < τ / T) ∧
      (τ / T = rhoStar (M.etaS μ 0 (θ t)) →
        M.Rloc μ (θ t) = M.Rglob μ (θ (t - τ)) (θ t)) := by
  obtain ⟨hlt, heq⟩ := s1_comparison hC8 M μ θ T t τ hA hR
  have hpos : 0 < 1 - M.etaS μ 0 (θ t) := sub_pos.mpr hη
  have hρ : rhoStar (M.etaS μ 0 (θ t)) = -(1 / 2 * log (1 - M.etaS μ 0 (θ t))) := by
    rw [rhoStar, one_div (1 - M.etaS μ 0 (θ t)), log_inv]
    ring
  have hexp : -2 * τ / T = -(2 * (τ / T)) := by ring
  refine ⟨?_, fun h => ?_⟩
  · rw [hlt, hρ, hexp, lt_sub_comm, ← lt_log_iff_exp_lt hpos]
    constructor <;> intro h <;> linarith
  · rw [heq, hexp, h, hρ]
    have : -(2 * -(1 / 2 * log (1 - M.etaS μ 0 (θ t)))) = log (1 - M.etaS μ 0 (θ t)) := by ring
    rw [this, exp_log hpos]
    ring

/-- Theorem (local_global_crossover). -/
theorem main (hC8 : C08.Statement) : C10.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA hR
  refine ⟨s2_rearrange hC8 M μ θ T t τ hA hR, fun h1 hlt => ?_⟩
  -- Finding F4: the case `η_S(0) = 1` is not in the paper's proof. By step 1 the
  -- comparison would read `1 < 1 − e^{−2τ/T}`.
  have h := (s1_comparison hC8 M μ θ T t τ hA hR).1.mp hlt
  rw [h1] at h
  linarith [exp_pos (-2 * τ / T)]

end TinaV2.C10.A1
