import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Degenerate

/-! # C5.b, attempt A1: mirrors paper proof C5.b/p1

Paper: `technical-appendices-v2.tex`, paragraph "Centering the affine model"
(lines 87-95). Two steps: the centered desired action is `K θ^c`; then
translating each observation and each action by its known mean is a bijection
of the admissible rules that leaves `x − x⋆` unchanged. -/

namespace TinaV2.C05b.A1

open MeasureTheory ProbabilityTheory Matrix

/-- Step 1 (technical-appendices-v2.tex 90-91): "Then the centered desired
action is `x^{⋆,c} = K θ^c`, with `K` as in Eq. (affine_map_and_sensitivity)",
i.e. `K = Q⁻¹ B`. -/
theorem s1_centered_target {ι κ α Ω : Type} [Fintype κ] [Fintype α] [DecidableEq α]
    [MeasurableSpace Ω] (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (B : Matrix α κ ℝ) (b₀ : α → ℝ) (now : Ω → κ → ℝ)
    (hK : M.K = M.Q⁻¹ * B) (hnow : MemLp now 2 μ) (ω : Ω) :
    center μ (fun ω => M.Q⁻¹ *ᵥ (B *ᵥ now ω + b₀)) ω = M.K *ᵥ center μ now ω := by
  rw [hK]
  exact Degenerate.center_affine M.Q⁻¹ B b₀ hnow ω

/-- Step 2 (technical-appendices-v2.tex 92-95): translating each observation
and each action by its known mean gives a bijection of the admissible rules and
leaves `x − x⋆` unchanged; thus the regret of the uncentered problem is the
regret of the main text's tracking loss in centered coordinates. -/
theorem s2_translation_bijection {ι κ α Ω : Type} [Fintype κ] [Fintype α] [DecidableEq α]
    [MeasurableSpace Ω] (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (B : Matrix α κ ℝ) (b₀ : α → ℝ) (snap now : Ω → κ → ℝ) (r : ℕ∞)
    (hK : M.K = M.Q⁻¹ * B) (hnow : MemLp now 2 μ) :
    regret μ M.Q M.actor (fun ω => M.Q⁻¹ *ᵥ (B *ᵥ now ω + b₀)) (M.obs r snap)
      = M.R μ r (center μ snap) (center μ now) := by
  set xstar : Ω → α → ℝ := fun ω => M.Q⁻¹ *ᵥ (B *ᵥ now ω + b₀) with hxstar
  -- the known means: `E[x⋆]` for the actions, the view of `E[θ]` for the observations
  set m : α → ℝ := fun c => ∫ ω, xstar ω c ∂μ with hm
  set a : (i : ι) → M.Scope r i → ℝ := fun i => M.view r i fun k => ∫ ω, snap ω k ∂μ with ha
  have hZ : ∀ i ω, M.obs r (center μ snap) i ω + a i = M.obs r snap i ω :=
    Degenerate.obs_center_add M μ r snap
  -- the centered target is `x⋆ − E[x⋆]`
  have htarget : ∀ ω, M.target (center μ now) ω = xstar ω - m := by
    intro ω
    exact (s1_centered_target M μ B b₀ now hK hnow ω).symm
  -- the translation of rules, with its inverse
  let e : Rule M.actor (fun i => M.Scope r i → ℝ) ≃ Rule M.actor (fun i => M.Scope r i → ℝ) :=
    { toFun := fun g c z => g c (z + a (M.actor c)) - m c
      invFun := fun g c z => g c (z - a (M.actor c)) + m c
      left_inv := fun g => by funext c z; simp
      right_inv := fun g => by funext c z; simp }
  -- it maps admissible rules to admissible rules, in both directions
  have hadm : ∀ g, Admissible μ (M.obs r snap) g ↔
      Admissible μ (M.obs r (center μ snap)) (e g) := by
    intro g
    constructor
    · intro hg
      exact (Degenerate.admissible_translate a m hZ hg).1
    · intro hg
      have hZ' : ∀ i ω, M.obs r snap i ω + (fun i => -a i) i = M.obs r (center μ snap) i ω := by
        intro i ω
        rw [← hZ i ω]
        simp
      have h := (Degenerate.admissible_translate (fun i => -a i) (-m) hZ' hg).1
      have hback : (fun c z => e g c (z + (fun i => -a i) (M.actor c)) - (-m) c) = g := by
        funext c z
        simp [e]
      rwa [hback] at h
  -- and it leaves `x − x⋆` unchanged, hence the cost
  have hcost : ∀ g : {g : Rule M.actor (fun i => M.Scope r i → ℝ) //
      Admissible μ (M.obs r snap) g},
      excessCost μ M.Q (M.target (center μ now))
          (jointAction (e g.1) (M.obs r (center μ snap)))
        = excessCost μ M.Q xstar (jointAction g.1 (M.obs r snap)) := by
    intro g
    have hj : jointAction (e g.1) (M.obs r (center μ snap))
        = fun ω => jointAction g.1 (M.obs r snap) ω - m :=
      (Degenerate.admissible_translate a m hZ g.2).2
    unfold excessCost
    congr 2
    funext ω
    rw [hj, htarget, sub_sub_sub_cancel_right]
  -- a bijection of the index sets that preserves the cost preserves the infimum
  unfold Model.R regret
  exact Equiv.iInf_congr (e.subtypeEquiv hadm) hcost

theorem main : C05b.Statement := by
  intro ι κ α Ω _ _ _ _ _ M μ _ B b₀ snap now r hK hnow
  exact ⟨s1_centered_target M μ B b₀ now hK hnow,
    s2_translation_bijection M μ B b₀ snap now r hK hnow⟩

end TinaV2.C05b.A1
