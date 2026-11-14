import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection

/-! # Routine facts for the conditional normal equations (claim C2)

What the justification of Corollary (conditional_normal_equations) in
`technical-appendices-v2.tex` (lines 256-269) leaves unsaid:

* a perturbation supported on one action coordinate, with that coordinate a
  square-integrable `𝒢_i`-measurable function, belongs to `𝒮(𝒜)`, and the
  indicator of an event is square-integrable;
* square-integrability and integrability of the coordinates of `Qu − b(θ_t)`
  and of their products with the coordinates of a perturbation;
* `E[hᵀ(Qu − b)] = Σ_c E[h_c (Qu − b)_c]`: linearity of the integral over the
  finite sum that defines the dot product;
* the equivalence of Eq. (conditional_normal_equations) with the block form
  Eq. (block_conditional_normal_equations) for members of `𝒮(𝒜)`: linearity
  of conditional expectation over the finite sum `(Qu)_c = Σ_{c'} Q_{cc'} u_{c'}`
  and `E[u_{c'} | 𝒢_i] = u_{c'}` for the coordinates `c'` of agent `i` itself.
  The corollary asserts this with the word "equivalently" and the justification
  has no step for it.

Nothing here is a step of a paper proof. This file imports `Defs/` and the
routine files above only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory Set

variable {Ω : Type} [m0 : MeasurableSpace Ω] {ι α : Type} [Fintype α]

/-! ## One-coordinate perturbations -/

/-- The indicator of an event is square-integrable under a finite measure. -/
theorem memLp_indicator_one {μ : Measure Ω} [IsFiniteMeasure μ] {s : Set Ω}
    (hs : MeasurableSet s) : MemLp (s.indicator fun _ => (1 : ℝ)) 2 μ :=
  (memLp_const (1 : ℝ)).indicator hs

/-- A perturbation supported on the action coordinate `k`, with that coordinate a
square-integrable function measurable with respect to the sigma-algebra of the
agent who chooses `k`, is a member of the policy space. -/
theorem sigmaAdmissible_single [DecidableEq α] {μ : Measure Ω} {actor : α → ι}
    {𝒢 : ι → MeasurableSpace Ω} {k : α} {φ : Ω → ℝ} (hφ : Measurable[𝒢 (actor k)] φ)
    (hφ2 : MemLp φ 2 μ) : SigmaAdmissible μ actor 𝒢 fun ω => Pi.single k (φ ω) := by
  refine ⟨fun k' => ?_, memLp_pi_iff.2 fun k' => ?_⟩
  · by_cases hk : k' = k
    · subst hk
      simpa using hφ
    · simp only [Pi.single_eq_of_ne hk]
      exact measurable_const
  · by_cases hk : k' = k
    · subst hk
      simpa using hφ2
    · simp only [Pi.single_eq_of_ne hk]
      exact MemLp.zero'

/-! ## The residual `Qu − b(θ_t)`, coordinate by coordinate -/

/-- Each coordinate of `Qu − b(θ_t)` is square-integrable. -/
theorem memLp_residual_apply {μ : Measure Ω} (Q : Matrix α α ℝ) {b u : Ω → α → ℝ}
    (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) (k : α) :
    MemLp (fun ω => (Q *ᵥ u ω - b ω) k) 2 μ :=
  memLp_pi_iff.1 ((memLp_mulVec Q hu).sub hb) k

/-- Each coordinate of `Qu − b(θ_t)` is integrable. -/
theorem integrable_residual_apply {μ : Measure Ω} [IsFiniteMeasure μ] (Q : Matrix α α ℝ)
    {b u : Ω → α → ℝ} (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) (k : α) :
    Integrable (fun ω => (Q *ᵥ u ω - b ω) k) μ :=
  (memLp_residual_apply Q hb hu k).integrable one_le_two

/-- The product of a coordinate of a perturbation with the same coordinate of
`Qu − b(θ_t)` is integrable. -/
theorem integrable_mul_residual_apply {μ : Measure Ω} (Q : Matrix α α ℝ) {b u h : Ω → α → ℝ}
    (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) (hh : MemLp h 2 μ) (k : α) :
    Integrable (fun ω => h ω k * (Q *ᵥ u ω - b ω) k) μ :=
  (memLp_pi_iff.1 hh k).integrable_mul (memLp_residual_apply Q hb hu k)

/-- `E[hᵀ(Qu − b)] = Σ_k E[h_k (Qu − b)_k]`. -/
theorem integral_linearTerm_eq_sum {μ : Measure Ω} (Q : Matrix α α ℝ) {b u h : Ω → α → ℝ}
    (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) (hh : MemLp h 2 μ) :
    ∫ ω, h ω ⬝ᵥ (Q *ᵥ u ω - b ω) ∂μ = ∑ k, ∫ ω, h ω k * (Q *ᵥ u ω - b ω) k ∂μ := by
  simp only [dotProduct]
  exact integral_finsetSum _ fun k _ => integrable_mul_residual_apply Q hb hu hh k

