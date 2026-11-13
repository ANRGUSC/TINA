import TinaV2.Defs

/-! # C4.b: Stationary AR(1) satisfies the prediction rule

Paper: main-alt.tex Section "A common temporal prediction rule" (last sentence); technical-appendices-alt.tex Section "Temporal special cases". -/

namespace TinaV2.C04b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Integer time. `θ_{s+1} = c θ_s + ξ_{s+1}` with `0 < c < 1`, `θ` stationary,
and each innovation mean-zero, square-integrable and independent of every
earlier state. Then the lag-`k` prediction coefficient is `c^k`, and the
composition weights are `1 − c^{2k}` and `c^{2k}`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ ξ : ℤ → Ω → κ → ℝ) (c : ℝ),
    0 < c → c < 1 → StationaryState μ θ →
    (∀ s, Measurable (ξ s)) → (∀ s, MemLp (ξ s) 2 μ) → (∀ s k, ∫ ω, ξ s ω k ∂μ = 0) →
    (∀ s ω, θ (s + 1) ω = c • θ s ω + ξ (s + 1) ω) →
    (∀ s u, s < u → IndepFun (ξ u) (θ s) μ) →
    ∀ (t : ℤ) (k : ℕ),
      PredictionRule μ (c ^ k) (θ (t - k)) (θ t) ∧
      ∀ r : ℕ∞, M.R μ r (θ (t - k)) (θ t)
        = (1 - c ^ (2 * k)) * M.Rinf μ (θ t) + c ^ (2 * k) * M.R μ r (θ t) (θ t)

end TinaV2.C04b
