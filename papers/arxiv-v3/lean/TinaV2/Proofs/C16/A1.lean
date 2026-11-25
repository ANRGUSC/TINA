import TinaV2.Statements
import TinaV2.Routine.ExpRadius
import TinaV2.Routine.RadiusCalculus

/-! # C16, attempt A1: mirrors paper proof C16/p1

Proposition (generic_exponential_radius), main-v2.tex 759-786. One lemma per
step of the paper's proof, then `main`. Throughout, `expGain η0 ℓc v T` is the
captured benefit `G(r) = (1 − η₀ e^{−2r/ℓ_c}) e^{−2(r/v)/T}` and
`expBracket η0 ℓc v T r` is the bracket in the paper's formula for `G'(r)`:
`η₀ (1/(vT) + 1/ℓ_c) e^{−2r/ℓ_c} − 1/(vT)`. -/

namespace TinaV2.C16.A1
open Real Set Filter Topology
open TinaV2.Routine.ExpRadius

variable (η0 ℓc v T : ℝ)

/-- Step 1 (main-v2.tex 775-780): differentiating the captured benefit gives
`G'(r) = 2 e^{−2r/(vT)} [η₀ (1/(vT) + 1/ℓ_c) e^{−2r/ℓ_c} − 1/(vT)]`. -/
theorem s1_deriv_formula (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T) (r : ℝ) :
    HasDerivAt (expGain η0 ℓc v T) (2 * exp (-2 * r / (v * T)) * expBracket η0 ℓc v T r) r := by
  have hη : HasDerivAt (fun x : ℝ => 1 - η0 * exp (-2 * x / ℓc))
      (-(η0 * (exp (-2 * r / ℓc) * (-2 / ℓc)))) r := by
    have h1 : HasDerivAt (fun x : ℝ => -2 * x / ℓc) (-2 / ℓc) r :=
      (((hasDerivAt_id' r).const_mul (-2 : ℝ)).div_const ℓc).congr_deriv (by ring)
    exact ((h1.exp).const_mul η0).const_sub 1
  have hτ : HasDerivAt (fun x : ℝ => exp (-2 * (x / v) / T))
      (exp (-2 * (r / v) / T) * (-2 / (v * T))) r := by
    have h1 : HasDerivAt (fun x : ℝ => -2 * (x / v) / T) (-2 / (v * T)) r :=
      ((((hasDerivAt_id' r).div_const v).const_mul (-2 : ℝ)).div_const T).congr_deriv
        (by ring)
    exact h1.exp
  have harg : -2 * (r / v) / T = -2 * r / (v * T) := by ring
  refine (hη.mul hτ).congr_deriv ?_
  rw [harg]
  field_simp
  ring

/-- Step 2 (main-v2.tex 781): the bracket decreases strictly to a negative
limit, namely `−1/(vT)`. -/
theorem s2_bracket_decreases (hη0 : 0 < η0) (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T) :
    StrictAnti (fun r : ℝ => expBracket η0 ℓc v T r) ∧
      Tendsto (fun r : ℝ => expBracket η0 ℓc v T r) atTop (𝓝 (-(1 / (v * T)))) ∧
      -(1 / (v * T)) < 0 := by
  have hvT : 0 < v * T := mul_pos hv hT
  have hk : 0 < η0 * (1 / (v * T) + 1 / ℓc) := by positivity
  refine ⟨?_, ?_, neg_lt_zero.mpr (one_div_pos.mpr hvT)⟩
  · intro a b hab
    have hexp : exp (-2 * b / ℓc) < exp (-2 * a / ℓc) := by
      apply exp_lt_exp.mpr
      apply div_lt_div_of_pos_right _ hℓc
      linarith
    have := mul_lt_mul_of_pos_left hexp hk
    show _ - _ < _ - _
    linarith
  · have harg : Tendsto (fun r : ℝ => -2 * r / ℓc) atTop atBot :=
      (tendsto_id.const_mul_atTop_of_neg (by norm_num : (-2 : ℝ) < 0)).atBot_div_const hℓc
    have hexp : Tendsto (fun r : ℝ => exp (-2 * r / ℓc)) atTop (𝓝 0) :=
      tendsto_exp_atBot.comp harg
    have := (hexp.const_mul (η0 * (1 / (v * T) + 1 / ℓc))).sub_const (1 / (v * T))
    simpa [expBracket] using this

/-- Step 3 (main-v2.tex 781-783): if the bracket's value at zero is nonpositive,
`G` decreases for all positive radii and zero is its unique maximum (including
when the initial derivative is zero). -/
theorem s3_nonpositive_at_zero (hη0 : 0 < η0) (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T)
    (hB0 : expBracket η0 ℓc v T 0 ≤ 0) :
    StrictAntiOn (expGain η0 ℓc v T) (Ici 0) ∧
      ∀ r, 0 < r → expGain η0 ℓc v T r < expGain η0 ℓc v T 0 := by
  obtain ⟨hanti, -, -⟩ := s2_bracket_decreases η0 ℓc v T hη0 hℓc hv hT
  have hG : StrictAntiOn (expGain η0 ℓc v T) (Ici 0) := by
    refine RadiusCalculus.strictAntiOn_of_hasDerivAt_neg (convex_Ici 0)
      (fun x _ => s1_deriv_formula η0 ℓc v T hℓc hv hT x) ?_
    intro x hx
    rw [interior_Ici] at hx
    have hx' : expBracket η0 ℓc v T x < 0 := lt_of_lt_of_le (hanti hx) hB0
    exact mul_neg_of_pos_of_neg (by positivity) hx'
  exact ⟨hG, fun r hr => hG self_mem_Ici hr.le hr⟩

/-- Step 4 (main-v2.tex 783-784): otherwise (the bracket is positive at zero)
`G` increases up to the bracket's unique crossing `c > 0` and decreases
thereafter. The last conjunct, that `c` is then the unique maximizer over
`r ≥ 0`, is the conclusion the paper draws from this shape without saying so
(step 3 says it for the other case). -/
theorem s4_positive_at_zero (hη0 : 0 < η0) (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T)
    (hB0 : 0 < expBracket η0 ℓc v T 0) :
    ∃ c, 0 < c ∧ expBracket η0 ℓc v T c = 0 ∧ (∀ c', expBracket η0 ℓc v T c' = 0 → c' = c) ∧
      StrictMonoOn (expGain η0 ℓc v T) (Icc 0 c) ∧ StrictAntiOn (expGain η0 ℓc v T) (Ici c) ∧
      ∀ r, 0 ≤ r → r ≠ c → expGain η0 ℓc v T r < expGain η0 ℓc v T c := by
  obtain ⟨hanti, hlim, hneg⟩ := s2_bracket_decreases η0 ℓc v T hη0 hℓc hv hT
  -- the bracket is eventually negative, because its limit is
  obtain ⟨R, hR⟩ : ∃ R : ℝ, expBracket η0 ℓc v T R < 0 :=
    (hlim.eventually (eventually_lt_nhds hneg)).exists
  have hR0 : 0 < R := by
    by_contra h
    have := hanti.antitone (not_lt.mp h)
    linarith
  -- so it crosses zero between `0` and `R`, by continuity
  have hcont : Continuous (fun r : ℝ => expBracket η0 ℓc v T r) := by fun_prop
  obtain ⟨c, hc, hBc⟩ : ∃ c ∈ Icc 0 R, expBracket η0 ℓc v T c = 0 :=
    intermediate_value_Icc' hR0.le hcont.continuousOn ⟨hR.le, hB0.le⟩
  have hc0 : 0 < c := by
    rcases hc.1.eq_or_lt with h | h
    · rw [← h] at hBc; linarith
    · exact h
  have hmono : StrictMonoOn (expGain η0 ℓc v T) (Icc 0 c) := by
    refine RadiusCalculus.strictMonoOn_of_hasDerivAt_pos (convex_Icc 0 c)
      (fun x _ => s1_deriv_formula η0 ℓc v T hℓc hv hT x) ?_
    intro x hx
    rw [interior_Icc] at hx
    have hx' : 0 < expBracket η0 ℓc v T x := by have := hanti hx.2; simp only at this; linarith
    exact mul_pos (by positivity) hx'
  have hdecr : StrictAntiOn (expGain η0 ℓc v T) (Ici c) := by
    refine RadiusCalculus.strictAntiOn_of_hasDerivAt_neg (convex_Ici c)
      (fun x _ => s1_deriv_formula η0 ℓc v T hℓc hv hT x) ?_
    intro x hx
    rw [interior_Ici] at hx
    have hx' : expBracket η0 ℓc v T x < 0 := by have := hanti hx; simp only at this; linarith
    exact mul_neg_of_pos_of_neg (by positivity) hx'
  refine ⟨c, hc0, hBc, fun c' hc' => hanti.injective (hc'.trans hBc.symm), hmono, hdecr, ?_⟩
  intro r hr hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact hmono ⟨hr, h.le⟩ ⟨hc0.le, le_refl c⟩ h
  · exact hdecr self_mem_Ici h.le h

/-- Step 5 (main-v2.tex 784-785): solving for the crossing gives the formula.
A zero `c` of the bracket satisfies `η₀(1 + vT/ℓ_c) e^{−2c/ℓ_c} = 1`, so
`c = (ℓ_c/2) log(η₀(1 + vT/ℓ_c))`; this is `r⋆` of
Eq. (generic_exponential_rstar) when the bracket is positive at zero, and when
it is not the positive part makes `r⋆ = 0`, the maximizer of step 3. -/
theorem s5_solve_crossing (hη0 : 0 < η0) (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T) :
    (expBracket η0 ℓc v T 0 ≤ 0 → expRadius η0 ℓc v T = 0) ∧
      (0 < expBracket η0 ℓc v T 0 → ∀ c, expBracket η0 ℓc v T c = 0 → c = expRadius η0 ℓc v T) := by
  have hvT : 0 < v * T := mul_pos hv hT
  have hz : 0 < η0 * (1 + v * T / ℓc) := by positivity
  have key : ∀ c : ℝ,
      v * T * expBracket η0 ℓc v T c = η0 * (1 + v * T / ℓc) * exp (-2 * c / ℓc) - 1 := by
    intro c
    field_simp
  have key0 : v * T * expBracket η0 ℓc v T 0 = η0 * (1 + v * T / ℓc) - 1 := by
    rw [key 0]; simp
  constructor
  · intro h0
    have hle : η0 * (1 + v * T / ℓc) ≤ 1 := by
      have := mul_nonpos_of_nonneg_of_nonpos hvT.le h0
      linarith
    unfold expRadius
    rw [max_eq_right (log_nonpos hz.le hle), mul_zero]
  · intro h0 c hc
    have hgt : 1 < η0 * (1 + v * T / ℓc) := by
      have := mul_pos hvT h0
      linarith
    have h1 : η0 * (1 + v * T / ℓc) * exp (-2 * c / ℓc) = 1 := by
      have := key c
      rw [hc, mul_zero] at this
      linarith
    have h2 : log (η0 * (1 + v * T / ℓc)) + -2 * c / ℓc = 0 := by
      have := congrArg log h1
      rwa [log_mul hz.ne' (exp_ne_zero _), log_exp, log_one] at this
    have h3 : log (η0 * (1 + v * T / ℓc)) = 2 * c / ℓc := by
      have : -2 * c / ℓc = -(2 * c / ℓc) := by ring
      linarith
    unfold expRadius
    rw [max_eq_left (log_pos hgt).le, h3]
    field_simp

/-- Step 6 (main-v2.tex 785): a cap truncates the maximizing radius. On `[0, D]`
the unique maximizer is `min{D, m}`, where `m` is the unconstrained maximizer
of step 3 (zero) or of step 4 (the crossing). -/
theorem s6_cap_truncates (hη0 : 0 < η0) (hℓc : 0 < ℓc) (hv : 0 < v) (hT : 0 < T) :
    (expBracket η0 ℓc v T 0 ≤ 0 →
        ∀ D, 0 ≤ D → ∀ r ∈ Icc 0 D, r ≠ min D 0 →
          expGain η0 ℓc v T r < expGain η0 ℓc v T (min D 0)) ∧
      (0 < expBracket η0 ℓc v T 0 → ∀ c, expBracket η0 ℓc v T c = 0 →
        ∀ D, 0 ≤ D → ∀ r ∈ Icc 0 D, r ≠ min D c →
          expGain η0 ℓc v T r < expGain η0 ℓc v T (min D c)) := by
  constructor
  · intro hB0 D hD r hr hne
    obtain ⟨-, hmax⟩ := s3_nonpositive_at_zero η0 ℓc v T hη0 hℓc hv hT hB0
    rw [min_eq_right hD] at hne ⊢
    exact hmax r (lt_of_le_of_ne hr.1 (Ne.symm hne))
  · intro hB0 c hBc D hD r hr hne
    obtain ⟨c₀, hc0, -, huniq, hmono, -, hmax⟩ :=
      s4_positive_at_zero η0 ℓc v T hη0 hℓc hv hT hB0
    obtain rfl : c = c₀ := huniq c hBc
    rcases le_or_gt D c with hDc | hDc
    · rw [min_eq_left hDc] at hne ⊢
      exact hmono ⟨hr.1, hr.2.trans hDc⟩ ⟨hD, hDc⟩ (lt_of_le_of_ne hr.2 hne)
    · rw [min_eq_right hDc.le] at hne ⊢
      exact hmax r hr.1 hne

/-- Proposition (generic_exponential_radius): assembly of steps 3-6, by the
sign of the bracket at zero. -/
theorem main : C16.Statement := by
  intro η0 ℓc v T hη0 _ hℓc hv hT
  dsimp only
  have hz : 0 < η0 * (1 + v * T / ℓc) := by positivity
  obtain ⟨h5a, h5b⟩ := s5_solve_crossing η0 ℓc v T hη0 hℓc hv hT
  obtain ⟨h6a, h6b⟩ := s6_cap_truncates η0 ℓc v T hη0 hℓc hv hT
  rcases le_or_gt (expBracket η0 ℓc v T 0) 0 with hB | hB
  · rw [h5a hB]
    exact ⟨fun r hr hne => (s3_nonpositive_at_zero η0 ℓc v T hη0 hℓc hv hT hB).2 r
        (lt_of_le_of_ne hr (Ne.symm hne)),
      h5a hB ▸ expRadius_pos_iff hℓc hz, h6a hB⟩
  · obtain ⟨c, -, hBc, -, -, -, hmax⟩ := s4_positive_at_zero η0 ℓc v T hη0 hℓc hv hT hB
    rw [← h5b hB c hBc]
    exact ⟨hmax, h5b hB c hBc ▸ expRadius_pos_iff hℓc hz, h6b hB c hBc⟩

end TinaV2.C16.A1
