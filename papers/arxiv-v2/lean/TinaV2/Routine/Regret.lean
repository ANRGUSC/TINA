import TinaV2.Defs

/-! # Routine facts about the quadratic form, rules and regret

What the paper leaves unsaid when it manipulates `E[(u − x⋆)ᵀ Q (u − x⋆)]` and
the infimum over admissible rules: ring identities for the quadratic form,
measurability, integrability of products of square-integrable vectors,
nonemptiness and boundedness of the family the infimum runs over, and
linearity of conditional expectation.

Nothing here is a step of a paper proof. This file imports `Defs/` only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory Set

variable {Ω : Type} [MeasurableSpace Ω] {ι κ α : Type} [Fintype κ] [Fintype α]

/-! ## Ring identities for `vᵀ Q v` -/

/-- `wᵀ Q v = vᵀ Q w` for symmetric `Q`. -/
theorem dotProduct_mulVec_comm {Q : Matrix α α ℝ} (hQ : Q.IsHermitian) (v w : α → ℝ) :
    w ⬝ᵥ (Q *ᵥ v) = v ⬝ᵥ (Q *ᵥ w) := by
  have hT : Qᵀ = Q := by simpa [conjTranspose_eq_transpose_of_trivial] using hQ.eq
  rw [dotProduct_mulVec, dotProduct_comm, ← mulVec_transpose, hT]

/-- Expanding the square: `(v+w)ᵀQ(v+w) = vᵀQv + 2 vᵀQw + wᵀQw`. -/
theorem quad_add {Q : Matrix α α ℝ} (hQ : Q.IsHermitian) (v w : α → ℝ) :
    quad Q (v + w) = quad Q v + 2 * (v ⬝ᵥ (Q *ᵥ w)) + quad Q w := by
  simp only [quad, mulVec_add, dotProduct_add, add_dotProduct]
  rw [dotProduct_mulVec_comm hQ v w]
  ring

/-- `(a v)ᵀ Q (a v) = a² vᵀ Q v`. -/
theorem quad_smul (Q : Matrix α α ℝ) (a : ℝ) (v : α → ℝ) :
    quad Q (a • v) = a ^ 2 * quad Q v := by
  simp only [quad, mulVec_smul, smul_dotProduct, dotProduct_smul, smul_eq_mul]
  ring

/-- `(v − w)ᵀ Q (v − w) = (w − v)ᵀ Q (w − v)`. -/
theorem quad_sub_comm (Q : Matrix α α ℝ) (v w : α → ℝ) :
    quad Q (v - w) = quad Q (w - v) := by
  have h : v - w = (-1 : ℝ) • (w - v) := by simp
  rw [h, quad_smul]
  ring

/-- `vᵀ Q v ≥ 0` for `Q ≻ 0`. -/
theorem quad_nonneg {Q : Matrix α α ℝ} (hQ : Q.PosDef) (v : α → ℝ) : 0 ≤ quad Q v := by
  simpa [quad] using hQ.posSemidef.dotProduct_mulVec_nonneg v

/-! ## Measurability -/

theorem measurable_mulVec (A : Matrix α κ ℝ) : Measurable fun s : κ → ℝ => A *ᵥ s :=
  (Matrix.mulVecLin A).continuous_of_finiteDimensional.measurable

theorem measurable_quad (Q : Matrix α α ℝ) : Measurable (quad Q) := by
  unfold quad dotProduct
  exact Finset.measurable_sum _ fun c _ =>
    (measurable_pi_apply c).mul ((measurable_pi_apply c).comp (measurable_mulVec Q))

/-! ## Integrability of products of square-integrable vectors -/

theorem memLp_mulVec {μ : Measure Ω} (A : Matrix α κ ℝ) {X : Ω → κ → ℝ} (hX : MemLp X 2 μ) :
    MemLp (fun ω => A *ᵥ X ω) 2 μ := by
  refine memLp_pi_iff.2 fun c => ?_
  have h : (fun ω => (A *ᵥ X ω) c) = fun ω => ∑ k, A c k * X ω k := by
    funext ω; simp [mulVec, dotProduct]
  rw [h]
  exact memLp_finsetSum _ fun k _ => (memLp_pi_iff.1 hX k).const_mul (A c k)

