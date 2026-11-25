import TinaV2.Statements
import TinaV2.Routine.Estimation

/-! # C11, attempt A1: mirrors paper proof C11/p1

Paper: `main-v2.tex`, paragraph "A two-sensor example", lines 66-86. One lemma
per step of the paper's argument, in the paper's order, then `main`.

Notation. `X s`, `Y s` are the two signals at time `s`; the target is
`Z_t = (X_t + Y_t)/2`, written out as `fun ω => (X t ω + Y t ω) / 2`; the two
old readings are the pair `fun ω => (X (t − τ) ω, Y (t − τ) ω)`;
`a = e^{−τ/T}`. `Var(Z_t)` is Mathlib's `Var[· ; μ]`.

What the paper leaves unsaid and `Routine/Estimation.lean` supplies: that the
conditional mean is the best estimate (`bestMSE_eq_of_condExp`, with the
orthogonality `integral_mul_error_of_condExp` behind it), and that an
independent extra reading does not change a conditional mean
(`condExp_comap_prodMk_of_indepFun_left/right`). Each use is marked below. -/

namespace TinaV2.C11.A1

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [MeasurableSpace Ω]

/-- Step 1 (main-v2.tex 72-73). "With only `X_t`, our best estimate is `X_t/2`.
The error is the missing term `Y_t/2`, so the mean squared error is `σ²/4`." -/
theorem s1_fresh_reading (μ : Measure Ω) [IsProbabilityMeasure μ] (X Y : ℝ → Ω → ℝ) (σ t : ℝ)
    (hXm : ∀ s, Measurable (X s)) (hYm : ∀ s, Measurable (Y s))
    (hX2 : ∀ s, MemLp (X s) 2 μ) (hY2 : ∀ s, MemLp (Y s) 2 μ)
    (hY : ∀ s, ∫ ω, Y s ω ∂μ = 0 ∧ ∫ ω, Y s ω ^ 2 ∂μ = σ ^ 2)
    (hind : IndepFun (fun ω (s : ℝ) => X s ω) (fun ω (s : ℝ) => Y s ω) μ) :
    bestMSE μ (fun ω => (X t ω + Y t ω) / 2) (X t) = σ ^ 2 / 4 ∧
      ∫ ω, ((X t ω + Y t ω) / 2 - X t ω / 2) ^ 2 ∂μ = σ ^ 2 / 4 ∧
      ∀ g : ℝ → ℝ, Measurable g → MemLp (fun ω => g (X t ω)) 2 μ →
        ∫ ω, ((X t ω + Y t ω) / 2 - g (X t ω)) ^ 2 ∂μ ≤ σ ^ 2 / 4 →
        (fun ω => g (X t ω)) =ᵐ[μ] fun ω => X t ω / 2 := by
  -- the error is the missing term `Y_t/2`, so the mean squared error is `σ²/4`
  have herr : ∀ ω, (X t ω + Y t ω) / 2 - X t ω / 2 = Y t ω / 2 := fun ω => by ring
  have hmse : ∫ ω, ((X t ω + Y t ω) / 2 - X t ω / 2) ^ 2 ∂μ = σ ^ 2 / 4 := by
    simp_rw [herr, div_pow]
    rw [integral_div, (hY t).2]
    norm_num
  -- `X_t/2` is the conditional mean of `Z_t` given `X_t`: the signals are
  -- independent and `Y_t` has mean zero, so `E[Y_t | X_t] = E[Y_t] = 0`
  have hindt : IndepFun (Y t) (X t) μ :=
    (hind.comp (measurable_pi_apply t) (measurable_pi_apply t)).symm
  have hYc : μ[Y t | MeasurableSpace.comap (X t) inferInstance] =ᵐ[μ] fun _ => 0 := by
    have h := condExp_indep_eq (hYm t).comap_le (hXm t).comap_le
      (comap_measurable (Y t)).stronglyMeasurable ((IndepFun_iff_Indep _ _ _).1 hindt)
    rwa [(hY t).1] at h
  have hXc : μ[X t | MeasurableSpace.comap (X t) inferInstance] =ᵐ[μ] X t :=
    Filter.EventuallyEq.of_eq (condExp_of_stronglyMeasurable (hXm t).comap_le
      (comap_measurable (X t)).stronglyMeasurable ((hX2 t).integrable one_le_two))
  have hcond : μ[fun ω => (X t ω + Y t ω) / 2 | MeasurableSpace.comap (X t) inferInstance]
      =ᵐ[μ] fun ω => X t ω / 2 := by
    refine (condExp_half_add ((hX2 t).integrable one_le_two) ((hY2 t).integrable one_le_two)
      hXc hYc).trans ?_
    filter_upwards with ω
    simp
  -- unsaid in the paper: the conditional mean is the unique best estimate
  refine ⟨?_, hmse, fun g hg hg2 hle => ?_⟩
  · rw [bestMSE_eq_of_condExp (h := fun x => x / 2) (hXm t) (memLp_half_add (hX2 t) (hY2 t))
      (measurable_id.div_const 2) (memLp_div_const (hX2 t) 2) hcond, hmse]
  · exact bestMSE_unique_of_condExp (h := fun x => x / 2) (hXm t) (memLp_half_add (hX2 t) (hY2 t))
      (measurable_id.div_const 2) (memLp_div_const (hX2 t) 2) hg hg2 hcond (by rwa [hmse])

