import LCSS.PhysicalSchedule
import LCSS.MeasuredObjective

/-! A policy is one time-indexed action, shared by all horizons. Its information
contains literal arithmetic messages from a single locally finite send schedule.
At reception instants we use the left-limit convention (strict reception time).
The audit records the remaining almost-everywhere convention bridge. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology

namespace PhysicalSchedule
variable (S : PhysicalSchedule)

def receivedBefore (δ t : ℝ) : Set ℝ :=
  {r | ∃ k, k ∈ S.active ∧ S.send k + δ < t ∧ r = S.send k}

theorem trace_endpoint (δ : ℝ) (hδ : 0 ≤ δ) (R : ℝ)
    (j : Fin (S.count (R-δ))) :
    (S.trace δ hδ R).reception j + (S.trace δ hδ R).duration j =
      S.boundary δ R j.succ := by
  rw [S.trace_reception]
  change S.send j.val + δ + (S.boundary δ R j.succ - S.boundary δ R j.castSucc) = _
  simp only [boundary, Fin.val_castSucc, j.isLt, if_true]
  ring

theorem no_received_before_initial (δ : ℝ) (hδ : 0 ≤ δ) {R t : ℝ}
    (ht : t ≤ (S.trace δ hδ R).initial) : S.receivedBefore δ t = ∅ := by
  apply Set.eq_empty_iff_forall_notMem.mpr
  rintro r ⟨k,hk,hkt,_⟩
  rw [S.trace_initial] at ht
  by_cases hn : 0 < S.count (R-δ)
  · have ht' : t ≤ S.send 0+δ := by simpa [boundary,hn] using ht
    have := S.ordered (Nat.zero_le k)
    linarith
  · have hz : S.count (R-δ) = 0 := Nat.eq_zero_of_not_pos hn
    have ht' : t ≤ max R 0 := by simpa [boundary,hz] using ht
    by_cases hR : 0 ≤ R
    · rw [max_eq_left hR] at ht'
      have hc := (S.count_spec (R-δ) k).mpr ⟨hk,by linarith⟩
      omega
    · rw [max_eq_right (le_of_not_ge hR)] at ht'
      have := S.nonnegative k hk
      linarith

theorem received_before_phase (δ : ℝ) (hδ : 0 ≤ δ) {R : ℝ}
    (j : Fin (S.count (R-δ))) {x : ℝ} (hx : x ≤ (S.trace δ hδ R).duration j) :
    ∀ r ∈ S.receivedBefore δ ((S.trace δ hδ R).reception j+x), r ≤ S.send j.val := by
  rintro r ⟨k,hk,hkt,rfl⟩
  have hEnd : S.send k+δ < S.boundary δ R j.succ :=
    hkt.trans_le (by linarith [S.trace_endpoint δ hδ R j])
  by_cases hn : j.val+1 < S.count (R-δ)
  · have hEnd' : S.send k+δ < S.send (j.val+1)+δ := by simpa [boundary,hn] using hEnd
    have hkj : k ≤ j.val := by
      by_contra h
      have := S.ordered (show j.val+1 ≤ k by omega)
      linarith
    exact S.ordered hkj
  · have hEnd' : S.send k+δ < max R 0 := by simpa [boundary,hn] using hEnd
    have hR : 0 ≤ R := by
      have hj := (S.count_spec (R-δ) j.val).mp j.isLt
      have := S.nonnegative j.val hj.1
      linarith [hj.2]
    rw [max_eq_left hR] at hEnd'
    have hkc := (S.count_spec (R-δ) k).mpr ⟨hk,by linarith⟩
    exact S.ordered (by omega)

end PhysicalSchedule

variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

/-- Each physical agent has a sensor index in every component. In the paper,
all components have the same agent set and this map is the identity. -/
structure AgentCoordinates (p : ι → Parameters) where
  view : (m : ι) → Fin (p m).n → (k : ι) → Fin (p k).n
  self : ∀ m i, view m i m = i

structure ScheduledPolicy (D : PaperComponents (μ := μ) ι p)
    (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ) where
  action : ℝ → (m : ι) → Fin (p m).n → RV (μ := μ)
  feasible : ∀ t, 0 < t → ∀ m i,
    action t m i ∈ informationSpace (μ := μ)
      (D.receivedInfo (a.view m i) t (S.receivedBefore δ t))

namespace ScheduledPolicy
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (S : PhysicalSchedule) (δ : ℝ) (hδ : 0 ≤ δ)
variable (u : ScheduledPolicy D a S δ)

/-- The information constraint itself admits a policy for every supplied
model. This does not assert the existence of that model or joint regularity. -/
def zero : ScheduledPolicy D a S δ where
  action _ _ _ := 0
  feasible _ _ _ _ := (informationSpace _).zero_mem

