import TinaV2.Defs.Architecture

/-! # The common temporal prediction rule (claim C4, an assumption)

Paper: `main-v3.tex` lines 328-350, Section "A common temporal prediction rule",
Eq. (state_innovation_decomposition). -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory

variable {Ω : Type} [MeasurableSpace Ω] {κ : Type} [Fintype κ]

/-- "A stationary state process with finite second moments", over a time index
`𝕋` (`ℝ`, or `ℤ` for AR(1)). Stationarity is used in the form the paper names:
"the same one-time distribution at the two epochs" (finding F7). Measurability
of each `θ t` is the regularity the paper leaves implicit. -/
structure StationaryState {𝕋 : Type} (μ : Measure Ω) (θ : 𝕋 → Ω → κ → ℝ) : Prop where
  measurable : ∀ t, Measurable (θ t)
  memLp : ∀ t, MemLp (θ t) 2 μ
  identDistrib : ∀ s t, IdentDistrib (θ s) (θ t) μ μ

/-- Eq. (state_innovation_decomposition) for one pair of epochs:
`now = a • old + ε` with `E[ε | old] = 0`, where `ε = now − a • old` and the
conditioning is on the whole old state. -/
def PredictionRule (μ : Measure Ω) (a : ℝ) (old now : Ω → κ → ℝ) : Prop :=
  condExp (MeasurableSpace.comap old MeasurableSpace.pi) μ (fun ω => now ω - a • old ω)
    =ᵐ[μ] 0

/-- Assumption C4 at epoch `t` and delay `τ`, as used "Under
Theorem (spatiotemporal_composition)": stationary state with finite second
moments, `T > 0`, finite delay `τ ≥ 0`, and
`θ_t = a θ_{t−τ} + ε_{t,τ}`, `a = e^{−τ/T}`, `E[ε_{t,τ} | θ_{t−τ}] = 0`. -/
structure TemporalAssumption (μ : Measure Ω) (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) : Prop where
  stationary : StationaryState μ θ
  T_pos : 0 < T
  τ_nonneg : 0 ≤ τ
  prediction : PredictionRule μ (Real.exp (-τ / T)) (θ (t - τ)) (θ t)

end TinaV2
