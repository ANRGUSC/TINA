import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection
import TinaV2.Routine.NormalEq

/-! # C2, attempt A1: mirrors paper proof C2/p1

Paper: `technical-appendices-v2.tex`, "Justification of the conditional normal
equations", lines 256-269. One lemma per step of the paper's proof, in the
paper's order, then `main`.

Notation. `S = policySpace μ actor 𝒢` is `𝒮(𝒜)`, `x⋆ = Q⁻¹ b(θ_t)`, and the
paper's `u⋆` ("the unique team optimum in Lemma (radner_projection)") is any `p`
with `IsQProjection μ Q S x⋆ p`. Step 1 uses claim C1 (a projection is optimal)
as the hypothesis `hC1 : C01.Statement`. Agent `i`'s action block is the set of
action coordinates `k` with `actor k = i`; the equations are written coordinate
by coordinate.

The third conjunct of `C02.Statement`, the equivalence with the block form
Eq. (block_conditional_normal_equations), has no step in the paper's proof (the
corollary says "equivalently"). `main` takes it from
`normalEquations_iff_block` in `Routine/NormalEq.lean`. -/

namespace TinaV2.C02.A1

open MeasureTheory ProbabilityTheory Matrix

/-- Step 1 (technical-appendices-v2.tex 257-258). "For an admissible
perturbation `h`, differentiating expected quadratic cost at the optimum gives
`E[hᵀ(Qu⋆ − b(θ_t))] = 0`." The optimum is a projection `p` of `x⋆`, optimal by
claim C1; `t ↦ E[f(p + t h)] − E[f(p)] = t E[hᵀ(Qp − b)] + ½ t² ‖h‖_Q²` has a
minimum at `t = 0`, so its derivative there, `E[hᵀ(Qp − b)]`, is zero. -/
theorem s1_first_order (hC1 : C01.Statement) {ι α Ω : Type} [Fintype α] [DecidableEq α]
    [m0 : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ)
    (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ) (c : Ω → ℝ)
    (hQ : Q.PosDef) (h𝒢 : ∀ i, 𝒢 i ≤ m0) (hb : MemLp b 2 μ) (hc : Integrable c μ)
    {p : Ω → α → ℝ}
    (hp : IsQProjection μ Q (policySpace μ actor 𝒢) (fun ω => Q⁻¹ *ᵥ b ω) p)
    {h : Ω → α → ℝ} (hh : h ∈ policySpace μ actor 𝒢) :
    ∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ = 0 := by
  -- `p` is optimal in `𝒮(𝒜)` (claim C1)
  have hopt : ∀ u ∈ policySpace μ actor 𝒢, expectedCost μ Q b c p ≤ expectedCost μ Q b c u :=
    ((hC1 μ Q actor 𝒢 b c hQ h𝒢 hb hc).2.2 p hp).1
  -- the cost along the line `p + t h`, relative to its value at `p`
  have hline : ∀ t : ℝ,
      0 ≤ t * (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ) + 1 / 2 * (t ^ 2 * qNormSq μ Q h) := by
    intro t
    have hth : t • h ∈ policySpace μ actor 𝒢 := SigmaAdmissible.smul hh t
    have h1 := expectedCost_add (c := c) hQ.isHermitian hb hc hp.1.2 hth.2
    have h2 : ∫ ω, (t • h) ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ
        = t * ∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ := by
      rw [← integral_const_mul]
      exact integral_congr_ae (ae_of_all _ fun ω => by
        simp only [Pi.smul_apply, smul_dotProduct, smul_eq_mul])
    have h3 : qNormSq μ Q (t • h) = t ^ 2 * qNormSq μ Q h := by
      unfold qNormSq
      rw [qInner_smul_left, qInner_smul_right]
      ring
    have h4 := hopt (p + t • h) (SigmaAdmissible.add hp.1 hth)
    rw [h2, h3] at h1
    linarith
  -- it has a minimum at `t = 0`, and its derivative there is the linear term
  have hmin : IsLocalMin (fun t : ℝ =>
      t * (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ) + 1 / 2 * (t ^ 2 * qNormSq μ Q h)) 0 :=
    Filter.Eventually.of_forall fun t => by simpa using hline t
  have hderiv : HasDerivAt (fun t : ℝ =>
      t * (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ) + 1 / 2 * (t ^ 2 * qNormSq μ Q h))
      (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ) 0 := by
    have hd := (hasDerivAt_mul_const (x := (0 : ℝ)) (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ)).add
      (((hasDerivAt_pow 2 (0 : ℝ)).mul_const (qNormSq μ Q h)).const_mul (1 / 2))
    have hval : (∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ)
        + 1 / 2 * (((2 : ℕ) : ℝ) * (0 : ℝ) ^ (2 - 1) * qNormSq μ Q h)
        = ∫ ω, h ω ⬝ᵥ (Q *ᵥ p ω - b ω) ∂μ := by simp
    rw [hval] at hd
    exact hd
  exact hmin.hasDerivAt_eq_zero hderiv

