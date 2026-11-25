import TinaV2.Defs

/-! # C3: Common information: vector conditional mean is optimal

Paper: technical-appendices-v3.tex lines 271-276, paragraph "Common-information optimality". -/

namespace TinaV2.C03

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- If every agent observes the same `Z` (so `𝒢_i = σ(Z)` for every `i`), then
`m = E[x⋆ | Z]` is admissible, is optimal, and is the unique optimal policy up
to almost-sure equality, for every `Q ≻ 0`. -/
def Statement : Prop :=
  ∀ {ι α Ω O : Type} [Fintype α] [DecidableEq α] [MeasurableSpace Ω] [MeasurableSpace O]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι) (Z : Ω → O)
    (b : Ω → α → ℝ) (c : Ω → ℝ),
    Q.PosDef → Measurable Z → MemLp b 2 μ → Integrable c μ →
    let xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω
    let S := policySpace μ actor fun _ => MeasurableSpace.comap Z inferInstance
    let m : Ω → α → ℝ := μ[xstar | MeasurableSpace.comap Z inferInstance]
    m ∈ S ∧
    (∀ u ∈ S, expectedCost μ Q b c m ≤ expectedCost μ Q b c u) ∧
    (∀ u ∈ S, expectedCost μ Q b c u ≤ expectedCost μ Q b c m → u =ᵐ[μ] m)

end TinaV2.C03
