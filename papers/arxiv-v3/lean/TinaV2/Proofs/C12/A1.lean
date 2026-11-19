import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Aggregate

/-! # C12, attempt A1: mirrors paper proof C12/p1

Paper: `main-v2.tex`, proof of Proposition (aggregate_local), lines 592-612
(the main-text proof; the appendix derivation `C12/p2` is not followed). One lemma
per step of the paper's proof, in the paper's order, then `main`.

Notation. `θ = now`. The cost of Eq. (shared_resource_cost) is
`f(x,θ) = ½ xᵀQx − θᵀx = quadCost M.Q θ 0 x` with `Q = qI + γ11ᵀ`
(`Aggregate.quadCost_aggQ` writes it out in coordinates). An admissible
fresh-local rule is `g` with `Admissible μ (M.obs 0 now) g`, and
`u = jointAction g (M.obs 0 now)`. The paper's `μ_i` is `∫ ω, u ω i ∂μ` and its
`ũ_i` is `center μ u ω i`. The full-information action `x⋆ = Q⁻¹θ` is
`M.target now`.

The paper works with expected costs `E[f(u,θ)]` and obtains the regrets by
subtraction in step 7. The Lean regret is defined through the excess
`½ E[(u − x⋆)ᵀQ(u − x⋆)]`; the two agree by completing the square, claim C5,
which enters as the hypothesis `hC5 : C05.Statement` in steps 6 and 7. -/

namespace TinaV2.C12.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {n : ℕ} {q γ σ : ℝ} {Ω : Type} [MeasurableSpace Ω]

/-- Step 1 (main-v2.tex 592-594). "For any admissible `u_i = g_i(θ_i)`, write
`u_i = μ_i + ũ_i`, where `μ_i = E[u_i]` and `E[ũ_i] = 0`." -/
theorem s1_mean_plus_centered (M : Model (Fin n) (Fin n) (Fin n)) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (now : Ω → Fin n → ℝ)
    {g : Rule M.actor fun i => M.Scope 0 i → ℝ} (hg : Admissible μ (M.obs 0 now) g)
    (i : Fin n) :
    (∀ ω, jointAction g (M.obs 0 now) ω i
        = (∫ ω', jointAction g (M.obs 0 now) ω' i ∂μ)
          + center μ (jointAction g (M.obs 0 now)) ω i) ∧
      ∫ ω, center μ (jointAction g (M.obs 0 now)) ω i ∂μ = 0 := by
  have hint : Integrable (fun ω => jointAction g (M.obs 0 now) ω i) μ :=
    (memLp_pi_iff.1 hg.2 i).integrable one_le_two
  refine ⟨fun ω => by simp [center], ?_⟩
  simp only [center]
  rw [integral_sub hint (integrable_const _), integral_const]
  simp

