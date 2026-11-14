import TinaV2.Defs.Cost

/-! # Architectures, admissible rules and regret (claim C6)

Paper: `main-alt.tex` Section "Model and observations", Eqs. (r_neighborhood),
(radius_arch), (architecture_regret), (Rinf_general), (eta_S_definition); and
`technical-appendices-alt.tex` Eq. (policy_subspace) for the sigma-algebra form.

Conventions.
* `ι` agents, `κ` state coordinates, `α` action coordinates, all finite.
  `owner k` is the agent whose local state contains state coordinate `k`, and
  `actor c` is the agent who chooses action coordinate `c`. This is the paper's
  `θ = (θ_1,…,θ_n)`, `θ_i ∈ ℝ^{m_i}` and `x = (x_1,…,x_n)`, `x_i ∈ ℝ^{d_i}`.
* A snapshot is a random state vector `Ω → κ → ℝ`. Definitions here take
  snapshots, not a process and a time: `R(𝒜_{r,τ})` at epoch `t` is
  `M.R μ r (θ (t - τ)) (θ t)`.
* The radius is `r : ℕ∞`. `r = ⊤` is the complete view (finding F5). -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory

variable {Ω : Type} [MeasurableSpace Ω] {ι κ α : Type} [Fintype κ] [Fintype α]

/-! ## Rules and regret for arbitrary observations -/

/-- A joint rule `(g_i)`. Agent `i` observes a value in `O i`; each action
coordinate `c` is a function of the observation of its agent `actor c`. Agent
`i`'s vector-valued `g_i` is the tuple of the `g c` with `actor c = i`. -/
abbrev Rule (actor : α → ι) (O : ι → Type) : Type := (c : α) → O (actor c) → ℝ

/-- The joint action `u = (g_i(Z_i))_i`. -/
def jointAction {actor : α → ι} {O : ι → Type} (g : Rule actor O)
    (Z : (i : ι) → Ω → O i) : Ω → α → ℝ :=
  fun ω c => g c (Z (actor c) ω)

/-- Admissible rule: `u_i = g_i(Z_i)` with finite second moment. Measurability
of each `g c` is the regularity the paper leaves implicit. -/
def Admissible {actor : α → ι} {O : ι → Type} [∀ i, MeasurableSpace (O i)]
    (μ : Measure Ω) (Z : (i : ι) → Ω → O i) (g : Rule actor O) : Prop :=
  (∀ c, Measurable (g c)) ∧ MemLp (jointAction g Z) 2 μ

/-- Eq. (architecture_regret): `R = inf_{g_i} ½ E[(u − x⋆)ᵀ Q (u − x⋆)]` over
admissible rules of the observations `Z`. The infimum is over a nonempty family
(the zero rule) bounded below by `0` when `Q` is positive definite, so the real
`⨅` is the true infimum. -/
def regret (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι) {O : ι → Type}
    [∀ i, MeasurableSpace (O i)] (xstar : Ω → α → ℝ) (Z : (i : ι) → Ω → O i) : ℝ :=
  ⨅ g : {g : Rule actor O // Admissible μ Z g}, excessCost μ Q xstar (jointAction g.1 Z)

/-! ## Sigma-algebra form (appendix) -/

/-- Eq. (policy_subspace): `u ∈ 𝒮(𝒜)` for `𝒜 = (𝒢_i)`: finite second moment
and `u_i` is `𝒢_i`-measurable. -/
def SigmaAdmissible (μ : Measure Ω) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω)
    (u : Ω → α → ℝ) : Prop :=
  (∀ c, Measurable[𝒢 (actor c)] fun ω => u ω c) ∧ MemLp u 2 μ

