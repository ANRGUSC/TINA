import TinaV2.Statements
import TinaV2.Routine.Canonical
import TinaV2.Routine.CanonicalSpace

/-! # C18, attempt A1: mirrors the appendix proof C18/p1

Paper: `technical-appendices-v2.tex`, Section "Canonical spatial omission
calculation", lines 405-482. One lemma per step of the appendix proof, in its
order, then `main`. One step is supplied: `s3b_residual_fields`, between the
paper's Step 2 and Step 3, proves the spatial Markov property that the paper
uses by citation.

Notation. The paper takes `z = 0` and suppresses the time; here the location
`z` and the time `t` stay general, and `β_c = 1/ℓ_c`, `β_s = 1/ℓ_s`. The
target `x⋆` is `lineTarget θ ℓc z t`, and `lineObsSigma θ r z t` below is the
sigma-algebra of the observation `𝒪_r`. The paper's `M_r`, `T_r^+`, `T_r^-`
are `lineMid`, `lineTailR`, `lineTailL`. A half line is given by its boundary
point and its direction: the paper's `Y_r = ∫₀^∞ e^{−β_c s} θ(r+s) ds` is
`lineY θ ℓc (z + r) 1 t` and its left analogue is `lineY θ ℓc (z - r) (-1) t`;
the residual fields `ε^±(s)` of the supplied step are
`lineRes θ ℓs (z ± r) (±1) t s` and their discounted integrals `E^±` are
`lineE θ ℓc ℓs (z ± r) (±1) t`. The paper's constant `C` is `lineTailConst`.
All of these are defined in `Routine/CanonicalSpace.lean`. -/

namespace TinaV2.C18.A1

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
  {θ : ℝ → ℝ → Ω → ℝ} {σ ℓs T : ℝ}

/-- Step 0 (appendix 413-419). "With `Q = qI` the optimal policy given `𝒪_r` is
`E[x⋆(0) | 𝒪_r]`. Its expected loss is `(q/2) E[Var(x⋆(0) | 𝒪_r)]` ... Since
`R_∞ = (q/2) Var(x⋆(0))`, `η_S(r) = Var(x⋆(0) | 𝒪_r) / Var(x⋆(0))`."
The expectation of the conditional variance is kept here; that the conditional
variance is a deterministic number comes out of the supplied step. -/
theorem s1_variance_ratio (h : CanonicalField μ θ σ ℓs T) {ℓc q : ℝ} (hℓc : 0 < ℓc)
    (hq : 0 < q) (r z t : ℝ) :
    lineEtaS μ q θ ℓc r z t
      = (∫ ω, Var[lineTarget θ ℓc z t; μ | lineObsSigma θ r z t] ω ∂μ)
          / Var[lineTarget θ ℓc z t; μ] := by
  unfold lineEtaS lineRinf
  rw [h.lineR_eq hℓc hq r 0 z t, sub_zero]
  exact mul_div_mul_left _ _ (by positivity)

/-- Step 1 (appendix 421-427). "Write `x⋆(0) = M_r + T_r^+ + T_r^-` ... The
middle `M_r` is computed from observed values, so it contributes no conditional
variance." The split holds for almost every outcome (those whose weighted path
is integrable). -/
theorem s2_split (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) {r : ℝ}
    (hr : 0 ≤ r) :
    (lineTarget θ ℓc z t =ᵐ[μ] fun ω =>
        lineMid θ ℓc r z t ω + lineTailR θ ℓc r z t ω + lineTailL θ ℓc r z t ω) ∧
      StronglyMeasurable[lineObsSigma θ r z t] (lineMid θ ℓc r z t) := by
  refine ⟨?_, h.stronglyMeasurable_lineMid ℓc z t hr⟩
  filter_upwards [(h.slice z t).ae_integrable (ν := volume) (measurable_lineKernel ℓc)
    (integrable_lineKernel hℓc)] with ω hω
  exact integral_eq_Icc_add_Ioi_add_Iio hω hr

