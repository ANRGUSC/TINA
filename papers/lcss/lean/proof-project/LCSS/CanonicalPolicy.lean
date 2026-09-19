import LCSS.StrictReception

/-! A single horizon-independent attaining policy for each physical schedule.
All action and feasibility results in this file are independent of joint loss
regularity. The exact finite-horizon expected cost is derived, not assumed. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

namespace ScheduledPolicy
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (S : PhysicalSchedule) (δ : ℝ) (hδ : 0 ≤ δ)

def canonicalAction (t : ℝ) : (m : ι) → Fin (p m).n → RV (μ := μ) :=
  match S.strictCount (t-δ) with
  | 0 => fun m => (D.sensor m).localPolicy t
  | k+1 => fun m => (D.sensor m).hybrid (S.send k) t

def canonical : ScheduledPolicy D a S δ where
  action := canonicalAction D S δ
  feasible t _ m i := by
    have hl : (D.sensor m).localInfo t i ≤
        D.receivedInfo (a.view m i) t (S.receivedBefore δ t) := by
      have h := le_iSup (fun k => (D.sensor k).localInfo t (a.view m i k)) m
      rw [a.self] at h
      exact h.trans le_sup_left
    cases hn : S.strictCount (t-δ) with
    | zero =>
      simpa only [canonicalAction,hn] using
        informationSpace_mono hl ((D.sensor m).local_feasible t i)
    | succ k =>
      have hk := (S.strictCount_spec (t-δ) k).mp (by omega)
      have hm : S.send k ∈ S.receivedBefore δ t := ⟨k,hk.1,by linarith,rfl⟩
      have hs : (D.sensor m).receivedSnapshotInfo (S.send k) t i ≤
          D.receivedInfo (a.view m i) t (S.receivedBefore δ t) := by
        apply sup_le hl
        exact ((le_iSup (fun r : S.receivedBefore δ t =>
          MeasurableSpace.comap ((D.sensor m).message r) inferInstance) ⟨S.send k,hm⟩).trans
          (le_iSup (fun k => ⨆ r : S.receivedBefore δ t,
            MeasurableSpace.comap ((D.sensor k).message r) inferInstance) m)).trans le_sup_right
      simpa only [canonicalAction,hn] using informationSpace_mono hs
        ((D.sensor m).hybrid_received_snapshot_feasible (by linarith [hk.2]) i)

theorem canonical_initial {R t : ℝ} (ht : t ≤ (S.trace δ hδ R).initial) :
    (canonical D a S δ hδ).action t = fun m => (D.sensor m).localPolicy t := by
  funext m
  simp only [canonical,canonicalAction,S.strictCount_initial δ hδ ht]

theorem canonical_phase {R : ℝ} (j : Fin (S.count (R-δ))) {x : ℝ}
    (hx : x ∈ Ioc 0 ((S.trace δ hδ R).duration j)) :
    (canonical D a S δ hδ).action ((S.trace δ hδ R).reception j+x) =
      fun m => (D.sensor m).hybrid ((S.trace δ hδ R).reception j-δ)
        ((S.trace δ hδ R).reception j+x) := by
  change (match S.strictCount ((S.trace δ hδ R).reception j+x-δ) with
    | 0 => fun m => (D.sensor m).localPolicy _
    | k+1 => fun m => (D.sensor m).hybrid (S.send k) _) = _
  rw [S.strictCount_phase δ hδ j hx]
  simp only [S.trace_reception,add_sub_cancel_right]

theorem canonical_controls_cost (w : ι → ℝ) (hw : ∀ m, 0 < w m)
    (R : ℝ) {c : ℝ} (hc : 0 ≤ c) :
    RefreshControls.cost D w δ ((canonical D a S δ hδ).toControls D a S δ hδ R) c =
      ENNReal.ofReal ((S.trace δ hδ R).cost (RefreshMixture.ofParameters p w hw δ)
        (RefreshMixture.baseline p w) c) := by
  rw [← RefreshControls.optimal_cost D w hw δ hδ (S.trace δ hδ R) hc]
  unfold RefreshControls.cost
  congr 2
  · apply lintegral_congr_ae
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    change ENNReal.ofReal (D.totalLoss w x ((canonical D a S δ hδ).action x)) = _
    rw [canonical_initial D a S δ hδ hx.2]
    rfl
  · apply Finset.sum_congr rfl
    intro j _
    apply lintegral_congr_ae
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    change ENNReal.ofReal (D.totalLoss w _
      ((canonical D a S δ hδ).action ((S.trace δ hδ R).reception j+x))) = _
    rw [canonical_phase D a S δ hδ j hx]
    rfl

end ScheduledPolicy
end
end LCSS