/-- Step 2 (main-v2.tex 73-79). "With both old readings, we know the old average
`Z_{t−τ}` exactly. Suppose the two signal processes are independent and
stationary, and each satisfies the scalar conditional-mean prediction rule
`E[X_t | X_{t−τ}] = e^{−τ/T} X_{t−τ}` (and likewise for `Y`) ... Our best
estimate today is then `e^{−τ/T} Z_{t−τ}`. Its mean squared error is
`Var(Z_t)(1 − e^{−2τ/T})`." -/
theorem s2_old_readings (μ : Measure Ω) [IsProbabilityMeasure μ] (X Y : ℝ → Ω → ℝ)
    (σ T t τ : ℝ)
    (hXm : ∀ s, Measurable (X s)) (hYm : ∀ s, Measurable (Y s))
    (hX2 : ∀ s, MemLp (X s) 2 μ) (hY2 : ∀ s, MemLp (Y s) 2 μ)
    (hX : ∀ s, ∫ ω, X s ω ∂μ = 0 ∧ ∫ ω, X s ω ^ 2 ∂μ = σ ^ 2)
    (hY : ∀ s, ∫ ω, Y s ω ∂μ = 0 ∧ ∫ ω, Y s ω ^ 2 ∂μ = σ ^ 2)
    (hind : IndepFun (fun ω (s : ℝ) => X s ω) (fun ω (s : ℝ) => Y s ω) μ)
    (hXid : ∀ s s', IdentDistrib (X s) (X s') μ μ)
    (hYid : ∀ s s', IdentDistrib (Y s) (Y s') μ μ)
    (hXpred : condExp (MeasurableSpace.comap (X (t - τ)) inferInstance) μ (X t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * X (t - τ) ω))
    (hYpred : condExp (MeasurableSpace.comap (Y (t - τ)) inferInstance) μ (Y t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * Y (t - τ) ω)) :
    bestMSE μ (fun ω => (X t ω + Y t ω) / 2) (fun ω => (X (t - τ) ω, Y (t - τ) ω))
        = Var[fun ω => (X t ω + Y t ω) / 2; μ] * (1 - exp (-2 * τ / T)) ∧
      ∫ ω, ((X t ω + Y t ω) / 2 - exp (-τ / T) * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2 ∂μ
        = Var[fun ω => (X t ω + Y t ω) / 2; μ] * (1 - exp (-2 * τ / T)) ∧
      ∀ g : ℝ × ℝ → ℝ, Measurable g →
        MemLp (fun ω => g (X (t - τ) ω, Y (t - τ) ω)) 2 μ →
        ∫ ω, ((X t ω + Y t ω) / 2 - g (X (t - τ) ω, Y (t - τ) ω)) ^ 2 ∂μ
          ≤ Var[fun ω => (X t ω + Y t ω) / 2; μ] * (1 - exp (-2 * τ / T)) →
        (fun ω => g (X (t - τ) ω, Y (t - τ) ω))
          =ᵐ[μ] fun ω => exp (-τ / T) * ((X (t - τ) ω + Y (t - τ) ω) / 2) := by
  have ha2 : exp (-τ / T) ^ 2 = exp (-2 * τ / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  set a : ℝ := exp (-τ / T) with ha
  have hXi : ∀ s, Integrable (X s) μ := fun s => (hX2 s).integrable one_le_two
  have hYi : ∀ s, Integrable (Y s) μ := fun s => (hY2 s).integrable one_le_two
  -- "we know the old average `Z_{t−τ}` exactly": `a Z_{t−τ}` is a function of the
  -- two old readings
  have hobs : Measurable fun ω => (X (t - τ) ω, Y (t - τ) ω) := (hXm _).prodMk (hYm _)
  have hh : Measurable fun p : ℝ × ℝ => a * ((p.1 + p.2) / 2) :=
    measurable_const.mul ((measurable_fst.add measurable_snd).div_const 2)
  have hZ2 : MemLp (fun ω => (X t ω + Y t ω) / 2) 2 μ := memLp_half_add (hX2 t) (hY2 t)
  have hh2 : MemLp (fun ω => a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) 2 μ :=
    (memLp_half_add (hX2 _) (hY2 _)).const_mul a
  -- unsaid in the paper: the processes are independent, so the other sensor's
  -- old reading does not change the conditional mean,
  -- `E[X_t | X_{t−τ}, Y_{t−τ}] = E[X_t | X_{t−τ}]`, and likewise for `Y`
  have hXind : IndepFun (fun ω => (X t ω, X (t - τ) ω)) (Y (t - τ)) μ :=
    hind.comp (φ := fun f : ℝ → ℝ => (f t, f (t - τ)))
      ((measurable_pi_apply t).prodMk (measurable_pi_apply (t - τ)))
      (measurable_pi_apply (t - τ))
  have hYind : IndepFun (fun ω => (Y t ω, Y (t - τ) ω)) (X (t - τ)) μ :=
    hind.symm.comp (φ := fun f : ℝ → ℝ => (f t, f (t - τ)))
      ((measurable_pi_apply t).prodMk (measurable_pi_apply (t - τ)))
      (measurable_pi_apply (t - τ))
  -- the prediction rule for each signal
  have hXc : μ[X t | MeasurableSpace.comap (fun ω => (X (t - τ) ω, Y (t - τ) ω)) inferInstance]
      =ᵐ[μ] fun ω => a * X (t - τ) ω :=
    (condExp_comap_prodMk_of_indepFun_left (hXm t) (hXi t) (hXm _) (hYm _) hXind).trans hXpred
  have hYc : μ[Y t | MeasurableSpace.comap (fun ω => (X (t - τ) ω, Y (t - τ) ω)) inferInstance]
      =ᵐ[μ] fun ω => a * Y (t - τ) ω :=
    (condExp_comap_prodMk_of_indepFun_right (hYm t) (hYi t) (hXm _) (hYm _) hYind).trans hYpred
  -- so the conditional mean of `Z_t` given both old readings is `a Z_{t−τ}`
  have hcond : μ[fun ω => (X t ω + Y t ω) / 2 |
        MeasurableSpace.comap (fun ω => (X (t - τ) ω, Y (t - τ) ω)) inferInstance]
      =ᵐ[μ] fun ω => a * ((X (t - τ) ω + Y (t - τ) ω) / 2) := by
    refine (condExp_half_add (hXi t) (hYi t) hXc hYc).trans ?_
    filter_upwards with ω
    ring
  -- stationarity (with independence): `E[Z_{t−τ}²] = E[Z_t²]`
  have hpair : IdentDistrib (fun ω => (X (t - τ) ω, Y (t - τ) ω)) (fun ω => (X t ω, Y t ω))
      μ μ :=
    identDistrib_prodMk_of_indepFun (hXid _ _) (hYid _ _)
      (hind.comp (measurable_pi_apply (t - τ)) (measurable_pi_apply (t - τ)))
      (hind.comp (measurable_pi_apply t) (measurable_pi_apply t))
  have hstat : ∫ ω, ((X (t - τ) ω + Y (t - τ) ω) / 2) ^ 2 ∂μ
      = ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ :=
    (hpair.comp (u := fun p : ℝ × ℝ => ((p.1 + p.2) / 2) ^ 2)
      (((measurable_fst.add measurable_snd).div_const 2).pow_const 2)).integral_eq
  -- mean zero: `Var(Z_t) = E[Z_t²]`
  have hZ0 : ∫ ω, (X t ω + Y t ω) / 2 ∂μ = 0 := by
    rw [integral_div, integral_add (hXi t) (hYi t), (hX t).1, (hY t).1]
    norm_num
  have hvar : Var[fun ω => (X t ω + Y t ω) / 2; μ] = ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ :=
    variance_of_integral_eq_zero hZ2.aestronglyMeasurable.aemeasurable hZ0
  -- the error of the conditional mean is orthogonal to the estimate, so
  -- `E[Z_t²] = E[(Z_t − a Z_{t−τ})²] + a² E[Z_{t−τ}²]`
  have horth : ∫ ω, a * ((X (t - τ) ω + Y (t - τ) ω) / 2)
      * ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ∂μ = 0 :=
    integral_mul_error_of_condExp
      (target := fun ω => (X t ω + Y t ω) / 2)
      (obs := fun ω => (X (t - τ) ω, Y (t - τ) ω))
      (h := fun p : ℝ × ℝ => a * ((p.1 + p.2) / 2))
      (k := fun p : ℝ × ℝ => a * ((p.1 + p.2) / 2)) hobs hZ2 hh hh2 hh hh2 hcond
  have hE2 : MemLp (fun ω => (X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) 2 μ :=
    hZ2.sub hh2
  have hI1 : Integrable (fun ω =>
      ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2) μ := hE2.integrable_sq
  have hI2 : Integrable (fun ω => 2 * (a * ((X (t - τ) ω + Y (t - τ) ω) / 2)
      * ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)))) μ :=
    (hh2.integrable_mul hE2).const_mul 2
  have hI3 : Integrable (fun ω => a ^ 2 * ((X (t - τ) ω + Y (t - τ) ω) / 2) ^ 2) μ :=
    (memLp_half_add (hX2 _) (hY2 _)).integrable_sq.const_mul (a ^ 2)
  have hI12 : Integrable (fun ω =>
      ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2
      + 2 * (a * ((X (t - τ) ω + Y (t - τ) ω) / 2)
        * ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)))) μ := hI1.add hI2
  have hsum : ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ
      = ∫ ω, ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2 ∂μ
        + a ^ 2 * ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ := by
    have hpt : ∀ ω, ((X t ω + Y t ω) / 2) ^ 2
        = ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2
          + 2 * (a * ((X (t - τ) ω + Y (t - τ) ω) / 2)
            * ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)))
          + a ^ 2 * ((X (t - τ) ω + Y (t - τ) ω) / 2) ^ 2 := fun ω => by ring
    calc ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ
        = ∫ ω, (((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2
          + 2 * (a * ((X (t - τ) ω + Y (t - τ) ω) / 2)
            * ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)))
          + a ^ 2 * ((X (t - τ) ω + Y (t - τ) ω) / 2) ^ 2) ∂μ :=
          integral_congr_ae (Filter.Eventually.of_forall hpt)
      _ = ∫ ω, ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2 ∂μ
          + a ^ 2 * ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ := by
          rw [integral_add hI12 hI3, integral_add hI1 hI2, integral_const_mul, horth,
            integral_const_mul, hstat]
          ring
  -- "Its mean squared error is `Var(Z_t)(1 − e^{−2τ/T})`."
  have hmse : ∫ ω, ((X t ω + Y t ω) / 2 - a * ((X (t - τ) ω + Y (t - τ) ω) / 2)) ^ 2 ∂μ
      = Var[fun ω => (X t ω + Y t ω) / 2; μ] * (1 - exp (-2 * τ / T)) := by
    rw [hvar, ← ha2]
    linear_combination (-1 : ℝ) * hsum
  -- unsaid in the paper: the conditional mean is the unique best estimate
  refine ⟨?_, hmse, fun g hg hg2 hle => ?_⟩
  · rw [bestMSE_eq_of_condExp (h := fun p : ℝ × ℝ => a * ((p.1 + p.2) / 2)) hobs hZ2 hh hh2 hcond,
      hmse]
  · exact bestMSE_unique_of_condExp (h := fun p : ℝ × ℝ => a * ((p.1 + p.2) / 2)) hobs hZ2 hh hh2
      hg hg2 hcond (by rwa [hmse])

