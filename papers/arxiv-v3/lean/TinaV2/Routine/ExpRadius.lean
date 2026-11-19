import TinaV2.Defs

/-! # Routine facts for the exponential-omission radius (C16, C19)

What the proofs of Proposition (generic_exponential_radius) and Theorem
(canonical_optimal_radius) leave unsaid: the passage from the sign of a
derivative on an interval to strict monotonicity there, and reading the sign
of `r⋆` off its closed form. -/

namespace TinaV2.Routine.ExpRadius

open Real Set

/-- A function with a strictly positive derivative on the interior of a convex
set is strictly increasing on the set. Mathlib's `strictMonoOn_of_deriv_pos`,
restated for a derivative given by `HasDerivAt`. -/
theorem strictMonoOn_of_hasDerivAt_pos {f f' : ℝ → ℝ} {D : Set ℝ} (hD : Convex ℝ D)
    (hf : ∀ x, HasDerivAt f (f' x) x) (hf' : ∀ x ∈ interior D, 0 < f' x) :
    StrictMonoOn f D :=
  strictMonoOn_of_deriv_pos hD (fun x _ => (hf x).continuousAt.continuousWithinAt)
    (fun x hx => by rw [(hf x).deriv]; exact hf' x hx)

/-- A function with a strictly negative derivative on the interior of a convex
set is strictly decreasing on the set. Mathlib's `strictAntiOn_of_deriv_neg`,
restated for a derivative given by `HasDerivAt`. -/
theorem strictAntiOn_of_hasDerivAt_neg {f f' : ℝ → ℝ} {D : Set ℝ} (hD : Convex ℝ D)
    (hf : ∀ x, HasDerivAt f (f' x) x) (hf' : ∀ x ∈ interior D, f' x < 0) :
    StrictAntiOn f D :=
  strictAntiOn_of_deriv_neg hD (fun x _ => (hf x).continuousAt.continuousWithinAt)
    (fun x hx => by rw [(hf x).deriv]; exact hf' x hx)

/-- Reading the sign off Eq. (generic_exponential_rstar): `(ℓ_c/2)[log z]_+ > 0`
exactly when `z > 1`, for `z = η₀(1 + vT/ℓ_c) > 0`. -/
theorem expRadius_pos_iff {η0 ℓc v T : ℝ} (hℓc : 0 < ℓc)
    (hz : 0 < η0 * (1 + v * T / ℓc)) :
    0 < expRadius η0 ℓc v T ↔ 1 < η0 * (1 + v * T / ℓc) := by
  unfold expRadius
  rw [mul_pos_iff_of_pos_left (half_pos hℓc), lt_max_iff, Real.log_pos_iff hz.le]
  simp

end TinaV2.Routine.ExpRadius
