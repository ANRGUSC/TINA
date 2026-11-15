import TinaV2.Statements

/-! # C19, attempt A1: mirrors paper proof C19/p1

Theorem (canonical_optimal_radius), main-v2.tex 883-920, in the algebraic form
of `C19.AlgebraicStatement` (formalization C19/f1, superseded by the field
form proved in attempt A2): the radius formula, its uniqueness and the threshold. The
comparative statics in the rest of the paper's proof are claim C19.b. -/

namespace TinaV2.C19.A1
open Real Set

variable (ℓc ℓs v T : ℝ)

local notation "G" =>
  gain (fun r : ℝ => ℓc / (ℓc + 2 * ℓs) * exp (-2 * r / ℓc)) (fun r : ℝ => r / v) T

/-- Step 1 (main-v2.tex 910-911): Lemma (canonical_eta_S) gives
`η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`. In the algebraic form the statement already fixes this
`η₀`, so the lemma (C18, tier D) is not a hypothesis here. The step records only
what the next step needs of that value: it is an admissible prefactor for
Proposition (generic_exponential_radius), `0 < η₀ < 1`. -/
theorem s1_eta0 (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) :
    0 < ℓc / (ℓc + 2 * ℓs) ∧ ℓc / (ℓc + 2 * ℓs) < 1 := by
  have hd : 0 < ℓc + 2 * ℓs := by positivity
  exact ⟨div_pos hℓc hd, (div_lt_one hd).mpr (by linarith)⟩

/-- Step 2 (main-v2.tex 911-913): substitution into Proposition
(generic_exponential_radius) gives the radius and the threshold `vT > 2ℓ_s`.
With `η₀ = ℓ_c/(ℓ_c + 2ℓ_s)`, `η₀(1 + vT/ℓ_c) = (ℓ_c + vT)/(ℓ_c + 2ℓ_s)`, so the
proposition's `r⋆` is `(ℓ_c/2)[log((ℓ_c + vT)/(ℓ_c + 2ℓ_s))]_+` and its
condition `η₀(1 + vT/ℓ_c) > 1` is `vT > 2ℓ_s`. The paper's proposition is stated
"under Theorem (spatiotemporal_composition)" (C17.b for this model); the
algebraic form does not mention the field model, so that is not a hypothesis. -/
theorem s2_substitute (hC16 : C16.Statement)
    (hℓc : 0 < ℓc) (hℓs : 0 < ℓs) (hv : 0 < v) (hT : 0 < T) :
    (∀ r, 0 ≤ r → r ≠ canonRadius ℓc ℓs v T → G r < G (canonRadius ℓc ℓs v T)) ∧
      (0 < canonRadius ℓc ℓs v T ↔ 2 * ℓs < v * T) := by
  obtain ⟨hη0, hη1⟩ := s1_eta0 ℓc ℓs hℓc hℓs
  have h := hC16 (ℓc / (ℓc + 2 * ℓs)) ℓc v T hη0 hη1 hℓc hv hT
  dsimp only at h
  obtain ⟨hmax, hpos, -⟩ := h
  have hd : 0 < ℓc + 2 * ℓs := by positivity
  have hsub : ℓc / (ℓc + 2 * ℓs) * (1 + v * T / ℓc) = (ℓc + v * T) / (ℓc + 2 * ℓs) := by
    field_simp
  have hrad : expRadius (ℓc / (ℓc + 2 * ℓs)) ℓc v T = canonRadius ℓc ℓs v T := by
    unfold expRadius canonRadius
    rw [hsub]
  rw [hrad] at hmax hpos
  rw [hsub, one_lt_div hd] at hpos
  refine ⟨hmax, hpos.trans ⟨fun h => by linarith, fun h => by linarith⟩⟩

/-- Theorem (canonical_optimal_radius), algebraic form: step 2 is the
statement. -/
theorem main (hC16 : C16.Statement) : C19.AlgebraicStatement := by
  intro ℓc ℓs v T hℓc hℓs hv hT
  exact s2_substitute ℓc ℓs v T hC16 hℓc hℓs hv hT

end TinaV2.C19.A1