/-- Regret of the architecture `𝒜 = (𝒢_i)` in the appendix's form. -/
def sigmaRegret (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι) (xstar : Ω → α → ℝ)
    (𝒢 : ι → MeasurableSpace Ω) : ℝ :=
  ⨅ u : {u : Ω → α → ℝ // SigmaAdmissible μ actor 𝒢 u}, excessCost μ Q xstar u.1

/-! ## The model of the main text -/

/-- The centered affine tracking model: graph `G`, desired action `x⋆ = K θ`,
loss `½ (x − x⋆)ᵀ Q (x − x⋆)` with `Q ≻ 0` (Eq. (tracking_loss)). -/
structure Model (ι κ α : Type) [Fintype κ] [Fintype α] where
  /-- Communication graph on the agents. -/
  G : SimpleGraph ι
  /-- Agent whose local state contains a state coordinate. -/
  owner : κ → ι
  /-- Agent who chooses an action coordinate. -/
  actor : α → ι
  /-- Decision sensitivity: `x⋆ = K θ`. -/
  K : Matrix α κ ℝ
  /-- Cost matrix. -/
  Q : Matrix α α ℝ
  Q_posDef : Q.PosDef

namespace Model

variable (M : Model ι κ α)

/-- Eq. (r_neighborhood): `𝒩_r(i) = {j : d_G(i,j) ≤ r}`. The hop distance is
`⊤` between agents in different components. -/
def nbhd (r : ℕ∞) (i : ι) : Set ι := {j | M.G.edist i j ≤ r}

/-- State coordinates agent `i` sees at radius `r`: those owned by `𝒩_r(i)`. -/
abbrev Scope (r : ℕ∞) (i : ι) : Type := {k : κ // M.owner k ∈ M.nbhd r i}

/-- Agent `i`'s radius-`r` view of the state vector `s`. -/
def view (r : ℕ∞) (i : ι) (s : κ → ℝ) : M.Scope r i → ℝ := fun k => s k.1

/-- Eq. (radius_arch): `Z_i = (θ_j : j ∈ 𝒩_r(i))` read from the snapshot `snap`
(`snap = θ_{t−τ}` gives `Z_{i,t}^{(r,τ)}`). -/
def obs (r : ℕ∞) (snap : Ω → κ → ℝ) : (i : ι) → Ω → (M.Scope r i → ℝ) :=
  fun i ω => M.view r i (snap ω)

/-- The desired action `x⋆ = K θ` for the current state `now`. -/
def target (now : Ω → κ → ℝ) : Ω → α → ℝ := fun ω => M.K *ᵥ now ω

/-- `R(𝒜_{r,τ})` at epoch `t` is `M.R μ r (θ (t - τ)) (θ t)`: the agents see the
radius-`r` views of the snapshot `snap` and track the desired action for `now`. -/
def R (μ : Measure Ω) (r : ℕ∞) (snap now : Ω → κ → ℝ) : ℝ :=
  regret μ M.Q M.actor (M.target now) (M.obs r snap)

/-- Fresh-local regret `R_loc = R(𝒜_{0,0})`. -/
def Rloc (μ : Measure Ω) (now : Ω → κ → ℝ) : ℝ := M.R μ 0 now now

/-- Stale-global regret `R_glob(τ)`: every agent sees the whole snapshot. -/
def Rglob (μ : Measure Ω) (snap now : Ω → κ → ℝ) : ℝ := M.R μ ⊤ snap now

/-- Eq. (Rinf_general): `R_∞ = ½ E[x⋆ᵀ Q x⋆]`. -/
def Rinf (μ : Measure Ω) (now : Ω → κ → ℝ) : ℝ :=
  1 / 2 * ∫ ω, quad M.Q (M.target now ω) ∂μ

/-- Eq. (eta_S_definition): `η_S(r) = R(𝒜_{r,0}) / R_∞`. The paper defines it
for `R_∞ > 0`; statements that use it carry that hypothesis. -/
def etaS (μ : Measure Ω) (r : ℕ∞) (now : Ω → κ → ℝ) : ℝ :=
  M.R μ r now now / M.Rinf μ now

end Model

/-! ## Covariance and centering -/

/-- `Σ_S = Cov(θ)`. -/
def covMatrix (μ : Measure Ω) (X : Ω → κ → ℝ) : Matrix κ κ ℝ :=
  Matrix.of fun k l => cov[fun ω => X ω k, fun ω => X ω l; μ]

/-- The centered vector `θ^c = θ − E[θ]`. -/
def center {β : Type} (μ : Measure Ω) (X : Ω → β → ℝ) : Ω → β → ℝ :=
  fun ω k => X ω k - ∫ ω', X ω' k ∂μ

end TinaV2
