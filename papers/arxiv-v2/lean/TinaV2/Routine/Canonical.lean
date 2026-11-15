import TinaV2.Routine.ProcessIntegral
import TinaV2.Routine.CanonicalIntegrals
import TinaV2.Routine.Conditioning

/-! # Routine: regularity of the canonical field

What the paper leaves unsaid about the field of claim C17: its values have
finite second moments, a spatial slice can be integrated against the kernel,
the target `x⋆(z,t)` is a centred random variable with finite second moment,
the observation is measurable, and the regret at a location is `q/2` times the
expected conditional variance of the target given the observation ("There is no
action coupling, so the optimal policy is the conditional mean").

Used by the tier D claims C17.b and C18. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
  {θ : ℝ → ℝ → Ω → ℝ} {σ ℓs T : ℝ}

namespace CanonicalField

omit [IsProbabilityMeasure μ] in
/-- Each value of the field has a finite second moment. -/
theorem memLp (h : CanonicalField μ θ σ ℓs T) (z t : ℝ) : MemLp (θ z t) 2 μ :=
  (h.gaussian.hasGaussianLaw_eval (z, t)).memLp_two

omit [IsProbabilityMeasure μ] in
/-- `E[θ(z,t)²] = σ²`. -/
theorem integral_sq (h : CanonicalField μ θ σ ℓs T) (z t : ℝ) :
    ∫ ω, θ z t ω ^ 2 ∂μ = σ ^ 2 := by
  have := h.cov z z t t
  simpa [pow_two] using this

omit [IsProbabilityMeasure μ] in
/-- The covariance at one time: `E[θ(y,t) θ(y',t)] = σ² e^{−|y−y'|/ℓ_s}`. -/
theorem cov_same_time (h : CanonicalField μ θ σ ℓs T) (y y' t : ℝ) :
    ∫ ω, θ y t ω * θ y' t ω ∂μ = σ ^ 2 * exp (-|y - y'| / ℓs) := by
  have := h.cov y y' t t
  simpa using this

omit [IsProbabilityMeasure μ] in
/-- A spatial slice of the field, recentred at `z`, can be integrated over the
location. -/
theorem slice (h : CanonicalField μ θ σ ℓs T) (z t : ℝ) :
    L2Process μ (fun u => θ (z + u) t) :=
  L2Process.of_continuous (fun _ => h.measurable _ _)
    (fun ω => (h.continuous t ω).comp (continuous_const.add continuous_id))
    (fun _ => h.memLp _ _) ⟨σ ^ 2, fun _ => (h.integral_sq _ _).le⟩

omit [IsProbabilityMeasure μ] in
theorem measurable_lineTarget (h : CanonicalField μ θ σ ℓs T) (ℓc z t : ℝ) :
    Measurable (lineTarget θ ℓc z t) :=
  (h.slice z t).measurable_integral (measurable_lineKernel ℓc)

theorem memLp_lineTarget (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) :
    MemLp (lineTarget θ ℓc z t) 2 μ :=
  (h.slice z t).memLp_integral (measurable_lineKernel ℓc) (integrable_lineKernel hℓc)

/-- The target is centred. -/
theorem integral_lineTarget (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (z t : ℝ) :
    ∫ ω, lineTarget θ ℓc z t ω ∂μ = 0 := by
  unfold lineTarget
  rw [(h.slice z t).integral_integral (measurable_lineKernel ℓc) (integrable_lineKernel hℓc)]
  simp [h.mean]

omit [IsProbabilityMeasure μ] in
theorem measurable_lineObs (h : CanonicalField μ θ σ ℓs T) (r z t : ℝ) :
    Measurable (lineObs θ r z t) :=
  measurable_pi_lambda _ fun _ => h.measurable _ _

/-- The regret at a location is `q/2` times the expected conditional variance
of the target given the observed interval. -/
theorem lineR_eq (h : CanonicalField μ θ σ ℓs T) {ℓc q : ℝ} (hℓc : 0 < ℓc) (hq : 0 < q)
    (r τ z t : ℝ) :
    lineR μ q θ ℓc r τ z t
      = q / 2 * ∫ ω, Var[lineTarget θ ℓc z t; μ |
          MeasurableSpace.comap (lineObs θ r z (t - τ)) MeasurableSpace.pi] ω ∂μ :=
  regret_unit_eq_integral_condVar hq (h.memLp_lineTarget hℓc z t)
    (h.measurable_lineObs r z (t - τ))

end CanonicalField

end TinaV2
