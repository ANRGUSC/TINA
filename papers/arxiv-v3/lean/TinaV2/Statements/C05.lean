import TinaV2.Defs

/-! # C5: Quadratic cost and completing the square

Paper: technical-appendices-v3.tex lines 25-68, Eqs. (quadratic_cost), (clairvoyant), (complete_square). -/

namespace TinaV2.C05

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- At a fixed state (`b = b(θ)`, `c = c(θ)`), with `x⋆ = Q⁻¹ b`:
`f(x) − f(x⋆) = ½ (x − x⋆)ᵀ Q (x − x⋆)`, and `x⋆` is the unique minimizer. -/
def Statement : Prop :=
  ∀ {α : Type} [Fintype α] [DecidableEq α] (Q : Matrix α α ℝ) (b : α → ℝ) (c : ℝ),
    Q.PosDef →
    let xstar := Q⁻¹ *ᵥ b
    (∀ x, quadCost Q b c x - quadCost Q b c xstar = 1 / 2 * quad Q (x - xstar)) ∧
    (∀ x, x ≠ xstar → quadCost Q b c xstar < quadCost Q b c x)

end TinaV2.C05
