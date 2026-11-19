import TinaV2.Statements
import TinaV2.Routine.RadiusCalculus

/-! # C20, attempt A1: mirrors the supplement proof C20/p1

The paper states the limit of the canonical radius for a large decision range
without argument (`main-v3.tex` 951-954). The proof mirrored here is not in
the paper. It is the supplement proof `C20/p1` in the ledger
(`python3 tools/ledger.py supplement C20`), written for the formalization
under disposition `C20/d1`. One lemma per step of that proof, in its order,
then `main`. The limit is about the closed form of Eq.
(canonical_optimal_radius); that this radius is the optimal one is claim C19
(Theorem (canonical_optimal_radius)), which no step needs. -/

namespace TinaV2.C20.A1

open Real Set Filter Topology

/-- Step 1 (supplied). "Let `vT > 2ℓ_s`, the positive-radius condition
Eq. (positive_radius_condition), which does not involve `ℓ_c`. Then for every
`ℓ_c > 0`, `(ℓ_c + vT)/(ℓ_c + 2ℓ_s) = 1 + (vT − 2ℓ_s)/(ℓ_c + 2ℓ_s) > 1`, so the
logarithm in Eq. (canonical_optimal_radius) is positive, the positive part is
inactive, and `r⋆ = (ℓ_c/2) log(1 + (vT − 2ℓ_s)/(ℓ_c + 2ℓ_s))`." -/
theorem s1_regime (ℓc ℓs v T : ℝ) (hc : 0 < ℓc) (hs : 0 < ℓs) (h : 2 * ℓs < v * T) :
    canonRadius ℓc ℓs v T
      = ℓc / 2 * log (1 + (v * T - 2 * ℓs) / (ℓc + 2 * ℓs)) := by
  have hden : 0 < ℓc + 2 * ℓs := by positivity
  rw [RadiusCalculus.canonRadius_of_regime hc hs h]
  congr 2
  field_simp
  ring

/-- Step 2 (supplied). "For constants `c` and `d`: `y log(1 + c/y) → c` as
`y → ∞`, because `log(1 + u)/u → 1` as `u → 0`; and `log(1 + c/y) → 0`. With
`y = x + d`, `x log(1 + c/(x + d)) = y log(1 + c/y) − d log(1 + c/y) → c` as
`x → ∞`." -/
theorem s2_limit (c d : ℝ) :
    Tendsto (fun x : ℝ => x * log (1 + c / (x + d))) atTop (𝓝 c) := by
  have hy : Tendsto (fun x : ℝ => x + d) atTop atTop :=
    tendsto_atTop_add_const_right _ d tendsto_id
  have h1 : Tendsto (fun x : ℝ => (x + d) * log (1 + c / (x + d))) atTop (𝓝 c) :=
    (Real.tendsto_mul_log_one_add_div_atTop c).comp hy
  have h2 : Tendsto (fun x : ℝ => log (1 + c / (x + d))) atTop (𝓝 0) := by
    have harg : Tendsto (fun x : ℝ => 1 + c / (x + d)) atTop (𝓝 (1 + 0)) :=
      tendsto_const_nhds.add (tendsto_const_nhds.div_atTop hy)
    have h := (continuousAt_log (by norm_num : (1 : ℝ) + 0 ≠ 0)).tendsto.comp harg
    rw [add_zero, Real.log_one] at h
    exact h
  have h3 := h1.sub (h2.const_mul d)
  simp only [mul_zero, sub_zero] at h3
  exact h3.congr fun x => by ring

/-- Step 3 (supplied). "By step 1, for every `ℓ_c > 0`,
`r⋆ = ½ · ℓ_c log(1 + (vT − 2ℓ_s)/(ℓ_c + 2ℓ_s))`. By step 2 with
`c = vT − 2ℓ_s` and `d = 2ℓ_s`, `r⋆ → (vT − 2ℓ_s)/2` as `ℓ_c → ∞`." -/
theorem s3_radius_limit (ℓs v T : ℝ) (hs : 0 < ℓs) (h : 2 * ℓs < v * T) :
    Tendsto (fun ℓc => canonRadius ℓc ℓs v T) atTop (𝓝 ((v * T - 2 * ℓs) / 2)) := by
  have h2 := (s2_limit (v * T - 2 * ℓs) (2 * ℓs)).div_const 2
  refine h2.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with ℓc hc
  rw [s1_regime ℓc ℓs v T hc hs h]
  ring

/-- The sentence before Section "Numerical Illustrations". -/
theorem main : C20.Statement := by
  intro ℓs v T hs _ _ h
  exact s3_radius_limit ℓs v T hs h

end TinaV2.C20.A1
