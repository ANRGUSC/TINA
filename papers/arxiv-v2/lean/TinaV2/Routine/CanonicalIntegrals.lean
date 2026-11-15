import TinaV2.Defs

/-! # Routine: the integrals of the canonical model

Real-variable calculus for the decision kernel `w_{ℓ_c}(u) = e^{−|u|/ℓ_c}/(2ℓ_c)`
and the exponential covariance `e^{−|u−v|/ℓ_s}`: "the kernel integrates to one",
the splitting of an integral over the line at `±r`, the substitutions
`u = r + s` and `u = −r − s`, and the values of the covariance integrals of the
appendix (`technical-appendices-v2.tex`, Step 5). With `β_c = 1/ℓ_c`,
`β_s = 1/ℓ_s` the paper's `β_c/(β_c+β_s)` is `ℓ_s/(ℓ_c+ℓ_s)` and its
`β_c(2β_c+β_s)/(2(β_c+β_s)²)` is `ℓ_s(ℓ_c+2ℓ_s)/(2(ℓ_c+ℓ_s)²)`.

Used by the tier D claims C17.b and C18. -/

noncomputable section

namespace TinaV2

open MeasureTheory Real Set

/-! ## Exponential integrals on the half line -/

theorem integrableOn_Ioi_exp_neg_div {ℓ : ℝ} (hℓ : 0 < ℓ) :
    IntegrableOn (fun s : ℝ => exp (-s / ℓ)) (Ioi 0) := by
  have e : (fun s : ℝ => exp (-s / ℓ)) = fun s : ℝ => exp (-(1 / ℓ) * s) := by
    funext s; congr 1; ring
  rw [e]
  exact integrableOn_exp_mul_Ioi (neg_lt_zero.2 (by positivity)) 0

theorem integral_Ioi_exp_neg_div {ℓ : ℝ} (hℓ : 0 < ℓ) :
    ∫ s in Ioi (0 : ℝ), exp (-s / ℓ) = ℓ := by
  have e : (fun s : ℝ => exp (-s / ℓ)) = fun s : ℝ => exp (-(1 / ℓ) * s) := by
    funext s; congr 1; ring
  rw [e, integral_exp_mul_Ioi (neg_lt_zero.2 (by positivity))]
  simp only [mul_zero, exp_zero]
  field_simp

