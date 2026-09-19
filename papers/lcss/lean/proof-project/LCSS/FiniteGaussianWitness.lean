import LCSS.PaperModel
import Mathlib.Probability.BrownianMotion.GaussianProjectiveFamily

/-! Nonvacuity evidence for every finite subsystem of the unit-variance OU
covariance specification. This constructs actual Gaussian laws; it does NOT
construct the all-real-time PaperModel or assert a projective extension. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal ProbabilityTheory
namespace FiniteGaussianWitness

def clock (rate t : ℝ) : ℝ≥0 := ⟨Real.exp (2*rate*t), (Real.exp_pos _).le⟩

def times (rate : ℝ) (I : Finset ℝ) : Finset ℝ≥0 := I.image (clock rate)

def index (rate : ℝ) (I : Finset ℝ) (t : I) : times rate I :=
  ⟨clock rate t, Finset.mem_image.mpr ⟨t,t.property,rfl⟩⟩

def law (rate : ℝ) (I : Finset ℝ) : Measure (times rate I → ℝ) :=
  BrownianReal.projectiveFamily (times rate I)

def value (rate : ℝ) (I : Finset ℝ) (t : I) (ω : times rate I → ℝ) : ℝ :=
  Real.exp (-rate*t.val) * ω (index rate I t)

theorem probability (rate : ℝ) (I : Finset ℝ) : IsProbabilityMeasure (law rate I) := by
  unfold law
  infer_instance

theorem gaussian (rate : ℝ) (I : Finset ℝ) :
    HasGaussianLaw (fun ω t => value rate I t ω) (law rate I) := by
  let L : (times rate I → ℝ) →L[ℝ] (I → ℝ) := {
    toFun := fun ω t => value rate I t ω
    map_add' := by intro x y; ext t; simp [value, mul_add]
    map_smul' := by intro c x; ext t; simp [value]; ring
    cont := by unfold value; fun_prop }
  letI : IsGaussian (law rate I) := by unfold law; infer_instance
  exact (IsGaussian.hasGaussianLaw_id (μ := law rate I)).map L

theorem centered (rate : ℝ) (I : Finset ℝ) (t : I) :
    (∫ ω, value rate I t ω ∂law rate I) = 0 := by
  simp [value,law,integral_const_mul]

theorem exp_covariance {rate s t : ℝ} (hrate : 0 ≤ rate) :
    Real.exp (-rate*s) * (Real.exp (-rate*t) *
      min (Real.exp (2*rate*s)) (Real.exp (2*rate*t))) = kernel rate s t := by
  unfold kernel
  rcases le_total s t with h | h
  · rw [min_eq_left (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left h (by positivity))),
      abs_of_nonpos (sub_nonpos.mpr h), ← Real.exp_add, ← Real.exp_add]
    congr 1
    ring
  · rw [min_eq_right (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left h (by positivity))),
      abs_of_nonneg (sub_nonneg.mpr h), ← Real.exp_add, ← Real.exp_add]
    congr 1
    ring

theorem covariance (rate : ℝ) (hrate : 0 ≤ rate) (I : Finset ℝ) (s t : I) :
    cov[value rate I s, value rate I t; law rate I] = kernel rate s t := by
  unfold value law
  rw [covariance_const_mul_left, covariance_const_mul_right,
    BrownianReal.covariance_eval_projectiveFamily]
  exact exp_covariance hrate

/-- Concrete finite-dimensional Gaussian consistency, with variance one at
every sampled time. Nonvacuity for the infinite-time model remains open. -/
theorem finite_ou_witness (rate : ℝ) (hrate : 0 < rate) (I : Finset ℝ) :
    IsProbabilityMeasure (law rate I) ∧
      HasGaussianLaw (fun ω t => value rate I t ω) (law rate I) ∧
      (∀ t : I, (∫ ω, value rate I t ω ∂law rate I) = 0) ∧
      (∀ s t : I, cov[value rate I s, value rate I t; law rate I] = kernel rate s t) ∧
      (∀ t : I, cov[value rate I t, value rate I t; law rate I] = 1) := by
  refine ⟨probability rate I, gaussian rate I, centered rate I, covariance rate hrate.le I, ?_⟩
  intro t
  rw [covariance rate hrate.le I, kernel]
  simp

end FiniteGaussianWitness
end
end LCSS
