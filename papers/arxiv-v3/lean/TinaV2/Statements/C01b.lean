import TinaV2.Defs

/-! # C1.b: Q-orthogonality and Pythagorean form

Paper: technical-appendices-v2.tex, the two sentences after the proof of Lemma (radner_projection). -/

namespace TinaV2.C01b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the projection `u⋆ = Π_{𝒮(𝒜)} x⋆`: the error `x⋆ − u⋆` is `Q`-orthogonal to
every admissible policy, and `2 R(𝒜) = ‖x⋆‖_Q² − ‖u⋆‖_Q²`. -/
def Statement : Prop :=
  ∀ {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω)
    (xstar : Ω → α → ℝ),
    Q.PosDef → (∀ i, 𝒢 i ≤ m0) → MemLp xstar 2 μ →
    let S := policySpace μ actor 𝒢
    ∀ p, IsQProjection μ Q S xstar p →
      (∀ h ∈ S, qInner μ Q h (xstar - p) = 0) ∧
      2 * sigmaRegret μ Q actor xstar 𝒢 = qNormSq μ Q xstar - qNormSq μ Q p

end TinaV2.C01b
