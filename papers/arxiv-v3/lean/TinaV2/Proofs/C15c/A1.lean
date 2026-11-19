import TinaV2.Statements

/-! # C15.c, attempt A1: mirrors the supplement proof C15.c/p1

The paper states the comparative statics in `T` and in the latency scale
without argument (`main-v3.tex` 761-765). The proof mirrored here is not in
the paper. It is the supplement proof `C15.c/p1` in the ledger
(`python3 tools/ledger.py supplement C15.c`), written for the formalization
under disposition `C15.c/d1`. One lemma per step of that proof, in its order,
then `main`. The single-crossing remark C15.b enters as the hypothesis
`hC15b : C15b.Statement`. Throughout, `Δ` is the balance gap: the left side of
Eq. (marginal_balance_condition) minus its right side, with one-sided
derivatives at `0` and `D`. -/

namespace TinaV2.C15c.A1

open Real Set

/-- Step 1 (supplied). "Let `α > 0` and `τ = ατ₀`. Then `τ` is continuously
differentiable on `[0, D]` with `τ' = ατ₀' ≥ 0`, so the pair `(η_S, τ)`
satisfies the hypotheses of Proposition (marginal_balance); and the difference
between the left and right sides of Eq. (marginal_balance_condition) is
`Δ_{α,T}(r) = d/dr log[1 − η_S(r)] − 2ατ₀'(r)/T`." -/
theorem s1_scaled_delay (η τ₀ : ℝ → ℝ) (D α : ℝ) (hc : SmoothCurves η τ₀ D) (hα : 0 < α) :
    SmoothCurves η (fun r => α * τ₀ r) D ∧
    ∀ T, ∀ r ∈ Icc 0 D, balanceGap η (fun r => α * τ₀ r) T D r
      = derivWithin (fun x => log (1 - η x)) (Icc 0 D) r
        - 2 * (α * derivWithin τ₀ (Icc 0 D) r) / T := by
  have hderiv : ∀ r ∈ Icc 0 D,
      derivWithin (fun r => α * τ₀ r) (Icc 0 D) r = α * derivWithin τ₀ (Icc 0 D) r :=
    fun r hr => derivWithin_const_mul α (hc.τ_contDiffOn.differentiableOn one_ne_zero r hr)
  refine ⟨⟨hc.D_pos, contDiffOn_const.mul hc.τ_contDiffOn, hc.η_contDiffOn, fun r hr => ?_,
    hc.η_deriv_nonpos, hc.η_range⟩, fun T r hr => ?_⟩
  · rw [hderiv r hr]
    exact mul_nonneg hα.le (hc.τ_deriv_nonneg r hr)
  · rw [balanceGap, hderiv r hr]

