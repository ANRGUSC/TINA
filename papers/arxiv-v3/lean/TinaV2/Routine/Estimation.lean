import TinaV2.Defs
import TinaV2.Routine.Regret

/-! # Routine facts about the best mean-squared-error estimate (claim C11)

What the two-sensor example (`main-v2.tex`, paragraph "A two-sensor example")
leaves unsaid:

* nonemptiness and boundedness of the family the infimum in `bestMSE` runs over;
* square-integrability of halves and averages, and linearity of conditional
  expectation for the average `(U + V)/2`;
* the textbook fact that the conditional mean is the best estimate: if
  `E[target | obs] = h(obs)` then the error `target − h(obs)` is orthogonal to
  every square-integrable function of `obs`, so `h` attains the smallest mean
  squared error. The paper uses this as understood ("our best estimate is ...")
  and neither argues nor cites it;
* two library-level facts about independence that Mathlib v4.33.1 does not
  have: conditioning on an extra independent observation does not change a
  conditional expectation, and an independent pair with stationary marginals
  has a stationary joint law.

Nothing here is a step of a paper proof. This file imports `Defs/` and
`Routine/Regret` only (plus `Mathlib.Probability.ConditionalExpectation` for
`condExp_indep_eq`, used by the proof file). -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Set

variable {Ω O : Type} [mΩ : MeasurableSpace Ω] [MeasurableSpace O]

/-! ## The family the infimum in `bestMSE` runs over -/

