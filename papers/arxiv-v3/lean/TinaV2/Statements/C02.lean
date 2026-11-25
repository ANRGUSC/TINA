import TinaV2.Defs

/-! # C2: Coupled conditional normal equations

Paper: technical-appendices-v3.tex lines 220-269, Corollary (conditional_normal_equations), Eqs. (conditional_normal_equations), (block_conditional_normal_equations). -/

namespace TinaV2.C02

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the architecture `𝒜 = (𝒢_i)` and the cost `f(x,θ) = ½ xᵀQx − b(θ)ᵀx + c(θ)`
with `x⋆ = Q⁻¹ b(θ_t)`:
1. the team optimum of Lemma (radner_projection), `Π_{𝒮(𝒜)} x⋆`, satisfies
   `E[(Q u⋆ − b(θ_t))_i | 𝒢_i] = 0` for every agent `i`;
2. the equations are sufficient: an admissible policy that satisfies them is
   optimal, and is the unique optimal policy up to almost-sure equality;
3. for an admissible policy the equations are equivalent to the block form
   `Q_ii u_i + Σ_{j≠i} Q_ij E[u_j | 𝒢_i] = E[b_i(θ_t) | 𝒢_i]`. -/
def Statement : Prop :=
  ∀ {ι α Ω : Type} [Fintype α] [DecidableEq α] [DecidableEq ι] [m0 : MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ) (c : Ω → ℝ),
    Q.PosDef → (∀ i, 𝒢 i ≤ m0) → MemLp b 2 μ → Integrable c μ →
    let xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω
    let S := policySpace μ actor 𝒢
    (∀ p, IsQProjection μ Q S xstar p → NormalEquations μ Q actor 𝒢 b p) ∧
    (∀ u ∈ S, NormalEquations μ Q actor 𝒢 b u →
      (∀ v ∈ S, expectedCost μ Q b c u ≤ expectedCost μ Q b c v) ∧
      (∀ v ∈ S, expectedCost μ Q b c v ≤ expectedCost μ Q b c u → v =ᵐ[μ] u)) ∧
    (∀ u ∈ S, NormalEquations μ Q actor 𝒢 b u ↔ BlockNormalEquations μ Q actor 𝒢 b u)

end TinaV2.C02