/-- Step 2 (main-v2.tex 594-602). "Independence across agents and zero state
means give
`E[f(u,θ)] = Σ_i E[(q+γ)/2 ũ_i² − θ_i ũ_i] + q/2 Σ_i μ_i² + γ/2 (Σ_i μ_i)²`"
(Eq. (aggregate_centered_cost)). -/
theorem s2_centered_cost (M : Model (Fin n) (Fin n) (Fin n)) (hagg : IsAggregateModel M q γ)
    (μ : Measure Ω) [IsProbabilityMeasure μ] {now : Ω → Fin n → ℝ}
    (hst : AggregateState μ now σ)
    {g : Rule M.actor fun i => M.Scope 0 i → ℝ} (hg : Admissible μ (M.obs 0 now) g) :
    ∫ ω, quadCost M.Q (now ω) 0 (jointAction g (M.obs 0 now) ω) ∂μ
      = ∑ i, ∫ ω, ((q + γ) / 2 * center μ (jointAction g (M.obs 0 now)) ω i ^ 2
            - now ω i * center μ (jointAction g (M.obs 0 now)) ω i) ∂μ
        + q / 2 * ∑ i, (∫ ω, jointAction g (M.obs 0 now) ω i ∂μ) ^ 2
        + γ / 2 * (∑ i, ∫ ω, jointAction g (M.obs 0 now) ω i ∂μ) ^ 2 := by
  -- `u`, its means `m = (μ_i)` and its centered part `v = (ũ_i)`
  set u : Ω → Fin n → ℝ := jointAction g (M.obs 0 now) with hu_def
  set m : Fin n → ℝ := fun i => ∫ ω, u ω i ∂μ with hm_def
  set v : Ω → Fin n → ℝ := center μ u with hv_def
  have hv : MemLp v 2 μ := Aggregate.memLp_center hg.2
  have hvi : ∀ i, MemLp (fun ω => v ω i) 2 μ := memLp_pi_iff.1 hv
  have hθi : ∀ i, MemLp (fun ω => now ω i) 2 μ := memLp_pi_iff.1 hst.memLp
  -- step 1: `u = m + ũ` with `E[ũ_i] = 0`
  have hsplit : ∀ ω, u ω = m + v ω := fun ω =>
    funext fun i => (s1_mean_plus_centered M μ now hg i).1 ω
  have hmean : ∀ i, ∫ ω, v ω i ∂μ = 0 := fun i => (s1_mean_plus_centered M μ now hg i).2
  -- independence across agents: `ũ_i` is a function of `θ_i` alone, so
  -- `E[ũ_i ũ_j] = E[ũ_i] E[ũ_j] = 0` for `i ≠ j`
  obtain ⟨φ, hφ, hφu⟩ := Aggregate.exists_local_rule_eq M hagg.owner_eq hagg.actor_eq hg.1
  have hvφ : ∀ k, (fun ω => v ω k) = (fun x => φ k x - m k) ∘ fun ω => now ω k := by
    intro k
    funext ω
    simp only [hv_def, center, Function.comp_apply, hm_def, hu_def, M.jointAction_obs]
    rw [hφu]
  have hcross : ∀ i j, i ≠ j → ∫ ω, v ω i * v ω j ∂μ = 0 := by
    intro i j hij
    have hind : IndepFun (fun ω => v ω i) (fun ω => v ω j) μ := by
      rw [hvφ i, hvφ j]
      exact (hst.indep.indepFun hij).comp ((hφ i).sub_const _) ((hφ j).sub_const _)
    rw [hind.integral_fun_mul_eq_mul_integral (hvi i).aestronglyMeasurable
      (hvi j).aestronglyMeasurable, hmean i, zero_mul]
  -- the cost at `u = m + ũ`, expanded
  have hpt : ∀ ω, quadCost M.Q (now ω) 0 (u ω)
      = ∑ i, ((q + γ) / 2 * v ω i ^ 2 - now ω i * v ω i)
        + (q / 2 * ∑ i, m i ^ 2 + γ / 2 * (∑ i, m i) ^ 2)
        + (∑ i, (q * m i + γ * ∑ j, m j) * v ω i - ∑ i, m i * now ω i
            + γ / 2 * ((∑ i, v ω i) ^ 2 - ∑ i, v ω i ^ 2)) := by
    intro ω
    rw [hagg.Q_eq, hsplit ω, Aggregate.aggCost_split]
  -- integrability of each group of terms
  have hIv : ∀ i, Integrable (fun ω => v ω i) μ := fun i => (hvi i).integrable one_le_two
  have hIθ : ∀ i, Integrable (fun ω => now ω i) μ := fun i => (hθi i).integrable one_le_two
  have hIterm : ∀ i, Integrable
      (fun ω => (q + γ) / 2 * v ω i ^ 2 - now ω i * v ω i) μ := fun i =>
    ((hvi i).integrable_sq.const_mul _).sub ((hθi i).integrable_mul (hvi i))
  have hIA : Integrable (fun ω => ∑ i, ((q + γ) / 2 * v ω i ^ 2 - now ω i * v ω i)) μ :=
    integrable_finsetSum _ fun i _ => hIterm i
  have hIlin : Integrable (fun ω => ∑ i, (q * m i + γ * ∑ j, m j) * v ω i) μ :=
    integrable_finsetSum _ fun i _ => (hIv i).const_mul _
  have hIθm : Integrable (fun ω => ∑ i, m i * now ω i) μ :=
    integrable_finsetSum _ fun i _ => (hIθ i).const_mul _
  have hIsq : Integrable (fun ω => (∑ i, v ω i) ^ 2) μ :=
    (memLp_finsetSum _ fun i _ => hvi i).integrable_sq
  have hIdiag : Integrable (fun ω => ∑ i, v ω i ^ 2) μ :=
    integrable_finsetSum _ fun i _ => (hvi i).integrable_sq
  -- the terms linear in `ũ` vanish because `E[ũ_i] = 0`
  have h1 : ∫ ω, ∑ i, (q * m i + γ * ∑ j, m j) * v ω i ∂μ = 0 := by
    rw [integral_finsetSum _ fun i _ => (hIv i).const_mul _]
    exact Finset.sum_eq_zero fun i _ => by rw [integral_const_mul, hmean i, mul_zero]
  -- zero state means: `E[μ_i θ_i] = 0`
  have h2 : ∫ ω, ∑ i, m i * now ω i ∂μ = 0 := by
    rw [integral_finsetSum _ fun i _ => (hIθ i).const_mul _]
    exact Finset.sum_eq_zero fun i _ => by rw [integral_const_mul, hst.mean_zero i, mul_zero]
  -- independence across agents: `E[(Σ_i ũ_i)²] = Σ_i E[ũ_i²]`
  have h3 : ∫ ω, (∑ i, v ω i) ^ 2 ∂μ = ∑ i, ∫ ω, v ω i ^ 2 ∂μ :=
    Aggregate.integral_sq_sum_of_cross hv hcross
  have h4 : ∫ ω, ∑ i, v ω i ^ 2 ∂μ = ∑ i, ∫ ω, v ω i ^ 2 ∂μ :=
    integral_finsetSum _ fun i _ => (hvi i).integrable_sq
  have hIR1 : Integrable
      (fun ω => ∑ i, (q * m i + γ * ∑ j, m j) * v ω i - ∑ i, m i * now ω i) μ :=
    hIlin.sub hIθm
  have hIR2 : Integrable (fun ω => (∑ i, v ω i) ^ 2 - ∑ i, v ω i ^ 2) μ := hIsq.sub hIdiag
  have hIR3 : Integrable (fun ω => γ / 2 * ((∑ i, v ω i) ^ 2 - ∑ i, v ω i ^ 2)) μ :=
    hIR2.const_mul _
  have hIR : Integrable (fun ω => ∑ i, (q * m i + γ * ∑ j, m j) * v ω i - ∑ i, m i * now ω i
      + γ / 2 * ((∑ i, v ω i) ^ 2 - ∑ i, v ω i ^ 2)) μ := hIR1.add hIR3
  have hIAC : Integrable (fun ω => ∑ i, ((q + γ) / 2 * v ω i ^ 2 - now ω i * v ω i)
      + (q / 2 * ∑ i, m i ^ 2 + γ / 2 * (∑ i, m i) ^ 2)) μ := hIA.add (integrable_const _)
  have hrest : ∫ ω, (∑ i, (q * m i + γ * ∑ j, m j) * v ω i - ∑ i, m i * now ω i
      + γ / 2 * ((∑ i, v ω i) ^ 2 - ∑ i, v ω i ^ 2)) ∂μ = 0 := by
    rw [integral_add hIR1 hIR3, integral_sub hIlin hIθm, integral_const_mul,
      integral_sub hIsq hIdiag, h1, h2, h3, h4]
    ring
  simp_rw [hpt]
  rw [integral_add hIAC hIR, integral_add hIA (integrable_const _), integral_const, hrest,
    integral_finsetSum _ fun i _ => hIterm i]
  simp only [hm_def, probReal_univ, one_smul, add_zero]
  ring

