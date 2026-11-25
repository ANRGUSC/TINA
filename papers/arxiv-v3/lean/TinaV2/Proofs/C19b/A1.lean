import TinaV2.Statements
import TinaV2.Routine.RadiusCalculus

/-! # C19.b, attempt A1: mirrors paper proof C19.b/p1

Comparative statics of the canonical radius, `main-v3.tex` 916-939 and
`technical-appendices-v3.tex` 490-499. The paper's proof has three steps:
(1) `∂r⋆/∂(vT) = ℓ_c/[2(ℓ_c + vT)] > 0` in the positive-radius regime (items 1
and 2); (2) `∂r⋆/∂ℓ_s = −ℓ_c/(ℓ_c + 2ℓ_s) < 0` (item 3); (3) the integral
representation `r⋆ = ½ ∫_{2ℓ_s}^{vT} ℓ_c/(ℓ_c + s) ds`, whose integrand is
strictly increasing in `ℓ_c` (item 4). -/

namespace TinaV2.C19b.A1

open Real Set

/-- Step 1 (main-v3.tex 932-933): in the positive-radius regime `vT > 2ℓ_s`,
`∂r⋆/∂(vT) = ℓ_c/[2(ℓ_c + vT)] > 0`. Since `r⋆` depends on `v` and `T` only
through `vT`, it increases strictly with `T` and with `v` (items 1 and 2). -/
theorem s1_deriv_vT (ℓc ℓs : ℝ) (hc : 0 < ℓc) (hs : 0 < ℓs) :
    (∀ x, 2 * ℓs < x →
      HasDerivAt (fun y => canonRadius ℓc ℓs y 1) (ℓc / (2 * (ℓc + x))) x ∧
        0 < ℓc / (2 * (ℓc + x))) ∧
    (∀ v T, 0 < v → 0 < T → 2 * ℓs < v * T →
      (∀ T', T < T' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v T') ∧
      (∀ v', v < v' → canonRadius ℓc ℓs v T < canonRadius ℓc ℓs v' T)) := by
  have hden : 0 < ℓc + 2 * ℓs := by positivity
  have hderiv : ∀ x, 2 * ℓs < x →
      HasDerivAt (fun y => canonRadius ℓc ℓs y 1) (ℓc / (2 * (ℓc + x))) x ∧
        0 < ℓc / (2 * (ℓc + x)) := by
    intro x hx
    have hnum : 0 < ℓc + x := by linarith
    refine ⟨?_, by positivity⟩
    have hEq : (fun y => canonRadius ℓc ℓs y 1)
        =ᶠ[nhds x] fun y => ℓc / 2 * log ((ℓc + y) / (ℓc + 2 * ℓs)) := by
      filter_upwards [Ioi_mem_nhds hx] with y hy
      have hy' : 2 * ℓs < y * 1 := by rw [mul_one]; exact hy
      rw [RadiusCalculus.canonRadius_of_regime hc hs hy', mul_one]
    have h1 : HasDerivAt (fun y : ℝ => ℓc + y) 1 x := (hasDerivAt_id x).const_add ℓc
    have h2 : HasDerivAt (fun y : ℝ => (ℓc + y) / (ℓc + 2 * ℓs)) (1 / (ℓc + 2 * ℓs)) x :=
      h1.div_const _
    have h3 := (h2.log (div_pos hnum hden).ne').const_mul (ℓc / 2)
    refine (h3.congr_of_eventuallyEq hEq).congr_deriv ?_
    field_simp
  refine ⟨hderiv, fun v T hv hT hreg => ?_⟩
  have hmono : StrictMonoOn (fun y => canonRadius ℓc ℓs y 1) (Ioi (2 * ℓs)) :=
    RadiusCalculus.strictMonoOn_of_hasDerivAt_pos (convex_Ioi _)
      (fun x hx => (hderiv x hx).1) (fun x hx => (hderiv x (interior_subset hx)).2)
  refine ⟨fun T' hT' => ?_, fun v' hv' => ?_⟩
  · have hlt : v * T < v * T' := mul_lt_mul_of_pos_left hT' hv
    rw [RadiusCalculus.canonRadius_mul ℓc ℓs v T, RadiusCalculus.canonRadius_mul ℓc ℓs v T']
    exact hmono hreg (hreg.trans hlt) hlt
  · have hlt : v * T < v' * T := mul_lt_mul_of_pos_right hv' hT
    rw [RadiusCalculus.canonRadius_mul ℓc ℓs v T, RadiusCalculus.canonRadius_mul ℓc ℓs v' T]
    exact hmono hreg (hreg.trans hlt) hlt

/-- Step 2 (main-v3.tex 934): in the positive-radius regime,
`∂r⋆/∂ℓ_s = −ℓ_c/(ℓ_c + 2ℓ_s) < 0`, so `r⋆` decreases strictly with `ℓ_s`
inside the regime (item 3): both `ℓ_s` and the larger `ℓ_s'` are in it. -/
theorem s2_deriv_ls (ℓc v T : ℝ) (hc : 0 < ℓc) :
    (∀ ℓs, 0 < ℓs → 2 * ℓs < v * T →
      HasDerivAt (fun y => canonRadius ℓc y v T) (-(ℓc / (ℓc + 2 * ℓs))) ℓs ∧
        -(ℓc / (ℓc + 2 * ℓs)) < 0) ∧
    (∀ ℓs ℓs', 0 < ℓs → ℓs < ℓs' → 2 * ℓs' < v * T →
      canonRadius ℓc ℓs' v T < canonRadius ℓc ℓs v T) := by
  have hderiv : ∀ ℓs, 0 < ℓs → 2 * ℓs < v * T →
      HasDerivAt (fun y => canonRadius ℓc y v T) (-(ℓc / (ℓc + 2 * ℓs))) ℓs ∧
        -(ℓc / (ℓc + 2 * ℓs)) < 0 := by
    intro ℓs hs hreg
    have hden : 0 < ℓc + 2 * ℓs := by positivity
    have hnum : 0 < ℓc + v * T := by linarith
    refine ⟨?_, neg_lt_zero.mpr (div_pos hc hden)⟩
    have hEq : (fun y => canonRadius ℓc y v T)
        =ᶠ[nhds ℓs] fun y => ℓc / 2 * log ((ℓc + v * T) / (ℓc + 2 * y)) := by
      filter_upwards [Ioo_mem_nhds hs (show ℓs < v * T / 2 by linarith)] with y hy
      exact RadiusCalculus.canonRadius_of_regime hc hy.1 (by linarith [hy.2])
    have h1 : HasDerivAt (fun y : ℝ => ℓc + 2 * y) (2 * 1) ℓs :=
      ((hasDerivAt_id ℓs).const_mul 2).const_add ℓc
    have h2 := (hasDerivAt_const ℓs (ℓc + v * T)).fun_div h1 hden.ne'
    have h3 := (h2.log (div_pos hnum hden).ne').const_mul (ℓc / 2)
    refine (h3.congr_of_eventuallyEq hEq).congr_deriv ?_
    field_simp
    ring
  have hanti : StrictAntiOn (fun y => canonRadius ℓc y v T) (Ioo 0 (v * T / 2)) :=
    RadiusCalculus.strictAntiOn_of_hasDerivAt_neg (convex_Ioo _ _)
      (fun y hy => (hderiv y hy.1 (by linarith [hy.2])).1)
      (fun y hy => (hderiv y (interior_subset hy).1 (by linarith [(interior_subset hy).2])).2)
  exact ⟨hderiv, fun ℓs ℓs' hs hlt hreg' =>
    hanti ⟨hs, by linarith⟩ ⟨hs.trans hlt, by linarith⟩ hlt⟩

/-- Step 3 (technical-appendices-v3.tex 490-499): in the positive-radius regime
`r⋆ = ½ ∫_{2ℓ_s}^{vT} ℓ_c/(ℓ_c + s) ds`; the limits do not depend on `ℓ_c` and
the integrand `ℓ_c/(ℓ_c + s) = 1 − s/(ℓ_c + s)` is strictly increasing in `ℓ_c`
for every `s > 0`; hence `r⋆` increases strictly with `ℓ_c` (item 4). -/
theorem s3_integral_rep (ℓs v T : ℝ) (hs : 0 < ℓs) (hreg : 2 * ℓs < v * T) :
    (∀ ℓc, 0 < ℓc →
      canonRadius ℓc ℓs v T = 1 / 2 * ∫ s in (2 * ℓs)..(v * T), ℓc / (ℓc + s)) ∧
    (∀ ℓc ℓc' s : ℝ, 0 < ℓc → ℓc < ℓc' → 0 < s → ℓc / (ℓc + s) < ℓc' / (ℓc' + s)) ∧
    (∀ ℓc ℓc', 0 < ℓc → ℓc < ℓc' → canonRadius ℓc ℓs v T < canonRadius ℓc' ℓs v T) := by
  have h2s : 0 < 2 * ℓs := by positivity
  have hrep : ∀ ℓc, 0 < ℓc →
      canonRadius ℓc ℓs v T = 1 / 2 * ∫ s in (2 * ℓs)..(v * T), ℓc / (ℓc + s) := by
    intro ℓc hc
    have hFTC : ∫ s in (2 * ℓs)..(v * T), ℓc / (ℓc + s)
        = ℓc * log (ℓc + v * T) - ℓc * log (ℓc + 2 * ℓs) := by
      refine intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun s => ℓc * log (ℓc + s)) (fun s hs' => ?_)
        ((RadiusCalculus.continuousOn_div_add hc h2s.le).intervalIntegrable_of_Icc hreg.le)
      rw [uIcc_of_le hreg.le] at hs'
      have hpos : 0 < ℓc + s := by linarith [hs'.1]
      have h1 : HasDerivAt (fun y : ℝ => ℓc + y) 1 s := (hasDerivAt_id s).const_add ℓc
      refine ((h1.log hpos.ne').const_mul ℓc).congr_deriv ?_
      ring
    rw [RadiusCalculus.canonRadius_of_regime hc hs hreg, hFTC,
      log_div (by linarith : ℓc + v * T ≠ 0) (by linarith : ℓc + 2 * ℓs ≠ 0)]
    ring
  have hinc : ∀ ℓc ℓc' s : ℝ, 0 < ℓc → ℓc < ℓc' → 0 < s →
      ℓc / (ℓc + s) < ℓc' / (ℓc' + s) := by
    intro ℓc ℓc' s hc hlt hs'
    have hid : ∀ c : ℝ, 0 < c → c / (c + s) = 1 - s / (c + s) := fun c hc' => by
      have : c + s ≠ 0 := by positivity
      field_simp
      ring
    rw [hid ℓc hc, hid ℓc' (hc.trans hlt)]
    exact sub_lt_sub_left (div_lt_div_of_pos_left hs' (by positivity) (by linarith)) 1
  refine ⟨hrep, hinc, fun ℓc ℓc' hc hlt => ?_⟩
  have hc' : 0 < ℓc' := hc.trans hlt
  have hint : ∫ s in (2 * ℓs)..(v * T), ℓc / (ℓc + s)
      < ∫ s in (2 * ℓs)..(v * T), ℓc' / (ℓc' + s) :=
    intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt hreg
      (RadiusCalculus.continuousOn_div_add hc h2s.le)
      (RadiusCalculus.continuousOn_div_add hc' h2s.le)
      (fun s hs' => (hinc ℓc ℓc' s hc hlt (h2s.trans hs'.1)).le)
      ⟨v * T, right_mem_Icc.mpr hreg.le, hinc ℓc ℓc' (v * T) hc hlt (h2s.trans hreg)⟩
  rw [hrep ℓc hc, hrep ℓc' hc']
  exact mul_lt_mul_of_pos_left hint (by norm_num)

/-- Comparative statics, items 1-4: assembly of the three steps. -/
theorem main : C19b.Statement := fun ℓc ℓs v T hc hs hv hT hreg =>
  ⟨((s1_deriv_vT ℓc ℓs hc hs).2 v T hv hT hreg).1,
    ((s1_deriv_vT ℓc ℓs hc hs).2 v T hv hT hreg).2,
    fun ℓs' hlt hreg' => (s2_deriv_ls ℓc v T hc).2 ℓs ℓs' hs hlt hreg',
    fun ℓc' hlt => (s3_integral_rep ℓs v T hs hreg).2.2 ℓc ℓc' hc hlt⟩

end TinaV2.C19b.A1
