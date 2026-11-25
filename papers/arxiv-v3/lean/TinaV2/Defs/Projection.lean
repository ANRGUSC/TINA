import TinaV2.Defs.Architecture

/-! # Expected cost, the weighted inner product and orthogonal projection
(claims C1, C1.b, C2, C3)

Paper: `technical-appendices-v3.tex` lines 25-269, Eqs. (quadratic_cost), (policy_subspace),
(hilbert_space), (q_inner_product), (optimal_projection),
(conditional_normal_equations), (block_conditional_normal_equations).

Conventions.
* An element of `ℋ = L²(Ω, ℱ, ℙ; ℝ^d)` is a function `u : Ω → α → ℝ` with
  `MemLp u 2 μ`. Two such functions are the same element of `ℋ` when they are
  equal almost surely, so "unique" and "closed" are read up to `=ᵐ[μ]`.
* The cost data enter as random variables: `b : Ω → α → ℝ` is `b(θ_t)` and
  `c : Ω → ℝ` is `c(θ_t)`. The state `θ_t` itself does not appear, because the
  fixed-epoch formulation uses it only through these two.
* An architecture is the family `𝒢 : ι → MeasurableSpace Ω` of the agents'
  sigma-algebras (the appendix's form, as in `SigmaAdmissible`). -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory Filter Topology

variable {Ω : Type} [MeasurableSpace Ω] {ι α : Type} [Fintype α]

/-- Expected cost `E[f(u, θ_t)]` of the joint action `u` under
Eq. (quadratic_cost), `f(x,θ) = ½ xᵀQx − b(θ)ᵀx + c(θ)`. -/
def expectedCost (μ : Measure Ω) (Q : Matrix α α ℝ) (b : Ω → α → ℝ) (c : Ω → ℝ)
    (u : Ω → α → ℝ) : ℝ :=
  ∫ ω, quadCost Q (b ω) (c ω) (u ω) ∂μ

/-- Eq. (q_inner_product): `⟨u,v⟩_Q = E[uᵀ Q v]`. -/
def qInner (μ : Measure Ω) (Q : Matrix α α ℝ) (u v : Ω → α → ℝ) : ℝ :=
  ∫ ω, u ω ⬝ᵥ (Q *ᵥ v ω) ∂μ

/-- Eq. (q_inner_product): `‖u‖_Q² = ⟨u,u⟩_Q`. -/
def qNormSq (μ : Measure Ω) (Q : Matrix α α ℝ) (u : Ω → α → ℝ) : ℝ := qInner μ Q u u

/-- Eq. (policy_subspace): the policy space `𝒮(𝒜)` of the architecture
`𝒜 = (𝒢_i)`, as a set of joint actions. -/
def policySpace (μ : Measure Ω) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω) :
    Set (Ω → α → ℝ) :=
  {u | SigmaAdmissible μ actor 𝒢 u}

/-- "`S` is a closed linear subspace of `ℋ`". Closed: if members of `S`
converge in `L²` (`E‖u_n − v‖² → 0`) to some `v ∈ ℋ`, then `v` is almost surely
equal to a member of `S`. -/
structure IsClosedSubspace (μ : Measure Ω) (S : Set (Ω → α → ℝ)) : Prop where
  memLp : ∀ u ∈ S, MemLp u 2 μ
  zero_mem : (0 : Ω → α → ℝ) ∈ S
  add_mem : ∀ u ∈ S, ∀ v ∈ S, u + v ∈ S
  smul_mem : ∀ (a : ℝ), ∀ u ∈ S, a • u ∈ S
  closed : ∀ (u : ℕ → Ω → α → ℝ) (v : Ω → α → ℝ), (∀ n, u n ∈ S) → MemLp v 2 μ →
    Tendsto (fun n => ∫ ω, ∑ c, (u n ω c - v ω c) ^ 2 ∂μ) atTop (𝓝 0) →
    ∃ v' ∈ S, v' =ᵐ[μ] v

/-- Eq. (optimal_projection): `p = Π_S x`, the orthogonal projection of `x`
onto `S` with respect to `⟨·,·⟩_Q`. It is the member of `S` whose error `x − p`
is `Q`-orthogonal to every member of `S`. -/
def IsQProjection (μ : Measure Ω) (Q : Matrix α α ℝ) (S : Set (Ω → α → ℝ))
    (x p : Ω → α → ℝ) : Prop :=
  p ∈ S ∧ ∀ h ∈ S, qInner μ Q h (x - p) = 0

/-- Eq. (conditional_normal_equations): `E[(Q u − b(θ_t))_i | 𝒢_i] = 0` for
every agent `i`, written for each action coordinate `c` of agent `actor c`. -/
def NormalEquations (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b u : Ω → α → ℝ) : Prop :=
  ∀ c, μ[fun ω => (Q *ᵥ u ω - b ω) c | 𝒢 (actor c)] =ᵐ[μ] 0

/-- Eq. (block_conditional_normal_equations):
`Q_ii u_i + Σ_{j≠i} Q_ij E[u_j | 𝒢_i] = E[b_i(θ_t) | 𝒢_i]`, written for each
action coordinate `c` of agent `i = actor c`. The coordinates `c'` of the same
agent enter as `u_{c'}`; those of other agents as `E[u_{c'} | 𝒢_i]`. -/
def BlockNormalEquations [DecidableEq ι] (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b u : Ω → α → ℝ) : Prop :=
  ∀ c, (fun ω => ∑ c', Q c c' *
      if actor c' = actor c then u ω c' else (μ[fun ω' => u ω' c' | 𝒢 (actor c)]) ω)
    =ᵐ[μ] μ[fun ω => b ω c | 𝒢 (actor c)]

end TinaV2
