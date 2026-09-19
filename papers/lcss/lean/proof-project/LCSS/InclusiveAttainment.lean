import LCSS.InclusiveObjective

/-! Lower bounds and attained optimality for the larger non-strict class.
Canonical strict actions remain feasible by inclusion of their information. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D) (a : AgentCoordinates p)
variable (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

namespace InclusiveRawStrategy

def noRefresh : InclusiveRawStrategy B a w δ hδ Ξ ν :=
  (RawScheduledStrategy.noRefresh B a w δ hδ ν).toInclusive B a w δ hδ ν

def periodic (T : ℝ) (hT : 0 < T) : InclusiveRawStrategy B a w δ hδ Ξ ν :=
  (RawScheduledStrategy.periodic B a w δ hδ ν T hT).toInclusive B a w δ hδ ν

theorem noRefresh_cost (hw : ∀ m, 0 < w m) {c : ℝ} (hc : 0 ≤ c) :
    (noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w) := by
  rw [noRefresh, RawScheduledStrategy.toInclusive_timeUpperCost]
  exact RawScheduledStrategy.noRefresh_cost B a w δ hδ ν hw hc

theorem periodic_cost (hw : ∀ m, 0 < w m) {c : ℝ} (hc : 0 ≤ c) (T : ℝ) (hT : 0 < T) :
    (periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal ((RefreshMixture.ofParameters p w hw δ).periodCost
        (RefreshMixture.baseline p w) c T) := by
  rw [periodic, RawScheduledStrategy.toInclusive_timeUpperCost]
  exact RawScheduledStrategy.periodic_cost B a w δ hδ ν hw hc T hT

end InclusiveRawStrategy

theorem theorem2_inclusive_lower_bounds (hw : ∀ m, 0 < w m) (c : ℝ) (hc : 0 < c)
    (S : InclusiveRawStrategy B a w δ hδ Ξ ν) :
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ENNReal.ofReal (RefreshMixture.baseline p w) ≤ S.timeUpperCost B a w δ hδ ν c) ∧
    (∀ T : ℝ, 0 < T → (RefreshMixture.ofParameters p w hw δ).marginal T = c →
      ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ≤
        S.timeUpperCost B a w δ hδ ν c) := by
  rw [← S.toStrict_timeUpperCost B a w δ hδ ν c]
  exact theorem2_raw_lower_bounds B a w δ hδ ν hw c hc (S.toStrict B a w δ hδ ν)

/-- The comparison quantifies over all non-strict raw strategies, including
immediate use at reception. The supplied raw process model is still explicit. -/
theorem theorem2_inclusive_physical_attainment (hw : ∀ m, 0 < w m) (c : ℝ) (hc : 0 < c) :
    ((InclusiveRawStrategy.noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w)) ∧
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ∀ S : InclusiveRawStrategy B a w δ hδ Ξ ν,
        (InclusiveRawStrategy.noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c ≤
          S.timeUpperCost B a w δ hδ ν c) ∧
    (c < (RefreshMixture.ofParameters p w hw δ).threshold →
      ∃ T : ℝ, ∃ hT : 0 < T,
        (RefreshMixture.ofParameters p w hw δ).marginal T = c ∧
        (∀ U : ℝ, 0 < U → (RefreshMixture.ofParameters p w hw δ).marginal U = c → U = T) ∧
        0 ≤ RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T ∧
        (InclusiveRawStrategy.periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c =
          ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ∧
        (∀ S : InclusiveRawStrategy B a w δ hδ Ξ ν,
          (InclusiveRawStrategy.periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c ≤
            S.timeUpperCost B a w δ hδ ν c)) := by
  have hn := InclusiveRawStrategy.noRefresh_cost B a w δ hδ ν hw hc.le
  refine ⟨hn, ?_, ?_⟩
  · intro hcrit S
    rw [hn]
    exact (theorem2_inclusive_lower_bounds B a w δ hδ ν hw c hc S).1 hcrit
  · intro hcrit
    let q := RefreshMixture.ofParameters p w hw δ
    obtain ⟨T,hT,huniq⟩ := q.exists_unique_period hc hcrit
    have he : (InclusiveRawStrategy.periodic B a w δ hδ ν T hT.1).timeUpperCost B a w δ hδ ν c =
        ENNReal.ofReal (RefreshMixture.baseline p w - q.value T) := by
      rw [InclusiveRawStrategy.periodic_cost B a w δ hδ ν hw hc.le T hT.1,
        q.period_cost_at_root hT.1 hT.2]
    refine ⟨T,hT.1,hT.2,(fun U hU hroot => huniq U ⟨hU,hroot⟩),
      q.running_nonneg (RefreshMixture.baseline_ge_value p w hw hδ) hT.1.le,he,?_⟩
    intro S
    rw [he]
    exact (theorem2_inclusive_lower_bounds B a w δ hδ ν hw c hc S).2 T hT.1 hT.2

end
end LCSS
