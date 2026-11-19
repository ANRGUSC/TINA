import TinaV2.Statements

/-! # C19, attempt A2: mirrors paper proof C19/p1, for the field model

Theorem (canonical_optimal_radius), main-v3.tex 899-939, as a statement about
the regret of the canonical field (`C19.Statement`, formalization C19/f2): the
radius formula, its uniqueness and the threshold. The comparative statics in
the rest of the paper's proof are claim C19.b.

Attempt A1 proved the algebraic form, about the gain function only. Here the
composition paragraph (C17.b) turns the regret of the field into
`R_∞ [1 − G(r)]` (step 0, a sentence of the proof since arXiv v3, upstream
`12a9b32`, finding F10), the lemma (C18) supplies the omission curve, and the
proposition (C16) is applied to that curve. -/

namespace TinaV2.C19.A2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
  {θ : ℝ → ℝ → Ω → ℝ} {σ ℓs T ℓc q : ℝ}

/-- Step 0 (main-v3.tex 927-929): "The field calculation preceding Lemma
(canonical_eta_S) shows that a delayed interval retains `e^{−2τ(r)/T}` times
its fresh gain, so its regret satisfies `R(r) = R_∞ [1 − G(r)]`", with
`τ(r) = r/v` and `G(r) = (1 − η_S(r)) e^{−2τ(r)/T}`, Eq. (snapshot_gain).
`R_∞ ≠ 0` is the section's standing assumption `R_∞ > 0`; `η_S` is a ratio. -/
theorem s0_field_regret (hC17b : C17b.Statement) (h : CanonicalField μ θ σ ℓs T)
    (hℓc : 0 < ℓc) (hq : 0 < q) {v : ℝ} (hv : 0 < v) (z t : ℝ)
    (hRinf : lineRinf μ q θ ℓc z t ≠ 0) {r : ℝ} (hr : 0 ≤ r) :
    lineR μ q θ ℓc r (r / v) z t = lineRinf μ q θ ℓc z t *
      (1 - gain (fun r : ℝ => lineEtaS μ q θ ℓc r z t) (fun r : ℝ => r / v) T r) := by
  have hcomp := (hC17b μ θ σ ℓs T ℓc q h hℓc hq z t r (r / v) hr (div_nonneg hr hv.le)).2
  have hexp : exp (-(r / v) / T) ^ 2 = exp (-2 * (r / v) / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  have hfresh : lineR μ q θ ℓc r 0 z t
      = lineEtaS μ q θ ℓc r z t * lineRinf μ q θ ℓc z t := by
    rw [lineEtaS, div_mul_cancel₀ _ hRinf]
  rw [hexp, hfresh] at hcomp
  show lineR μ q θ ℓc r (r / v) z t = lineRinf μ q θ ℓc z t *
    (1 - (1 - lineEtaS μ q θ ℓc r z t) * exp (-2 * (r / v) / T))
  linear_combination -hcomp

/-- Step 1 (main-v3.tex 929-930): "The lemma gives
`η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`": the omission curve of the field is
`η_S(r) = η₀ e^{−2r/ℓ_c}`, and this `η₀` is an admissible prefactor for
Proposition (generic_exponential_radius), `0 < η₀ < 1`. -/
theorem s1_eta0 (hC18 : C18.Statement) (h : CanonicalField μ θ σ ℓs T) (hσ : σ ≠ 0)
    (hℓc : 0 < ℓc) (hq : 0 < q) (z t : ℝ) {r : ℝ} (hr : 0 ≤ r) :
    lineEtaS μ q θ ℓc r z t = ℓc / (ℓc + 2 * ℓs) * exp (-2 * r / ℓc) ∧
      0 < ℓc / (ℓc + 2 * ℓs) ∧ ℓc / (ℓc + 2 * ℓs) < 1 := by
  have hℓs := h.ℓs_pos
  have hd : 0 < ℓc + 2 * ℓs := by positivity
  exact ⟨hC18 μ θ σ ℓs T ℓc q h hσ hℓc hq z t r hr, div_pos hℓc hd,
    (div_lt_one hd).mpr (by linarith)⟩

/-- Step 2 (main-v3.tex 930-932): "Substitution into Proposition
(generic_exponential_radius) gives the radius and the threshold `vT > 2ℓ_s`."
The proposition is about a curve `R(r) = R_∞ [1 − G(r)]`; step 0 says the
regret of the field is such a curve and step 1 gives its omission share, so
`G(r) = (1 − η₀e^{−2r/ℓ_c}) e^{−2r/(vT)}`; `R_∞ > 0` because `η_S(0) = η₀ ≠ 0`.
With `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`, `η₀(1 + vT/ℓ_c) = (ℓ_c + vT)/(ℓ_c + 2ℓ_s)`, so the
proposition's `r⋆` is `(ℓ_c/2)[log((ℓ_c + vT)/(ℓ_c + 2ℓ_s))]_+` and its
condition is `vT > 2ℓ_s`. -/
theorem s2_substitute (hC16 : C16.Statement) (hC17b : C17b.Statement) (hC18 : C18.Statement)
    (h : CanonicalField μ θ σ ℓs T) (hσ : σ ≠ 0) (hℓc : 0 < ℓc) (hq : 0 < q) {v : ℝ}
    (hv : 0 < v) (z t : ℝ) :
    (∀ r, 0 ≤ r → r ≠ canonRadius ℓc ℓs v T →
        lineR μ q θ ℓc (canonRadius ℓc ℓs v T) (canonRadius ℓc ℓs v T / v) z t
          < lineR μ q θ ℓc r (r / v) z t) ∧
      (0 < canonRadius ℓc ℓs v T ↔ 2 * ℓs < v * T) := by
  have hℓs := h.ℓs_pos
  have hT := h.T_pos
  have hd : 0 < ℓc + 2 * ℓs := by positivity
  obtain ⟨he0, hη0, hη1⟩ := s1_eta0 hC18 h hσ hℓc hq z t (le_refl (0 : ℝ))
  -- `R_∞ > 0`, because `η_S(0) = η₀ ≠ 0`
  have hRinf_nonneg : 0 ≤ lineRinf μ q θ ℓc z t :=
    mul_nonneg (by positivity) (variance_nonneg _ _)
  have hRinf_ne : lineRinf μ q θ ℓc z t ≠ 0 := by
    intro h0
    have hz : lineEtaS μ q θ ℓc 0 z t = 0 := by simp [lineEtaS, h0]
    rw [hz] at he0
    have : 0 < ℓc / (ℓc + 2 * ℓs) * exp (-2 * 0 / ℓc) := mul_pos hη0 (exp_pos _)
    linarith
  have hRinf_pos : 0 < lineRinf μ q θ ℓc z t := lt_of_le_of_ne hRinf_nonneg (Ne.symm hRinf_ne)
  -- the regret of the field is `R_∞ [1 − G(r)]` (step 0), with the lemma's curve (step 1)
  have hR : ∀ r, 0 ≤ r → lineR μ q θ ℓc r (r / v) z t = lineRinf μ q θ ℓc z t *
      (1 - gain (fun r : ℝ => ℓc / (ℓc + 2 * ℓs) * exp (-2 * r / ℓc)) (fun r : ℝ => r / v) T r) := by
    intro r hr
    have h0 := s0_field_regret hC17b h hℓc hq hv z t hRinf_ne hr
    have h1 := (s1_eta0 hC18 h hσ hℓc hq z t hr).1
    simp only [gain] at h0 ⊢
    rw [h0, h1]
  -- the proposition, with `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`
  have h16 := hC16 (ℓc / (ℓc + 2 * ℓs)) ℓc v T hη0 hη1 hℓc hv hT
  dsimp only at h16
  obtain ⟨hmax, hpos, -⟩ := h16
  have hsub : ℓc / (ℓc + 2 * ℓs) * (1 + v * T / ℓc) = (ℓc + v * T) / (ℓc + 2 * ℓs) := by
    field_simp
  have hrad : expRadius (ℓc / (ℓc + 2 * ℓs)) ℓc v T = canonRadius ℓc ℓs v T := by
    unfold expRadius canonRadius
    rw [hsub]
  rw [hrad] at hmax hpos
  rw [hsub, one_lt_div hd] at hpos
  have hrstar : 0 ≤ canonRadius ℓc ℓs v T :=
    mul_nonneg (by positivity) (le_max_right _ _)
  refine ⟨fun r hr hne => ?_, hpos.trans ⟨fun h => by linarith, fun h => by linarith⟩⟩
  rw [hR r hr, hR _ hrstar]
  have hG := hmax r hr hne
  exact mul_lt_mul_of_pos_left (by linarith) hRinf_pos

/-- Theorem (canonical_optimal_radius) for the field: step 2 is the statement. -/
theorem main (hC16 : C16.Statement) (hC17b : C17b.Statement) (hC18 : C18.Statement) :
    C19.Statement := by
  intro Ω _ μ _ θ σ ℓs T ℓc q v h hσ hℓc hq hv z t
  exact s2_substitute hC16 hC17b hC18 h hσ hℓc hq hv z t

end TinaV2.C19.A2
