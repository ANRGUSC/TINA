import TinaV2.Statements
import TinaV2.Routine.RadiusCalculus

/-! # C15.b, attempt A1: mirrors the supplement proof C15.b/p1

The paper states that single crossing identifies the unique optimum without
argument (`main-v3.tex` 755-760). The proof mirrored here is not in the paper.
It is the supplement proof `C15.b/p1` in the ledger
(`python3 tools/ledger.py supplement C15.b`), written for the formalization
under disposition `C15.b/d1`. One lemma per step of that proof, in its order,
then `main`. Throughout, `Δ` is the balance gap: the left side of
Eq. (marginal_balance_condition) minus its right side, with one-sided
derivatives at `0` and `D`. -/

namespace TinaV2.C15b.A1

open Real Set

/-- Step 1 (supplied). "Let `L(r) = log[1 − η_S(r)] − 2τ(r)/T` on `[0, D]`.
Since `η_S < 1`, `G(r) = e^{L(r)}` by Eq. (snapshot_gain). Since `η_S` and `τ`
are continuously differentiable on `[0, D]` and `1 − η_S > 0`, `L` is
continuously differentiable on `[0, D]`, and its derivative (one-sided at the
two endpoints) is the difference `Δ(r)` between the left and right sides of
Eq. (marginal_balance_condition). In particular `Δ` is continuous on
`[0, D]`." -/
theorem s1_log_gain (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D) :
    (∀ r ∈ Icc 0 D, gain η τ T r = exp (log (1 - η r) - 2 * τ r / T)) ∧
    (∀ r ∈ Icc 0 D, HasDerivWithinAt (fun x => log (1 - η x) - 2 * τ x / T)
      (balanceGap η τ T D r) (Icc 0 D) r) ∧
    ContinuousOn (balanceGap η τ T D) (Icc 0 D) := by
  have hpos : ∀ r ∈ Icc 0 D, 0 < 1 - η r := fun r hr => sub_pos.mpr (hc.η_range r hr).2
  have hlogC : ContDiffOn ℝ 1 (fun x => log (1 - η x)) (Icc 0 D) :=
    (contDiffOn_const.sub hc.η_contDiffOn).log fun x hx => (hpos x hx).ne'
  have hU : UniqueDiffOn ℝ (Icc 0 D) := uniqueDiffOn_Icc hc.D_pos
  refine ⟨fun r hr => ?_, fun r hr => ?_, ?_⟩
  · rw [← RadiusCalculus.log_gain (hc.η_range r hr).2, exp_log]
    exact mul_pos (hpos r hr) (exp_pos _)
  · have h1 : HasDerivWithinAt (fun x => log (1 - η x))
        (derivWithin (fun x => log (1 - η x)) (Icc 0 D) r) (Icc 0 D) r :=
      (hlogC.differentiableOn one_ne_zero r hr).hasDerivWithinAt
    have h2 : HasDerivWithinAt τ (derivWithin τ (Icc 0 D) r) (Icc 0 D) r :=
      (hc.τ_contDiffOn.differentiableOn one_ne_zero r hr).hasDerivWithinAt
    exact h1.sub ((h2.const_mul 2).div_const T)
  · exact (hlogC.continuousOn_derivWithin hU le_rfl).sub
      (((hc.τ_contDiffOn.continuousOn_derivWithin hU le_rfl).const_mul 2).div_const T)

