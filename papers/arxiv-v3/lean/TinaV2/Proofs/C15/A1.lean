import TinaV2.Statements
import TinaV2.Routine.RadiusCalculus

/-! # C15, attempt A1: mirrors paper proof C15/p1

Proposition (marginal_balance), `main-v2.tex` 719-739. The paper's proof has
three steps: (1) `G > 0`, so maximizing `G` is maximizing `log G`; (2) at an
interior optimum `(log G)' = 0`; (3) differentiating Eq. (snapshot_gain) gives
the stated equality. -/

namespace TinaV2.C15.A1

open Real Set

/-- Step 1 (main-v2.tex 736): `G(r) > 0` on `[0, D]`, so a point maximizes `G`
on `[0, D]` exactly when it maximizes `log G` there. -/
theorem s1_max_log (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D) :
    (∀ r ∈ Icc 0 D, 0 < gain η τ T r) ∧
    ∀ rstar ∈ Icc 0 D,
      (IsMaxOn (gain η τ T) (Icc 0 D) rstar ↔
        IsMaxOn (fun r => log (gain η τ T r)) (Icc 0 D) rstar) := by
  have hpos : ∀ r ∈ Icc 0 D, 0 < gain η τ T r := fun r hr =>
    mul_pos (sub_pos.mpr (hc.η_range r hr).2) (exp_pos _)
  refine ⟨hpos, fun rstar hrstar => ?_⟩
  simp only [isMaxOn_iff]
  exact forall₂_congr fun r hr => (log_le_log_iff (hpos r hr) (hpos rstar hrstar)).symm

/-- Step 2 (main-v2.tex 737): at an interior optimum, `(log G)' = 0`. -/
theorem s2_interior_deriv_zero (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D)
    (rstar : ℝ) (hr : rstar ∈ Ioo 0 D) (hmax : IsMaxOn (gain η τ T) (Icc 0 D) rstar) :
    deriv (fun r => log (gain η τ T r)) rstar = 0 := by
  have hlogmax : IsMaxOn (fun r => log (gain η τ T r)) (Icc 0 D) rstar :=
    ((s1_max_log η τ T D hc).2 rstar (Ioo_subset_Icc_self hr)).mp hmax
  exact (hlogmax.isLocalMax (Icc_mem_nhds hr.1 hr.2)).deriv_eq_zero

/-- Step 3 (main-v2.tex 737-738): differentiating Eq. (snapshot_gain) at an
interior point gives `(log G)' = d/dr log[1 − η(r)] − 2τ'(r)/T`; with step 2
this is the stated equality at an interior optimum. -/
theorem s3_differentiate_gain (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D)
    (rstar : ℝ) (hr : rstar ∈ Ioo 0 D) :
    deriv (fun r => log (gain η τ T r)) rstar
        = deriv (fun r => log (1 - η r)) rstar - 2 * deriv τ rstar / T ∧
    (IsMaxOn (gain η τ T) (Icc 0 D) rstar →
      deriv (fun r => log (1 - η r)) rstar = 2 * deriv τ rstar / T) := by
  have hη : DifferentiableAt ℝ η rstar :=
    RadiusCalculus.differentiableAt_of_contDiffOn_Icc hc.η_contDiffOn hr
  have hτ : DifferentiableAt ℝ τ rstar :=
    RadiusCalculus.differentiableAt_of_contDiffOn_Icc hc.τ_contDiffOn hr
  have hlog : DifferentiableAt ℝ (fun r => log (1 - η r)) rstar :=
    ((differentiableAt_const 1).sub hη).log
      (sub_pos.mpr (hc.η_range rstar (Ioo_subset_Icc_self hr)).2).ne'
  have hdelay : DifferentiableAt ℝ (fun r => 2 * τ r / T) rstar :=
    (hτ.const_mul 2).div_const T
  have hform : deriv (fun r => log (gain η τ T r)) rstar
      = deriv (fun r => log (1 - η r)) rstar - 2 * deriv τ rstar / T := by
    have hEq : (fun r => log (gain η τ T r))
        =ᶠ[nhds rstar] fun r => log (1 - η r) - 2 * τ r / T := by
      filter_upwards [Icc_mem_nhds hr.1 hr.2] with r hrD
      exact RadiusCalculus.log_gain (hc.η_range r hrD).2
    rw [hEq.deriv_eq, deriv_fun_sub hlog hdelay, deriv_div_const, deriv_const_mul 2 hτ]
  refine ⟨hform, fun hmax => ?_⟩
  have hzero := s2_interior_deriv_zero η τ T D hc rstar hr hmax
  rw [hform] at hzero
  exact sub_eq_zero.mp hzero

/-- Proposition (marginal_balance): assembly of the three steps. -/
theorem main : C15.Statement := fun η τ T D _ hc rstar hr hmax =>
  (s3_differentiate_gain η τ T D hc rstar hr).2 hmax

end TinaV2.C15.A1
