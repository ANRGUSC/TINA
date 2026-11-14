import TinaV2.Routine.Regret

/-! # Routine facts for C3.b (degenerate normalization) and C5.b (centering)

Regularity that the paper leaves unsaid and that `Routine/Regret.lean` does not
already provide: a positive definite form vanishes only at zero, translating a
rule by constants keeps it admissible, and the mean of an affine image of an
integrable vector is the affine image of the mean.

Everything is in the namespace `TinaV2.Degenerate`, so that the names cannot
clash with `TinaV2/Routine/Regret.lean`. This file imports `Routine/Regret`
(and through it `Defs/`) only. -/

noncomputable section

namespace TinaV2.Degenerate

open MeasureTheory Matrix

variable {Ω : Type} [MeasurableSpace Ω] {ι κ α : Type} [Fintype κ] [Fintype α]

/-! ## The quadratic form -/

/-- `Q ≻ 0` gives `vᵀ Q v = 0` only for `v = 0`: the definition of positive
definiteness, read contrapositively. -/
theorem quad_eq_zero_iff {Q : Matrix α α ℝ} (hQ : Q.PosDef) (v : α → ℝ) :
    quad Q v = 0 ↔ v = 0 := by
  constructor
  · intro h
    by_contra hv
    have := hQ.dotProduct_mulVec_pos hv
    simp only [star_trivial] at this
    exact this.ne' h
  · rintro rfl
    simp [quad]

/-! ## Translation by constants -/

/-- Translating the observations by constants `a i` and the actions by a
constant `m` keeps a rule admissible: if `Z' i + a i = Z i`, and `g` is
admissible for `Z`, then `z ↦ g (z + a) − m` is admissible for `Z'`
(measurable, and square-integrable because `m` is a constant and the measure is
finite), and its joint action is the joint action of `g` minus `m`. -/
theorem admissible_translate {actor : α → ι} {S : ι → Type} {μ : Measure Ω} [IsFiniteMeasure μ]
    {Z Z' : (i : ι) → Ω → (S i → ℝ)} (a : (i : ι) → S i → ℝ) (m : α → ℝ)
    (hZ : ∀ i ω, Z' i ω + a i = Z i ω) {g : Rule actor fun i => S i → ℝ}
    (hg : Admissible μ Z g) :
    Admissible μ Z' (fun c z => g c (z + a (actor c)) - m c) ∧
      jointAction (fun c z => g c (z + a (actor c)) - m c) Z'
        = fun ω => jointAction g Z ω - m := by
  have hja : jointAction (fun c z => g c (z + a (actor c)) - m c) Z'
      = fun ω => jointAction g Z ω - m := by
    funext ω c
    simp [jointAction, hZ]
  refine ⟨⟨fun c => ?_, ?_⟩, hja⟩
  · exact ((hg.1 c).comp (measurable_id.add_const _)).sub_const _
  · rw [hja]
    exact hg.2.sub (memLp_const m)

/-! ## Centering -/

/-- Centering the snapshot translates every radius-`r` view by the view of the
mean. -/
theorem obs_center_add (M : Model ι κ α) (μ : Measure Ω) (r : ℕ∞) (snap : Ω → κ → ℝ) (i : ι)
    (ω : Ω) :
    M.obs r (center μ snap) i ω + M.view r i (fun k => ∫ ω', snap ω' k ∂μ)
      = M.obs r snap i ω := by
  funext k
  simp [Model.obs, Model.view, center]

omit [Fintype α] in
/-- Linearity of expectation: the centered version of `A θ + v` is `A θ^c`,
for an integrable vector `θ` under a probability measure. -/
theorem center_mulVec_add_const {μ : Measure Ω} [IsProbabilityMeasure μ] (A : Matrix α κ ℝ)
    (v : α → ℝ) {X : Ω → κ → ℝ} (hX : ∀ k, Integrable (fun ω => X ω k) μ) (ω : Ω) :
    center μ (fun ω => A *ᵥ X ω + v) ω = A *ᵥ center μ X ω := by
  funext c
  have hsum : Integrable (fun ω' => ∑ k, A c k * X ω' k) μ :=
    integrable_finsetSum _ fun k _ => (hX k).const_mul (A c k)
  simp only [center, mulVec, dotProduct, Pi.add_apply]
  rw [integral_add hsum (integrable_const _),
    integral_finsetSum _ fun k _ => (hX k).const_mul (A c k)]
  simp only [integral_const_mul, integral_const, probReal_univ, one_smul, mul_sub,
    Finset.sum_sub_distrib]
  ring

/-- The same for the affine desired action `A (B θ + b₀)`: its centered version
is `(A B) θ^c`. With `A = Q⁻¹` and `K = Q⁻¹ B` this is `x^{⋆,c} = K θ^c`. -/
theorem center_affine {μ : Measure Ω} [IsProbabilityMeasure μ] (A : Matrix α α ℝ)
    (B : Matrix α κ ℝ) (b₀ : α → ℝ) {X : Ω → κ → ℝ} (hX : MemLp X 2 μ) (ω : Ω) :
    center μ (fun ω => A *ᵥ (B *ᵥ X ω + b₀)) ω = (A * B) *ᵥ center μ X ω := by
  have h : (fun ω => A *ᵥ (B *ᵥ X ω + b₀)) = fun ω => (A * B) *ᵥ X ω + A *ᵥ b₀ := by
    funext ω
    rw [mulVec_add, mulVec_mulVec]
  rw [h]
  exact center_mulVec_add_const (A * B) (A *ᵥ b₀)
    (fun k => ((memLp_pi_iff.1 hX k).integrable one_le_two)) ω

end TinaV2.Degenerate
