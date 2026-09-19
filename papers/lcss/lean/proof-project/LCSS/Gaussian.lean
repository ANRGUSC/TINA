import Mathlib.Probability.Distributions.Gaussian.IsGaussianProcess.Independence
import Mathlib.Probability.ConditionalExpectation
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.LinearAlgebra.Finsupp.LinearCombination
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Module

/-! Finite linear combinations and independence from an arbitrary indexed history.
The history-independence argument is adapted from Release 7 GaussianHistory. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal RealInnerProductSpace ProbabilityTheory
variable {Ω T J : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
abbrev RV := Lp ℝ (2 : ℝ≥0∞) μ
abbrev historySigma (Y : J → RV (μ := μ)) : MeasurableSpace Ω :=
  ⨆ j, MeasurableSpace.comap (Y j) inferInstance

theorem historySigma_le (Y : J → RV (μ := μ)) : historySigma Y ≤ mΩ := by
  exact iSup_le (fun j => (Lp.stronglyMeasurable (Y j)).measurable.comap_le)

abbrev lin (S : T → RV (μ := μ)) : (T →₀ ℝ) →ₗ[ℝ] RV (μ := μ) :=
  Finsupp.linearCombination ℝ S

theorem lin_ae (S : T → RV (μ := μ)) (c : T →₀ ℝ) :
    (lin S c : Ω → ℝ) =ᵐ[μ]
      Finsupp.linearCombination ℝ (fun q => (S q : Ω → ℝ)) c := by
  induction c using Finsupp.induction_linear with
  | zero => simpa using (Lp.coeFn_zero ℝ (2 : ℝ≥0∞) μ)
  | add c d hc hd =>
      simp only [map_add]
      filter_upwards [Lp.coeFn_add (lin S c) (lin S d), hc, hd] with ω h hc hd
      simpa [hc, hd] using h
  | single q r => simpa using (Lp.coeFn_smul r (S q))

theorem lin_gaussian (S : T → RV (μ := μ))
    (hS : IsGaussianProcess (fun q => (S q : Ω → ℝ)) μ) (c : J → T →₀ ℝ) :
    IsGaussianProcess (fun j => (lin S (c j) : Ω → ℝ)) μ := by
  classical
  have hraw : IsGaussianProcess
      (fun j => Finsupp.linearCombination ℝ (fun q => (S q : Ω → ℝ)) (c j)) μ := by
    apply hS.of_isGaussianProcess
    intro j
    let I := (c j).support
    let L : (I → ℝ) →L[ℝ] ℝ :=
      { toFun := fun x => ∑ q : I, c j q * x q
        map_add' := by intro x y; simp [mul_add, Finset.sum_add_distrib]
        map_smul' := by intro r x; simp [Finset.mul_sum]; congr 1; ext q; ring }
    refine ⟨I, L, ?_⟩
    intro ω
    simpa [L, I, Finsupp.linearCombination_apply, Finsupp.sum] using
      ((c j).support.sum_attach (fun q => c j q * S q ω)).symm
  exact hraw.congr (fun j => (lin_ae S (c j)).symm)

theorem integral_lin_zero (S : T → RV (μ := μ))
    (hS : ∀ q, ∫ ω, S q ω ∂μ = 0) (c : T →₀ ℝ) :
    (∫ ω, lin S c ω ∂μ) = 0 := by
  induction c using Finsupp.induction_linear with
  | zero => simp
  | add c d hc hd =>
      rw [map_add, integral_congr_ae (Lp.coeFn_add _ _)]
      change (∫ ω, lin S c ω + lin S d ω ∂μ) = 0
      rw [integral_add ((Lp.memLp (lin S c)).integrable (by norm_num))
        ((Lp.memLp (lin S d)).integrable (by norm_num)), hc, hd]
      simp
  | single q r =>
      simp only [Finsupp.linearCombination_single]
      rw [integral_congr_ae (Lp.coeFn_smul r (S q))]
      simp [integral_const_mul, hS]

theorem covariance_eq_inner (f g : RV (μ := μ))
    (hf : ∫ ω, f ω ∂μ = 0) (hg : ∫ ω, g ω ∂μ = 0) :
    cov[f, g; μ] = ⟪f, g⟫_ℝ := by
  rw [covariance_eq_sub (Lp.memLp f) (Lp.memLp g), hf, hg]
  simp [L2.inner_def, real_inner_comm, mul_comm]

theorem lin_indep_history (S : T → RV (μ := μ))
    (hS : IsGaussianProcess (fun q => (S q : Ω → ℝ)) μ)
    (hmean : ∀ q, ∫ ω, S q ω ∂μ = 0)
    (c : T →₀ ℝ) (obs : J → T →₀ ℝ)
    (horth : ∀ j, ⟪lin S c, lin S (obs j)⟫_ℝ = 0) :
    Indep (MeasurableSpace.comap (lin S c) inferInstance)
      (historySigma (fun j => lin S (obs j))) μ := by
  have hj := lin_gaussian S hS (Sum.elim (fun _ : Unit => c) obs)
  have hj' : IsGaussianProcess (Sum.elim
      (fun _ : Unit => (lin S c : Ω → ℝ)) (fun j => (lin S (obs j) : Ω → ℝ))) μ := by
    convert hj using 1
    ext q ω
    cases q <;> rfl
  have hi := hj'.indepFun_of_covariance_eq_zero
    (X := fun _ : Unit => (lin S c : Ω → ℝ))
    (Y := fun j => (lin S (obs j) : Ω → ℝ))
    (fun _ => (Lp.stronglyMeasurable _).measurable.aemeasurable)
    (fun _ => (Lp.stronglyMeasurable _).measurable.aemeasurable)
    (fun _ j => by rw [covariance_eq_inner _ _ (integral_lin_zero S hmean c)
      (integral_lin_zero S hmean (obs j))]; exact horth j)
  have hi' := hi.comp (measurable_pi_apply ()) measurable_id
  rw [IndepFun_iff_Indep] at hi'
  simpa [historySigma, MeasurableSpace.comap_process_pi, Function.comp_def] using hi'

/-- Gaussian independence yields orthogonality to every square-integrable
history-measurable random variable, including nonlinear policies. -/
theorem inner_eq_zero_of_indep (R w : RV (μ := μ))
    {G : MeasurableSpace Ω} (hG : G ≤ mΩ)
    (hi : Indep (MeasurableSpace.comap R inferInstance) G μ)
    (hmean : ∫ ω, R ω ∂μ = 0) (hw : AEStronglyMeasurable[G] w μ) :
    ⟪R, w⟫_ℝ = 0 := by
  let v := hw.mk w
  have hv : StronglyMeasurable[G] v := hw.stronglyMeasurable_mk
  have hiv : IndepFun (R : Ω → ℝ) v μ :=
    (IndepFun_iff_Indep _ _ μ).2
      (indep_of_indep_of_le hi le_rfl hv.measurable.comap_le)
  rw [L2.inner_def]
  calc
    (∫ ω, inner ℝ (R ω) (w ω) ∂μ) = ∫ ω, R ω * v ω ∂μ := by
      apply integral_congr_ae
      filter_upwards [hw.ae_eq_mk] with ω hω
      simp [hω, real_inner_comm, mul_comm, v]
    _ = (∫ ω, R ω ∂μ) * (∫ ω, v ω ∂μ) :=
      hiv.integral_fun_mul_eq_mul_integral (Lp.aestronglyMeasurable R)
        (hv.mono hG).aestronglyMeasurable
    _ = 0 := by rw [hmean, zero_mul]

theorem integral_sq_eq_norm_sq (R : RV (μ := μ)) :
    (∫ ω, (R ω)^2 ∂μ) = ‖R‖^2 := by
  rw [← real_inner_self_eq_norm_sq, L2.inner_def]
  simp [pow_two, real_inner_self_eq_norm_sq, Real.norm_eq_abs, sq_abs]

theorem condExp_eq_of_indep_residual (X m : RV (μ := μ))
    {G : MeasurableSpace Ω} (hG : G ≤ mΩ)
    (hi : Indep (MeasurableSpace.comap (X-m) inferInstance) G μ)
    (hmean : ∫ ω, (X-m) ω ∂μ = 0) (hm : AEStronglyMeasurable[G] m μ) :
    μ[(X : Ω → ℝ) | G] =ᵐ[μ] (m : Ω → ℝ) := by
  have hR := condExp_indep_eq (Lp.stronglyMeasurable (X-m)).measurable.comap_le
    hG (comap_measurable (X-m)).stronglyMeasurable hi
  have hm' := condExp_of_aestronglyMeasurable' hG hm
    (Lp.memLp m |>.integrable (by norm_num))
  have hs := condExp_add (Lp.memLp (X-m) |>.integrable (by norm_num))
    (Lp.memLp m |>.integrable (by norm_num)) G
  have hae : (X : Ω → ℝ) =ᵐ[μ] (fun ω => (X-m) ω + m ω) := by
    filter_upwards [Lp.coeFn_sub X m] with ω hω
    simp only [Pi.sub_apply] at hω
    rw [hω]; ring
  have hc := condExp_congr_ae (m := G) hae
  filter_upwards [hR, hm', hs, hc] with ω hr hm hs hc
  simp only [hmean] at hr
  rw [hc]
  change μ[(↑(X-m) + ↑m : Ω → ℝ) | G] ω = m ω
  rw [hs]
  simp only [Pi.add_apply, hr, hm, zero_add]

theorem conditional_sq_of_indep (R : RV (μ := μ))
    {G : MeasurableSpace Ω} (hG : G ≤ mΩ)
    (hi : Indep (MeasurableSpace.comap R inferInstance) G μ) :
    μ[(fun ω => (R ω)^2) | G] =ᵐ[μ] (fun _ => ‖R‖^2) := by
  have h := condExp_indep_eq (Lp.stronglyMeasurable R).measurable.comap_le hG
    ((comap_measurable R).pow_const 2).stronglyMeasurable hi
  simpa only [integral_sq_eq_norm_sq] using h

end
end LCSS
