import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.CommonInfo
import TinaV2.Routine.Estimation
import TinaV2.Routine.NoInfo
import TinaV2.Routine.Modes

/-! # C9, attempt A1: mirrors paper proof C9/p1

Paper: `main-v3.tex`, lines 483-490: three sentences (steps 1, 2 and 3 below).
Three steps are supplied, written in the ledger and not in the paper: step 0
(the modes add up to the state), step 2a (conditioning on the whole snapshot)
and step 2b (the regret of the complete old snapshot is `R_∞` minus half the
captured gain). Claim C4.c enters as the hypothesis `hC4c : C04c.Statement`.

Notation. Mode `k` of the state at epoch `s` is `P k *ᵥ θ s ω`, its
contribution to the desired action is `M.K *ᵥ (P k *ᵥ θ s ω)`, and
`a_k = e^{−τ/T_k}` is written out as `exp (-τ / Tc k)`. The complete old
snapshot generates the sigma-algebra `snapSigma θ (t - τ)`. -/

namespace TinaV2.C09.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω m : Type} [Fintype κ] [Fintype α] [Fintype m] [DecidableEq κ]
  [mΩ : MeasurableSpace Ω] {μ : Measure Ω} {θ : ℝ → Ω → κ → ℝ} {P : m → Matrix κ κ ℝ}
  {Tc : m → ℝ} {S : m → Matrix κ κ ℝ}

omit mΩ in
/-- Step 0 (supplied). Since `∑_k P_k = 1`, the state is the sum of its modes,
`θ_s = ∑_k P_k θ_s`, and applying `K` gives `x⋆ = ∑_k x_k⋆`. -/
theorem s0_decomposition (M : Model ι κ α) (hP : ∑ k, P k = 1) (s : ℝ) (ω : Ω) :
    θ s ω = ∑ k, P k *ᵥ θ s ω ∧ M.target (θ s) ω = ∑ k, M.K *ᵥ (P k *ᵥ θ s ω) := by
  have h : θ s ω = ∑ k, P k *ᵥ θ s ω := by rw [← Matrix.sum_mulVec, hP, Matrix.one_mulVec]
  refine ⟨h, ?_⟩
  simp only [Model.target]
  rw [← Matrix.mulVec_sum, ← h]