/-- Step 3 (main-v2.tex 603). "The mean terms are minimized at zero": the terms
`q/2 Σ_i μ_i² + γ/2 (Σ_i μ_i)²` of Eq. (aggregate_centered_cost) are
nonnegative and vanish when every `μ_i = 0`, so the expected cost is at least
the sum of the centered terms, with equality for a rule with zero means. -/
theorem s3_mean_terms_min (hq : 0 < q) (hγ : 0 ≤ γ) (M : Model (Fin n) (Fin n) (Fin n))
    (hagg : IsAggregateModel M q γ) (μ : Measure Ω) [IsProbabilityMeasure μ]
    {now : Ω → Fin n → ℝ} (hst : AggregateState μ now σ)
    {g : Rule M.actor fun i => M.Scope 0 i → ℝ} (hg : Admissible μ (M.obs 0 now) g) :
    ∑ i, ∫ ω, ((q + γ) / 2 * center μ (jointAction g (M.obs 0 now)) ω i ^ 2
            - now ω i * center μ (jointAction g (M.obs 0 now)) ω i) ∂μ
        ≤ ∫ ω, quadCost M.Q (now ω) 0 (jointAction g (M.obs 0 now) ω) ∂μ ∧
      ((∀ i, ∫ ω, jointAction g (M.obs 0 now) ω i ∂μ = 0) →
        ∫ ω, quadCost M.Q (now ω) 0 (jointAction g (M.obs 0 now) ω) ∂μ
          = ∑ i, ∫ ω, ((q + γ) / 2 * center μ (jointAction g (M.obs 0 now)) ω i ^ 2
            - now ω i * center μ (jointAction g (M.obs 0 now)) ω i) ∂μ) := by
  rw [s2_centered_cost M hagg μ hst hg]
  refine ⟨?_, fun h0 => by simp [h0]⟩
  have h1 : 0 ≤ q / 2 * ∑ i, (∫ ω, jointAction g (M.obs 0 now) ω i ∂μ) ^ 2 :=
    mul_nonneg (by positivity) (Finset.sum_nonneg fun i _ => sq_nonneg _)
  have h2 : 0 ≤ γ / 2 * (∑ i, ∫ ω, jointAction g (M.obs 0 now) ω i ∂μ) ^ 2 :=
    mul_nonneg (by positivity) (sq_nonneg _)
  linarith