/-- Step 2 (supplied). "Let `[a, b] ⊆ [0, D]`. If `Δ > 0` on `(a, b)`, then by
the mean value theorem `L` is strictly increasing on `[a, b]`, and so is
`G = e^L`. If `Δ < 0` on `(a, b)`, both are strictly decreasing on
`[a, b]`." -/
theorem s2_monotone_pieces (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D) (a b : ℝ)
    (ha : 0 ≤ a) (hb : b ≤ D) :
    ((∀ x ∈ Ioo a b, 0 < balanceGap η τ T D x) → StrictMonoOn (gain η τ T) (Icc a b)) ∧
    ((∀ x ∈ Ioo a b, balanceGap η τ T D x < 0) → StrictAntiOn (gain η τ T) (Icc a b)) := by
  obtain ⟨hG, hL, -⟩ := s1_log_gain η τ T D hc
  have hsub : Icc a b ⊆ Icc 0 D := Icc_subset_Icc ha hb
  have hcont : ContinuousOn (fun x => log (1 - η x) - 2 * τ x / T) (Icc a b) := fun x hx =>
    (hL x (hsub hx)).continuousWithinAt.mono hsub
  have hderiv : ∀ x ∈ interior (Icc a b),
      deriv (fun x => log (1 - η x) - 2 * τ x / T) x = balanceGap η τ T D x := by
    intro x hx
    rw [interior_Icc] at hx
    have hx' : x ∈ Ioo 0 D := ⟨ha.trans_lt hx.1, hx.2.trans_le hb⟩
    exact ((hL x (Ioo_subset_Icc_self hx')).hasDerivAt (Icc_mem_nhds hx'.1 hx'.2)).deriv
  constructor
  · intro hpos
    have hmono : StrictMonoOn (fun x => log (1 - η x) - 2 * τ x / T) (Icc a b) :=
      strictMonoOn_of_deriv_pos (convex_Icc a b) hcont fun x hx => by
        rw [hderiv x hx]
        exact hpos x (by rwa [interior_Icc] at hx)
    intro x hx y hy hxy
    rw [hG x (hsub hx), hG y (hsub hy)]
    exact exp_lt_exp.mpr (hmono hx hy hxy)
  · intro hneg
    have hanti : StrictAntiOn (fun x => log (1 - η x) - 2 * τ x / T) (Icc a b) :=
      strictAntiOn_of_deriv_neg (convex_Icc a b) hcont fun x hx => by
        rw [hderiv x hx]
        exact hneg x (by rwa [interior_Icc] at hx)
    intro x hx y hy hxy
    rw [hG x (hsub hx), hG y (hsub hy)]
    exact exp_lt_exp.mpr (hanti hx hy hxy)

/-- Step 3 (supplied). "Suppose `Δ` is strictly decreasing on `[0, D]` and
`Δ(0) ≤ 0`. Then `Δ(r) < Δ(0) ≤ 0` for `0 < r ≤ D`, so by step 2 `G` is
strictly decreasing on `[0, D]`: `G(r) < G(0)` for every `r ∈ (0, D]`." -/
theorem s3_optimum_at_zero (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D)
    (hΔ : StrictAntiOn (balanceGap η τ T D) (Icc 0 D)) (h0 : balanceGap η τ T D 0 ≤ 0) :
    ∀ r ∈ Icc 0 D, r ≠ 0 → gain η τ T r < gain η τ T 0 := by
  have hD : (0 : ℝ) ≤ D := hc.D_pos.le
  have hanti := (s2_monotone_pieces η τ T D hc 0 D le_rfl le_rfl).2 fun x hx =>
    (hΔ (left_mem_Icc.mpr hD) (Ioo_subset_Icc_self hx) hx.1).trans_le h0
  intro r hr hne
  exact hanti (left_mem_Icc.mpr hD) hr (lt_of_le_of_ne hr.1 (Ne.symm hne))

/-- Step 4 (supplied). "Suppose `Δ` is strictly decreasing on `[0, D]` and
`Δ(D) ≥ 0`. Then `Δ(r) > Δ(D) ≥ 0` for `0 ≤ r < D`, so by step 2 `G` is
strictly increasing on `[0, D]`: `G(r) < G(D)` for every `r ∈ [0, D)`." -/
theorem s4_optimum_at_D (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D)
    (hΔ : StrictAntiOn (balanceGap η τ T D) (Icc 0 D)) (hDge : 0 ≤ balanceGap η τ T D D) :
    ∀ r ∈ Icc 0 D, r ≠ D → gain η τ T r < gain η τ T D := by
  have hD : (0 : ℝ) ≤ D := hc.D_pos.le
  have hmono := (s2_monotone_pieces η τ T D hc 0 D le_rfl le_rfl).1 fun x hx =>
    hDge.trans_lt (hΔ (Ioo_subset_Icc_self hx) (right_mem_Icc.mpr hD) hx.2)
  intro r hr hne
  exact hmono hr (right_mem_Icc.mpr hD) (lt_of_le_of_ne hr.2 hne)

/-- Step 5 (supplied). "Suppose `Δ` is strictly decreasing on `[0, D]`,
`Δ(0) > 0` and `Δ(D) < 0`. By step 1 `Δ` is continuous, so the intermediate
value theorem gives `r₀ ∈ (0, D)` with `Δ(r₀) = 0`; it is the only zero
because `Δ` is strictly decreasing. Then `Δ > 0` on `[0, r₀)` and `Δ < 0` on
`(r₀, D]`, so by step 2 `G` is strictly increasing on `[0, r₀]` and strictly
decreasing on `[r₀, D]`: `G(r) < G(r₀)` for every `r ≠ r₀` in `[0, D]`." -/
theorem s5_interior_crossing (η τ : ℝ → ℝ) (T D : ℝ) (hc : SmoothCurves η τ D)
    (hΔ : StrictAntiOn (balanceGap η τ T D) (Icc 0 D)) (h0 : 0 < balanceGap η τ T D 0)
    (hDneg : balanceGap η τ T D D < 0) :
    ∃ r₀ ∈ Ioo 0 D, balanceGap η τ T D r₀ = 0 ∧
      (∀ r ∈ Ioo 0 D, balanceGap η τ T D r = 0 → r = r₀) ∧
      ∀ r ∈ Icc 0 D, r ≠ r₀ → gain η τ T r < gain η τ T r₀ := by
  obtain ⟨-, -, hcont⟩ := s1_log_gain η τ T D hc
  obtain ⟨r₀, hr₀, hzero⟩ := intermediate_value_Ioo' hc.D_pos.le hcont ⟨hDneg, h0⟩
  have hr₀I : r₀ ∈ Icc 0 D := Ioo_subset_Icc_self hr₀
  refine ⟨r₀, hr₀, hzero, fun r hr hrz =>
    hΔ.injOn (Ioo_subset_Icc_self hr) hr₀I (hrz.trans hzero.symm), ?_⟩
  have hmono := (s2_monotone_pieces η τ T D hc 0 r₀ le_rfl hr₀.2.le).1 fun x hx => by
    have h := hΔ ⟨hx.1.le, hx.2.le.trans hr₀.2.le⟩ hr₀I hx.2
    rwa [hzero] at h
  have hanti := (s2_monotone_pieces η τ T D hc r₀ D hr₀.1.le le_rfl).2 fun x hx => by
    have h := hΔ hr₀I ⟨hr₀.1.le.trans hx.1.le, hx.2.le⟩ hx.1
    rwa [hzero] at h
  intro r hr hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact hmono ⟨hr.1, hlt.le⟩ (right_mem_Icc.mpr hr₀.1.le) hlt
  · exact hanti (left_mem_Icc.mpr hr₀.2.le) ⟨hgt.le, hr.2⟩ hgt

/-- The sentence after Proposition (marginal_balance) on single crossing. -/
theorem main : C15b.Statement := by
  intro η τ T D _ hc hΔ
  exact ⟨s3_optimum_at_zero η τ T D hc hΔ, s4_optimum_at_D η τ T D hc hΔ,
    s5_interior_crossing η τ T D hc hΔ⟩

end TinaV2.C15b.A1
