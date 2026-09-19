import LCSS.Components

/-! Discrete pooled snapshots and additive coordination value. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

def snapshotInfo (s t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  M.localInfo t i ⊔ MeasurableSpace.comap (M.pool s) inferInstance

theorem hybrid_snapshot_feasible {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.hybrid s t i ∈ informationSpace (μ := μ) (M.snapshotInfo s t i) := by
  have hlocal : informationSpace (μ := μ) (M.localInfo t i) ≤
      informationSpace (μ := μ) (M.snapshotInfo s t i) := informationSpace_mono le_sup_left
  have hnow := hlocal (history_mem (fun r : Set.Iic t => M.Y r i) ⟨t, by simp⟩)
  have hthen := hlocal (history_mem (fun r : Set.Iic t => M.Y r i) ⟨s,hst⟩)
  have hpool : M.pool s ∈ informationSpace (μ := μ) (M.snapshotInfo s t i) := by
    apply mem_lpMeas_iff_aestronglyMeasurable.mpr
    have hm : Measurable[M.snapshotInfo s t i] (M.pool s : Ω → ℝ) :=
      (comap_measurable (M.pool s)).mono le_sup_right le_rfl
    exact hm.stronglyMeasurable.aestronglyMeasurable
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hpool)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hnow
      ((informationSpace _).smul_mem _ hthen)))

end SensorModel

namespace RefreshMixture
variable {ι : Type*} [Fintype ι] [Nonempty ι]

def ofParameters (p : ι → Parameters) (w : ι → ℝ) (hw : ∀ m, 0 < w m) (δ : ℝ) : RefreshMixture ι where
  amplitude m := w m*(p m).delta*Real.exp (-2*(p m).rate*δ)
  rate m := 2*(p m).rate
  amplitude_pos m := mul_pos (mul_pos (hw m) (p m).delta_pos) (Real.exp_pos _)
  rate_pos m := mul_pos (by norm_num) (p m).hrate

def baseline (p : ι → Parameters) (w : ι → ℝ) : ℝ := ∑ m, w m*(p m).localCost

theorem baseline_ge_value (p : ι → Parameters) (w : ι → ℝ) (hw : ∀ m, 0 < w m)
    {δ : ℝ} (hδ : 0 ≤ δ) :
    (ofParameters p w hw δ).value 0 ≤ baseline p w := by
  apply Finset.sum_le_sum
  intro m _
  have hp : 0 ≤ (p m).pooledCost := by
    rw [(p m).pooledCost_eq_variance]
    exact div_nonneg (mul_nonneg (p m).ha.le (p m).hb.le)
      (add_nonneg (p m).hb.le (mul_nonneg (Nat.cast_nonneg _) (p m).ha.le))
  have hd : (p m).delta ≤ (p m).localCost := by dsimp [Parameters.delta]; linarith
  have he : Real.exp (-2*(p m).rate*δ) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    nlinarith [(p m).hrate]
  have h := mul_le_mul_of_nonneg_left he (mul_nonneg (hw m).le (p m).delta_pos.le)
  simp only [ofParameters, mul_zero, Real.exp_zero, mul_one] at *
  exact h.trans (mul_le_mul_of_nonneg_left hd (hw m).le)

theorem value_le_initial (q : RefreshMixture ι) {x : ℝ} (hx : 0 ≤ x) : q.value x ≤ q.value 0 := by
  apply Finset.sum_le_sum
  intro i _
  simp only [mul_zero, Real.exp_zero, mul_one]
  have he : Real.exp (-q.rate i*x) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    nlinarith [q.rate_pos i]
  simpa using mul_le_mul_of_nonneg_left he (q.amplitude_pos i).le

theorem running_nonneg (q : RefreshMixture ι) {baseline x : ℝ}
    (hb : q.value 0 ≤ baseline) (hx : 0 ≤ x) : 0 ≤ baseline-q.value x :=
  sub_nonneg.mpr ((q.value_le_initial hx).trans hb)

theorem interval_running_nonneg (q : RefreshMixture ι) {baseline T : ℝ}
    (hb : q.value 0 ≤ baseline) (hT : 0 ≤ T) : 0 ≤ baseline*T-q.benefit T := by
  have h := q.benefit_tangent 0 T
  simp only [q.benefit_zero, sub_zero, zero_add] at h
  nlinarith

end RefreshMixture

namespace PaperComponents
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p)

theorem totalLoss_nonneg (w : ι → ℝ) (hw : ∀ m, 0 ≤ w m) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ)) : 0 ≤ D.totalLoss w t u := by
  apply Finset.sum_nonneg
  intro m _
  rw [expectedLoss_eq_teamCost]
  exact mul_nonneg (hw m) (teamCost_nonneg (p m).hκ _ _)

theorem total_hybrid_cost (w : ι → ℝ) (hw : ∀ m, 0 < w m)
    (r δ x : ℝ) (hδ : 0 ≤ δ) (hx : 0 ≤ x) :
    D.totalLoss w (r+x) (fun m => (D.sensor m).hybrid (r-δ) (r+x)) =
      RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value x := by
  have he (m : ι) : expectedLoss (p m).κ ((D.sensor m).X (r+x))
      ((D.sensor m).hybrid (r-δ) (r+x)) =
      (p m).localCost-(p m).delta*Real.exp (-2*(p m).rate*(δ+x)) := by
    have ht : r-δ = (r+x)-(δ+x) := by ring
    rw [ht, expectedLoss_eq_teamCost, (D.sensor m).hybrid_cost_age (r+x) (δ+x) (add_nonneg hδ hx)]
    have h := (p m).exponential_value (δ+x)
    dsimp [Parameters.delta] at *
    linarith
  simp only [totalLoss, he, RefreshMixture.baseline, RefreshMixture.value,
    RefreshMixture.ofParameters, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro m _
  rw [mul_add, Real.exp_add]
  ring

/-- The scalar age cost is derived from the Gaussian team and bounds every
nonlinear policy using the enlarged componentwise history information. -/
theorem running_lower_bound (w : ι → ℝ) (hw : ∀ m, 0 < w m)
    (r δ x : ℝ) (hδ : 0 ≤ δ) (hx : 0 ≤ x)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ m i, u m i ∈ informationSpace (μ := μ) (D.info m (r-δ) (r+x) i)) :
    RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value x ≤
      D.totalLoss w (r+x) u := by
  rw [← D.total_hybrid_cost w hw r δ x hδ hx]
  exact D.total_minimal w (fun m => (hw m).le) (by linarith) u hu

end PaperComponents
end
end LCSS
