import TinaV2.Statements

/-! # C13.b, attempt A1: mirrors the supplement proof C13.b/p1

The paper states the large-`n` limit of the threshold and the local share
without argument (`main-v2.tex` 649-664). The proof mirrored here is not in the
paper. It is the supplement proof `C13.b/p1` in the ledger
(`python3 tools/ledger.py supplement C13.b`), written for the formalization
under disposition `C13.b/d1`. One lemma per step of that proof, in its order,
then `main`. -/

namespace TinaV2.C13b.A1

open Real Set Filter Topology

/-- Step 1 (supplied). "For fixed `q > 0` and `γ ≥ 0`,
`(q + γ(n−1))/(q + γn) = 1 − γ/(q + γn) → 1` as `n → ∞`." -/
theorem s1_ratio (q γ : ℝ) (hq : 0 < q) (hγ : 0 ≤ γ) :
    Tendsto (fun n : ℕ => (q + γ * (n - 1)) / (q + γ * n)) atTop (𝓝 1) := by
  have hpos : ∀ n : ℕ, 0 < q + γ * n := fun n => by positivity
  have hfrac : Tendsto (fun n : ℕ => γ / (q + γ * n)) atTop (𝓝 0) := by
    rcases hγ.eq_or_lt with rfl | hγ'
    · simp
    · exact tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_left _ q
        (tendsto_natCast_atTop_atTop.const_mul_atTop hγ'))
  have h := (tendsto_const_nhds (x := (1 : ℝ))).sub hfrac
  rw [sub_zero] at h
  refine h.congr fun n => ?_
  have := (hpos n).ne'
  field_simp
  ring

/-- Step 2 (supplied). "Hence the argument of the logarithm in
Eq. (aggregate_rho_star), `((q+γ)/q) · (q + γ(n−1))/(q + γn)`, tends to
`(q+γ)/q = 1 + γ/q > 0`, and continuity of the logarithm there gives
Eq. (large_n_threshold)." -/
theorem s2_threshold (q γ : ℝ) (hq : 0 < q) (hγ : 0 ≤ γ) :
    Tendsto (fun n : ℕ => aggRhoStar n q γ) atTop (𝓝 (1 / 2 * log (1 + γ / q))) := by
  have harg : Tendsto (fun n : ℕ => (q + γ) / q * ((q + γ * (n - 1)) / (q + γ * n))) atTop
      (𝓝 (1 + γ / q)) := by
    have h := (s1_ratio q γ hq hγ).const_mul ((q + γ) / q)
    have he : (q + γ) / q * 1 = 1 + γ / q := by field_simp
    rwa [he] at h
  have hlim : (1 : ℝ) + γ / q ≠ 0 := by positivity
  have h := ((continuousAt_log hlim).tendsto.comp harg).const_mul (1 / 2)
  refine h.congr fun n => ?_
  have h1 : (0 : ℝ) < q + γ * n := by positivity
  simp only [aggRhoStar, Function.comp_apply]
  congr 2
  field_simp

/-- Step 3 (supplied). "By Eq. (aggregate_eta),
`1 − η_S(0) = (q/(q+γ)) · (q + γn)/(q + γ(n−1))` for `n ≥ 1`, the reciprocal of
that argument, so by step 1 it tends to `q/(q+γ)`." -/
theorem s3_local_share (q γ : ℝ) (hq : 0 < q) (hγ : 0 ≤ γ) :
    Tendsto (fun n : ℕ => 1 - aggEta n q γ) atTop (𝓝 (q / (q + γ))) := by
  have hinv : Tendsto (fun n : ℕ => q / (q + γ) * ((q + γ * (n - 1)) / (q + γ * n))⁻¹) atTop
      (𝓝 (q / (q + γ))) := by
    have h := ((s1_ratio q γ hq hγ).inv₀ one_ne_zero).const_mul (q / (q + γ))
    rwa [inv_one, mul_one] at h
  refine hinv.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn' : (0 : ℝ) ≤ (n : ℝ) - 1 := by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  have h1 : (0 : ℝ) < q + γ * n := by positivity
  have h2 : (0 : ℝ) < q + γ * (n - 1) := by positivity
  have h3 : (0 : ℝ) < q + γ := by positivity
  simp only [aggEta]
  field_simp
  ring

/-- Eq. (large_n_threshold) and the sentence after it. -/
theorem main : C13b.Statement := by
  intro q γ hq hγ
  exact ⟨s2_threshold q γ hq hγ, s3_local_share q γ hq hγ⟩

end TinaV2.C13b.A1
