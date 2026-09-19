import LCSS.RawObjective
import LCSS.PhysicalTraceCosts

/-! Physical attainment from measurable raw primitives. The old conditional
result remains available, but its quotient-representative regularity contract
is not a premise or dependency of this theorem. Strict receptions are retained. -/
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

namespace RawScheduledStrategy

def canonical (Q : PhysicalSchedule) : RawScheduledStrategy B a w δ hδ Ξ ν where
  schedule _ := Q
  policy _ := RawScheduledPolicy.canonical B a Q δ hδ
  before_measurable _ _ := (B.realizedLoss_joint w _
    (RawScheduledPolicy.canonicalAction_joint B Q δ)).aemeasurable
  after_measurable _ R j := (measurable_time_translate _
    (B.realizedLoss_joint w _ (RawScheduledPolicy.canonicalAction_joint B Q δ))
    ((Q.trace δ hδ R).reception j)).aemeasurable
  count_measurable _ := measurable_const
  loss_measurable R :=
    ((B.realizedLoss_joint w _ (RawScheduledPolicy.canonicalAction_joint B Q δ)).lintegral_prod_left.comp
      measurable_snd).aemeasurable

theorem canonical_average (Q : PhysicalSchedule) (hw : ∀ m, 0 < w m)
    {c : ℝ} (hc : 0 ≤ c) (R : ℝ) :
    (canonical B a w δ hδ ν Q).timeAverage B a w δ hδ ν c R =
      ENNReal.ofReal ((Q.trace δ hδ R).cost (RefreshMixture.ofParameters p w hw δ)
        (RefreshMixture.baseline p w) c) / ENNReal.ofReal R := by
  rw [timeAverage_eq B a w δ hδ ν _ (fun m => (hw m).le)]
  change (∫⁻ _ξ, RefreshControls.cost D w δ
    (((RawScheduledPolicy.canonical B a Q δ hδ).toLp B a Q δ).toControls D a Q δ hδ R) c ∂ν) / _ = _
  rw [RawScheduledPolicy.canonical_toLp,
    ScheduledPolicy.canonical_controls_cost D a Q δ hδ w hw R hc]
  simp

def noRefresh : RawScheduledStrategy B a w δ hδ Ξ ν := canonical B a w δ hδ ν PhysicalSchedule.none
def periodic (T : ℝ) (hT : 0 < T) : RawScheduledStrategy B a w δ hδ Ξ ν :=
  canonical B a w δ hδ ν (PhysicalSchedule.periodic T hT)

theorem noRefresh_cost (hw : ∀ m, 0 < w m) {c : ℝ} (hc : 0 ≤ c) :
    (noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w) := by
  rw [← RefreshStrategy.none_cost D w δ ν hw hδ hc]
  unfold timeUpperCost RefreshStrategy.upperCost
  apply Filter.limsup_congr
  filter_upwards [] with R
  rw [noRefresh, canonical_average B a w δ hδ ν _ hw hc R, PhysicalSchedule.none_trace]
  simp only [RefreshStrategy.averageCost, RefreshStrategy.none,
    RefreshControls.optimal_cost D w hw δ hδ _ hc, lintegral_const, measure_univ, mul_one]

