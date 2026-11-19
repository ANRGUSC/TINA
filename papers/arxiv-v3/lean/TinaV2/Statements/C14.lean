import TinaV2.Defs

/-! # C14: Radius objective and one-more-hop criterion

Paper: main-v3.tex Eqs. (snapshot_gain), (discrete_radius_improvement), (R_decomposition). -/

namespace TinaV2.C14

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Graph radii, delay `τ(r)` at radius `r`, `R(r) = R(𝒜_{r,τ(r)})`,
`G(r) = (1 − η_S(r)) e^{−2τ(r)/T}`, `R_∞ > 0`:
`R(r) = R_∞ [1 − G(r)]`; one more hop lowers regret exactly when
`G(r+1) > G(r)`; and `R(r)/R_∞ = (1 − e^{−2τ(r)/T}) + e^{−2τ(r)/T} η_S(r)`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ) (τ : ℕ∞ → ℝ),
    (∀ r, TemporalAssumption μ θ T t (τ r)) → 0 < M.Rinf μ (θ t) →
    let Rr : ℕ∞ → ℝ := fun r => M.R μ r (θ (t - τ r)) (θ t)
    let G : ℕ∞ → ℝ := gain (fun r => M.etaS μ r (θ t)) τ T
    (∀ r, Rr r = M.Rinf μ (θ t) * (1 - G r)) ∧
    (∀ r, Rr (r + 1) < Rr r ↔ G r < G (r + 1)) ∧
    (∀ r, Rr r / M.Rinf μ (θ t)
      = (1 - exp (-2 * τ r / T)) + exp (-2 * τ r / T) * M.etaS μ r (θ t))

end TinaV2.C14