/-- Step 2 (supplied). "Since `τ₀' ≥ 0` on `[0, D]`, the formula of step 1
shows: if `0 < T ≤ T'`, then `Δ_{α,T} ≤ Δ_{α,T'}` on `[0, D]`; and if
`0 < α ≤ α'` and `T > 0`, then `Δ_{α',T} ≤ Δ_{α,T}` on `[0, D]`." -/
theorem s2_gap_order (η τ₀ : ℝ → ℝ) (D : ℝ) (hc : SmoothCurves η τ₀ D) :
    (∀ α T T' : ℝ, 0 < α → 0 < T → T ≤ T' → ∀ r ∈ Icc 0 D,
      balanceGap η (fun r => α * τ₀ r) T D r ≤ balanceGap η (fun r => α * τ₀ r) T' D r) ∧
    (∀ T α α' : ℝ, 0 < T → 0 < α → α ≤ α' → ∀ r ∈ Icc 0 D,
      balanceGap η (fun r => α' * τ₀ r) T D r ≤ balanceGap η (fun r => α * τ₀ r) T D r) := by
  constructor
  · intro α T T' hα hT hTT' r hr
    have hd := hc.τ_deriv_nonneg r hr
    rw [(s1_scaled_delay η τ₀ D α hc hα).2 T r hr, (s1_scaled_delay η τ₀ D α hc hα).2 T' r hr]
    gcongr
  · intro T α α' hT hα hαα' r hr
    have hd := hc.τ_deriv_nonneg r hr
    rw [(s1_scaled_delay η τ₀ D α' hc (hα.trans_le hαα')).2 T r hr,
      (s1_scaled_delay η τ₀ D α hc hα).2 T r hr]
    gcongr

/-- Step 3 (supplied). "Let `(η_S, τ)` satisfy the hypotheses of Proposition
(marginal_balance), let its difference `Δ` be strictly decreasing on `[0, D]`,
and let `r` maximize `G` on `[0, D]`. By the single-crossing statement, the
radius it names is strictly better than every other radius, so `r` is that
radius: `0` if `Δ(0) ≤ 0`, `D` if `Δ(D) ≥ 0`, and otherwise the zero of `Δ` in
`(0, D)`. Hence if `r > 0` then `Δ(r) ≥ 0` (the first case is excluded, and
`Δ(r)` is `Δ(D) ≥ 0` or `0`), and if `r < D` then `Δ(r) ≤ 0` (the second case
is excluded, and `Δ(r)` is `Δ(0) ≤ 0` or `0`)." -/
theorem s3_gap_sign_at_optimum (hC15b : C15b.Statement) (η τ : ℝ → ℝ) (T D : ℝ) (hT : 0 < T)
    (hc : SmoothCurves η τ D) (hΔ : StrictAntiOn (balanceGap η τ T D) (Icc 0 D)) (r : ℝ)
    (hr : r ∈ Icc 0 D) (hmax : IsMaxOn (gain η τ T) (Icc 0 D) r) :
    (0 < r → 0 ≤ balanceGap η τ T D r) ∧ (r < D → balanceGap η τ T D r ≤ 0) := by
  obtain ⟨h0, hD, hint⟩ := hC15b η τ T D hT hc hΔ
  have huniq : ∀ s ∈ Icc 0 D,
      (∀ x ∈ Icc 0 D, x ≠ s → gain η τ T x < gain η τ T s) → r = s := by
    intro s hs hstrict
    by_contra hne
    exact absurd (hstrict r hr hne) (not_lt.mpr (isMaxOn_iff.mp hmax s hs))
  have h0mem : (0 : ℝ) ∈ Icc 0 D := left_mem_Icc.mpr hc.D_pos.le
  have hDmem : D ∈ Icc 0 D := right_mem_Icc.mpr hc.D_pos.le
  constructor
  · intro hrpos
    rcases le_or_gt (balanceGap η τ T D 0) 0 with h0le | h0pos
    · exact absurd (huniq 0 h0mem (h0 h0le)) hrpos.ne'
    · rcases le_or_gt 0 (balanceGap η τ T D D) with hDge | hDlt
      · rw [huniq D hDmem (hD hDge)]
        exact hDge
      · obtain ⟨r₀, hr₀, hz, -, hstrict⟩ := hint h0pos hDlt
        rw [huniq r₀ (Ioo_subset_Icc_self hr₀) hstrict, hz]
  · intro hrD
    rcases le_or_gt 0 (balanceGap η τ T D D) with hDge | hDlt
    · exact absurd (huniq D hDmem (hD hDge)) hrD.ne
    · rcases le_or_gt (balanceGap η τ T D 0) 0 with h0le | h0pos
      · rw [huniq 0 h0mem (h0 h0le)]
        exact h0le
      · obtain ⟨r₀, hr₀, hz, -, hstrict⟩ := hint h0pos hDlt
        rw [huniq r₀ (Ioo_subset_Icc_self hr₀) hstrict, hz]

/-- Step 4 (supplied). "Larger `T`. Let `α > 0` and `0 < T ≤ T'`, with
`Δ_{α,T}` and `Δ_{α,T'}` strictly decreasing on `[0, D]`, and let `r` and `r'`
maximize `G` for `T` and for `T'`. Suppose `r' < r`. Then `r' < D`, so
`Δ_{α,T'}(r') ≤ 0` by step 3; and `r > 0`, so `Δ_{α,T}(r) ≥ 0` by step 3.
Since `Δ_{α,T}` is strictly decreasing, `Δ_{α,T}(r') > Δ_{α,T}(r) ≥ 0`, and by
step 2 `Δ_{α,T'}(r') ≥ Δ_{α,T}(r') > 0`, a contradiction. Hence `r ≤ r'`." -/
theorem s4_larger_T (hC15b : C15b.Statement) (η τ₀ : ℝ → ℝ) (D α T T' : ℝ)
    (hc : SmoothCurves η τ₀ D) (hα : 0 < α) (hT : 0 < T) (hTT' : T ≤ T')
    (hs : StrictAntiOn (balanceGap η (fun r => α * τ₀ r) T D) (Icc 0 D))
    (hs' : StrictAntiOn (balanceGap η (fun r => α * τ₀ r) T' D) (Icc 0 D))
    (r : ℝ) (hr : r ∈ Icc 0 D) (r' : ℝ) (hr' : r' ∈ Icc 0 D)
    (hmax : IsMaxOn (gain η (fun r => α * τ₀ r) T) (Icc 0 D) r)
    (hmax' : IsMaxOn (gain η (fun r => α * τ₀ r) T') (Icc 0 D) r') : r ≤ r' := by
  have hcα := (s1_scaled_delay η τ₀ D α hc hα).1
  by_contra hlt
  rw [not_le] at hlt
  have h1 := (s3_gap_sign_at_optimum hC15b η _ T' D (hT.trans_le hTT') hcα hs' r' hr' hmax').2
    (hlt.trans_le hr.2)
  have h2 := (s3_gap_sign_at_optimum hC15b η _ T D hT hcα hs r hr hmax).1 (hr'.1.trans_lt hlt)
  have h3 := hs hr' hr hlt
  have h4 := (s2_gap_order η τ₀ D hc).1 α T T' hα hT hTT' r' hr'
  linarith

/-- Step 5 (supplied). "Larger latency scale. Let `T > 0` and `0 < α ≤ α'`,
with `Δ_{α,T}` and `Δ_{α',T}` strictly decreasing on `[0, D]`, and let `r` and
`r'` maximize `G` for `α` and for `α'`. Suppose `r < r'`. Then `r < D`, so
`Δ_{α,T}(r) ≤ 0` by step 3; and `r' > 0`, so `Δ_{α',T}(r') ≥ 0` by step 3.
Since `Δ_{α',T}` is strictly decreasing, `Δ_{α',T}(r) > Δ_{α',T}(r') ≥ 0`, and
by step 2 `Δ_{α,T}(r) ≥ Δ_{α',T}(r) > 0`, a contradiction. Hence `r' ≤ r`." -/
theorem s5_larger_scale (hC15b : C15b.Statement) (η τ₀ : ℝ → ℝ) (D T α α' : ℝ)
    (hc : SmoothCurves η τ₀ D) (hT : 0 < T) (hα : 0 < α) (hαα' : α ≤ α')
    (hs : StrictAntiOn (balanceGap η (fun r => α * τ₀ r) T D) (Icc 0 D))
    (hs' : StrictAntiOn (balanceGap η (fun r => α' * τ₀ r) T D) (Icc 0 D))
    (r : ℝ) (hr : r ∈ Icc 0 D) (r' : ℝ) (hr' : r' ∈ Icc 0 D)
    (hmax : IsMaxOn (gain η (fun r => α * τ₀ r) T) (Icc 0 D) r)
    (hmax' : IsMaxOn (gain η (fun r => α' * τ₀ r) T) (Icc 0 D) r') : r' ≤ r := by
  have hcα := (s1_scaled_delay η τ₀ D α hc hα).1
  have hcα' := (s1_scaled_delay η τ₀ D α' hc (hα.trans_le hαα')).1
  by_contra hlt
  rw [not_le] at hlt
  have h1 := (s3_gap_sign_at_optimum hC15b η _ T D hT hcα hs r hr hmax).2 (hlt.trans_le hr'.2)
  have h2 := (s3_gap_sign_at_optimum hC15b η _ T D hT hcα' hs' r' hr' hmax').1
    (hr.1.trans_lt hlt)
  have h3 := hs' hr hr' hlt
  have h4 := (s2_gap_order η τ₀ D hc).2 T α α' hT hα hαα' r hr
  linarith

/-- The sentence after Proposition (marginal_balance) on `T` and the latency
scale. -/
theorem main (hC15b : C15b.Statement) : C15c.Statement := by
  intro η τ₀ D hc
  exact ⟨fun α T T' hα hT hTT' hs hs' r hr r' hr' hmax hmax' =>
      s4_larger_T hC15b η τ₀ D α T T' hc hα hT hTT' hs hs' r hr r' hr' hmax hmax',
    fun T α α' hT hα hαα' hs hs' r hr r' hr' hmax hmax' =>
      s5_larger_scale hC15b η τ₀ D T α α' hc hT hα hαα' hs hs' r hr r' hr' hmax hmax'⟩

end TinaV2.C15c.A1
