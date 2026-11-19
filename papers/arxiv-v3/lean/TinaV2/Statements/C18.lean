import TinaV2.Defs

/-! # C18: Exponential omission by self-similarity

Paper: main-v3.tex Lemma (canonical_eta_S), Eq. (canonical_eta_S). -/

namespace TinaV2.C18

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- For the canonical field with `σ ≠ 0`, at every location and time and for
every radius `r ≥ 0`: `η_S(r) = η₀ e^{−2r/ℓ_c}` with `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`. -/
def Statement : Prop :=
  ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → ℝ → Ω → ℝ) (σ ℓs T ℓc q : ℝ),
    CanonicalField μ θ σ ℓs T → σ ≠ 0 → 0 < ℓc → 0 < q →
    ∀ (z t r : ℝ), 0 ≤ r →
      lineEtaS μ q θ ℓc r z t = ℓc / (ℓc + 2 * ℓs) * exp (-2 * r / ℓc)

end TinaV2.C18
