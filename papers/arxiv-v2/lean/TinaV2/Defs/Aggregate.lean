import TinaV2.Defs.Architecture

/-! # The aggregate-coupling example (claims C12, C13)

Paper: `main-alt.tex` Section "Role of Decision Coupling", Eqs.
(shared_resource_Q), (aggregate_eta), (aggregate_rho_star);
`technical-appendices-alt.tex` Eqs. (aggregate_Rinf), (aggregate_Rloc). -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory

/-- Eq. (shared_resource_Q): `Q = q I + γ 1 1ᵀ`. -/
def aggQ (n : ℕ) (q γ : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  q • (1 : Matrix (Fin n) (Fin n) ℝ) + γ • Matrix.of fun _ _ => (1 : ℝ)

/-- The model of Eq. (shared_resource_cost): `n` agents with one scalar state
and one scalar action each, `Q = q I + γ 1 1ᵀ` and `K = Q⁻¹`. The graph is
unrestricted. -/
structure IsAggregateModel {n : ℕ} (M : Model (Fin n) (Fin n) (Fin n)) (q γ : ℝ) : Prop where
  Q_eq : M.Q = aggQ n q γ
  K_eq : M.K = M.Q⁻¹
  owner_eq : M.owner = id
  actor_eq : M.actor = id

/-- "The state components `θ_i` are independent and mean-zero, with equal
finite variance `σ²`", at a single epoch. -/
structure AggregateState {Ω : Type} [MeasurableSpace Ω] {n : ℕ} (μ : Measure Ω)
    (now : Ω → Fin n → ℝ) (σ : ℝ) : Prop where
  measurable : Measurable now
  memLp : MemLp now 2 μ
  indep : iIndepFun (fun i ω => now ω i) μ
  mean_zero : ∀ i, ∫ ω, now ω i ∂μ = 0
  variance : ∀ i, ∫ ω, now ω i ^ 2 ∂μ = σ ^ 2

/-- Eq. (aggregate_eta): `η_S(0) = γ²(n−1) / ((q+γ)(q+γ(n−1)))`. -/
def aggEta (n : ℕ) (q γ : ℝ) : ℝ := γ ^ 2 * (n - 1) / ((q + γ) * (q + γ * (n - 1)))

/-- Eq. (aggregate_rho_star):
`ρ⋆(γ,n) = ½ log[(q+γ)(q+γ(n−1)) / (q(q+γn))]`. -/
def aggRhoStar (n : ℕ) (q γ : ℝ) : ℝ :=
  1 / 2 * Real.log ((q + γ) * (q + γ * (n - 1)) / (q * (q + γ * n)))

/-- Eq. (aggregate_Rinf): `R_∞ = nσ²(q+γ(n−1)) / (2q(q+γn))`. -/
def aggRinf (n : ℕ) (q γ σ : ℝ) : ℝ := n * σ ^ 2 * (q + γ * (n - 1)) / (2 * q * (q + γ * n))

/-- Eq. (aggregate_Rloc): `R_loc = nσ²γ²(n−1) / (2q(q+γ)(q+γn))`. -/
def aggRloc (n : ℕ) (q γ σ : ℝ) : ℝ :=
  n * σ ^ 2 * γ ^ 2 * (n - 1) / (2 * q * (q + γ) * (q + γ * n))

end TinaV2