/-- The zero function is an estimator, so the family is nonempty. -/
instance nonempty_estimator (μ : Measure Ω) (obs : Ω → O) :
    Nonempty {g : O → ℝ // Measurable g ∧ MemLp (fun ω => g (obs ω)) 2 μ} :=
  ⟨⟨fun _ => 0, measurable_const, MemLp.zero'⟩⟩

/-- The best error is at most the error of any estimator. -/
theorem bestMSE_le (μ : Measure Ω) (target : Ω → ℝ) (obs : Ω → O) {g : O → ℝ}
    (hg : Measurable g) (hg2 : MemLp (fun ω => g (obs ω)) 2 μ) :
    bestMSE μ target obs ≤ ∫ ω, (target ω - g (obs ω)) ^ 2 ∂μ :=
  ciInf_le (f := fun g : {g : O → ℝ // Measurable g ∧ MemLp (fun ω => g (obs ω)) 2 μ} =>
      ∫ ω, (target ω - g.1 (obs ω)) ^ 2 ∂μ)
    (bddBelow_range_of_nonneg fun _ => integral_nonneg fun _ => sq_nonneg _) ⟨g, hg, hg2⟩

/-! ## Square-integrability of halves and averages -/

/-- `f / c` is square-integrable when `f` is. -/
theorem memLp_div_const {μ : Measure Ω} {f : Ω → ℝ} (hf : MemLp f 2 μ) (c : ℝ) :
    MemLp (fun ω => f ω / c) 2 μ := by
  simpa [div_eq_inv_mul] using hf.const_mul c⁻¹

/-- The average `(U + V)/2` is square-integrable when `U` and `V` are. -/
theorem memLp_half_add {μ : Measure Ω} {U V : Ω → ℝ} (hU : MemLp U 2 μ) (hV : MemLp V 2 μ) :
    MemLp (fun ω => (U ω + V ω) / 2) 2 μ :=
  memLp_div_const (hU.add hV) 2

/-! ## Linearity of conditional expectation for an average -/

/-- `E[(U + V)/2 | m] = (E[U | m] + E[V | m])/2`. -/
theorem condExp_half_add {μ : Measure Ω} {m : MeasurableSpace Ω} {U V u v : Ω → ℝ}
    (hU : Integrable U μ) (hV : Integrable V μ)
    (hUc : μ[U | m] =ᵐ[μ] u) (hVc : μ[V | m] =ᵐ[μ] v) :
    μ[fun ω => (U ω + V ω) / 2 | m] =ᵐ[μ] fun ω => (u ω + v ω) / 2 := by
  have h1 : (fun ω => (U ω + V ω) / 2) = (2⁻¹ : ℝ) • (U + V) := by
    funext ω
    simp [div_eq_inv_mul]
  rw [h1]
  filter_upwards [condExp_smul (2⁻¹ : ℝ) (U + V) m, condExp_add hU hV m, hUc, hVc]
    with ω h2 h3 h4 h5
  rw [h2, Pi.smul_apply, h3, Pi.add_apply, h4, h5, smul_eq_mul]
  ring

/-! ## The conditional mean is the best estimate -/

/-- Orthogonality: if `E[target | obs] = h(obs)`, the error `target − h(obs)`
is orthogonal to every square-integrable function `k(obs)` of the observation. -/
theorem integral_mul_error_of_condExp {μ : Measure Ω} [IsFiniteMeasure μ] {target : Ω → ℝ}
    {obs : Ω → O} {h k : O → ℝ} (hobs : Measurable obs) (ht : MemLp target 2 μ)
    (hh : Measurable h) (hh2 : MemLp (fun ω => h (obs ω)) 2 μ)
    (hk : Measurable k) (hk2 : MemLp (fun ω => k (obs ω)) 2 μ)
    (hcond : μ[target | MeasurableSpace.comap obs inferInstance] =ᵐ[μ] fun ω => h (obs ω)) :
    ∫ ω, k (obs ω) * (target ω - h (obs ω)) ∂μ = 0 := by
  have hm : MeasurableSpace.comap obs inferInstance ≤ mΩ := hobs.comap_le
  have hkm : StronglyMeasurable[MeasurableSpace.comap obs inferInstance] fun ω => k (obs ω) :=
    (hk.comp (comap_measurable obs)).stronglyMeasurable
  have hhm : StronglyMeasurable[MeasurableSpace.comap obs inferInstance] fun ω => h (obs ω) :=
    (hh.comp (comap_measurable obs)).stronglyMeasurable
  have htint : Integrable target μ := ht.integrable one_le_two
  have hhint : Integrable (fun ω => h (obs ω)) μ := hh2.integrable one_le_two
  have hE2 : MemLp (fun ω => target ω - h (obs ω)) 2 μ := ht.sub hh2
  have hEint : Integrable (fun ω => target ω - h (obs ω)) μ := hE2.integrable one_le_two
  have hkE : Integrable (fun ω => k (obs ω) * (target ω - h (obs ω))) μ := hk2.integrable_mul hE2
  -- `E[target − h(obs) | obs] = 0`
  have hE_cond : μ[fun ω => target ω - h (obs ω) | MeasurableSpace.comap obs inferInstance]
      =ᵐ[μ] 0 := by
    have h1 := condExp_sub htint hhint (MeasurableSpace.comap obs inferInstance)
    have h2 : μ[fun ω => h (obs ω) | MeasurableSpace.comap obs inferInstance]
        = fun ω => h (obs ω) := condExp_of_stronglyMeasurable hm hhm hhint
    filter_upwards [h1, hcond] with ω h1 h3
    have h1' : (μ[fun ω => target ω - h (obs ω) | MeasurableSpace.comap obs inferInstance]) ω
        = (μ[target | MeasurableSpace.comap obs inferInstance]) ω
          - (μ[fun ω => h (obs ω) | MeasurableSpace.comap obs inferInstance]) ω := h1
    rw [h1', h2, h3]
    simp
  calc ∫ ω, k (obs ω) * (target ω - h (obs ω)) ∂μ
      = ∫ ω, (μ[fun ω => k (obs ω) * (target ω - h (obs ω)) |
          MeasurableSpace.comap obs inferInstance]) ω ∂μ := (integral_condExp hm).symm
    _ = ∫ ω, k (obs ω) * (μ[fun ω => target ω - h (obs ω) |
          MeasurableSpace.comap obs inferInstance]) ω ∂μ :=
        integral_congr_ae (condExp_mul_of_stronglyMeasurable_left hkm hkE hEint)
    _ = ∫ _, (0 : ℝ) ∂μ := integral_congr_ae (by
        filter_upwards [hE_cond] with ω hω
        simp [hω])
    _ = 0 := by simp

/-- If `E[target | obs] = h(obs)`, then `h` attains the smallest mean squared
error among square-integrable functions of `obs`, and that error is
`E[(target − h(obs))²]`. -/
theorem bestMSE_eq_of_condExp {μ : Measure Ω} [IsFiniteMeasure μ] {target : Ω → ℝ}
    {obs : Ω → O} {h : O → ℝ} (hobs : Measurable obs) (ht : MemLp target 2 μ)
    (hh : Measurable h) (hh2 : MemLp (fun ω => h (obs ω)) 2 μ)
    (hcond : μ[target | MeasurableSpace.comap obs inferInstance] =ᵐ[μ] fun ω => h (obs ω)) :
    bestMSE μ target obs = ∫ ω, (target ω - h (obs ω)) ^ 2 ∂μ := by
  refine le_antisymm (bestMSE_le μ target obs hh hh2) (le_ciInf fun g => ?_)
  obtain ⟨g, hg, hg2⟩ := g
  change ∫ ω, (target ω - h (obs ω)) ^ 2 ∂μ ≤ ∫ ω, (target ω - g (obs ω)) ^ 2 ∂μ
  have hE2 : MemLp (fun ω => target ω - h (obs ω)) 2 μ := ht.sub hh2
  have hD2 : MemLp (fun ω => h (obs ω) - g (obs ω)) 2 μ := hh2.sub hg2
  -- the error of `h` is orthogonal to `h(obs) − g(obs)`
  have horth : ∫ ω, (h (obs ω) - g (obs ω)) * (target ω - h (obs ω)) ∂μ = 0 :=
    integral_mul_error_of_condExp (k := fun o => h o - g o) hobs ht hh hh2 (hh.sub hg) hD2 hcond
  have hI1 : Integrable (fun ω => (target ω - h (obs ω)) ^ 2) μ := hE2.integrable_sq
  have hI2 : Integrable (fun ω => 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))) μ :=
    (hD2.integrable_mul hE2).const_mul 2
  have hI3 : Integrable (fun ω => (h (obs ω) - g (obs ω)) ^ 2) μ := hD2.integrable_sq
  have hI12 : Integrable (fun ω => (target ω - h (obs ω)) ^ 2
      + 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))) μ := hI1.add hI2
  have hpt : ∀ ω, (target ω - g (obs ω)) ^ 2 = (target ω - h (obs ω)) ^ 2
      + 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))
      + (h (obs ω) - g (obs ω)) ^ 2 := fun ω => by ring
  simp_rw [hpt]
  rw [integral_add hI12 hI3, integral_add hI1 hI2, integral_const_mul, horth]
  have : 0 ≤ ∫ ω, (h (obs ω) - g (obs ω)) ^ 2 ∂μ := integral_nonneg fun _ => sq_nonneg _
  linarith

