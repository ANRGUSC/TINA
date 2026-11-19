import TinaV2.Defs

/-! # C4.b: Stationary AR(1) satisfies the prediction rule

Paper: main-v3.tex Section "A common temporal prediction rule" (last sentence,
lines 359-361); technical-appendices-v3.tex Section "Temporal special cases"
(lines 313-320).

Formalization C4.b/f2. Since arXiv v3 the hypothesis on the innovations is
`E[ε_t | ℱ_{t−1}] = 0` with `ℱ_{t−1} = σ(θ_s : s ≤ t−1)`; C4.b/f1 assumed each
innovation independent of every earlier state. -/

namespace TinaV2.C04b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Integer time. `θ_{s+1} = c θ_s + ε_{s+1}` with `0 < c < 1`, `θ` stationary,
the innovations square-integrable and `E[ε_{s+1} | ℱ_s] = 0`, where
`ℱ_s = σ(θ_u : u ≤ s)`. Then the lag-`k` prediction coefficient is `c^k`, and
the composition weights are `1 − c^{2k}` and `c^{2k}`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ ε : ℤ → Ω → κ → ℝ) (c : ℝ),
    0 < c → c < 1 → StationaryState μ θ →
    (∀ s, MemLp (ε s) 2 μ) →
    (∀ s ω, θ (s + 1) ω = c • θ s ω + ε (s + 1) ω) →
    (∀ s, μ[ε (s + 1) | ⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (θ u) MeasurableSpace.pi]
      =ᵐ[μ] 0) →
    ∀ (t : ℤ) (k : ℕ),
      PredictionRule μ (c ^ k) (θ (t - k)) (θ t) ∧
      ∀ r : ℕ∞, M.R μ r (θ (t - k)) (θ t)
        = (1 - c ^ (2 * k)) * M.Rinf μ (θ t) + c ^ (2 * k) * M.R μ r (θ t) (θ t)

end TinaV2.C04b
