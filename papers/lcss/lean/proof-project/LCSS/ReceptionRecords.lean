import LCSS.ControlledRefresh
import Mathlib.Order.Interval.Finset.Fin

/-! Correspondence between chronological finite reception records and the
interval representation used by the scheduling theorem. Local finiteness is
exactly what makes each finite-horizon chronological record finite. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open scoped BigOperators
namespace RefreshTrace

theorem sum_differences {n : ℕ} (b : Fin (n+1) → ℝ) :
    (∑ j : Fin n, (b j.succ-b j.castSucc)) = b (Fin.last n)-b 0 := by
  have h₁ := Fin.sum_univ_succ b
  have h₂ := Fin.sum_univ_castSucc b
  rw [Finset.sum_sub_distrib]
  linarith

/-- `b 0, ..., b (n-1)` are the receptions and `b n` is the horizon.
Repeated timestamps are permitted; each still incurs a transmission charge. -/
abbrev ofReceptions (R : ℝ) {n : ℕ} (b : Fin (n+1) → ℝ) (hb : Monotone b)
    (hfirst : 0 ≤ b 0) (hlast : b (Fin.last n) = max R 0)
    (sent : ℕ) (hsent : n ≤ sent) : RefreshTrace R where
  received := n
  duration j := b j.succ-b j.castSucc
  duration_nonneg j := sub_nonneg.mpr (hb (show j.castSucc ≤ j.succ from Nat.le_succ j.val))
  coverage := by rw [sum_differences, hlast]; linarith
  sent := sent
  received_le_sent := hsent

theorem ofReceptions_initial (R : ℝ) {n : ℕ} (b : Fin (n+1) → ℝ) (hb : Monotone b)
    (hfirst : 0 ≤ b 0) (hlast : b (Fin.last n) = max R 0) (sent : ℕ) (hsent : n ≤ sent) :
    (ofReceptions R b hb hfirst hlast sent hsent).initial = b 0 := by
  simp only [initial, ofReceptions, sum_differences, hlast]
  ring

theorem prefix_sum {n : ℕ} (f : Fin n → ℝ) (j : Fin n) :
    (∑ k ∈ Finset.univ.filter (fun k => k < j), f k) =
      ∑ k : Fin j.val, f ⟨k.val, by omega⟩ := by
  classical
  symm
  apply Finset.sum_bij (fun (k : Fin j.val) _ => (⟨k.val, by omega⟩ : Fin n))
  · intro k _; simp; exact k.isLt
  · intro k _ l _ h; exact Fin.ext (congrArg (fun x : Fin n => x.val) h)
  · intro k hk
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk
    exact ⟨⟨k.val,hk⟩, Finset.mem_univ _, rfl⟩
  · intro k _; rfl

theorem ofReceptions_reception (R : ℝ) {n : ℕ} (b : Fin (n+1) → ℝ) (hb : Monotone b)
    (hfirst : 0 ≤ b 0) (hlast : b (Fin.last n) = max R 0) (sent : ℕ) (hsent : n ≤ sent)
    (j : Fin n) : (ofReceptions R b hb hfirst hlast sent hsent).reception j = b j.castSucc := by
  rw [reception, ofReceptions_initial, prefix_sum]
  have h := sum_differences (fun k : Fin (j.val+1) => b ⟨k.val, by omega⟩)
  change b 0 + (∑ k : Fin j.val, (b ⟨k.val+1, by omega⟩-b ⟨k.val, by omega⟩)) = b j.castSucc
  change (∑ k : Fin j.val, (b ⟨k.val+1, by omega⟩-b ⟨k.val, by omega⟩)) = b j.castSucc-b 0 at h
  linarith

theorem periodic_initial (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) {R : ℝ} (hR : δ ≤ R) :
    (periodic δ T hδ hT R).initial = δ := by
  simp only [periodic, dif_pos hR, periodicAfter]
  simp only [initial, Fin.sum_univ_castSucc, Fin.lastCases_castSucc, Fin.lastCases_last,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, max_eq_left (hδ.trans hR)]
  ring

theorem periodic_after_reception (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) {R : ℝ} (hR : δ ≤ R)
    (j : Fin (⌊(R-δ)/T⌋₊+1)) :
    (periodicAfter δ T hδ hT R hR).reception j = δ+(j.val : ℝ)*T := by
  simp only [reception, initial, periodicAfter, Fin.sum_univ_castSucc, Fin.lastCases_castSucc,
    Fin.lastCases_last, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
    max_eq_left (hδ.trans hR)]
  have hi : R-((⌊(R-δ)/T⌋₊ : ℝ)*T+(R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T)) = δ := by ring
  rw [hi, prefix_sum]
  have hd : ∀ k : Fin j.val,
      Fin.lastCases (R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T) (fun _ => T)
        (⟨k.val, by omega⟩ : Fin (⌊(R-δ)/T⌋₊+1)) = T := by
    intro k
    have hk : k.val < ⌊(R-δ)/T⌋₊ := by omega
    exact Fin.lastCases_castSucc (motive := fun _ => ℝ)
      (last := R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T) (cast := fun _ => T) ⟨k.val,hk⟩
  simp only [hd, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

end RefreshTrace
end
end LCSS
