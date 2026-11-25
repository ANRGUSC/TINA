import TinaV2.Defs

/-! # C3.b: Degenerate normalization R_inf = 0

Paper: technical-appendices-v3.tex lines 287-292, paragraph "Degenerate normalization". -/

namespace TinaV2.C03b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `R_∞ = 0` and `Q ≻ 0` give `x⋆ = 0` a.s.; then every architecture has zero
regret, and the unnormalized composition law holds for every weight `a`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (now : Ω → κ → ℝ),
    Measurable now → MemLp now 2 μ → M.Rinf μ now = 0 →
    (M.target now =ᵐ[μ] 0) ∧
    (∀ (O : ι → Type) [∀ i, MeasurableSpace (O i)] (Z : (i : ι) → Ω → O i),
        regret μ M.Q M.actor (M.target now) Z = 0) ∧
    (∀ (r : ℕ∞) (snap : Ω → κ → ℝ) (a : ℝ),
        M.R μ r snap now = (1 - a ^ 2) * M.Rinf μ now + a ^ 2 * M.R μ r now now)

end TinaV2.C03b
