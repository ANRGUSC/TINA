import TinaV2.Defs

/-! # C13: Explicit aggregate-coupling threshold

Paper: main-alt.tex Eqs. (aggregate_rho_star), (aggregate_crossover). -/

namespace TinaV2.C13

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- In the aggregate-coupling model under the temporal assumption:
`ρ⋆ = ρ⋆(γ,n)` of Eq. (aggregate_rho_star), and
`R_loc < R_glob(τ) ⟺ τ/T > ρ⋆(γ,n)`. -/
def Statement : Prop :=
  ∀ (n : ℕ) (q γ σ : ℝ), 2 ≤ n → 0 < q → 0 ≤ γ → 0 < σ →
    ∀ (M : Model (Fin n) (Fin n) (Fin n)), IsAggregateModel M q γ →
    ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
      (θ : ℝ → Ω → Fin n → ℝ) (T t τ : ℝ),
    TemporalAssumption μ θ T t τ → AggregateState μ (θ t) σ →
    rhoStar (M.etaS μ 0 (θ t)) = aggRhoStar n q γ ∧
    (M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t) ↔ aggRhoStar n q γ < τ / T)

end TinaV2.C13
