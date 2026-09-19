import LCSS.History

set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

theorem inner_hybrid_X (s t : ℝ) (i : Fin p.n) :
    ⟪M.hybrid s t i, M.X t⟫_ℝ =
      kernel p.rate t s ^ 2 * (p.a ^ 2 / p.v) +
        (1 - kernel p.rate t s ^ 2) * (p.a ^ 2 / p.d) := by
  simp only [hybrid, prediction, innovation, inner_add_left, inner_sub_left,
    real_inner_smul_left, M.inner_pool_X, M.inner_Y_X, kernel_self]
  rw [kernel_symm p.rate s t]
  ring

theorem hybrid_cost {s t : ℝ} (hst : s ≤ t) :
    teamCost p.κ (M.X t) (M.hybrid s t) =
      kernel p.rate t s ^ 2 * p.pooledCost +
        (1 - kernel p.rate t s ^ 2) * p.localCost := by
  have hstationary : ∀ i,
      ⟪M.hybrid s t i, gradient p.κ (M.X t) (M.hybrid s t) i⟫_ℝ = 0 := by
    intro i
    rw [real_inner_comm]
    apply inner_eq_zero_of_indep _ _ (historySigma_le _) (M.gradient_indep_hybrid hst i)
    · rw [← M.lin_gradient]; exact integral_lin_zero M.source M.centered _
    · exact mem_lpMeas_iff_aestronglyMeasurable.mp (M.hybrid_feasible_hybrid hst i)
  rw [teamCost_eq_of_stationary p.n_ne _ _ _ hstationary]
  simp only [M.norm_X_sq, M.inner_hybrid_X, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, Parameters.pooledCost, Parameters.localCost]
  field_simp [p.n_ne, ne_of_gt p.v_pos, ne_of_gt p.d_pos]
  <;> ring

theorem kernel_age (t τ : ℝ) (hτ : 0 ≤ τ) :
    kernel p.rate t (t-τ) = p.rho τ := by
  simp [kernel, Parameters.rho, abs_of_nonneg hτ]

theorem hybrid_cost_age (t τ : ℝ) (hτ : 0 ≤ τ) :
    teamCost p.κ (M.X t) (M.hybrid (t-τ) t) = p.hybridCost τ := by
  rw [M.hybrid_cost (by linarith), (kernel_age (p := p)) t τ hτ]
  rfl

theorem exponential_coordination_value (t τ : ℝ) (hτ : 0 ≤ τ) :
    p.localCost - teamCost p.κ (M.X t) (M.hybrid (t-τ) t) =
      p.delta * Real.exp (-2 * p.rate * τ) := by
  rw [M.hybrid_cost_age t τ hτ]
  exact p.exponential_value τ

end SensorModel
end
end LCSS
