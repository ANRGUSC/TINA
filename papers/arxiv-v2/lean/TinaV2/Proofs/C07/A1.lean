import TinaV2.Statements
import TinaV2.Routine.Regret

/-! # C7, attempt A1: mirrors paper proof C7/p1

Paper: `main-v2.tex`, proof of Theorem (spatiotemporal_composition), lines
404-442. One lemma per step of the paper's proof, in the paper's order, then
`main`.

Notation. `old = θ_{t−τ}`, `now = θ_t`, `a = e^{−τ/T}`. The paper's
`x⋆_{t−τ}` is `M.target old`, `x⋆_t` is `M.target now`, the disturbance
`K ε_{t,τ}` is `M.K *ᵥ (now ω - a • old ω)`, and a joint admissible rule `u`
is `jointAction g (M.obs r old)` for `g` admissible on the radius-`r` views of
`old`. The steps are stated for any real `a` and any pair of snapshots that
satisfy what the step uses; `main` supplies `a = e^{−τ/T}` and the two epochs. -/

namespace TinaV2.C07.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype κ] [Fintype α]

/-- Step 1 (main-v2.tex 404-408). "Applying `K` to the transition gives
`x⋆_t = a x⋆_{t−τ} + K ε_{t,τ}`." -/
theorem s1_apply_K (M : Model ι κ α) (a : ℝ) (old now : Ω → κ → ℝ) (ω : Ω) :
    M.target now ω = a • M.target old ω + M.K *ᵥ (now ω - a • old ω) := by
  simp [Model.target, mulVec_sub, mulVec_smul]

variable [MeasurableSpace Ω]

/-- Step 2 (main-v2.tex 409-416). "Every joint admissible rule `u` is a function
of the complete old state ... the cross term vanishes":
`E[(a x⋆_{t−τ} − u)ᵀ Q K ε] = E[(a x⋆_{t−τ} − u)ᵀ Q K E[ε | θ_{t−τ}]] = 0`. -/
theorem s2_cross_term_vanishes (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (a : ℝ) (r : ℕ∞) {old now : Ω → κ → ℝ} (hold_meas : Measurable old)
    (hold : MemLp old 2 μ) (hnow : MemLp now 2 μ) (hpred : PredictionRule μ a old now)
    {g : Rule M.actor fun i => M.Scope r i → ℝ} (hg : Admissible μ (M.obs r old) g) :
    ∫ ω, (a • M.target old ω - jointAction g (M.obs r old) ω)
        ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (now ω - a • old ω))) ∂μ = 0 := by
  -- `W = a x⋆_{t−τ} − u` and `E = Q K ε`
  let W : Ω → α → ℝ := fun ω => a • M.target old ω - jointAction g (M.obs r old) ω
  let E : Ω → α → ℝ := fun ω => M.Q *ᵥ (M.K *ᵥ (now ω - a • old ω))
  have hm : MeasurableSpace.comap old MeasurableSpace.pi ≤ ‹MeasurableSpace Ω› :=
    hold_meas.comap_le
  -- `u`, and with it `W`, is a function of the complete old state
  have hW_meas : ∀ c,
      StronglyMeasurable[MeasurableSpace.comap old MeasurableSpace.pi] fun ω => W ω c := by
    intro c
    have hφ : Measurable fun s : κ → ℝ =>
        (a • (M.K *ᵥ s) - fun c => g c (M.view r (M.actor c) s)) c :=
      (measurable_pi_apply c).comp
        (((measurable_mulVec M.K).const_smul a).sub (M.measurable_jointAction_view r hg.1))
    exact (hφ.comp (comap_measurable old)).stronglyMeasurable
  -- `E[Q K ε | θ_{t−τ}] = Q K E[ε | θ_{t−τ}] = 0`, coordinate by coordinate
  have hE_cond : ∀ c,
      μ[fun ω => E ω c | MeasurableSpace.comap old MeasurableSpace.pi] =ᵐ[μ] 0 := by
    intro c
    simpa [E, mulVec_mulVec] using hpred.condExp_mulVec_apply hold hnow (M.Q * M.K) c
  have hW : MemLp W 2 μ := ((M.memLp_target hold).const_smul a).sub hg.2
  have hE : MemLp E 2 μ := memLp_mulVec M.Q (memLp_mulVec M.K (hnow.sub (hold.const_smul a)))
  have hWE : ∀ c, Integrable (fun ω => W ω c * E ω c) μ := fun c =>
    (memLp_pi_iff.1 hW c).integrable_mul (memLp_pi_iff.1 hE c)
  have hterm : ∀ c, ∫ ω, W ω c * E ω c ∂μ = 0 := by
    intro c
    have hEint : Integrable (fun ω => E ω c) μ := (memLp_pi_iff.1 hE c).integrable one_le_two
    calc ∫ ω, W ω c * E ω c ∂μ
        = ∫ ω, (μ[fun ω => W ω c * E ω c | MeasurableSpace.comap old MeasurableSpace.pi]) ω ∂μ :=
          (integral_condExp hm).symm
      _ = ∫ ω, W ω c * (μ[fun ω => E ω c | MeasurableSpace.comap old MeasurableSpace.pi]) ω ∂μ :=
          integral_congr_ae (condExp_mul_of_stronglyMeasurable_left (hW_meas c) (hWE c) hEint)
      _ = ∫ _, (0 : ℝ) ∂μ := integral_congr_ae (by
          filter_upwards [hE_cond c] with ω hω
          simp [hω])
      _ = 0 := by simp
  change ∫ ω, ∑ c, W ω c * E ω c ∂μ = 0
  rw [integral_finsetSum _ fun c _ => hWE c]
  exact Finset.sum_eq_zero fun c _ => hterm c