/-- Step 4 (main-v2.tex 603-605). "Each remaining term is minimized pointwise
by `ũ_i = θ_i/(q+γ)`, which is feasible and has zero mean." -/
theorem s4_pointwise_min (hq : 0 < q) (hγ : 0 ≤ γ) (M : Model (Fin n) (Fin n) (Fin n))
    (hagg : IsAggregateModel M q γ) (μ : Measure Ω) [IsProbabilityMeasure μ]
    {now : Ω → Fin n → ℝ} (hst : AggregateState μ now σ) :
    (∀ v t : ℝ, (q + γ) / 2 * (t / (q + γ)) ^ 2 - t * (t / (q + γ))
        ≤ (q + γ) / 2 * v ^ 2 - t * v) ∧
      ∃ g : Rule M.actor fun i => M.Scope 0 i → ℝ,
        Admissible μ (M.obs 0 now) g ∧
        (∀ ω i, jointAction g (M.obs 0 now) ω i = now ω i / (q + γ)) ∧
        ∀ i, ∫ ω, jointAction g (M.obs 0 now) ω i ∂μ = 0 := by
  have hqγ : 0 < q + γ := by linarith
  constructor
  · -- pointwise in `(ũ_i, θ_i) = (v, t)`: the difference is a square
    intro v t
    have h : (q + γ) / 2 * v ^ 2 - t * v
        - ((q + γ) / 2 * (t / (q + γ)) ^ 2 - t * (t / (q + γ)))
        = (q + γ) / 2 * (v - t / (q + γ)) ^ 2 := by
      field_simp
      ring
    have h' : 0 ≤ (q + γ) / 2 * (v - t / (q + γ)) ^ 2 := by positivity
    linarith
  · -- feasible: agent `i` sees `θ_i` at radius 0
    let g : Rule M.actor fun i => M.Scope 0 i → ℝ := fun c o =>
      o ⟨M.actor c, Aggregate.self_mem_nbhd_zero M hagg.owner_eq (M.actor c)⟩ / (q + γ)
    have hact : ∀ ω i, jointAction g (M.obs 0 now) ω i = now ω i / (q + γ) := by
      intro ω i
      change now ω (M.actor i) / (q + γ) = now ω i / (q + γ)
      rw [congrFun hagg.actor_eq i]
      rfl
    have hfun : jointAction g (M.obs 0 now) = fun ω => (q + γ)⁻¹ • now ω := by
      funext ω i
      rw [hact, Pi.smul_apply, smul_eq_mul, div_eq_inv_mul]
    refine ⟨g, ⟨fun c => (measurable_pi_apply _).div_const _, ?_⟩, hact, fun i => ?_⟩
    · rw [hfun]
      exact hst.memLp.const_smul (q + γ)⁻¹
    · -- zero mean, from the zero state means
      simp_rw [hact]
      rw [integral_div, hst.mean_zero i, zero_div]

