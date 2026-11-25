import TinaV2.Defs

/-! # C17.b: The composition law holds in the continuum model

Paper: main-v3.tex lines 854-870, the unlabelled paragraph after Eq. (temporal_propagation_length). -/

namespace TinaV2.C17b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the canonical field, every location `z`, radius `r ≥ 0` and delay
`τ ≥ 0`, with `a = e^{−τ/T}`:
`E[x⋆(z,t) | 𝒪_r(z,t−τ)] = a E[x⋆(z,t−τ) | 𝒪_r(z,t−τ)]`, and the delayed
interval retains `a²` times the gain, over acting without observations, of a
fresh interval of the same radius: `R_∞ − R(r,τ) = a² (R_∞ − R(r,0))`. -/
def Statement : Prop :=
  ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → ℝ → Ω → ℝ) (σ ℓs T ℓc q : ℝ),
    CanonicalField μ θ σ ℓs T → 0 < ℓc → 0 < q →
    ∀ (z t r τ : ℝ), 0 ≤ r → 0 ≤ τ →
      (μ[lineTarget θ ℓc z t | MeasurableSpace.comap (lineObs θ r z (t - τ)) MeasurableSpace.pi]
          =ᵐ[μ] fun ω => exp (-τ / T) *
            (μ[lineTarget θ ℓc z (t - τ) |
              MeasurableSpace.comap (lineObs θ r z (t - τ)) MeasurableSpace.pi]) ω) ∧
      lineRinf μ q θ ℓc z t - lineR μ q θ ℓc r τ z t
        = exp (-τ / T) ^ 2 * (lineRinf μ q θ ℓc z t - lineR μ q θ ℓc r 0 z t)

end TinaV2.C17b
