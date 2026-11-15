import TinaV2.Statements
import TinaV2.Routine.Regret

/-! # C7.b, attempt A1: mirrors the supplement proof C7.b/p1

The paper states the normalized law as "equivalently" inside Theorem
(spatiotemporal_composition) (`main-v2.tex` 391-396); its proof ends with
"normalization is valid when `R_∞ > 0`" (442) and gives no further argument.
The proof mirrored here is not in the paper. It is the supplement proof
`C7.b/p1` in the ledger (`python3 tools/ledger.py supplement C7.b`), written
for the formalization under disposition `C7.b/d1`. One lemma per step of that
proof, in its order, then `main`. The composition theorem C7 enters as the
hypothesis `hC7 : C07.Statement`. -/

namespace TinaV2.C07b.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (supplied). "Divide Eq. (regret_composition_unnormalized) by
`R_∞ > 0`: `R(𝒜_{r,τ})/R_∞ = (1 − a²) + a² R(𝒜_{r,0})/R_∞`, and
`R(𝒜_{r,0})/R_∞ = η_S(r)` by Eq. (eta_S_definition)." -/
theorem s1_divide (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (r : ℕ∞)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t)) :
    M.R μ r (θ (t - τ)) (θ t) / M.Rinf μ (θ t)
      = (1 - exp (-τ / T) ^ 2) + exp (-τ / T) ^ 2 * M.etaS μ r (θ t) := by
  rw [hC7 M μ θ T t τ r hA, Model.etaS]
  field_simp

/-- Step 2 (supplied). "Subtract from one:
`1 − R(𝒜_{r,τ})/R_∞ = a² [1 − η_S(r)]`, and `a² = e^{−2τ/T}`." -/
theorem s2_subtract (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (r : ℕ∞)
    (hA : TemporalAssumption μ θ T t τ) (hR : 0 < M.Rinf μ (θ t)) :
    1 - M.R μ r (θ (t - τ)) (θ t) / M.Rinf μ (θ t)
      = exp (-2 * τ / T) * (1 - M.etaS μ r (θ t)) := by
  have hsq : exp (-τ / T) ^ 2 = exp (-2 * τ / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  rw [s1_divide hC7 M μ θ T t τ r hA hR, hsq]
  ring

/-- Eq. (regret_composition_normalized). -/
theorem main (hC7 : C07.Statement) : C07b.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ r hA hR
  exact s2_subtract hC7 M μ θ T t τ r hA hR

end TinaV2.C07b.A1