/-- Step 5 (main-v2.tex 605-606). "Thus the expected local cost is
`−nσ²/[2(q+γ)]`, and the best constant cost is zero." The local cost is a lower
bound over all admissible fresh-local rules, attained by `u_i = θ_i/(q+γ)`;
every constant action has nonnegative expected cost and the zero action has
cost zero. -/
theorem s5_local_and_constant_cost (hq : 0 < q) (hγ : 0 ≤ γ)
    (M : Model (Fin n) (Fin n) (Fin n)) (hagg : IsAggregateModel M q γ) (μ : Measure Ω)
    [IsProbabilityMeasure μ] {now : Ω → Fin n → ℝ} (hst : AggregateState μ now σ) :
    (∀ g : Rule M.actor fun i => M.Scope 0 i → ℝ, Admissible μ (M.obs 0 now) g →
        -(n * σ ^ 2) / (2 * (q + γ))
          ≤ ∫ ω, quadCost M.Q (now ω) 0 (jointAction g (M.obs 0 now) ω) ∂μ) ∧
      (∃ g : Rule M.actor fun i => M.Scope 0 i → ℝ,
        Admissible μ (M.obs 0 now) g ∧
        (∀ ω i, jointAction g (M.obs 0 now) ω i = now ω i / (q + γ)) ∧
        ∫ ω, quadCost M.Q (now ω) 0 (jointAction g (M.obs 0 now) ω) ∂μ
          = -(n * σ ^ 2) / (2 * (q + γ))) ∧
      (∀ c : Fin n → ℝ, 0 ≤ ∫ ω, quadCost M.Q (now ω) 0 c ∂μ) ∧
      ∫ ω, quadCost M.Q (now ω) 0 0 ∂μ = 0 := by
  have hqγ : 0 < q + γ := by linarith
  obtain ⟨hpw, g₀, hg₀, hact, hmean₀⟩ := s4_pointwise_min hq hγ M hagg μ hst
  have hθi : ∀ i, MemLp (fun ω => now ω i) 2 μ := memLp_pi_iff.1 hst.memLp
  -- the value of one centered term at the pointwise minimizer: `−σ²/[2(q+γ)]`
  have hmin : ∀ i, (fun ω => (q + γ) / 2 * (now ω i / (q + γ)) ^ 2
      - now ω i * (now ω i / (q + γ))) = fun ω => -1 / (2 * (q + γ)) * now ω i ^ 2 := by
    intro i
    funext ω
    field_simp
    ring
  have hval : ∀ i, ∫ ω, ((q + γ) / 2 * (now ω i / (q + γ)) ^ 2
      - now ω i * (now ω i / (q + γ))) ∂μ = -σ ^ 2 / (2 * (q + γ)) := by
    intro i
    rw [hmin i, integral_const_mul, hst.variance i]
    ring
  have hsum : ∑ _i : Fin n, -σ ^ 2 / (2 * (q + γ)) = -(n * σ ^ 2) / (2 * (q + γ)) := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  refine ⟨fun g hg => ?_, ⟨g₀, hg₀, hact, ?_⟩, fun c => ?_, ?_⟩
  · -- lower bound for every admissible fresh-local rule: steps 3 and 4
    have hvi : ∀ i, MemLp (fun ω => center μ (jointAction g (M.obs 0 now)) ω i) 2 μ :=
      memLp_pi_iff.1 (Aggregate.memLp_center hg.2)
    have hterm : ∀ i, -σ ^ 2 / (2 * (q + γ))
        ≤ ∫ ω, ((q + γ) / 2 * center μ (jointAction g (M.obs 0 now)) ω i ^ 2
            - now ω i * center μ (jointAction g (M.obs 0 now)) ω i) ∂μ := by
      intro i
      rw [← hval i]
      refine integral_mono ?_ ?_ fun ω => hpw _ _
      · rw [hmin i]
        exact (hθi i).integrable_sq.const_mul _
      · exact ((hvi i).integrable_sq.const_mul _).sub ((hθi i).integrable_mul (hvi i))
    calc -(n * σ ^ 2) / (2 * (q + γ)) = ∑ _i : Fin n, -σ ^ 2 / (2 * (q + γ)) := hsum.symm
      _ ≤ ∑ i, ∫ ω, ((q + γ) / 2 * center μ (jointAction g (M.obs 0 now)) ω i ^ 2
            - now ω i * center μ (jointAction g (M.obs 0 now)) ω i) ∂μ :=
          Finset.sum_le_sum fun i _ => hterm i
      _ ≤ _ := (s3_mean_terms_min hq hγ M hagg μ hst hg).1
  · -- the rule `θ_i/(q+γ)` has zero means, so it is its own centered part
    rw [(s3_mean_terms_min hq hγ M hagg μ hst hg₀).2 hmean₀]
    have hc : ∀ ω i, center μ (jointAction g₀ (M.obs 0 now)) ω i = now ω i / (q + γ) := by
      intro ω i
      rw [center, hmean₀ i, sub_zero, hact]
    simp_rw [hc, hval]
    exact hsum
  · -- a constant action is an admissible rule with `ũ = 0`
    have hadm : Admissible μ (M.obs 0 now)
        (fun i _ => c i : Rule M.actor fun i => M.Scope 0 i → ℝ) :=
      Aggregate.admissible_const μ _ c
    have h3 := (s3_mean_terms_min hq hγ M hagg μ hst hadm).1
    have hc0 : ∀ ω i, center μ (jointAction
        (fun i _ => c i : Rule M.actor fun i => M.Scope 0 i → ℝ) (M.obs 0 now)) ω i = 0 := by
      intro ω i
      simp [center, Aggregate.jointAction_const]
    simp_rw [hc0, Aggregate.jointAction_const] at h3
    simpa using h3
  · -- the zero action has zero means
    have h3 := (s3_mean_terms_min hq hγ M hagg μ hst (admissible_zero μ (M.obs 0 now))).2
      (fun i => by simp [jointAction_zero])
    have hc0 : ∀ ω i, center μ (jointAction
        (fun _ _ => 0 : Rule M.actor fun i => M.Scope 0 i → ℝ) (M.obs 0 now)) ω i = 0 := by
      intro ω i
      simp [center, jointAction_zero]
    simp_rw [hc0, jointAction_zero] at h3
    simpa using h3