/-- Step 2 (technical-appendices-v2.tex 259-261). "Choose perturbations
supported on one agent's action block, with that block an arbitrary
square-integrable function of its observations. Conditional expectation then
gives Eq. (conditional_normal_equations)." The perturbation is supported on one
coordinate `k` of the block of agent `actor k` and equals the indicator of an
event `A ∈ 𝒢_{actor k}` there; step 1 gives `E[1_A (Qp − b)_k] = 0` for every
such `A`, which is the defining property of `E[(Qp − b)_k | 𝒢_{actor k}] = 0`. -/
theorem s2_conditional_equations (hC1 : C01.Statement) {ι α Ω : Type} [Fintype α]
    [DecidableEq α] [m0 : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Q : Matrix α α ℝ) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ)
    (c : Ω → ℝ) (hQ : Q.PosDef) (h𝒢 : ∀ i, 𝒢 i ≤ m0) (hb : MemLp b 2 μ)
    (hc : Integrable c μ) {p : Ω → α → ℝ}
    (hp : IsQProjection μ Q (policySpace μ actor 𝒢) (fun ω => Q⁻¹ *ᵥ b ω) p) :
    NormalEquations μ Q actor 𝒢 b p := by
  intro k
  have hm : 𝒢 (actor k) ≤ m0 := h𝒢 (actor k)
  have hg : Integrable (fun ω => (Q *ᵥ p ω - b ω) k) μ :=
    integrable_residual_apply Q hb hp.1.2 k
  -- the residual coordinate integrates to zero over every event of the agent
  have hset : ∀ A : Set Ω, MeasurableSet[𝒢 (actor k)] A →
      ∫ ω in A, (Q *ᵥ p ω - b ω) k ∂μ = 0 := by
    intro A hA
    have hA0 : MeasurableSet A := hm A hA
    -- the perturbation: `1_A` on coordinate `k`, zero elsewhere
    have hadm : (fun ω => Pi.single k (A.indicator (fun _ => (1 : ℝ)) ω))
        ∈ policySpace μ actor 𝒢 :=
      sigmaAdmissible_single (measurable_const.indicator hA) (memLp_indicator_one hA0)
    have h1 := s1_first_order hC1 μ Q actor 𝒢 b c hQ h𝒢 hb hc hp hadm
    rw [← integral_indicator hA0, ← h1]
    refine integral_congr_ae (ae_of_all _ fun ω => ?_)
    by_cases hω : ω ∈ A <;> simp [single_dotProduct, hω]
  -- so `0` is the conditional expectation
  exact (ae_eq_condExp_of_forall_setIntegral_eq hm hg (g := 0)
    (fun _ _ _ => integrableOn_zero) (fun A hA _ => by rw [hset A hA]; simp)
    aestronglyMeasurable_zero).symm

