import TinaV2.Routine.Regret

/-! # Routine facts for C12 (aggregate coupling)

What the main-text proof of Proposition (aggregate_local) leaves unsaid and
`Routine/Regret.lean` does not already provide:

* `Q = qI + γ11ᵀ` and the cost of Eq. (shared_resource_cost) written out in
  coordinates, and the expansion of that cost at `x = m + v`;
* the radius-0 view of agent `i` is the single coordinate `θ_i`, so a
  fresh-local rule is a measurable function of the agent's own state;
* constant rules are admissible; centering keeps a vector square-integrable;
  the cost is integrable for square-integrable actions;
* the second moment of a sum whose cross moments vanish, and the cross moments
  of independent mean-zero states;
* `Q⁻¹ b` is the solution of `Q y = b` for `Q ≻ 0`.

Everything is in the namespace `TinaV2.Aggregate`, so that the names cannot
clash with the other files under `TinaV2/Routine/`. This file imports
`Routine/Regret` (and through it `Defs/`) only. -/

noncomputable section

namespace TinaV2.Aggregate

open MeasureTheory Matrix ProbabilityTheory Set

variable {Ω : Type} [MeasurableSpace Ω]

/-! ## `Q = qI + γ11ᵀ` and the cost in coordinates -/

/-- `(Q v)_i = q v_i + γ Σ_j v_j` for `Q = qI + γ11ᵀ`. -/
theorem aggQ_mulVec (n : ℕ) (q γ : ℝ) (v : Fin n → ℝ) (i : Fin n) :
    (aggQ n q γ *ᵥ v) i = q * v i + γ * ∑ j, v j := by
  simp [aggQ, mulVec, dotProduct, add_mul, Finset.sum_add_distrib, Matrix.one_apply,
    Finset.mul_sum]

/-- `vᵀ Q v = q Σ_i v_i² + γ (Σ_i v_i)²`. -/
theorem quad_aggQ (n : ℕ) (q γ : ℝ) (v : Fin n → ℝ) :
    quad (aggQ n q γ) v = q * ∑ i, v i ^ 2 + γ * (∑ i, v i) ^ 2 := by
  simp only [quad, dotProduct, aggQ_mulVec]
  calc ∑ i, v i * (q * v i + γ * ∑ j, v j)
      = ∑ i, (q * v i ^ 2 + (γ * ∑ j, v j) * v i) :=
        Finset.sum_congr rfl fun i _ => by ring
    _ = q * ∑ i, v i ^ 2 + (γ * ∑ j, v j) * ∑ i, v i := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
    _ = q * ∑ i, v i ^ 2 + γ * (∑ i, v i) ^ 2 := by ring

/-- Eq. (shared_resource_cost) is `½ xᵀQx − θᵀx` with `Q = qI + γ11ᵀ`:
`f(x,θ) = Σ_i (q/2 x_i² − θ_i x_i) + γ/2 (Σ_i x_i)²`. -/
theorem quadCost_aggQ (n : ℕ) (q γ : ℝ) (t x : Fin n → ℝ) :
    quadCost (aggQ n q γ) t 0 x
      = ∑ i, (q / 2 * x i ^ 2 - t i * x i) + γ / 2 * (∑ i, x i) ^ 2 := by
  rw [quadCost, quad_aggQ, dotProduct, Finset.sum_sub_distrib, ← Finset.mul_sum]
  ring

/-- The cost at `x = m + v`, expanded and grouped: the terms in `v` alone that
survive in Eq. (aggregate_centered_cost), the terms in `m` alone, and the
remainder (linear in `v`, linear in `t`, and the off-diagonal part of
`(Σ_i v_i)²`). A ring identity. -/
theorem aggCost_split (n : ℕ) (q γ : ℝ) (m v t : Fin n → ℝ) :
    quadCost (aggQ n q γ) t 0 (m + v)
      = ∑ i, ((q + γ) / 2 * v i ^ 2 - t i * v i)
        + (q / 2 * ∑ i, m i ^ 2 + γ / 2 * (∑ i, m i) ^ 2)
        + (∑ i, (q * m i + γ * ∑ j, m j) * v i - ∑ i, m i * t i
            + γ / 2 * ((∑ i, v i) ^ 2 - ∑ i, v i ^ 2)) := by
  have h1 : ∑ i, (q / 2 * (m i + v i) ^ 2 - t i * (m i + v i))
      = q / 2 * ∑ i, m i ^ 2 + q * ∑ i, m i * v i + q / 2 * ∑ i, v i ^ 2
        - ∑ i, m i * t i - ∑ i, t i * v i := by
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have h2 : ∑ i, (m i + v i) = ∑ i, m i + ∑ i, v i := Finset.sum_add_distrib
  have h3 : ∑ i, ((q + γ) / 2 * v i ^ 2 - t i * v i)
      = (q + γ) / 2 * ∑ i, v i ^ 2 - ∑ i, t i * v i := by
    rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  have h4 : ∑ i, (q * m i + γ * ∑ j, m j) * v i
      = q * ∑ i, m i * v i + γ * (∑ j, m j) * ∑ i, v i := by
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [quadCost_aggQ, Pi.add_apply]
  rw [h1, h2, h3, h4]
  ring

