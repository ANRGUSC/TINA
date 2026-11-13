import TinaV2.Prelude

/-! # Mean squared error of the best estimate (claim C11, two-sensor example)

Paper: `main-alt.tex`, paragraph "A two-sensor example". -/

noncomputable section

namespace TinaV2

open MeasureTheory

/-- Smallest mean squared error in estimating `target` by a function of the
observation `obs` with finite second moment. -/
def bestMSE {Ω O : Type} [MeasurableSpace Ω] [MeasurableSpace O] (μ : Measure Ω)
    (target : Ω → ℝ) (obs : Ω → O) : ℝ :=
  ⨅ g : {g : O → ℝ // Measurable g ∧ MemLp (fun ω => g (obs ω)) 2 μ},
    ∫ ω, (target ω - g.1 (obs ω)) ^ 2 ∂μ

end TinaV2
