import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Module

/-! The actual tracking-plus-disagreement objective on scalar random variables
in a real Hilbert space. Instantiation with L² gives expected team loss. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open scoped InnerProductSpace BigOperators RealInnerProductSpace
variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H]
variable {n : ℕ} {κ : ℝ}

def average (u : Fin n → H) : H := (n : ℝ)⁻¹ • ∑ i, u i

theorem average_add (u w : Fin n → H) :
    average (u + w) = average u + average w := by
  simp [average, Finset.sum_add_distrib, smul_add]

theorem average_sub (u w : Fin n → H) :
    average (u - w) = average u - average w := by
  simp [average, Finset.sum_sub_distrib, smul_sub]

theorem average_const (hn : (n : ℝ) ≠ 0) (x : H) :
    average (fun _ : Fin n => x) = x := by
  simp [average, ← Nat.cast_smul_eq_nsmul ℝ, smul_smul, hn]

def teamCost (κ : ℝ) (X : H) (u : Fin n → H) : ℝ :=
  (n : ℝ)⁻¹ * ((∑ i, ‖u i - X‖ ^ 2) + κ * (∑ i, ‖u i - average u‖ ^ 2))

def gradient (κ : ℝ) (X : H) (u : Fin n → H) (i : Fin n) : H :=
  (1 + κ) • u i - κ • average u - X

theorem teamCost_nonneg (hκ : 0 ≤ κ) (X : H) (u : Fin n → H) :
    0 ≤ teamCost κ X u := by
  exact mul_nonneg (inv_nonneg.mpr (Nat.cast_nonneg n))
    (add_nonneg (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
      (mul_nonneg hκ (Finset.sum_nonneg (fun _ _ => sq_nonneg _))))

theorem sum_inner_average (hn : (n : ℝ) ≠ 0) (u : Fin n → H) (x : H) :
    (∑ i, ⟪u i, x⟫_ℝ) = (n : ℝ) * ⟪average u, x⟫_ℝ := by
  simp [average, real_inner_smul_left, sum_inner, hn]

theorem sum_inner_deviations (hn : (n : ℝ) ≠ 0) (u w : Fin n → H) :
    (∑ i, ⟪w i - average w, u i - average u⟫_ℝ) =
      (∑ i, ⟪w i, u i⟫_ℝ) - (n : ℝ) * ⟪average w, average u⟫_ℝ := by
  simp only [inner_sub_left, inner_sub_right, Finset.sum_sub_distrib]
  rw [sum_inner_average hn]
  have h : (∑ i, ⟪average w, u i⟫_ℝ) = (n : ℝ) * ⟪average w, average u⟫_ℝ := by
    simp [average, real_inner_smul_right, inner_sum, hn]
  rw [h]
  simp

theorem teamCost_add (hn : (n : ℝ) ≠ 0) (κ : ℝ) (X : H) (u w : Fin n → H) :
    teamCost κ X (u + w) = teamCost κ X u + teamCost κ 0 w +
      2 * (n : ℝ)⁻¹ * ∑ i, ⟪w i, gradient κ X u i⟫_ℝ := by
  have ht : ∀ i, (u + w) i - X = (u i - X) + w i := by intro i; simp; abel
  have hd : ∀ i, (u + w) i - average (u + w) =
      (u i - average u) + (w i - average w) := by
    intro i; rw [average_add]; simp; abel
  have htrack : (∑ i, ⟪u i - X, w i⟫_ℝ) =
      (∑ i, ⟪w i, u i⟫_ℝ) - ∑ i, ⟪w i, X⟫_ℝ := by
    simp only [inner_sub_left, Finset.sum_sub_distrib]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro i hi <;> exact real_inner_comm _ _
  have hcross : (∑ i, ⟪u i - average u, w i - average w⟫_ℝ) =
      (∑ i, ⟪w i, u i⟫_ℝ) - (n : ℝ) * ⟪average w, average u⟫_ℝ := by
    rw [← sum_inner_deviations hn u w]
    apply Finset.sum_congr rfl
    intro i hi
    exact real_inner_comm _ _
  simp only [teamCost, ht, hd, norm_add_sq_real, sub_zero,
    Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [htrack, hcross]
  simp only [gradient, inner_sub_right, real_inner_smul_right,
    Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [sum_inner_average hn w (average u)]
  ring

theorem teamCost_minimal_of_orthogonal (hn : (n : ℝ) ≠ 0)
    (hκ : 0 ≤ κ) (X : H) (u v : Fin n → H)
    (horth : ∀ i, ⟪v i - u i, gradient κ X u i⟫_ℝ = 0) :
    teamCost κ X u ≤ teamCost κ X v := by
  have h := teamCost_add hn κ X u (v - u)
  have huv : u + (v - u) = v := by abel
  rw [huv] at h
  simp only [Pi.sub_apply, horth, Finset.sum_const_zero, mul_zero, add_zero] at h
  linarith [teamCost_nonneg hκ (0 : H) (v - u)]

theorem teamCost_stationary_identity (hn : (n : ℝ) ≠ 0) (κ : ℝ) (X : H)
    (u : Fin n → H) :
    teamCost κ X u = ‖X‖ ^ 2 - (n : ℝ)⁻¹ * (∑ i, ⟪u i, X⟫_ℝ) +
      (n : ℝ)⁻¹ * ∑ i, ⟪u i, gradient κ X u i⟫_ℝ := by
  have hvar := sum_inner_deviations hn u u
  simp only [real_inner_self_eq_norm_sq] at hvar
  simp only [teamCost, norm_sub_sq_real, Finset.sum_add_distrib,
    Finset.sum_sub_distrib, Finset.sum_mul, gradient, inner_sub_right,
    real_inner_smul_right, real_inner_self_eq_norm_sq, ← Finset.mul_sum]
  rw [sum_inner_average hn u (average u)]
  simp only [real_inner_self_eq_norm_sq, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp
  <;> ring

theorem teamCost_eq_of_stationary (hn : (n : ℝ) ≠ 0) (κ : ℝ) (X : H)
    (u : Fin n → H) (h : ∀ i, ⟪u i, gradient κ X u i⟫_ℝ = 0) :
    teamCost κ X u = ‖X‖ ^ 2 - (n : ℝ)⁻¹ * ∑ i, ⟪u i, X⟫_ℝ := by
  rw [teamCost_stationary_identity hn]
  simp [h]

end
end LCSS
