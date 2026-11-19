import TinaV2.Statements

/-! # C10.b, attempt A1: mirrors the supplement proof C10.b/p1

The paper states the two sentences after the crossover theorem without
argument (`main-v3.tex` 516-519). The proof mirrored here is not in the paper.
It is the supplement proof `C10.b/p1` in the ledger
(`python3 tools/ledger.py supplement C10.b`), written for the formalization
under disposition `C10.b/d1`. One lemma per step of that proof, in its order,
then `main`. The crossover theorem C10 enters as the hypothesis
`hC10 : C10.Statement`. -/

namespace TinaV2.C10b.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (supplied). "If `η_S(0) = 0`, then `R_loc = η_S(0) R_∞ = 0`, and
`ρ⋆ = ½ log 1 = 0`. By Theorem (local_global_crossover), fresh-local
information is strictly better exactly when `τ/T > 0`, that is, since `T > 0`,
at every positive delay." -/
theorem s1_zero_share (hC10 : C10.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t))
    (hη : M.etaS μ 0 (θ t) = 0) :
    M.Rloc μ (θ t) = 0 ∧
      (0 < τ → M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t)) := by
  have hloc : M.Rloc μ (θ t) = M.etaS μ 0 (θ t) * M.Rinf μ (θ t) := by
    rw [Model.etaS, Model.Rloc, div_mul_cancel₀ _ hR.ne']
  have hρ : rhoStar (M.etaS μ 0 (θ t)) = 0 := by simp [hη, rhoStar]
  refine ⟨by rw [hloc, hη, zero_mul], fun hτ => ?_⟩
  have h := ((hC10 M μ θ T t τ hA hR).1 (by rw [hη]; exact zero_lt_one)).1
  rw [hρ] at h
  exact h.mpr (div_pos hτ hA.T_pos)

/-- Step 2 (supplied). "If `0 < η_S(0) < 1`, then `0 < 1 − η_S(0) < 1`, so
`1/(1 − η_S(0)) > 1` and `ρ⋆ = ½ log (1/(1 − η_S(0))) > 0`." -/
theorem s2_threshold_pos (η : ℝ) (h0 : 0 < η) (h1 : η < 1) : 0 < rhoStar η := by
  have hpos : 0 < 1 - η := sub_pos.mpr h1
  have hgt : 1 < 1 / (1 - η) := by
    rw [lt_div_iff₀ hpos]
    linarith
  have := Real.log_pos hgt
  rw [rhoStar]
  positivity

/-- Step 3 (supplied). "Let `η_S(0) < 1`. By Theorem (local_global_crossover),
fresh-local information is strictly better exactly when `τ/T > ρ⋆`, and the two
regrets are equal exactly when `τ/T = ρ⋆`. If `τ/T < ρ⋆`, neither holds, so
stale-global information is strictly better. Hence the two losses are equal at
one delay only, `τ = ρ⋆ T`, with stale-global strictly better before it and
fresh-local strictly better after it." -/
theorem s3_single_crossing (hC10 : C10.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t))
    (hη : M.etaS μ 0 (θ t) < 1) :
    (τ / T < rhoStar (M.etaS μ 0 (θ t)) →
        M.Rglob μ (θ (t - τ)) (θ t) < M.Rloc μ (θ t)) ∧
      (τ / T = rhoStar (M.etaS μ 0 (θ t)) →
        M.Rloc μ (θ t) = M.Rglob μ (θ (t - τ)) (θ t)) ∧
      (rhoStar (M.etaS μ 0 (θ t)) < τ / T →
        M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t)) := by
  obtain ⟨hlt, heq⟩ := (hC10 M μ θ T t τ hA hR).1 hη
  refine ⟨fun hbelow => ?_, heq.mp, hlt.mpr⟩
  rcases lt_trichotomy (M.Rglob μ (θ (t - τ)) (θ t)) (M.Rloc μ (θ t)) with h | h | h
  · exact h
  · exact absurd (heq.mpr h.symm) hbelow.ne
  · exact absurd (hlt.mp h) (not_lt.mpr hbelow.le)

/-- The two sentences after Theorem (local_global_crossover). -/
theorem main (hC10 : C10.Statement) : C10b.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA hR
  exact ⟨s1_zero_share hC10 M μ θ T t τ hA hR,
    fun h0 h1 => ⟨s2_threshold_pos _ h0 h1, s3_single_crossing hC10 M μ θ T t τ hA hR h1⟩⟩

end TinaV2.C10b.A1
