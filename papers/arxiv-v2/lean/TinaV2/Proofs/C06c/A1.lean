import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection
import TinaV2.Routine.RadiusInfo

/-! # C6.c, attempt A1: mirrors paper proof C6.c/p1, with two supplied steps

Paper: `main-v2.tex` 317-326. The paper argues the monotonicity clause
("extra observations can be ignored", step 1) and the diameter clause (step 2).
Two steps are supplied by the formalization and are not in the paper:

* step 0a, the range `0 ≤ η_S(r) ≤ 1`, which the paper states in
  Eq. (eta_S_definition) without argument (disposition `C6.c/d1`);
* step 0b, the link between the main text's rules `u_i = g_i(Z_i)` and the
  appendix's `σ(Z_i)`-measurable policies (finding F6, disposition `F6.1`),
  needed because step 1 applies the appendix's information inclusion C1.c to
  the main text's radius architectures.

One lemma per step, in order, then `main`. Information inclusion C1.c enters as
the hypothesis `hC1c : C01c.Statement`. -/

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

/-- Step 0b (supplied). "The observation `Z_i` of Eq. (radius_arch) takes values
in a finite-dimensional space, so a random variable is `σ(Z_i)`-measurable
exactly when it is a measurable function of `Z_i` (Doob–Dynkin). Hence the
regret of Eq. (architecture_regret), over rules `u_i = g_i(Z_i)`, equals the
regret of the appendix's architecture `𝒢_i = σ(Z_i)`, over the policy space of
Eq. (policy_subspace)." -/
theorem s0b_link (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ] (r : ℕ∞)
    (snap now : Ω → κ → ℝ) :
    M.R μ r snap now = sigmaRegret μ M.Q M.actor (M.target now)
      (fun i => MeasurableSpace.comap (M.obs r snap i) inferInstance) := by
  unfold Model.R
  apply le_antisymm
  · -- a `σ(Z_i)`-measurable policy is a measurable function of `Z_i` (Doob–Dynkin)
    refine le_sigmaRegret _ fun u hu => ?_
    have hfac : ∀ c, ∃ h : (M.Scope r (M.actor c) → ℝ) → ℝ,
        Measurable h ∧ (fun ω => u ω c) = h ∘ M.obs r snap (M.actor c) :=
      fun c => (hu.1 c).exists_eq_measurable_comp
    choose g hg hug using hfac
    have hu' : jointAction g (M.obs r snap) = u := by
      funext ω c
      exact (congrFun (hug c) ω).symm
    have hadm : Admissible μ (M.obs r snap) g := ⟨hg, by rw [hu']; exact hu.2⟩
    have hle := regret_le μ M.Q_posDef (M.target now) (M.obs r snap) hadm
    rwa [hu'] at hle
  · -- a measurable function of `Z_i` is `σ(Z_i)`-measurable
    refine le_ciInf fun g => ?_
    refine sigmaRegret_le M.Q_posDef _ ⟨fun c => ?_, g.2.2⟩
    exact (g.2.1 c).comp (comap_measurable (M.obs r snap (M.actor c)))

/-- Step 1 (main-v2.tex 323-324). "Larger fresh neighborhoods cannot increase
it, since their extra observations can be ignored." For `r ≤ r'` the radius-`r`
view is a restriction of the radius-`r'` view, so `σ(Z_i^{(r)}) ⊆ σ(Z_i^{(r')})`;
information inclusion C1.c and the link of step 0b give the inequality. -/
theorem s1_monotone (hC1c : C01c.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (now : Ω → κ → ℝ) (hm : Measurable now) (h2 : MemLp now 2 μ)
    (hR : 0 < M.Rinf μ now) (r r' : ℕ∞) (hrr : r ≤ r') :
    M.etaS μ r' now ≤ M.etaS μ r now := by
  -- the radius-`r` view is a restriction of the radius-`r'` view
  have hsub : ∀ i, MeasurableSpace.comap (M.obs r now i) inferInstance
      ≤ MeasurableSpace.comap (M.obs r' now i) inferInstance := by
    intro i
    rw [← M.restrictView_comp_obs hrr now i, ← MeasurableSpace.comap_comp]
    exact MeasurableSpace.comap_mono (M.measurable_restrictView hrr i).comap_le
  have hamb : ∀ i, MeasurableSpace.comap (M.obs r' now i) inferInstance ≤ ‹MeasurableSpace Ω› :=
    fun i => (M.measurable_obs r' hm i).comap_le
  -- information inclusion C1.c, transported by the link of step 0b
  have h := (hC1c μ M.Q M.actor (M.target now) _ _ M.Q_posDef (M.memLp_target h2) hsub hamb).2
  rw [← s0b_link M μ r' now now, ← s0b_link M μ r now now] at h
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
theorem main (hC1c : C01c.Statement) : C06c.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ now hm h2 hR
  exact ⟨fun r => s0a_range M μ now hR r,
    fun r r' hrr => s1_monotone hC1c M μ now hm h2 hR r r' hrr,
    fun hc => s2_diameter M μ now h2 hc⟩

end TinaV2.C06c.A1