theorem periodic_cost (hw : ∀ m, 0 < w m) {c : ℝ} (hc : 0 ≤ c) (T : ℝ) (hT : 0 < T) :
    (periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal ((RefreshMixture.ofParameters p w hw δ).periodCost
        (RefreshMixture.baseline p w) c T) := by
  rw [← RefreshStrategy.periodic_cost D w δ ν hw hδ hc T hT]
  unfold timeUpperCost RefreshStrategy.upperCost
  apply Filter.limsup_congr
  filter_upwards [eventually_ge_atTop δ] with R hR
  rw [periodic, canonical_average B a w δ hδ ν _ hw hc R,
    PhysicalSchedule.periodic_trace δ T hδ hT hR]
  simp only [RefreshStrategy.averageCost, RefreshStrategy.periodic,
    RefreshControls.optimal_cost D w hw δ hδ _ hc, lintegral_const, measure_univ, mul_one]

end RawScheduledStrategy

theorem theorem2_raw_lower_bounds (hw : ∀ m, 0 < w m) (c : ℝ) (hc : 0 < c)
    (S : RawScheduledStrategy B a w δ hδ Ξ ν) :
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ENNReal.ofReal (RefreshMixture.baseline p w) ≤ S.timeUpperCost B a w δ hδ ν c) ∧
    (∀ T : ℝ, 0 < T → (RefreshMixture.ofParameters p w hw δ).marginal T = c →
      ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ≤
        S.timeUpperCost B a w δ hδ ν c) := by
  rw [S.timeUpperCost_eq B a w δ hδ ν (fun m => (hw m).le)]
  constructor
  · intro hcrit
    have h := RefreshStrategy.none_optimal D w δ ν hw hδ hc hcrit (S.toStrategy B a w δ hδ ν)
    rwa [RefreshStrategy.none_cost D w δ ν hw hδ hc.le] at h
  · intro T hT hroot
    have h := RefreshStrategy.periodic_optimal D w δ ν hw hδ hc hT hroot (S.toStrategy B a w δ hδ ν)
    rwa [RefreshStrategy.periodic_cost D w δ ν hw hδ hc.le T hT,
      (RefreshMixture.ofParameters p w hw δ).period_cost_at_root hT hroot] at h

/-- No regularity of L² coercions is requested. All cost equalities and
candidate admissibility are derived from the raw primitive interface. This
statement uses strict reception information and a supplied raw realization. -/
theorem theorem2_raw_physical_attainment (hw : ∀ m, 0 < w m) (c : ℝ) (hc : 0 < c) :
    ((RawScheduledStrategy.noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w)) ∧
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ∀ S : RawScheduledStrategy B a w δ hδ Ξ ν,
        (RawScheduledStrategy.noRefresh B a w δ hδ ν).timeUpperCost B a w δ hδ ν c ≤
          S.timeUpperCost B a w δ hδ ν c) ∧
    (c < (RefreshMixture.ofParameters p w hw δ).threshold →
      ∃ T : ℝ, ∃ hT : 0 < T,
        (RefreshMixture.ofParameters p w hw δ).marginal T = c ∧
        (∀ U : ℝ, 0 < U → (RefreshMixture.ofParameters p w hw δ).marginal U = c → U = T) ∧
        0 ≤ RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T ∧
        (RawScheduledStrategy.periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c =
          ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ∧
        (∀ S : RawScheduledStrategy B a w δ hδ Ξ ν,
          (RawScheduledStrategy.periodic B a w δ hδ ν T hT).timeUpperCost B a w δ hδ ν c ≤
            S.timeUpperCost B a w δ hδ ν c)) := by
  have hn := RawScheduledStrategy.noRefresh_cost B a w δ hδ ν hw hc.le
  refine ⟨hn, ?_, ?_⟩
  · intro hcrit S
    rw [hn]
    exact (theorem2_raw_lower_bounds B a w δ hδ ν hw c hc S).1 hcrit
  · intro hcrit
    let q := RefreshMixture.ofParameters p w hw δ
    obtain ⟨T,hT,huniq⟩ := q.exists_unique_period hc hcrit
    have he : (RawScheduledStrategy.periodic B a w δ hδ ν T hT.1).timeUpperCost B a w δ hδ ν c =
        ENNReal.ofReal (RefreshMixture.baseline p w - q.value T) := by
      rw [RawScheduledStrategy.periodic_cost B a w δ hδ ν hw hc.le T hT.1,
        q.period_cost_at_root hT.1 hT.2]
    refine ⟨T,hT.1,hT.2,(fun U hU hroot => huniq U ⟨hU,hroot⟩),
      q.running_nonneg (RefreshMixture.baseline_ge_value p w hw hδ) hT.1.le,he,?_⟩
    intro S
    rw [he]
    exact (theorem2_raw_lower_bounds B a w δ hδ ν hw c hc S).2 T hT.1 hT.2

end
end LCSS
