import TinaV2.Defs

/-! # C6.c: Omission share is in [0,1], nonincreasing, zero at the diameter

Paper: main-v2.tex Eq. (eta_S_definition) and the paragraph after it. -/

namespace TinaV2.C06c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For `R_∞ > 0`: `0 ≤ η_S(r) ≤ 1`; `η_S` is nonincreasing in `r`; on a finite
connected graph `η_S` is zero at the diameter. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (now : Ω → κ → ℝ),
    Measurable now → MemLp now 2 μ → 0 < M.Rinf μ now →
    (∀ r : ℕ∞, 0 ≤ M.etaS μ r now ∧ M.etaS μ r now ≤ 1) ∧
    (∀ r r' : ℕ∞, r ≤ r' → M.etaS μ r' now ≤ M.etaS μ r now) ∧
    (M.G.Connected → M.etaS μ (M.G.diam : ℕ∞) now = 0)

end TinaV2.C06c
