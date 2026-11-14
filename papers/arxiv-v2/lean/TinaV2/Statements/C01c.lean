import TinaV2.Defs

/-! # C1.c: Information inclusion

Paper: technical-appendices-alt.tex Eq. (info_inclusion). -/

namespace TinaV2.C01c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `𝒢_i ⊆ 𝒢'_i` for all `i` implies `𝒮(𝒜) ⊆ 𝒮(𝒜')` and `R(𝒜') ≤ R(𝒜)`, in the
appendix's sigma-algebra form, for any square-integrable target. -/
def Statement : Prop :=
  ∀ {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι) (xstar : Ω → α → ℝ)
    (𝒢 𝒢' : ι → MeasurableSpace Ω),
    Q.PosDef → MemLp xstar 2 μ → (∀ i, 𝒢 i ≤ 𝒢' i) → (∀ i, 𝒢' i ≤ m0) →
    (∀ u, SigmaAdmissible μ actor 𝒢 u → SigmaAdmissible μ actor 𝒢' u) ∧
      sigmaRegret μ Q actor xstar 𝒢' ≤ sigmaRegret μ Q actor xstar 𝒢

end TinaV2.C01c
