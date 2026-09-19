import LCSS.ReceptionRecords
import Mathlib.Order.UpperLower.Basic

/-! A single chronological, locally finite transmission sequence. Finite
and empty schedules are supported by an initial segment of active indices.
All messages are generated at nonnegative times; there are no initial messages.
Counts and finite-horizon records are derived, rather than supplied. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open Set
open scoped BigOperators

structure PhysicalSchedule where
  active : Set ℕ
  active_lower : IsLowerSet active
  send : ℕ → ℝ
  ordered : Monotone send
  nonnegative : ∀ k ∈ active, 0 ≤ send k
  locally_finite : ∀ R : ℝ, {k | k ∈ active ∧ send k ≤ R}.Finite

namespace PhysicalSchedule
variable (S : PhysicalSchedule)

theorem exists_count (R : ℝ) :
    ∃ N : ℕ, ∀ k : ℕ, k < N ↔ k ∈ S.active ∧ S.send k ≤ R := by
  have hl : IsLowerSet {k | k ∈ S.active ∧ S.send k ≤ R} := by
    intro i j hij hj
    exact ⟨S.active_lower hij hj.1, (S.ordered hij).trans hj.2⟩
  rcases hl.eq_univ_or_Iio with he | ⟨N,he⟩
  · have hf := S.locally_finite R
    rw [he] at hf
    exact False.elim (Set.infinite_univ hf)
  · exact ⟨N, fun k => by change k ∈ Iio N ↔ _; rw [← he]; rfl⟩

def count (R : ℝ) : ℕ := (S.exists_count R).choose

theorem count_spec (R : ℝ) (k : ℕ) :
    k < S.count R ↔ k ∈ S.active ∧ S.send k ≤ R := (S.exists_count R).choose_spec k

theorem count_mono : Monotone S.count := by
  intro R Q h
  by_contra hn
  have hk : S.count Q < S.count R := Nat.lt_of_not_ge hn
  have hk' := (S.count_spec R _).mp hk
  have := (S.count_spec Q _).mpr ⟨hk'.1,hk'.2.trans h⟩
  exact (Nat.lt_irrefl _ this)

theorem count_of_neg {R : ℝ} (hR : R < 0) : S.count R = 0 := by
  by_contra hn
  have h := (S.count_spec R 0).mp (Nat.pos_of_ne_zero hn)
  have := S.nonnegative 0 h.1
  linarith

def boundary (δ R : ℝ) (j : Fin (S.count (R-δ)+1)) : ℝ :=
  if j.val < S.count (R-δ) then S.send j.val+δ else max R 0

theorem boundary_le (δ R : ℝ) (j : Fin (S.count (R-δ)+1)) :
    S.boundary δ R j ≤ max R 0 := by
  unfold boundary
  split_ifs with h
  · have := ((S.count_spec (R-δ) j.val).mp h).2
    have := le_max_left R 0
    linarith
  · exact le_rfl

theorem boundary_nonneg {δ : ℝ} (hδ : 0 ≤ δ) (R : ℝ)
    (j : Fin (S.count (R-δ)+1)) : 0 ≤ S.boundary δ R j := by
  unfold boundary
  split_ifs with h
  · exact add_nonneg (S.nonnegative j.val ((S.count_spec (R-δ) j.val).mp h).1) hδ
  · exact le_max_right R 0

theorem boundary_mono (δ R : ℝ) : Monotone (S.boundary δ R) := by
  intro i j hij
  unfold boundary
  split_ifs with hi hj hj
  · exact add_le_add (S.ordered hij) le_rfl
  · simpa only [boundary, if_pos hi] using S.boundary_le δ R i
  · have : i.val ≤ j.val := hij
    omega
  · exact le_rfl

theorem boundary_last (δ R : ℝ) :
    S.boundary δ R (Fin.last (S.count (R-δ))) = max R 0 := by
  simp [boundary]

abbrev trace (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ) : RefreshTrace R :=
  RefreshTrace.ofReceptions R (S.boundary δ R) (S.boundary_mono δ R)
    (S.boundary_nonneg hδ R 0) (S.boundary_last δ R)
    (S.count R) (S.count_mono (by linarith))

theorem trace_received (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ) :
    (S.trace δ hδ R).received = S.count (R-δ) := rfl

theorem trace_sent (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ) :
    (S.trace δ hδ R).sent = S.count R := rfl

theorem trace_reception (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ)
    (j : Fin (S.count (R-δ))) :
    (S.trace δ hδ R).reception j = S.send j.val+δ := by
  calc
    _ = S.boundary δ R j.castSucc := RefreshTrace.ofReceptions_reception R
      (S.boundary δ R) (S.boundary_mono δ R) (S.boundary_nonneg hδ R 0)
      (S.boundary_last δ R) (S.count R) (S.count_mono (by linarith)) j
    _ = _ := by simp [boundary, j.isLt]

theorem trace_initial (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ) :
    (S.trace δ hδ R).initial = S.boundary δ R 0 :=
  RefreshTrace.ofReceptions_initial R (S.boundary δ R) (S.boundary_mono δ R)
    (S.boundary_nonneg hδ R 0) (S.boundary_last δ R) (S.count R)
    (S.count_mono (by linarith))

def none : PhysicalSchedule where
  active := ∅
  active_lower := by intro i j _ h; exact h
  send _ := 0
  ordered := monotone_const
  nonnegative := by simp
  locally_finite R := by simp

theorem none_count (R : ℝ) : none.count R = 0 := by
  by_contra h
  have h' := (none.count_spec R 0).mp (Nat.pos_of_ne_zero h)
  exact h'.1

def periodic (T : ℝ) (hT : 0 < T) : PhysicalSchedule where
  active := univ
  active_lower := by intro i j _ _; trivial
  send k := (k : ℝ)*T
  ordered := fun i j hij => mul_le_mul_of_nonneg_right (by exact_mod_cast hij) hT.le
  nonnegative k _ := mul_nonneg (Nat.cast_nonneg _) hT.le
  locally_finite R := by
    apply (Set.finite_Iio (⌊R/T⌋₊+1)).subset
    intro k hk
    change k < ⌊R/T⌋₊+1
    have hR : 0 ≤ R := (mul_nonneg (Nat.cast_nonneg k) hT.le).trans hk.2
    exact Nat.lt_succ_iff.mpr ((Nat.le_floor_iff (div_nonneg hR hT.le)).mpr
      ((le_div_iff₀ hT).mpr hk.2))

theorem periodic_count (T : ℝ) (hT : 0 < T) {R : ℝ} (hR : 0 ≤ R) :
    (periodic T hT).count R = ⌊R/T⌋₊+1 := by
  apply Nat.le_antisymm
  · by_contra h
    have hk := ((periodic T hT).count_spec R (⌊R/T⌋₊+1)).mp (Nat.lt_of_not_ge h)
    have hk' := (le_div_iff₀ hT).mpr hk.2
    have hf := Nat.lt_floor_add_one (R/T)
    simp only [Nat.cast_add, Nat.cast_one] at hk'
    linarith
  · have hk := ((periodic T hT).count_spec R ⌊R/T⌋₊).mpr
      ⟨Set.mem_univ _, (le_div_iff₀ hT).mp (Nat.floor_le (div_nonneg hR hT.le))⟩
    exact hk

end PhysicalSchedule
end
end LCSS