/-- Step 3 (main-v2.tex 417-423). "Thus the error is the sum of a
predictable-part error and a disturbance error" (Eq. (innovation_split)). -/
theorem s3_error_split (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (a : ℝ) (r : ℕ∞) {old now : Ω → κ → ℝ} (hold_meas : Measurable old)
    (hold : MemLp old 2 μ) (hnow : MemLp now 2 μ) (hpred : PredictionRule μ a old now)
    {g : Rule M.actor fun i => M.Scope r i → ℝ} (hg : Admissible μ (M.obs r old) g) :
    ∫ ω, quad M.Q (M.target now ω - jointAction g (M.obs r old) ω) ∂μ
      = ∫ ω, quad M.Q (a • M.target old ω - jointAction g (M.obs r old) ω) ∂μ
        + ∫ ω, quad M.Q (M.K *ᵥ (now ω - a • old ω)) ∂μ := by
  have hW : MemLp (fun ω => a • M.target old ω - jointAction g (M.obs r old) ω) 2 μ :=
    ((M.memLp_target hold).const_smul a).sub hg.2
  have hKε : MemLp (fun ω => M.K *ᵥ (now ω - a • old ω)) 2 μ :=
    memLp_mulVec M.K (hnow.sub (hold.const_smul a))
  -- expand the squared tracking error pointwise, using step 1
  have hpt : ∀ ω, quad M.Q (M.target now ω - jointAction g (M.obs r old) ω)
      = quad M.Q (a • M.target old ω - jointAction g (M.obs r old) ω)
        + 2 * ((a • M.target old ω - jointAction g (M.obs r old) ω)
            ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (now ω - a • old ω))))
        + quad M.Q (M.K *ᵥ (now ω - a • old ω)) := by
    intro ω
    rw [s1_apply_K M a old now ω, ← quad_add M.Q_posDef.isHermitian]
    congr 1
    abel
  have hI1 : Integrable
      (fun ω => quad M.Q (a • M.target old ω - jointAction g (M.obs r old) ω)) μ :=
    integrable_quad M.Q hW
  have hI2 : Integrable (fun ω => 2 * ((a • M.target old ω - jointAction g (M.obs r old) ω)
      ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (now ω - a • old ω))))) μ :=
    (integrable_dotProduct_mulVec M.Q hW hKε).const_mul 2
  have hI3 : Integrable (fun ω => quad M.Q (M.K *ᵥ (now ω - a • old ω))) μ :=
    integrable_quad M.Q hKε
  have hI12 : Integrable (fun ω =>
      quad M.Q (a • M.target old ω - jointAction g (M.obs r old) ω)
        + 2 * ((a • M.target old ω - jointAction g (M.obs r old) ω)
            ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (now ω - a • old ω))))) μ := hI1.add hI2
  simp_rw [hpt]
  rw [integral_add hI12 hI3, integral_add hI1 hI2, integral_const_mul,
    s2_cross_term_vanishes M μ a r hold_meas hold hnow hpred hg]
  ring

