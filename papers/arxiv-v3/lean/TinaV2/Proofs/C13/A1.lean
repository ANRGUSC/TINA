import TinaV2.Statements

/-! # C13, attempt A1: mirrors the supplement proof C13/p1

The paper states the explicit threshold of the aggregate-coupling model and
the equivalence after it without argument (`main-v3.tex` 629-661: "combining
Proposition (aggregate_local) with Theorem (local_global_crossover) gives an
explicit threshold"). The proof mirrored here is not in the paper. It is the
supplement proof `C13/p1` in the ledger
(`python3 tools/ledger.py supplement C13`), written for the formalization
under disposition `C13/d1`. One lemma per step of that proof, in its order,
then `main`. The proposition C12 and the crossover theorem C10 enter as the
hypotheses `hC12 : C12.Statement` and `hC10 : C10.Statement`. -/

namespace TinaV2.C13.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

/-- Step 1 (supplied). "By Proposition (aggregate_local), `η_S(0)` is the right
side of Eq. (aggregate_eta), and
`R_∞ = nσ²(q + γ(n−1)) / (2q(q + γn))` (Eq. (aggregate_Rinf)), which is
positive because `n ≥ 2`, `σ > 0`, `q > 0` and `γ ≥ 0`." -/
theorem s1_closed_forms (hC12 : C12.Statement) (n : ℕ) (q γ σ : ℝ) (hn : 2 ≤ n)
    (hq : 0 < q) (hγ : 0 ≤ γ) (hσ : 0 < σ) (M : Model (Fin n) (Fin n) (Fin n))
    (hM : IsAggregateModel M q γ) {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (now : Ω → Fin n → ℝ) (hS : AggregateState μ now σ) :
    M.etaS μ 0 now = aggEta n q γ ∧ 0 < M.Rinf μ now := by
  obtain ⟨-, hRinf, -, hη⟩ := hC12 n q γ σ hn hq hγ hσ M hM μ now hS
  refine ⟨hη, ?_⟩
  have hn2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hn1 : (0 : ℝ) ≤ (n : ℝ) - 1 := by linarith
  have hnum : 0 < q + γ * ((n : ℝ) - 1) := add_pos_of_pos_of_nonneg hq (mul_nonneg hγ hn1)
  have hnpos : (0 : ℝ) < n := by linarith
  rw [hRinf, aggRinf]
  exact div_pos (mul_pos (mul_pos hnpos (pow_pos hσ 2)) hnum) (by positivity)

/-- Step 2 (supplied). "Write `η` for the right side of Eq. (aggregate_eta).
Since `(q+γ)(q + γ(n−1)) − γ²(n−1) = q(q + γn)`,
`1 − η = q(q + γn) / ((q+γ)(q + γ(n−1)))`, which is positive. So `η < 1`, and
`½ log(1/(1 − η))` is the right side of Eq. (aggregate_rho_star)." -/
theorem s2_threshold (n : ℕ) (q γ : ℝ) (hn : 2 ≤ n) (hq : 0 < q) (hγ : 0 ≤ γ) :
    aggEta n q γ < 1 ∧ rhoStar (aggEta n q γ) = aggRhoStar n q γ := by
  have hn2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hn1 : (0 : ℝ) ≤ (n : ℝ) - 1 := by linarith
  have h1 : 0 < q + γ := by positivity
  have h2 : 0 < q + γ * ((n : ℝ) - 1) := add_pos_of_pos_of_nonneg hq (mul_nonneg hγ hn1)
  have h3 : 0 < q + γ * (n : ℝ) := by positivity
  have hone : 1 - aggEta n q γ = q * (q + γ * n) / ((q + γ) * (q + γ * (n - 1))) := by
    rw [aggEta]
    field_simp
    ring
  have hpos : 0 < 1 - aggEta n q γ := by
    rw [hone]
    exact div_pos (mul_pos hq h3) (mul_pos h1 h2)
  refine ⟨by linarith, ?_⟩
  rw [rhoStar, aggRhoStar, hone, one_div_div]

/-- Step 3 (supplied). "By steps 1 and 2, `R_∞ > 0`, `η_S(0) < 1` and
`ρ⋆ = ½ log(1/(1 − η_S(0))) = ρ⋆(γ,n)`. So the first case of Theorem
(local_global_crossover) applies: `R_loc < R_glob(τ)` exactly when
`τ/T > ρ⋆ = ρ⋆(γ,n)`, which is Eq. (aggregate_crossover)." -/
theorem s3_crossover (hC10 : C10.Statement) (hC12 : C12.Statement) (n : ℕ) (q γ σ : ℝ)
    (hn : 2 ≤ n) (hq : 0 < q) (hγ : 0 ≤ γ) (hσ : 0 < σ)
    (M : Model (Fin n) (Fin n) (Fin n)) (hM : IsAggregateModel M q γ) {Ω : Type}
    [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → Ω → Fin n → ℝ) (T t τ : ℝ) (hA : TemporalAssumption μ θ T t τ)
    (hS : AggregateState μ (θ t) σ) :
    rhoStar (M.etaS μ 0 (θ t)) = aggRhoStar n q γ ∧
      (M.Rloc μ (θ t) < M.Rglob μ (θ (t - τ)) (θ t) ↔ aggRhoStar n q γ < τ / T) := by
  obtain ⟨hη, hR⟩ := s1_closed_forms hC12 n q γ σ hn hq hγ hσ M hM μ (θ t) hS
  obtain ⟨hlt, hρ⟩ := s2_threshold n q γ hn hq hγ
  have h := ((hC10 M μ θ T t τ hA hR).1 (by rw [hη]; exact hlt)).1
  rw [hη, hρ] at h
  exact ⟨by rw [hη, hρ], h⟩

/-- Eqs. (aggregate_rho_star) and (aggregate_crossover). -/
theorem main (hC10 : C10.Statement) (hC12 : C12.Statement) : C13.Statement := by
  intro n q γ σ hn hq hγ hσ M hM Ω _ μ _ θ T t τ hA hS
  exact s3_crossover hC10 hC12 n q γ σ hn hq hγ hσ M hM μ θ T t τ hA hS

end TinaV2.C13.A1
