import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Degenerate

/-! # Routine facts about expected cost, the weighted inner product and the
policy space (claims C1, C2, C3)

What the appendix leaves unsaid when it works in `ℋ` with `⟨u,v⟩_Q = E[uᵀQv]`:

* the ring identity `f(u+h) − f(u) = hᵀ(Qu − b) + ½ hᵀQh` and its expectation;
* integrability of the cost and of products of square-integrable vectors;
* bilinearity and symmetry of `⟨·,·⟩_Q`, and that almost surely equal random
  vectors have the same inner products and the same expected cost;
* `‖u‖_Q = 0` only for `u = 0` almost surely;
* `Q x⋆ = b` for `x⋆ = Q⁻¹ b`, and square-integrability of `x⋆`;
* `𝒢_i`-measurability and square-integrability of `0`, sums, differences and
  scalar multiples, coordinate by coordinate;
* nonemptiness and boundedness of the family the infimum in `sigmaRegret` runs
  over.

Nothing here is a step of a paper proof. This file imports `Defs/` and the two
routine files above only. It is shared by the attempts for C1, C2 and C3. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory Set

variable {Ω : Type} [MeasurableSpace Ω] {ι α : Type} [Fintype α]

/-! ## The cost at one state -/

/-- `f(u + h) − f(u) = hᵀ(Qu − b) + ½ hᵀQh` for symmetric `Q`. -/
theorem quadCost_add {Q : Matrix α α ℝ} (hQ : Q.IsHermitian) (b : α → ℝ) (c : ℝ)
    (u h : α → ℝ) :
    quadCost Q b c (u + h) - quadCost Q b c u = h ⬝ᵥ (Q *ᵥ u - b) + 1 / 2 * quad Q h := by
  simp only [quadCost, quad_add hQ u h, dotProduct_add, dotProduct_sub]
  rw [dotProduct_mulVec_comm hQ u h, dotProduct_comm h b]
  ring

