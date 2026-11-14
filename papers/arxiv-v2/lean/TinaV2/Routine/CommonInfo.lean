import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection

/-! # Routine facts about a vector-valued conditional expectation (claim C3)

What the paragraph "Common-information optimality" of the appendix leaves
unsaid when it writes `m = E[x⋆ | Z]` for a random vector `x⋆` and conditions
`hᵀQ(x⋆ − m)` on `Z`:

* each coordinate of `E[x | 𝒢]` is `𝒢`-measurable;
* linearity of conditional expectation, coordinate by coordinate: every
  coordinate of `A (x − E[x | 𝒢])` has zero conditional expectation given `𝒢`;
* the expectation of a dot product is the sum of the expectations of the
  coordinate products.

That `E[x | 𝒢]` is square-integrable when `x` is, is Mathlib's `MemLp.condExp`.

Nothing here is a step of a paper proof. This file imports `Defs/` and the two
routine files above only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {κ α : Type} [Fintype κ] [Fintype α]

/-- Each coordinate of the vector conditional expectation `E[x | 𝒢]` is
`𝒢`-measurable. -/
theorem measurable_condExp_apply (μ : Measure Ω) (𝒢 : MeasurableSpace Ω)
    (x : Ω → α → ℝ) (c : α) : Measurable[𝒢] fun ω => (μ[x | 𝒢]) ω c :=
  (measurable_pi_apply c).comp stronglyMeasurable_condExp.measurable

omit [Fintype α] in
/-- Linearity of conditional expectation: every coordinate of
`A (x − E[x | 𝒢])` has zero conditional expectation given `𝒢`, because
`E[x − E[x | 𝒢] | 𝒢] = E[x | 𝒢] − E[x | 𝒢] = 0`. -/
theorem condExp_mulVec_sub_condExp_apply {μ : Measure Ω} [IsFiniteMeasure μ]
    {𝒢 : MeasurableSpace Ω} (h𝒢 : 𝒢 ≤ mΩ) {x : Ω → κ → ℝ} (hx : Integrable x μ)
    (A : Matrix α κ ℝ) (c : α) :
    μ[fun ω => (A *ᵥ (x ω - (μ[x | 𝒢]) ω)) c | 𝒢] =ᵐ[μ] 0 := by
  have hint : Integrable (fun ω => x ω - (μ[x | 𝒢]) ω) μ := hx.sub integrable_condExp
  -- `E[x − E[x | 𝒢] | 𝒢] = 0`
  have h0 : μ[fun ω => x ω - (μ[x | 𝒢]) ω | 𝒢] =ᵐ[μ] 0 := by
    have h1 : μ[x - μ[x | 𝒢] | 𝒢] =ᵐ[μ] μ[x | 𝒢] - μ[μ[x | 𝒢] | 𝒢] :=
      condExp_sub hx integrable_condExp 𝒢
    have h2 : μ[μ[x | 𝒢] | 𝒢] = μ[x | 𝒢] :=
      condExp_of_stronglyMeasurable h𝒢 stronglyMeasurable_condExp integrable_condExp
    rw [h2, sub_self] at h1
    exact h1
  -- the coordinate of `A ·` is a continuous linear map, and passes through
  let L : (κ → ℝ) →L[ℝ] ℝ :=
    (ContinuousLinearMap.proj c).comp (LinearMap.toContinuousLinearMap (Matrix.mulVecLin A))
  have hL := L.comp_condExp_comm hint (m := 𝒢)
  refine hL.symm.trans ?_
  filter_upwards [h0] with ω hω
  simp [hω]

/-- `E[uᵀv] = Σ_c E[u_c v_c]` for square-integrable `u`, `v`. -/
theorem integral_dotProduct_eq_sum {μ : Measure Ω} {u v : Ω → α → ℝ} (hu : MemLp u 2 μ)
    (hv : MemLp v 2 μ) : ∫ ω, u ω ⬝ᵥ v ω ∂μ = ∑ c, ∫ ω, u ω c * v ω c ∂μ := by
  simp only [dotProduct]
  exact integral_finsetSum _ fun c _ => (memLp_pi_iff.1 hu c).integrable_mul (memLp_pi_iff.1 hv c)

end TinaV2
