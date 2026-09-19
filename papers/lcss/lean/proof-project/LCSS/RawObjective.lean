import LCSS.RawPolicy
import LCSS.TimeIntegral

/-! The physical objective uses raw functions throughout. Only fixed-time
expected costs are transported to L²; Tonelli supplies the time interchange. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)

namespace RawRealization

theorem expected_integrated_raw_loss (w : ι → ℝ) (hw : ∀ m, 0 ≤ w m)
    {τ : Measure ℝ} [SFinite τ]
    (u : ℝ → (m : ι) → Fin (p m).n → Ω → ℝ)
    (v : ℝ → (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ t m i, u t m i =ᵐ[μ] (v t m i : Ω → ℝ))
    (hj : AEMeasurable (fun z : ℝ × Ω => B.realizedLoss w z.1 (u z.1) z.2) (τ.prod μ)) :
    (∫⁻ ω, ∫⁻ t, B.realizedLoss w t (u t) ω ∂τ ∂μ) =
      ∫⁻ t, ENNReal.ofReal (D.totalLoss w t (v t)) ∂τ := by
  rw [expected_integrated_loss _ hj]
  apply lintegral_congr
  intro t
  exact B.expected_realizedLoss w hw t (u t) (v t) (hu t)

end RawRealization

namespace PhysicalSchedule

theorem lintegral_phases (Q : PhysicalSchedule) (δ : ℝ) (hδ : 0 ≤ δ)
    (R : ℝ) (f : ℝ → ℝ≥0∞) :
    (∫⁻ x in Ioc 0 (Q.trace δ hδ R).initial, f x) +
    (∑ j : Fin (Q.count (R-δ)), ∫⁻ x in Ioc 0 ((Q.trace δ hδ R).duration j),
      f ((Q.trace δ hδ R).reception j+x)) = ∫⁻ t in Ioc 0 R, f t := by
  rw [Q.trace_initial]
  have hj (j : Fin (Q.count (R-δ))) :
      (∫⁻ x in Ioc 0 ((Q.trace δ hδ R).duration j), f ((Q.trace δ hδ R).reception j+x)) =
      ∫⁻ t in Ioc (Q.boundary δ R j.castSucc) (Q.boundary δ R j.succ), f t := by
    have hr : (Q.trace δ hδ R).reception j = Q.boundary δ R j.castSucc := by
      rw [Q.trace_reception]
      simp [PhysicalSchedule.boundary, j.isLt]
    rw [hr]
    exact lintegral_translate_Ioc f _ _
  simp only [hj]
  rw [lintegral_Ioc_chain f _ (Q.boundary_mono δ R) (Q.boundary_nonneg hδ R 0), Q.boundary_last]
  by_cases hR : 0 ≤ R
  · rw [max_eq_left hR]
  · simp [max_eq_right (le_of_not_ge hR), Set.Ioc_eq_empty_of_le (le_of_not_ge hR)]

end PhysicalSchedule

/-- One raw action path per independent schedule seed. The analytic fields
are only measurability of losses and counts, never values or bounds of costs.
The two phase fields allow the same weak loss regularity as ScheduledStrategy. -/
structure RawScheduledStrategy (a : AgentCoordinates p) (w : ι → ℝ)
    (δ : ℝ) (hδ : 0 ≤ δ) (Ξ : Type*) [MeasurableSpace Ξ] (ν : Measure Ξ) where
  schedule : Ξ → PhysicalSchedule
  policy : (ξ : Ξ) → RawScheduledPolicy B a (schedule ξ) δ
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

namespace RawScheduledStrategy
variable (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
variable (S : RawScheduledStrategy B a w δ hδ Ξ ν)

def toStrategy : RefreshStrategy D δ Ξ where
  trace ξ R := (S.schedule ξ).trace δ hδ R
  controls ξ R := ((S.policy ξ).toLp B a (S.schedule ξ) δ).toControls D a (S.schedule ξ) δ hδ R

def timeAverage (c R : ℝ) : ℝ≥0∞ :=
  (∫⁻ z : Ξ × Ω, (∫⁻ t in Ioc 0 R,
    B.realizedLoss w t ((S.policy z.1).action t) z.2) +
      ENNReal.ofReal c * (S.schedule z.1).count R ∂ν.prod μ) / ENNReal.ofReal R

def timeUpperCost (c : ℝ) : ℝ≥0∞ := limsup (S.timeAverage B a w δ hδ ν c) atTop

theorem expected_horizon_cost (hw : ∀ m, 0 ≤ w m) (ξ : Ξ) (c R : ℝ) :
    (∫⁻ ω, (∫⁻ t in Ioc 0 R, B.realizedLoss w t ((S.policy ξ).action t) ω) +
      ENNReal.ofReal c * (S.schedule ξ).count R ∂μ) =
      RefreshControls.cost D w δ ((S.toStrategy B a w δ hδ ν).controls ξ R) c := by
  simp_rw [← (S.schedule ξ).lintegral_phases δ hδ R]
  rw [lintegral_add_right _ measurable_const,
    lintegral_add_left' (S.before_measurable ξ R).lintegral_prod_left,
    lintegral_finsetSum' _ (fun j _ => (S.after_measurable ξ R j).lintegral_prod_left)]
  simp only [lintegral_const, measure_univ, mul_one]
  rw [expected_integrated_loss _ (S.before_measurable ξ R)]
  have ha (j : Fin ((S.schedule ξ).count (R-δ))) :=
    expected_integrated_loss (fun x ω =>
      B.realizedLoss w (((S.schedule ξ).trace δ hδ R).reception j+x)
        ((S.policy ξ).action (((S.schedule ξ).trace δ hδ R).reception j+x)) ω)
      (S.after_measurable ξ R j)
  simp only [ha]
  have he (t : ℝ) := B.expected_realizedLoss w hw t ((S.policy ξ).action t)
    (((S.policy ξ).toLp B a (S.schedule ξ) δ).action t)
    (fun m i => (S.policy ξ).action_eq B a (S.schedule ξ) δ t m i)
  simp only [he]
  rfl

theorem timeAverage_eq (hw : ∀ m, 0 ≤ w m) (c R : ℝ) :
    S.timeAverage B a w δ hδ ν c R =
      RefreshStrategy.averageCost D w δ ν c (S.toStrategy B a w δ hδ ν) R := by
  have hn : Measurable (fun z : Ξ × Ω => ENNReal.ofReal c * (S.schedule z.1).count R) := by
    have h : Measurable (fun z : Ξ × Ω => (S.schedule z.1).count R) :=
      (S.count_measurable R).comp measurable_fst
    fun_prop
  unfold timeAverage
  have hj : AEMeasurable (fun z : Ξ × Ω =>
      (∫⁻ t in Ioc 0 R, B.realizedLoss w t ((S.policy z.1).action t) z.2) +
        ENNReal.ofReal c * (S.schedule z.1).count R) (ν.prod μ) :=
    (S.loss_measurable R).add hn.aemeasurable
  rw [lintegral_prod _ hj]
  congr 1
  apply lintegral_congr
  intro ξ
  exact S.expected_horizon_cost B a w δ hδ ν hw ξ c R

theorem timeUpperCost_eq (hw : ∀ m, 0 ≤ w m) (c : ℝ) :
    S.timeUpperCost B a w δ hδ ν c =
      RefreshStrategy.upperCost D w δ ν c (S.toStrategy B a w δ hδ ν) := by
  unfold timeUpperCost RefreshStrategy.upperCost
  congr 1
  funext R
  exact S.timeAverage_eq B a w δ hδ ν hw c R

end RawScheduledStrategy
end
end LCSS
