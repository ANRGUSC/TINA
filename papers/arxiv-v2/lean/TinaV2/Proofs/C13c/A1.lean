import TinaV2.Statements

/-! # C13.c, attempt A1: mirrors the supplement proof C13.c/p1

The paper states the behaviour of `η_S(0)` and of the crossover in the coupling
strength without argument (`main-v2.tex` 666-673). The proof mirrored here is
not in the paper. It is the supplement proof `C13.c/p1` in the ledger
(`python3 tools/ledger.py supplement C13.c`), written for the formalization
under disposition `C13.c/d1`. One lemma per step of that proof, in its order,
then `main`. -/

namespace TinaV2.C13c.A1

open Real Set

/-- Step 1 (supplied). "At `γ = 0` the numerator of Eq. (aggregate_eta) is zero,
so `η_S(0) = 0`; and the argument of the logarithm in Eq. (aggregate_rho_star)
is `q·q/(q·q) = 1`, so `ρ⋆(0,n) = 0`." -/
theorem s1_at_zero (n : ℕ) (q : ℝ) (hq : 0 < q) :
    aggEta n q 0 = 0 ∧ aggRhoStar n q 0 = 0 := by
  have hq' := hq.ne'
  constructor
  · simp [aggEta]
  · simp [aggRhoStar, hq']

/-- Step 2 (supplied). "Write `A(γ) = (q+γ)(q+γ(n−1)) / (q(q+γn))` for the
argument of the logarithm in Eq. (aggregate_rho_star). Since
`(q+γ)(q+γ(n−1)) = q(q+γn) + γ²(n−1)`,
`A(γ) = 1 + ((n−1)/q) · γ²/(q+γn)`; and by Eq. (aggregate_eta),
`1 − η_S(0) = 1/A(γ)`." -/
theorem s2_argument (n : ℕ) (q γ : ℝ) (hn : 2 ≤ n) (hq : 0 < q) (hγ : 0 ≤ γ) :
    (q + γ) * (q + γ * (n - 1)) / (q * (q + γ * n))
        = 1 + (n - 1) / q * (γ ^ 2 / (q + γ * n)) ∧
      1 - aggEta n q γ = ((q + γ) * (q + γ * (n - 1)) / (q * (q + γ * n)))⁻¹ := by
  have hn' : (0 : ℝ) ≤ (n : ℝ) - 1 := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  have h1 : (0 : ℝ) < q + γ * n := by positivity
  have h2 : (0 : ℝ) < q + γ * (n - 1) := by positivity
  have h3 : (0 : ℝ) < q + γ := by positivity
  constructor
  · field_simp
    ring
  · simp only [aggEta]
    field_simp
    ring

/-- Step 3 (supplied). "The function `γ ↦ γ²/(q+γn)` is strictly increasing on
`γ ≥ 0`: for `0 ≤ γ₁ < γ₂`,
`γ₂²(q+γ₁n) − γ₁²(q+γ₂n) = (γ₂−γ₁)[q(γ₁+γ₂) + nγ₁γ₂] > 0`." -/
theorem s3_strictMono (n : ℕ) (q : ℝ) (hq : 0 < q) :
    StrictMonoOn (fun γ : ℝ => γ ^ 2 / (q + γ * n)) (Ici 0) := by
  intro γ₁ h₁ γ₂ h₂ hlt
  have h₁' : (0 : ℝ) ≤ γ₁ := h₁
  have h₂' : (0 : ℝ) < γ₂ := lt_of_le_of_lt h₁' hlt
  have hd₁ : (0 : ℝ) < q + γ₁ * n := by positivity
  have hd₂ : (0 : ℝ) < q + γ₂ * n := by positivity
  show γ₁ ^ 2 / (q + γ₁ * n) < γ₂ ^ 2 / (q + γ₂ * n)
  rw [div_lt_div_iff₀ hd₁ hd₂]
  have hkey : γ₂ ^ 2 * (q + γ₁ * n) - γ₁ ^ 2 * (q + γ₂ * n)
      = (γ₂ - γ₁) * (q * (γ₁ + γ₂) + n * γ₁ * γ₂) := by ring
  have hpos : 0 < (γ₂ - γ₁) * (q * (γ₁ + γ₂) + n * γ₁ * γ₂) := by
    have hsum : 0 < q * (γ₁ + γ₂) := by positivity
    have hprod : (0 : ℝ) ≤ n * γ₁ * γ₂ := by positivity
    exact mul_pos (sub_pos.2 hlt) (by linarith)
  linarith

/-- Step 4 (supplied). "Since `n ≥ 2`, the coefficient `(n−1)/q` is positive, so
by steps 2 and 3 `A` is strictly increasing on `γ ≥ 0`, and `A(γ) ≥ 1`." -/
theorem s4_argument_strictMono (n : ℕ) (q : ℝ) (hn : 2 ≤ n) (hq : 0 < q) :
    StrictMonoOn (fun γ : ℝ => (q + γ) * (q + γ * (n - 1)) / (q * (q + γ * n))) (Ici 0) ∧
      ∀ γ : ℝ, 0 ≤ γ → 1 ≤ (q + γ) * (q + γ * (n - 1)) / (q * (q + γ * n)) := by
  have hc : (0 : ℝ) < (n - 1) / q := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    exact div_pos (by linarith) hq
  constructor
  · intro γ₁ h₁ γ₂ h₂ hlt
    have h₁' : (0 : ℝ) ≤ γ₁ := h₁
    have h₂' : (0 : ℝ) ≤ γ₂ := h₂
    show (q + γ₁) * (q + γ₁ * (n - 1)) / (q * (q + γ₁ * n))
      < (q + γ₂) * (q + γ₂ * (n - 1)) / (q * (q + γ₂ * n))
    rw [(s2_argument n q γ₁ hn hq h₁').1, (s2_argument n q γ₂ hn hq h₂').1]
    have h := mul_lt_mul_of_pos_left (s3_strictMono n q hq h₁ h₂ hlt) hc
    simpa using h
  · intro γ hγ
    rw [(s2_argument n q γ hn hq hγ).1]
    have h1 : (0 : ℝ) < q + γ * n := by positivity
    have : 0 ≤ (n - 1) / q * (γ ^ 2 / (q + γ * n)) := by positivity
    linarith

/-- Step 5 (supplied). "Consequently `ρ⋆(γ,n) = ½ log A(γ)` is strictly
increasing on `γ ≥ 0`, because the logarithm is strictly increasing on positive
numbers; and `η_S(0) = 1 − 1/A(γ)` (step 2) is strictly increasing, because
`A` is positive and strictly increasing." -/
theorem s5_strictMono (n : ℕ) (q : ℝ) (hn : 2 ≤ n) (hq : 0 < q) :
    StrictMonoOn (fun γ => aggEta n q γ) (Ici 0) ∧
      StrictMonoOn (fun γ => aggRhoStar n q γ) (Ici 0) := by
  obtain ⟨hmono, hge⟩ := s4_argument_strictMono n q hn hq
  constructor
  · intro γ₁ h₁ γ₂ h₂ hlt
    have e₁ := (s2_argument n q γ₁ hn hq h₁).2
    have e₂ := (s2_argument n q γ₂ hn hq h₂).2
    have hA₁ : 0 < (q + γ₁) * (q + γ₁ * (n - 1)) / (q * (q + γ₁ * n)) :=
      lt_of_lt_of_le one_pos (hge γ₁ h₁)
    have hinv := inv_strictAnti₀ hA₁ (hmono h₁ h₂ hlt)
    show aggEta n q γ₁ < aggEta n q γ₂
    linarith
  · intro γ₁ h₁ γ₂ h₂ hlt
    have hA₁ : 0 < (q + γ₁) * (q + γ₁ * (n - 1)) / (q * (q + γ₁ * n)) :=
      lt_of_lt_of_le one_pos (hge γ₁ h₁)
    have hlog := Real.log_lt_log hA₁ (hmono h₁ h₂ hlt)
    show aggRhoStar n q γ₁ < aggRhoStar n q γ₂
    simp only [aggRhoStar]
    linarith

/-- The last paragraph of Section "Role of Decision Coupling". -/
theorem main : C13c.Statement := by
  intro n q hn hq
  exact ⟨(s1_at_zero n q hq).1, (s1_at_zero n q hq).2, s5_strictMono n q hn hq⟩

end TinaV2.C13c.A1
