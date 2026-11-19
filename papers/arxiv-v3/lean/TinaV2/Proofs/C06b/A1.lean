import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.NoInfo

/-! # C6.b, attempt A1: mirrors the supplement proof C6.b/p1

The paper states that the best no-information action is zero in centered
coordinates, and the trace formula Eq. (Rinf_general), without argument
(`main-v2.tex` 311-316). The proof mirrored here is not in the paper. It is the
supplement proof `C6.b/p1` in the ledger
(`python3 tools/ledger.py supplement C6.b`), written for the formalization
under disposition `C6.b/d1`. One lemma per step of that proof, in its order,
then `main`. -/

namespace TinaV2.C06b.A1

open MeasureTheory ProbabilityTheory Matrix

variable {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (supplied). "For a constant action `c`,
`E[(c − x⋆)ᵀQ(c − x⋆)] = cᵀQc − 2cᵀQ E[x⋆] + E[x⋆ᵀQx⋆] = cᵀQc + E[x⋆ᵀQx⋆]`,
since `E[x⋆] = K E[θ] = 0` in centered coordinates." -/
theorem s1_constant_cost (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (h2 : MemLp now 2 μ) (h0 : ∀ k, ∫ ω, now ω k ∂μ = 0) (u₀ : α → ℝ) :
    excessCost μ M.Q (M.target now) (fun _ => u₀) = 1 / 2 * quad M.Q u₀ + M.Rinf μ now := by
  have hQ : M.Q.IsHermitian := M.Q_posDef.isHermitian
  have hx : MemLp (M.target now) 2 μ := M.memLp_target h2
  -- `(c − x⋆)ᵀQ(c − x⋆) = cᵀQc − 2cᵀQx⋆ + x⋆ᵀQx⋆`, pointwise
  have hpt : ∀ ω, quad M.Q (u₀ - M.target now ω)
      = quad M.Q u₀ - 2 * (u₀ ⬝ᵥ (M.Q *ᵥ M.target now ω)) + quad M.Q (M.target now ω) := by
    intro ω
    simp only [quad, mulVec_sub, dotProduct_sub, sub_dotProduct]
    rw [dotProduct_mulVec_comm hQ u₀ (M.target now ω)]
    ring
  -- `E[x⋆] = K E[θ] = 0` in centered coordinates
  have hmean : (fun c => ∫ ω, M.target now ω c ∂μ) = 0 := by
    funext c
    have h := integral_const_dotProduct (μ := μ) (fun k => M.K c k) h2
    have hz : (fun k => ∫ ω, now ω k ∂μ) = 0 := funext h0
    rw [hz, dotProduct_zero] at h
    exact h
  -- so the cross term `cᵀQ E[x⋆]` vanishes
  have hcross : ∫ ω, u₀ ⬝ᵥ (M.Q *ᵥ M.target now ω) ∂μ = 0 := by
    simp_rw [dotProduct_mulVec]
    rw [integral_const_dotProduct _ hx, hmean, dotProduct_zero]
  have hIc : Integrable (fun ω => u₀ ⬝ᵥ (M.Q *ᵥ M.target now ω)) μ :=
    integrable_dotProduct_mulVec M.Q (memLp_const u₀) hx
  have hIq : Integrable (fun ω => quad M.Q (M.target now ω)) μ := integrable_quad M.Q hx
  unfold excessCost Model.Rinf
  simp_rw [hpt]
  have hI2 : Integrable (fun ω => 2 * (u₀ ⬝ᵥ (M.Q *ᵥ M.target now ω))) μ := hIc.const_mul 2
  have hI1 : Integrable
      (fun ω => quad M.Q u₀ - 2 * (u₀ ⬝ᵥ (M.Q *ᵥ M.target now ω))) μ :=
    (integrable_const _).sub hI2
  rw [integral_add hI1 hIq, integral_sub (integrable_const _) hI2, integral_const,
    integral_const_mul, hcross]
  simp only [probReal_univ, one_smul, mul_zero, sub_zero]
  ring

/-- Step 2 (supplied). "Since `Q ≻ 0`, `cᵀQc ≥ 0`, with equality at `c = 0`. So
no constant action costs less than `R_∞ = ½ E[x⋆ᵀQx⋆]`, and the zero action
costs exactly `R_∞`." -/
theorem s2_zero_best (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (h2 : MemLp now 2 μ) (h0 : ∀ k, ∫ ω, now ω k ∂μ = 0) :
    (∀ u₀ : α → ℝ, M.Rinf μ now ≤ excessCost μ M.Q (M.target now) (fun _ => u₀)) ∧
      excessCost μ M.Q (M.target now) (fun _ => 0) = M.Rinf μ now := by
  refine ⟨fun u₀ => ?_, ?_⟩
  · -- `cᵀQc ≥ 0` since `Q ≻ 0`
    rw [s1_constant_cost M μ now h2 h0 u₀]
    linarith [quad_nonneg M.Q_posDef u₀]
  · -- equality at `c = 0`
    rw [s1_constant_cost M μ now h2 h0 0]
    simp [quad]

/-- Step 3 (supplied). "`x⋆ᵀQx⋆ = θᵀKᵀQKθ = tr(KᵀQK θθᵀ)`. Taking expectations,
with `E[θθᵀ] = Σ_S` for the centered state, `R_∞ = ½ tr(KᵀQK Σ_S)`." -/
theorem s3_trace (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (now : Ω → κ → ℝ) (h2 : MemLp now 2 μ) (h0 : ∀ k, ∫ ω, now ω k ∂μ = 0) :
    M.Rinf μ now = 1 / 2 * Matrix.trace (M.Kᵀ * M.Q * M.K * covMatrix μ now) := by
  have hi : ∀ k, MemLp (fun ω => now ω k) 2 μ := memLp_pi_iff.1 h2
  -- `x⋆ᵀQx⋆ = θᵀKᵀQKθ`
  have hpt : ∀ ω, quad M.Q (M.target now ω) = quad (M.Kᵀ * M.Q * M.K) (now ω) := by
    intro ω
    simp only [quad, Model.target]
    rw [← mulVec_mulVec, ← mulVec_mulVec, dotProduct_mulVec (now ω), vecMul_transpose]
  -- `E[θθᵀ] = Σ_S` for the centered state
  have hcov : ∀ k l, ∫ ω, now ω k * now ω l ∂μ = covMatrix μ now l k := by
    intro k l
    simp only [covMatrix, of_apply]
    rw [covariance_comm, covariance_eq_sub (hi k) (hi l), h0 k, h0 l]
    simp
  -- taking expectations: `E[θᵀAθ] = Σ_{k,l} A_kl E[θ_k θ_l] = tr(A Σ_S)`
  unfold Model.Rinf
  simp_rw [hpt]
  rw [integral_quad_eq_sum_sum _ h2, trace_mul_eq_sum_sum]
  simp_rw [hcov]

/-- Eq. (Rinf_general) and the sentence before it. -/
theorem main : C06b.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ now _ h2 h0
  exact ⟨(s2_zero_best M μ now h2 h0).1, (s2_zero_best M μ now h2 h0).2,
    s3_trace M μ now h2 h0⟩

end TinaV2.C06b.A1