omit mΩ in
/-- Step 2 (appendix 429-433). "Substituting `u = r + s`,
`T_r^+ = (β_c/2) e^{−β_c r} Y_r`, `Y_r = ∫₀^∞ e^{−β_c s} θ(r+s) ds`." -/
theorem s3_right_tail (θ : ℝ → ℝ → Ω → ℝ) {ℓc r : ℝ} (hr : 0 ≤ r) (z t : ℝ) (ω : Ω) :
    lineTailR θ ℓc r z t ω = 1 / (2 * ℓc) * exp (-r / ℓc) * lineY θ ℓc (z + r) 1 t ω := by
  show ∫ u in Ioi r, lineKernel ℓc u * θ (z + u) t ω
    = 1 / (2 * ℓc) * exp (-r / ℓc) * ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * θ (z + r + 1 * s) t ω
  rw [integral_Ioi_eq_integral_Ioi_zero (fun u => lineKernel ℓc u * θ (z + u) t ω) r,
    ← integral_const_mul]
  refine setIntegral_congr_fun measurableSet_Ioi fun s hs => ?_
  have hs' : (0 : ℝ) ≤ s := le_of_lt hs
  simp only [lineKernel_add hr hs', one_mul, add_assoc]
  ring

/-- Supplied step (residual fields). "For `s ≥ 0` write
`θ(r+s) = e^{−β_s s} θ(r) + ε⁺(s)` and `θ(−r−s) = e^{−β_s s} θ(−r) + ε⁻(s)`. By
the exponential covariance each `ε⁺(s)` is uncorrelated with every `θ(u)`,
`u ≤ r`, and each `ε⁻(s)` with every `θ(u)`, `u ≥ −r`. The families
`(θ(u))_{|u|≤r}`, `(ε⁺(s))_{s≥0}` and `(ε⁻(s))_{s≥0}` are jointly Gaussian and
pairwise uncorrelated, hence independent. Integrating against `e^{−β_c s}`
gives `Y_r = θ(r)/(β_c+β_s) + E⁺` and, for the left tail,
`Y⁻_r = θ(−r)/(β_c+β_s) + E⁻`, where `E^± = ∫₀^∞ e^{−β_c s} ε^±(s) ds` have mean
zero, `E⁺` and `E⁻` are independent, and the pair is independent of the
observation `𝒪_r`."
Lean needs beyond it: the residual families are indexed by all of `ℝ` with the
index clamped at `0`, so that the integrals `E^±` are measurable functions of
them. -/
theorem s3b_residual_fields (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ)
    {r : ℝ} (hr : 0 ≤ r) :
    (lineY θ ℓc (z + r) 1 t =ᵐ[μ] fun ω =>
        ℓc * ℓs / (ℓc + ℓs) * θ (z + r) t ω + lineE θ ℓc ℓs (z + r) 1 t ω) ∧
      (lineY θ ℓc (z - r) (-1) t =ᵐ[μ] fun ω =>
        ℓc * ℓs / (ℓc + ℓs) * θ (z - r) t ω + lineE θ ℓc ℓs (z - r) (-1) t ω) ∧
      IndepFun (lineE θ ℓc ℓs (z + r) 1 t) (lineE θ ℓc ℓs (z - r) (-1) t) μ ∧
      Indep (MeasurableSpace.comap
          (fun ω => (lineE θ ℓc ℓs (z + r) 1 t ω, lineE θ ℓc ℓs (z - r) (-1) t ω)) inferInstance)
        (lineObsSigma θ r z t) μ ∧
      ∫ ω, lineE θ ℓc ℓs (z + r) 1 t ω ∂μ = 0 ∧ ∫ ω, lineE θ ℓc ℓs (z - r) (-1) t ω ∂μ = 0 := by
  have hℓs := h.ℓs_pos
  -- the residual fields `ε⁺`, `ε⁻` (index clamped at `0`) and the observed field
  let εR : ℝ → Ω → ℝ := fun s => lineRes θ ℓs (z + r) 1 t (max s 0)
  let εL : ℝ → Ω → ℝ := fun s => lineRes θ ℓs (z - r) (-1) t (max s 0)
  let Xo : Icc (-r) r → Ω → ℝ := fun u => θ (z + u) t
  -- "each `ε⁺(s)` is uncorrelated with every `θ(u)`, `u ≤ r`": the exponential
  -- covariance factorizes across the boundary point
  have hcovR : ∀ s y', 0 ≤ s → y' ≤ z + r →
      cov[lineRes θ ℓs (z + r) 1 t s, θ y' t; μ] = 0 := by
    intro s y' hs hy
    rw [h.covariance_lineRes, abs_of_nonneg (show (0 : ℝ) ≤ z + r + 1 * s - y' by linarith),
      abs_of_nonneg (show (0 : ℝ) ≤ z + r - y' by linarith), ← exp_add,
      show -(z + r + 1 * s - y') / ℓs = -s / ℓs + -(z + r - y') / ℓs by ring, sub_self,
      mul_zero]
  -- "and each `ε⁻(s)` with every `θ(u)`, `u ≥ −r`"
  have hcovL : ∀ s y', 0 ≤ s → z - r ≤ y' →
      cov[lineRes θ ℓs (z - r) (-1) t s, θ y' t; μ] = 0 := by
    intro s y' hs hy
    rw [h.covariance_lineRes, abs_of_nonpos (show z - r + -1 * s - y' ≤ 0 by linarith),
      abs_of_nonpos (show z - r - y' ≤ 0 by linarith), ← exp_add,
      show -(-(z - r + -1 * s - y')) / ℓs = -s / ℓs + -(-(z - r - y')) / ℓs by ring, sub_self,
      mul_zero]
  -- `ε⁺(s)` and `ε⁻(s')` are uncorrelated: `ε⁻(s')` is built from values at or left of `z + r`
  have hcovRL : ∀ s s', 0 ≤ s → 0 ≤ s' →
      cov[lineRes θ ℓs (z + r) 1 t s, lineRes θ ℓs (z - r) (-1) t s'; μ] = 0 := by
    intro s s' hs hs'
    have e : lineRes θ ℓs (z - r) (-1) t s'
        = fun ω => θ (z - r + -1 * s') t ω - exp (-s' / ℓs) * θ (z - r) t ω := rfl
    rw [e, covariance_fun_sub_right (h.memLp_lineRes _ _ _ _) (h.memLp _ _)
      ((h.memLp _ _).const_mul _), covariance_const_mul_right,
      hcovR s _ hs (by linarith), hcovR s _ hs (by linarith)]
    simp
  -- the three families are jointly Gaussian: each value is a combination of two field values
  have hG : IsGaussianProcess (Sum.elim (Sum.elim εR εL) Xo) μ := by
    refine h.isGaussianProcess_of_forall_eq fun i => ?_
    rcases i with (s | s) | u
    · refine ⟨1, -exp (-(max s 0) / ℓs), z + r + 1 * max s 0, z + r, t, t, fun ω => ?_⟩
      show θ (z + r + 1 * max s 0) t ω - exp (-(max s 0) / ℓs) * θ (z + r) t ω = _
      ring
    · refine ⟨1, -exp (-(max s 0) / ℓs), z - r + -1 * max s 0, z - r, t, t, fun ω => ?_⟩
      show θ (z - r + -1 * max s 0) t ω - exp (-(max s 0) / ℓs) * θ (z - r) t ω = _
      ring
    · refine ⟨1, 0, z + u, z + u, t, t, fun ω => ?_⟩
      show θ (z + u) t ω = _
      ring
  have hG' : IsGaussianProcess (Sum.elim εR εL) μ := hG.comp_right Sum.inl
  -- "jointly Gaussian and pairwise uncorrelated, hence independent"
  have hInd1 : IndepFun (fun ω (i : ℝ ⊕ ℝ) => Sum.elim εR εL i ω)
      (fun ω (u : Icc (-r) r) => Xo u ω) μ := by
    refine hG.indepFun_of_covariance_eq_zero (fun i => ?_)
      (fun u => (h.measurable _ _).aemeasurable) fun i u => ?_
    · rcases i with s | s
      · exact (h.measurable_lineRes _ _ _ _).aemeasurable
      · exact (h.measurable_lineRes _ _ _ _).aemeasurable
    · rcases i with s | s
      · exact hcovR _ _ (le_max_right _ _) (by linarith [u.2.2])
      · exact hcovL _ _ (le_max_right _ _) (by linarith [u.2.1])
  have hInd2 : IndepFun (fun ω (s : ℝ) => εR s ω) (fun ω (s : ℝ) => εL s ω) μ :=
    hG'.indepFun_of_covariance_eq_zero (fun s => (h.measurable_lineRes _ _ _ _).aemeasurable)
      (fun s => (h.measurable_lineRes _ _ _ _).aemeasurable)
      fun s s' => hcovRL _ _ (le_max_right _ _) (le_max_right _ _)
  -- `E⁺` and `E⁻` are functions of the residual families
  have hER1 : StronglyMeasurable[MeasurableSpace.comap (fun ω (s : ℝ) => εR s ω)
      MeasurableSpace.pi] (lineE θ ℓc ℓs (z + r) 1 t) :=
    h.stronglyMeasurable_lineE ℓc _ _ _ fun s =>
      (measurable_pi_apply s).comp (comap_measurable fun ω (s : ℝ) => εR s ω)
  have hEL1 : StronglyMeasurable[MeasurableSpace.comap (fun ω (s : ℝ) => εL s ω)
      MeasurableSpace.pi] (lineE θ ℓc ℓs (z - r) (-1) t) :=
    h.stronglyMeasurable_lineE ℓc _ _ _ fun s =>
      (measurable_pi_apply s).comp (comap_measurable fun ω (s : ℝ) => εL s ω)
  have hER2 : StronglyMeasurable[MeasurableSpace.comap
      (fun ω (i : ℝ ⊕ ℝ) => Sum.elim εR εL i ω) MeasurableSpace.pi]
      (lineE θ ℓc ℓs (z + r) 1 t) :=
    h.stronglyMeasurable_lineE ℓc _ _ _ fun s =>
      (measurable_pi_apply (Sum.inl s)).comp
        (comap_measurable fun ω (i : ℝ ⊕ ℝ) => Sum.elim εR εL i ω)
  have hEL2 : StronglyMeasurable[MeasurableSpace.comap
      (fun ω (i : ℝ ⊕ ℝ) => Sum.elim εR εL i ω) MeasurableSpace.pi]
      (lineE θ ℓc ℓs (z - r) (-1) t) :=
    h.stronglyMeasurable_lineE ℓc _ _ _ fun s =>
      (measurable_pi_apply (Sum.inr s)).comp
        (comap_measurable fun ω (i : ℝ ⊕ ℝ) => Sum.elim εR εL i ω)
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  -- integrating against `e^{−β_c s}`: `Y = θ(boundary)/(β_c+β_s) + E`
  · filter_upwards [h.lineE_ae_eq hℓc (z + r) 1 t] with ω hω
    rw [hω, integral_Ioi_exp_mul_exp hℓc hℓs]
    ring
  · filter_upwards [h.lineE_ae_eq hℓc (z - r) (-1) t] with ω hω
    rw [hω, integral_Ioi_exp_mul_exp hℓc hℓs]
    ring
  -- `E⁺` and `E⁻` are independent
  · exact (IndepFun_iff_Indep _ _ _).2 (indep_of_indep_of_le_left
      (indep_of_indep_of_le_right ((IndepFun_iff_Indep _ _ _).1 hInd2)
        hEL1.measurable.comap_le) hER1.measurable.comap_le)
  -- the pair is independent of the observation
  · exact indep_of_indep_of_le_left ((IndepFun_iff_Indep _ _ _).1 hInd1)
      (hER2.measurable.prodMk hEL2.measurable).comap_le
  -- `E^±` have mean zero
  · rw [lineE_eq_max, (h.res _ _ _).integral_integral (measurable_exp_neg_div ℓc)
      (integrableOn_Ioi_exp_neg_div hℓc)]
    simp [h.integral_lineRes]
  · rw [lineE_eq_max, (h.res _ _ _).integral_integral (measurable_exp_neg_div ℓc)
      (integrableOn_Ioi_exp_neg_div hℓc)]
    simp [h.integral_lineRes]

/-- Step 3 (appendix 435-439). "the field is Markov in `z`. Given the observed
segment `[−r,r]`, the right tail and the left tail are conditionally
independent, and each depends on the segment only through its adjacent endpoint
`θ(r)` or `θ(−r)`. Therefore `Var(T_r^+ | 𝒪_r) = Var(T_r^+ | θ(r))`,
`Var(T_r^- | 𝒪_r) = Var(T_r^- | θ(−r))`, `Cov(T_r^+, T_r^- | 𝒪_r) = 0`."
Lean proves the Markov property from the supplied step: each tail is a multiple
of its endpoint value plus a multiple of `E^±`, which is independent of the
observation. The identities hold almost surely. -/
theorem s4_markov (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) {r : ℝ}
    (hr : 0 ≤ r) :
    (Var[lineTailR θ ℓc r z t; μ | lineObsSigma θ r z t]
        =ᵐ[μ] Var[lineTailR θ ℓc r z t; μ | MeasurableSpace.comap (θ (z + r) t) inferInstance]) ∧
      (Var[lineTailL θ ℓc r z t; μ | lineObsSigma θ r z t]
        =ᵐ[μ] Var[lineTailL θ ℓc r z t; μ | MeasurableSpace.comap (θ (z - r) t) inferInstance]) ∧
      (μ[fun ω => (lineTailR θ ℓc r z t ω - (μ[lineTailR θ ℓc r z t | lineObsSigma θ r z t]) ω)
          * (lineTailL θ ℓc r z t ω - (μ[lineTailL θ ℓc r z t | lineObsSigma θ r z t]) ω)
          | lineObsSigma θ r z t] =ᵐ[μ] 0) := by
  obtain ⟨hYR, hYL, hIndE, hInd, hER0, hEL0⟩ := s3b_residual_fields h hℓc z t hr
  set c : ℝ := 1 / (2 * ℓc) * exp (-r / ℓc)
  set κ : ℝ := ℓc * ℓs / (ℓc + ℓs)
  set ER : Ω → ℝ := lineE θ ℓc ℓs (z + r) 1 t
  set EL : Ω → ℝ := lineE θ ℓc ℓs (z - r) (-1) t
  have hERm : Measurable ER := h.measurable_lineE ℓc _ _ _
  have hELm : Measurable EL := h.measurable_lineE ℓc _ _ _
  have hER2 : MemLp ER 2 μ := h.memLp_lineE hℓc _ _ _
  have hEL2 : MemLp EL 2 μ := h.memLp_lineE hℓc _ _ _
  have hm𝒪 : lineObsSigma θ r z t ≤ mΩ := (h.measurable_lineObs r z t).comap_le
  -- the endpoint values are observed
  have hbR : Measurable[lineObsSigma θ r z t] (θ (z + r) t) := measurable_lineObs_right θ z t hr
  have hbL : Measurable[lineObsSigma θ r z t] (θ (z - r) t) := measurable_lineObs_left θ z t hr
  -- each tail is a multiple of its endpoint value plus a multiple of `E^±` (Step 2, supplied step)
  have hTR : lineTailR θ ℓc r z t =ᵐ[μ] fun ω => c * κ * θ (z + r) t ω + c * ER ω := by
    filter_upwards [hYR] with ω hω
    rw [s3_right_tail θ hr z t ω, hω]
    ring
  have hTL : lineTailL θ ℓc r z t =ᵐ[μ] fun ω => c * κ * θ (z - r) t ω + c * EL ω := by
    filter_upwards [hYL] with ω hω
    rw [lineTailL_eq θ hr z t ω, hω]
    ring
  -- the multiples of `E^±` are independent of the observation
  have hWRi : Indep (MeasurableSpace.comap (fun ω => c * ER ω) inferInstance) (lineObsSigma θ r z t) μ :=
    indep_of_indep_of_le_left hInd (Measurable.comap_le
      (Measurable.comp (g := fun p : ℝ × ℝ => c * p.1) (measurable_fst.const_mul c)
        (comap_measurable _)))
  have hWLi : Indep (MeasurableSpace.comap (fun ω => c * EL ω) inferInstance) (lineObsSigma θ r z t) μ :=
    indep_of_indep_of_le_left hInd (Measurable.comap_le
      (Measurable.comp (g := fun p : ℝ × ℝ => c * p.2) (measurable_snd.const_mul c)
        (comap_measurable _)))
  have hAR2 : MemLp (fun ω => c * κ * θ (z + r) t ω) 2 μ := (h.memLp _ _).const_mul _
  have hAL2 : MemLp (fun ω => c * κ * θ (z - r) t ω) 2 μ := (h.memLp _ _).const_mul _
  have hAR : StronglyMeasurable[lineObsSigma θ r z t] (fun ω => c * κ * θ (z + r) t ω) :=
    (hbR.const_mul _).stronglyMeasurable
  have hAL : StronglyMeasurable[lineObsSigma θ r z t] (fun ω => c * κ * θ (z - r) t ω) :=
    (hbL.const_mul _).stronglyMeasurable
  have hWRm : Measurable (fun ω => c * ER ω) := hERm.const_mul c
  have hWLm : Measurable (fun ω => c * EL ω) := hELm.const_mul c
  have hWR2 : MemLp (fun ω => c * ER ω) 2 μ := hER2.const_mul c
  have hWL2 : MemLp (fun ω => c * EL ω) 2 μ := hEL2.const_mul c
  refine ⟨?_, ?_, ?_⟩
  -- right tail: both conditional variances are the variance of the independent part
  · have h1 := condVar_add_of_indep hm𝒪 hAR hAR2 hWRm hWR2 hWRi
    have h2 := condVar_add_of_indep (h.measurable (z + r) t).comap_le
      ((comap_measurable (θ (z + r) t)).const_mul (c * κ)).stronglyMeasurable hAR2 hWRm hWR2
      (indep_of_indep_of_le_right hWRi hbR.comap_le)
    exact (condVar_congr_ae hTR).trans (h1.trans (h2.symm.trans (condVar_congr_ae hTR).symm))
  -- left tail
  · have h1 := condVar_add_of_indep hm𝒪 hAL hAL2 hWLm hWL2 hWLi
    have h2 := condVar_add_of_indep (h.measurable (z - r) t).comap_le
      ((comap_measurable (θ (z - r) t)).const_mul (c * κ)).stronglyMeasurable hAL2 hWLm hWL2
      (indep_of_indep_of_le_right hWLi hbL.comap_le)
    exact (condVar_congr_ae hTL).trans (h1.trans (h2.symm.trans (condVar_congr_ae hTL).symm))
  -- conditional covariance: the centred tails are the multiples of `E⁺` and `E⁻`,
  -- which are independent of the observation and of each other, with mean zero
  · have hcR : μ[lineTailR θ ℓc r z t | lineObsSigma θ r z t]
        =ᵐ[μ] fun ω => c * κ * θ (z + r) t ω := by
      have h0 : ∫ ω', c * ER ω' ∂μ = 0 := by rw [integral_const_mul, hER0, mul_zero]
      filter_upwards [condExp_congr_ae (m := lineObsSigma θ r z t) hTR,
        condExp_add_of_indep hm𝒪 hAR (hAR2.integrable one_le_two) hWRm
          (hWR2.integrable one_le_two) hWRi] with ω e1 e2
      rw [e1, e2, h0, add_zero]
    have hcL : μ[lineTailL θ ℓc r z t | lineObsSigma θ r z t]
        =ᵐ[μ] fun ω => c * κ * θ (z - r) t ω := by
      have h0 : ∫ ω', c * EL ω' ∂μ = 0 := by rw [integral_const_mul, hEL0, mul_zero]
      filter_upwards [condExp_congr_ae (m := lineObsSigma θ r z t) hTL,
        condExp_add_of_indep hm𝒪 hAL (hAL2.integrable one_le_two) hWLm
          (hWL2.integrable one_le_two) hWLi] with ω e1 e2
      rw [e1, e2, h0, add_zero]
    have hprod : (fun ω => (lineTailR θ ℓc r z t ω - (μ[lineTailR θ ℓc r z t | lineObsSigma θ r z t]) ω)
          * (lineTailL θ ℓc r z t ω - (μ[lineTailL θ ℓc r z t | lineObsSigma θ r z t]) ω))
        =ᵐ[μ] fun ω => c * ER ω * (c * EL ω) := by
      filter_upwards [hTR, hTL, hcR, hcL] with ω e1 e2 e3 e4
      rw [e1, e2, e3, e4]
      ring
    have hWW : StronglyMeasurable[MeasurableSpace.comap (fun ω => (ER ω, EL ω)) inferInstance]
        (fun ω => c * ER ω * (c * EL ω)) :=
      (Measurable.comp (g := fun p : ℝ × ℝ => c * p.1 * (c * p.2))
        ((measurable_fst.const_mul c).mul (measurable_snd.const_mul c))
        (comap_measurable _)).stronglyMeasurable
    have h4 : μ[fun ω => c * ER ω * (c * EL ω) | lineObsSigma θ r z t]
        =ᵐ[μ] fun _ => ∫ ω, c * ER ω * (c * EL ω) ∂μ :=
      condExp_indep_eq (hERm.prodMk hELm).comap_le hm𝒪 hWW hInd
    have h5 : ∫ ω, c * ER ω * (c * EL ω) ∂μ = 0 := by
      have e : ∀ ω, c * ER ω * (c * EL ω) = c * c * (ER ω * EL ω) := fun ω => by ring
      simp_rw [e]
      rw [integral_const_mul, hIndE.integral_fun_mul_eq_mul_integral hERm.aestronglyMeasurable
        hELm.aestronglyMeasurable, hER0, zero_mul, mul_zero]
    rw [h5] at h4
    exact (condExp_congr_ae hprod).trans h4

/-- Step 4 (appendix 441-447). "Define `C = Var(Y_0 | θ(0))`. Shifting the field
by `r` does not change its law, so `Var(Y_r | θ(r)) = C` for every `r`. By
reflection symmetry (the covariance depends only on `|u − u'|`), the left tail
gives the same value. Hence `Var(x⋆(0) | 𝒪_r) = 2 (β_c/2)² e^{−2β_c r} C` ...
Dividing, `η_S(r) = η_S(0) e^{−2r/ℓ_c}`. The unknown constant `C` cancels."
In Lean `Var(Y | θ(boundary)) = Var(E) = lineTailConst σ ℓc ℓs`, a double
integral of the second moments of the residual field, which involve neither the
boundary point nor the side; this is the shift and reflection invariance. -/
theorem s5_self_similarity (h : CanonicalField μ θ σ ℓs T) {ℓc q : ℝ} (hℓc : 0 < ℓc)
    (hq : 0 < q) (z t : ℝ) {r : ℝ} (hr : 0 ≤ r) :
    lineEtaS μ q θ ℓc r z t = lineEtaS μ q θ ℓc 0 z t * exp (-2 * r / ℓc) := by
  -- "`Var(Y_ρ | θ(ρ)) = C` for every `ρ`", and the same value for the left tail
  have hC : ∀ ρ : ℝ, 0 ≤ ρ →
      (Var[lineY θ ℓc (z + ρ) 1 t; μ | MeasurableSpace.comap (θ (z + ρ) t) inferInstance]
          =ᵐ[μ] fun _ => lineTailConst σ ℓc ℓs) ∧
        (Var[lineY θ ℓc (z - ρ) (-1) t; μ | MeasurableSpace.comap (θ (z - ρ) t) inferInstance]
          =ᵐ[μ] fun _ => lineTailConst σ ℓc ℓs) := by
    intro ρ hρ
    obtain ⟨hYR, hYL, -, hInd, hER0, hEL0⟩ := s3b_residual_fields h hℓc z t hρ
    have hbR : Measurable[lineObsSigma θ ρ z t] (θ (z + ρ) t) := measurable_lineObs_right θ z t hρ
    have hbL : Measurable[lineObsSigma θ ρ z t] (θ (z - ρ) t) := measurable_lineObs_left θ z t hρ
    have hER2 : MemLp (lineE θ ℓc ℓs (z + ρ) 1 t) 2 μ := h.memLp_lineE hℓc _ _ _
    have hEL2 : MemLp (lineE θ ℓc ℓs (z - ρ) (-1) t) 2 μ := h.memLp_lineE hℓc _ _ _
    -- the variance of `E^±` is the same double integral for every boundary point and side
    have hVR : Var[lineE θ ℓc ℓs (z + ρ) 1 t; μ] = lineTailConst σ ℓc ℓs := by
      rw [variance_eq_sub hER2, hER0]
      simp only [Pi.pow_apply]
      rw [h.integral_sq_lineE hℓc (z + ρ) t (by simp)]
      ring
    have hVL : Var[lineE θ ℓc ℓs (z - ρ) (-1) t; μ] = lineTailConst σ ℓc ℓs := by
      rw [variance_eq_sub hEL2, hEL0]
      simp only [Pi.pow_apply]
      rw [h.integral_sq_lineE hℓc (z - ρ) t (by simp)]
      ring
    -- `E^±` is independent of the endpoint value
    have hiR : Indep (MeasurableSpace.comap (lineE θ ℓc ℓs (z + ρ) 1 t) inferInstance)
        (MeasurableSpace.comap (θ (z + ρ) t) inferInstance) μ :=
      indep_of_indep_of_le_left (indep_of_indep_of_le_right hInd hbR.comap_le)
        (Measurable.comap_le (Measurable.comp (g := fun p : ℝ × ℝ => p.1) measurable_fst
          (comap_measurable _)))
    have hiL : Indep (MeasurableSpace.comap (lineE θ ℓc ℓs (z - ρ) (-1) t) inferInstance)
        (MeasurableSpace.comap (θ (z - ρ) t) inferInstance) μ :=
      indep_of_indep_of_le_left (indep_of_indep_of_le_right hInd hbL.comap_le)
        (Measurable.comap_le (Measurable.comp (g := fun p : ℝ × ℝ => p.2) measurable_snd
          (comap_measurable _)))
    constructor
    · have h1 := condVar_add_of_indep (h.measurable (z + ρ) t).comap_le
        ((comap_measurable (θ (z + ρ) t)).const_mul (ℓc * ℓs / (ℓc + ℓs))).stronglyMeasurable
        ((h.memLp (z + ρ) t).const_mul _) (h.measurable_lineE ℓc _ _ _) hER2 hiR
      rw [hVR] at h1
      exact (condVar_congr_ae hYR).trans h1
    · have h1 := condVar_add_of_indep (h.measurable (z - ρ) t).comap_le
        ((comap_measurable (θ (z - ρ) t)).const_mul (ℓc * ℓs / (ℓc + ℓs))).stronglyMeasurable
        ((h.memLp (z - ρ) t).const_mul _) (h.measurable_lineE ℓc _ _ _) hEL2 hiL
      rw [hVL] at h1
      exact (condVar_congr_ae hYL).trans h1
  -- "Hence `Var(x⋆(0) | 𝒪_ρ) = 2 (β_c/2)² e^{−2β_c ρ} C`", for every radius `ρ`
  have key : ∀ ρ : ℝ, 0 ≤ ρ →
      ∫ ω, Var[lineTarget θ ℓc z t; μ | lineObsSigma θ ρ z t] ω ∂μ
        = 2 * (1 / (2 * ℓc) * exp (-ρ / ℓc)) ^ 2 * lineTailConst σ ℓc ℓs := by
    intro ρ hρ
    obtain ⟨hx, hM⟩ := s2_split h hℓc z t hρ
    obtain ⟨h4R, h4L, h4c⟩ := s4_markov h hℓc z t hρ
    obtain ⟨hCR, hCL⟩ := hC ρ hρ
    have hm𝒪 : lineObsSigma θ ρ z t ≤ mΩ := (h.measurable_lineObs ρ z t).comap_le
    -- the middle contributes no conditional variance
    have hadd := condVar_add_add hm𝒪 hM (h.memLp_lineMid hℓc ρ z t)
      (h.memLp_lineTailR hℓc ρ z t) (h.memLp_lineTailL hℓc ρ z t)
    -- the tails are multiples of `Y^±` (Step 2 and its reflection)
    have hTR : lineTailR θ ℓc ρ z t
        = (1 / (2 * ℓc) * exp (-ρ / ℓc)) • lineY θ ℓc (z + ρ) 1 t :=
      funext fun ω => s3_right_tail θ hρ z t ω
    have hTL : lineTailL θ ℓc ρ z t
        = (1 / (2 * ℓc) * exp (-ρ / ℓc)) • lineY θ ℓc (z - ρ) (-1) t :=
      funext fun ω => lineTailL_eq θ hρ z t ω
    have hVTR : Var[lineTailR θ ℓc ρ z t; μ | MeasurableSpace.comap (θ (z + ρ) t) inferInstance]
        =ᵐ[μ] fun _ => (1 / (2 * ℓc) * exp (-ρ / ℓc)) ^ 2 * lineTailConst σ ℓc ℓs := by
      rw [hTR]
      filter_upwards [condVar_smul (μ := μ)
        (m := MeasurableSpace.comap (θ (z + ρ) t) inferInstance)
        (1 / (2 * ℓc) * exp (-ρ / ℓc)) (lineY θ ℓc (z + ρ) 1 t), hCR] with ω e1 e2
      rw [e1, Pi.smul_apply, e2, smul_eq_mul]
    have hVTL : Var[lineTailL θ ℓc ρ z t; μ | MeasurableSpace.comap (θ (z - ρ) t) inferInstance]
        =ᵐ[μ] fun _ => (1 / (2 * ℓc) * exp (-ρ / ℓc)) ^ 2 * lineTailConst σ ℓc ℓs := by
      rw [hTL]
      filter_upwards [condVar_smul (μ := μ)
        (m := MeasurableSpace.comap (θ (z - ρ) t) inferInstance)
        (1 / (2 * ℓc) * exp (-ρ / ℓc)) (lineY θ ℓc (z - ρ) (-1) t), hCL] with ω e1 e2
      rw [e1, Pi.smul_apply, e2, smul_eq_mul]
    have hae : Var[lineTarget θ ℓc z t; μ | lineObsSigma θ ρ z t] =ᵐ[μ] fun _ =>
        2 * (1 / (2 * ℓc) * exp (-ρ / ℓc)) ^ 2 * lineTailConst σ ℓc ℓs := by
      filter_upwards [condVar_congr_ae (m := lineObsSigma θ ρ z t) hx, hadd, h4R, h4L, h4c, hVTR,
        hVTL] with ω e1 e2 e3 e4 e5 e6 e7
      rw [e1, e2, e3, e4, e5, e6, e7, Pi.zero_apply]
      ring
    rw [integral_congr_ae hae, integral_const]
    simp
  rw [s1_variance_ratio h hℓc hq r z t, s1_variance_ratio h hℓc hq 0 z t, key r hr,
    key 0 le_rfl, show -2 * r / ℓc = -r / ℓc + -r / ℓc by ring, exp_add, neg_zero, zero_div,
    exp_zero]
  ring

/-- Step 5a (appendix 449). "Conditioning on the single Gaussian variable `θ(0)`
gives `Var(x⋆(0) | θ(0)) = Var(x⋆(0)) (1 − Corr(x⋆(0), θ(0))²)` ..., so
`η_S(0) = 1 − Corr²`."
In Lean, at `r = 0` the target is `ρ θ(z) + W` almost surely, with
`ρ = ℓ_s/(ℓ_c+ℓ_s)` and `W` a multiple of `E⁺ + E⁻`, independent of `θ(z)`
(Steps 1, 2 and the supplied step); so the conditional variance is `Var W`,
`Var x⋆ = ρ² Var θ(z) + Var W` and `Cov(x⋆, θ(z)) = ρ Var θ(z)`. -/
theorem s6_eta_zero (h : CanonicalField μ θ σ ℓs T) (hσ : σ ≠ 0) {ℓc q : ℝ} (hℓc : 0 < ℓc)
    (hq : 0 < q) (z t : ℝ) :
    lineEtaS μ q θ ℓc 0 z t
      = 1 - cov[lineTarget θ ℓc z t, θ z t; μ] ^ 2
          / (Var[lineTarget θ ℓc z t; μ] * Var[θ z t; μ]) := by
  have hℓs := h.ℓs_pos
  obtain ⟨hx, -⟩ := s2_split h hℓc z t (le_refl (0 : ℝ))
  obtain ⟨hYR, hYL, -, hInd, -, -⟩ := s3b_residual_fields h hℓc z t (le_refl (0 : ℝ))
  simp only [add_zero, sub_zero] at hYR hYL hInd
  set ER : Ω → ℝ := lineE θ ℓc ℓs z 1 t
  set EL : Ω → ℝ := lineE θ ℓc ℓs z (-1) t
  have hERm : Measurable ER := h.measurable_lineE ℓc _ _ _
  have hELm : Measurable EL := h.measurable_lineE ℓc _ _ _
  have hER2 : MemLp ER 2 μ := h.memLp_lineE hℓc _ _ _
  have hEL2 : MemLp EL 2 μ := h.memLp_lineE hℓc _ _ _
  -- at radius zero the target is `ρ θ(z) + W`
  obtain ⟨W, hWdef⟩ : ∃ W : Ω → ℝ, W = fun ω => 1 / (2 * ℓc) * (ER ω + EL ω) := ⟨_, rfl⟩
  have hxW : lineTarget θ ℓc z t =ᵐ[μ] fun ω => ℓs / (ℓc + ℓs) * θ z t ω + W ω := by
    filter_upwards [hx, hYR, hYL] with ω e1 e2 e3
    rw [e1, lineMid_zero, s3_right_tail θ (le_refl (0 : ℝ)) z t ω,
      lineTailL_eq θ (le_refl (0 : ℝ)) z t ω]
    simp only [add_zero, sub_zero, neg_zero, zero_div, exp_zero, mul_one]
    rw [e2, e3, hWdef]
    field_simp
    ring
  have hm𝒪 : lineObsSigma θ 0 z t ≤ mΩ := (h.measurable_lineObs 0 z t).comap_le
  have hb : Measurable[lineObsSigma θ 0 z t] (θ z t) := by
    have := measurable_lineObs_right θ z t (le_refl (0 : ℝ))
    rwa [add_zero] at this
  have hWm : Measurable W := by rw [hWdef]; exact (hERm.add hELm).const_mul _
  have hW2 : MemLp W 2 μ := by rw [hWdef]; exact (hER2.add hEL2).const_mul _
  -- `W` is independent of the observation, hence of `θ(z)`
  have hWi : Indep (MeasurableSpace.comap W inferInstance) (lineObsSigma θ 0 z t) μ := by
    rw [hWdef]
    exact indep_of_indep_of_le_left hInd (Measurable.comap_le
      (Measurable.comp (g := fun p : ℝ × ℝ => 1 / (2 * ℓc) * (p.1 + p.2))
        ((measurable_fst.add measurable_snd).const_mul _) (comap_measurable _)))
  have hA : StronglyMeasurable[lineObsSigma θ 0 z t] (fun ω => ℓs / (ℓc + ℓs) * θ z t ω) :=
    (hb.const_mul _).stronglyMeasurable
  have hA2 : MemLp (fun ω => ℓs / (ℓc + ℓs) * θ z t ω) 2 μ := (h.memLp z t).const_mul _
  have hWθ : IndepFun W (θ z t) μ :=
    (IndepFun_iff_Indep _ _ _).2 (indep_of_indep_of_le_right hWi hb.comap_le)
  have hθW : IndepFun (fun ω => ℓs / (ℓc + ℓs) * θ z t ω) W μ :=
    (IndepFun_iff_Indep _ _ _).2
      (indep_of_indep_of_le_right hWi (hb.const_mul _).comap_le).symm
  have hVθ : Var[θ z t; μ] = σ ^ 2 := h.variance_eq z t
  -- the expected conditional variance is `Var W`
  have hI : ∫ ω, Var[lineTarget θ ℓc z t; μ | lineObsSigma θ 0 z t] ω ∂μ = Var[W; μ] := by
    rw [integral_congr_ae ((condVar_congr_ae hxW).trans
      (condVar_add_of_indep hm𝒪 hA hA2 hWm hW2 hWi)), integral_const]
    simp
  -- `Var x⋆ = ρ² σ² + Var W`
  have hVx : Var[lineTarget θ ℓc z t; μ] = (ℓs / (ℓc + ℓs)) ^ 2 * σ ^ 2 + Var[W; μ] := by
    have hv : Var[fun ω => ℓs / (ℓc + ℓs) * θ z t ω + W ω; μ]
        = Var[fun ω => ℓs / (ℓc + ℓs) * θ z t ω; μ] + Var[W; μ] :=
      IndepFun.variance_add hA2 hW2 hθW
    rw [variance_congr hxW, hv, variance_const_mul, hVθ]
  -- `Cov(x⋆, θ(z)) = ρ σ²`
  have hcov : cov[lineTarget θ ℓc z t, θ z t; μ] = ℓs / (ℓc + ℓs) * σ ^ 2 := by
    have hc : cov[fun ω => ℓs / (ℓc + ℓs) * θ z t ω + W ω, θ z t; μ]
        = cov[fun ω => ℓs / (ℓc + ℓs) * θ z t ω, θ z t; μ] + cov[W, θ z t; μ] :=
      covariance_add_left hA2 hW2 (h.memLp z t)
    rw [covariance_congr_left hxW, hc, covariance_const_mul_left,
      covariance_self (h.measurable z t).aemeasurable, hVθ,
      hWθ.covariance_eq_zero hW2 (h.memLp z t), add_zero]
  rw [s1_variance_ratio h hℓc hq 0 z t, hI, hcov, hVx, hVθ]
  have hσ2 : 0 < σ ^ 2 := by positivity
  have hρ : 0 < (ℓs / (ℓc + ℓs)) ^ 2 * σ ^ 2 := by positivity
  have hW0 : 0 ≤ Var[W; μ] := variance_nonneg W μ
  have hV : (ℓs / (ℓc + ℓs)) ^ 2 * σ ^ 2 + Var[W; μ] ≠ 0 := by linarith
  rw [eq_sub_iff_add_eq, div_add_div _ _ hV (mul_ne_zero hV hσ2.ne'), div_eq_one_iff_eq
    (mul_ne_zero hV (mul_ne_zero hV hσ2.ne'))]
  ring

/-- Step 5b (appendix 451-455). "Covariance with the local value:
`Cov(x⋆(0), θ(0)) = ∫ w(u) σ² e^{−β_s|u|} du = σ² β_c/(β_c+β_s)`." -/
theorem s7_covariance (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) :
    cov[lineTarget θ ℓc z t, θ z t; μ] = σ ^ 2 * (ℓs / (ℓc + ℓs)) := by
  have e : ∫ ω, lineTarget θ ℓc z t ω * θ z t ω ∂μ
      = ∫ u, lineKernel ℓc u * ∫ ω, θ (z + u) t ω * θ z t ω ∂μ :=
    (h.slice z t).integral_integral_mul (measurable_lineKernel ℓc) (integrable_lineKernel hℓc)
      (h.memLp z t)
  rw [covariance_eq_sub (h.memLp_lineTarget hℓc z t) (h.memLp z t), h.mean, mul_zero, sub_zero]
  simp only [Pi.mul_apply]
  rw [e]
  simp_rw [h.cov_same_time, add_sub_cancel_left]
  rw [← integral_lineKernel_mul_exp hℓc h.ℓs_pos, ← integral_const_mul]
  refine integral_congr_ae (ae_of_all _ fun u => ?_)
  show lineKernel ℓc u * (σ ^ 2 * exp (-|u| / ℓs)) = σ ^ 2 * (lineKernel ℓc u * exp (-|u| / ℓs))
  ring

/-- Step 5c (appendix 457-475). "Variance of the target:
`Var(x⋆(0)) = (σ² β_c²/4) I`, `I = ∬ e^{−β_c(|u|+|v|) − β_s|u−v|} du dv`", and
the evaluation of `I`, giving
`Var(x⋆(0)) = σ² β_c (2β_c+β_s) / (2 (β_c+β_s)²)`. The evaluation of the double
integral is `integral_integral_lineKernel_mul_exp` in
`Routine/CanonicalIntegrals.lean`. -/
theorem s8_variance (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) :
    Var[lineTarget θ ℓc z t; μ] = σ ^ 2 * (ℓs * (ℓc + 2 * ℓs) / (2 * (ℓc + ℓs) ^ 2)) := by
  have e : ∫ ω, lineTarget θ ℓc z t ω * lineTarget θ ℓc z t ω ∂μ
      = ∫ u, ∫ v, lineKernel ℓc u * lineKernel ℓc v * ∫ ω, θ (z + u) t ω * θ (z + v) t ω ∂μ :=
    (h.slice z t).integral_integral_mul_integral (h.slice z t) (measurable_lineKernel ℓc)
      (integrable_lineKernel hℓc) (measurable_lineKernel ℓc) (integrable_lineKernel hℓc)
  have e2 : ∀ u v : ℝ, lineKernel ℓc u * lineKernel ℓc v * (σ ^ 2 * exp (-|u - v| / ℓs))
      = σ ^ 2 * (lineKernel ℓc u * lineKernel ℓc v * exp (-|u - v| / ℓs)) := fun u v => by ring
  rw [variance_eq_sub (h.memLp_lineTarget hℓc z t), h.integral_lineTarget hℓc]
  simp only [Pi.pow_apply, sq]
  rw [e]
  simp_rw [h.cov_same_time, add_sub_add_left_eq_sub, e2, integral_const_mul]
  rw [integral_integral_lineKernel_mul_exp hℓc h.ℓs_pos]
  ring

/-- Step 5d (appendix 477-481). "Combine. With `Var(θ(0)) = σ²`,
`Corr² = 2β_c/(2β_c+β_s)`, `η_S(0) = β_s/(2β_c+β_s) = ℓ_c/(ℓ_c+2ℓ_s)`", and with
Step 4, `η_S(r) = ℓ_c/(ℓ_c+2ℓ_s) e^{−2r/ℓ_c}`. -/
theorem s9_combine (h : CanonicalField μ θ σ ℓs T) (hσ : σ ≠ 0) {ℓc q : ℝ} (hℓc : 0 < ℓc)
    (hq : 0 < q) (z t : ℝ) {r : ℝ} (hr : 0 ≤ r) :
    lineEtaS μ q θ ℓc r z t = ℓc / (ℓc + 2 * ℓs) * exp (-2 * r / ℓc) := by
  have hℓs := h.ℓs_pos
  rw [s5_self_similarity h hℓc hq z t hr, s6_eta_zero h hσ hℓc hq z t, s7_covariance h hℓc z t,
    s8_variance h hℓc z t, h.variance_eq z t]
  congr 1
  field_simp
  ring

theorem main : C18.Statement := by
  intro Ω _ μ _ θ σ ℓs T ℓc q h hσ hℓc hq z t r hr
  exact s9_combine h hσ hℓc hq z t hr

end TinaV2.C18.A1