/-- Step 4 (main-v2.tex 424-429). "Apply the same expansion with `u = 0`.
Stationarity gives `E[(Kε)ᵀ Q (Kε)] = (1 − a²) E[x⋆_tᵀ Q x⋆_t] = 2(1 − a²) R_∞`"
(Eq. (innovation_energy)). -/
theorem s4_disturbance_energy (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (a : ℝ) {old now : Ω → κ → ℝ} (hold_meas : Measurable old)
    (hold : MemLp old 2 μ) (hnow : MemLp now 2 μ) (hpred : PredictionRule μ a old now)
    (hid : IdentDistrib old now μ μ) :
    ∫ ω, quad M.Q (M.K *ᵥ (now ω - a • old ω)) ∂μ
        = (1 - a ^ 2) * ∫ ω, quad M.Q (M.target now ω) ∂μ ∧
      ∫ ω, quad M.Q (M.K *ᵥ (now ω - a • old ω)) ∂μ = 2 * (1 - a ^ 2) * M.Rinf μ now := by
  -- the same expansion with `u = 0`
  have h0 := s3_error_split M μ a 0 hold_meas hold hnow hpred (admissible_zero μ (M.obs 0 old))
  simp only [jointAction_zero, Pi.zero_apply, sub_zero, quad_smul] at h0
  rw [integral_const_mul] at h0
  -- stationarity: the same one-time distribution at the two epochs
  have hstat : ∫ ω, quad M.Q (M.target old ω) ∂μ = ∫ ω, quad M.Q (M.target now ω) ∂μ :=
    (hid.comp ((measurable_quad M.Q).comp (measurable_mulVec M.K))).integral_eq
  rw [hstat] at h0
  have h1 : ∫ ω, quad M.Q (M.K *ᵥ (now ω - a • old ω)) ∂μ
      = (1 - a ^ 2) * ∫ ω, quad M.Q (M.target now ω) ∂μ := by linarith
  refine ⟨h1, ?_⟩
  rw [h1, Model.Rinf]
  ring

/-- Step 5 (main-v2.tex 430-439). "For finite delay `a > 0`, write `u = a ũ`.
This rescaling is a bijection of the admissible rule class ... Consequently
`inf_u E[(a x⋆_{t−τ} − u)ᵀ Q (a x⋆_{t−τ} − u)]
  = a² inf_ũ E[(x⋆_{t−τ} − ũ)ᵀ Q (x⋆_{t−τ} − ũ)]`"
(first equality of Eq. (policy_rescaling)). -/
theorem s5_rescaling (M : Model ι κ α) (μ : Measure Ω) (a : ℝ) (ha : 0 < a) (r : ℕ∞)
    (old : Ω → κ → ℝ) :
    ⨅ g : {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g},
        ∫ ω, quad M.Q (a • M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ
      = a ^ 2 *
        ⨅ g : {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g},
          ∫ ω, quad M.Q (M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ := by
  -- the bijection `ũ ↦ u = a ũ` of the admissible rule class
  let e : {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g}
      ≃ {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g} :=
    { toFun := fun g => ⟨fun c o => a * g.1 c o, g.2.const_mul a⟩
      invFun := fun g => ⟨fun c o => a⁻¹ * g.1 c o, g.2.const_mul a⁻¹⟩
      left_inv := fun g => Subtype.ext (by
        funext c o
        simp [← mul_assoc, inv_mul_cancel₀ ha.ne'])
      right_inv := fun g => Subtype.ext (by
        funext c o
        simp [← mul_assoc, mul_inv_cancel₀ ha.ne']) }
  rw [Real.mul_iInf_of_nonneg (sq_nonneg a)]
  refine (Equiv.iInf_congr e fun g => ?_).symm
  change ∫ ω, quad M.Q (a • M.target old ω
      - jointAction (fun c o => a * g.1 c o) (M.obs r old) ω) ∂μ = _
  rw [← integral_const_mul]
  refine integral_congr_ae (ae_of_all _ fun ω => ?_)
  simp only [jointAction_const_mul, ← smul_sub, quad_smul]

/-- Step 6 (main-v2.tex 440-441). The second equality of Eq. (policy_rescaling):
`inf_ũ E[(x⋆_{t−τ} − ũ)ᵀ Q (x⋆_{t−τ} − ũ)] = 2 R(𝒜_{r,0})`. "The last
equality uses stationarity and the same observation pattern at each epoch." -/
theorem s6_fresh_at_old_epoch (M : Model ι κ α) (μ : Measure Ω) (r : ℕ∞)
    {old now : Ω → κ → ℝ} (hid : IdentDistrib old now μ μ) :
    ⨅ g : {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g},
        ∫ ω, quad M.Q (M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ
      = 2 * M.R μ r now now := by
  unfold Model.R regret excessCost
  rw [Real.mul_iInf_of_nonneg (by norm_num)]
  -- the same observation pattern at each epoch: the same rules are admissible
  refine Equiv.iInf_congr (Equiv.subtypeEquivRight (M.admissible_congr r hid)) fun g => ?_
  rw [Equiv.subtypeEquivRight_apply_coe]
  -- stationarity: the expected error depends only on the law of the snapshot
  have hφ : Measurable fun s : κ → ℝ =>
      quad M.Q (M.K *ᵥ s - fun c => g.1 c (M.view r (M.actor c) s)) :=
    (measurable_quad M.Q).comp
      ((measurable_mulVec M.K).sub (M.measurable_jointAction_view r g.2.1))
  have hstat : ∫ ω, quad M.Q (M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ
      = ∫ ω, quad M.Q (M.target now ω - jointAction g.1 (M.obs r now) ω) ∂μ :=
    (hid.comp hφ).integral_eq
  rw [hstat]
  simp_rw [quad_sub_comm M.Q (jointAction g.1 (M.obs r now) _) (M.target now _)]
  ring

/-- Step 7 (main-v2.tex 441-442). "Combining the two errors and dividing by two
proves the law": `R(𝒜_{r,τ}) = (1 − a²) R_∞ + a² R(𝒜_{r,0})`. -/
theorem s7_combine (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (a : ℝ) (ha : 0 < a) (r : ℕ∞) {old now : Ω → κ → ℝ} (hold_meas : Measurable old)
    (hold : MemLp old 2 μ) (hnow : MemLp now 2 μ) (hpred : PredictionRule μ a old now)
    (hid : IdentDistrib old now μ μ) :
    M.R μ r old now = (1 - a ^ 2) * M.Rinf μ now + a ^ 2 * M.R μ r now now := by
  -- the two errors, for each admissible rule (steps 3 and 4), divided by two
  have hsplit : ∀ g : {g : Rule M.actor fun i => M.Scope r i → ℝ //
        Admissible μ (M.obs r old) g},
      excessCost μ M.Q (M.target now) (jointAction g.1 (M.obs r old))
        = 1 / 2 * ∫ ω, quad M.Q (a • M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ
          + (1 - a ^ 2) * M.Rinf μ now := by
    intro g
    have h3 := s3_error_split M μ a r hold_meas hold hnow hpred g.2
    have h4 := (s4_disturbance_energy M μ a hold_meas hold hnow hpred hid).2
    unfold excessCost
    simp_rw [quad_sub_comm M.Q (jointAction g.1 (M.obs r old) _) (M.target now _)]
    linarith
  have hbdd : BddBelow (range fun g : {g : Rule M.actor fun i => M.Scope r i → ℝ //
      Admissible μ (M.obs r old) g} =>
      1 / 2 * ∫ ω, quad M.Q (a • M.target old ω - jointAction g.1 (M.obs r old) ω) ∂μ) :=
    bddBelow_range_of_nonneg fun g =>
      mul_nonneg (by norm_num) (integral_nonneg fun _ => quad_nonneg M.Q_posDef _)
  rw [show M.R μ r old now
      = ⨅ g : {g : Rule M.actor fun i => M.Scope r i → ℝ // Admissible μ (M.obs r old) g},
          excessCost μ M.Q (M.target now) (jointAction g.1 (M.obs r old)) from rfl]
  simp_rw [hsplit]
  rw [ciInf_add_const hbdd, ← Real.mul_iInf_of_nonneg (by norm_num),
    s5_rescaling M μ a ha r old, s6_fresh_at_old_epoch M μ r hid]
  ring

/-- Theorem (spatiotemporal_composition), Eq. (regret_composition_unnormalized). -/
theorem main : C07.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ r hA
  exact s7_combine M μ (exp (-τ / T)) (exp_pos _) r (hA.stationary.measurable _)
    (hA.stationary.memLp _) (hA.stationary.memLp _) hA.prediction
    (hA.stationary.identDistrib _ _)

end TinaV2.C07.A1
