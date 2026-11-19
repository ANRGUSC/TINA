import TinaV2.Statements

/-! # C10, attempt A1: mirrors paper proof C10/p1

Paper: `main-v3.tex`, proof of Theorem (local_global_crossover), lines 510-514.
The stale-global corollary C8 enters as the hypothesis `hC8 : C08.Statement`.

The proof has three sentences since arXiv v3 (upstream `12a9b32`, finding F4):
the comparison, the rearrangement for `η_S(0) < 1`, and the endpoint
`η_S(0) = 1`. Before v3 the endpoint had no sentence and was one line in `main`. -/

namespace TinaV2.C10.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (main-v3.tex 510-511). "Divide the two regrets by `R_∞`: the
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

/-- Step 2 (main-v3.tex 511-512). "For `η_S(0) < 1`, rearranging gives the
threshold and equality case": the comparison of step 1 is `τ/T > ρ⋆`, and
`τ/T = ρ⋆` gives equal regret. -/
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

/-- Step 3 (main-v3.tex 512-514). "At `η_S(0) = 1`, fresh-local regret equals
`R_∞`, while stale-global regret is strictly smaller at every finite delay." -/
theorem s3_endpoint (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t))
    (hη : M.etaS μ 0 (θ t) = 1) :
    M.Rloc μ (θ t) = M.Rinf μ (θ t) ∧
      M.Rglob μ (θ (t - τ)) (θ t) < M.Rinf μ (θ t) := by
  constructor
  · have hloc : M.Rloc μ (θ t) = M.etaS μ 0 (θ t) * M.Rinf μ (θ t) := by
      rw [Model.etaS, Model.Rloc, div_mul_cancel₀ _ hR.ne']
    rw [hloc, hη, one_mul]
  · rw [hC8 M μ θ T t τ hA]
    have := mul_pos (exp_pos (-2 * τ / T)) hR
    linarith

/-- Theorem (local_global_crossover). -/
theorem main (hC8 : C08.Statement) : C10.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA hR
  refine ⟨s2_rearrange hC8 M μ θ T t τ hA hR, fun h1 hlt => ?_⟩
  obtain ⟨hloc, hglob⟩ := s3_endpoint hC8 M μ θ T t τ hA hR h1
  linarith

end TinaV2.C10.A1