theorem integrable_dotProduct_mulVec {μ : Measure Ω} (Q : Matrix α α ℝ) {u w : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hw : MemLp w 2 μ) : Integrable (fun ω => u ω ⬝ᵥ (Q *ᵥ w ω)) μ := by
  have hQw := memLp_mulVec Q hw
  simp only [dotProduct]
  exact integrable_finsetSum _ fun c _ =>
    (memLp_pi_iff.1 hu c).integrable_mul (memLp_pi_iff.1 hQw c)

theorem integrable_quad {μ : Measure Ω} (Q : Matrix α α ℝ) {u : Ω → α → ℝ} (hu : MemLp u 2 μ) :
    Integrable (fun ω => quad Q (u ω)) μ :=
  integrable_dotProduct_mulVec Q hu hu

/-! ## Rules and the family the infimum runs over -/

/-- A family of nonnegative reals is bounded below. -/
theorem bddBelow_range_of_nonneg {β : Sort*} {f : β → ℝ} (hf : ∀ i, 0 ≤ f i) :
    BddBelow (range f) :=
  ⟨0, by rintro _ ⟨i, rfl⟩; exact hf i⟩

section Rules

variable {actor : α → ι} {O : ι → Type} [∀ i, MeasurableSpace (O i)]

/-- The zero rule is admissible. -/
theorem admissible_zero (μ : Measure Ω) (Z : (i : ι) → Ω → O i) :
    Admissible μ Z (fun _ _ => 0 : Rule actor O) :=
  ⟨fun _ => measurable_const, MemLp.zero⟩

omit [MeasurableSpace Ω] [Fintype α] [∀ i, MeasurableSpace (O i)] in
/-- The joint action of the zero rule is zero. -/
theorem jointAction_zero (Z : (i : ι) → Ω → O i) :
    jointAction (fun _ _ => 0 : Rule actor O) Z = 0 := rfl

/-- A scalar multiple of an admissible rule is admissible. -/
theorem Admissible.const_mul {μ : Measure Ω} {Z : (i : ι) → Ω → O i} {g : Rule actor O}
    (hg : Admissible μ Z g) (a : ℝ) : Admissible μ Z (fun c o => a * g c o) :=
  ⟨fun c => (hg.1 c).const_mul a, hg.2.const_smul a⟩

omit [MeasurableSpace Ω] [Fintype α] [∀ i, MeasurableSpace (O i)] in
/-- The joint action of a scaled rule is the scaled joint action. -/
theorem jointAction_const_mul (g : Rule actor O) (Z : (i : ι) → Ω → O i) (a : ℝ) (ω : Ω) :
    jointAction (fun c o => a * g c o) Z ω = a • jointAction g Z ω := rfl

