import TinaV2.Defs

/-! # C15.b: Single-crossing gives the unique optimum

Paper: main-v3.tex, paragraph after Proposition (marginal_balance). -/

namespace TinaV2.C15b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- If the balance gap is strictly decreasing on `[0, D]`, its sign identifies
the unique maximizer of `G` on `[0, D]`: `0` if the gap is nonpositive at `0`,
`D` if it is nonnegative at `D`, otherwise the unique interior zero of the gap. -/
def Statement : Prop :=
  ∀ (η τ : ℝ → ℝ) (T D : ℝ), 0 < T → SmoothCurves η τ D →
    StrictAntiOn (balanceGap η τ T D) (Icc 0 D) →
    let G := gain η τ T
    let Δ := balanceGap η τ T D
    (Δ 0 ≤ 0 → ∀ r ∈ Icc 0 D, r ≠ 0 → G r < G 0) ∧
    (0 ≤ Δ D → ∀ r ∈ Icc 0 D, r ≠ D → G r < G D) ∧
    (0 < Δ 0 → Δ D < 0 →
      ∃ r₀ ∈ Ioo 0 D, Δ r₀ = 0 ∧ (∀ r ∈ Ioo 0 D, Δ r = 0 → r = r₀) ∧
        ∀ r ∈ Icc 0 D, r ≠ r₀ → G r < G r₀)

end TinaV2.C15b
