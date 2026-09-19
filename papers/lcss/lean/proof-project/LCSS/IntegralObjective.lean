import LCSS.Objective
import Mathlib.MeasureTheory.Measure.Prod

/-! The nonnegative integral form of the original quadratic loss and the
Tonelli interchange used to interpret integrated expected costs. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory
open scoped ENNReal BigOperators
variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {n : ℕ}

theorem pointwiseLoss_nonneg {κ : ℝ} (hκ : 0 ≤ κ) (X : Ω → ℝ)
    (u : Fin n → Ω → ℝ) (ω : Ω) : 0 ≤ pointwiseLoss κ X u ω := by
  apply mul_nonneg (inv_nonneg.mpr (Nat.cast_nonneg n))
  exact add_nonneg (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
    (mul_nonneg hκ (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))

theorem pointwiseLoss_integrable (κ : ℝ) (X : RV (μ := μ)) (u : Fin n → RV (μ := μ)) :
    Integrable (fun ω => pointwiseLoss κ X (fun i => u i) ω) μ := by
  have ht (i : Fin n) : Integrable (fun ω => (u i ω-X ω)^2) μ := by
    apply (integrable_sq (u i-X)).congr
    filter_upwards [Lp.coeFn_sub (u i) X] with ω h
    simp only [Pi.sub_apply] at h
    rw [h]
  have hd (i : Fin n) : Integrable
      (fun ω => (u i ω-(n : ℝ)⁻¹*∑ j, u j ω)^2) μ := by
    apply (integrable_sq (u i-average u)).congr
    filter_upwards [Lp.coeFn_sub (u i) (average u), average_ae u] with ω h ha
    simp only [Pi.sub_apply] at h
    rw [h, ha]
  exact ((integrable_finsetSum _ (fun i _ => ht i)).add
    ((integrable_finsetSum _ (fun i _ => hd i)).const_mul κ)).const_mul (n : ℝ)⁻¹

theorem expectedLoss_ofReal {κ : ℝ} (hκ : 0 ≤ κ) (X : RV (μ := μ))
    (u : Fin n → RV (μ := μ)) : ENNReal.ofReal (expectedLoss κ X u) =
      ∫⁻ ω, ENNReal.ofReal (pointwiseLoss κ X (fun i => u i) ω) ∂μ := by
  exact ofReal_integral_eq_lintegral_ofReal (pointwiseLoss_integrable κ X u)
    (Filter.Eventually.of_forall (pointwiseLoss_nonneg hκ X (fun i => u i)))

/-- On any time interval, expected integrated loss equals integrated expected
loss for every jointly measurable nonnegative loss; infinite values are allowed. -/
theorem expected_integrated_loss {ν : Measure ℝ} [SFinite ν]
    (loss : ℝ → Ω → ℝ≥0∞)
    (h : AEMeasurable (Function.uncurry loss) (ν.prod μ)) :
    (∫⁻ ω, ∫⁻ t, loss t ω ∂ν ∂μ) = ∫⁻ t, ∫⁻ ω, loss t ω ∂μ ∂ν := by
  exact (lintegral_lintegral_swap h).symm

end
end LCSS
