import TinaV2.Prelude

/-! # Radius choice: gain, crossover threshold and closed-form radii

Paper: `main-alt.tex` Eqs. (OU_crossover), (snapshot_gain),
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

/-- Eq. (generic_exponential_rstar):
`r⋆ = (ℓ_c/2) [log(η_0 (1 + vT/ℓ_c))]_+`. -/
def expRadius (η0 ℓc v T : ℝ) : ℝ := ℓc / 2 * max (log (η0 * (1 + v * T / ℓc))) 0

/-- Eq. (canonical_optimal_radius):
`r⋆ = (ℓ_c/2) [log((ℓ_c + vT)/(ℓ_c + 2ℓ_s))]_+`. -/
def canonRadius (ℓc ℓs v T : ℝ) : ℝ := ℓc / 2 * max (log ((ℓc + v * T) / (ℓc + 2 * ℓs))) 0

end TinaV2
