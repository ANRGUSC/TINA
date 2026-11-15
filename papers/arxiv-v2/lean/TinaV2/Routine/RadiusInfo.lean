import TinaV2.Defs
import TinaV2.Routine.Regret

/-! # Routine facts about radius views (claim C6.c)

Bookkeeping the paper leaves unsaid when it compares the radius architectures
of Eq. (radius_arch) at two radii:

* `𝒩_r(i) ⊆ 𝒩_{r'}(i)` for `r ≤ r'`;
* the restriction map that forgets the coordinates outside the smaller scope,
  its measurability, and the fact that it sends the larger view to the smaller;
* measurability of the observation of a measurable snapshot;
* on a finite connected graph every hop distance is at most the diameter, so
  the scope at the diameter is every state coordinate;
* the excess cost of the zero action is `R_∞`, by unfolding the definitions.

Nothing here is a step of a paper proof. This file imports `Defs/` and the
routine file above only. -/

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
  measurable_pi_lambda _ fun _ => measurable_pi_apply _

/-- The radius-`r` view is the restriction of the radius-`r'` view. -/
theorem restrictView_view {r r' : ℕ∞} (h : r ≤ r') (i : ι) (s : κ → ℝ) :
    M.restrictView h i (M.view r' i s) = M.view r i s := rfl

omit [MeasurableSpace Ω] in
/-- The radius-`r` observation is the restriction of the radius-`r'`
observation. -/
theorem restrictView_comp_obs {r r' : ℕ∞} (h : r ≤ r') (snap : Ω → κ → ℝ) (i : ι) :
    M.restrictView h i ∘ M.obs r' snap i = M.obs r snap i := rfl

/-- The observation of a measurable snapshot is measurable. -/
theorem measurable_obs (r : ℕ∞) {snap : Ω → κ → ℝ} (hs : Measurable snap) (i : ι) :
    Measurable (M.obs r snap i) :=
  (M.measurable_view r i).comp hs

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

end Model

end TinaV2
