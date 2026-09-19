import LCSS.Parameters
import LCSS.Team
import LCSS.Gaussian
import Mathlib.Tactic.LinearCombination

set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace

def kernel (rate t r : ℝ) : ℝ := Real.exp (-rate * |t-r|)
@[simp] theorem kernel_self (rate t : ℝ) : kernel rate t t = 1 := by simp [kernel]
theorem kernel_symm (rate t r : ℝ) : kernel rate t r = kernel rate r t := by
  simp [kernel, abs_sub_comm]
theorem kernel_comp (rate : ℝ) {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t) :
    kernel rate t r = kernel rate t s * kernel rate s r := by
  simp only [kernel, abs_of_nonneg (sub_nonneg.mpr hrs),
    abs_of_nonneg (sub_nonneg.mpr hst), abs_of_nonneg (sub_nonneg.mpr (hrs.trans hst))]
  rw [← Real.exp_add]
  congr 1
  ring

abbrev SourceIndex (n : ℕ) := Option (Fin n) × ℝ
def spatial (p : Parameters) : Option (Fin p.n) → Option (Fin p.n) → ℝ
  | some i, some j => p.a + if i = j then p.b else 0
  | _, _ => p.a

variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Centered jointly Gaussian signal and sensors with the covariance kernel
obtained from X and independent sensor errors in equation (1). The `none`
coordinate is X; `some i` is Yᵢ. Inner products are second moments in L². -/
structure SensorModel (p : Parameters) where
  source : SourceIndex p.n → RV (μ := μ)
  gaussian : IsGaussianProcess (fun q => (source q : Ω → ℝ)) μ
  centered : ∀ q, ∫ ω, source q ω ∂μ = 0
  secondMoment : ∀ c d t r,
    ⟪source (c,t), source (d,r)⟫_ℝ = spatial p c d * kernel p.rate t r

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)
abbrev X (t : ℝ) := M.source (none,t)
abbrev Y (t : ℝ) (i : Fin p.n) := M.source (some i,t)
def pool (t : ℝ) := average (M.Y t)
def innovation (s t : ℝ) (i : Fin p.n) := M.Y t i - kernel p.rate t s • M.Y s i
def prediction (s t : ℝ) := (kernel p.rate t s * (p.a / p.v)) • M.pool s
def hybrid (s t : ℝ) (i : Fin p.n) := M.prediction s t + (p.a / p.d) • M.innovation s t i
def posterior (s t : ℝ) (i : Fin p.n) :=
  M.prediction s t + (p.a / (p.a + p.b)) • M.innovation s t i

@[simp] theorem inner_X_Y (t r : ℝ) (i : Fin p.n) :
    ⟪M.X t, M.Y r i⟫_ℝ = p.a * kernel p.rate t r := M.secondMoment _ _ _ _
@[simp] theorem inner_Y_X (t r : ℝ) (i : Fin p.n) :
    ⟪M.Y t i, M.X r⟫_ℝ = p.a * kernel p.rate t r := M.secondMoment _ _ _ _
@[simp] theorem inner_Y_Y (t r : ℝ) (i j : Fin p.n) :
    ⟪M.Y t i, M.Y r j⟫_ℝ =
      (p.a + if i = j then p.b else 0) * kernel p.rate t r := M.secondMoment _ _ _ _
@[simp] theorem norm_X_sq (t : ℝ) : ‖M.X t‖ ^ 2 = p.a := by
  rw [← real_inner_self_eq_norm_sq, M.secondMoment]
  simp [spatial]

theorem inner_pool_Y (t r : ℝ) (i : Fin p.n) :
    ⟪M.pool t, M.Y r i⟫_ℝ = p.v * kernel p.rate t r := by
  classical
  simp only [pool, average, real_inner_smul_left, sum_inner, M.inner_Y_Y]
  simp only [add_mul, Finset.sum_add_distrib, ← Finset.sum_mul]
  simp [Parameters.v]
  field_simp [p.n_ne]
  <;> ring

theorem inner_pool_X (t r : ℝ) :
    ⟪M.pool t, M.X r⟫_ℝ = p.a * kernel p.rate t r := by
  simp [pool, average, real_inner_smul_left, sum_inner, p.n_ne]

