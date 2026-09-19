import LCSS.TimeIntegral

/-! Counts of strict receptions, including exact endpoints and repeated sends. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory Set

namespace PhysicalSchedule
variable (S : PhysicalSchedule)

theorem exists_strictCount (r : ℝ) :
    ∃ N : ℕ, ∀ k : ℕ, k < N ↔ k ∈ S.active ∧ S.send k < r := by
  have hl : IsLowerSet {k | k ∈ S.active ∧ S.send k < r} := by
    intro i j hij hj
    exact ⟨S.active_lower hij hj.1, (S.ordered hij).trans_lt hj.2⟩
  rcases hl.eq_univ_or_Iio with he | ⟨N,he⟩
  · have hf : {k | k ∈ S.active ∧ S.send k < r}.Finite :=
      (S.locally_finite r).subset (fun _ h => ⟨h.1,h.2.le⟩)
    rw [he] at hf
    exact False.elim (Set.infinite_univ hf)
  · exact ⟨N, fun k => by change k ∈ Iio N ↔ _; rw [← he]; rfl⟩

def strictCount (r : ℝ) : ℕ := (S.exists_strictCount r).choose

theorem strictCount_spec (r : ℝ) (k : ℕ) :
    k < S.strictCount r ↔ k ∈ S.active ∧ S.send k < r :=
  (S.exists_strictCount r).choose_spec k

theorem strictCount_mono : Monotone S.strictCount := by
  intro r s hrs
  by_contra hn
  have h := (S.strictCount_spec r _).mp (Nat.lt_of_not_ge hn)
  exact (Nat.lt_irrefl _ ((S.strictCount_spec s _).mpr ⟨h.1,h.2.trans_le hrs⟩))

theorem strictCount_measurable : Measurable S.strictCount :=
  S.strictCount_mono.measurable

theorem strictCount_initial (δ : ℝ) (hδ : 0 ≤ δ) {R t : ℝ}
    (ht : t ≤ (S.trace δ hδ R).initial) : S.strictCount (t-δ) = 0 := by
  by_contra hn
  have h := (S.strictCount_spec (t-δ) 0).mp (Nat.pos_of_ne_zero hn)
  have hm : S.send 0 ∈ S.receivedBefore δ t := ⟨0,h.1,by linarith,rfl⟩
  simpa [S.no_received_before_initial δ hδ ht] using hm

theorem strictCount_phase (δ : ℝ) (hδ : 0 ≤ δ) {R : ℝ}
    (j : Fin (S.count (R-δ))) {x : ℝ}
    (hx : x ∈ Ioc 0 ((S.trace δ hδ R).duration j)) :
    S.strictCount ((S.trace δ hδ R).reception j+x-δ) = j.val+1 := by
  apply Nat.le_antisymm
  · by_contra hn
    have hk := (S.strictCount_spec ((S.trace δ hδ R).reception j+x-δ) (j.val+1)).mp
      (Nat.lt_of_not_ge hn)
    have he : S.send (j.val+1)+δ < S.boundary δ R j.succ := by
      linarith [S.trace_endpoint δ hδ R j, hx.2, hk.2]
    by_cases hj : j.val+1 < S.count (R-δ)
    · simpa [boundary,hj] using he
    · have he' : S.send (j.val+1)+δ < max R 0 := by simpa [boundary,hj] using he
      have hR : 0 ≤ R := by
        have h := (S.count_spec (R-δ) j.val).mp j.isLt
        have := S.nonnegative j.val h.1
        linarith [h.2]
      rw [max_eq_left hR] at he'
      exact hj ((S.count_spec (R-δ) _).mpr ⟨hk.1,by linarith⟩)
  · have hj := (S.count_spec (R-δ) j.val).mp j.isLt
    apply (S.strictCount_spec _ j.val).mpr
    refine ⟨hj.1,?_⟩
    rw [S.trace_reception]
    linarith [hx.1]

end PhysicalSchedule
end
end LCSS