/-- `Q (Q⁻¹ b) = b` for `Q ≻ 0`. -/
theorem mulVec_inv_mulVec [DecidableEq α] {Q : Matrix α α ℝ} (hQ : Q.PosDef) (b : α → ℝ) :
    Q *ᵥ (Q⁻¹ *ᵥ b) = b := by
  rw [mulVec_mulVec, mul_nonsing_inv Q (isUnit_iff_ne_zero.2 hQ.det_pos.ne'), one_mulVec]

/-- With `x⋆ = Q⁻¹ b`: `Qu − b = Q(u − x⋆)`. -/
theorem mulVec_sub_eq [DecidableEq α] {Q : Matrix α α ℝ} (hQ : Q.PosDef) (b u : α → ℝ) :
    Q *ᵥ u - b = Q *ᵥ (u - Q⁻¹ *ᵥ b) := by
  rw [mulVec_sub, mulVec_inv_mulVec hQ]

/-! ## Integrability -/

theorem integrable_dotProduct {μ : Measure Ω} {u v : Ω → α → ℝ} (hu : MemLp u 2 μ)
    (hv : MemLp v 2 μ) : Integrable (fun ω => u ω ⬝ᵥ v ω) μ := by
  simp only [dotProduct]
  exact integrable_finsetSum _ fun c _ => (memLp_pi_iff.1 hu c).integrable_mul (memLp_pi_iff.1 hv c)

/-- The cost `f(u, θ_t)` is integrable for square-integrable `u` and `b(θ_t)`
and integrable `c(θ_t)`. -/
theorem integrable_quadCost {μ : Measure Ω} (Q : Matrix α α ℝ) {b u : Ω → α → ℝ} {c : Ω → ℝ}
    (hb : MemLp b 2 μ) (hc : Integrable c μ) (hu : MemLp u 2 μ) :
    Integrable (fun ω => quadCost Q (b ω) (c ω) (u ω)) μ :=
  (((integrable_quad Q hu).const_mul (1 / 2)).sub (integrable_dotProduct hb hu)).add hc

/-- The linear term `hᵀ(Qu − b)` is integrable. -/
theorem integrable_linearTerm {μ : Measure Ω} (Q : Matrix α α ℝ) {b u h : Ω → α → ℝ}
    (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) (hh : MemLp h 2 μ) :
    Integrable (fun ω => h ω ⬝ᵥ (Q *ᵥ u ω - b ω)) μ :=
  integrable_dotProduct hh ((memLp_mulVec Q hu).sub hb)

/-- `x⋆ = Q⁻¹ b(θ_t)` is square-integrable when `b(θ_t)` is. -/
theorem memLp_xstar [DecidableEq α] {μ : Measure Ω} (Q : Matrix α α ℝ) {b : Ω → α → ℝ}
    (hb : MemLp b 2 μ) : MemLp (fun ω => Q⁻¹ *ᵥ b ω) 2 μ :=
  memLp_mulVec Q⁻¹ hb

/-! ## Expected cost -/

/-- The expansion `E[f(u+h) − f(u)] = E[hᵀ(Qu − b)] + ½ E[hᵀQh]`: the ring
identity `quadCost_add`, integrated. -/
theorem expectedCost_add {μ : Measure Ω} {Q : Matrix α α ℝ} (hQ : Q.IsHermitian)
    {b u h : Ω → α → ℝ} {c : Ω → ℝ} (hb : MemLp b 2 μ) (hc : Integrable c μ)
    (hu : MemLp u 2 μ) (hh : MemLp h 2 μ) :
    expectedCost μ Q b c (u + h) - expectedCost μ Q b c u
      = ∫ ω, h ω ⬝ᵥ (Q *ᵥ u ω - b ω) ∂μ + 1 / 2 * qNormSq μ Q h := by
  have h1 : expectedCost μ Q b c (u + h) - expectedCost μ Q b c u
      = ∫ ω, (quadCost Q (b ω) (c ω) (u ω + h ω) - quadCost Q (b ω) (c ω) (u ω)) ∂μ :=
    (integral_sub (integrable_quadCost Q hb hc (hu.add hh)) (integrable_quadCost Q hb hc hu)).symm
  have h2 : ∫ ω, h ω ⬝ᵥ (Q *ᵥ u ω - b ω) ∂μ + 1 / 2 * qNormSq μ Q h
      = ∫ ω, (h ω ⬝ᵥ (Q *ᵥ u ω - b ω) + 1 / 2 * quad Q (h ω)) ∂μ := by
    rw [integral_add (integrable_linearTerm Q hb hu hh) ((integrable_quad Q hh).const_mul (1 / 2)),
      integral_const_mul]
    rfl
  rw [h1, h2]
  exact integral_congr_ae (ae_of_all _ fun ω => quadCost_add hQ (b ω) (c ω) (u ω) (h ω))

/-- Almost surely equal actions have the same expected cost. -/
theorem expectedCost_congr_ae {μ : Measure Ω} (Q : Matrix α α ℝ) (b : Ω → α → ℝ) (c : Ω → ℝ)
    {u u' : Ω → α → ℝ} (h : u =ᵐ[μ] u') : expectedCost μ Q b c u = expectedCost μ Q b c u' :=
  integral_congr_ae (by filter_upwards [h] with ω hω; rw [hω])

/-! ## The weighted inner product -/

omit [Fintype α] in
/-- Excess cost is half the squared `Q`-norm of the deviation: both sides are
`½ E[(u − x⋆)ᵀ Q (u − x⋆)]` by definition. -/
theorem excessCost_eq_qNormSq [Fintype α] (μ : Measure Ω) (Q : Matrix α α ℝ)
    (xstar u : Ω → α → ℝ) : excessCost μ Q xstar u = 1 / 2 * qNormSq μ Q (u - xstar) := rfl

theorem qInner_congr_ae {μ : Measure Ω} (Q : Matrix α α ℝ) {u u' v v' : Ω → α → ℝ}
    (hu : u =ᵐ[μ] u') (hv : v =ᵐ[μ] v') : qInner μ Q u v = qInner μ Q u' v' :=
  integral_congr_ae (by filter_upwards [hu, hv] with ω h1 h2; rw [h1, h2])

theorem qNormSq_congr_ae {μ : Measure Ω} (Q : Matrix α α ℝ) {u u' : Ω → α → ℝ}
    (hu : u =ᵐ[μ] u') : qNormSq μ Q u = qNormSq μ Q u' :=
  qInner_congr_ae Q hu hu

theorem qInner_comm {μ : Measure Ω} {Q : Matrix α α ℝ} (hQ : Q.IsHermitian)
    (u v : Ω → α → ℝ) : qInner μ Q u v = qInner μ Q v u :=
  integral_congr_ae (ae_of_all _ fun ω => dotProduct_mulVec_comm hQ (v ω) (u ω))

theorem qInner_add_left {μ : Measure Ω} (Q : Matrix α α ℝ) {u v w : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hv : MemLp v 2 μ) (hw : MemLp w 2 μ) :
    qInner μ Q (u + v) w = qInner μ Q u w + qInner μ Q v w := by
  unfold qInner
  rw [← integral_add (integrable_dotProduct_mulVec Q hu hw) (integrable_dotProduct_mulVec Q hv hw)]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [add_dotProduct])

theorem qInner_smul_left (μ : Measure Ω) (Q : Matrix α α ℝ) (a : ℝ) (u w : Ω → α → ℝ) :
    qInner μ Q (a • u) w = a * qInner μ Q u w := by
  unfold qInner
  rw [← integral_const_mul]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [smul_dotProduct])

theorem qInner_sub_left {μ : Measure Ω} (Q : Matrix α α ℝ) {u v w : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hv : MemLp v 2 μ) (hw : MemLp w 2 μ) :
    qInner μ Q (u - v) w = qInner μ Q u w - qInner μ Q v w := by
  unfold qInner
  rw [← integral_sub (integrable_dotProduct_mulVec Q hu hw) (integrable_dotProduct_mulVec Q hv hw)]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [sub_dotProduct])

theorem qInner_add_right {μ : Measure Ω} (Q : Matrix α α ℝ) {u v w : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hv : MemLp v 2 μ) (hw : MemLp w 2 μ) :
    qInner μ Q u (v + w) = qInner μ Q u v + qInner μ Q u w := by
  unfold qInner
  rw [← integral_add (integrable_dotProduct_mulVec Q hu hv) (integrable_dotProduct_mulVec Q hu hw)]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [mulVec_add, dotProduct_add])

