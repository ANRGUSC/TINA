import TinaV2.Prelude

/-! Toolchain smoke test (not part of the ledger): the rearrangement used in
the crossover theorem, `η < 1 - e^{-2ρ} ↔ ρ > ½ log (1 / (1 - η))`. -/

namespace TinaV2.Smoke

open Real

theorem crossover_rearrange (η ρ : ℝ) (hη : η < 1) :
    η < 1 - exp (-2 * ρ) ↔ ρ > 1 / 2 * log (1 / (1 - η)) := by
  have h1 : 0 < 1 - η := by linarith
  have hlog : log (1 / (1 - η)) = -log (1 - η) := by rw [one_div, log_inv]
  rw [hlog]
  constructor
  · intro h
    have h2 : exp (-2 * ρ) < 1 - η := by linarith
    have h3 : -2 * ρ < log (1 - η) := (lt_log_iff_exp_lt h1).mpr h2
    linarith
  · intro h
    have h3 : -2 * ρ < log (1 - η) := by linarith
    have h2 : exp (-2 * ρ) < 1 - η := (lt_log_iff_exp_lt h1).mp h3
    linarith

end TinaV2.Smoke
