import TinaV2.Defs

/-! # C13.b: Large-n limit of the threshold

Paper: main-alt.tex Eq. (large_n_threshold) and the sentence after it. -/

namespace TinaV2.C13b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `ρ⋆(γ,n) → ½ log(1 + γ/q)` as `n → ∞`, and the share captured locally,
`1 − η_S(0)`, tends to `q/(q+γ)`. -/
def Statement : Prop :=
  ∀ (q γ : ℝ), 0 < q → 0 ≤ γ →
    Tendsto (fun n : ℕ => aggRhoStar n q γ) atTop (𝓝 (1 / 2 * log (1 + γ / q))) ∧
    Tendsto (fun n : ℕ => 1 - aggEta n q γ) atTop (𝓝 (q / (q + γ)))

end TinaV2.C13b