/-- Almost-sure uniqueness of the conditional-mean estimator: if
`E[target | obs] = h(obs)` and another square-integrable estimator `g(obs)`
achieves no larger mean squared error, then `g(obs) = h(obs)` almost surely. -/
theorem bestMSE_unique_of_condExp {μ : Measure Ω} [IsFiniteMeasure μ] {target : Ω → ℝ}
    {obs : Ω → O} {h g : O → ℝ} (hobs : Measurable obs) (ht : MemLp target 2 μ)
    (hh : Measurable h) (hh2 : MemLp (fun ω => h (obs ω)) 2 μ)
    (hg : Measurable g) (hg2 : MemLp (fun ω => g (obs ω)) 2 μ)
    (hcond : μ[target | MeasurableSpace.comap obs inferInstance] =ᵐ[μ] fun ω => h (obs ω))
    (hle : ∫ ω, (target ω - g (obs ω)) ^ 2 ∂μ ≤ ∫ ω, (target ω - h (obs ω)) ^ 2 ∂μ) :
    (fun ω => g (obs ω)) =ᵐ[μ] fun ω => h (obs ω) := by
  have hE2 : MemLp (fun ω => target ω - h (obs ω)) 2 μ := ht.sub hh2
  have hD2 : MemLp (fun ω => h (obs ω) - g (obs ω)) 2 μ := hh2.sub hg2
  have horth : ∫ ω, (h (obs ω) - g (obs ω)) * (target ω - h (obs ω)) ∂μ = 0 :=
    integral_mul_error_of_condExp (k := fun o => h o - g o) hobs ht hh hh2 (hh.sub hg) hD2 hcond
  have hI1 : Integrable (fun ω => (target ω - h (obs ω)) ^ 2) μ := hE2.integrable_sq
  have hI2 : Integrable (fun ω => 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))) μ :=
    (hD2.integrable_mul hE2).const_mul 2
  have hI3 : Integrable (fun ω => (h (obs ω) - g (obs ω)) ^ 2) μ := hD2.integrable_sq
  have hI12 : Integrable (fun ω => (target ω - h (obs ω)) ^ 2
      + 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))) μ := hI1.add hI2
  have hpt : ∀ ω, (target ω - g (obs ω)) ^ 2 = (target ω - h (obs ω)) ^ 2
      + 2 * ((h (obs ω) - g (obs ω)) * (target ω - h (obs ω)))
      + (h (obs ω) - g (obs ω)) ^ 2 := fun ω => by ring
  have hexp : ∫ ω, (target ω - g (obs ω)) ^ 2 ∂μ
      = ∫ ω, (target ω - h (obs ω)) ^ 2 ∂μ + ∫ ω, (h (obs ω) - g (obs ω)) ^ 2 ∂μ := by
    simp_rw [hpt]
    rw [integral_add hI12 hI3, integral_add hI1 hI2, integral_const_mul, horth]
    ring
  have hzero : ∫ ω, (h (obs ω) - g (obs ω)) ^ 2 ∂μ = 0 :=
    le_antisymm (by linarith) (integral_nonneg fun _ => sq_nonneg _)
  have hae : (fun ω => (h (obs ω) - g (obs ω)) ^ 2) =ᵐ[μ] 0 :=
    (integral_eq_zero_iff_of_nonneg_ae (Filter.Eventually.of_forall fun _ => sq_nonneg _) hI3).1
      hzero
  filter_upwards [hae] with ω hω
  exact (sub_eq_zero.1 (sq_eq_zero_iff.1 hω)).symm

