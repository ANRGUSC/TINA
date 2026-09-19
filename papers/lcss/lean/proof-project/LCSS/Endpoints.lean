import LCSS.Value

set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

def localInfo (t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  historySigma (fun r : Set.Iic t => M.Y r i)
def localPolicy (t : ℝ) (i : Fin p.n) := (p.a / p.d) • M.Y t i
def localForm (p : Parameters) (t : ℝ) (i : Fin p.n) : SourceIndex p.n →₀ ℝ :=
  (p.a / p.d) • atom (some i) t
def localGradientForm (p : Parameters) (t : ℝ) (i : Fin p.n) : SourceIndex p.n →₀ ℝ :=
  (1+p.κ) • localForm p t i - p.κ • ((p.n : ℝ)⁻¹ • ∑ j, localForm p t j) - atom none t

@[simp] theorem lin_local (t : ℝ) (i : Fin p.n) :
    lin M.source (localForm p t i) = M.localPolicy t i := by simp [localForm, localPolicy]
@[simp] theorem lin_localGradient (t : ℝ) (i : Fin p.n) :
    lin M.source (localGradientForm p t i) = gradient p.κ (M.X t) (M.localPolicy t) i := by
  simp [localGradientForm, gradient, average]

theorem average_localPolicy (t : ℝ) : average (M.localPolicy t) = (p.a/p.d) • M.pool t := by
  simp only [average, localPolicy, ← Finset.smul_sum, pool, smul_smul]
  congr 1
  ring

theorem local_gradient_orthogonal (t r : ℝ) (i : Fin p.n) :
    ⟪gradient p.κ (M.X t) (M.localPolicy t) i, M.Y r i⟫_ℝ = 0 := by
  simp only [gradient, localPolicy, inner_sub_left, real_inner_smul_left,
    M.inner_Y_Y, ite_true, M.inner_X_Y]
  change (1+p.κ) * (p.a/p.d * ((p.a+p.b)*kernel p.rate t r)) -
    p.κ * ⟪average (M.localPolicy t), M.Y r i⟫_ℝ - p.a * kernel p.rate t r = 0
  rw [M.average_localPolicy, real_inner_smul_left, M.inner_pool_Y]
  field_simp [ne_of_gt p.d_pos]
  linear_combination p.a * kernel p.rate t r * p.normal_identity

theorem local_gradient_indep (t : ℝ) (i : Fin p.n) :
    Indep (MeasurableSpace.comap
      ((gradient p.κ (M.X t) (M.localPolicy t) i : RV (μ := μ)) : Ω → ℝ) inferInstance)
      (M.localInfo t i) μ := by
  have h := lin_indep_history M.source M.gaussian M.centered
    (localGradientForm p t i) (fun r : Set.Iic t => atom (some i) r)
    (fun r => by simpa using M.local_gradient_orthogonal t r i)
  simpa [localInfo] using h

theorem local_feasible (t : ℝ) (i : Fin p.n) :
    M.localPolicy t i ∈ informationSpace (μ := μ) (M.localInfo t i) := by
  have h := history_mem (fun r : Set.Iic t => M.Y r i) ⟨t, by simp⟩
  exact (informationSpace _).smul_mem _ h

theorem local_stationarity (t : ℝ) (i : Fin p.n) (w : RV (μ := μ))
    (hw : w ∈ informationSpace (μ := μ) (M.localInfo t i)) :
    ⟪w, gradient p.κ (M.X t) (M.localPolicy t) i⟫_ℝ = 0 := by
  rw [real_inner_comm]
  apply inner_eq_zero_of_indep _ _ (historySigma_le _) (M.local_gradient_indep t i)
  · rw [← M.lin_localGradient]
    exact integral_lin_zero M.source M.centered _
  · exact mem_lpMeas_iff_aestronglyMeasurable.mp hw

theorem local_minimal (t : ℝ) (u : Fin p.n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (M.localInfo t i)) :
    teamCost p.κ (M.X t) (M.localPolicy t) ≤ teamCost p.κ (M.X t) u := by
  apply teamCost_minimal_of_orthogonal p.n_ne p.hκ
  intro i
  exact M.local_stationarity t i _
    ((informationSpace _).sub_mem (hu i) (M.local_feasible t i))

theorem local_cost (t : ℝ) : teamCost p.κ (M.X t) (M.localPolicy t) = p.localCost := by
  rw [teamCost_eq_of_stationary p.n_ne _ _ _
    (fun i => M.local_stationarity t i _ (M.local_feasible t i))]
  simp only [M.norm_X_sq, localPolicy, real_inner_smul_left, M.inner_Y_X, kernel_self,
    mul_one, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  dsimp [Parameters.localCost]
  field_simp [p.n_ne, ne_of_gt p.d_pos]

theorem hybrid_zero_policy (t : ℝ) (i : Fin p.n) :
    M.hybrid t t i = (p.a/p.v) • M.pool t := by
  simp [hybrid, prediction, innovation]

theorem pooled_cost (t : ℝ) : teamCost p.κ (M.X t) (M.hybrid t t) = p.pooledCost := by
  rw [M.hybrid_cost le_rfl]
  simp

end SensorModel
end
end LCSS
