import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.RadiusInfo

/-! # C6.c, attempt A1: mirrors paper proof C6.c/p1, with one supplied step

Paper: `main-v2.tex` 317-326. The paper argues the monotonicity clause
("extra observations can be ignored", step 1) and the diameter clause (step 2).
One step is supplied by the formalization and is not in the paper: step 0a, the
range `0 ≤ η_S(r) ≤ 1`, which the paper states in Eq. (eta_S_definition)
without argument (disposition `C6.c/d1`).

One lemma per step, in order, then `main`. Step 1 is the paper's argument taken
literally: a rule of the smaller view is a rule of the larger view that ignores
the extra observations. It uses neither information inclusion C1.c nor the link
between the main text's rules and the appendix's sigma-algebra policies; that
link is proved separately as `Model.R_eq_sigmaRegret` in
`Routine/RadiusInfo.lean` (finding F6, disposition `F6.1`). -/

namespace TinaV2.C06c.A1

open MeasureTheory ProbabilityTheory Matrix

variable {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 0a (supplied). "Regret is nonnegative because `Q ≻ 0`. It is at most
`R_∞` because the zero rule is admissible at every radius and its expected
excess cost is `½ E[x⋆ᵀQx⋆] = R_∞`. Dividing by `R_∞ > 0` gives
`0 ≤ η_S(r) ≤ 1`." -/
theorem s0a_range (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (hR : 0 < M.Rinf μ now) (r : ℕ∞) :
    0 ≤ M.etaS μ r now ∧ M.etaS μ r now ≤ 1 := by
  -- regret is nonnegative because `Q ≻ 0`
  have h0 : 0 ≤ M.R μ r now now := regret_nonneg μ M.Q_posDef _ _
  -- the zero rule is admissible and its expected excess cost is `R_∞`
  have h1 : M.R μ r now now ≤ M.Rinf μ now := by
    have hle := regret_le μ M.Q_posDef (M.target now) (M.obs r now)
      (admissible_zero (actor := M.actor) μ (M.obs r now))
    rwa [jointAction_zero, M.excessCost_zero_eq_Rinf μ now] at hle
  -- divide by `R_∞ > 0`
  unfold Model.etaS
  exact ⟨div_nonneg h0 hR.le, (div_le_one hR).2 h1⟩

/-- Step 1 (main-v2.tex 323-324). "Larger fresh neighborhoods cannot increase
it, since their extra observations can be ignored." For `r ≤ r'`, a rule `g` of
the radius-`r` views becomes a rule of the radius-`r'` views by first forgetting
the coordinates outside the smaller scope; it produces the same joint action,
so every cost attainable at radius `r` is attainable at radius `r'`. -/
theorem s1_monotone (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (hR : 0 < M.Rinf μ now) (r r' : ℕ∞) (hrr : r ≤ r') :
    M.etaS μ r' now ≤ M.etaS μ r now := by
  have h : M.R μ r' now now ≤ M.R μ r now now := by
    unfold Model.R
    refine le_ciInf fun g => ?_
    -- ignore the extra observations: restrict the larger view, then apply `g`
    let g' : Rule M.actor fun i => M.Scope r' i → ℝ :=
      fun c o => g.1 c (M.restrictView hrr (M.actor c) o)
    -- the two rules produce the same joint action
    have hu : jointAction g' (M.obs r' now) = jointAction g.1 (M.obs r now) := rfl
    have hadm : Admissible μ (M.obs r' now) g' :=
      ⟨fun c => (g.2.1 c).comp (M.measurable_restrictView hrr (M.actor c)), by
        rw [hu]
        exact g.2.2⟩
    have hle := regret_le μ M.Q_posDef (M.target now) (M.obs r' now) hadm
    rwa [hu] at hle
  unfold Model.etaS
  exact div_le_div_of_nonneg_right h hR.le

/-- Step 2 (main-v2.tex 325-326). "at the diameter of a finite connected graph
the fresh view is complete and omission is zero." -/
theorem s2_diameter [Fintype ι] (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (h2 : MemLp now 2 μ) (hc : M.G.Connected) :
    M.etaS μ (M.G.diam : ℕ∞) now = 0 := by
  -- at the diameter every agent sees every state coordinate, so `x⋆ = K θ` is feasible
  have hfeas : M.R μ (M.G.diam : ℕ∞) now now = 0 := by
    let g : Rule M.actor fun i => M.Scope (M.G.diam : ℕ∞) i → ℝ :=
      fun c o => ∑ k, M.K c k * o ⟨k, M.mem_nbhd_diam hc (M.actor c) (M.owner k)⟩
    have hu : jointAction g (M.obs (M.G.diam : ℕ∞) now) = M.target now := by
      funext ω c
      simp [g, jointAction, Model.obs, Model.view, Model.target, mulVec, dotProduct]
    have hg : Admissible μ (M.obs (M.G.diam : ℕ∞) now) g :=
      ⟨fun c => Finset.measurable_sum _ fun k _ => (measurable_pi_apply _).const_mul _, by
        rw [hu]
        exact M.memLp_target h2⟩
    refine le_antisymm ?_ (regret_nonneg μ M.Q_posDef _ _)
    have hle := regret_le μ M.Q_posDef (M.target now) (M.obs (M.G.diam : ℕ∞) now) hg
    rw [hu] at hle
    simpa [Model.R, excessCost, quad] using hle
  unfold Model.etaS
  rw [hfeas, zero_div]

/-- Eq. (eta_S_definition) and the paragraph after it. -/
theorem main : C06c.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ now _ h2 hR
  exact ⟨fun r => s0a_range M μ now hR r,
    fun r r' hrr => s1_monotone M μ now hR r r' hrr,
    fun hc => s2_diameter M μ now h2 hc⟩

end TinaV2.C06c.A1