/-- Step 6 (main-v2.tex 607-609). "The eigenvalues of `Q` are `q+γn` once and
`q` with multiplicity `n−1`. The full-information expected cost is therefore
`−(σ²/2)[(n−1)/q + 1/(q+γn)]`." The eigenvalue `q+γn` has eigenvector `1`, and
the eigenvalue `q` has the `(n−1)`-dimensional eigenspace `{v : Σ_i v_i = 0}`.
The full-information cost is `f(x⋆,θ) = −½ x⋆ᵀQx⋆` by C5 at `x = 0`. -/
theorem s6_eigen_full_info_cost (hC5 : C05.Statement) (hn : 2 ≤ n) (hq : 0 < q) (hγ : 0 ≤ γ)
    (M : Model (Fin n) (Fin n) (Fin n)) (hagg : IsAggregateModel M q γ) (μ : Measure Ω)
    [IsProbabilityMeasure μ] {now : Ω → Fin n → ℝ} (hst : AggregateState μ now σ) :
    (M.Q *ᵥ (fun _ => (1 : ℝ)) = (q + γ * n) • fun _ => (1 : ℝ)) ∧
      (∀ v : Fin n → ℝ, ∑ i, v i = 0 → M.Q *ᵥ v = q • v) ∧
      ∫ ω, quadCost M.Q (now ω) 0 (M.target now ω) ∂μ
        = -(σ ^ 2 / 2) * ((n - 1) / q + 1 / (q + γ * n)) := by
  have hn0 : (n : ℝ) ≠ 0 := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  have hnpos : (0 : ℝ) < n := lt_of_le_of_ne (Nat.cast_nonneg n) (Ne.symm hn0)
  have hqn : 0 < q + γ * n := by positivity
  -- the eigenvalues of `Q`
  have he1 : M.Q *ᵥ (fun _ => (1 : ℝ)) = (q + γ * n) • fun _ => (1 : ℝ) := by
    rw [hagg.Q_eq]
    funext i
    simp [Aggregate.aggQ_mulVec]
  have he2 : ∀ v : Fin n → ℝ, ∑ i, v i = 0 → M.Q *ᵥ v = q • v := by
    intro v hv
    rw [hagg.Q_eq]
    funext i
    simp [Aggregate.aggQ_mulVec, hv]
  refine ⟨he1, he2, ?_⟩
  have hx : ∀ ω, M.target now ω = M.Q⁻¹ *ᵥ now ω := fun ω => by rw [Model.target, hagg.K_eq]
  -- C5 at `x = 0`: `f(x⋆,θ) = −½ x⋆ᵀ Q x⋆`
  have hcost : ∀ ω, quadCost M.Q (now ω) 0 (M.target now ω)
      = -(1 / 2) * quad M.Q (M.target now ω) := by
    intro ω
    have h := (hC5 M.Q (now ω) 0 M.Q_posDef).1 0
    have h0 : quadCost M.Q (now ω) 0 0 = 0 := by simp [quadCost, quad]
    rw [h0, quad_sub_comm, sub_zero] at h
    rw [hx ω]
    linarith
  -- `x⋆ = Q⁻¹θ` from the eigenvalues: split `θ` into its component along `1`
  -- and a sum-zero remainder (this is Eq. (shared_resource_xstar))
  have hxstar : ∀ ω, M.target now ω
      = ((∑ j, now ω j) / n / (q + γ * n)) • (fun _ => (1 : ℝ))
        + (1 / q) • (now ω - ((∑ j, now ω j) / n) • fun _ => (1 : ℝ)) := by
    intro ω
    rw [hx ω]
    apply Aggregate.inv_mulVec_eq_of_mulVec_eq M.Q_posDef
    have hz : ∑ i, (now ω - ((∑ j, now ω j) / n) • fun _ => (1 : ℝ) : Fin n → ℝ) i = 0 := by
      simp [Finset.sum_sub_distrib]
      field_simp
      ring
    rw [mulVec_add, mulVec_smul, mulVec_smul, he1, he2 _ hz]
    funext i
    simp
    field_simp
    ring
  -- `x⋆ᵀ Q x⋆ = x⋆ᵀ θ`, written out
  have hquad : ∀ ω, quad M.Q (M.target now ω)
      = (∑ j, now ω j) ^ 2 / (n * (q + γ * n))
        + 1 / q * (∑ j, now ω j ^ 2 - (∑ j, now ω j) ^ 2 / n) := by
    intro ω
    have hQx : M.Q *ᵥ M.target now ω = now ω := by
      rw [hx ω, Aggregate.mulVec_inv_mulVec M.Q_posDef]
    have h1 : (fun _ => (1 : ℝ)) ⬝ᵥ now ω = ∑ j, now ω j := by simp [dotProduct]
    have h2 : now ω ⬝ᵥ now ω = ∑ j, now ω j ^ 2 := by simp [dotProduct, sq]
    rw [quad, hQx, hxstar ω]
    simp only [add_dotProduct, smul_dotProduct, sub_dotProduct, smul_eq_mul, h1, h2]
    field_simp
  -- expectation: independent mean-zero states of variance `σ²`
  have hθi : ∀ i, MemLp (fun ω => now ω i) 2 μ := memLp_pi_iff.1 hst.memLp
  have hIS : Integrable (fun ω => (∑ j, now ω j) ^ 2) μ :=
    (memLp_finsetSum _ fun i _ => hθi i).integrable_sq
  have hIT : Integrable (fun ω => ∑ j, now ω j ^ 2) μ :=
    integrable_finsetSum _ fun i _ => (hθi i).integrable_sq
  have hI1 : Integrable (fun ω => (∑ j, now ω j) ^ 2 / (n * (q + γ * n))) μ := hIS.div_const _
  have hI2 : Integrable (fun ω => (∑ j, now ω j) ^ 2 / n) μ := hIS.div_const _
  have hI3 : Integrable (fun ω => ∑ j, now ω j ^ 2 - (∑ j, now ω j) ^ 2 / n) μ := hIT.sub hI2
  have hI4 : Integrable
      (fun ω => 1 / q * (∑ j, now ω j ^ 2 - (∑ j, now ω j) ^ 2 / n)) μ := hI3.const_mul _
  simp_rw [hcost, hquad]
  rw [integral_const_mul, integral_add hI1 hI4, integral_div, integral_const_mul,
    integral_sub hIT hI2, integral_div, Aggregate.integral_sq_sum hst,
    Aggregate.integral_sum_sq hst]
  field_simp
  ring

