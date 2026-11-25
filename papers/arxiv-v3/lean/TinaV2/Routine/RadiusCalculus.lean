import TinaV2.Defs

/-! # Routine calculus facts for the radius claims (C15, C19.b)

Bookkeeping the paper leaves unsaid: differentiability at an interior point of
a curve that is `C¹` on `[0, D]`, the unfolded form of `log G`, the unfolded
form of `canonRadius` where the positive part is inactive, the wrapper
"derivative of one sign on an interval implies strictly monotone", and
continuity of the integrand `s ↦ ℓ_c/(ℓ_c + s)`. -/

namespace TinaV2.RadiusCalculus

open Real Set Filter Topology

/-- A curve that is `C¹` on `[0, D]` is differentiable at every interior point. -/
theorem differentiableAt_of_contDiffOn_Icc {f : ℝ → ℝ} {D r : ℝ}
    (hf : ContDiffOn ℝ 1 f (Icc 0 D)) (hr : r ∈ Ioo 0 D) : DifferentiableAt ℝ f r :=
  (hf.differentiableOn one_ne_zero).differentiableAt (Icc_mem_nhds hr.1 hr.2)

/-- Unfolding `gain`: `log G(r) = log(1 − η(r)) − 2τ(r)/T` where `η(r) < 1`. -/
theorem log_gain {η τ : ℝ → ℝ} {T r : ℝ} (h : η r < 1) :
    log (gain η τ T r) = log (1 - η r) - 2 * τ r / T := by
  unfold gain
  rw [log_mul (sub_pos.mpr h).ne' (exp_pos _).ne', log_exp]
  ring

/-- A strictly positive derivative on the interior of a convex set gives a strictly
increasing function on the set. -/
theorem strictMonoOn_of_hasDerivAt_pos {D : Set ℝ} (hD : Convex ℝ D) {f f' : ℝ → ℝ}
    (hf : ∀ x ∈ D, HasDerivAt f (f' x) x) (hpos : ∀ x ∈ interior D, 0 < f' x) : StrictMonoOn f D :=
  strictMonoOn_of_deriv_pos hD (fun x hx => (hf x hx).continuousAt.continuousWithinAt)
    fun x hx => by
      rw [(hf x (interior_subset hx)).deriv]
      exact hpos x hx

/-- A strictly negative derivative on the interior of a convex set gives a strictly
decreasing function on the set. -/
theorem strictAntiOn_of_hasDerivAt_neg {D : Set ℝ} (hD : Convex ℝ D) {f f' : ℝ → ℝ}
    (hf : ∀ x ∈ D, HasDerivAt f (f' x) x) (hneg : ∀ x ∈ interior D, f' x < 0) : StrictAntiOn f D :=
  strictAntiOn_of_deriv_neg hD (fun x hx => (hf x hx).continuousAt.continuousWithinAt)
    fun x hx => by
      rw [(hf x (interior_subset hx)).deriv]
      exact hneg x hx

/-- Unfolding `canonRadius`: it depends on `v` and `T` only through `vT`. -/
theorem canonRadius_mul (ℓc ℓs v T : ℝ) :
    canonRadius ℓc ℓs v T = canonRadius ℓc ℓs (v * T) 1 := by
  simp [canonRadius]

/-- Unfolding `canonRadius` in the positive-radius regime `vT > 2ℓ_s`, where
the logarithm is positive and the positive part `[·]_+` is inactive. -/
theorem canonRadius_of_regime {ℓc ℓs v T : ℝ} (hc : 0 < ℓc) (hs : 0 < ℓs)
    (h : 2 * ℓs < v * T) :
    canonRadius ℓc ℓs v T = ℓc / 2 * log ((ℓc + v * T) / (ℓc + 2 * ℓs)) := by
  have hden : 0 < ℓc + 2 * ℓs := by positivity
  have hlog : 0 ≤ log ((ℓc + v * T) / (ℓc + 2 * ℓs)) :=
    log_nonneg ((one_le_div hden).mpr (by linarith))
  rw [canonRadius, max_eq_left hlog]

/-- The integrand `s ↦ ℓ_c/(ℓ_c + s)` is continuous on `[a, b]` when `a ≥ 0`. -/
theorem continuousOn_div_add {ℓc a b : ℝ} (hc : 0 < ℓc) (ha : 0 ≤ a) :
    ContinuousOn (fun s : ℝ => ℓc / (ℓc + s)) (Icc a b) :=
  continuousOn_const.div (continuousOn_const.add continuousOn_id) fun _ hs =>
    (add_pos_of_pos_of_nonneg hc (ha.trans hs.1)).ne'

end TinaV2.RadiusCalculus
