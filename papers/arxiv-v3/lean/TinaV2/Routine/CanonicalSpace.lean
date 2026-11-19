import TinaV2.Routine.Canonical

/-! # Routine: the notation of the canonical spatial omission calculation

The appendix proof of the exponential omission law (claim C18) splits the
target `x⋆ = ∫ w(u) θ(u) du` into an observed middle `M_r` and two tails
`T_r^±`, rewrites each tail as a multiple of a discounted integral `Y` of the
field along a half line, and (supplied step) splits the field along the half
line into its regression on the boundary value and a residual field. This file
defines that notation and proves what the paper leaves unsaid about it: the
pieces are random variables with finite second moments, the middle and the
boundary values are functions of the observation, the tail integrals are
linear in the field, expectation passes under the integral sign, and every
process built from finitely many field values is Gaussian.

A half line is given by its boundary point `y` and its direction `d`: the
locations `y + d s`, `s ≥ 0`. The right tail of the radius-`r` observation at
`z` is `y = z + r`, `d = 1`; the left tail is `y = z − r`, `d = −1`.

Used by the tier D claim C18. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

/-! ## The notation of the proof -/

section Defs

variable {Ω : Type}

/-- The observed middle `M_r = ∫_{−r}^{r} w(u) θ(z+u) du`. -/
def lineMid (θ : ℝ → ℝ → Ω → ℝ) (ℓc r z t : ℝ) : Ω → ℝ :=
  fun ω => ∫ u in Icc (-r) r, lineKernel ℓc u * θ (z + u) t ω

/-- The right tail `T_r^+ = ∫_r^∞ w(u) θ(z+u) du`. -/
def lineTailR (θ : ℝ → ℝ → Ω → ℝ) (ℓc r z t : ℝ) : Ω → ℝ :=
  fun ω => ∫ u in Ioi r, lineKernel ℓc u * θ (z + u) t ω

/-- The left tail `T_r^- = ∫_{−∞}^{−r} w(u) θ(z+u) du`. -/
def lineTailL (θ : ℝ → ℝ → Ω → ℝ) (ℓc r z t : ℝ) : Ω → ℝ :=
  fun ω => ∫ u in Iio (-r), lineKernel ℓc u * θ (z + u) t ω

/-- The discounted integral of the field along the half line that starts at
`y` and runs in direction `d`: `∫₀^∞ e^{−s/ℓ_c} θ(y + d s) ds`. The paper's
`Y_r` is `lineY θ ℓc (z + r) 1 t`; its left analogue is
`lineY θ ℓc (z − r) (−1) t`. -/
def lineY (θ : ℝ → ℝ → Ω → ℝ) (ℓc y d t : ℝ) : Ω → ℝ :=
  fun ω => ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * θ (y + d * s) t ω

/-- The residual field along a half line: `ε(s) = θ(y + d s) − e^{−s/ℓ_s} θ(y)`,
what is left of the value at distance `s` after its regression on the boundary
value. -/
def lineRes (θ : ℝ → ℝ → Ω → ℝ) (ℓs y d t s : ℝ) : Ω → ℝ :=
  fun ω => θ (y + d * s) t ω - exp (-s / ℓs) * θ y t ω

/-- The discounted integral of the residual field:
`E = ∫₀^∞ e^{−s/ℓ_c} ε(s) ds`. -/
def lineE (θ : ℝ → ℝ → Ω → ℝ) (ℓc ℓs y d t : ℝ) : Ω → ℝ :=
  fun ω => ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * lineRes θ ℓs y d t s ω

/-- The paper's constant `C = Var(Y_0 | θ(0))`, as the double integral
`∫₀^∞∫₀^∞ e^{−a/ℓ_c} e^{−b/ℓ_c} σ² (e^{−|a−b|/ℓ_s} − e^{−(a+b)/ℓ_s}) db da`. It
is never evaluated. -/
def lineTailConst (σ ℓc ℓs : ℝ) : ℝ :=
  ∫ a in Ioi (0 : ℝ), ∫ b in Ioi (0 : ℝ),
    exp (-a / ℓc) * exp (-b / ℓc) * (σ ^ 2 * (exp (-|a - b| / ℓs) - exp (-(a + b) / ℓs)))

/-! ## Unfolding and substitution -/