/-! ## Independence: an extra independent observation, and joint stationarity -/

/-- If `m₂` is independent of `σ(f) ⊔ m₁`, then conditioning on `m₂` in addition
to `m₁` does not change the conditional expectation of `f`:
`E[f | m₁ ⊔ m₂] = E[f | m₁]`. (Williams, *Probability with Martingales*, 9.7(k).)
Not in Mathlib v4.33.1. -/
theorem condExp_sup_of_indep {μ : Measure Ω} [IsProbabilityMeasure μ]
    {m₁ m₂ : MeasurableSpace Ω} {f : Ω → ℝ}
    (hm₁ : m₁ ≤ mΩ) (hm₂ : m₂ ≤ mΩ)
    (hfm : Measurable[mΩ] f) (hf : Integrable f μ)
    (hind : Indep (MeasurableSpace.comap f inferInstance ⊔ m₁) m₂ μ) :
    μ[f | m₁ ⊔ m₂] =ᵐ[μ] μ[f | m₁] := by
  have hm : m₁ ⊔ m₂ ≤ mΩ := sup_le hm₁ hm₂
  have hfm' : MeasurableSpace.comap f inferInstance ⊔ m₁ ≤ mΩ :=
    sup_le hfm.comap_le hm₁
  suffices key : ∀ s, MeasurableSet[m₁ ⊔ m₂] s →
      ∫ x in s, (μ[f | m₁]) x ∂μ = ∫ x in s, f x ∂μ from
    (ae_eq_condExp_of_forall_setIntegral_eq (g := μ[f | m₁]) hm hf
      (fun _ _ _ => integrable_condExp.integrableOn) (fun s hs _ => key s hs)
      (stronglyMeasurable_condExp.mono le_sup_left).aestronglyMeasurable).symm
  intro s hs
  -- the rectangles `A ∩ B` form a π-system generating `m₁ ⊔ m₂`
  let C : Set (Set Ω) := {s | ∃ A B, MeasurableSet[m₁] A ∧ MeasurableSet[m₂] B ∧ s = A ∩ B}
  have hC : m₁ ⊔ m₂ = MeasurableSpace.generateFrom C := by
    apply le_antisymm
    · refine sup_le (fun A hA => ?_) (fun B hB => ?_)
      · exact MeasurableSpace.measurableSet_generateFrom
          ⟨A, univ, hA, MeasurableSet.univ, (inter_univ A).symm⟩
      · exact MeasurableSpace.measurableSet_generateFrom
          ⟨univ, B, MeasurableSet.univ, hB, (univ_inter B).symm⟩
    · refine MeasurableSpace.generateFrom_le ?_
      rintro _ ⟨A, B, hA, hB, rfl⟩
      exact MeasurableSet.inter ((le_sup_left : m₁ ≤ m₁ ⊔ m₂) A hA)
        ((le_sup_right : m₂ ≤ m₁ ⊔ m₂) B hB)
  have hpi : IsPiSystem C := by
    rintro _ ⟨A, B, hA, hB, rfl⟩ _ ⟨A', B', hA', hB', rfl⟩ _
    exact ⟨A ∩ A', B ∩ B', hA.inter hA', hB.inter hB', inter_inter_inter_comm A B A' B'⟩
  -- on a rectangle the integral of a `σ(f) ⊔ m₁`-measurable function factors
  have hrect : ∀ φ : Ω → ℝ, Measurable[MeasurableSpace.comap f inferInstance ⊔ m₁] φ →
      ∀ A B, MeasurableSet[m₁] A → MeasurableSet[m₂] B →
      ∫ ω in A ∩ B, φ ω ∂μ = (∫ ω in A, φ ω ∂μ) * ∫ ω, B.indicator (1 : Ω → ℝ) ω ∂μ := by
    intro φ hφ A B hA hB
    have hA' : MeasurableSet[MeasurableSpace.comap f inferInstance ⊔ m₁] A :=
      (le_sup_right : m₁ ≤ MeasurableSpace.comap f inferInstance ⊔ m₁) A hA
    have h1 : Measurable[MeasurableSpace.comap f inferInstance ⊔ m₁] (A.indicator φ) :=
      hφ.indicator hA'
    have h2 : Measurable[m₂] (B.indicator (1 : Ω → ℝ)) := measurable_one.indicator hB
    have hIF : IndepFun (A.indicator φ) (B.indicator (1 : Ω → ℝ)) μ := by
      rw [IndepFun_iff_Indep]
      exact indep_of_indep_of_le_left (indep_of_indep_of_le_right hind h2.comap_le) h1.comap_le
    have hprod := hIF.integral_fun_mul_eq_mul_integral
      (h1.mono hfm' le_rfl).aestronglyMeasurable (h2.mono hm₂ le_rfl).aestronglyMeasurable
    rw [← integral_indicator ((hm₁ A hA).inter (hm₂ B hB)), ← integral_indicator (hm₁ A hA),
      ← hprod]
    refine integral_congr_ae (ae_of_all _ fun ω => ?_)
    have := Set.inter_indicator_mul (s := A) (t := B) φ (1 : Ω → ℝ) ω
    simpa using this
  have hf_meas : Measurable[MeasurableSpace.comap f inferInstance ⊔ m₁] f :=
    (comap_measurable f).mono le_sup_left le_rfl
  have hg_meas : Measurable[MeasurableSpace.comap f inferInstance ⊔ m₁] (μ[f | m₁]) :=
    stronglyMeasurable_condExp.measurable.mono le_sup_right le_rfl
  -- π-λ induction over the `m₁ ⊔ m₂`-measurable sets
  refine MeasurableSpace.induction_on_inter
    (C := fun s _ => ∫ x in s, (μ[f | m₁]) x ∂μ = ∫ x in s, f x ∂μ) hC hpi ?_ ?_ ?_ ?_ s hs
  · simp
  · rintro _ ⟨A, B, hA, hB, rfl⟩
    rw [hrect _ hg_meas A B hA hB, hrect _ hf_meas A B hA hB, setIntegral_condExp hm₁ hf hA]
  · intro t ht ih
    rw [setIntegral_compl (hm t ht) integrable_condExp, setIntegral_compl (hm t ht) hf, ih,
      integral_condExp hm₁]
  · intro F hd hF ih
    rw [integral_iUnion (fun i => hm _ (hF i)) hd integrable_condExp.integrableOn,
      integral_iUnion (fun i => hm _ (hF i)) hd hf.integrableOn]
    exact tsum_congr ih

variable {A B : Type} [MeasurableSpace A] [MeasurableSpace B]

/-- If `V` is independent of the pair `(f, U)`, then
`E[f | U, V] = E[f | U]`. -/
theorem condExp_comap_prodMk_of_indepFun_left {μ : Measure Ω} [IsProbabilityMeasure μ]
    {f : Ω → ℝ} {U : Ω → A} {V : Ω → B} (hfm : Measurable f) (hf : Integrable f μ)
    (hU : Measurable U) (hV : Measurable V) (hind : IndepFun (fun ω => (f ω, U ω)) V μ) :
    μ[f | MeasurableSpace.comap (fun ω => (U ω, V ω)) inferInstance]
      =ᵐ[μ] μ[f | MeasurableSpace.comap U inferInstance] := by
  have e₁ : MeasurableSpace.comap (fun ω => (f ω, U ω)) inferInstance
      = MeasurableSpace.comap f inferInstance ⊔ MeasurableSpace.comap U inferInstance :=
    MeasurableSpace.comap_prodMk f U
  have e₂ : MeasurableSpace.comap (fun ω => (U ω, V ω)) inferInstance
      = MeasurableSpace.comap U inferInstance ⊔ MeasurableSpace.comap V inferInstance :=
    MeasurableSpace.comap_prodMk U V
  rw [IndepFun_iff_Indep, e₁] at hind
  rw [e₂]
  exact condExp_sup_of_indep hU.comap_le hV.comap_le hfm hf hind

/-- If `U` is independent of the pair `(f, V)`, then
`E[f | U, V] = E[f | V]`. -/
theorem condExp_comap_prodMk_of_indepFun_right {μ : Measure Ω} [IsProbabilityMeasure μ]
    {f : Ω → ℝ} {U : Ω → A} {V : Ω → B} (hfm : Measurable f) (hf : Integrable f μ)
    (hU : Measurable U) (hV : Measurable V) (hind : IndepFun (fun ω => (f ω, V ω)) U μ) :
    μ[f | MeasurableSpace.comap (fun ω => (U ω, V ω)) inferInstance]
      =ᵐ[μ] μ[f | MeasurableSpace.comap V inferInstance] := by
  have e₁ : MeasurableSpace.comap (fun ω => (f ω, V ω)) inferInstance
      = MeasurableSpace.comap f inferInstance ⊔ MeasurableSpace.comap V inferInstance :=
    MeasurableSpace.comap_prodMk f V
  have e₂ : MeasurableSpace.comap (fun ω => (U ω, V ω)) inferInstance
      = MeasurableSpace.comap V inferInstance ⊔ MeasurableSpace.comap U inferInstance :=
    (MeasurableSpace.comap_prodMk U V).trans (sup_comm _ _)
  rw [IndepFun_iff_Indep, e₁] at hind
  rw [e₂]
  exact condExp_sup_of_indep hV.comap_le hU.comap_le hfm hf hind

/-- An independent pair whose two marginal laws do not change has a joint law
that does not change: two independent stationary processes are jointly
stationary at each time. -/
theorem identDistrib_prodMk_of_indepFun {μ : Measure Ω} [IsFiniteMeasure μ]
    {U U' : Ω → A} {V V' : Ω → B} (hU : IdentDistrib U U' μ μ) (hV : IdentDistrib V V' μ μ)
    (hind : IndepFun U V μ) (hind' : IndepFun U' V' μ) :
    IdentDistrib (fun ω => (U ω, V ω)) (fun ω => (U' ω, V' ω)) μ μ :=
  ⟨hU.aemeasurable_fst.prodMk hV.aemeasurable_fst,
    hU.aemeasurable_snd.prodMk hV.aemeasurable_snd, by
    rw [(indepFun_iff_map_prod_eq_prod_map_map hU.aemeasurable_fst hV.aemeasurable_fst).1 hind,
      (indepFun_iff_map_prod_eq_prod_map_map hU.aemeasurable_snd hV.aemeasurable_snd).1 hind',
      hU.map_eq, hV.map_eq]⟩

end TinaV2
