import TinaV2.Defs

/-! # C12: Local explainability under aggregate coupling

Paper: main-v3.tex lines 577-627, Proposition (aggregate_local), Eqs. (optimal_local_shared), (aggregate_eta); technical-appendices-v3.tex lines 324-352, Eqs. (aggregate_Rinf), (aggregate_Rloc). -/

namespace TinaV2.C12

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- In the aggregate-coupling model with independent, mean-zero, variance-`σ²`
states: the rule `u_i = θ_i/(q+γ)` is admissible for the fresh-local
architecture, attains `R_loc`, and is almost-surely unique among admissible
fresh-local rules attaining `R_loc`; `R_∞` and `R_loc` have the closed forms of
the appendix; and `η_S(0) = γ²(n−1)/((q+γ)(q+γ(n−1)))`. -/
def Statement : Prop :=
  ∀ (n : ℕ) (q γ σ : ℝ), 2 ≤ n → 0 < q → 0 ≤ γ → 0 < σ →
    ∀ (M : Model (Fin n) (Fin n) (Fin n)), IsAggregateModel M q γ →
    ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
      (now : Ω → Fin n → ℝ), AggregateState μ now σ →
    ((∃ g : Rule M.actor (fun i => M.Scope 0 i → ℝ),
      Admissible μ (M.obs 0 now) g ∧
      (∀ ω i, jointAction g (M.obs 0 now) ω i = now ω i / (q + γ)) ∧
      excessCost μ M.Q (M.target now) (jointAction g (M.obs 0 now)) = M.Rloc μ now) ∧
      ∀ g : Rule M.actor (fun i => M.Scope 0 i → ℝ),
        Admissible μ (M.obs 0 now) g →
        excessCost μ M.Q (M.target now) (jointAction g (M.obs 0 now)) ≤ M.Rloc μ now →
        jointAction g (M.obs 0 now) =ᵐ[μ] fun ω i => now ω i / (q + γ)) ∧
    M.Rinf μ now = aggRinf n q γ σ ∧
    M.Rloc μ now = aggRloc n q γ σ ∧
    M.etaS μ 0 now = aggEta n q γ

end TinaV2.C12
