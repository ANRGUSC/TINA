import TinaV2.Statements
import TinaV2.Routine.Projection
import TinaV2.Routine.RadiusInfo

/-! # C1.c, attempt A1: mirrors the supplement proof C1.c/p1

The paper states information inclusion, Eq. (info_inclusion), without argument
(`technical-appendices-v2.tex` 111-119). The proof mirrored here is not in the
paper. It is the supplement proof `C1.c/p1` in the ledger
(`python3 tools/ledger.py supplement C1.c`), written for the formalization
under disposition `C1.c/d1`. One lemma per step of that proof, in its order,
then `main`. -/

namespace TinaV2.C01c.A1

open MeasureTheory Matrix

variable {ι α Ω : Type} [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (supplied). "If `u ∈ 𝒮(𝒜)` then each `u_i` is `𝒢_i`-measurable, hence
`𝒢'_i`-measurable because `𝒢_i ⊆ 𝒢'_i`; so `𝒮(𝒜) ⊆ 𝒮(𝒜')`." -/
theorem s1_policy_inclusion (μ : Measure Ω) (actor : α → ι) (𝒢 𝒢' : ι → MeasurableSpace Ω)
    (h : ∀ i, 𝒢 i ≤ 𝒢' i) (u : Ω → α → ℝ) (hu : SigmaAdmissible μ actor 𝒢 u) :
    SigmaAdmissible μ actor 𝒢' u :=
  ⟨fun c => (hu.1 c).mono (h (actor c)) le_rfl, hu.2⟩

/-- Step 2 (supplied). "`R(𝒜')` is the infimum of the same expected excess cost
over the larger set `𝒮(𝒜')`, and that cost is bounded below by zero because
`Q ≻ 0`; so `R(𝒜') ≤ R(𝒜)`." -/
theorem s2_regret_le (μ : Measure Ω) (Q : Matrix α α ℝ) (hQ : Q.PosDef) (actor : α → ι)
    (xstar : Ω → α → ℝ) (𝒢 𝒢' : ι → MeasurableSpace Ω) (h : ∀ i, 𝒢 i ≤ 𝒢' i) :
    sigmaRegret μ Q actor xstar 𝒢' ≤ sigmaRegret μ Q actor xstar 𝒢 :=
  le_sigmaRegret xstar fun u hu =>
    sigmaRegret_le hQ xstar (s1_policy_inclusion μ actor 𝒢 𝒢' h u hu)

/-- Eq. (info_inclusion) together with the Doob–Dynkin bridge `M.R = sigmaRegret`. -/
theorem main : C01c.Statement := by
  refine ⟨?_, fun M μ r snap now => M.R_eq_sigmaRegret μ r snap now⟩
  intro ι α Ω _ m0 μ _ Q actor xstar 𝒢 𝒢' hQ _ h _
  exact ⟨s1_policy_inclusion μ actor 𝒢 𝒢' h, s2_regret_le μ Q hQ actor xstar 𝒢 𝒢' h⟩

end TinaV2.C01c.A1
