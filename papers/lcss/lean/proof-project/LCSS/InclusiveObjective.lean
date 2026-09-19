import LCSS.InclusivePolicy

/-! The non-strict class has the same analytic requirements as RawScheduledStrategy.
Endpoint modification preserves every horizon cost, even when it is infinite. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)

structure InclusiveRawStrategy (a : AgentCoordinates p) (w : ι → ℝ)
    (δ : ℝ) (hδ : 0 ≤ δ) (Ξ : Type*) [MeasurableSpace Ξ] (ν : Measure Ξ) where
  schedule : Ξ → PhysicalSchedule
  policy : (ξ : Ξ) → InclusiveRawPolicy B a (schedule ξ) δ
  before_measurable : ∀ ξ R, AEMeasurable
    (fun z : ℝ × Ω => B.realizedLoss w z.1 ((policy ξ).action z.1) z.2)
    ((volume.restrict (Ioc 0 ((schedule ξ).trace δ hδ R).initial)).prod μ)
  after_measurable : ∀ ξ R (j : Fin ((schedule ξ).count (R-δ))), AEMeasurable
    (fun z : ℝ × Ω => B.realizedLoss w (((schedule ξ).trace δ hδ R).reception j+z.1)
      ((policy ξ).action (((schedule ξ).trace δ hδ R).reception j+z.1)) z.2)
    ((volume.restrict (Ioc 0 (((schedule ξ).trace δ hδ R).duration j))).prod μ)
  count_measurable : ∀ R, Measurable (fun ξ => (schedule ξ).count R)
  loss_measurable : ∀ R, AEMeasurable (fun z : Ξ × Ω =>
    ∫⁻ t in Ioc 0 R, B.realizedLoss w t ((policy z.1).action t) z.2) (ν.prod μ)

namespace InclusiveRawStrategy
variable (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
variable (S : InclusiveRawStrategy B a w δ hδ Ξ ν)

def toStrict : RawScheduledStrategy B a w δ hδ Ξ ν where
  schedule := S.schedule
  policy ξ := (S.policy ξ).toStrict B a (S.schedule ξ) δ
  before_measurable ξ R := by
    apply (S.before_measurable ξ R).congr
    simpa only [zero_add] using ((S.policy ξ).toStrict_loss_phase_ae B a (S.schedule ξ) δ w
      0 ((S.schedule ξ).trace δ hδ R).initial).symm
  after_measurable ξ R j := (S.after_measurable ξ R j).congr
    ((S.policy ξ).toStrict_loss_phase_ae B a (S.schedule ξ) δ w
      (((S.schedule ξ).trace δ hδ R).reception j)
      (((S.schedule ξ).trace δ hδ R).duration j)).symm
  count_measurable := S.count_measurable
  loss_measurable R := by
    apply (S.loss_measurable R).congr
    exact Filter.Eventually.of_forall (fun z =>
      ((S.policy z.1).toStrict_integrated_loss B a (S.schedule z.1) δ w R z.2).symm)

def timeAverage (c R : ℝ) : ℝ≥0∞ :=
  (∫⁻ z : Ξ × Ω, (∫⁻ t in Ioc 0 R,
    B.realizedLoss w t ((S.policy z.1).action t) z.2) +
      ENNReal.ofReal c * (S.schedule z.1).count R ∂ν.prod μ) / ENNReal.ofReal R

def timeUpperCost (c : ℝ) : ℝ≥0∞ := limsup (S.timeAverage B a w δ hδ ν c) atTop

omit [Nonempty ι] [IsProbabilityMeasure ν] in
theorem toStrict_timeAverage (c R : ℝ) :
    (S.toStrict B a w δ hδ ν).timeAverage B a w δ hδ ν c R =
      S.timeAverage B a w δ hδ ν c R := by
  unfold RawScheduledStrategy.timeAverage timeAverage
  congr 1
  apply lintegral_congr
  intro z
  exact congrArg (fun x => x + ENNReal.ofReal c * (S.schedule z.1).count R)
    ((S.policy z.1).toStrict_integrated_loss B a (S.schedule z.1) δ w R z.2)

omit [IsProbabilityMeasure ν] in
theorem toStrict_timeUpperCost (c : ℝ) :
    (S.toStrict B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      S.timeUpperCost B a w δ hδ ν c := by
  unfold RawScheduledStrategy.timeUpperCost timeUpperCost
  congr 1
  funext R
  exact S.toStrict_timeAverage B a w δ hδ ν c R

/-- The expected finite-horizon inequality is proved for each seed. The
charge still counts sends by the horizon, including messages in flight. -/
theorem expected_horizon_lower_bound (hw : ∀ m, 0 < w m)
    (ξ : Ξ) (c : ℝ) (hc : 0 ≤ c) (R : ℝ) :
    ENNReal.ofReal (((S.schedule ξ).trace δ hδ R).cost
      (RefreshMixture.ofParameters p w hw δ) (RefreshMixture.baseline p w) c) ≤
    ∫⁻ ω, (∫⁻ t in Ioc 0 R, B.realizedLoss w t ((S.policy ξ).action t) ω) +
      ENNReal.ofReal c * (S.schedule ξ).count R ∂μ := by
  have he := (S.toStrict B a w δ hδ ν).expected_horizon_cost B a w δ hδ ν
    (fun m => (hw m).le) ξ c R
  have hi : (∫⁻ ω, (∫⁻ t in Ioc 0 R,
      B.realizedLoss w t (((S.toStrict B a w δ hδ ν).policy ξ).action t) ω) +
      ENNReal.ofReal c * (S.schedule ξ).count R ∂μ) =
      ∫⁻ ω, (∫⁻ t in Ioc 0 R, B.realizedLoss w t ((S.policy ξ).action t) ω) +
        ENNReal.ofReal c * (S.schedule ξ).count R ∂μ := by
    apply lintegral_congr
    intro ω
    exact congrArg (fun x => x + ENNReal.ofReal c * (S.schedule ξ).count R)
      ((S.policy ξ).toStrict_integrated_loss B a (S.schedule ξ) δ w R ω)
  exact (RefreshControls.cost_lower_bound D w hw δ hδ
    ((S.toStrict B a w δ hδ ν).toStrategy B a w δ hδ ν |>.controls ξ R) hc).trans_eq
      (he.symm.trans hi)

end InclusiveRawStrategy

namespace RawScheduledStrategy
variable (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

def toInclusive (S : RawScheduledStrategy B a w δ hδ Ξ ν) :
    InclusiveRawStrategy B a w δ hδ Ξ ν where
  schedule := S.schedule
  policy ξ := (S.policy ξ).toInclusive B a (S.schedule ξ) δ
  before_measurable := S.before_measurable
  after_measurable := S.after_measurable
  count_measurable := S.count_measurable
  loss_measurable := S.loss_measurable

omit [Nonempty ι] [IsProbabilityMeasure ν] in
theorem toInclusive_timeAverage (S : RawScheduledStrategy B a w δ hδ Ξ ν) (c R : ℝ) :
    (S.toInclusive B a w δ hδ ν).timeAverage B a w δ hδ ν c R =
      S.timeAverage B a w δ hδ ν c R := rfl

omit [Nonempty ι] [IsProbabilityMeasure ν] in
theorem toInclusive_timeUpperCost (S : RawScheduledStrategy B a w δ hδ Ξ ν) (c : ℝ) :
    (S.toInclusive B a w δ hδ ν).timeUpperCost B a w δ hδ ν c =
      S.timeUpperCost B a w δ hδ ν c := rfl

end RawScheduledStrategy
end
end LCSS
