import TinaV2.Defs

/-! # C4.c: The stationary Gaussian Ornstein–Uhlenbeck process satisfies the prediction rule

Paper: technical-appendices-v3.tex Section "Temporal special cases"
(lines 298-312), Eqs. (OU_process), (separable_space_time_covariance);
main-v3.tex lines 356-358.

"Ornstein–Uhlenbeck" is read through its law: a jointly Gaussian process with
mean zero and covariance `e^{−|t−s|/T} Σ_S`. The stochastic differential
equation Eq. (OU_process) is not stated. -/

namespace TinaV2.C04c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- A jointly Gaussian state process with mean zero and
`E[θ_{t,k} θ_{s,l}] = e^{−|t−s|/T} S_{kl}`, `T > 0`. Then at every epoch `t`
and every delay `τ ≥ 0` the innovation `θ_t − e^{−τ/T} θ_{t−τ}` is Gaussian and
independent of the earlier states `(θ_s : s ≤ t − τ)`, and the process
satisfies the temporal assumption C4 with coherence time `T`. -/
def Statement : Prop :=
  ∀ {κ Ω : Type} [Fintype κ] [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → Ω → κ → ℝ) (S : Matrix κ κ ℝ) (T : ℝ), 0 < T →
    IsGaussianProcess (fun (p : ℝ × κ) ω => θ p.1 ω p.2) μ →
    (∀ t, Measurable (θ t)) →
    (∀ t k, ∫ ω, θ t ω k ∂μ = 0) →
    (∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = exp (-|t - s| / T) * S k l) →
    ∀ t τ : ℝ, 0 ≤ τ →
      HasGaussianLaw (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω) μ ∧
      IndepFun (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω)
        (fun ω (s : Iic (t - τ)) => θ s ω) μ ∧
      TemporalAssumption μ θ T t τ

end TinaV2.C04c