/-! ## The radius-0 view is the agent's own state -/

section View

variable {ι α : Type} [Fintype ι] [Fintype α]

/-- With one state coordinate per agent, agent `i` sees its own coordinate at
radius 0. -/
theorem self_mem_nbhd_zero (M : Model ι ι α) (ho : M.owner = id) (i : ι) :
    M.owner i ∈ M.nbhd 0 i := by
  simp [ho, Model.nbhd]

/-- With one state coordinate per agent, the radius-0 view of agent `i` is the
single coordinate `s i`. -/
theorem view_zero (M : Model ι ι α) (ho : M.owner = id) (i : ι) (s : ι → ℝ) :
    M.view 0 i s = fun _ => s i := by
  funext k
  have hk : M.G.edist i (M.owner k.1) ≤ 0 := k.2
  rw [nonpos_iff_eq_zero, SimpleGraph.edist_eq_zero_iff] at hk
  have hk' : k.1 = i := (congrFun ho k.1).symm.trans hk.symm
  simp [Model.view, hk']

/-- `u_i = g_i(θ_i)`: with one scalar state and one scalar action per agent, a
fresh-local rule is a measurable function of the agent's own state. -/
theorem exists_local_rule_eq (M : Model ι ι ι) (ho : M.owner = id) (ha : M.actor = id)
    {g : Rule M.actor fun i => M.Scope 0 i → ℝ} (hg : ∀ c, Measurable (g c)) :
    ∃ φ : ι → ℝ → ℝ, (∀ c, Measurable (φ c)) ∧
      ∀ (s : ι → ℝ) (c : ι), g c (M.view 0 (M.actor c) s) = φ c (s c) := by
  refine ⟨fun c x => g c fun _ => x,
    fun c => (hg c).comp (Measurable.of_eval fun _ => measurable_id), fun s c => ?_⟩
  rw [view_zero M ho]
  have hc : M.actor c = c := congrFun ha c
  exact congrArg (g c) (funext fun _ => congrArg s hc)

end View

/-! ## Constant rules, centering, integrability of the cost -/

section Rules

variable {ι α : Type} [Fintype α]

/-- A constant rule is admissible (finite measure). -/
theorem admissible_const {actor : α → ι} {O : ι → Type} [∀ i, MeasurableSpace (O i)]
    (μ : Measure Ω) [IsFiniteMeasure μ] (Z : (i : ι) → Ω → O i) (a : α → ℝ) :
    Admissible μ Z (fun c _ => a c : Rule actor O) :=
  ⟨fun _ => measurable_const, memLp_const a⟩

omit [MeasurableSpace Ω] [Fintype α] in
/-- The joint action of a constant rule is the constant. -/
theorem jointAction_const {actor : α → ι} {O : ι → Type} (Z : (i : ι) → Ω → O i)
    (a : α → ℝ) (ω : Ω) : jointAction (fun c _ => a c : Rule actor O) Z ω = a := rfl

/-- Subtracting the mean keeps a vector square-integrable. -/
theorem memLp_center {μ : Measure Ω} [IsFiniteMeasure μ] {X : Ω → α → ℝ} (hX : MemLp X 2 μ) :
    MemLp (center μ X) 2 μ :=
  memLp_pi_iff.2 fun k => (memLp_pi_iff.1 hX k).sub (memLp_const _)

/-- `ω ↦ ½ uᵀQu − bᵀu` is integrable for square-integrable `u` and `b`. -/
theorem integrable_quadCost {μ : Measure Ω} (Q : Matrix α α ℝ) {b u : Ω → α → ℝ}
    (hb : MemLp b 2 μ) (hu : MemLp u 2 μ) :
    Integrable (fun ω => quadCost Q (b ω) 0 (u ω)) μ := by
  have hbu : Integrable (fun ω => b ω ⬝ᵥ u ω) μ := by
    simp only [dotProduct]
    exact integrable_finsetSum _ fun c _ =>
      (memLp_pi_iff.1 hb c).integrable_mul (memLp_pi_iff.1 hu c)
  have h : (fun ω => quadCost Q (b ω) 0 (u ω))
      = fun ω => 1 / 2 * quad Q (u ω) - b ω ⬝ᵥ u ω := by
    funext ω
    rw [quadCost, add_zero]
  rw [h]
  exact ((integrable_quad Q hu).const_mul _).sub hbu

/-- `E[(Σ_i X_i)²] = Σ_i E[X_i²]` when the cross moments `E[X_i X_j]`, `i ≠ j`,
vanish. -/
theorem integral_sq_sum_of_cross {μ : Measure Ω} {X : Ω → α → ℝ} (hX : MemLp X 2 μ)
    (hcross : ∀ i j, i ≠ j → ∫ ω, X ω i * X ω j ∂μ = 0) :
    ∫ ω, (∑ i, X ω i) ^ 2 ∂μ = ∑ i, ∫ ω, X ω i ^ 2 ∂μ := by
  classical
  have hXi := memLp_pi_iff.1 hX
  have hmul : ∀ i j, Integrable (fun ω => X ω i * X ω j) μ := fun i j =>
    (hXi i).integrable_mul (hXi j)
  have hsq : ∀ ω, (∑ i, X ω i) ^ 2 = ∑ i, ∑ j, X ω i * X ω j := fun ω => by
    rw [sq, Finset.sum_mul_sum]
  simp_rw [hsq]
  rw [integral_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ => hmul i j]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [integral_finsetSum _ fun j _ => hmul i j,
    Finset.sum_eq_single i (fun j _ hji => hcross i j (Ne.symm hji)) (by simp)]
  simp [sq]

/-- `Q⁻¹ b` is the solution of `Q y = b` for `Q ≻ 0`. -/
theorem inv_mulVec_eq_of_mulVec_eq [DecidableEq α] {Q : Matrix α α ℝ} (hQ : Q.PosDef)
    {y b : α → ℝ} (h : Q *ᵥ y = b) : Q⁻¹ *ᵥ b = y := by
  rw [← h, mulVec_mulVec, nonsing_inv_mul _ ((Matrix.isUnit_iff_isUnit_det _).1 hQ.isUnit),
    one_mulVec]

/-- `Q (Q⁻¹ b) = b` for `Q ≻ 0`. -/
theorem mulVec_inv_mulVec [DecidableEq α] {Q : Matrix α α ℝ} (hQ : Q.PosDef) (b : α → ℝ) :
    Q *ᵥ (Q⁻¹ *ᵥ b) = b := by
  rw [mulVec_mulVec, mul_nonsing_inv _ ((Matrix.isUnit_iff_isUnit_det _).1 hQ.isUnit),
    one_mulVec]

end Rules

/-! ## Independent mean-zero states -/

section State

variable {n : ℕ} {μ : Measure Ω} {now : Ω → Fin n → ℝ} {σ : ℝ}

/-- Independent mean-zero states are uncorrelated: `E[θ_i θ_j] = 0`, `i ≠ j`. -/
theorem integral_mul_of_ne (h : AggregateState μ now σ) {i j : Fin n} (hij : i ≠ j) :
    ∫ ω, now ω i * now ω j ∂μ = 0 := by
  rw [(h.indep.indepFun hij).integral_fun_mul_eq_mul_integral
      (memLp_pi_iff.1 h.memLp i).aestronglyMeasurable
      (memLp_pi_iff.1 h.memLp j).aestronglyMeasurable,
    h.mean_zero i, zero_mul]

/-- `E[(Σ_i θ_i)²] = n σ²` for independent mean-zero states of variance `σ²`. -/
theorem integral_sq_sum (h : AggregateState μ now σ) :
    ∫ ω, (∑ i, now ω i) ^ 2 ∂μ = n * σ ^ 2 := by
  rw [integral_sq_sum_of_cross h.memLp fun i j hij => integral_mul_of_ne h hij]
  simp [h.variance]

/-- `E[Σ_i θ_i²] = n σ²`. -/
theorem integral_sum_sq (h : AggregateState μ now σ) :
    ∫ ω, ∑ i, now ω i ^ 2 ∂μ = n * σ ^ 2 := by
  rw [integral_finsetSum _ fun i _ => (memLp_pi_iff.1 h.memLp i).integrable_sq]
  simp [h.variance]

end State

end TinaV2.Aggregate
