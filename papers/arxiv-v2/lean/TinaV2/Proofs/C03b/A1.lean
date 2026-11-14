import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Degenerate

/-! # C3.b, attempt A1: mirrors paper proof C3.b/p1

Paper: `technical-appendices-v2.tex`, paragraph "Degenerate normalization"
(lines 287-292). Two steps: `R_∞ = 0` and `Q ≻ 0` force `x⋆ = 0` a.s.; then the
zero rule has zero regret under every architecture, so the unnormalized
composition law holds. -/

namespace TinaV2.C03b.A1

open MeasureTheory ProbabilityTheory Matrix

/-- Step 1 (technical-appendices-v2.tex 289-290): in centered coordinates,
`R_∞ = 0` and `Q ≻ 0` imply `x⋆ = 0` almost surely. -/
theorem s1_target_zero {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) (now : Ω → κ → ℝ) (hnow : MemLp now 2 μ)
    (hR : M.Rinf μ now = 0) : M.target now =ᵐ[μ] 0 := by
  -- `x⋆ᵀ Q x⋆` is integrable (second moments), nonnegative (`Q ≻ 0`), with zero mean
  have hint : Integrable (fun ω => quad M.Q (M.target now ω)) μ :=
    integrable_quad M.Q (M.memLp_target hnow)
  have h0 : ∫ ω, quad M.Q (M.target now ω) ∂μ = 0 := by
    unfold Model.Rinf at hR
    linarith
  -- so it vanishes almost surely
  have hae : (fun ω => quad M.Q (M.target now ω)) =ᵐ[μ] 0 :=
    (integral_eq_zero_iff_of_nonneg (fun ω => quad_nonneg M.Q_posDef _) hint).1 h0
  -- and `Q ≻ 0` turns `x⋆ᵀ Q x⋆ = 0` into `x⋆ = 0`
  filter_upwards [hae] with ω hω
  exact (Degenerate.quad_eq_zero_iff M.Q_posDef _).1 hω

/-- Step 2 (technical-appendices-v2.tex 290-292): the zero rule has zero regret
under every architecture, so the unnormalized composition law remains valid
(both sides are `0`, for every weight `a`). -/
theorem s2_zero_rule {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]
    (M : Model ι κ α) (μ : Measure Ω) (now : Ω → κ → ℝ) (hnow : MemLp now 2 μ)
    (hR : M.Rinf μ now = 0) :
    (∀ (O : ι → Type) [∀ i, MeasurableSpace (O i)] (Z : (i : ι) → Ω → O i),
        regret μ M.Q M.actor (M.target now) Z = 0) ∧
    (∀ (r : ℕ∞) (snap : Ω → κ → ℝ) (a : ℝ),
        M.R μ r snap now = (1 - a ^ 2) * M.Rinf μ now + a ^ 2 * M.R μ r now now) := by
  have h1 : M.target now =ᵐ[μ] 0 := s1_target_zero M μ now hnow hR
  have hzero : ∀ (O : ι → Type) [∀ i, MeasurableSpace (O i)] (Z : (i : ι) → Ω → O i),
      regret μ M.Q M.actor (M.target now) Z = 0 := by
    intro O _ Z
    -- the zero rule costs `½ E[x⋆ᵀ Q x⋆] = 0` because `x⋆ = 0` a.s.
    have hcost : excessCost μ M.Q (M.target now)
        (jointAction (fun _ _ => 0 : Rule M.actor O) Z) = 0 := by
      have hae : (fun ω => quad M.Q
          (jointAction (fun _ _ => 0 : Rule M.actor O) Z ω - M.target now ω)) =ᵐ[μ] 0 := by
        filter_upwards [h1] with ω hω
        simp [hω, jointAction_zero, quad]
      simp [excessCost, integral_congr_ae hae]
    -- the infimum is at most the cost of the zero rule, and no rule costs less than `0`
    have hbdd : BddBelow (Set.range fun g : {g : Rule M.actor O // Admissible μ Z g} =>
        excessCost μ M.Q (M.target now) (jointAction g.1 Z)) :=
      bddBelow_range_of_nonneg fun g => excessCost_nonneg μ M.Q_posDef _ _
    apply le_antisymm
    · calc regret μ M.Q M.actor (M.target now) Z
          ≤ excessCost μ M.Q (M.target now) (jointAction (fun _ _ => 0 : Rule M.actor O) Z) :=
            ciInf_le hbdd ⟨_, admissible_zero μ Z⟩
        _ = 0 := hcost
    · exact le_ciInf fun g => excessCost_nonneg μ M.Q_posDef _ _
  -- every term of the unnormalized law is `0`
  refine ⟨hzero, fun r snap a => ?_⟩
  simp [Model.R, hzero, hR]

theorem main : C03b.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ now _ hnow hR
  exact ⟨s1_target_zero M μ now hnow hR, s2_zero_rule M μ now hnow hR⟩

end TinaV2.C03b.A1