instance nonempty_admissible (μ : Measure Ω) (Z : (i : ι) → Ω → O i) :
    Nonempty {g : Rule actor O // Admissible μ Z g} :=
  ⟨⟨_, admissible_zero μ Z⟩⟩

theorem excessCost_nonneg (μ : Measure Ω) {Q : Matrix α α ℝ} (hQ : Q.PosDef)
    (xstar u : Ω → α → ℝ) : 0 ≤ excessCost μ Q xstar u :=
  mul_nonneg (by norm_num) (integral_nonneg fun _ => quad_nonneg hQ _)

/-- Regret is nonnegative for `Q ≻ 0`. -/
theorem regret_nonneg (μ : Measure Ω) {Q : Matrix α α ℝ} (hQ : Q.PosDef)
    (xstar : Ω → α → ℝ) (Z : (i : ι) → Ω → O i) : 0 ≤ regret μ Q actor xstar Z :=
  Real.iInf_nonneg fun _ => excessCost_nonneg μ hQ _ _

/-- Regret is at most the excess cost of any admissible rule. -/
theorem regret_le (μ : Measure Ω) {Q : Matrix α α ℝ} (hQ : Q.PosDef)
    (xstar : Ω → α → ℝ) (Z : (i : ι) → Ω → O i) {g : Rule actor O} (hg : Admissible μ Z g) :
    regret μ Q actor xstar Z ≤ excessCost μ Q xstar (jointAction g Z) :=
  ciInf_le (f := fun g : {g : Rule actor O // Admissible μ Z g} =>
      excessCost μ Q xstar (jointAction g.1 Z))
    (bddBelow_range_of_nonneg fun _ => excessCost_nonneg μ hQ _ _) ⟨g, hg⟩

end Rules

/-- A constant added to every member moves out of the infimum. -/
theorem ciInf_add_const {β : Sort*} [Nonempty β] {f : β → ℝ} (hf : BddBelow (range f)) (c : ℝ) :
    ⨅ i, (f i + c) = (⨅ i, f i) + c := by
  have hf' : BddBelow (range fun i => f i + c) := by
    obtain ⟨b, hb⟩ := hf
    exact ⟨b + c, by rintro _ ⟨i, rfl⟩; linarith [hb ⟨i, rfl⟩]⟩
  apply le_antisymm
  · have : (⨅ i, (f i + c)) - c ≤ ⨅ i, f i :=
      le_ciInf fun i => by linarith [ciInf_le hf' i]
    linarith
  · exact le_ciInf fun i => by linarith [ciInf_le hf i]

/-! ## The model: observations are functions of the snapshot -/

namespace Model

variable (M : Model ι κ α)

theorem measurable_view (r : ℕ∞) (i : ι) : Measurable (M.view r i) :=
  measurable_pi_lambda _ fun k => measurable_pi_apply k.1

/-- The joint action of a rule on radius-`r` views is one measurable function of
the whole snapshot. -/
theorem measurable_jointAction_view (r : ℕ∞) {g : Rule M.actor fun i => M.Scope r i → ℝ}
    (hg : ∀ c, Measurable (g c)) :
    Measurable fun s : κ → ℝ => fun c => g c (M.view r (M.actor c) s) :=
  measurable_pi_lambda _ fun c => (hg c).comp (M.measurable_view r (M.actor c))

omit [MeasurableSpace Ω] in
theorem jointAction_obs (r : ℕ∞) (g : Rule M.actor fun i => M.Scope r i → ℝ)
    (snap : Ω → κ → ℝ) (ω : Ω) :
    jointAction g (M.obs r snap) ω = fun c => g c (M.view r (M.actor c) (snap ω)) := rfl

/-- The desired action is square-integrable when the state is. -/
theorem memLp_target {μ : Measure Ω} {now : Ω → κ → ℝ} (h : MemLp now 2 μ) :
    MemLp (M.target now) 2 μ :=
  memLp_mulVec M.K h

/-- Two snapshots with the same law admit the same rules: the observation
pattern is the same and the second moment of the action depends only on the
law of the snapshot. -/
theorem admissible_congr {μ : Measure Ω} (r : ℕ∞) {old now : Ω → κ → ℝ}
    (hid : IdentDistrib old now μ μ) (g : Rule M.actor fun i => M.Scope r i → ℝ) :
    Admissible μ (M.obs r old) g ↔ Admissible μ (M.obs r now) g := by
  refine and_congr_right fun hg => ?_
  have h := hid.comp (M.measurable_jointAction_view r hg)
  exact ⟨fun h' => h.memLp_snd h', fun h' => h.symm.memLp_snd h'⟩

end Model

/-! ## Linearity of conditional expectation applied to the prediction rule -/

omit [Fintype α] in
/-- If `E[ε | old] = 0` for the vector `ε = now − a • old`, then each coordinate
of `A ε` has zero conditional expectation given `old`. -/
theorem PredictionRule.condExp_mulVec_apply {μ : Measure Ω} [IsFiniteMeasure μ] {a : ℝ}
    {old now : Ω → κ → ℝ} (h : PredictionRule μ a old now) (hold : MemLp old 2 μ)
    (hnow : MemLp now 2 μ) (A : Matrix α κ ℝ) (c : α) :
    μ[fun ω => (A *ᵥ (now ω - a • old ω)) c | MeasurableSpace.comap old MeasurableSpace.pi]
      =ᵐ[μ] 0 := by
  have hint : Integrable (fun ω => now ω - a • old ω) μ :=
    (hnow.sub (hold.const_smul a)).integrable one_le_two
  let L : (κ → ℝ) →L[ℝ] ℝ :=
    (ContinuousLinearMap.proj c).comp (LinearMap.toContinuousLinearMap (Matrix.mulVecLin A))
  have hL := L.comp_condExp_comm hint
    (m := MeasurableSpace.comap old MeasurableSpace.pi)
  refine hL.symm.trans ?_
  filter_upwards [h] with ω hω
  simp [hω]

end TinaV2
