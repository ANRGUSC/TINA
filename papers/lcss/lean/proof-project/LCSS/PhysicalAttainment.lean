import LCSS.CanonicalStrategy
import LCSS.PhysicalTraceCosts

/-! Theorem 2's physical attainment bridge, conditional on explicit joint loss
regularity. The candidates are constructed, all physical costs are derived,
and the comparison class is the ScheduledStrategy class. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (w : ι → ℝ) (hw : ∀ m, 0 < w m) (reg : CanonicalLossRegularity D w)
variable (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

namespace ScheduledStrategy

def noRefresh : ScheduledStrategy D a w δ hδ Ξ ν :=
  canonical D a w reg δ hδ ν PhysicalSchedule.none

def periodic (T : ℝ) (hT : 0 < T) : ScheduledStrategy D a w δ hδ Ξ ν :=
  canonical D a w reg δ hδ ν (PhysicalSchedule.periodic T hT)

include hw in
theorem noRefresh_cost {c : ℝ} (hc : 0 ≤ c) :
    (noRefresh D a w reg δ hδ ν).timeUpperCost D a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w) := by
  rw [← RefreshStrategy.none_cost D w δ ν hw hδ hc]
  unfold timeUpperCost RefreshStrategy.upperCost
  apply Filter.limsup_congr
  filter_upwards [] with R
  rw [noRefresh, canonical_average D a w reg δ hδ ν _ hw hc R,
    PhysicalSchedule.none_trace]
  simp only [RefreshStrategy.averageCost, RefreshStrategy.none,
    RefreshControls.optimal_cost D w hw δ hδ _ hc, lintegral_const, measure_univ, mul_one]

theorem periodic_cost {c : ℝ} (hc : 0 ≤ c) (T : ℝ) (hT : 0 < T) :
    (periodic D a w reg δ hδ ν T hT).timeUpperCost D a w δ hδ ν c =
      ENNReal.ofReal ((RefreshMixture.ofParameters p w hw δ).periodCost
        (RefreshMixture.baseline p w) c T) := by
  rw [← RefreshStrategy.periodic_cost D w δ ν hw hδ hc T hT]
  unfold timeUpperCost RefreshStrategy.upperCost
  apply Filter.limsup_congr
  filter_upwards [eventually_ge_atTop δ] with R hR
  rw [periodic, canonical_average D a w reg δ hδ ν _ hw hc R,
    PhysicalSchedule.periodic_trace δ T hδ hT hR]
  simp only [RefreshStrategy.averageCost, RefreshStrategy.periodic,
    RefreshControls.optimal_cost D w hw δ hδ _ hc, lintegral_const, measure_univ, mul_one]

end ScheduledStrategy

/-- The physical attaining candidates, their exact costs, and global
optimality. `reg` is an explicit analytic regularity hypothesis.
The positive root is unique; this does not claim uniqueness of all optimal
physical schedules. -/
theorem theorem2_physical_attainment (c : ℝ) (hc : 0 < c) :
    ((ScheduledStrategy.noRefresh D a w reg δ hδ ν).timeUpperCost D a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w)) ∧
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ∀ S : ScheduledStrategy D a w δ hδ Ξ ν,
        (ScheduledStrategy.noRefresh D a w reg δ hδ ν).timeUpperCost D a w δ hδ ν c ≤
          S.timeUpperCost D a w δ hδ ν c) ∧
    (c < (RefreshMixture.ofParameters p w hw δ).threshold →
      ∃ T : ℝ, ∃ hT : 0 < T,
        (RefreshMixture.ofParameters p w hw δ).marginal T = c ∧
        (∀ U : ℝ, 0 < U → (RefreshMixture.ofParameters p w hw δ).marginal U = c → U = T) ∧
        0 ≤ RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T ∧
        (ScheduledStrategy.periodic D a w reg δ hδ ν T hT).timeUpperCost D a w δ hδ ν c =
          ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ∧
        (∀ S : ScheduledStrategy D a w δ hδ Ξ ν,
          (ScheduledStrategy.periodic D a w reg δ hδ ν T hT).timeUpperCost D a w δ hδ ν c ≤
            S.timeUpperCost D a w δ hδ ν c)) := by
  have hn := ScheduledStrategy.noRefresh_cost D a w hw reg δ hδ ν hc.le
  refine ⟨hn, ?_, ?_⟩
  · intro hcrit S
    rw [hn]
    exact (theorem2_time_integrated_lower_bounds D a w hw δ hδ ν c hc S).1 hcrit
  · intro hcrit
    let q := RefreshMixture.ofParameters p w hw δ
    obtain ⟨T,hT,huniq⟩ := q.exists_unique_period hc hcrit
    have he : (ScheduledStrategy.periodic D a w reg δ hδ ν T hT.1).timeUpperCost D a w δ hδ ν c =
        ENNReal.ofReal (RefreshMixture.baseline p w - q.value T) := by
      rw [ScheduledStrategy.periodic_cost D a w hw reg δ hδ ν hc.le T hT.1,
        q.period_cost_at_root hT.1 hT.2]
    refine ⟨T,hT.1,hT.2,(fun U hU hroot => huniq U ⟨hU,hroot⟩),
      q.running_nonneg (RefreshMixture.baseline_ge_value p w hw hδ) hT.1.le,he,?_⟩
    intro S
    rw [he]
    exact (theorem2_time_integrated_lower_bounds D a w hw δ hδ ν c hc S).2 T hT.1 hT.2

end
end LCSS
