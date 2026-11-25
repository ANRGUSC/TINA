import TinaV2.Defs.Architecture

/-! # The canonical line model (claim C17)

Paper: `main-v3.tex` Section "The canonical three-length result" (lines 809-852),
Eqs. (canonical_space_time_covariance), (canonical_target),
(canonical_tracking_cost), (canonical_radius_observation); and
`technical-appendices-v3.tex` Section "Canonical spatial omission calculation"
(lines 410-488) for "a continuous version of the field".

Conventions.
* The field is `θ : ℝ → ℝ → Ω → ℝ`, read `θ z t ω`: location, time, outcome.
* Regret at a location is the expected pointwise loss there (the paper's
  "regret per unit length, equal by stationarity to expected pointwise loss";
  disposition F10.4). It is the general `regret` of `Defs/Architecture.lean`
  with one agent, one action coordinate and the `1 × 1` cost matrix `(q)`, so
  the rules are the measurable functions of the observed stretch of field with
  finite second moment.
* The observation `𝒪_r(z,t)` is the function `u ↦ θ(z+u,t)` on `[-r, r]`, a
  random element of `[-r, r] → ℝ` with the product sigma-algebra. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [MeasurableSpace Ω]

/-- The zero-mean jointly Gaussian space-time field on the line with
covariance Eq. (canonical_space_time_covariance):
`E[θ(z,t) θ(z',s)] = σ² e^{−|z−z'|/ℓ_s} e^{−|t−s|/T}`, with `ℓ_s > 0`, `T > 0`.

`measurable` is the regularity the paper leaves implicit. `continuous` is the
appendix's "we use a continuous version of the field": every sample path is
continuous in the location. It is what makes the target integral and the
observation of an interval well defined. -/
structure CanonicalField (μ : Measure Ω) (θ : ℝ → ℝ → Ω → ℝ) (σ ℓs T : ℝ) : Prop where
  ℓs_pos : 0 < ℓs
  T_pos : 0 < T
  gaussian : IsGaussianProcess (fun (p : ℝ × ℝ) => θ p.1 p.2) μ
  mean : ∀ z t, ∫ ω, θ z t ω ∂μ = 0
  cov : ∀ z z' t s,
    ∫ ω, θ z t ω * θ z' s ω ∂μ = σ ^ 2 * exp (-|z - z'| / ℓs) * exp (-|t - s| / T)
  measurable : ∀ z t, Measurable (θ z t)
  continuous : ∀ t ω, Continuous fun z => θ z t ω

/-- The decision kernel of Eq. (canonical_target):
`w_{ℓ_c}(u) = e^{−|u|/ℓ_c} / (2ℓ_c)`. -/
def lineKernel (ℓc u : ℝ) : ℝ := 1 / (2 * ℓc) * exp (-|u| / ℓc)

/-- Eq. (canonical_target): `x⋆(z,t) = ∫ w_{ℓ_c}(u) θ(z+u,t) du`. -/
def lineTarget (θ : ℝ → ℝ → Ω → ℝ) (ℓc z t : ℝ) : Ω → ℝ :=
  fun ω => ∫ u, lineKernel ℓc u * θ (z + u) t ω

/-- Eq. (canonical_radius_observation): `𝒪_r(z,t) = (θ(z+u,t) : |u| ≤ r)`. -/
def lineObs (θ : ℝ → ℝ → Ω → ℝ) (r z t : ℝ) : Ω → (Icc (-r) r → ℝ) :=
  fun ω u => θ (z + u) t ω

/-- The `1 × 1` cost matrix `(q)` of Eq. (canonical_tracking_cost):
`f_z(x,θ) = (q/2) [x(z) − x⋆(z,θ)]²`. -/
def lineCost (q : ℝ) : Matrix Unit Unit ℝ := Matrix.of fun _ _ => q

/-- Regret at location `z` and epoch `t` of acting on the radius-`r`
observation taken at time `t − τ`:
`inf_g (q/2) E[(g(𝒪_r(z,t−τ)) − x⋆(z,t))²]`. -/
def lineR (μ : Measure Ω) (q : ℝ) (θ : ℝ → ℝ → Ω → ℝ) (ℓc r τ z t : ℝ) : ℝ :=
  regret μ (lineCost q) (fun _ : Unit => ()) (O := fun _ : Unit => Icc (-r) r → ℝ)
    (fun ω _ => lineTarget θ ℓc z t ω) (fun _ => lineObs θ r z (t - τ))

/-- `R_∞ = (q/2) Var(x⋆(z,t))`. -/
def lineRinf (μ : Measure Ω) (q : ℝ) (θ : ℝ → ℝ → Ω → ℝ) (ℓc z t : ℝ) : ℝ :=
  q / 2 * Var[lineTarget θ ℓc z t; μ]

/-- The normalized zero-delay spatial omission error `η_S(r) = R(r, 0) / R_∞`
of the canonical model. -/
def lineEtaS (μ : Measure Ω) (q : ℝ) (θ : ℝ → ℝ → Ω → ℝ) (ℓc r z t : ℝ) : ℝ :=
  lineR μ q θ ℓc r 0 z t / lineRinf μ q θ ℓc z t

end TinaV2
