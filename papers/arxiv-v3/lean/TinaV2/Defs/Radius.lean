import TinaV2.Prelude

/-! # Radius choice: gain, crossover threshold and closed-form radii

Paper: `main-v3.tex` Eqs. (OU_crossover), (snapshot_gain),
(marginal_balance_condition), (generic_exponential_rstar),
(canonical_optimal_radius). All are functions of real numbers. -/

noncomputable section

namespace TinaV2

open Real Set

/-- Eq. (OU_crossover): `ρ⋆ = ½ log (1 / (1 − η_S(0)))`. -/
def rhoStar (η0 : ℝ) : ℝ := 1 / 2 * log (1 / (1 - η0))

/-- Eq. (snapshot_gain): `G(r) = (1 − η_S(r)) e^{−2τ(r)/T}` for an omission
curve `η` and a delay curve `τ`. The radius type `ρ` is `ℕ∞` on a graph and `ℝ`
for a continuous radius. -/
def gain {ρ : Type} (η τ : ρ → ℝ) (T : ℝ) (r : ρ) : ℝ :=
  (1 - η r) * exp (-2 * τ r / T)

/-- Left side minus right side of Eq. (marginal_balance_condition) at radius
`r ∈ [0, D]`: `d/dr log[1 − η(r)] − 2τ'(r)/T`. Derivatives are taken within
`[0, D]`, so they are one-sided at the endpoints. -/
def balanceGap (η τ : ℝ → ℝ) (T D : ℝ) (r : ℝ) : ℝ :=
  derivWithin (fun x => log (1 - η x)) (Icc 0 D) r - 2 * derivWithin τ (Icc 0 D) r / T

/-- Hypotheses of Proposition (marginal_balance) on the curves: `τ` and `η`
continuously differentiable on `[0, D]` with `τ' ≥ 0`, `η' ≤ 0`, `0 ≤ η < 1`. -/
structure SmoothCurves (η τ : ℝ → ℝ) (D : ℝ) : Prop where
  D_pos : 0 < D
  τ_contDiffOn : ContDiffOn ℝ 1 τ (Icc 0 D)
  η_contDiffOn : ContDiffOn ℝ 1 η (Icc 0 D)
  τ_deriv_nonneg : ∀ r ∈ Icc 0 D, 0 ≤ derivWithin τ (Icc 0 D) r
  η_deriv_nonpos : ∀ r ∈ Icc 0 D, derivWithin η (Icc 0 D) r ≤ 0
  η_range : ∀ r ∈ Icc 0 D, 0 ≤ η r ∧ η r < 1

/-- Eq. (generic_exponential_rstar):
`r⋆ = (ℓ_c/2) [log(η_0 (1 + vT/ℓ_c))]_+`. -/
def expRadius (η0 ℓc v T : ℝ) : ℝ := ℓc / 2 * max (log (η0 * (1 + v * T / ℓc))) 0

/-- Eq. (canonical_optimal_radius):
`r⋆ = (ℓ_c/2) [log((ℓ_c + vT)/(ℓ_c + 2ℓ_s))]_+`. -/
def canonRadius (ℓc ℓs v T : ℝ) : ℝ := ℓc / 2 * max (log ((ℓc + v * T) / (ℓc + 2 * ℓs))) 0

end TinaV2
