import TinaV2.Defs
import TinaV2.Routine.Regret

/-! # Routine facts for the no-information loss (claim C6.b)

What the supplement proof of Eq. (Rinf_general) leaves unsaid when it takes the
expectation of `cᵀQx⋆` and of `θᵀAθ`:

* the coordinates of a square-integrable vector are integrable;
* a constant vector moves out of the expectation of a dot product;
* the quadratic form and the trace of a product written out in coordinates;
* the expectation of the quadratic form is the finite sum of the expectations
  of its terms.

Nothing here is a step of a paper proof. This file imports `Defs/` and
`Routine/Regret` only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory

variable {Ω : Type} [MeasurableSpace Ω] {κ : Type} [Fintype κ]

/-- Each coordinate of a square-integrable vector is integrable. -/
theorem integrable_apply_of_memLp {μ : Measure Ω} [IsFiniteMeasure μ] {X : Ω → κ → ℝ}
    (hX : MemLp X 2 μ) (k : κ) : Integrable (fun ω => X ω k) μ :=
  (memLp_pi_iff.1 hX k).integrable one_le_two

/-- `E[wᵀX] = wᵀE[X]` for a constant vector `w`. -/
theorem integral_const_dotProduct {μ : Measure Ω} [IsFiniteMeasure μ] (w : κ → ℝ)
    {X : Ω → κ → ℝ} (hX : MemLp X 2 μ) :
    ∫ ω, w ⬝ᵥ X ω ∂μ = w ⬝ᵥ fun k => ∫ ω, X ω k ∂μ := by
  simp only [dotProduct]
  rw [integral_finsetSum _ fun k _ => (integrable_apply_of_memLp hX k).const_mul _]
  exact Finset.sum_congr rfl fun k _ => integral_const_mul _ _

/-- `vᵀAv = Σ_k Σ_l A_kl v_k v_l`. -/
theorem quad_eq_sum_sum (A : Matrix κ κ ℝ) (v : κ → ℝ) :
    quad A v = ∑ k, ∑ l, A k l * (v k * v l) := by
  simp only [quad, dotProduct, mulVec, Finset.mul_sum]
  exact Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun l _ => by ring

/-- `tr(AS) = Σ_k Σ_l A_kl S_lk`. -/
theorem trace_mul_eq_sum_sum (A S : Matrix κ κ ℝ) :
    Matrix.trace (A * S) = ∑ k, ∑ l, A k l * S l k := by
  simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply]

/-- `E[XᵀAX] = Σ_k Σ_l A_kl E[X_k X_l]`: the finite sums move out of the
expectation. -/
theorem integral_quad_eq_sum_sum {μ : Measure Ω} (A : Matrix κ κ ℝ) {X : Ω → κ → ℝ}
    (hX : MemLp X 2 μ) :
    ∫ ω, quad A (X ω) ∂μ = ∑ k, ∑ l, A k l * ∫ ω, X ω k * X ω l ∂μ := by
  have hi : ∀ k l, Integrable (fun ω => A k l * (X ω k * X ω l)) μ := fun k l =>
    ((memLp_pi_iff.1 hX k).integrable_mul (memLp_pi_iff.1 hX l)).const_mul _
  simp only [quad_eq_sum_sum]
  rw [integral_finsetSum _ fun k _ => integrable_finsetSum _ fun l _ => hi k l]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [integral_finsetSum _ fun l _ => hi k l]
  exact Finset.sum_congr rfl fun l _ => integral_const_mul _ _

end TinaV2