/-! ## The block form of the normal equations -/

/-- For a member `u` of the policy space, the conditional expectation of the
coordinate `k` of `Qu − b(θ_t)` given the sigma-algebra of its agent is the
left side minus the right side of Eq. (block_conditional_normal_equations):
conditional expectation is linear over the finite sum `Σ_{k'} Q_{kk'} u_{k'}`,
and it leaves the coordinates of the same agent unchanged. -/
theorem condExp_residual_apply [DecidableEq ι] {μ : Measure Ω} [IsFiniteMeasure μ]
    (Q : Matrix α α ℝ) {actor : α → ι} {𝒢 : ι → MeasurableSpace Ω} (h𝒢 : ∀ i, 𝒢 i ≤ m0)
    {b u : Ω → α → ℝ} (hb : MemLp b 2 μ) (hu : SigmaAdmissible μ actor 𝒢 u) (k : α) :
    μ[fun ω => (Q *ᵥ u ω - b ω) k | 𝒢 (actor k)] =ᵐ[μ] fun ω =>
      (∑ k', Q k k' *
        if actor k' = actor k then u ω k' else (μ[fun ω' => u ω' k' | 𝒢 (actor k)]) ω)
      - (μ[fun ω => b ω k | 𝒢 (actor k)]) ω := by
  have hm : 𝒢 (actor k) ≤ m0 := h𝒢 (actor k)
  have hui : ∀ k', Integrable (fun ω => u ω k') μ := fun k' =>
    (memLp_pi_iff.1 hu.2 k').integrable one_le_two
  have hbi : Integrable (fun ω => b ω k) μ := (memLp_pi_iff.1 hb k).integrable one_le_two
  -- the coordinates of the same agent are their own conditional expectation
  have hown : ∀ k', (μ[fun ω => u ω k' | 𝒢 (actor k)]) = fun ω =>
      if actor k' = actor k then u ω k' else (μ[fun ω' => u ω' k' | 𝒢 (actor k)]) ω := by
    intro k'
    by_cases hk : actor k' = actor k
    · simp only [hk, if_true]
      exact condExp_of_stronglyMeasurable hm (hk ▸ hu.1 k').stronglyMeasurable (hui k')
    · simp only [hk, if_false]
  -- `(Qu − b)_k = Σ_{k'} Q_{kk'} u_{k'} − b_k` as functions
  have hsplit : (fun ω => (Q *ᵥ u ω - b ω) k)
      = (∑ k', Q k k' • fun ω => u ω k') - fun ω => b ω k := by
    funext ω
    simp [mulVec, dotProduct, Finset.sum_apply]
  have hsumi : Integrable (∑ k', Q k k' • fun ω => u ω k') μ :=
    integrable_finsetSum' _ fun k' _ => (hui k').smul (Q k k')
  rw [hsplit]
  filter_upwards [condExp_sub hsumi hbi (𝒢 (actor k)),
    condExp_finsetSum (s := Finset.univ) (fun k' _ => (hui k').smul (Q k k')) (𝒢 (actor k)),
    ae_all_iff.2 fun k' => condExp_smul (Q k k') (fun ω => u ω k') (𝒢 (actor k))]
    with ω h1 h2 h3
  rw [h1, Pi.sub_apply, h2, Finset.sum_apply]
  congr 1
  refine Finset.sum_congr rfl fun k' _ => ?_
  rw [h3 k', Pi.smul_apply, smul_eq_mul]
  exact congrArg (Q k k' * ·) (congrFun (hown k') ω)

/-- Eq. (conditional_normal_equations) and Eq. (block_conditional_normal_equations)
are equivalent for a member of the policy space. -/
theorem normalEquations_iff_block [DecidableEq ι] {μ : Measure Ω} [IsFiniteMeasure μ]
    (Q : Matrix α α ℝ) {actor : α → ι} {𝒢 : ι → MeasurableSpace Ω} (h𝒢 : ∀ i, 𝒢 i ≤ m0)
    {b u : Ω → α → ℝ} (hb : MemLp b 2 μ) (hu : SigmaAdmissible μ actor 𝒢 u) :
    NormalEquations μ Q actor 𝒢 b u ↔ BlockNormalEquations μ Q actor 𝒢 b u := by
  constructor
  · intro h k
    filter_upwards [condExp_residual_apply Q h𝒢 hb hu k, h k] with ω h1 h2
    rw [h2, Pi.zero_apply] at h1
    linarith
  · intro h k
    filter_upwards [condExp_residual_apply Q h𝒢 hb hu k, h k] with ω h1 h2
    rw [h1, h2, Pi.zero_apply, sub_self]

end TinaV2