/-- Step 7 (main-v2.tex 610-612). "Subtracting this cost from the local and
constant costs gives Eqs. (aggregate_Rinf)-(aggregate_Rloc) in the appendix;
their ratio is the stated omission share." The subtraction is the passage from
expected cost to regret: `½ E[(u − x⋆)ᵀQ(u − x⋆)] = E[f(u,θ)] − E[f(x⋆,θ)]`
by C5. The rule of step 4 attains the local cost, hence `R_loc`. -/
theorem s7_subtract_and_ratio (hC5 : C05.Statement) (hn : 2 ≤ n) (hq : 0 < q) (hγ : 0 ≤ γ)
    (hσ : 0 < σ) (M : Model (Fin n) (Fin n) (Fin n)) (hagg : IsAggregateModel M q γ)
    (μ : Measure Ω) [IsProbabilityMeasure μ] {now : Ω → Fin n → ℝ}
    (hst : AggregateState μ now σ) :
    (∃ g : Rule M.actor fun i => M.Scope 0 i → ℝ,
        Admissible μ (M.obs 0 now) g ∧
        (∀ ω i, jointAction g (M.obs 0 now) ω i = now ω i / (q + γ)) ∧
        excessCost μ M.Q (M.target now) (jointAction g (M.obs 0 now)) = M.Rloc μ now) ∧
      M.Rinf μ now = aggRinf n q γ σ ∧
      M.Rloc μ now = aggRloc n q γ σ ∧
      M.etaS μ 0 now = aggEta n q γ := by
  obtain ⟨hlow, ⟨g₀, hg₀, hact, hval⟩, -, hzero⟩ :=
    s5_local_and_constant_cost hq hγ M hagg μ hst
  have hfull := (s6_eigen_full_info_cost hC5 hn hq hγ M hagg μ hst).2.2
  have hn2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hqγ : 0 < q + γ := by linarith
  have hqn : 0 < q + γ * n := by positivity
  have hqn1 : 0 < q + γ * (n - 1) := by
    have : 0 ≤ γ * (n - 1) := mul_nonneg hγ (by linarith)
    linarith
  -- regret is expected cost minus the full-information expected cost (C5)
  have hbridge : ∀ u : Ω → Fin n → ℝ, MemLp u 2 μ →
      excessCost μ M.Q (M.target now) u
        = ∫ ω, quadCost M.Q (now ω) 0 (u ω) ∂μ
          - ∫ ω, quadCost M.Q (now ω) 0 (M.target now ω) ∂μ := by
    intro u hu
    rw [excessCost, ← integral_const_mul,
      ← integral_sub (Aggregate.integrable_quadCost M.Q hst.memLp hu)
        (Aggregate.integrable_quadCost M.Q hst.memLp (M.memLp_target hst.memLp))]
    refine integral_congr_ae (ae_of_all _ fun ω => ?_)
    have h := (hC5 M.Q (now ω) 0 M.Q_posDef).1 (u ω)
    have hx : M.target now ω = M.Q⁻¹ *ᵥ now ω := by rw [Model.target, hagg.K_eq]
    beta_reduce
    rw [hx]
    exact h.symm
  -- constant cost minus full-information cost
  have hRinf : M.Rinf μ now
      = 0 - -(σ ^ 2 / 2) * ((n - 1) / q + 1 / (q + γ * n)) := by
    have h := hbridge 0 MemLp.zero
    simp only [Pi.zero_apply] at h
    rw [hzero, hfull] at h
    rw [← h, Model.Rinf, excessCost]
    congr 1
    refine integral_congr_ae (ae_of_all _ fun ω => ?_)
    change quad M.Q (M.target now ω) = quad M.Q (0 - M.target now ω)
    rw [quad_sub_comm, sub_zero]
  -- local cost minus full-information cost
  have hRloc : M.Rloc μ now
      = -(n * σ ^ 2) / (2 * (q + γ)) - -(σ ^ 2 / 2) * ((n - 1) / q + 1 / (q + γ * n)) := by
    apply le_antisymm
    · calc M.Rloc μ now
          ≤ excessCost μ M.Q (M.target now) (jointAction g₀ (M.obs 0 now)) :=
            regret_le μ M.Q_posDef _ _ hg₀
        _ = _ := by rw [hbridge _ hg₀.2, hval, hfull]
    · change _ ≤ ⨅ g : {g : Rule M.actor fun i => M.Scope 0 i → ℝ //
          Admissible μ (M.obs 0 now) g},
        excessCost μ M.Q (M.target now) (jointAction g.1 (M.obs 0 now))
      refine le_ciInf fun g => ?_
      rw [hbridge _ g.2.2, hfull]
      linarith [hlow g.1 g.2]
  -- the closed forms and their ratio
  have e1 : M.Rinf μ now = aggRinf n q γ σ := by
    rw [hRinf, aggRinf]
    field_simp
    ring
  have e2 : M.Rloc μ now = aggRloc n q γ σ := by
    rw [hRloc, aggRloc]
    field_simp
    ring
  refine ⟨⟨g₀, hg₀, hact, ?_⟩, e1, e2, ?_⟩
  · rw [hbridge _ hg₀.2, hval, hfull, hRloc]
  · change M.Rloc μ now / M.Rinf μ now = aggEta n q γ
    rw [e2, e1, aggRloc, aggRinf, aggEta]
    have hn0 : (n : ℝ) ≠ 0 := by linarith
    field_simp

/-- Proposition (aggregate_local), Eqs. (optimal_local_shared), (aggregate_eta),
(aggregate_Rinf), (aggregate_Rloc). -/
theorem main (hC5 : C05.Statement) : C12.Statement := by
  intro n q γ σ hn hq hγ hσ M hagg Ω _ μ _ now hst
  exact s7_subtract_and_ratio hC5 hn hq hγ hσ M hagg μ hst

end TinaV2.C12.A1