theorem qInner_sub_right {μ : Measure Ω} (Q : Matrix α α ℝ) {u v w : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hv : MemLp v 2 μ) (hw : MemLp w 2 μ) :
    qInner μ Q u (v - w) = qInner μ Q u v - qInner μ Q u w := by
  unfold qInner
  rw [← integral_sub (integrable_dotProduct_mulVec Q hu hv) (integrable_dotProduct_mulVec Q hu hw)]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [mulVec_sub, dotProduct_sub])

theorem qInner_smul_right (μ : Measure Ω) (Q : Matrix α α ℝ) (a : ℝ) (u w : Ω → α → ℝ) :
    qInner μ Q u (a • w) = a * qInner μ Q u w := by
  unfold qInner
  rw [← integral_const_mul]
  exact integral_congr_ae (ae_of_all _ fun ω => by simp [mulVec_smul, dotProduct_smul])

theorem qNormSq_nonneg (μ : Measure Ω) {Q : Matrix α α ℝ} (hQ : Q.PosDef) (u : Ω → α → ℝ) :
    0 ≤ qNormSq μ Q u :=
  integral_nonneg fun ω => quad_nonneg hQ (u ω)

/-- `‖u + v‖_Q² = ‖u‖_Q² + 2⟨u,v⟩_Q + ‖v‖_Q²`. -/
theorem qNormSq_add {μ : Measure Ω} {Q : Matrix α α ℝ} (hQ : Q.IsHermitian) {u v : Ω → α → ℝ}
    (hu : MemLp u 2 μ) (hv : MemLp v 2 μ) :
    qNormSq μ Q (u + v) = qNormSq μ Q u + 2 * qInner μ Q u v + qNormSq μ Q v := by
  unfold qNormSq
  rw [qInner_add_left Q hu hv (hu.add hv), qInner_add_right Q hu hu hv,
    qInner_add_right Q hv hu hv, qInner_comm hQ v u]
  ring