/-- Step 3 (main-v2.tex 79-86). "Since `Var(Z_t) = σ²/2`, the fresh reading wins
when `σ²/4 < (σ²/2)(1 − e^{−2τ/T}) ⟺ τ > T log 2 / 2`." -/
theorem s3_crossover (μ : Measure Ω) [IsProbabilityMeasure μ] (X Y : ℝ → Ω → ℝ)
    (σ T t τ : ℝ) (hσ : 0 < σ) (hT : 0 < T)
    (hXm : ∀ s, Measurable (X s)) (hYm : ∀ s, Measurable (Y s))
    (hX2 : ∀ s, MemLp (X s) 2 μ) (hY2 : ∀ s, MemLp (Y s) 2 μ)
    (hX : ∀ s, ∫ ω, X s ω ∂μ = 0 ∧ ∫ ω, X s ω ^ 2 ∂μ = σ ^ 2)
    (hY : ∀ s, ∫ ω, Y s ω ∂μ = 0 ∧ ∫ ω, Y s ω ^ 2 ∂μ = σ ^ 2)
    (hind : IndepFun (fun ω (s : ℝ) => X s ω) (fun ω (s : ℝ) => Y s ω) μ)
    (hXid : ∀ s s', IdentDistrib (X s) (X s') μ μ)
    (hYid : ∀ s s', IdentDistrib (Y s) (Y s') μ μ)
    (hXpred : condExp (MeasurableSpace.comap (X (t - τ)) inferInstance) μ (X t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * X (t - τ) ω))
    (hYpred : condExp (MeasurableSpace.comap (Y (t - τ)) inferInstance) μ (Y t)
      =ᵐ[μ] (fun ω => exp (-τ / T) * Y (t - τ) ω)) :
    Var[fun ω => (X t ω + Y t ω) / 2; μ] = σ ^ 2 / 2 ∧
      (bestMSE μ (fun ω => (X t ω + Y t ω) / 2) (X t)
          < bestMSE μ (fun ω => (X t ω + Y t ω) / 2) (fun ω => (X (t - τ) ω, Y (t - τ) ω))
        ↔ σ ^ 2 / 4 < σ ^ 2 / 2 * (1 - exp (-2 * τ / T))) ∧
      (σ ^ 2 / 4 < σ ^ 2 / 2 * (1 - exp (-2 * τ / T)) ↔ T * log 2 / 2 < τ) := by
  have hXi : Integrable (X t) μ := (hX2 t).integrable one_le_two
  have hYi : Integrable (Y t) μ := (hY2 t).integrable one_le_two
  -- `Var(Z_t) = σ²/2`: independent signals with mean zero and variance `σ²`
  have hindt : IndepFun (X t) (Y t) μ :=
    hind.comp (measurable_pi_apply t) (measurable_pi_apply t)
  have hXY : ∫ ω, X t ω * Y t ω ∂μ = 0 := by
    rw [hindt.integral_fun_mul_eq_mul_integral (hXm t).aestronglyMeasurable
      (hYm t).aestronglyMeasurable, (hX t).1, zero_mul]
  have hZ0 : ∫ ω, (X t ω + Y t ω) / 2 ∂μ = 0 := by
    rw [integral_div, integral_add hXi hYi, (hX t).1, (hY t).1]
    norm_num
  have hvar : Var[fun ω => (X t ω + Y t ω) / 2; μ] = σ ^ 2 / 2 := by
    rw [variance_of_integral_eq_zero
      (memLp_half_add (hX2 t) (hY2 t)).aestronglyMeasurable.aemeasurable hZ0]
    have hI1 : Integrable (fun ω => X t ω ^ 2) μ := (hX2 t).integrable_sq
    have hI2 : Integrable (fun ω => 2 * (X t ω * Y t ω)) μ :=
      ((hX2 t).integrable_mul (hY2 t)).const_mul 2
    have hI3 : Integrable (fun ω => Y t ω ^ 2) μ := (hY2 t).integrable_sq
    have hI12 : Integrable (fun ω => X t ω ^ 2 + 2 * (X t ω * Y t ω)) μ := hI1.add hI2
    calc ∫ ω, ((X t ω + Y t ω) / 2) ^ 2 ∂μ
        = ∫ ω, (X t ω ^ 2 + 2 * (X t ω * Y t ω) + Y t ω ^ 2) / 4 ∂μ :=
          integral_congr_ae (Filter.Eventually.of_forall fun ω => by ring)
      _ = σ ^ 2 / 2 := by
          rw [integral_div, integral_add hI12 hI3, integral_add hI1 hI2, integral_const_mul,
            hXY, (hX t).2, (hY t).2]
          ring
  refine ⟨hvar, ?_, ?_⟩
  -- "the fresh reading wins when": the two errors of steps 1 and 2
  · rw [(s1_fresh_reading μ X Y σ t hXm hYm hX2 hY2 hY hind).1,
      (s2_old_readings μ X Y σ T t τ hXm hYm hX2 hY2 hX hY hind hXid hYid hXpred hYpred).1,
      hvar]
  -- `σ²/4 < (σ²/2)(1 − e^{−2τ/T}) ⟺ e^{−2τ/T} < 1/2 ⟺ τ > T log 2 / 2`
  · have h1 : σ ^ 2 / 4 < σ ^ 2 / 2 * (1 - exp (-2 * τ / T))
        ↔ exp (-2 * τ / T) < exp (-log 2) := by
      rw [exp_neg, exp_log (by norm_num : (0 : ℝ) < 2), ← sub_pos,
        show σ ^ 2 / 2 * (1 - exp (-2 * τ / T)) - σ ^ 2 / 4
          = σ ^ 2 / 2 * (2⁻¹ - exp (-2 * τ / T)) by ring,
        mul_pos_iff_of_pos_left (by positivity), sub_pos]
    rw [h1, exp_lt_exp, div_lt_iff₀ hT]
    constructor <;> intro h <;> linarith

/-- The two-sensor example. -/
theorem main : C11.Statement := by
  intro Ω _ μ _ X Y σ T t τ hσ hT _ hXm hYm hX2 hY2 hX hY hind hXid hYid hXpred hYpred Z
  have h1 := s1_fresh_reading μ X Y σ t hXm hYm hX2 hY2 hY hind
  have h2 := s2_old_readings μ X Y σ T t τ hXm hYm hX2 hY2 hX hY hind hXid hYid hXpred hYpred
  obtain ⟨hvar, -, hcross⟩ :=
    s3_crossover μ X Y σ T t τ hσ hT hXm hYm hX2 hY2 hX hY hind hXid hYid hXpred hYpred
  -- substitute `Var(Z_t) = σ²/2` (step 3) in the error of step 2
  rw [hvar] at h2
  exact ⟨h1, h2, hcross⟩

end TinaV2.C11.A1
