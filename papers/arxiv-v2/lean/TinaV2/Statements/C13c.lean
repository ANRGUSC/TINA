import TinaV2.Defs

/-! # C13.c: Threshold behaviour in the coupling strength

Paper: main-alt.tex, last paragraph of Section "Role of Decision Coupling". -/

namespace TinaV2.C13c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- `γ = 0` gives `η_S(0) = 0`; `η_S(0)` and the crossover `ρ⋆(γ,n)` increase
strictly with `γ ≥ 0`. -/
def Statement : Prop :=
  ∀ (n : ℕ) (q : ℝ), 2 ≤ n → 0 < q →
    aggEta n q 0 = 0 ∧
    StrictMonoOn (fun γ => aggEta n q γ) (Ici 0) ∧
    StrictMonoOn (fun γ => aggRhoStar n q γ) (Ici 0)

end TinaV2.C13c
