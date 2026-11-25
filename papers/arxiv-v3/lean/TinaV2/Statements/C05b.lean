import TinaV2.Defs

/-! # C5.b: Centering the affine model is without loss

Paper: technical-appendices-v3.tex lines 87-97, paragraph "Centering the affine model". -/

namespace TinaV2.C05b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- With `b(θ) = Bθ + b₀` and `K = Q⁻¹B`, the uncentered desired action is
`x⋆ = Q⁻¹(Bθ + b₀)`. Its centered version is `K θ^c`, and the regret of the
uncentered problem equals the regret of the centered model. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [DecidableEq α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (B : Matrix α κ ℝ) (b₀ : α → ℝ) (snap now : Ω → κ → ℝ) (r : ℕ∞),
    M.K = M.Q⁻¹ * B → MemLp now 2 μ →
    let xstar : Ω → α → ℝ := fun ω => M.Q⁻¹ *ᵥ (B *ᵥ now ω + b₀)
    (∀ ω, center μ xstar ω = M.K *ᵥ center μ now ω) ∧
    regret μ M.Q M.actor xstar (M.obs r snap) = M.R μ r (center μ snap) (center μ now)

end TinaV2.C05b