/-- `∫₀^∞ e^{−β_c s} e^{−β_s s} ds = 1/(β_c + β_s)`. -/
theorem integral_Ioi_exp_mul_exp {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * exp (-s / ℓs) = ℓc * ℓs / (ℓc + ℓs) := by
  have hℓ : 0 < ℓc * ℓs / (ℓc + ℓs) := by positivity
  have e : (fun s : ℝ => exp (-s / ℓc) * exp (-s / ℓs))
      = fun s : ℝ => exp (-s / (ℓc * ℓs / (ℓc + ℓs))) := by
    funext s
    rw [← exp_add]
    congr 1
    field_simp
    ring
  rw [e, integral_Ioi_exp_neg_div hℓ]

/-- `e^{−|u|/ℓ}` is integrable on the line. -/
theorem integrable_exp_neg_abs_div {ℓ : ℝ} (hℓ : 0 < ℓ) :
    Integrable fun u : ℝ => exp (-|u| / ℓ) := by
  have h1 : IntegrableOn (fun u : ℝ => exp (-|u| / ℓ)) (Iic 0) := by
    refine (integrableOn_exp_mul_Iic (a := 1 / ℓ) (by positivity) 0).congr_fun
      (fun u hu => ?_) measurableSet_Iic
    have hu' : u ≤ 0 := hu
    simp only [abs_of_nonpos hu']
    congr 1; ring
  have h2 : IntegrableOn (fun u : ℝ => exp (-|u| / ℓ)) (Ioi 0) := by
    refine (integrableOn_Ioi_exp_neg_div hℓ).congr_fun (fun u hu => ?_) measurableSet_Ioi
    have hu' : 0 < u := hu
    simp only [abs_of_pos hu']
  have h := h1.union h2
  rwa [Iic_union_Ioi, integrableOn_univ] at h

/-! ## The kernel -/

theorem continuous_lineKernel (ℓc : ℝ) : Continuous (lineKernel ℓc) := by
  have h : Continuous fun u : ℝ => 1 / (2 * ℓc) * exp (-|u| / ℓc) := by fun_prop
  exact h

theorem measurable_lineKernel (ℓc : ℝ) : Measurable (lineKernel ℓc) :=
  (continuous_lineKernel ℓc).measurable

theorem lineKernel_nonneg {ℓc : ℝ} (hℓc : 0 < ℓc) (u : ℝ) : 0 ≤ lineKernel ℓc u := by
  unfold lineKernel
  positivity

theorem integrable_lineKernel {ℓc : ℝ} (hℓc : 0 < ℓc) : Integrable (lineKernel ℓc) :=
  (integrable_exp_neg_abs_div hℓc).const_mul (1 / (2 * ℓc))

/-- "The kernel integrates to one." -/
theorem integral_lineKernel {ℓc : ℝ} (hℓc : 0 < ℓc) : ∫ u, lineKernel ℓc u = 1 := by
  have h := integral_comp_abs (f := fun x : ℝ => 1 / (2 * ℓc) * exp (-x / ℓc))
  have h2 : ∫ u, lineKernel ℓc u = ∫ u : ℝ, 1 / (2 * ℓc) * exp (-|u| / ℓc) := rfl
  rw [h2, h, integral_const_mul, integral_Ioi_exp_neg_div hℓc]
  field_simp

/-- The kernel on the right tail: `w(r + s) = (1/(2ℓ_c)) e^{−r/ℓ_c} e^{−s/ℓ_c}`. -/
theorem lineKernel_add {ℓc r s : ℝ} (hr : 0 ≤ r) (hs : 0 ≤ s) :
    lineKernel ℓc (r + s) = 1 / (2 * ℓc) * exp (-r / ℓc) * exp (-s / ℓc) := by
  unfold lineKernel
  rw [abs_of_nonneg (add_nonneg hr hs), show -(r + s) / ℓc = -r / ℓc + -s / ℓc by ring, exp_add]
  ring

/-- The kernel on the left tail: `w(−r − s) = (1/(2ℓ_c)) e^{−r/ℓ_c} e^{−s/ℓ_c}`. -/
theorem lineKernel_neg_sub {ℓc r s : ℝ} (hr : 0 ≤ r) (hs : 0 ≤ s) :
    lineKernel ℓc (-r - s) = 1 / (2 * ℓc) * exp (-r / ℓc) * exp (-s / ℓc) := by
  unfold lineKernel
  rw [abs_of_nonpos (by linarith : -r - s ≤ 0),
    show -(-(-r - s)) / ℓc = -r / ℓc + -s / ℓc by ring, exp_add]
  ring

/-! ## Splitting and shifting integrals over the line -/

/-- An integral over the line is the sum of the middle `[−r, r]` and the two
tails. -/
theorem integral_eq_Icc_add_Ioi_add_Iio {f : ℝ → ℝ} (hf : Integrable f) {r : ℝ} (hr : 0 ≤ r) :
    ∫ u, f u = (∫ u in Icc (-r) r, f u) + (∫ u in Ioi r, f u) + ∫ u in Iio (-r), f u := by
  have h1 : ∫ u, f u = (∫ u in Iic r, f u) + ∫ u in Ioi r, f u :=
    (intervalIntegral.integral_Iic_add_Ioi hf.integrableOn hf.integrableOn).symm
  have hd : Disjoint (Iio (-r)) (Icc (-r) r) :=
    Set.disjoint_left.2 fun x hx hx' => not_le.2 hx hx'.1
  have h2 : ∫ u in Iic r, f u = (∫ u in Iio (-r), f u) + ∫ u in Icc (-r) r, f u := by
    rw [← setIntegral_union hd measurableSet_Icc hf.integrableOn hf.integrableOn,
      Iio_union_Icc_eq_Iic (by linarith)]
  rw [h1, h2]
  ring

/-- The substitution `u = r + s` on the right tail. -/
theorem integral_Ioi_eq_integral_Ioi_zero (f : ℝ → ℝ) (r : ℝ) :
    ∫ u in Ioi r, f u = ∫ s in Ioi (0 : ℝ), f (r + s) := by
  rw [← integral_indicator measurableSet_Ioi, ← integral_indicator measurableSet_Ioi,
    ← integral_add_left_eq_self ((Ioi r).indicator f) r]
  congr 1
  funext s
  by_cases hs : 0 < s
  · rw [indicator_of_mem (show r + s ∈ Ioi r by simpa using hs),
      indicator_of_mem (show s ∈ Ioi (0 : ℝ) from hs)]
  · rw [indicator_of_notMem (show r + s ∉ Ioi r by simpa using hs),
      indicator_of_notMem (show s ∉ Ioi (0 : ℝ) from hs)]

/-- The substitution `u = −r − s` on the left tail. -/
theorem integral_Iio_neg_eq_integral_Ioi_zero (f : ℝ → ℝ) (r : ℝ) :
    ∫ u in Iio (-r), f u = ∫ s in Ioi (0 : ℝ), f (-r - s) := by
  rw [← integral_indicator measurableSet_Iio, ← integral_indicator measurableSet_Ioi,
    ← integral_sub_left_eq_self ((Iio (-r)).indicator f) volume (-r)]
  congr 1
  funext s
  by_cases hs : 0 < s
  · rw [indicator_of_mem (show -r - s ∈ Iio (-r) by simpa using hs),
      indicator_of_mem (show s ∈ Ioi (0 : ℝ) from hs)]
  · rw [indicator_of_notMem (show -r - s ∉ Iio (-r) by simpa using hs),
      indicator_of_notMem (show s ∉ Ioi (0 : ℝ) from hs)]

/-! ## The covariance integrals of Step 5 -/

/-- `∫ w(u) e^{−β_s|u|} du = β_c/(β_c + β_s)`. -/
theorem integral_lineKernel_mul_exp {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ u, lineKernel ℓc u * exp (-|u| / ℓs) = ℓs / (ℓc + ℓs) := by
  have h := integral_comp_abs
    (f := fun x : ℝ => 1 / (2 * ℓc) * (exp (-x / ℓc) * exp (-x / ℓs)))
  have h2 : ∫ u, lineKernel ℓc u * exp (-|u| / ℓs)
      = ∫ u : ℝ, 1 / (2 * ℓc) * (exp (-|u| / ℓc) * exp (-|u| / ℓs)) := by
    congr 1
    funext u
    simp only [lineKernel, mul_assoc]
  rw [h2, h, integral_const_mul, integral_Ioi_exp_mul_exp hℓc hℓs]
  field_simp

/-- The same integral centred at any point of the line is finite and the
integrand is integrable. -/
theorem integrable_lineKernel_mul_exp {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) (v : ℝ) :
    Integrable fun u => lineKernel ℓc u * exp (-|u - v| / ℓs) := by
  refine (integrable_lineKernel hℓc).mono' ?_ (Filter.Eventually.of_forall fun u => ?_)
  · exact ((continuous_lineKernel ℓc).mul
      (by fun_prop : Continuous fun u : ℝ => exp (-|u - v| / ℓs))).aestronglyMeasurable
  · have h1 := lineKernel_nonneg hℓc u
    have h3 : exp (-|u - v| / ℓs) ≤ 1 :=
      exp_le_one_iff.2 (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.2 (abs_nonneg _)) hℓs.le)
    rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg h1 (exp_pos _).le)]
    exact mul_le_of_le_one_right h1 h3

/-! ### The double integral

The integrand `w(u) w(v) e^{−β_s|u−v|}` is symmetric under `(u,v) ↦ (v,u)` and
`(u,v) ↦ (−u,−v)`. These reduce the integral over the plane to the regions
`v ≤ 0 < u` and `0 < u < v`, on each of which the integrand is a product of
exponentials. No case `β_s = β_c` arises. -/

/-- For a symmetric integrable kernel, the integral over the plane is twice the
integral over the part above the diagonal. -/
theorem integral_integral_eq_two_mul_integral_Ioi_of_symm {μ : Measure ℝ} [SFinite μ]
    [NullSingletonClass μ] {K : ℝ → ℝ → ℝ} (hsymm : ∀ u v, K u v = K v u)
    (hK : Integrable (Function.uncurry K) (μ.prod μ)) (hKu : ∀ u, Integrable (K u) μ) :
    ∫ u, ∫ v, K u v ∂μ ∂μ = 2 * ∫ u, ∫ v in Ioi u, K u v ∂μ ∂μ := by
  -- the kernel cut off below the diagonal
  let G : ℝ → ℝ → ℝ := fun u v => if v ≤ u then K u v else 0
  have hG : Integrable (Function.uncurry G) (μ.prod μ) := by
    have h := hK.indicator
      (measurableSet_le measurable_snd measurable_fst : MeasurableSet {p : ℝ × ℝ | p.2 ≤ p.1})
    refine h.congr (Filter.Eventually.of_forall fun p => ?_)
    by_cases hp : p.2 ≤ p.1
    · simp [G, Function.uncurry, Set.indicator, hp]
    · simp [G, Function.uncurry, Set.indicator, hp]
  have hP : ∀ u, ∫ v, G u v ∂μ = ∫ v in Iic u, K u v ∂μ := by
    intro u
    rw [← integral_indicator measurableSet_Iic]
    refine integral_congr_ae (Filter.Eventually.of_forall fun v => ?_)
    by_cases hv : v ≤ u
    · simp [G, Set.indicator, hv]
    · simp [G, Set.indicator, hv]
  have hR : ∀ u, ∫ v, G v u ∂μ = ∫ v in Ioi u, K u v ∂μ := by
    intro u
    rw [← integral_Ici_eq_integral_Ioi, ← integral_indicator measurableSet_Ici]
    refine integral_congr_ae (Filter.Eventually.of_forall fun v => ?_)
    by_cases hv : u ≤ v
    · simp [G, Set.indicator, hv, hsymm v u]
    · simp [G, Set.indicator, hv]
  have hsplit : ∀ u, ∫ v, K u v ∂μ = (∫ v, G u v ∂μ) + ∫ v, G v u ∂μ := by
    intro u
    rw [hP, hR, ← compl_Iic, integral_add_compl measurableSet_Iic (hKu u)]
  have hswap : ∫ u, ∫ v, G u v ∂μ ∂μ = ∫ u, ∫ v, G v u ∂μ ∂μ := integral_integral_swap hG
  have hGint : Integrable (fun u => ∫ v, G u v ∂μ) μ := hG.integral_prod_left
  have hGint' : Integrable (fun u => ∫ v, G v u ∂μ) μ := hG.integral_prod_right
  calc ∫ u, ∫ v, K u v ∂μ ∂μ
      = ∫ u, ((∫ v, G u v ∂μ) + ∫ v, G v u ∂μ) ∂μ := by simp_rw [hsplit]
    _ = (∫ u, ∫ v, G u v ∂μ ∂μ) + ∫ u, ∫ v, G v u ∂μ ∂μ := integral_add hGint hGint'
    _ = 2 * ∫ u, ∫ v, G v u ∂μ ∂μ := by rw [hswap]; ring
    _ = 2 * ∫ u, ∫ v in Ioi u, K u v ∂μ ∂μ := by simp_rw [hR]

/-- The integrand of the double integral. -/
private def covK (ℓc ℓs u v : ℝ) : ℝ :=
  lineKernel ℓc u * lineKernel ℓc v * exp (-|u - v| / ℓs)

private theorem covK_eq (ℓc ℓs u v : ℝ) :
    covK ℓc ℓs u v = (1 / (2 * ℓc)) ^ 2 * exp (-(|u| + |v|) / ℓc - |u - v| / ℓs) := by
  unfold covK lineKernel
  rw [show -(|u| + |v|) / ℓc - |u - v| / ℓs = -|u| / ℓc + -|v| / ℓc + -|u - v| / ℓs by ring,
    exp_add, exp_add]
  ring

private theorem covK_symm (ℓc ℓs u v : ℝ) : covK ℓc ℓs u v = covK ℓc ℓs v u := by
  rw [covK_eq, covK_eq, abs_sub_comm u v, add_comm |u| |v|]

private theorem covK_neg (ℓc ℓs u v : ℝ) : covK ℓc ℓs (-u) (-v) = covK ℓc ℓs u v := by
  rw [covK_eq, covK_eq, abs_neg, abs_neg, neg_sub_neg, abs_sub_comm v u]

private theorem abs_covK_le {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) (u v : ℝ) :
    |covK ℓc ℓs u v| ≤ lineKernel ℓc u * lineKernel ℓc v := by
  have h1 := lineKernel_nonneg hℓc u
  have h2 := lineKernel_nonneg hℓc v
  have h3 : exp (-|u - v| / ℓs) ≤ 1 :=
    exp_le_one_iff.2 (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.2 (abs_nonneg _)) hℓs.le)
  unfold covK
  rw [abs_of_nonneg (mul_nonneg (mul_nonneg h1 h2) (exp_pos _).le)]
  exact mul_le_of_le_one_right (mul_nonneg h1 h2) h3