/-- Step 3 (technical-appendices-v2.tex 262-266). "Conversely, these conditional
equations make the linear term vanish in
`E[f(u⋆+h,θ_t) − f(u⋆,θ_t)] = E[hᵀ(Qu⋆ − b(θ_t))] + ½ E[hᵀQh]`."
For `u ∈ 𝒮(𝒜)` satisfying the equations and `h ∈ 𝒮(𝒜)`,
`E[h_k (Qu − b)_k] = E[h_k E[(Qu − b)_k | 𝒢_{actor k}]] = 0` for each coordinate
`k`, because `h_k` is `𝒢_{actor k}`-measurable; what remains is `½ ‖h‖_Q²`. -/
theorem s3_linear_term_vanishes {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ) (c : Ω → ℝ) (hQ : Q.PosDef)
    (h𝒢 : ∀ i, 𝒢 i ≤ m0) (hb : MemLp b 2 μ) (hc : Integrable c μ) {u : Ω → α → ℝ}
    (hu : u ∈ policySpace μ actor 𝒢) (hne : NormalEquations μ Q actor 𝒢 b u)
    {h : Ω → α → ℝ} (hh : h ∈ policySpace μ actor 𝒢) :
    expectedCost μ Q b c (u + h) - expectedCost μ Q b c u = 1 / 2 * qNormSq μ Q h := by
  -- the linear term vanishes, coordinate by coordinate
  have hlin : ∫ ω, h ω ⬝ᵥ (Q *ᵥ u ω - b ω) ∂μ = 0 := by
    rw [integral_linearTerm_eq_sum Q hb hu.2 hh.2]
    refine Finset.sum_eq_zero fun k _ => ?_
    have hm : 𝒢 (actor k) ≤ m0 := h𝒢 (actor k)
    have hhm : StronglyMeasurable[𝒢 (actor k)] fun ω => h ω k := (hh.1 k).stronglyMeasurable
    have hg : Integrable (fun ω => (Q *ᵥ u ω - b ω) k) μ :=
      integrable_residual_apply Q hb hu.2 k
    have hhg : Integrable (fun ω => h ω k * (Q *ᵥ u ω - b ω) k) μ :=
      integrable_mul_residual_apply Q hb hu.2 hh.2 k
    calc ∫ ω, h ω k * (Q *ᵥ u ω - b ω) k ∂μ
        = ∫ ω, (μ[fun ω => h ω k * (Q *ᵥ u ω - b ω) k | 𝒢 (actor k)]) ω ∂μ :=
          (integral_condExp hm).symm
      _ = ∫ ω, h ω k * (μ[fun ω => (Q *ᵥ u ω - b ω) k | 𝒢 (actor k)]) ω ∂μ :=
          integral_congr_ae (condExp_mul_of_stronglyMeasurable_left hhm hhg hg)
      _ = ∫ _, (0 : ℝ) ∂μ := integral_congr_ae (by
          filter_upwards [hne k] with ω hω
          rw [hω, Pi.zero_apply, mul_zero])
      _ = 0 := by simp
  -- the displayed expansion, with the linear term removed
  rw [expectedCost_add hQ.isHermitian hb hc hu.2 hh.2, hlin, zero_add]

/-- Step 4 (technical-appendices-v2.tex 267-268). "Positive definiteness makes
the remaining term positive for any nonzero `L²` perturbation, proving
sufficiency and uniqueness up to almost-sure equality." With `h = v − u`:
`E[f(v)] − E[f(u)] = ½ ‖v − u‖_Q² ≥ 0`, and it is `0` only if `v = u` almost
surely. -/
theorem s4_sufficient_unique {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ) (c : Ω → ℝ) (hQ : Q.PosDef)
    (h𝒢 : ∀ i, 𝒢 i ≤ m0) (hb : MemLp b 2 μ) (hc : Integrable c μ) {u : Ω → α → ℝ}
    (hu : u ∈ policySpace μ actor 𝒢) (hne : NormalEquations μ Q actor 𝒢 b u) :
    (∀ v ∈ policySpace μ actor 𝒢, expectedCost μ Q b c u ≤ expectedCost μ Q b c v) ∧
    (∀ v ∈ policySpace μ actor 𝒢,
      expectedCost μ Q b c v ≤ expectedCost μ Q b c u → v =ᵐ[μ] u) := by
  -- step 3 with the perturbation `h = v − u`
  have hexp : ∀ v ∈ policySpace μ actor 𝒢,
      expectedCost μ Q b c v - expectedCost μ Q b c u = 1 / 2 * qNormSq μ Q (v - u) := by
    intro v hv
    have h3 := s3_linear_term_vanishes μ Q actor 𝒢 b c hQ h𝒢 hb hc hu hne
      (SigmaAdmissible.sub hv hu)
    rwa [add_sub_cancel] at h3
  refine ⟨fun v hv => ?_, fun v hv hle => ?_⟩
  · -- sufficiency: the remaining term is nonnegative
    have h0 := qNormSq_nonneg μ hQ (v - u)
    linarith [hexp v hv]
  · -- uniqueness: the remaining term is zero only for `v − u = 0` a.s.
    have h0 : qNormSq μ Q (v - u) = 0 :=
      le_antisymm (by linarith [hexp v hv]) (qNormSq_nonneg μ hQ (v - u))
    filter_upwards [ae_eq_zero_of_qNormSq_eq_zero hQ (hv.2.sub hu.2) h0] with ω hω
    exact sub_eq_zero.1 hω

theorem main (hC1 : C01.Statement) : C02.Statement := by
  intro ι α Ω _ _ _ m0 μ _ Q actor 𝒢 b c hQ h𝒢 hb hc xstar S
  exact ⟨fun p hp => s2_conditional_equations hC1 μ Q actor 𝒢 b c hQ h𝒢 hb hc hp,
    fun u hu hne => s4_sufficient_unique μ Q actor 𝒢 b c hQ h𝒢 hb hc hu hne,
    fun u hu => normalEquations_iff_block Q h𝒢 hb hu⟩

end TinaV2.C02.A1
