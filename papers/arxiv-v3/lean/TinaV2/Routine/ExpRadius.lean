import TinaV2.Defs
import TinaV2.Routine.RadiusCalculus

/-! # Routine facts for the exponential-omission radius (C16, C19)

What the proofs of Proposition (generic_exponential_radius) and Theorem
(canonical_optimal_radius) leave unsaid: abbreviations for the exponential gain
and derivative bracket, and reading the sign of `r⋆` off its closed form.
Derivative-sign monotonicity lives in `TinaV2.Routine.RadiusCalculus`. -/

noncomputable section

namespace TinaV2.Routine.ExpRadius

open Real Set

/-- Captured benefit `G(r) = (1 − η₀ e^{−2r/ℓ_c}) e^{−2(r/v)/T}`. -/
abbrev expGain (η0 ℓc v T : ℝ) : ℝ → ℝ :=
  gain (fun r : ℝ => η0 * exp (-2 * r / ℓc)) (fun r : ℝ => r / v) T

/-- The bracket in `G'(r)`: `η₀ (1/(vT) + 1/ℓ_c) e^{−2r/ℓ_c} − 1/(vT)`. -/
abbrev expBracket (η0 ℓc v T r : ℝ) : ℝ :=
  η0 * (1 / (v * T) + 1 / ℓc) * exp (-2 * r / ℓc) - 1 / (v * T)

/-- Reading the sign off Eq. (generic_exponential_rstar): `(ℓ_c/2)[log z]_+ > 0`
exactly when `z > 1`, for `z = η₀(1 + vT/ℓ_c) > 0`. -/
theorem expRadius_pos_iff {η0 ℓc v T : ℝ} (hℓc : 0 < ℓc)
    (hz : 0 < η0 * (1 + v * T / ℓc)) :
    0 < expRadius η0 ℓc v T ↔ 1 < η0 * (1 + v * T / ℓc) := by
  unfold expRadius
  rw [mul_pos_iff_of_pos_left (half_pos hℓc), lt_max_iff, Real.log_pos_iff hz.le]
  simp

end TinaV2.Routine.ExpRadius
