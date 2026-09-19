import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Module

/-! Scalar parameters of Theorem 1; no probabilistic conclusions are inputs. -/
set_option autoImplicit false

namespace LCSS
noncomputable section

structure Parameters where
  n : ℕ
  hn : 2 ≤ n
  a : ℝ
  b : ℝ
  rate : ℝ
  κ : ℝ
  ha : 0 < a
  hb : 0 < b
  hrate : 0 < rate
  hκ : 0 ≤ κ

namespace Parameters
variable (p : Parameters)
def v : ℝ := p.a + p.b / p.n
def d : ℝ := p.a + p.b * (1 + p.κ * (1 - 1 / p.n))
def pooledCost : ℝ := p.a - p.a ^ 2 / p.v
def localCost : ℝ := p.a - p.a ^ 2 / p.d
def localVariance : ℝ := p.a * p.b / (p.a + p.b)
def pooledVariance : ℝ := p.a * p.b / (p.b + p.n * p.a)
def delta : ℝ := p.localCost - p.pooledCost
def rho (τ : ℝ) : ℝ := Real.exp (-p.rate * τ)
def hybridCost (τ : ℝ) : ℝ :=
  p.rho τ ^ 2 * p.pooledCost + (1 - p.rho τ ^ 2) * p.localCost
def hybridVariance (τ : ℝ) : ℝ :=
  p.rho τ ^ 2 * p.pooledVariance + (1 - p.rho τ ^ 2) * p.localVariance

theorem n_pos : (0 : ℝ) < p.n := by exact_mod_cast (by have := p.hn; omega : 0 < p.n)
theorem n_ne : (p.n : ℝ) ≠ 0 := ne_of_gt p.n_pos
theorem v_pos : 0 < p.v := add_pos p.ha (div_pos p.hb p.n_pos)
theorem d_pos : 0 < p.d := by
  have hn : (1 : ℝ) ≤ p.n := by exact_mod_cast (by have := p.hn; omega : 1 ≤ p.n)
  have h : 0 ≤ 1 - 1 / (p.n : ℝ) := by
    have := (div_le_one p.n_pos).mpr hn
    linarith
  have := mul_nonneg p.hκ h
  dsimp [d]
  nlinarith [p.ha, p.hb]

theorem normal_identity : (1 + p.κ) * (p.a + p.b) - p.κ * p.v = p.d := by
  dsimp [v, d]
  ring

theorem pooledCost_eq_variance : p.pooledCost = p.pooledVariance := by
  have h : p.b + (p.n : ℝ) * p.a ≠ 0 :=
    ne_of_gt (add_pos p.hb (mul_pos p.n_pos p.ha))
  have h' : p.a * (p.n : ℝ) + p.b ≠ 0 := by nlinarith [p.ha, p.hb, p.n_pos]
  dsimp [pooledCost, pooledVariance, v]
  field_simp [p.n_ne, h, h']
  ring_nf
  field_simp [h']
  <;> ring

theorem delta_formula : p.delta = p.a ^ 2 * (p.d - p.v) / (p.v * p.d) := by
  dsimp [delta, localCost, pooledCost]
  field_simp [ne_of_gt p.d_pos, ne_of_gt p.v_pos]
  <;> ring

theorem d_sub_v : p.d - p.v = p.b * (1 + p.κ) * (1 - 1 / p.n) := by
  dsimp [d, v]
  ring

theorem delta_pos : 0 < p.delta := by
  rw [p.delta_formula, p.d_sub_v]
  have hn : (1 : ℝ) < p.n := by exact_mod_cast (by have := p.hn; omega : 1 < p.n)
  have h : 0 < 1 - 1 / (p.n : ℝ) := by
    have := (div_lt_one p.n_pos).mpr hn
    linarith
  exact div_pos (mul_pos (sq_pos_of_pos p.ha)
    (mul_pos (mul_pos p.hb (by linarith [p.hκ])) h)) (mul_pos p.v_pos p.d_pos)

theorem rho_sq (τ : ℝ) : p.rho τ ^ 2 = Real.exp (-2 * p.rate * τ) := by
  rw [rho, pow_two, ← Real.exp_add]
  congr 1
  ring

theorem exponential_value (τ : ℝ) :
    p.localCost - p.hybridCost τ = p.delta * Real.exp (-2 * p.rate * τ) := by
  rw [← p.rho_sq]
  dsimp [hybridCost, delta]
  ring

theorem hybridCost_zero : p.hybridCost 0 = p.pooledCost := by
  simp [hybridCost, rho]

theorem hybridVariance_zero : p.hybridVariance 0 = p.pooledVariance := by
  simp [hybridVariance, rho]

end Parameters
end
end LCSS