def toControls (R : ℝ) : RefreshControls D δ (S.trace δ hδ R) where
  before x := u.action x
  after j x := u.action ((S.trace δ hδ R).reception j+x)
  before_feasible x hx m i := by
    have hu := u.feasible x hx.1 m i
    have he := S.no_received_before_initial δ hδ hx.2
    have hle := D.fresh_localInfo_le (a.view m i) x m
    rw [a.self] at hle
    apply informationSpace_mono hle
    have hle' : D.receivedInfo (a.view m i) x (S.receivedBefore δ x) ≤
        ⨆ k, (D.sensor k).localInfo x (a.view m i k) := by
      apply sup_le le_rfl
      apply iSup_le
      intro k
      apply iSup_le
      intro r
      exfalso
      simpa only [he, Set.mem_empty_iff_false] using r.property
    exact informationSpace_mono hle' hu
  after_feasible j x hx m i := by
    have hr : 0 ≤ (S.trace δ hδ R).reception j := by
      rw [S.trace_reception]
      exact add_nonneg (S.nonnegative j.val ((S.count_spec (R-δ) j.val).mp j.isLt).1) hδ
    have hu := u.feasible ((S.trace δ hδ R).reception j+x) (by linarith [hx.1]) m i
    have hle := D.receivedInfo_le (a.view m i) (S.send j.val)
      ((S.trace δ hδ R).reception j+x)
      (S.receivedBefore δ ((S.trace δ hδ R).reception j+x))
      (S.received_before_phase δ hδ j hx.2) m
    rw [a.self] at hle
    have hh := informationSpace_mono hle hu
    simpa only [S.trace_reception, add_sub_cancel_right] using hh

end ScheduledPolicy

/-- Regularity assumptions concern the actual realized loss, not a supplied
cost equality. Independence is expressed by the product law `ν.prod μ`.
There is one schedule and one action path per independent random seed. -/
structure ScheduledStrategy (D : PaperComponents (μ := μ) ι p)
    (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (Ξ : Type*) [MeasurableSpace Ξ] (ν : Measure Ξ) where
  schedule : Ξ → PhysicalSchedule
  policy : (ξ : Ξ) → ScheduledPolicy D a (schedule ξ) δ
  before_measurable : ∀ ξ R, AEMeasurable
    (Function.uncurry (fun x ω => D.realizedLoss w x ((policy ξ).action x) ω))
    ((volume.restrict (Ioc 0 ((schedule ξ).trace δ hδ R).initial)).prod μ)
  after_measurable : ∀ ξ R (j : Fin ((schedule ξ).count (R-δ))), AEMeasurable
    (Function.uncurry (fun x ω => D.realizedLoss w
      (((schedule ξ).trace δ hδ R).reception j+x)
      ((policy ξ).action (((schedule ξ).trace δ hδ R).reception j+x)) ω))
    ((volume.restrict (Ioc 0 (((schedule ξ).trace δ hδ R).duration j))).prod μ)
  count_measurable : ∀ R, Measurable (fun ξ => (schedule ξ).count R)
  loss_measurable : ∀ R, AEMeasurable (fun z : Ξ × Ω =>
    (∫⁻ x in Ioc 0 ((schedule z.1).trace δ hδ R).initial,
      D.realizedLoss w x ((policy z.1).action x) z.2) +
    ∑ j : Fin ((schedule z.1).count (R-δ)),
      ∫⁻ x in Ioc 0 (((schedule z.1).trace δ hδ R).duration j),
        D.realizedLoss w (((schedule z.1).trace δ hδ R).reception j+x)
          ((policy z.1).action (((schedule z.1).trace δ hδ R).reception j+x)) z.2) (ν.prod μ)

namespace ScheduledStrategy
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
variable (S : ScheduledStrategy D a w δ hδ Ξ ν)

def toMeasured : MeasuredRefreshStrategy D w δ Ξ ν where
  trace ξ R := (S.schedule ξ).trace δ hδ R
  controls ξ R := {
    controls := (S.policy ξ).toControls D a (S.schedule ξ) δ hδ R
    before_measurable := S.before_measurable ξ R
    after_measurable := S.after_measurable ξ R }
  loss_measurable := S.loss_measurable
  count_measurable := S.count_measurable

end ScheduledStrategy

/-- A concrete comparison theorem for one physical schedule/action path per
seed. Its product expectation is proved equal to the iterated objective.
Candidate attainment in this new class is deliberately not asserted here. -/
theorem theorem2_scheduled_lower_bounds
    (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
    (w : ι → ℝ) (hw : ∀ m, 0 < w m) (δ : ℝ) (hδ : 0 ≤ δ)
    {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (c : ℝ) (hc : 0 < c) (S : ScheduledStrategy D a w δ hδ Ξ ν) :
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ENNReal.ofReal (RefreshMixture.baseline p w) ≤
        (S.toMeasured D a w δ hδ ν).physicalUpperCost D w δ ν c) ∧
    (∀ T : ℝ, 0 < T → (RefreshMixture.ofParameters p w hw δ).marginal T = c →
      ENNReal.ofReal (RefreshMixture.baseline p w -
        (RefreshMixture.ofParameters p w hw δ).value T) ≤
        (S.toMeasured D a w δ hδ ν).physicalUpperCost D w δ ν c) := by
  rw [(S.toMeasured D a w δ hδ ν).physicalUpperCost_eq D w δ ν (fun m => (hw m).le)]
  constructor
  · intro hcrit
    have h := RefreshStrategy.none_optimal D w δ ν hw hδ hc hcrit
      ((S.toMeasured D a w δ hδ ν).toStrategy D w δ ν)
    rwa [RefreshStrategy.none_cost D w δ ν hw hδ hc.le] at h
  · intro T hT hroot
    have h := RefreshStrategy.periodic_optimal D w δ ν hw hδ hc hT hroot
      ((S.toMeasured D a w δ hδ ν).toStrategy D w δ ν)
    rwa [RefreshStrategy.periodic_cost D w δ ν hw hδ hc.le T hT,
      (RefreshMixture.ofParameters p w hw δ).period_cost_at_root hT hroot] at h

end
end LCSS
