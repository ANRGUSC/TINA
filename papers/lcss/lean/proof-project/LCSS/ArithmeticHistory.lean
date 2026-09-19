import LCSS.ReceivedInformation
import LCSS.Posterior

/-! Theorem 1 for literal arithmetic pooled messages at every past real time.
No simultaneous equality of uncountably many L² representatives is used. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal BigOperators ProbabilityTheory
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

abbrev arithmeticHybridInfo (s t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  M.localInfo t i ⊔ ⨆ r : Set.Iic s, MeasurableSpace.comap (M.message r) inferInstance

theorem arithmeticHybridInfo_le_full (s t : ℝ) (i : Fin p.n) :
    M.arithmeticHybridInfo s t i ≤ M.fullInfo s t i := by
  unfold fullInfo
  apply sup_le
  · apply iSup_le
    intro r
    have h := le_iSup (fun q => MeasurableSpace.comap
      (lin M.source (fullObservation p s t i q)) inferInstance) (Sum.inr r)
    simpa only [fullObservation, Sum.elim_inr, M.lin_atom] using h
  · apply iSup_le
    intro r
    apply Measurable.comap_le
    apply Measurable.const_mul
    apply Finset.measurable_sum
    intro j _
    have h := (comap_measurable
      (lin M.source (fullObservation p s t i (Sum.inl (j,r))))).mono
      (le_iSup (fun q => MeasurableSpace.comap
        (lin M.source (fullObservation p s t i q)) inferInstance) (Sum.inl (j,r))) le_rfl
    simpa only [fullInfo, fullObservation, Sum.elim_inl, M.lin_atom, historySigma] using h

theorem receivedSnapshotInfo_le_arithmetic (s t : ℝ) (i : Fin p.n) :
    M.receivedSnapshotInfo s t i ≤ M.arithmeticHybridInfo s t i := by
  exact sup_le_sup_left (le_iSup (fun r : Set.Iic s =>
    MeasurableSpace.comap (M.message r) inferInstance) ⟨s,by simp⟩) _

theorem hybrid_arithmetic_feasible {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.hybrid s t i ∈ informationSpace (μ := μ) (M.arithmeticHybridInfo s t i) :=
  informationSpace_mono (M.receivedSnapshotInfo_le_arithmetic s t i)
    (M.hybrid_received_snapshot_feasible hst i)

theorem hybrid_arithmetic_minimal {s t : ℝ} (hst : s ≤ t)
    (u : Fin p.n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (M.arithmeticHybridInfo s t i)) :
    teamCost p.κ (M.X t) (M.hybrid s t) ≤ teamCost p.κ (M.X t) u :=
  M.hybrid_minimal_full hst u (fun i =>
    informationSpace_mono (M.arithmeticHybridInfo_le_full s t i) (hu i))

theorem posterior_indep_full {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Indep (MeasurableSpace.comap ((M.X t - M.posterior s t i : RV (μ := μ)) : Ω → ℝ)
      inferInstance) (M.fullInfo s t i) μ := by
  have he : M.X t - M.posterior s t i =
      lin M.source (atom none t - posteriorForm p s t i) := by simp
  rw [he]
  apply lin_indep_history M.source M.gaussian M.centered
  intro q
  rw [← he]
  cases q with
  | inl q => simpa [fullObservation] using
      M.posterior_residual_orthogonal_past hst q.2.property i q.1
  | inr r => simpa [fullObservation] using
      M.posterior_residual_orthogonal_local s t r i

theorem posterior_arithmetic_feasible {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.posterior s t i ∈ informationSpace (μ := μ) (M.arithmeticHybridInfo s t i) := by
  have hl : informationSpace (μ := μ) (M.localInfo t i) ≤
      informationSpace (μ := μ) (M.arithmeticHybridInfo s t i) := informationSpace_mono le_sup_left
  have hn := hl (history_mem (fun r : Set.Iic t => M.Y r i) ⟨t,by simp⟩)
  have hs := hl (history_mem (fun r : Set.Iic t => M.Y r i) ⟨s,hst⟩)
  have hp : M.pool s ∈ informationSpace (μ := μ) (M.arithmeticHybridInfo s t i) := by
    apply mem_lpMeas_iff_aestronglyMeasurable.mpr
    have hm : Measurable[M.arithmeticHybridInfo s t i] (M.message s) :=
      (comap_measurable (M.message s)).mono
        ((le_iSup (fun r : Set.Iic s => MeasurableSpace.comap (M.message r) inferInstance)
          ⟨s,by simp⟩).trans le_sup_right) le_rfl
    exact hm.stronglyMeasurable.aestronglyMeasurable.congr (M.pool_eq_message_ae s).symm
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hp)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hn
      ((informationSpace _).smul_mem _ hs)))

theorem posterior_arithmetic_condVar {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Var[(M.X t : Ω → ℝ); μ | M.arithmeticHybridInfo s t i] =ᵐ[μ]
      (fun _ => kernel p.rate t s ^ 2 * p.pooledVariance +
        (1-kernel p.rate t s ^ 2) * p.localVariance) := by
  have hG := (M.arithmeticHybridInfo_le_full s t i).trans (historySigma_le _)
  have hi := indep_of_indep_of_le (M.posterior_indep_full hst i) le_rfl
    (M.arithmeticHybridInfo_le_full s t i)
  have hmean := condExp_eq_of_indep_residual _ _ hG hi
    (M.posterior_residual_centered s t i)
    (mem_lpMeas_iff_aestronglyMeasurable.mp (M.posterior_arithmetic_feasible hst i))
  have hsq := conditional_sq_of_indep _ hG hi
  have he : ((M.X t : Ω → ℝ) - μ[(M.X t : Ω → ℝ) | M.arithmeticHybridInfo s t i]) ^ 2 =ᵐ[μ]
      (fun ω => ((M.X t-M.posterior s t i) ω)^2) := by
    filter_upwards [hmean, Lp.coeFn_sub (M.X t) (M.posterior s t i)] with ω hm hr
    simp only [Pi.pow_apply, Pi.sub_apply, hm] at *
    rw [hr]
  unfold condVar
  exact (condExp_congr_ae he).trans
    (hsq.trans (Filter.EventuallyEq.of_eq (by rw [M.posterior_error_variance hst i])))

def arithmeticJH (t τ : ℝ) : ℝ :=
  optimalExpectedLoss p.κ (M.X t) (M.arithmeticHybridInfo (t-τ) t)

theorem arithmeticJH_eq {t τ : ℝ} (hτ : 0 ≤ τ) : M.arithmeticJH t τ = M.JH t τ := by
  rw [arithmeticJH, ← expectedLoss_eq_optimalExpectedLoss _ _ _ _
    (M.hybrid_arithmetic_feasible (by linarith)) (M.hybrid_arithmetic_minimal (by linarith)),
    expectedLoss_eq_teamCost, M.hybrid_cost_age t τ hτ, M.JH_eq t τ hτ]

end SensorModel

/-- Literal-message form of Theorem 1. The original theorem's nine claims
remain available, and the actual arithmetic-history optimum and conditional
variance are certified explicitly. -/
theorem theorem1_arithmetic {p : Parameters} (D : PaperModel (μ := μ) p)
    (t τ : ℝ) (hτ : 0 ≤ τ) :
    Theorem1Claims D.toSensorModel t τ ∧
    D.toSensorModel.arithmeticJH t τ = D.toSensorModel.JH t τ ∧
    (∀ i, D.toSensorModel.hybrid (t-τ) t i ∈ informationSpace (μ := μ)
      (D.toSensorModel.arithmeticHybridInfo (t-τ) t i)) ∧
    (∀ i, Var[(D.toSensorModel.X t : Ω → ℝ); μ |
      D.toSensorModel.arithmeticHybridInfo (t-τ) t i] =ᵐ[μ]
      (fun _ => p.rho τ ^ 2 * p.pooledVariance + (1-p.rho τ ^ 2)*p.localVariance)) := by
  refine ⟨theorem1 D t τ hτ, D.toSensorModel.arithmeticJH_eq hτ,
    D.toSensorModel.hybrid_arithmetic_feasible (by linarith), ?_⟩
  intro i
  simpa only [SensorModel.kernel_age t τ hτ] using
    D.toSensorModel.posterior_arithmetic_condVar (s := t-τ) (t := t) (by linarith) i

end
end LCSS
