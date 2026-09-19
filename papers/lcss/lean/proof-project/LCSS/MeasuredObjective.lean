import LCSS.Theorem2

/-! An actual expectation of accumulated pointwise team loss. Joint
measurability is explicit; Tonelli is applied in the proof, not just imported.
All integrals are nonnegative and may be infinite. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Filter Set
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

namespace PaperComponents
variable (D : PaperComponents (μ := μ) ι p)

def realizedLoss (w : ι → ℝ) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ)) (ω : Ω) : ℝ≥0∞ :=
  ∑ m, ENNReal.ofReal (w m) *
    ENNReal.ofReal (pointwiseLoss (p m).κ ((D.sensor m).X t) (fun i => u m i) ω)

theorem measurable_realizedLoss (w : ι → ℝ) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ)) :
    Measurable (D.realizedLoss w t u) := by
  apply Finset.measurable_sum
  intro m _
  apply Measurable.const_mul
  apply Measurable.ennreal_ofReal
  unfold pointwiseLoss
  have hX := (Lp.stronglyMeasurable ((D.sensor m).X t)).measurable
  have hu (i : Fin (p m).n) := (Lp.stronglyMeasurable (u m i)).measurable
  fun_prop

theorem integral_realizedLoss (w : ι → ℝ) (hw : ∀ m, 0 ≤ w m) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ)) :
    (∫⁻ ω, D.realizedLoss w t u ω ∂μ) = ENNReal.ofReal (D.totalLoss w t u) := by
  unfold realizedLoss totalLoss
  rw [ENNReal.ofReal_sum_of_nonneg (fun m _ => mul_nonneg (hw m)
    (by rw [expectedLoss_eq_teamCost]; exact teamCost_nonneg (p m).hκ _ _))]
  rw [lintegral_finsetSum]
  · apply Finset.sum_congr rfl
    intro m _
    rw [lintegral_const_mul' _ _ ENNReal.ofReal_ne_top,
      ← expectedLoss_ofReal (p m).hκ, ENNReal.ofReal_mul (hw m)]
  · intro m _
    have hm : Measurable (fun ω => ENNReal.ofReal
        (pointwiseLoss (p m).κ ((D.sensor m).X t) (fun i => u m i) ω)) := by
      apply Measurable.ennreal_ofReal
      unfold pointwiseLoss
      have hX := (Lp.stronglyMeasurable ((D.sensor m).X t)).measurable
      have hu (i : Fin (p m).n) := (Lp.stronglyMeasurable (u m i)).measurable
      fun_prop
    exact hm.const_mul _

end PaperComponents

structure MeasuredRefreshControls (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ)
    (δ : ℝ) {R : ℝ} (s : RefreshTrace R) where
  controls : RefreshControls D δ s
  before_measurable : AEMeasurable
    (Function.uncurry (fun x ω => D.realizedLoss w x (controls.before x) ω))
    ((volume.restrict (Ioc 0 s.initial)).prod μ)
  after_measurable : ∀ j, AEMeasurable
    (Function.uncurry (fun x ω => D.realizedLoss w (s.reception j+x) (controls.after j x) ω))
    ((volume.restrict (Ioc 0 (s.duration j))).prod μ)

namespace MeasuredRefreshControls
variable (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ) (δ : ℝ)
variable {R : ℝ} {s : RefreshTrace R} (u : MeasuredRefreshControls D w δ s)

def accumulatedLoss (ω : Ω) : ℝ≥0∞ :=
  (∫⁻ x in Ioc 0 s.initial, D.realizedLoss w x (u.controls.before x) ω) +
  ∑ j, ∫⁻ x in Ioc 0 (s.duration j),
    D.realizedLoss w (s.reception j+x) (u.controls.after j x) ω

theorem accumulatedLoss_aemeasurable : AEMeasurable (u.accumulatedLoss D w δ) μ :=
by
  apply u.before_measurable.lintegral_prod_left.add
  exact Finset.aemeasurable_fun_sum Finset.univ
    (fun j _ => (u.after_measurable j).lintegral_prod_left)