/-- `‖u − v‖_Q = ‖v − u‖_Q`. -/
theorem qNormSq_sub_comm (μ : Measure Ω) (Q : Matrix α α ℝ) (u v : Ω → α → ℝ) :
    qNormSq μ Q (u - v) = qNormSq μ Q (v - u) :=
  integral_congr_ae (ae_of_all _ fun ω => quad_sub_comm Q (u ω) (v ω))

/-- `‖u‖_Q = 0` and `Q ≻ 0` give `u = 0` almost surely. -/
theorem ae_eq_zero_of_qNormSq_eq_zero {μ : Measure Ω} {Q : Matrix α α ℝ} (hQ : Q.PosDef)
    {u : Ω → α → ℝ} (hu : MemLp u 2 μ) (h : qNormSq μ Q u = 0) : u =ᵐ[μ] 0 := by
  have hae : (fun ω => quad Q (u ω)) =ᵐ[μ] 0 :=
    (integral_eq_zero_iff_of_nonneg (fun ω => quad_nonneg hQ _) (integrable_quad Q hu)).1 h
  filter_upwards [hae] with ω hω
  exact (Degenerate.quad_eq_zero_iff hQ _).1 hω

/-! ## The policy space -/

section Policy

variable {μ : Measure Ω} {actor : α → ι} {𝒢 : ι → MeasurableSpace Ω}

omit [Fintype α] in
theorem mem_policySpace [Fintype α] {u : Ω → α → ℝ} :
    u ∈ policySpace μ actor 𝒢 ↔ SigmaAdmissible μ actor 𝒢 u := Iff.rfl

theorem SigmaAdmissible.zero : SigmaAdmissible μ actor 𝒢 (0 : Ω → α → ℝ) :=
  ⟨fun _ => measurable_const, MemLp.zero⟩

theorem SigmaAdmissible.add {u v : Ω → α → ℝ} (hu : SigmaAdmissible μ actor 𝒢 u)
    (hv : SigmaAdmissible μ actor 𝒢 v) : SigmaAdmissible μ actor 𝒢 (u + v) :=
  ⟨fun c => (hu.1 c).add (hv.1 c), hu.2.add hv.2⟩

theorem SigmaAdmissible.sub {u v : Ω → α → ℝ} (hu : SigmaAdmissible μ actor 𝒢 u)
    (hv : SigmaAdmissible μ actor 𝒢 v) : SigmaAdmissible μ actor 𝒢 (u - v) :=
  ⟨fun c => (hu.1 c).sub (hv.1 c), hu.2.sub hv.2⟩

theorem SigmaAdmissible.smul {u : Ω → α → ℝ} (hu : SigmaAdmissible μ actor 𝒢 u) (a : ℝ) :
    SigmaAdmissible μ actor 𝒢 (a • u) :=
  ⟨fun c => (hu.1 c).const_mul a, hu.2.const_smul a⟩

instance nonempty_sigmaAdmissible :
    Nonempty {u : Ω → α → ℝ // SigmaAdmissible μ actor 𝒢 u} :=
  ⟨⟨0, SigmaAdmissible.zero⟩⟩

/-- The regret is at most the excess cost of any member of the policy space. -/
theorem sigmaRegret_le {Q : Matrix α α ℝ} (hQ : Q.PosDef) (xstar : Ω → α → ℝ)
    {u : Ω → α → ℝ} (hu : SigmaAdmissible μ actor 𝒢 u) :
    sigmaRegret μ Q actor xstar 𝒢 ≤ excessCost μ Q xstar u :=
  ciInf_le (f := fun u : {u : Ω → α → ℝ // SigmaAdmissible μ actor 𝒢 u} =>
      excessCost μ Q xstar u.1)
    (bddBelow_range_of_nonneg fun _ => excessCost_nonneg μ hQ _ _) ⟨u, hu⟩

/-- A lower bound for the excess cost of every member of the policy space is a
lower bound for the regret. -/
theorem le_sigmaRegret {Q : Matrix α α ℝ} (xstar : Ω → α → ℝ) {a : ℝ}
    (h : ∀ u, SigmaAdmissible μ actor 𝒢 u → a ≤ excessCost μ Q xstar u) :
    a ≤ sigmaRegret μ Q actor xstar 𝒢 :=
  le_ciInf fun u => h u.1 u.2

end Policy

end TinaV2
