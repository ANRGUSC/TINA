import TinaV2.Defs

/-! # C1: Fixed-architecture quadratic projection

Paper: technical-appendices-v2.tex Lemma (radner_projection), Eqs. (optimal_projection), (projection_regret). -/

namespace TinaV2.C01

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the architecture `𝒜 = (𝒢_i)` and the cost `f(x,θ) = ½ xᵀQx − b(θ)ᵀx + c(θ)`
with `x⋆ = Q⁻¹ b(θ_t)`:
1. `𝒮(𝒜)` is a closed linear subspace of `ℋ`;
2. the projection `Π_{𝒮(𝒜)} x⋆` exists;
3. it is optimal: no policy in `𝒮(𝒜)` has lower expected cost;
4. it is the unique optimal policy up to almost-sure equality;
5. `R(𝒜) = ½ ‖x⋆ − Π_{𝒮(𝒜)} x⋆‖_Q²`.
Items 3–5 are stated for every `p` that is a projection of `x⋆`, so they do not
depend on which almost-surely-equal version is taken. -/
def Statement : Prop :=
  ∀ {ι α Ω : Type} [Fintype α] [DecidableEq α] [m0 : MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω)
    (b : Ω → α → ℝ) (c : Ω → ℝ),
    Q.PosDef → (∀ i, 𝒢 i ≤ m0) → MemLp b 2 μ → Integrable c μ →
    let xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω
    let S := policySpace μ actor 𝒢
    IsClosedSubspace μ S ∧
    (∃ p, IsQProjection μ Q S xstar p) ∧
    ∀ p, IsQProjection μ Q S xstar p →
      (∀ u ∈ S, expectedCost μ Q b c p ≤ expectedCost μ Q b c u) ∧
      (∀ u ∈ S, expectedCost μ Q b c u ≤ expectedCost μ Q b c p → u =ᵐ[μ] p) ∧
      sigmaRegret μ Q actor xstar 𝒢 = 1 / 2 * qNormSq μ Q (xstar - p)

end TinaV2.C01
