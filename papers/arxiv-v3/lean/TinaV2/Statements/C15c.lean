import TinaV2.Defs

/-! # C15.c: Comparative statics in T and latency scale

Paper: main-v3.tex, paragraph after Proposition (marginal_balance). -/

namespace TinaV2.C15c

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

/-- Delay `τ(r) = α τ₀(r)`, omission curve fixed, single crossing holding
before and after the change. A larger `T` moves the maximizer of `G` weakly
outward; a larger `α` moves it weakly inward. -/
def Statement : Prop :=
  ∀ (η τ₀ : ℝ → ℝ) (D : ℝ), SmoothCurves η τ₀ D →
    let τ : ℝ → ℝ → ℝ := fun α r => α * τ₀ r
    let single : ℝ → ℝ → Prop := fun α T => StrictAntiOn (balanceGap η (τ α) T D) (Icc 0 D)
    (∀ α T T' : ℝ, 0 < α → 0 < T → T ≤ T' → single α T → single α T' →
      ∀ r ∈ Icc 0 D, ∀ r' ∈ Icc 0 D,
        IsMaxOn (gain η (τ α) T) (Icc 0 D) r → IsMaxOn (gain η (τ α) T') (Icc 0 D) r' →
        r ≤ r') ∧
    (∀ T α α' : ℝ, 0 < T → 0 < α → α ≤ α' → single α T → single α' T →
      ∀ r ∈ Icc 0 D, ∀ r' ∈ Icc 0 D,
        IsMaxOn (gain η (τ α) T) (Icc 0 D) r → IsMaxOn (gain η (τ α') T) (Icc 0 D) r' →
        r' ≤ r)

end TinaV2.C15c