def physicalCost (c : ℝ) : ℝ≥0∞ :=
  ∫⁻ ω, u.accumulatedLoss D w δ ω + ENNReal.ofReal c*s.sent ∂μ

theorem physicalCost_eq (hw : ∀ m, 0 ≤ w m) (c : ℝ) :
    u.physicalCost D w δ c = RefreshControls.cost D w δ u.controls c := by
  unfold physicalCost accumulatedLoss
  rw [lintegral_add_right _ measurable_const, lintegral_add_left'
    u.before_measurable.lintegral_prod_left,
    lintegral_finsetSum' _ (fun j _ => (u.after_measurable j).lintegral_prod_left)]
  simp only [lintegral_const, measure_univ, mul_one]
  rw [expected_integrated_loss _ u.before_measurable]
  have ha (j : Fin s.received) := expected_integrated_loss _ (u.after_measurable j)
  simp only [ha, D.integral_realizedLoss w hw, RefreshControls.cost]

end MeasuredRefreshControls

structure MeasuredRefreshStrategy (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ)
    (δ : ℝ) (Ξ : Type*) [MeasurableSpace Ξ] (ν : Measure Ξ) where
  trace : Ξ → (R : ℝ) → RefreshTrace R
  controls : (ξ : Ξ) → (R : ℝ) → MeasuredRefreshControls D w δ (trace ξ R)
  loss_measurable : ∀ R, AEMeasurable
    (fun z : Ξ × Ω => (controls z.1 R).accumulatedLoss D w δ z.2) (ν.prod μ)
  count_measurable : ∀ R, Measurable (fun ξ => (trace ξ R).sent)

namespace MeasuredRefreshStrategy
variable (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ) (δ : ℝ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
variable (S : MeasuredRefreshStrategy D w δ Ξ ν)

def toStrategy : RefreshStrategy D δ Ξ where
  trace := S.trace
  controls ξ R := (S.controls ξ R).controls

def physicalAverage (c R : ℝ) : ℝ≥0∞ :=
  (∫⁻ z : Ξ × Ω, (S.controls z.1 R).accumulatedLoss D w δ z.2 +
    ENNReal.ofReal c * (S.trace z.1 R).sent ∂ν.prod μ) / ENNReal.ofReal R

def physicalUpperCost (c : ℝ) : ℝ≥0∞ :=
  limsup (S.physicalAverage D w δ ν c) atTop

theorem physicalAverage_eq (hw : ∀ m, 0 ≤ w m) (c R : ℝ) :
    S.physicalAverage D w δ ν c R =
      RefreshStrategy.averageCost D w δ ν c (S.toStrategy D w δ ν) R := by
  have hn : Measurable (fun z : Ξ × Ω => ENNReal.ofReal c * (S.trace z.1 R).sent) := by
    have h : Measurable (fun z : Ξ × Ω => (S.trace z.1 R).sent) :=
      (S.count_measurable R).comp measurable_fst
    fun_prop
  unfold physicalAverage
  have hj : AEMeasurable (fun z : Ξ × Ω =>
      (S.controls z.1 R).accumulatedLoss D w δ z.2 +
        ENNReal.ofReal c*(S.trace z.1 R).sent) (ν.prod μ) :=
    (S.loss_measurable R).add hn.aemeasurable
  rw [lintegral_prod _ hj]
  congr 1
  apply lintegral_congr
  intro ξ
  exact (S.controls ξ R).physicalCost_eq D w δ (hw := hw) c

theorem physicalUpperCost_eq (hw : ∀ m, 0 ≤ w m) (c : ℝ) :
    S.physicalUpperCost D w δ ν c =
      RefreshStrategy.upperCost D w δ ν c (S.toStrategy D w δ ν) := by
  unfold physicalUpperCost RefreshStrategy.upperCost
  congr 1
  funext R
  exact S.physicalAverage_eq D w δ ν hw c R

end MeasuredRefreshStrategy
end
end LCSS
