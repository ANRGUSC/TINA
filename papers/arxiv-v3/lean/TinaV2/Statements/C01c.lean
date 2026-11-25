import TinaV2.Defs

/-! # C1.c: Information inclusion

Paper: technical-appendices-v3.tex lines 111-119, Eq. (info_inclusion). -/

namespace TinaV2.C01c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `𝒢_i ⊆ 𝒢'_i` for all `i` implies `𝒮(𝒜) ⊆ 𝒮(𝒜')` and `R(𝒜') ≤ R(𝒜)`, in the
appendix's sigma-algebra form, for any square-integrable target; together with
the Doob–Dynkin bridge linking the main text's function-form regret `M.R` to
`sigmaRegret` for `𝒢_i = σ(Z_i)` (finding F6, disposition `F6.1`). -/
def Statement : Prop :=
  (∀ {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι) (xstar : Ω → α → ℝ)
    (𝒢 𝒢' : ι → MeasurableSpace Ω),
    Q.PosDef → MemLp xstar 2 μ → (∀ i, 𝒢 i ≤ 𝒢' i) → (∀ i, 𝒢' i ≤ m0) →
    (∀ u, SigmaAdmissible μ actor 𝒢 u → SigmaAdmissible μ actor 𝒢' u) ∧
      sigmaRegret μ Q actor xstar 𝒢' ≤ sigmaRegret μ Q actor xstar 𝒢) ∧
  (∀ {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) (r : ℕ∞) (snap now : Ω → κ → ℝ),
    M.R μ r snap now = sigmaRegret μ M.Q M.actor (M.target now)
      (fun i => MeasurableSpace.comap (M.obs r snap i) inferInstance))

end TinaV2.C01c