theorem inner_prediction_Y (s t r : ℝ) (j : Fin p.n) :
    ⟪M.prediction s t, M.Y r j⟫_ℝ =
      kernel p.rate t s * p.a * kernel p.rate s r := by
  rw [prediction, real_inner_smul_left, M.inner_pool_Y]
  field_simp [ne_of_gt p.v_pos]

theorem inner_innovation_Y (s t r : ℝ) (i j : Fin p.n) :
    ⟪M.innovation s t i, M.Y r j⟫_ℝ =
      (p.a + if i = j then p.b else 0) *
        (kernel p.rate t r - kernel p.rate t s * kernel p.rate s r) := by
  simp [innovation, inner_sub_left, real_inner_smul_left]
  ring

theorem inner_hybrid_Y (s t r : ℝ) (i j : Fin p.n) :
    ⟪M.hybrid s t i, M.Y r j⟫_ℝ =
      kernel p.rate t s * p.a * kernel p.rate s r +
      (p.a / p.d) * (p.a + if i = j then p.b else 0) *
        (kernel p.rate t r - kernel p.rate t s * kernel p.rate s r) := by
  simp only [hybrid, inner_add_left, real_inner_smul_left,
    M.inner_prediction_Y, M.inner_innovation_Y]
  ring

theorem inner_average_hybrid_Y (s t r : ℝ) (j : Fin p.n) :
    ⟪average (M.hybrid s t), M.Y r j⟫_ℝ =
      kernel p.rate t s * p.a * kernel p.rate s r +
      (p.a / p.d) * p.v *
        (kernel p.rate t r - kernel p.rate t s * kernel p.rate s r) := by
  classical
  simp only [average, real_inner_smul_left, sum_inner, M.inner_hybrid_Y,
    Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
  simp [Parameters.v, Finset.sum_add_distrib]
  field_simp [p.n_ne]
  <;> ring

/-- The team optimality residual is uncorrelated with the entire local
sensor process, not merely its current sample. -/
theorem gradient_orthogonal_local (s t r : ℝ) (i : Fin p.n) :
    ⟪gradient p.κ (M.X t) (M.hybrid s t) i, M.Y r i⟫_ℝ = 0 := by
  simp only [gradient, inner_sub_left, real_inner_smul_left,
    M.inner_hybrid_Y, M.inner_average_hybrid_Y, M.inner_X_Y, ite_true]
  have hd := p.normal_identity
  field_simp [ne_of_gt p.d_pos]
  linear_combination p.a * (kernel p.rate t r - kernel p.rate t s * kernel p.rate s r) * hd

/-- The same residual is uncorrelated with every sensor at every delayed
history time. This is the causal full-history step. -/
theorem gradient_orthogonal_past {s t r : ℝ} (hst : s ≤ t) (hrs : r ≤ s)
    (i j : Fin p.n) :
    ⟪gradient p.κ (M.X t) (M.hybrid s t) i, M.Y r j⟫_ℝ = 0 := by
  simp only [gradient, inner_sub_left, real_inner_smul_left,
    M.inner_hybrid_Y, M.inner_average_hybrid_Y, M.inner_X_Y]
  rw [kernel_comp p.rate hrs hst]
  ring

theorem posterior_residual_orthogonal_local (s t r : ℝ) (i : Fin p.n) :
    ⟪M.X t - M.posterior s t i, M.Y r i⟫_ℝ = 0 := by
  simp only [posterior, inner_sub_left, inner_add_left, real_inner_smul_left,
    M.inner_X_Y, M.inner_prediction_Y, M.inner_innovation_Y, ite_true]
  field_simp [ne_of_gt (add_pos p.ha p.hb)]
  ring

theorem posterior_residual_orthogonal_past {s t r : ℝ} (hst : s ≤ t) (hrs : r ≤ s)
    (i j : Fin p.n) :
    ⟪M.X t - M.posterior s t i, M.Y r j⟫_ℝ = 0 := by
  simp only [posterior, inner_sub_left, inner_add_left, real_inner_smul_left,
    M.inner_X_Y, M.inner_prediction_Y, M.inner_innovation_Y]
  rw [kernel_comp p.rate hrs hst]
  ring

end SensorModel
end
end LCSS
