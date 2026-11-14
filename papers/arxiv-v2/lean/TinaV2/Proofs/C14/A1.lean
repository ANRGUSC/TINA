import TinaV2.Statements

/-! # C14, attempt A1: mirrors paper proof C14/p1

Paper: `main-v2.tex` lines 692-694 (the radius objective), 698-702 (the
one-more-hop criterion, Eq. (discrete_radius_improvement)) and 711-717 (the
loss decomposition, Eq. (R_decomposition)). The composition theorem C7 enters
as the hypothesis `hC7 : C07.Statement`.

Notation: `R(r) = R(𝒜_{r,τ(r)})` is `M.R μ r (θ (t - τ r)) (θ t)`, and `G` is
`gain (fun r => M.etaS μ r (θ t)) τ T`. -/

namespace TinaV2.C14.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (main-v2.tex 692-694). "Writing `R(r) = R(𝒜_{r,τ(r)})`, Theorem
(spatiotemporal_composition) gives `R(r) = R_∞ [1 − G(r)]`." -/
theorem s1_objective (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ) (τ : ℕ∞ → ℝ)
    (hA : ∀ r, TemporalAssumption μ θ T t (τ r)) (hR : 0 < M.Rinf μ (θ t)) (r : ℕ∞) :
    M.R μ r (θ (t - τ r)) (θ t)
      = M.Rinf μ (θ t) * (1 - gain (fun r => M.etaS μ r (θ t)) τ T r) := by
  have hsq : exp (-τ r / T) ^ 2 = exp (-2 * τ r / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  have hη : M.R μ r (θ t) (θ t) = M.etaS μ r (θ t) * M.Rinf μ (θ t) := by
    rw [Model.etaS, div_mul_cancel₀ _ hR.ne']
  rw [hC7 M μ θ T t (τ r) r (hA r), hsq, hη, gain]
  ring

/-- Step 2 (main-v2.tex 698-702). "On a finite graph, one more hop improves
performance exactly when `G(r+1) > G(r)`" (Eq. (discrete_radius_improvement)). -/
theorem s2_one_more_hop (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ) (τ : ℕ∞ → ℝ)
    (hA : ∀ r, TemporalAssumption μ θ T t (τ r)) (hR : 0 < M.Rinf μ (θ t)) (r : ℕ∞) :
    M.R μ (r + 1) (θ (t - τ (r + 1))) (θ t) < M.R μ r (θ (t - τ r)) (θ t)
      ↔ gain (fun r => M.etaS μ r (θ t)) τ T r
          < gain (fun r => M.etaS μ r (θ t)) τ T (r + 1) := by
  rw [s1_objective hC7 M μ θ T t τ hA hR r, s1_objective hC7 M μ θ T t τ hA hR (r + 1),
    mul_lt_mul_iff_right₀ hR]
  constructor <;> intro h <;> linarith

/-- Step 3 (main-v2.tex 711-717). "The loss separates into the two components":
`R(r)/R_∞ = (1 − e^{−2τ(r)/T}) + e^{−2τ(r)/T} η_S(r)` (Eq. (R_decomposition)). -/
theorem s3_decomposition (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ) (τ : ℕ∞ → ℝ)
    (hA : ∀ r, TemporalAssumption μ θ T t (τ r)) (hR : 0 < M.Rinf μ (θ t)) (r : ℕ∞) :
    M.R μ r (θ (t - τ r)) (θ t) / M.Rinf μ (θ t)
      = (1 - exp (-2 * τ r / T)) + exp (-2 * τ r / T) * M.etaS μ r (θ t) := by
  rw [s1_objective hC7 M μ θ T t τ hA hR r, mul_div_cancel_left₀ _ hR.ne', gain]
  ring

/-- The radius objective, the one-more-hop criterion and the decomposition. -/
theorem main (hC7 : C07.Statement) : C14.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA hR
  exact ⟨s1_objective hC7 M μ θ T t τ hA hR, s2_one_more_hop hC7 M μ θ T t τ hA hR,
    s3_decomposition hC7 M μ θ T t τ hA hR⟩

end TinaV2.C14.A1
