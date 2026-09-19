import LCSS.Value
import Mathlib.Probability.CondVar

set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace ProbabilityTheory
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

theorem posterior_indep_hybrid {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Indep (MeasurableSpace.comap ((M.X t - M.posterior s t i : RV (μ := μ)) : Ω → ℝ)
      inferInstance) (M.hybridInfo s t i) μ := by
  have hrepr : M.X t - M.posterior s t i =
      lin M.source (atom none t - posteriorForm p s t i) := by simp
  rw [hrepr]
  apply lin_indep_history M.source M.gaussian M.centered
  intro q
  rw [← hrepr]
  cases q with
  | inl r =>
      simpa [hybridObservation] using M.posterior_residual_orthogonal_local s t r i
  | inr r =>
      simp only [hybridObservation, Sum.elim_inr, M.lin_pool,
        pool, average, real_inner_smul_right, inner_sum]
      simp [M.posterior_residual_orthogonal_past hst r.property]

theorem posterior_feasible {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.posterior s t i ∈ informationSpace (μ := μ) (M.hybridInfo s t i) := by
  have hnow := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inl (⟨t, by simp⟩ : Set.Iic t))
  have hthen := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inl (⟨s, by simpa only [Set.mem_Iic] using hst⟩ : Set.Iic t))
  have hpool := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inr (⟨s, by simp⟩ : Set.Iic s))
  simp only [hybridObservation, Sum.elim_inl, Sum.elim_inr, M.lin_atom, M.lin_pool] at *
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hpool)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hnow
      ((informationSpace _).smul_mem _ hthen)))

theorem posterior_residual_centered (s t : ℝ) (i : Fin p.n) :
    (∫ ω, (M.X t - M.posterior s t i) ω ∂μ) = 0 := by
  have h := integral_lin_zero M.source M.centered (atom none t - posteriorForm p s t i)
  simpa using h

theorem posterior_is_condExp {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    μ[(M.X t : Ω → ℝ) | M.hybridInfo s t i] =ᵐ[μ] (M.posterior s t i : Ω → ℝ) := by
  exact condExp_eq_of_indep_residual _ _ (historySigma_le _)
    (M.posterior_indep_hybrid hst i) (M.posterior_residual_centered s t i)
    (mem_lpMeas_iff_aestronglyMeasurable.mp (M.posterior_feasible hst i))

theorem inner_posterior_X (s t : ℝ) (i : Fin p.n) :
    ⟪M.posterior s t i, M.X t⟫_ℝ =
      kernel p.rate t s ^ 2 * (p.a ^ 2 / p.v) +
        (1 - kernel p.rate t s ^ 2) * (p.a ^ 2 / (p.a + p.b)) := by
  simp only [posterior, prediction, innovation, inner_add_left, inner_sub_left,
    real_inner_smul_left, M.inner_pool_X, M.inner_Y_X, kernel_self]
  rw [kernel_symm p.rate s t]
  ring

theorem posterior_error_variance {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    ‖M.X t - M.posterior s t i‖ ^ 2 =
      kernel p.rate t s ^ 2 * p.pooledVariance +
        (1 - kernel p.rate t s ^ 2) * p.localVariance := by
  have horth := inner_eq_zero_of_indep _ _ (historySigma_le _)
    (M.posterior_indep_hybrid hst i) (M.posterior_residual_centered s t i)
    (mem_lpMeas_iff_aestronglyMeasurable.mp (M.posterior_feasible hst i))
  have hnorm : ‖M.X t - M.posterior s t i‖ ^ 2 =
      p.a - ⟪M.posterior s t i, M.X t⟫_ℝ := by
    rw [inner_sub_left, real_inner_self_eq_norm_sq] at horth
    rw [norm_sub_sq_real, M.norm_X_sq]
    have hc := real_inner_comm (M.X t) (M.posterior s t i)
    linarith
  rw [hnorm, M.inner_posterior_X, ← p.pooledCost_eq_variance]
  dsimp [Parameters.pooledCost, Parameters.localVariance]
  field_simp [ne_of_gt p.v_pos, ne_of_gt (add_pos p.ha p.hb)]
  <;> ring

theorem posterior_condVar {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Var[(M.X t : Ω → ℝ); μ | M.hybridInfo s t i] =ᵐ[μ]
      (fun _ => kernel p.rate t s ^ 2 * p.pooledVariance +
        (1 - kernel p.rate t s ^ 2) * p.localVariance) := by
  have hmean := M.posterior_is_condExp hst i
  have hsq := conditional_sq_of_indep _ (historySigma_le _) (M.posterior_indep_hybrid hst i)
  have hrewrite : ((M.X t : Ω → ℝ) - μ[(M.X t : Ω → ℝ) | M.hybridInfo s t i]) ^ 2 =ᵐ[μ]
      (fun ω => ((M.X t - M.posterior s t i) ω)^2) := by
    filter_upwards [hmean, Lp.coeFn_sub (M.X t) (M.posterior s t i)] with ω hm hr
    simp only [Pi.pow_apply, Pi.sub_apply, hm] at *
    rw [hr]
  unfold condVar
  exact (condExp_congr_ae hrewrite).trans
    (hsq.trans (Filter.EventuallyEq.of_eq (by rw [M.posterior_error_variance hst i])))

theorem posterior_condVar_age (t τ : ℝ) (hτ : 0 ≤ τ) (i : Fin p.n) :
    Var[(M.X t : Ω → ℝ); μ | M.hybridInfo (t-τ) t i] =ᵐ[μ]
      (fun _ => p.hybridVariance τ) := by
  have h := M.posterior_condVar (s := t-τ) (t := t) (by linarith) i
  simpa only [(kernel_age (p := p)) t τ hτ, Parameters.hybridVariance] using h

end SensorModel
end
end LCSS
