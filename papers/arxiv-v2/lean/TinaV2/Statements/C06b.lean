import TinaV2.Defs

/-! # C6.b: No-information loss formula

Paper: main-v2.tex Eq. (Rinf_general). -/

namespace TinaV2.C06b

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- In centered coordinates no constant action beats zero, the zero action
costs `R_∞`, and `R_∞ = ½ tr(Kᵀ Q K Σ_S)`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (now : Ω → κ → ℝ),
    Measurable now → MemLp now 2 μ → (∀ k, ∫ ω, now ω k ∂μ = 0) →
    (∀ u₀ : α → ℝ, M.Rinf μ now ≤ excessCost μ M.Q (M.target now) (fun _ => u₀)) ∧
    excessCost μ M.Q (M.target now) (fun _ => 0) = M.Rinf μ now ∧
    M.Rinf μ now = 1 / 2 * Matrix.trace (M.Kᵀ * M.Q * M.K * covMatrix μ now)

end TinaV2.C06b
