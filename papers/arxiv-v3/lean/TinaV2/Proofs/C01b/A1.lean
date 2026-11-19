import TinaV2.Statements
import TinaV2.Routine.Projection

/-! # C1.b, attempt A1: mirrors the supplement proof C1.b/p1

The paper states the two sentences after the proof of Lemma (radner_projection)
without argument (`technical-appendices-v2.tex` 216-218). The proof mirrored
here is not in the paper. It is the supplement proof `C1.b/p1` in the ledger
(`python3 tools/ledger.py supplement C1.b`), written for the formalization
under disposition `C1.b/d1`. One lemma per step of that proof, in its order,
then `main`. The projection lemma C1 enters as the hypothesis
`hC1 : C01.Statement`. -/

namespace TinaV2.C01b.A1

open MeasureTheory Matrix

variable {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω]

/-- Step 1 (supplied). "`u⋆ = Π_{𝒮(𝒜)} x⋆` is the orthogonal projection for
`⟨·,·⟩_Q` (Eq. (optimal_projection)), so by definition `u⋆ ∈ 𝒮(𝒜)` and the
error `x⋆ − u⋆` is `Q`-orthogonal to every member of `𝒮(𝒜)`." -/
theorem s1_orthogonal (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (xstar p : Ω → α → ℝ)
    (hp : IsQProjection μ Q (policySpace μ actor 𝒢) xstar p) :
    p ∈ policySpace μ actor 𝒢 ∧
      ∀ h ∈ policySpace μ actor 𝒢, qInner μ Q h (xstar - p) = 0 := by
  -- Eq. (optimal_projection): `IsQProjection` is exactly these two properties
  exact ⟨hp.1, hp.2⟩

/-- Step 2 (supplied). "Taking `h = u⋆` in step 1 gives `⟨u⋆, x⋆ − u⋆⟩_Q = 0`.
Expanding `‖x⋆‖_Q² = ‖u⋆ + (x⋆ − u⋆)‖_Q²` then gives
`‖x⋆‖_Q² = ‖u⋆‖_Q² + ‖x⋆ − u⋆‖_Q²` (Pythagoras)." -/
theorem s2_pythagoras (μ : Measure Ω) (Q : Matrix α α ℝ) (hQ : Q.PosDef) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (xstar p : Ω → α → ℝ) (hx : MemLp xstar 2 μ)
    (hp : IsQProjection μ Q (policySpace μ actor 𝒢) xstar p) :
    qNormSq μ Q xstar = qNormSq μ Q p + qNormSq μ Q (xstar - p) := by
  -- step 1: `u⋆ ∈ 𝒮(𝒜)`, and `x⋆ − u⋆` is `Q`-orthogonal to `𝒮(𝒜)`
  obtain ⟨hpS, horth⟩ := s1_orthogonal μ Q actor 𝒢 xstar p hp
  -- `u⋆ ∈ 𝒮(𝒜) ⊆ ℋ`
  have hpL : MemLp p 2 μ := (mem_policySpace.1 hpS).2
  -- taking `h = u⋆`: `⟨u⋆, x⋆ − u⋆⟩_Q = 0`
  have hcross : qInner μ Q p (xstar - p) = 0 := horth p hpS
  -- `x⋆ = u⋆ + (x⋆ − u⋆)`
  have hsplit : xstar = p + (xstar - p) := (add_sub_cancel p xstar).symm
  -- expand `‖u⋆ + (x⋆ − u⋆)‖_Q²`
  have hexp := qNormSq_add (μ := μ) hQ.isHermitian hpL (hx.sub hpL)
  rw [← hsplit, hcross] at hexp
  linarith

/-- Step 3 (supplied). "By Lemma (radner_projection), applied with `b = Q x⋆`
and `c = 0`, `R(𝒜) = ½ ‖x⋆ − u⋆‖_Q²` (Eq. (projection_regret)). With step 2,
`2 R(𝒜) = ‖x⋆‖_Q² − ‖u⋆‖_Q²`." -/
theorem s3_regret (hC1 : C01.Statement) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Q : Matrix α α ℝ) (hQ : Q.PosDef) (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω)
    (h𝒢 : ∀ i, 𝒢 i ≤ m0) (xstar p : Ω → α → ℝ) (hx : MemLp xstar 2 μ)
    (hp : IsQProjection μ Q (policySpace μ actor 𝒢) xstar p) :
    2 * sigmaRegret μ Q actor xstar 𝒢 = qNormSq μ Q xstar - qNormSq μ Q p := by
  classical
  -- `Q` is positive definite, hence invertible: `Q⁻¹ (Q x⋆) = x⋆`
  have hinv : (fun ω => Q⁻¹ *ᵥ (Q *ᵥ xstar ω)) = xstar := by
    funext ω
    rw [mulVec_mulVec, nonsing_inv_mul Q (isUnit_iff_ne_zero.2 hQ.det_pos.ne'), one_mulVec]
  -- Lemma (radner_projection) with `b = Q x⋆` and `c = 0`
  have h := hC1 μ Q actor 𝒢 (fun ω => Q *ᵥ xstar ω) (fun _ => 0) hQ h𝒢 (memLp_mulVec Q hx)
    (integrable_zero Ω ℝ μ)
  simp only [hinv] at h
  -- Eq. (projection_regret): `R(𝒜) = ½ ‖x⋆ − u⋆‖_Q²`
  have hreg : sigmaRegret μ Q actor xstar 𝒢 = 1 / 2 * qNormSq μ Q (xstar - p) :=
    (h.2.2 p hp).2.2
  -- step 2: `‖x⋆‖_Q² = ‖u⋆‖_Q² + ‖x⋆ − u⋆‖_Q²`
  have hpyth := s2_pythagoras μ Q hQ actor 𝒢 xstar p hx hp
  rw [hreg, hpyth]
  ring

/-- The two sentences after the proof of Lemma (radner_projection). -/
theorem main (hC1 : C01.Statement) : C01b.Statement := by
  intro ι α Ω _ m0 μ _ Q actor 𝒢 xstar hQ h𝒢 hx S p hp
  exact ⟨(s1_orthogonal μ Q actor 𝒢 xstar p hp).2,
    s3_regret hC1 μ Q hQ actor 𝒢 h𝒢 xstar p hx hp⟩

end TinaV2.C01b.A1