/-- Step 1 (main-v3.tex 483). "Independence and centering make the cross-mode
terms vanish, so `∑_k w_k = 1`." The cross-mode terms are
`E[(x_k⋆)ᵀ Q x_{k'}⋆]` for `k ≠ k'`, at any epoch.
Beyond the sentence: the contributions are square integrable because the modes
are Gaussian, and `E[(x⋆)ᵀ Q x⋆] > 0` because `R_∞ > 0`. -/
theorem s1_cross_terms_vanish (M : Model ι κ α) [IsProbabilityMeasure μ]
    (hP : ∑ k, P k = 1)
    (hind : iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ)
    (hk : ∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l)) :
    (∀ (s : ℝ) (k k' : m), k ≠ k' →
      ∫ ω, (M.K *ᵥ (P k *ᵥ θ s ω)) ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (P k' *ᵥ θ s ω))) ∂μ = 0) ∧
    ∀ t, 0 < M.Rinf μ (θ t) →
      ∑ k, (∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ)
        / (∫ ω, quad M.Q (M.target (θ t) ω) ∂μ) = 1 := by
  have hz2 : ∀ k s, MemLp (fun ω => P k *ᵥ θ s ω) 2 μ := fun k s =>
    memLp_pi_iff.2 fun j => ((hk k).2.1.hasGaussianLaw_eval (s, j)).memLp_two
  have hx2 : ∀ k s, MemLp (fun ω => M.K *ᵥ (P k *ᵥ θ s ω)) 2 μ := fun k s =>
    memLp_mulVec M.K (hz2 k s)
  -- independence and centering: the cross-mode terms vanish
  have hcross : ∀ (s : ℝ) (k k' : m), k ≠ k' →
      ∫ ω, (M.K *ᵥ (P k *ᵥ θ s ω)) ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (P k' *ᵥ θ s ω))) ∂μ = 0 := by
    intro s k k' hne
    have hI : IndepFun (fun ω => P k *ᵥ θ s ω) (fun ω => P k' *ᵥ θ s ω) μ :=
      (hind.indepFun hne).comp (measurable_pi_apply s) (measurable_pi_apply s)
    rw [integral_dotProduct_eq_sum (hx2 k s) (memLp_mulVec M.Q (hx2 k' s))]
    refine Finset.sum_eq_zero fun c _ => ?_
    have hI' : IndepFun (fun ω => (M.K *ᵥ (P k *ᵥ θ s ω)) c)
        (fun ω => (M.Q *ᵥ (M.K *ᵥ (P k' *ᵥ θ s ω))) c) μ :=
      hI.comp (φ := fun v : κ → ℝ => (M.K *ᵥ v) c)
        (ψ := fun v : κ → ℝ => (M.Q *ᵥ (M.K *ᵥ v)) c)
        ((measurable_pi_apply c).comp (measurable_mulVec M.K))
        ((measurable_pi_apply c).comp ((measurable_mulVec M.Q).comp (measurable_mulVec M.K)))
    rw [hI'.integral_fun_mul_eq_mul_integral
      (memLp_pi_iff.1 (hx2 k s) c).aestronglyMeasurable
      (memLp_pi_iff.1 (memLp_mulVec M.Q (hx2 k' s)) c).aestronglyMeasurable]
    -- centering: the contribution of mode `k` has mean zero
    have h0 : ∫ ω, (M.K *ᵥ (P k *ᵥ θ s ω)) c ∂μ = 0 := by
      have h := integral_const_dotProduct (μ := μ) (fun j => M.K c j) (hz2 k s)
      have hz0 : (fun j => ∫ ω, (P k *ᵥ θ s ω) j ∂μ) = 0 := funext fun j => (hk k).2.2.1 s j
      rw [hz0, dotProduct_zero] at h
      exact h
    rw [h0, zero_mul]
  refine ⟨hcross, fun t hR => ?_⟩
  -- so the no-information loss is the sum of the modes' losses
  have hD : ∫ ω, quad M.Q (M.target (θ t) ω) ∂μ
      = ∑ k, ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ := by
    have htar : ∀ ω, M.target (θ t) ω = ∑ k, M.K *ᵥ (P k *ᵥ θ t ω) := fun ω =>
      (s0_decomposition M hP t ω).2
    have h := integral_quad_sum M.Q (v := fun k ω => M.K *ᵥ (P k *ᵥ θ t ω)) (fun k => hx2 k t)
    beta_reduce at h
    simp_rw [htar]
    rw [h]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [Finset.sum_eq_single k (fun k' _ hne => hcross t k k' (Ne.symm hne))
      (fun h => absurd (Finset.mem_univ k) h)]
    rfl
  have hpos : 0 < ∫ ω, quad M.Q (M.target (θ t) ω) ∂μ := by
    unfold Model.Rinf at hR
    linarith
  rw [← Finset.sum_div, ← hD, div_self hpos.ne']

/-- Step 2a (supplied). For each mode `k`, the innovation
`P_k θ_t − a_k P_k θ_{t−τ}` has conditional mean zero given the whole snapshot
`θ_{t−τ}`. By C4.c it has conditional mean zero given the mode's own old value.
The innovation and that old value are functions of mode `k`'s path, and the
other modes' old values are functions of the other paths, which are
independent of it; so conditioning on them as well changes nothing. The
snapshot is the sum of the modes' old values, so the tower property gives the
claim. -/
theorem s2a_whole_snapshot [IsProbabilityMeasure μ] (hC4c : C04c.Statement)
    (hm : ∀ t, Measurable (θ t)) (hP : ∑ k, P k = 1)
    (hind : iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ)
    (hk : ∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l))
    {t τ : ℝ} (hτ : 0 ≤ τ) (k : m) :
    μ[fun ω => P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω | snapSigma θ (t - τ)]
      =ᵐ[μ] 0 := by
  classical
  have hz2 : ∀ k s, MemLp (fun ω => P k *ᵥ θ s ω) 2 μ := fun k s =>
    memLp_pi_iff.2 fun j => ((hk k).2.1.hasGaussianLaw_eval (s, j)).memLp_two
  have hzm : ∀ k s, Measurable (fun ω => P k *ᵥ θ s ω) := fun k s =>
    (measurable_mulVec (P k)).comp (hm s)
  -- C4.c for mode `k`: conditional mean zero given the mode's own old value
  have hpred : PredictionRule μ (exp (-τ / Tc k)) (fun ω => P k *ᵥ θ (t - τ) ω)
      (fun ω => P k *ᵥ θ t ω) :=
    (hC4c μ (fun s ω => P k *ᵥ θ s ω) (S k) (Tc k) (hk k).1 (hk k).2.1 (hzm k) (hk k).2.2.1
      (hk k).2.2.2 t τ hτ).2.2.prediction
  have hε2 : MemLp (fun ω => P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) 2 μ :=
    (hz2 k t).sub ((hz2 k (t - τ)).const_smul (exp (-τ / Tc k)))
  have hεm : Measurable (fun ω => P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) :=
    (hzm k t).sub ((hzm k (t - τ)).const_smul (exp (-τ / Tc k)))
  -- `m₁`: mode `k`'s old value; `m₂`: the other modes' old values
  let T : Finset m := Finset.univ.erase k
  let others : Ω → (T → κ → ℝ) := fun ω i => P i *ᵥ θ (t - τ) ω
  have hom : Measurable others := Measurable.of_eval fun i => hzm i (t - τ)
  have hm₁ : MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi ≤ mΩ :=
    (hzm k (t - τ)).comap_le
  have hm₂ : MeasurableSpace.comap others MeasurableSpace.pi ≤ mΩ := hom.comap_le
  -- the path of mode `k` is independent of the paths of the other modes
  have hk0 : k ∈ ({k} : Finset m) := Finset.mem_singleton_self k
  have hI : Indep
      (MeasurableSpace.comap (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω)
        MeasurableSpace.pi)
      (MeasurableSpace.comap (fun ω (i : T) (s : ℝ) => P i *ᵥ θ s ω) MeasurableSpace.pi) μ :=
    (IndepFun_iff_Indep _ _ _).1
      (hind.indepFun_finset {k} T (by simp [T])
        (fun i => Measurable.of_eval fun s => hzm i s))
  have hle₂ : MeasurableSpace.comap others MeasurableSpace.pi
      ≤ MeasurableSpace.comap (fun ω (i : T) (s : ℝ) => P i *ᵥ θ s ω) MeasurableSpace.pi := by
    have hψ : Measurable (fun (f : T → ℝ → κ → ℝ) (i : T) => f i (t - τ)) :=
      Measurable.of_eval fun i => (measurable_pi_apply (t - τ)).comp (measurable_pi_apply i)
    have hc : Measurable[MeasurableSpace.comap (fun ω (i : T) (s : ℝ) => P i *ᵥ θ s ω)
        MeasurableSpace.pi] others :=
      hψ.comp (comap_measurable (fun ω (i : T) (s : ℝ) => P i *ᵥ θ s ω))
    exact hc.comap_le
  -- the snapshot is the sum of the modes' old values
  have h𝒢 : snapSigma θ (t - τ) ≤ MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi
      ⊔ MeasurableSpace.comap others MeasurableSpace.pi := by
    have hθ : θ (t - τ) = fun ω => ∑ i, P i *ᵥ θ (t - τ) ω := by
      funext ω
      rw [← Matrix.sum_mulVec, hP, Matrix.one_mulVec]
    have key : ∀ 𝓜 : MeasurableSpace Ω,
        MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi ≤ 𝓜 →
        MeasurableSpace.comap others MeasurableSpace.pi ≤ 𝓜 →
        Measurable[𝓜] (fun ω => ∑ i, P i *ᵥ θ (t - τ) ω) := by
      intro 𝓜 h1 h2
      refine Finset.measurable_sum _ fun i _ => ?_
      by_cases hi : i = k
      · rw [hi]
        exact (comap_measurable (fun ω => P k *ᵥ θ (t - τ) ω)).mono h1 le_rfl
      · have hiT : i ∈ T := by simp [T, hi]
        have hpi : Measurable (fun f : T → κ → ℝ => f ⟨i, hiT⟩) := measurable_pi_apply _
        have hc : Measurable[MeasurableSpace.comap others MeasurableSpace.pi]
            (fun ω => P i *ᵥ θ (t - τ) ω) := hpi.comp (comap_measurable others)
        exact hc.mono h2 le_rfl
    have hmeas := key _ le_sup_left le_sup_right
    rw [← hθ] at hmeas
    exact hmeas.comap_le
  -- coordinate by coordinate
  have hcoord : ∀ j,
      μ[fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j | snapSigma θ (t - τ)]
        =ᵐ[μ] 0 := by
    intro j
    have hfm : Measurable
        (fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j) :=
      (measurable_pi_apply j).comp hεm
    have hfi : Integrable
        (fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j) μ :=
      (memLp_pi_iff.1 hε2 j).integrable one_le_two
    have hle₁ : MeasurableSpace.comap
          (fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j) inferInstance
          ⊔ MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi
        ≤ MeasurableSpace.comap (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω)
          MeasurableSpace.pi := by
      refine sup_le ?_ ?_
      · have h1 : Measurable (fun f : (({k} : Finset m)) → ℝ → κ → ℝ => f ⟨k, hk0⟩ t) :=
          (measurable_pi_apply t).comp (measurable_pi_apply (⟨k, hk0⟩ : ({k} : Finset m)))
        have h2 : Measurable (fun f : (({k} : Finset m)) → ℝ → κ → ℝ => f ⟨k, hk0⟩ (t - τ)) :=
          (measurable_pi_apply (t - τ)).comp (measurable_pi_apply (⟨k, hk0⟩ : ({k} : Finset m)))
        have hφ : Measurable (fun f : (({k} : Finset m)) → ℝ → κ → ℝ =>
            (f ⟨k, hk0⟩ t - exp (-τ / Tc k) • f ⟨k, hk0⟩ (t - τ)) j) :=
          (measurable_pi_apply j).comp (h1.sub (h2.const_smul (exp (-τ / Tc k))))
        have hc : Measurable[MeasurableSpace.comap
            (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω) MeasurableSpace.pi]
            (fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j) :=
          hφ.comp (comap_measurable (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω))
        exact hc.comap_le
      · have h2 : Measurable (fun f : (({k} : Finset m)) → ℝ → κ → ℝ => f ⟨k, hk0⟩ (t - τ)) :=
          (measurable_pi_apply (t - τ)).comp (measurable_pi_apply (⟨k, hk0⟩ : ({k} : Finset m)))
        have hc : Measurable[MeasurableSpace.comap
            (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω) MeasurableSpace.pi]
            (fun ω => P k *ᵥ θ (t - τ) ω) :=
          h2.comp (comap_measurable (fun ω (i : ({k} : Finset m)) (s : ℝ) => P i *ᵥ θ s ω))
        exact hc.comap_le
    have hsup := condExp_sup_of_indep hm₁ hm₂ hfm hfi
      (indep_of_indep_of_le_left (indep_of_indep_of_le_right hI hle₂) hle₁)
    have h1 : μ[fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j |
        MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi] =ᵐ[μ] 0 := by
      have h := hpred.condExp_mulVec_apply (hz2 k (t - τ)) (hz2 k t) (1 : Matrix κ κ ℝ) j
      simpa only [Matrix.one_mulVec] using h
    calc μ[fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j | snapSigma θ (t - τ)]
        =ᵐ[μ] μ[μ[fun ω => (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) j |
            MeasurableSpace.comap (fun ω => P k *ᵥ θ (t - τ) ω) MeasurableSpace.pi
              ⊔ MeasurableSpace.comap others MeasurableSpace.pi] | snapSigma θ (t - τ)] :=
          (condExp_condExp_of_le h𝒢 (sup_le hm₁ hm₂)).symm
      _ =ᵐ[μ] μ[(0 : Ω → ℝ) | snapSigma θ (t - τ)] := condExp_congr_ae (hsup.trans h1)
      _ = 0 := condExp_zero
  exact condExp_eq_zero_of_apply (hε2.integrable one_le_two) hcoord

/-- Step 2 (main-v3.tex 484-486). "The complete old snapshot predicts mode `k`'s
contribution as `e^{−τ/T_k} x⋆_{k,t−τ}`, so its captured quadratic gain scales
by `e^{−2τ/T_k}`." The prediction is the conditional mean given the snapshot;
its quadratic gain is `E[(a_k x⋆_{k,t−τ})ᵀ Q (a_k x⋆_{k,t−τ})]`.
Beyond the sentence: the mode is stationary (C4.c), so the gain at epoch
`t − τ` equals the gain at epoch `t`. -/
theorem s2_mode_prediction (M : Model ι κ α) [IsProbabilityMeasure μ] (hC4c : C04c.Statement)
    (hm : ∀ t, Measurable (θ t)) (hP : ∑ k, P k = 1)
    (hind : iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ)
    (hk : ∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l))
    {t τ : ℝ} (hτ : 0 ≤ τ) (k : m) :
    μ[fun ω => M.K *ᵥ (P k *ᵥ θ t ω) | snapSigma θ (t - τ)]
        =ᵐ[μ] (fun ω => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) ∧
      ∫ ω, quad M.Q (exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) ∂μ
        = exp (-2 * τ / Tc k) * ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ := by
  have hz2 : ∀ k s, MemLp (fun ω => P k *ᵥ θ s ω) 2 μ := fun k s =>
    memLp_pi_iff.2 fun j => ((hk k).2.1.hasGaussianLaw_eval (s, j)).memLp_two
  have hzm : ∀ k s, Measurable (fun ω => P k *ᵥ θ s ω) := fun k s =>
    (measurable_mulVec (P k)).comp (hm s)
  have hε2 : MemLp (fun ω => P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) 2 μ :=
    (hz2 k t).sub ((hz2 k (t - τ)).const_smul (exp (-τ / Tc k)))
  constructor
  · -- `x⋆_{k,t} = a_k x⋆_{k,t−τ} + K ε_k`, and `E[K ε_k | θ_{t−τ}] = 0` by step 2a
    have hsplit : (fun ω => M.K *ᵥ (P k *ᵥ θ t ω))
        = (fun ω => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)))
          + fun ω => M.K *ᵥ (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω) := by
      funext ω
      simp [mulVec_sub, mulVec_smul]
    have hφ : Measurable (fun v : κ → ℝ => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ v))) :=
      ((measurable_mulVec M.K).comp (measurable_mulVec (P k))).const_smul (exp (-τ / Tc k))
    have hA : StronglyMeasurable[snapSigma θ (t - τ)]
        (fun ω => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) :=
      (hφ.comp (comap_measurable (θ (t - τ)))).stronglyMeasurable
    have hAi : Integrable (fun ω => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) μ :=
      ((memLp_mulVec M.K (hz2 k (t - τ))).const_smul (exp (-τ / Tc k))).integrable one_le_two
    have hBi : Integrable
        (fun ω => M.K *ᵥ (P k *ᵥ θ t ω - exp (-τ / Tc k) • P k *ᵥ θ (t - τ) ω)) μ :=
      (memLp_mulVec M.K hε2).integrable one_le_two
    have hB := condExp_mulVec_eq_zero (hε2.integrable one_le_two)
      (s2a_whole_snapshot hC4c hm hP hind hk hτ k) M.K
    rw [hsplit]
    filter_upwards [condExp_add hAi hBi (snapSigma θ (t - τ)), hB] with ω e1 e2
    rw [e1, Pi.add_apply, condExp_of_stronglyMeasurable (hm (t - τ)).comap_le hA hAi, e2]
    simp
  · -- the mode is stationary (C4.c): the same gain at the two epochs
    have hid : IdentDistrib (fun ω => P k *ᵥ θ (t - τ) ω) (fun ω => P k *ᵥ θ t ω) μ μ :=
      (hC4c μ (fun s ω => P k *ᵥ θ s ω) (S k) (Tc k) (hk k).1 (hk k).2.1 (hzm k) (hk k).2.2.1
        (hk k).2.2.2 t τ hτ).2.2.stationary.identDistrib (t - τ) t
    have hφ : Measurable (fun v : κ → ℝ => quad M.Q (M.K *ᵥ v)) :=
      (measurable_quad M.Q).comp (measurable_mulVec M.K)
    have hstat : ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)) ∂μ
        = ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ := (hid.comp hφ).integral_eq
    have hexp : exp (-τ / Tc k) ^ 2 = exp (-2 * τ / Tc k) := by
      rw [sq, ← exp_add]
      congr 1
      ring
    simp_rw [quad_smul]
    rw [integral_const_mul, hstat, hexp]

/-- Step 2b (supplied). The regret of the complete old snapshot is `R_∞` minus
half the captured gain of the prediction `x̂ = ∑_k a_k x⋆_{k,t−τ}`:
`R_glob(τ) = R_∞ − ½ E[x̂ᵀ Q x̂]`. By step 0 and step 2, `x̂ = E[x⋆_t | θ_{t−τ}]`.
Every admissible rule `u` of the complete snapshot is a function of it, so the
cross term `E[(x̂ − u)ᵀ Q (x⋆_t − x̂)]` vanishes and
`E[(u − x⋆_t)ᵀ Q (u − x⋆_t)] = E[(x̂ − u)ᵀ Q (x̂ − u)] + E[(x⋆_t − x̂)ᵀ Q (x⋆_t − x̂)]`,
which is smallest for `u = x̂`, an admissible rule. The same expansion with
`u = 0` gives `E[(x⋆_t − x̂)ᵀ Q (x⋆_t − x̂)] = E[(x⋆_t)ᵀ Q x⋆_t] − E[x̂ᵀ Q x̂]`. -/
theorem s2b_regret_gain (M : Model ι κ α) [IsProbabilityMeasure μ] (hC4c : C04c.Statement)
    (hm : ∀ t, Measurable (θ t)) (hP : ∑ k, P k = 1)
    (hind : iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ)
    (hk : ∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l))
    {t τ : ℝ} (hτ : 0 ≤ τ) :
    M.Rglob μ (θ (t - τ)) (θ t)
      = M.Rinf μ (θ t)
        - 1 / 2 * ∫ ω, quad M.Q (∑ k, exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) ∂μ := by
  have hz2 : ∀ k s, MemLp (fun ω => P k *ᵥ θ s ω) 2 μ := fun k s =>
    memLp_pi_iff.2 fun j => ((hk k).2.1.hasGaussianLaw_eval (s, j)).memLp_two
  have hx2 : ∀ k s, MemLp (fun ω => M.K *ᵥ (P k *ᵥ θ s ω)) 2 μ := fun k s =>
    memLp_mulVec M.K (hz2 k s)
  have hQ : M.Q.IsHermitian := M.Q_posDef.isHermitian
  have h𝒢 : snapSigma θ (t - τ) ≤ mΩ := (hm (t - τ)).comap_le
  -- the prediction `x̂` and the target `x⋆_t`
  let xhat : Ω → α → ℝ := fun ω => ∑ k, exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))
  have hxhat2 : MemLp xhat 2 μ :=
    memLp_finsetSum _ fun k _ => (hx2 k (t - τ)).const_smul (exp (-τ / Tc k))
  have hxsum : M.target (θ t) = ∑ k, fun ω => M.K *ᵥ (P k *ᵥ θ t ω) := by
    funext ω
    rw [Finset.sum_apply]
    exact (s0_decomposition M hP t ω).2
  have hx2' : MemLp (M.target (θ t)) 2 μ := by
    rw [hxsum]
    exact memLp_finsetSum' _ fun k _ => hx2 k t
  -- `x̂` is the conditional mean of the target given the snapshot (steps 0 and 2)
  have hcond : μ[M.target (θ t) | snapSigma θ (t - τ)] =ᵐ[μ] xhat := by
    rw [hxsum]
    refine (condExp_finsetSum (fun k _ => (hx2 k t).integrable one_le_two) (snapSigma θ (t - τ))).trans ?_
    have hall : ∀ᵐ ω ∂μ, ∀ k ∈ (Finset.univ : Finset m),
        (μ[fun ω => M.K *ᵥ (P k *ᵥ θ t ω) | snapSigma θ (t - τ)]) ω
          = exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)) :=
      (Filter.eventually_all_finset _).2 fun k _ =>
        (s2_mode_prediction M hC4c hm hP hind hk hτ k).1
    filter_upwards [hall] with ω hω
    rw [Finset.sum_apply]
    exact Finset.sum_congr rfl fun k hk' => hω k hk'
  -- so every coordinate of `Q (x⋆_t − x̂)` has conditional mean zero
  have hE2 : MemLp (fun ω => M.Q *ᵥ (M.target (θ t) ω - xhat ω)) 2 μ :=
    memLp_mulVec M.Q (hx2'.sub hxhat2)
  have hEc : ∀ c, μ[fun ω => (M.Q *ᵥ (M.target (θ t) ω - xhat ω)) c | snapSigma θ (t - τ)]
      =ᵐ[μ] 0 := fun c =>
    (condExp_congr_ae (by filter_upwards [hcond] with ω hω; rw [hω])).trans
      (condExp_mulVec_sub_condExp_apply h𝒢 (hx2'.integrable one_le_two) M.Q c)
  -- `x̂` is a function of the snapshot
  have hφ : Measurable (fun v : κ → ℝ => ∑ k, exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ v))) :=
    Finset.measurable_sum _ fun k _ =>
      ((measurable_mulVec M.K).comp (measurable_mulVec (P k))).const_smul (exp (-τ / Tc k))
  have hxhatm : ∀ c, StronglyMeasurable[snapSigma θ (t - τ)] fun ω => xhat ω c := fun c =>
    ((measurable_pi_apply c).comp (hφ.comp (comap_measurable (θ (t - τ))))).stronglyMeasurable
  -- the expansion: for `W` a function of the snapshot,
  -- `E[(W + (x⋆ − x̂))ᵀ Q (W + (x⋆ − x̂))] = E[Wᵀ Q W] + E[(x⋆ − x̂)ᵀ Q (x⋆ − x̂)]`
  have hexpand : ∀ W : Ω → α → ℝ, MemLp W 2 μ →
      (∀ c, StronglyMeasurable[snapSigma θ (t - τ)] fun ω => W ω c) →
      ∫ ω, quad M.Q (W ω + (M.target (θ t) ω - xhat ω)) ∂μ
        = ∫ ω, quad M.Q (W ω) ∂μ + ∫ ω, quad M.Q (M.target (θ t) ω - xhat ω) ∂μ := by
    intro W hW hWm
    have hcrossW : ∫ ω, W ω ⬝ᵥ (M.Q *ᵥ (M.target (θ t) ω - xhat ω)) ∂μ = 0 :=
      integral_dotProduct_eq_zero_of_condExp h𝒢 hW hE2 hWm hEc
    have hd2 : MemLp (fun ω => M.target (θ t) ω - xhat ω) 2 μ := hx2'.sub hxhat2
    have hi1 : Integrable (fun ω => quad M.Q (W ω)) μ := integrable_quad M.Q hW
    have hi2 : Integrable
        (fun ω => 2 * (W ω ⬝ᵥ (M.Q *ᵥ (M.target (θ t) ω - xhat ω)))) μ :=
      (integrable_dotProduct_mulVec M.Q hW hd2).const_mul 2
    have hi3 : Integrable (fun ω => quad M.Q (M.target (θ t) ω - xhat ω)) μ :=
      integrable_quad M.Q hd2
    have hi12 : Integrable (fun ω => quad M.Q (W ω)
        + 2 * (W ω ⬝ᵥ (M.Q *ᵥ (M.target (θ t) ω - xhat ω)))) μ := hi1.add hi2
    simp_rw [quad_add hQ]
    rw [integral_add hi12 hi3, integral_add hi1 hi2, integral_const_mul, hcrossW]
    ring
  -- with `W = x̂`: `E[(x⋆ − x̂)ᵀ Q (x⋆ − x̂)] = E[(x⋆)ᵀ Q x⋆] − E[x̂ᵀ Q x̂]`
  have henergy : ∫ ω, quad M.Q (M.target (θ t) ω - xhat ω) ∂μ
      = ∫ ω, quad M.Q (M.target (θ t) ω) ∂μ - ∫ ω, quad M.Q (xhat ω) ∂μ := by
    have h := hexpand xhat hxhat2 hxhatm
    simp only [add_sub_cancel] at h
    linarith
  -- `x̂` is the joint action of an admissible rule of the complete snapshot
  obtain ⟨g₀, hg₀, hu₀⟩ : ∃ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ,
      Admissible μ (M.obs ⊤ (θ (t - τ))) g ∧
      jointAction g (M.obs ⊤ (θ (t - τ))) = xhat := by
    let D : Matrix α κ ℝ := ∑ k, exp (-τ / Tc k) • (M.K * P k)
    let g : Rule M.actor fun i => M.Scope ⊤ i → ℝ :=
      fun c o => ∑ j, D c j * o ⟨j, (le_top : M.G.edist (M.actor c) (M.owner j) ≤ ⊤)⟩
    have hu : jointAction g (M.obs ⊤ (θ (t - τ))) = xhat := by
      funext ω
      have h1 : jointAction g (M.obs ⊤ (θ (t - τ))) ω = D *ᵥ θ (t - τ) ω := by
        funext c
        simp [g, jointAction, Model.obs, Model.view, mulVec, dotProduct]
      rw [h1]
      simp only [D, xhat, Matrix.sum_mulVec, Matrix.smul_mulVec, Matrix.mulVec_mulVec]
    refine ⟨g, ⟨fun c => ?_, ?_⟩, hu⟩
    · exact Finset.measurable_sum _ fun j _ => (measurable_pi_apply _).const_mul _
    · rw [hu]
      exact hxhat2
  -- the regret is the cost of that rule
  have hcost : ∀ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ,
      Admissible μ (M.obs ⊤ (θ (t - τ))) g →
      excessCost μ M.Q (M.target (θ t)) (jointAction g (M.obs ⊤ (θ (t - τ))))
        = 1 / 2 * ∫ ω, quad M.Q (xhat ω - jointAction g (M.obs ⊤ (θ (t - τ))) ω) ∂μ
          + 1 / 2 * ∫ ω, quad M.Q (M.target (θ t) ω - xhat ω) ∂μ := by
    intro g hg
    have hWm : ∀ c, StronglyMeasurable[snapSigma θ (t - τ)]
        fun ω => (xhat ω - jointAction g (M.obs ⊤ (θ (t - τ))) ω) c := by
      intro c
      have hψ : Measurable fun s : κ → ℝ =>
          ((∑ k, exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ s)))
            - fun c => g c (M.view ⊤ (M.actor c) s)) c :=
        (measurable_pi_apply c).comp (hφ.sub (M.measurable_jointAction_view ⊤ hg.1))
      exact (hψ.comp (comap_measurable (θ (t - τ)))).stronglyMeasurable
    have h := hexpand (fun ω => xhat ω - jointAction g (M.obs ⊤ (θ (t - τ))) ω)
      (hxhat2.sub hg.2) hWm
    have hpt : ∀ ω, quad M.Q (jointAction g (M.obs ⊤ (θ (t - τ))) ω - M.target (θ t) ω)
        = quad M.Q (xhat ω - jointAction g (M.obs ⊤ (θ (t - τ))) ω
          + (M.target (θ t) ω - xhat ω)) := by
      intro ω
      rw [quad_sub_comm]
      congr 1
      abel
    unfold excessCost
    simp_rw [hpt]
    rw [h]
    ring
  have hnn : ∀ W : Ω → α → ℝ, 0 ≤ ∫ ω, quad M.Q (W ω) ∂μ := fun W =>
    integral_nonneg fun ω => quad_nonneg M.Q_posDef _
  have hreg : M.Rglob μ (θ (t - τ)) (θ t)
      = 1 / 2 * ∫ ω, quad M.Q (M.target (θ t) ω - xhat ω) ∂μ := by
    unfold Model.Rglob Model.R
    refine le_antisymm ?_ ?_
    · refine (regret_le μ M.Q_posDef (M.target (θ t)) (M.obs ⊤ (θ (t - τ))) hg₀).trans ?_
      rw [hcost g₀ hg₀, hu₀]
      simp [quad]
    · refine le_ciInf fun g => ?_
      rw [hcost g.1 g.2]
      have := hnn fun ω => xhat ω - jointAction g.1 (M.obs ⊤ (θ (t - τ))) ω
      linarith
  rw [hreg, henergy]
  unfold Model.Rinf
  ring

/-- Step 3 (main-v3.tex 486-490). "Summing over modes gives
`1 − R_glob(τ)/R_∞ = ∑_k w_k e^{−2τ/T_k}`."
Beyond the sentence: the captured gain of the whole prediction is the sum of
the modes' captured gains because the cross-mode terms vanish at epoch `t − τ`
(step 1), and `R_∞ − R_glob(τ)` is half that gain (step 2b). -/
theorem s3_sum_over_modes (M : Model ι κ α) [IsProbabilityMeasure μ] (hC4c : C04c.Statement)
    (hm : ∀ t, Measurable (θ t)) (hP : ∑ k, P k = 1)
    (hind : iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ)
    (hk : ∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l))
    {t τ : ℝ} (hτ : 0 ≤ τ) (hR : 0 < M.Rinf μ (θ t)) :
    1 - M.Rglob μ (θ (t - τ)) (θ t) / M.Rinf μ (θ t)
      = ∑ k, (∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ)
          / (∫ ω, quad M.Q (M.target (θ t) ω) ∂μ) * exp (-2 * τ / Tc k) := by
  have hz2 : ∀ k s, MemLp (fun ω => P k *ᵥ θ s ω) 2 μ := fun k s =>
    memLp_pi_iff.2 fun j => ((hk k).2.1.hasGaussianLaw_eval (s, j)).memLp_two
  have hx2 : ∀ k s, MemLp (fun ω => M.K *ᵥ (P k *ᵥ θ s ω)) 2 μ := fun k s =>
    memLp_mulVec M.K (hz2 k s)
  -- summing the captured gains over modes: the cross-mode terms vanish (step 1)
  have hgain : ∫ ω, quad M.Q (∑ k, exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω))) ∂μ
      = ∑ k, exp (-2 * τ / Tc k) * ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ := by
    have h := integral_quad_sum M.Q
      (v := fun k ω => exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)))
      (fun k => (hx2 k (t - τ)).const_smul (exp (-τ / Tc k)))
    beta_reduce at h
    rw [h]
    refine Finset.sum_congr rfl fun k _ => ?_
    have hoff : ∀ k' ∈ (Finset.univ : Finset m), k' ≠ k →
        ∫ ω, (exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)))
          ⬝ᵥ (M.Q *ᵥ (exp (-τ / Tc k') • (M.K *ᵥ (P k' *ᵥ θ (t - τ) ω)))) ∂μ = 0 := by
      intro k' _ hne
      have hpt : ∀ ω, (exp (-τ / Tc k) • (M.K *ᵥ (P k *ᵥ θ (t - τ) ω)))
            ⬝ᵥ (M.Q *ᵥ (exp (-τ / Tc k') • (M.K *ᵥ (P k' *ᵥ θ (t - τ) ω))))
          = exp (-τ / Tc k) * exp (-τ / Tc k')
            * ((M.K *ᵥ (P k *ᵥ θ (t - τ) ω)) ⬝ᵥ (M.Q *ᵥ (M.K *ᵥ (P k' *ᵥ θ (t - τ) ω)))) := by
        intro ω
        simp only [mulVec_smul, smul_dotProduct, dotProduct_smul, smul_eq_mul]
        ring
      simp_rw [hpt]
      rw [integral_const_mul, (s1_cross_terms_vanish M hP hind hk).1 (t - τ) k k' (Ne.symm hne),
        mul_zero]
    rw [Finset.sum_eq_single k hoff (fun h => absurd (Finset.mem_univ k) h)]
    exact (s2_mode_prediction M hC4c hm hP hind hk hτ k).2
  have hD : M.Rinf μ (θ t) = 1 / 2 * ∫ ω, quad M.Q (M.target (θ t) ω) ∂μ := rfl
  have hpos : 0 < ∫ ω, quad M.Q (M.target (θ t) ω) ∂μ := by
    rw [hD] at hR
    linarith
  rw [s2b_regret_gain M hC4c hm hP hind hk hτ, hgain, hD]
  simp_rw [div_mul_eq_mul_div]
  rw [← Finset.sum_div]
  have hsum : ∑ k, (∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ) * exp (-2 * τ / Tc k)
      = ∑ k, exp (-2 * τ / Tc k) * ∫ ω, quad M.Q (M.K *ᵥ (P k *ᵥ θ t ω)) ∂μ :=
    Finset.sum_congr rfl fun k _ => mul_comm _ _
  rw [hsum]
  field_simp
  ring

/-- C9: the unequal-rate formula. The decomposition is step 0, the weights sum
to one by step 1, and the formula is step 3. -/
theorem main (hC4c : C04c.Statement) : C09.Statement := by
  intro ι κ α Ω m _ _ _ _ _ _ M μ _ θ P Tc S hm hP hind hk t τ hτ hR
  exact ⟨fun ω => (s0_decomposition M hP t ω).2, (s1_cross_terms_vanish M hP hind hk).2 t hR,
    s3_sum_over_modes M hC4c hm hP hind hk hτ hR⟩

end TinaV2.C09.A1
