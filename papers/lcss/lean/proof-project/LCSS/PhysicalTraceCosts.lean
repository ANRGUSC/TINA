import LCSS.StrictReception

/-! The empty and periodic physical traces agree with the established traces.
Periodic equality is required only after the first reception, which suffices
for all asymptotic costs and avoids artificial negative-horizon sends. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open Set
open scoped BigOperators

namespace RefreshTrace
theorem ext_records {R : ℝ} {s t : RefreshTrace R}
    (hr : s.received = t.received)
    (hd : ∀ j, s.duration j = t.duration (Fin.cast hr j))
    (hs : s.sent = t.sent) : s = t := by
  cases s
  cases t
  dsimp at hr hs hd
  subst hr
  subst hs
  have := funext hd
  simp only [Fin.cast_refl] at this
  cases this
  rfl
end RefreshTrace

namespace PhysicalSchedule

theorem none_trace (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ) :
    none.trace δ hδ R = RefreshTrace.none R := by
  apply RefreshTrace.ext_records (none_count (R-δ))
  · intro j
    have : j.val < none.count (R-δ) := j.isLt
    rw [none_count] at this
    omega
  · exact none_count R

theorem periodic_trace (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T)
    {R : ℝ} (hR : δ ≤ R) :
    (periodic T hT).trace δ hδ R = RefreshTrace.periodic δ T hδ hT R := by
  have hn := periodic_count T hT (show 0 ≤ R-δ by linarith)
  have hs := periodic_count T hT (hδ.trans hR)
  rw [RefreshTrace.periodic, dif_pos hR]
  apply RefreshTrace.ext_records hn _ hs
  intro j
  have hbound : j.val < (periodic T hT).count (R-δ) := j.isLt
  change ((if j.val+1 < (periodic T hT).count (R-δ)
      then ((j.val+1 : ℕ) : ℝ)*T+δ else max R 0) -
    (if j.val < (periodic T hT).count (R-δ)
      then (j.val : ℝ)*T+δ else max R 0)) =
      Fin.lastCases (R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T) (fun _ => T) (Fin.cast hn j)
  have hval : j.val < ⌊(R-δ)/T⌋₊+1 := by omega
  by_cases hj : j.val < ⌊(R-δ)/T⌋₊
  · have he : Fin.cast hn j = (⟨j.val,hj⟩ : Fin ⌊(R-δ)/T⌋₊).castSucc := Fin.ext rfl
    rw [he, Fin.lastCases_castSucc]
    simp only [hbound, if_true,
      show j.val+1 < (periodic T hT).count (R-δ) by omega, Nat.cast_add, Nat.cast_one]
    ring
  · have hj' : j.val = ⌊(R-δ)/T⌋₊ := by omega
    have he : Fin.cast hn j = Fin.last ⌊(R-δ)/T⌋₊ := Fin.ext hj'
    rw [he, Fin.lastCases_last]
    rw [if_pos hbound, if_neg (show ¬j.val+1 < (periodic T hT).count (R-δ) by omega),
      hj', max_eq_left (hδ.trans hR)]
    ring

end PhysicalSchedule
end
end LCSS
