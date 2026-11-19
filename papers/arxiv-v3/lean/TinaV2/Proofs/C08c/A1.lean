import TinaV2.Statements

/-! # C8.c, attempt A1: mirrors the supplement proof C8.c/p1

The paper states the behaviour of the stale-global regret at small and at
large delay without argument (`main-v3.tex` 468-471). The proof mirrored here
is not in the paper. It is the supplement proof `C8.c/p1` in the ledger
(`python3 tools/ledger.py supplement C8.c`), written for the formalization
under disposition `C8.c/d1`. One lemma per step of that proof, in its order,
then `main`. The stale-global corollary C8 enters as the hypothesis
`hC8 : C08.Statement`. -/

namespace TinaV2.C08c.A1

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology Asymptotics

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (supplied). "By Corollary (OU_stale_regret),
`R_glob(τ) = (1 − e^{−2τ/T}) R_∞` for every delay `τ ≥ 0`. At `τ = 0` the
factor is `1 − e⁰ = 0`, so the regret is zero at zero delay." -/
theorem s1_closed_form (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ)
    (hA : ∀ τ, 0 ≤ τ → TemporalAssumption μ θ T t τ) :
    (∀ τ, 0 ≤ τ →
      M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t)) ∧
    M.Rglob μ (θ t) (θ t) = 0 := by
  have h : ∀ τ, 0 ≤ τ →
      M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t) :=
    fun τ hτ => hC8 M μ θ T t τ (hA τ hτ)
  refine ⟨h, ?_⟩
  have h0 := h 0 le_rfl
  simpa using h0

/-- Step 2 (supplied). "The exponential has derivative `1` at `0`, so
`e^x = 1 + x + o(x)` as `x → 0`. With `x = −2τ/T`, which tends to `0` as
`τ ↓ 0`, this gives `1 − e^{−2τ/T} = 2τ/T + o(τ/T)`. Multiplying by the
constant `R_∞` and using step 1, `R_glob(τ) = 2(τ/T) R_∞ + o(τ/T)` as
`τ ↓ 0`." -/
theorem s2_small_delay (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ)
    (hA : ∀ τ, 0 ≤ τ → TemporalAssumption μ θ T t τ) :
    (fun τ => M.Rglob μ (θ (t - τ)) (θ t) - 2 * (τ / T) * M.Rinf μ (θ t))
      =o[𝓝[≥] 0] (fun τ => τ / T) := by
  have hexp : (fun x : ℝ => exp x - 1 - x) =o[𝓝 0] fun x => x := by
    have h := hasDerivAt_iff_isLittleO.mp (Real.hasDerivAt_exp 0)
    simpa using h
  have hlin : Tendsto (fun τ : ℝ => -2 * τ / T) (𝓝[≥] 0) (𝓝 0) := by
    have hc : Continuous fun τ : ℝ => -2 * τ / T := by fun_prop
    have h := hc.tendsto 0
    simp only [mul_zero, zero_div] at h
    exact h.mono_left nhdsWithin_le_nhds
  have hbig : (fun τ : ℝ => -2 * τ / T) =O[𝓝[≥] 0] fun τ => τ / T :=
    (isBigO_const_mul_self (-2) (fun τ : ℝ => τ / T) _).congr_left fun τ => by ring
  have h := ((hexp.comp_tendsto hlin).trans_isBigO hbig).const_mul_left (-(M.Rinf μ (θ t)))
  refine h.congr' ?_ EventuallyEq.rfl
  filter_upwards [self_mem_nhdsWithin] with τ hτ
  rw [(s1_closed_form hC8 M μ θ T t hA).1 τ hτ]
  simp only [Function.comp_apply]
  ring

/-- Step 3 (supplied). "Since `T > 0`, `−2τ/T → −∞` as `τ → ∞`, so
`e^{−2τ/T} → 0` and, by step 1, `R_glob(τ) → (1 − 0) R_∞ = R_∞`." -/
theorem s3_large_delay (hC8 : C08.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ : ℝ → Ω → κ → ℝ) (T t : ℝ)
    (hA : ∀ τ, 0 ≤ τ → TemporalAssumption μ θ T t τ) :
    Tendsto (fun τ => M.Rglob μ (θ (t - τ)) (θ t)) atTop (𝓝 (M.Rinf μ (θ t))) := by
  have hT : 0 < T := (hA 0 le_rfl).T_pos
  have hlin : Tendsto (fun τ : ℝ => -2 * τ / T) atTop atBot := by
    have h : Tendsto (fun τ : ℝ => 2 / T * τ) atTop atTop :=
      tendsto_id.const_mul_atTop (by positivity)
    refine (tendsto_neg_atTop_atBot.comp h).congr fun τ => ?_
    simp only [Function.comp_apply]
    ring
  have hexp : Tendsto (fun τ : ℝ => exp (-2 * τ / T)) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp hlin
  have h := ((tendsto_const_nhds (x := (1 : ℝ))).sub hexp).mul_const (M.Rinf μ (θ t))
  rw [sub_zero, one_mul] at h
  refine h.congr' ?_
  filter_upwards [eventually_ge_atTop 0] with τ hτ
  exact ((s1_closed_form hC8 M μ θ T t hA).1 τ hτ).symm

/-- The sentence after Corollary (OU_stale_regret). -/
theorem main (hC8 : C08.Statement) : C08c.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t hA
  exact ⟨(s1_closed_form hC8 M μ θ T t hA).2, s2_small_delay hC8 M μ θ T t hA,
    s3_large_delay hC8 M μ θ T t hA⟩

end TinaV2.C08c.A1
