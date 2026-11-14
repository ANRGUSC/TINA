import TinaV2.Prelude

/-! # Quadratic cost and tracking loss (claim C5)

Paper: `main-v2.tex` Eq. (tracking_loss); `technical-appendices-v2.tex`
Eqs. (quadratic_cost), (clairvoyant), (complete_square).

Actions are vectors indexed by a finite type `α` of action coordinates. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix

variable {α : Type} [Fintype α]

/-- The quadratic form `vᵀ Q v`. -/
def quad (Q : Matrix α α ℝ) (v : α → ℝ) : ℝ := v ⬝ᵥ (Q *ᵥ v)

/-- Eq. (quadratic_cost) at one fixed state: `f(x) = ½ xᵀQx − bᵀx + c`, where
`b` and `c` stand for `b(θ)` and `c(θ)`. -/
def quadCost (Q : Matrix α α ℝ) (b : α → ℝ) (c : ℝ) (x : α → ℝ) : ℝ :=
  1 / 2 * quad Q x - b ⬝ᵥ x + c

/-- Expected excess cost of the joint action `u` against the desired action
`xstar`: `½ E[(u − x⋆)ᵀ Q (u − x⋆)]`, the quantity minimized in
Eq. (architecture_regret). -/
def excessCost {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) (Q : Matrix α α ℝ)
    (xstar u : Ω → α → ℝ) : ℝ :=
  1 / 2 * ∫ ω, quad Q (u ω - xstar ω) ∂μ

end TinaV2
