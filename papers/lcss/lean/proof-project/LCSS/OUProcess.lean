import LCSS.FiniteGaussianWitness
import LCSS.ModelTransport
import BrownianMotion.Gaussian.BrownianMotion

/-! A continuous OU covariance process on all real times, constructed from
Brownian motion by the exponential clock. No stochastic-integral model is used. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal NNReal ProbabilityTheory
namespace OUProcess

abbrev Sample := ℝ≥0 → ℝ
abbrev law : Measure Sample := gaussianLimit
abbrev clock := FiniteGaussianWitness.clock

def value (variance rate t : ℝ) (ω : Sample) : ℝ :=
  Real.sqrt variance * (Real.exp (-rate*t) * brownian (clock rate t) ω)

theorem clock_continuous (rate : ℝ) : Continuous (clock rate) := by
  unfold clock FiniteGaussianWitness.clock
  fun_prop

theorem continuous_path (variance rate : ℝ) (ω : Sample) :
    Continuous (fun t => value variance rate t ω) := by
  have h := (continuous_brownian ω).comp (clock_continuous rate)
  unfold value
  fun_prop

theorem measurable_section (variance rate t : ℝ) : Measurable (value variance rate t) :=
  ((measurable_brownian (clock rate t)).const_mul _).const_mul _

theorem joint_measurable (variance rate : ℝ) :
    Measurable (Function.uncurry (value variance rate)) :=
  measurable_uncurry_of_continuous_of_measurable (continuous_path variance rate)
    (measurable_section variance rate)

theorem gaussian (variance rate : ℝ) : IsGaussianProcess (value variance rate) law := by
  change IsGaussianProcess (fun t ω => Real.sqrt variance *
    (Real.exp (-rate*t) * brownian (clock rate t) ω)) law
  have h := (isGaussianProcess_brownian.comp_right (clock rate)).smul
    (fun t => Real.sqrt variance * Real.exp (-rate*t))
  simpa only [smul_eq_mul, Function.comp_apply, mul_assoc] using h

theorem memLp (variance rate t : ℝ) : MemLp (value variance rate t) (2 : ℝ≥0∞) law :=
  ((gaussian variance rate).hasGaussianLaw_eval t).memLp_two

theorem centered (variance rate t : ℝ) : (∫ ω, value variance rate t ω ∂law) = 0 := by
  have h : (∫ ω, brownian (clock rate t) ω ∂law) = 0 := by
    simpa using (hasLaw_brownian_eval (t := clock rate t)).integral_eq
  simp only [value, integral_const_mul, h, mul_zero]

theorem covariance (variance rate : ℝ) (hv : 0 ≤ variance) (hr : 0 ≤ rate) (s t : ℝ) :
    cov[value variance rate s, value variance rate t; law] = variance * kernel rate s t := by
  unfold value
  rw [covariance_const_mul_left, covariance_const_mul_left,
    covariance_const_mul_right, covariance_const_mul_right, covariance_brownian]
  change Real.sqrt variance * (Real.exp (-rate*s) *
    (Real.sqrt variance * (Real.exp (-rate*t) *
      min (Real.exp (2*rate*s)) (Real.exp (2*rate*t))))) = _
  calc
    _ = (Real.sqrt variance)^2 * (Real.exp (-rate*s) *
        (Real.exp (-rate*t) * min (Real.exp (2*rate*s)) (Real.exp (2*rate*t)))) := by ring
    _ = _ := by rw [Real.sq_sqrt hv, FiniteGaussianWitness.exp_covariance hr]

end OUProcess
end
end LCSS