/-- The middle of a radius-zero observation is an integral over a point. -/
theorem lineMid_zero (θ : ℝ → ℝ → Ω → ℝ) (ℓc z t : ℝ) (ω : Ω) : lineMid θ ℓc 0 z t ω = 0 :=
  setIntegral_measure_zero _ (by simp)

/-- The left tail, substituting `u = −r − s` (the paper's "by reflection
symmetry"): `T_r^- = (1/(2ℓ_c)) e^{−r/ℓ_c} ∫₀^∞ e^{−s/ℓ_c} θ(z − r − s) ds`. -/
theorem lineTailL_eq (θ : ℝ → ℝ → Ω → ℝ) {ℓc r : ℝ} (hr : 0 ≤ r) (z t : ℝ) (ω : Ω) :
    lineTailL θ ℓc r z t ω = 1 / (2 * ℓc) * exp (-r / ℓc) * lineY θ ℓc (z - r) (-1) t ω := by
  show ∫ u in Iio (-r), lineKernel ℓc u * θ (z + u) t ω
    = 1 / (2 * ℓc) * exp (-r / ℓc) * ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * θ (z - r + -1 * s) t ω
  rw [integral_Iio_neg_eq_integral_Ioi_zero (fun u => lineKernel ℓc u * θ (z + u) t ω) r,
    ← integral_const_mul]
  refine setIntegral_congr_fun measurableSet_Ioi fun s hs => ?_
  have hs' : (0 : ℝ) ≤ s := le_of_lt hs
  simp only [lineKernel_neg_sub hr hs']
  rw [show z + (-r - s) = z - r + -1 * s by ring]
  ring

/-- Inside the integral over `s > 0` the index may be clamped at `0`. -/
theorem lineE_eq_max (θ : ℝ → ℝ → Ω → ℝ) (ℓc ℓs y d t : ℝ) :
    lineE θ ℓc ℓs y d t
      = fun ω => ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * lineRes θ ℓs y d t (max s 0) ω := by
  funext ω
  refine setIntegral_congr_fun measurableSet_Ioi fun s hs => ?_
  have hs' : (0 : ℝ) ≤ s := le_of_lt hs
  simp only [max_eq_left hs']

/-- A value of the field inside the observed interval is a function of the
observation. -/
theorem measurable_lineObs_apply (θ : ℝ → ℝ → Ω → ℝ) (r z t : ℝ) {u : ℝ}
    (hu : u ∈ Icc (-r) r) :
    Measurable[MeasurableSpace.comap (lineObs θ r z t) MeasurableSpace.pi] (θ (z + u) t) :=
  (measurable_pi_apply (⟨u, hu⟩ : Icc (-r) r)).comp (comap_measurable (lineObs θ r z t))

/-- The right endpoint value `θ(z + r)` is observed. -/
theorem measurable_lineObs_right (θ : ℝ → ℝ → Ω → ℝ) (z t : ℝ) {r : ℝ} (hr : 0 ≤ r) :
    Measurable[MeasurableSpace.comap (lineObs θ r z t) MeasurableSpace.pi] (θ (z + r) t) :=
  measurable_lineObs_apply θ r z t ⟨by linarith, le_rfl⟩

/-- The left endpoint value `θ(z − r)` is observed. -/
theorem measurable_lineObs_left (θ : ℝ → ℝ → Ω → ℝ) (z t : ℝ) {r : ℝ} (hr : 0 ≤ r) :
    Measurable[MeasurableSpace.comap (lineObs θ r z t) MeasurableSpace.pi] (θ (z - r) t) := by
  have h := measurable_lineObs_apply θ r z t (u := -r) ⟨le_rfl, by linarith⟩
  rwa [← sub_eq_add_neg] at h

end Defs

theorem measurable_exp_neg_div (ℓ : ℝ) : Measurable fun s : ℝ => exp (-s / ℓ) :=
  (by fun_prop : Continuous fun s : ℝ => exp (-s / ℓ)).measurable

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {μ : Measure Ω}

/-- The covariance depends on its first argument only up to almost-sure
equality. -/
theorem covariance_congr_left {X X' Y : Ω → ℝ} (h : X =ᵐ[μ] X') :
    cov[X, Y; μ] = cov[X', Y; μ] := by
  unfold covariance
  rw [integral_congr_ae h]
  refine integral_congr_ae ?_
  filter_upwards [h] with ω hω
  rw [hω]

variable {θ : ℝ → ℝ → Ω → ℝ} {σ ℓs T : ℝ}

namespace CanonicalField

/-! ## Regularity that does not use the total mass -/

section NoProb

/-- The middle is "computed from observed values": it is measurable for the
observation. -/
theorem stronglyMeasurable_lineMid (h : CanonicalField μ θ σ ℓs T) (ℓc z t : ℝ) {r : ℝ}
    (hr : 0 ≤ r) :
    StronglyMeasurable[MeasurableSpace.comap (lineObs θ r z t) MeasurableSpace.pi]
      (lineMid θ ℓc r z t) := by
  have hcl : ∀ u : ℝ, max (-r) (min u r) ∈ Icc (-r) r := fun u =>
    ⟨le_max_left _ _, max_le (by linarith) (min_le_right _ _)⟩
  have e : lineMid θ ℓc r z t
      = fun ω => ∫ u in Icc (-r) r, lineKernel ℓc u * θ (z + max (-r) (min u r)) t ω := by
    funext ω
    refine setIntegral_congr_fun measurableSet_Icc fun u hu => ?_
    simp only [min_eq_left hu.2, max_eq_right hu.1]
  rw [e]
  refine stronglyMeasurable_integral_of_continuous (fun u => ?_) (fun ω => ?_)
    (measurable_lineKernel ℓc) _
  · exact measurable_lineObs_apply θ r z t (hcl u)
  · exact (h.continuous t ω).comp (by fun_prop)

/-- The field along a half line, with the index clamped at `0`, can be
integrated over the index. -/
theorem ray (h : CanonicalField μ θ σ ℓs T) (y d t : ℝ) :
    L2Process μ (fun s => θ (y + d * max s 0) t) :=
  (h.slice y t).comp (ρ := fun s : ℝ => d * max s 0)
    ((measurable_id.max measurable_const).const_mul d)

theorem measurable_lineRes (h : CanonicalField μ θ σ ℓs T) (y d t s : ℝ) :
    Measurable (lineRes θ ℓs y d t s) :=
  (h.measurable _ t).sub ((h.measurable y t).const_mul _)

theorem memLp_lineRes (h : CanonicalField μ θ σ ℓs T) (y d t s : ℝ) :
    MemLp (lineRes θ ℓs y d t s) 2 μ :=
  (h.memLp _ t).sub ((h.memLp y t).const_mul _)

theorem continuous_lineRes (h : CanonicalField μ θ σ ℓs T) (y d t : ℝ) (ω : Ω) :
    Continuous fun s => lineRes θ ℓs y d t (max s 0) ω :=
  ((h.continuous t ω).comp (by fun_prop)).sub
    ((by fun_prop : Continuous fun s : ℝ => exp (-(max s 0) / ℓs)).mul continuous_const)

/-- The residual field, with the index clamped at `0`, can be integrated over
the index. -/
theorem res (h : CanonicalField μ θ σ ℓs T) (y d t : ℝ) :
    L2Process μ (fun s => lineRes θ ℓs y d t (max s 0)) :=
  (h.ray y d t).sub
    ((L2Process.const (A := ℝ) (h.measurable y t) (h.memLp y t)).coeff_mul
      (c := fun s => exp (-(max s 0) / ℓs))
      (by fun_prop : Continuous fun s : ℝ => exp (-(max s 0) / ℓs)).measurable
      ⟨1, fun s => by
        rw [abs_of_pos (exp_pos _)]
        exact exp_le_one_iff.2
          (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.2 (le_max_right _ _)) h.ℓs_pos.le)⟩)

theorem measurable_lineE (h : CanonicalField μ θ σ ℓs T) (ℓc y d t : ℝ) :
    Measurable (lineE θ ℓc ℓs y d t) := by
  rw [lineE_eq_max]
  exact (h.res y d t).measurable_integral (measurable_exp_neg_div ℓc)

/-- The discounted integral of the residual field is measurable for any
sigma-algebra that makes every residual measurable. -/
theorem stronglyMeasurable_lineE (h : CanonicalField μ θ σ ℓs T) (ℓc y d t : ℝ)
    {m : MeasurableSpace Ω} (hm : ∀ s, Measurable[m] (lineRes θ ℓs y d t (max s 0))) :
    StronglyMeasurable[m] (lineE θ ℓc ℓs y d t) := by
  rw [lineE_eq_max]
  exact stronglyMeasurable_integral_of_continuous hm (continuous_lineRes (mΩ := mΩ) h y d t)
    (measurable_exp_neg_div ℓc) _

/-- `E[(θ(y₁) − c θ(y₂)) θ(y₃)]` from the covariance of the field. -/
theorem integral_sub_mul (h : CanonicalField μ θ σ ℓs T) (y₁ y₂ y₃ t c : ℝ) :
    ∫ ω, (θ y₁ t ω - c * θ y₂ t ω) * θ y₃ t ω ∂μ
      = σ ^ 2 * (exp (-|y₁ - y₃| / ℓs) - c * exp (-|y₂ - y₃| / ℓs)) := by
  have i1 : Integrable (fun ω => θ y₁ t ω * θ y₃ t ω) μ :=
    (h.memLp y₁ t).integrable_mul (h.memLp y₃ t)
  have i2 : Integrable (fun ω => c * (θ y₂ t ω * θ y₃ t ω)) μ :=
    ((h.memLp y₂ t).integrable_mul (h.memLp y₃ t)).const_mul c
  have e : ∀ ω, (θ y₁ t ω - c * θ y₂ t ω) * θ y₃ t ω
      = θ y₁ t ω * θ y₃ t ω - c * (θ y₂ t ω * θ y₃ t ω) := fun ω => by ring
  simp_rw [e]
  rw [integral_sub i1 i2, integral_const_mul, h.cov_same_time, h.cov_same_time]
  ring

/-- The second moments of the residual field along a half line (`d = ±1`):
`E[ε(a) ε(b)] = σ² (e^{−|a−b|/ℓ_s} − e^{−(a+b)/ℓ_s})` for `a, b ≥ 0`. The value
does not depend on the boundary point or on the direction. -/
theorem integral_lineRes_mul_lineRes (h : CanonicalField μ θ σ ℓs T) (y t : ℝ) {d : ℝ}
    (hd : |d| = 1) {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    ∫ ω, lineRes θ ℓs y d t a ω * lineRes θ ℓs y d t b ω ∂μ
      = σ ^ 2 * (exp (-|a - b| / ℓs) - exp (-(a + b) / ℓs)) := by
  have e : ∀ ω, lineRes θ ℓs y d t a ω * lineRes θ ℓs y d t b ω
      = (θ (y + d * a) t ω - exp (-a / ℓs) * θ y t ω) * θ (y + d * b) t ω
        - exp (-b / ℓs) * ((θ (y + d * a) t ω - exp (-a / ℓs) * θ y t ω) * θ y t ω) :=
    fun ω => by unfold lineRes; ring
  have i1 : Integrable
      (fun ω => (θ (y + d * a) t ω - exp (-a / ℓs) * θ y t ω) * θ (y + d * b) t ω) μ :=
    (h.memLp_lineRes y d t a).integrable_mul (h.memLp _ t)
  have i2 : Integrable (fun ω => exp (-b / ℓs)
      * ((θ (y + d * a) t ω - exp (-a / ℓs) * θ y t ω) * θ y t ω)) μ :=
    ((h.memLp_lineRes y d t a).integrable_mul (h.memLp y t)).const_mul _
  have h1 : |y + d * a - (y + d * b)| = |a - b| := by
    rw [show y + d * a - (y + d * b) = d * (a - b) by ring, abs_mul, hd, one_mul]
  have h2 : |y + d * a - y| = a := by
    rw [add_sub_cancel_left, abs_mul, hd, one_mul, abs_of_nonneg ha]
  have h3 : |y - (y + d * b)| = b := by
    rw [show y - (y + d * b) = -(d * b) by ring, abs_neg, abs_mul, hd, one_mul,
      abs_of_nonneg hb]
  simp_rw [e]
  rw [integral_sub i1 i2, integral_const_mul, h.integral_sub_mul, h.integral_sub_mul, h1, h2,
    h3, sub_self, abs_zero, neg_zero, zero_div, exp_zero,
    show -(a + b) / ℓs = -a / ℓs + -b / ℓs by ring, exp_add]
  ring

/-- Every process whose values are combinations of two values of the field is
Gaussian. -/
theorem isGaussianProcess_of_forall_eq {S : Type} (h : CanonicalField μ θ σ ℓs T)
    {Y : S → Ω → ℝ}
    (hY : ∀ s, ∃ a b y y' t t' : ℝ, ∀ ω, Y s ω = a * θ y t ω + b * θ y' t' ω) :
    IsGaussianProcess Y μ := by
  classical
  refine h.gaussian.of_isGaussianProcess fun s => ?_
  obtain ⟨a, b, y, y', t, t', hs⟩ := hY s
  have m1 : (y, t) ∈ ({(y, t), (y', t')} : Finset (ℝ × ℝ)) := by simp
  have m2 : (y', t') ∈ ({(y, t), (y', t')} : Finset (ℝ × ℝ)) := by simp
  refine ⟨{(y, t), (y', t')},
    a • ContinuousLinearMap.proj (R := ℝ)
        (φ := fun _ : ({(y, t), (y', t')} : Finset (ℝ × ℝ)) => ℝ) ⟨(y, t), m1⟩
      + b • ContinuousLinearMap.proj (R := ℝ)
        (φ := fun _ : ({(y, t), (y', t')} : Finset (ℝ × ℝ)) => ℝ) ⟨(y', t'), m2⟩,
    fun ω => ?_⟩
  rw [hs ω]
  simp

end NoProb

/-! ## Regularity under a probability measure -/

variable [IsProbabilityMeasure μ]

/-- `Var(θ(z,t)) = σ²`. -/
theorem variance_eq (h : CanonicalField μ θ σ ℓs T) (z t : ℝ) : Var[θ z t; μ] = σ ^ 2 := by
  rw [variance_eq_sub (h.memLp z t), h.mean]
  simp [h.integral_sq]

/-- The residual field is centred. -/
theorem integral_lineRes (h : CanonicalField μ θ σ ℓs T) (y d t s : ℝ) :
    ∫ ω, lineRes θ ℓs y d t s ω ∂μ = 0 := by
  have i1 : Integrable (θ (y + d * s) t) μ := (h.memLp _ t).integrable one_le_two
  have i2 : Integrable (fun ω => exp (-s / ℓs) * θ y t ω) μ :=
    ((h.memLp y t).integrable one_le_two).const_mul _
  show ∫ ω, (θ (y + d * s) t ω - exp (-s / ℓs) * θ y t ω) ∂μ = 0
  rw [integral_sub i1 i2, integral_const_mul, h.mean, h.mean]
  ring

/-- The kernel-weighted integral of the field over any set of locations has a
finite second moment. -/
theorem memLp_setIntegral_lineKernel (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc)
    (S : Set ℝ) (z t : ℝ) :
    MemLp (fun ω => ∫ u in S, lineKernel ℓc u * θ (z + u) t ω) 2 μ :=
  (h.slice z t).memLp_integral (measurable_lineKernel ℓc) (integrable_lineKernel hℓc).restrict

theorem memLp_lineMid (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (r z t : ℝ) :
    MemLp (lineMid θ ℓc r z t) 2 μ :=
  h.memLp_setIntegral_lineKernel hℓc _ z t

theorem memLp_lineTailR (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (r z t : ℝ) :
    MemLp (lineTailR θ ℓc r z t) 2 μ :=
  h.memLp_setIntegral_lineKernel hℓc _ z t

theorem memLp_lineTailL (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (r z t : ℝ) :
    MemLp (lineTailL θ ℓc r z t) 2 μ :=
  h.memLp_setIntegral_lineKernel hℓc _ z t

theorem memLp_lineE (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (y d t : ℝ) :
    MemLp (lineE θ ℓc ℓs y d t) 2 μ := by
  rw [lineE_eq_max]
  exact (h.res y d t).memLp_integral (measurable_exp_neg_div ℓc)
    (integrableOn_Ioi_exp_neg_div hℓc)

/-- The covariance of a residual with a value of the field, from the
covariance of the field (both are centred). -/
theorem covariance_lineRes (h : CanonicalField μ θ σ ℓs T) (y d t s y' : ℝ) :
    cov[lineRes θ ℓs y d t s, θ y' t; μ]
      = σ ^ 2 * (exp (-|y + d * s - y'| / ℓs) - exp (-s / ℓs) * exp (-|y - y'| / ℓs)) := by
  rw [covariance_eq_sub (h.memLp_lineRes y d t s) (h.memLp y' t), h.integral_lineRes, zero_mul,
    sub_zero]
  exact h.integral_sub_mul _ _ _ _ _

/-- Linearity of the half-line integral, almost surely:
`E = Y − (∫₀^∞ e^{−s/ℓ_c} e^{−s/ℓ_s} ds) θ(y)`. -/
theorem lineE_ae_eq (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (y d t : ℝ) :
    lineE θ ℓc ℓs y d t =ᵐ[μ] fun ω =>
      lineY θ ℓc y d t ω - (∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * exp (-s / ℓs)) * θ y t ω := by
  have hee : IntegrableOn (fun s : ℝ => exp (-s / ℓc) * exp (-s / ℓs)) (Ioi 0) := by
    by_contra hni
    have h0 := integral_undef hni
    rw [integral_Ioi_exp_mul_exp hℓc h.ℓs_pos] at h0
    have : 0 < ℓc * ℓs / (ℓc + ℓs) := by have := h.ℓs_pos; positivity
    linarith
  filter_upwards [(h.ray y d t).ae_integrable (ν := volume.restrict (Ioi 0))
    (measurable_exp_neg_div ℓc) (integrableOn_Ioi_exp_neg_div hℓc)] with ω hω
  have h1 : IntegrableOn (fun s => exp (-s / ℓc) * θ (y + d * s) t ω) (Ioi 0) := by
    refine hω.congr ((ae_restrict_mem measurableSet_Ioi).mono fun s hs => ?_)
    have hs' : (0 : ℝ) ≤ s := le_of_lt hs
    simp only [max_eq_left hs']
  have h2 : IntegrableOn (fun s => exp (-s / ℓc) * exp (-s / ℓs) * θ y t ω) (Ioi 0) :=
    hee.mul_const _
  show ∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * (θ (y + d * s) t ω - exp (-s / ℓs) * θ y t ω)
    = (∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * θ (y + d * s) t ω)
      - (∫ s in Ioi (0 : ℝ), exp (-s / ℓc) * exp (-s / ℓs)) * θ y t ω
  rw [← integral_mul_const, ← integral_sub h1 h2]
  refine integral_congr_ae (ae_of_all _ fun s => ?_)
  show exp (-s / ℓc) * (θ (y + d * s) t ω - exp (-s / ℓs) * θ y t ω)
    = exp (-s / ℓc) * θ (y + d * s) t ω - exp (-s / ℓc) * exp (-s / ℓs) * θ y t ω
  ring

/-- Expectation under the integral sign: the second moment of the discounted
residual integral along a half line (`d = ±1`) is the double integral
`lineTailConst`, which does not involve the boundary point or the direction. -/
theorem integral_sq_lineE (h : CanonicalField μ θ σ ℓs T) {ℓc : ℝ} (hℓc : 0 < ℓc) (y t : ℝ)
    {d : ℝ} (hd : |d| = 1) :
    ∫ ω, lineE θ ℓc ℓs y d t ω ^ 2 ∂μ = lineTailConst σ ℓc ℓs := by
  have hg := integrableOn_Ioi_exp_neg_div hℓc
  have hgm := measurable_exp_neg_div ℓc
  have e := (h.res y d t).integral_integral_mul_integral (ν := volume.restrict (Ioi 0))
    (ν' := volume.restrict (Ioi 0)) (h.res y d t) hgm hg hgm hg
  simp_rw [lineE_eq_max, sq]
  rw [e]
  unfold lineTailConst
  refine setIntegral_congr_fun measurableSet_Ioi fun a ha => ?_
  refine setIntegral_congr_fun measurableSet_Ioi fun b hb => ?_
  have ha' : (0 : ℝ) ≤ a := le_of_lt ha
  have hb' : (0 : ℝ) ≤ b := le_of_lt hb
  simp only [max_eq_left ha', max_eq_left hb']
  rw [h.integral_lineRes_mul_lineRes y t hd ha' hb']

end CanonicalField

end TinaV2
