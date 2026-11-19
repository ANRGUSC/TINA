import TinaV2.Defs

/-! # C9: Unequal-rate formula for a complete old snapshot

Paper: main-v3.tex Section "Complete old information versus current local
information", the paragraph after Corollary (OU_stale_regret), lines 473-490.

Mode `k` is the part `P_k θ` of the state, where the matrices `P_k` sum to the
identity; `x_k⋆ = K P_k θ`. Each mode is an Ornstein–Uhlenbeck process in the
sense of claim C4.c, with its own coherence time. -/

namespace TinaV2.C09

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- The state splits into modes `P_k θ` with `∑_k P_k = 1`. The mode processes
are independent; mode `k` is jointly Gaussian with mean zero and covariance
`e^{−|t−s|/T_k} S_k`, `T_k > 0`. For `R_∞ > 0`, with `x_k⋆ = K P_k θ_t` and
`w_k = E[(x_k⋆)ᵀ Q x_k⋆] / E[(x⋆)ᵀ Q x⋆]`: `x⋆ = ∑_k x_k⋆`, `∑_k w_k = 1`, and
`1 − R_glob(τ)/R_∞ = ∑_k w_k e^{−2τ/T_k}`. -/
def Statement : Prop :=
  ∀ {ι κ α Ω m : Type} [Fintype ι] [Fintype κ] [Fintype α] [Fintype m] [DecidableEq κ]
    [MeasurableSpace Ω] (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → Ω → κ → ℝ) (P : m → Matrix κ κ ℝ) (Tc : m → ℝ) (S : m → Matrix κ κ ℝ),
    (∀ t, Measurable (θ t)) →
    ∑ k, P k = 1 →
    iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ →
    (∀ k, 0 < Tc k ∧
      IsGaussianProcess (fun (p : ℝ × κ) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
      (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
      (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ
        = exp (-|t - s| / Tc k) * S k j l)) →
    ∀ t τ : ℝ, 0 ≤ τ → 0 < M.Rinf μ (θ t) →
      let xk : m → Ω → α → ℝ := fun k ω => M.K *ᵥ (P k *ᵥ θ t ω)
      let w : m → ℝ := fun k =>
        (∫ ω, quad M.Q (xk k ω) ∂μ) / (∫ ω, quad M.Q (M.target (θ t) ω) ∂μ)
      (∀ ω, M.target (θ t) ω = ∑ k, xk k ω) ∧
      ∑ k, w k = 1 ∧
      1 - M.Rglob μ (θ (t - τ)) (θ t) / M.Rinf μ (θ t) = ∑ k, w k * exp (-2 * τ / Tc k)

end TinaV2.C09