private theorem continuous_covK (ℓc ℓs : ℝ) :
    Continuous fun p : ℝ × ℝ => covK ℓc ℓs p.1 p.2 := by
  unfold covK lineKernel
  fun_prop

private theorem integrable_covK {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    Integrable (Function.uncurry (covK ℓc ℓs)) ((volume : Measure ℝ).prod volume) := by
  refine ((integrable_lineKernel hℓc).mul_prod (integrable_lineKernel hℓc)).mono'
    (continuous_covK ℓc ℓs).aestronglyMeasurable (Filter.Eventually.of_forall fun p => ?_)
  exact abs_covK_le hℓc hℓs p.1 p.2

private theorem integrable_covK_right {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) (u : ℝ) :
    Integrable (covK ℓc ℓs u) := by
  refine ((integrable_lineKernel hℓc).const_mul (lineKernel ℓc u)).mono'
    ?_ (Filter.Eventually.of_forall fun v => ?_)
  · exact ((continuous_covK ℓc ℓs).comp (Continuous.prodMk_right u)).aestronglyMeasurable
  · exact abs_covK_le hℓc hℓs u v

private theorem integrable_integral_covK {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs)
    (s t : Set ℝ) :
    Integrable (fun u => ∫ v in t, covK ℓc ℓs u v) (volume.restrict s) := by
  have h : Integrable (Function.uncurry (covK ℓc ℓs))
      ((volume.restrict s).prod (volume.restrict t)) := by
    rw [Measure.prod_restrict]
    exact (integrable_covK hℓc hℓs).restrict
  exact h.integral_prod_left

/-- The reflection `(u,v) ↦ (−u,−v)`: the integral over the plane is twice the
integral over the half plane `u > 0`. -/
private theorem integral_integral_covK_eq_two_mul (ℓc ℓs : ℝ) :
    ∫ u, ∫ v, covK ℓc ℓs u v = 2 * ∫ u in Ioi (0 : ℝ), ∫ v, covK ℓc ℓs u v := by
  have hev : ∀ u : ℝ, ∫ v, covK ℓc ℓs u v = ∫ v, covK ℓc ℓs |u| v := by
    intro u
    rcases le_total 0 u with hu | hu
    · rw [abs_of_nonneg hu]
    · have h := integral_neg_eq_self (fun v => covK ℓc ℓs (-u) v) volume
      rw [abs_of_nonpos hu, ← h]
      simp only [covK_neg]
  rw [← integral_comp_abs (f := fun u => ∫ v, covK ℓc ℓs u v)]
  exact integral_congr_ae (Filter.Eventually.of_forall hev)

/-- The half plane `u > 0` is the union of the quadrants `v ≤ 0` and `v > 0`. -/
private theorem integral_Ioi_integral_covK_split {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ u in Ioi (0 : ℝ), ∫ v, covK ℓc ℓs u v
      = (∫ u in Ioi (0 : ℝ), ∫ v in Iic (0 : ℝ), covK ℓc ℓs u v)
        + ∫ u in Ioi (0 : ℝ), ∫ v in Ioi (0 : ℝ), covK ℓc ℓs u v := by
  calc ∫ u in Ioi (0 : ℝ), ∫ v, covK ℓc ℓs u v
      = ∫ u in Ioi (0 : ℝ), ((∫ v in Iic (0 : ℝ), covK ℓc ℓs u v)
          + ∫ v in Ioi (0 : ℝ), covK ℓc ℓs u v) := by
        congr 1
        funext u
        exact (intervalIntegral.integral_Iic_add_Ioi
          (integrable_covK_right hℓc hℓs u).integrableOn
          (integrable_covK_right hℓc hℓs u).integrableOn).symm
    _ = _ := integral_add (integrable_integral_covK hℓc hℓs _ _)
        (integrable_integral_covK hℓc hℓs _ _)

/-- The quadrant `v ≤ 0 < u`, where the integrand is
`(β_c/2)² e^{−(β_c+β_s)u} e^{(β_c+β_s)v}`. -/
private theorem integral_Ioi_integral_Iic_covK {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ u in Ioi (0 : ℝ), ∫ v in Iic (0 : ℝ), covK ℓc ℓs u v
      = (1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) ^ 2 := by
  have hκ : 0 < 1 / ℓc + 1 / ℓs := by positivity
  have hin : ∀ u ∈ Ioi (0 : ℝ), ∫ v in Iic (0 : ℝ), covK ℓc ℓs u v
      = (1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) * exp (-(1 / ℓc + 1 / ℓs) * u) := by
    intro u hu
    have hu' : (0 : ℝ) < u := hu
    have hpt : ∀ v ∈ Iic (0 : ℝ), covK ℓc ℓs u v
        = (1 / (2 * ℓc)) ^ 2 * exp (-(1 / ℓc + 1 / ℓs) * u) * exp ((1 / ℓc + 1 / ℓs) * v) := by
      intro v hv
      have hv' : v ≤ 0 := hv
      rw [covK_eq, abs_of_pos hu', abs_of_nonpos hv', abs_of_nonneg (by linarith : 0 ≤ u - v),
        mul_assoc, ← exp_add]
      congr 2
      ring
    rw [setIntegral_congr_fun measurableSet_Iic hpt, integral_const_mul,
      integral_exp_mul_Iic hκ]
    simp only [mul_zero, exp_zero]
    ring
  rw [setIntegral_congr_fun measurableSet_Ioi hin, integral_const_mul,
    integral_exp_mul_Ioi (neg_lt_zero.2 hκ)]
  simp only [mul_zero, exp_zero]
  field_simp

/-- The region `0 < u < v`, where the integrand is
`(β_c/2)² e^{(β_s−β_c)u} e^{−(β_c+β_s)v}`; the inner integral is over `v`. -/
private theorem integral_Ioi_integral_Ioi_covK {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ u in Ioi (0 : ℝ), ∫ v in Ioi u, covK ℓc ℓs u v
      = (1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) * (ℓc / 2) := by
  have hκ : 0 < 1 / ℓc + 1 / ℓs := by positivity
  have hin : ∀ u ∈ Ioi (0 : ℝ), ∫ v in Ioi u, covK ℓc ℓs u v
      = (1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) * exp (-(2 / ℓc) * u) := by
    intro u hu
    have hu' : (0 : ℝ) < u := hu
    have hpt : ∀ v ∈ Ioi u, covK ℓc ℓs u v
        = (1 / (2 * ℓc)) ^ 2 * exp ((1 / ℓs - 1 / ℓc) * u) * exp (-(1 / ℓc + 1 / ℓs) * v) := by
      intro v hv
      have hv' : u < v := hv
      rw [covK_eq, abs_of_pos hu', abs_of_pos (hu'.trans hv'),
        abs_of_neg (by linarith : u - v < 0), mul_assoc, ← exp_add]
      congr 2
      ring
    rw [setIntegral_congr_fun measurableSet_Ioi hpt, integral_const_mul,
      integral_exp_mul_Ioi (neg_lt_zero.2 hκ),
      show -(2 / ℓc) * u = (1 / ℓs - 1 / ℓc) * u + -(1 / ℓc + 1 / ℓs) * u by ring, exp_add]
    field_simp
  rw [setIntegral_congr_fun measurableSet_Ioi hin, integral_const_mul,
    integral_exp_mul_Ioi (neg_lt_zero.2 (by positivity))]
  simp only [mul_zero, exp_zero]
  field_simp

/-- `∬ w(u) w(v) e^{−β_s|u−v|} du dv = β_c(2β_c + β_s)/(2(β_c + β_s)²)`, the
value of `(β_c²/4) I` in the appendix, including the case `β_s = β_c`. -/
theorem integral_integral_lineKernel_mul_exp {ℓc ℓs : ℝ} (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    ∫ u, ∫ v, lineKernel ℓc u * lineKernel ℓc v * exp (-|u - v| / ℓs)
      = ℓs * (ℓc + 2 * ℓs) / (2 * (ℓc + ℓs) ^ 2) := by
  have hquad : ∫ u in Ioi (0 : ℝ), ∫ v in Ioi (0 : ℝ), covK ℓc ℓs u v
      = 2 * ∫ u in Ioi (0 : ℝ), ∫ v in Ioi u, covK ℓc ℓs u v := by
    have hK : Integrable (Function.uncurry (covK ℓc ℓs))
        ((volume.restrict (Ioi (0 : ℝ))).prod (volume.restrict (Ioi (0 : ℝ)))) := by
      rw [Measure.prod_restrict]
      exact (integrable_covK hℓc hℓs).restrict
    rw [integral_integral_eq_two_mul_integral_Ioi_of_symm (covK_symm ℓc ℓs) hK
      fun u => (integrable_covK_right hℓc hℓs u).restrict]
    congr 1
    refine setIntegral_congr_fun measurableSet_Ioi fun u hu => ?_
    have hu' : (0 : ℝ) < u := hu
    rw [Measure.restrict_restrict measurableSet_Ioi,
      inter_eq_left.2 (Ioi_subset_Ioi hu'.le)]
  calc ∫ u, ∫ v, lineKernel ℓc u * lineKernel ℓc v * exp (-|u - v| / ℓs)
      = ∫ u, ∫ v, covK ℓc ℓs u v := rfl
    _ = 2 * ((1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) ^ 2
          + 2 * ((1 / (2 * ℓc)) ^ 2 / (1 / ℓc + 1 / ℓs) * (ℓc / 2))) := by
        rw [integral_integral_covK_eq_two_mul, integral_Ioi_integral_covK_split hℓc hℓs,
          integral_Ioi_integral_Iic_covK hℓc hℓs, hquad, integral_Ioi_integral_Ioi_covK hℓc hℓs]
    _ = ℓs * (ℓc + 2 * ℓs) / (2 * (ℓc + ℓs) ^ 2) := by
        field_simp
        ring

end TinaV2
