import LCSS.ScheduledPolicy
import Mathlib.MeasureTheory.Group.MeasurableEquiv
import Mathlib.MeasureTheory.Group.Measure

/-! The finite phase sum is exactly the integral over the whole horizon.
These nonnegative change-of-variable and partition identities need no
integrability hypothesis and do not discard infinite costs. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology

theorem lintegral_translate_Ioc (f : ℝ → ℝ≥0∞) (a b : ℝ) :
    (∫⁻ x in Ioc 0 (b-a), f (a+x)) = ∫⁻ t in Ioc a b, f t := by
  have he : (fun x : ℝ => a+x) ⁻¹' Ioc a b = Ioc 0 (b-a) := by
    ext x
    simp only [mem_preimage, mem_Ioc]
    constructor <;> rintro ⟨h₁,h₂⟩ <;> constructor <;> linarith
  simpa only [he] using (measurePreserving_add_left volume a).setLIntegral_comp_preimage_emb
    (MeasurableEquiv.addLeft a).measurableEmbedding f (Ioc a b)

theorem lintegral_Ioc_split (f : ℝ → ℝ≥0∞) {a b c : ℝ} (hab : a ≤ b) (hbc : b ≤ c) :
    (∫⁻ t in Ioc a b, f t) + (∫⁻ t in Ioc b c, f t) = ∫⁻ t in Ioc a c, f t := by
  rw [← Ioc_union_Ioc_eq_Ioc hab hbc, lintegral_union measurableSet_Ioc]
  exact Set.disjoint_left.mpr (by intro x hx hy; exact (not_lt_of_ge hx.2) hy.1)

theorem lintegral_Ioc_chain (f : ℝ → ℝ≥0∞) {n : ℕ}
    (b : Fin (n+1) → ℝ) (hb : Monotone b) (h₀ : 0 ≤ b 0) :
    (∫⁻ t in Ioc 0 (b 0), f t) +
      (∑ j : Fin n, ∫⁻ t in Ioc (b j.castSucc) (b j.succ), f t) =
        ∫⁻ t in Ioc 0 (b (Fin.last n)), f t := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Fin.sum_univ_castSucc, ← add_assoc]
    have hi := ih (fun j => b j.castSucc) (hb.comp (by intro i j hij; exact hij)) h₀
    simp only [Fin.castSucc_zero, Fin.castSucc_succ] at hi
    rw [hi]
    apply lintegral_Ioc_split f
    · exact h₀.trans (hb (Fin.zero_le _))
    · exact hb (Fin.le_last _)

namespace ScheduledStrategy
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
variable (S : ScheduledStrategy D a w δ hδ Ξ ν)

theorem accumulatedLoss_eq (ξ : Ξ) (R : ℝ) (ω : Ω) :
    ((S.toMeasured D a w δ hδ ν).controls ξ R).accumulatedLoss D w δ ω =
      ∫⁻ t in Ioc 0 R, D.realizedLoss w t ((S.policy ξ).action t) ω := by
  let Q := S.schedule ξ
  let f := fun t => D.realizedLoss w t ((S.policy ξ).action t) ω
  change (∫⁻ x in Ioc 0 (Q.trace δ hδ R).initial, f x) +
    (∑ j : Fin (Q.count (R-δ)),
      ∫⁻ x in Ioc 0 ((Q.trace δ hδ R).duration j),
        f ((Q.trace δ hδ R).reception j+x)) = _
  rw [Q.trace_initial]
  have hj (j : Fin (Q.count (R-δ))) :
      (∫⁻ x in Ioc 0 ((Q.trace δ hδ R).duration j),
        f ((Q.trace δ hδ R).reception j+x)) =
      ∫⁻ t in Ioc (Q.boundary δ R j.castSucc) (Q.boundary δ R j.succ), f t := by
    have hr : (Q.trace δ hδ R).reception j = Q.boundary δ R j.castSucc := by
      rw [Q.trace_reception]
      simp [PhysicalSchedule.boundary, j.isLt]
    rw [hr]
    exact lintegral_translate_Ioc f _ _
  simp only [hj]
  rw [lintegral_Ioc_chain f _ (Q.boundary_mono δ R) (Q.boundary_nonneg hδ R 0),
    Q.boundary_last]
  by_cases hR : 0 ≤ R
  · rw [max_eq_left hR]
  · simp [max_eq_right (le_of_not_ge hR), Set.Ioc_eq_empty_of_le (le_of_not_ge hR)]

/-- The paper-shaped objective: first integrate in physical time, then take
expectation over independent schedule seed and sensor outcome, then limsup. -/
def timeAverage (c R : ℝ) : ℝ≥0∞ :=
  (∫⁻ z : Ξ × Ω, (∫⁻ t in Ioc 0 R,
    D.realizedLoss w t ((S.policy z.1).action t) z.2) +
      ENNReal.ofReal c * (S.schedule z.1).count R ∂ν.prod μ) / ENNReal.ofReal R

def timeUpperCost (c : ℝ) : ℝ≥0∞ := limsup (S.timeAverage D a w δ hδ ν c) atTop

theorem timeUpperCost_eq (c : ℝ) :
    S.timeUpperCost D a w δ hδ ν c =
      (S.toMeasured D a w δ hδ ν).physicalUpperCost D w δ ν c := by
  unfold timeUpperCost MeasuredRefreshStrategy.physicalUpperCost
  congr 1
  funext R
  unfold timeAverage MeasuredRefreshStrategy.physicalAverage
  congr 1
  apply lintegral_congr
  intro z
  rw [← S.accumulatedLoss_eq D a w δ hδ ν z.1 R z.2]
  rfl

end ScheduledStrategy

theorem theorem2_time_integrated_lower_bounds
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
    (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
    (w : ι → ℝ) (hw : ∀ m, 0 < w m) (δ : ℝ) (hδ : 0 ≤ δ)
    {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (c : ℝ) (hc : 0 < c) (S : ScheduledStrategy D a w δ hδ Ξ ν) :
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ENNReal.ofReal (RefreshMixture.baseline p w) ≤ S.timeUpperCost D a w δ hδ ν c) ∧
    (∀ T : ℝ, 0 < T → (RefreshMixture.ofParameters p w hw δ).marginal T = c →
      ENNReal.ofReal (RefreshMixture.baseline p w -
        (RefreshMixture.ofParameters p w hw δ).value T) ≤ S.timeUpperCost D a w δ hδ ν c) := by
  rw [S.timeUpperCost_eq D a w δ hδ ν]
  exact theorem2_scheduled_lower_bounds D a w hw δ hδ ν c hc S

end
end LCSS
