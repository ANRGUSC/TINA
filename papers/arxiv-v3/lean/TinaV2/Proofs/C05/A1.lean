import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection

/-! # C5, attempt A1: mirrors the supplement proof C5/p1

The paper states the identity without proof: "Completing the square in
(quadratic_cost) gives (complete_square)" (`technical-appendices-v2.tex`
58-66), and calls `x⋆` "the unique optimal joint action" (44-45). The proof
mirrored here is not in the paper. It is the supplement proof `C5/p1` in the
ledger (`python3 tools/ledger.py supplement C5`), written for the
formalization under disposition `C5/d1`. One lemma per step of that proof,
in its order, then `main`. -/

namespace TinaV2.C05.A1

open Matrix

variable {α : Type} [Fintype α] [DecidableEq α]

/-- Step 1 (supplied). "Since `x⋆ = Q⁻¹b` and `Q` is invertible, `Qx⋆ = b`." -/
theorem s1_first_order (Q : Matrix α α ℝ) (b : α → ℝ) (hQ : Q.PosDef) :
    Q *ᵥ (Q⁻¹ *ᵥ b) = b :=
  mulVec_inv_mulVec hQ b

/-- Step 2 (supplied). "Write `x = x⋆ + h`. Because `Q` is symmetric,
`f(x⋆ + h) = f(x⋆) + hᵀ(Qx⋆ − b) + ½ hᵀQh`, and the middle term vanishes by
step 1. With `h = x − x⋆` this is Eq. (complete_square)." -/
theorem s2_complete_square (Q : Matrix α α ℝ) (b : α → ℝ) (c : ℝ) (hQ : Q.PosDef) (x : α → ℝ) :
    quadCost Q b c x - quadCost Q b c (Q⁻¹ *ᵥ b) = 1 / 2 * quad Q (x - Q⁻¹ *ᵥ b) := by
  have h := quadCost_add hQ.isHermitian b c (Q⁻¹ *ᵥ b) (x - Q⁻¹ *ᵥ b)
  rw [add_sub_cancel, s1_first_order Q b hQ, sub_self, dotProduct_zero, zero_add] at h
  exact h

/-- Step 3 (supplied). "If `x ≠ x⋆` then `(x − x⋆)ᵀQ(x − x⋆) > 0` because `Q` is
positive definite, so `f(x) > f(x⋆)` by step 2." -/
theorem s3_unique_minimizer (Q : Matrix α α ℝ) (b : α → ℝ) (c : ℝ) (hQ : Q.PosDef) (x : α → ℝ)
    (hx : x ≠ Q⁻¹ *ᵥ b) : quadCost Q b c (Q⁻¹ *ᵥ b) < quadCost Q b c x := by
  have hpos : 0 < quad Q (x - Q⁻¹ *ᵥ b) := by
    simpa [quad] using hQ.dotProduct_mulVec_pos (sub_ne_zero.2 hx)
  have h := s2_complete_square Q b c hQ x
  linarith

theorem main : C05.Statement := by
  intro α _ _ Q b c hQ
  exact ⟨fun x => s2_complete_square Q b c hQ x, fun x hx => s3_unique_minimizer Q b c hQ x hx⟩

end TinaV2.C05.A1
