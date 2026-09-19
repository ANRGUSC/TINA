import LCSS.Gaussian
import LCSS.Team

/-! Equality with the paper's expected pointwise loss, for every L² policy. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {n : ℕ}

def pointwiseLoss (κ : ℝ) (X : Ω → ℝ) (u : Fin n → Ω → ℝ) (ω : Ω) : ℝ :=
  (n : ℝ)⁻¹ * ((∑ i, (u i ω - X ω)^2) +
    κ * (∑ i, (u i ω - (n : ℝ)⁻¹ * ∑ j, u j ω)^2))

def expectedLoss (κ : ℝ) (X : RV (μ := μ)) (u : Fin n → RV (μ := μ)) : ℝ :=
  ∫ ω, pointwiseLoss κ X (fun i => u i) ω ∂μ

theorem average_ae (u : Fin n → RV (μ := μ)) :
    ((average u : RV (μ := μ)) : Ω → ℝ) =ᵐ[μ] (fun ω => (n : ℝ)⁻¹ * ∑ i, u i ω) := by
  filter_upwards [Lp.coeFn_smul (n : ℝ)⁻¹ (∑ i, u i), Lp.coeFn_fun_finsetSum Finset.univ u]
    with ω h1 h2
  simpa only [average, Pi.smul_apply, smul_eq_mul, h2] using h1

theorem integrable_sq (f : RV (μ := μ)) : Integrable (fun ω => f ω ^ 2) μ := by
  apply (Lp.memLp f).integrable_mul (Lp.memLp f) |>.congr
  filter_upwards [] with ω
  simp [pow_two]

theorem expectedLoss_eq_teamCost (κ : ℝ) (X : RV (μ := μ)) (u : Fin n → RV (μ := μ)) :
    expectedLoss κ X u = teamCost κ X u := by
  have hae : (fun ω => pointwiseLoss κ X (fun i => u i) ω) =ᵐ[μ]
      (fun ω => (n : ℝ)⁻¹ * (∑ i, ((u i-X) ω)^2 + κ * ∑ i, ((u i-average u) ω)^2)) := by
    have hsubX : ∀ᵐ ω ∂μ, ∀ i, (u i-X) ω = u i ω - X ω := by
      rw [ae_all_iff]; intro i; exact Lp.coeFn_sub _ _
    have hsubU : ∀ᵐ ω ∂μ, ∀ i, (u i-average u) ω = u i ω - average u ω := by
      rw [ae_all_iff]; intro i; exact Lp.coeFn_sub _ _
    filter_upwards [hsubX, hsubU, average_ae u] with ω hx hu ha
    simp only [pointwiseLoss, hx, hu, ha]
  rw [expectedLoss, integral_congr_ae hae, integral_const_mul,
    integral_add (integrable_finsetSum _ (fun i _ => integrable_sq (u i-X)))
      ((integrable_finsetSum _ (fun i _ => integrable_sq (u i-average u))).const_mul κ),
    integral_const_mul, integral_finsetSum _ (fun i _ => integrable_sq (u i-X)),
    integral_finsetSum _ (fun i _ => integrable_sq (u i-average u))]
  simp only [integral_sq_eq_norm_sq, teamCost]

end
end LCSS
