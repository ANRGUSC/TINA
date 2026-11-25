import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection

/-! # Routine facts about radius views (claim C6.c, finding F6)

Bookkeeping the paper leaves unsaid when it compares the radius architectures
of Eq. (radius_arch) at two radii:

* `𝒩_r(i) ⊆ 𝒩_{r'}(i)` for `r ≤ r'`;
* the restriction map that forgets the coordinates outside the smaller scope,
  its measurability, and the fact that it sends the larger view to the smaller;
* on a finite connected graph every hop distance is at most the diameter, so
  the scope at the diameter is every state coordinate;
* the excess cost of the zero action is `R_∞`, by unfolding the definitions.

It also holds the link asked for by finding F6 (disposition `F6.1`):
`Model.R_eq_sigmaRegret`, the main text's regret over rules `u_i = g_i(Z_i)`
equals the appendix's regret of the architecture `𝒢_i = σ(Z_i)`. No proof
attempt uses it; it is the bridge that lets the appendix results (C1, C1.b,
C1.c, C2), stated for sigma-algebras, be read for the radius architectures.

Nothing here is a step of a paper proof. This file imports `Defs/` and the two
routine files above only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix

variable {Ω : Type} [MeasurableSpace Ω] {ι κ α : Type} [Fintype κ] [Fintype α]

namespace Model

variable (M : Model ι κ α)

/-- `𝒩_r(i) ⊆ 𝒩_{r'}(i)` for `r ≤ r'`. -/
theorem nbhd_mono {r r' : ℕ∞} (h : r ≤ r') (i : ι) : M.nbhd r i ⊆ M.nbhd r' i :=
  fun _ hj => le_trans hj h

/-- The restriction map from the radius-`r'` view to the radius-`r` view, for
`r ≤ r'`: forget the coordinates outside the smaller scope. -/
def restrictView {r r' : ℕ∞} (h : r ≤ r') (i : ι) (o : M.Scope r' i → ℝ) : M.Scope r i → ℝ :=
  fun k => o ⟨k.1, M.nbhd_mono h i k.2⟩

theorem measurable_restrictView {r r' : ℕ∞} (h : r ≤ r') (i : ι) :
    Measurable (M.restrictView h i) :=
  Measurable.of_eval fun _ => measurable_pi_apply _

/-- The radius-`r` view is the restriction of the radius-`r'` view. -/
theorem restrictView_view {r r' : ℕ∞} (h : r ≤ r') (i : ι) (s : κ → ℝ) :
    M.restrictView h i (M.view r' i s) = M.view r i s := rfl

omit [MeasurableSpace Ω] in
/-- The radius-`r` observation is the restriction of the radius-`r'`
observation. -/
theorem restrictView_comp_obs {r r' : ℕ∞} (h : r ≤ r') (snap : Ω → κ → ℝ) (i : ι) :
    M.restrictView h i ∘ M.obs r' snap i = M.obs r snap i := rfl

/-- On a finite connected graph every hop distance is at most the diameter. -/
theorem edist_le_diam [Finite ι] (hc : M.G.Connected) (i j : ι) :
    M.G.edist i j ≤ (M.G.diam : ℕ∞) := by
  have : Nonempty ι := hc.nonempty
  have hne : M.G.ediam ≠ ⊤ := SimpleGraph.connected_iff_ediam_ne_top.1 hc
  have hcoe : ((M.G.diam : ℕ) : ℕ∞) = M.G.ediam := ENat.natCast_toNat hne
  rw [hcoe]
  exact SimpleGraph.edist_le_ediam

/-- On a finite connected graph the neighborhood at the diameter is everyone. -/
theorem mem_nbhd_diam [Finite ι] (hc : M.G.Connected) (i j : ι) :
    j ∈ M.nbhd (M.G.diam : ℕ∞) i :=
  M.edist_le_diam hc i j

/-- `R_∞` is the excess cost of the zero action: both are `½ E[x⋆ᵀ Q x⋆]`. -/
theorem excessCost_zero_eq_Rinf (μ : Measure Ω) (now : Ω → κ → ℝ) :
    excessCost μ M.Q (M.target now) 0 = M.Rinf μ now := by
  unfold excessCost Rinf
  congr 2
  funext ω
  rw [quad_sub_comm]
  simp

/-- Finding F6, disposition `F6.1`: the two definitions of regret agree for the
radius architectures. The observation `Z_i` of Eq. (radius_arch) takes values in
a finite-dimensional space, so a random variable is `σ(Z_i)`-measurable exactly
when it is a measurable function of `Z_i` (Doob–Dynkin). Hence the regret of
Eq. (architecture_regret), over rules `u_i = g_i(Z_i)`, equals the regret of the
appendix's architecture `𝒢_i = σ(Z_i)`, over the policy space of
Eq. (policy_subspace). -/
theorem R_eq_sigmaRegret (μ : Measure Ω) (r : ℕ∞) (snap now : Ω → κ → ℝ) :
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

end Model

end TinaV2
