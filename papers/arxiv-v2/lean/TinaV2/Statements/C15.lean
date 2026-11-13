import TinaV2.Defs

/-! # C15: Continuous marginal-balance characterization

Paper: main-alt.tex Proposition (marginal_balance), Eq. (marginal_balance_condition). -/

namespace TinaV2.C15

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Every interior maximizer `r⋆ ∈ (0, D)` of `G` on `[0, D]` satisfies
`d/dr log[1 − η(r)] = 2τ'(r)/T` at `r⋆`. -/
def Statement : Prop :=
  ∀ (η τ : ℝ → ℝ) (T D : ℝ), 0 < T → SmoothCurves η τ D →
    ∀ rstar ∈ Ioo 0 D, IsMaxOn (gain η τ T) (Icc 0 D) rstar →
      deriv (fun r => log (1 - η r)) rstar = 2 * deriv τ rstar / T

end TinaV2.C15
