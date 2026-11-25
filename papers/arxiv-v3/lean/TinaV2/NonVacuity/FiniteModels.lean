import Mathlib.Probability.Independence.InfinitePi
import TinaV2.Assembly
import TinaV2.Routine.Aggregate
import TinaV2.Routine.RadiusCalculus
import TinaV2.Routine.RadiusInfo

/-! # Non-vacuity witnesses for Tiers A–C (finite, analytic, and discrete-time models)

This module supplies kernel-checked existential witnesses proving that the
universally quantified hypothesis bundles of all non-continuum claims in `TinaV2`
(Tiers A–C: `C1`–`C3.b`, `C4.b`, `C5`, `C5.b`, `C6.b`–`C8.c`, `C10`–`C16`,
`C19.b`, `C20`) are simultaneously satisfiable by concrete, non-degenerate
objects using only the three standard Lean axioms (`propext`, `Classical.choice`,
`Quot.sound`).

Kept outside `TinaV2/Proofs/` so the SQLite ledger stays 1:1 with manuscript
claims; imported by `TinaV2.lean` and axiom-audited by `tools/verify_release.py`.

Contents:
1. Analytic curves (`SmoothCurves` + `StrictAntiOn (balanceGap ...)`) with both
   an interior-crossing witness and left/right boundary-sticking witnesses
   (`C15`, `C15.b`, `C15.c`, `C16`, resolving parked item `C15.c/f1/d3`), plus
   closed-form radius regime witnesses (`C16`, `C19.b`, `C20`).
2. Aggregate-coupling model (`n = 2`, `q = γ = σ = 1`) and independent
   Rademacher states on `Bool × Bool` (`C12`, `C13`, `C13.b`, `C13.c`, `C6.b`,
   `C6.c`), together with a two-sensor finite model attaining `η₀ = 1/2`.
3. Hilbert projection, cost-centering, and degenerate-normalization witnesses on
   `Bool × Bool` (`C1`–`C3.b`, `C5`, `C5.b`).
4. A non-degenerate continuous-delay `TemporalAssumption` and two-sensor process
   witness holding for all `τ ≥ 0` (`C7`, `C7.b`, `C8`, `C8.c`, `C10`, `C10.b`,
   `C11`, `C13`, `C14`).
5. A non-degenerate discrete-time stationary AR(1) process witness on `ℤ → Bool`
   (`C4.b`).

The remaining continuum Gaussian / pathwise-continuous field witnesses (`C4.c`,
`C9`, `C17.b`, `C18`, `C19`) are deferred to Phase 5 (`GaussianModels.lean`). -/

noncomputable section

namespace TinaV2.NonVacuity.FiniteModels

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology

/-! ## 1. Analytic curves and radius regimes (`C15`, `C15.b`, `C15.c`, `C16`, `C19.b`, `C20`) -/

/-- Concrete exponential omission curve `η(r) = ½ e^{−2r}`. -/
def expEta (r : ℝ) : ℝ := (1 / 2 : ℝ) * Real.exp (-2 * r)

/-- Concrete unit-speed linear latency curve `τ(r) = r`. -/
def linTau (r : ℝ) : ℝ := r

private theorem hasDerivAt_expEta (r : ℝ) :
    HasDerivAt expEta (-Real.exp (-2 * r)) r := by
  have h1 : HasDerivAt (fun x : ℝ => (-2 : ℝ) * x) (-2 : ℝ) r := by
    simpa using (hasDerivAt_id r).const_mul (-2 : ℝ)
  have h2 : HasDerivAt (fun x : ℝ => Real.exp (-2 * x)) (Real.exp (-2 * r) * (-2)) r :=
    h1.exp
  have h3 : HasDerivAt expEta ((1 / 2 : ℝ) * (Real.exp (-2 * r) * (-2))) r :=
    h2.const_mul (1 / 2 : ℝ)
  convert h3 using 1
  ring

private theorem expEta_lt_one {r : ℝ} (hr : 0 ≤ r) : expEta r < 1 := by
  unfold expEta
  have hexp : Real.exp (-2 * r) ≤ 1 := Real.exp_le_one_iff.mpr (by linarith)
  linarith

private theorem hasDerivAt_log_one_sub_expEta {r : ℝ} (hr : 0 ≤ r) :
    HasDerivAt (fun x => Real.log (1 - expEta x)) (Real.exp (-2 * r) / (1 - expEta r)) r := by
  have hsub : HasDerivAt (fun x => 1 - expEta x) (Real.exp (-2 * r)) r := by
    have h := (hasDerivAt_const r (1 : ℝ)).sub (hasDerivAt_expEta r)
    rw [zero_sub, neg_neg] at h
    exact h
  exact hsub.log (sub_pos.mpr (expEta_lt_one hr)).ne'

theorem smoothCurves_expEta_linTau : SmoothCurves expEta linTau 1 where
  D_pos := by norm_num
  τ_contDiffOn := contDiffOn_id
  η_contDiffOn := by
    unfold expEta
    exact (contDiff_const.mul (Real.contDiff_exp.comp (contDiff_const.mul contDiff_id))).contDiffOn
  τ_deriv_nonneg := by
    intro r hr
    have hu : UniqueDiffWithinAt ℝ (Icc (0 : ℝ) 1) r :=
      uniqueDiffOn_Icc (by norm_num : (0 : ℝ) < 1) r hr
    rw [show derivWithin linTau (Icc 0 1) r = 1 from
      (hasDerivAt_id r).hasDerivWithinAt.derivWithin hu]
    norm_num
  η_deriv_nonpos := by
    intro r hr
    have hu : UniqueDiffWithinAt ℝ (Icc (0 : ℝ) 1) r :=
      uniqueDiffOn_Icc (by norm_num : (0 : ℝ) < 1) r hr
    rw [(hasDerivAt_expEta r).hasDerivWithinAt.derivWithin hu]
    linarith [Real.exp_pos (-2 * r)]
  η_range := by
    intro r hr
    exact ⟨by unfold expEta; positivity, expEta_lt_one hr.1⟩

private theorem balanceGap_expEta_scaled (α T : ℝ) {r : ℝ} (hr : r ∈ Icc (0 : ℝ) 1) :
    balanceGap expEta (fun x => α * linTau x) T 1 r =
      Real.exp (-2 * r) / (1 - expEta r) - 2 * α / T := by
  unfold balanceGap
  have hu : UniqueDiffWithinAt ℝ (Icc (0 : ℝ) 1) r :=
    uniqueDiffOn_Icc (by norm_num : (0 : ℝ) < 1) r hr
  have hlog : derivWithin (fun x => Real.log (1 - expEta x)) (Icc 0 1) r =
      Real.exp (-2 * r) / (1 - expEta r) :=
    (hasDerivAt_log_one_sub_expEta hr.1).hasDerivWithinAt.derivWithin hu
  have htau : derivWithin (fun x => α * linTau x) (Icc 0 1) r = α := by
    have h : HasDerivAt (fun x : ℝ => α * x) α r := by
      simpa using (hasDerivAt_id r).const_mul α
    exact h.hasDerivWithinAt.derivWithin hu
  rw [hlog, htau]

theorem strictAntiOn_balanceGap_expEta (α T : ℝ) :
    StrictAntiOn (balanceGap expEta (fun x => α * linTau x) T 1) (Icc 0 1) := by
  intro r₁ hr₁ r₂ hr₂ hlt
  rw [balanceGap_expEta_scaled α T hr₁, balanceGap_expEta_scaled α T hr₂]
  have hd₁ : 0 < 1 - expEta r₁ := sub_pos.mpr (expEta_lt_one hr₁.1)
  have hd₂ : 0 < 1 - expEta r₂ := sub_pos.mpr (expEta_lt_one hr₂.1)
  have hexp : Real.exp (-2 * r₂) < Real.exp (-2 * r₁) := Real.exp_lt_exp.mpr (by linarith)
  have hfrac : Real.exp (-2 * r₂) / (1 - expEta r₂) < Real.exp (-2 * r₁) / (1 - expEta r₁) := by
    rw [div_lt_div_iff₀ hd₂ hd₁]
    unfold expEta
    nlinarith
  linarith

private theorem exp_neg_two_lt_quarter : Real.exp (-2 : ℝ) < 1 / 4 := by
  have h1 : (2 : ℝ) < Real.exp 1 := by
    have := Real.add_one_lt_exp (by norm_num : (1 : ℝ) ≠ 0)
    linarith
  have h2 : (4 : ℝ) < Real.exp 2 := by
    have hmul : Real.exp (1 : ℝ) * Real.exp 1 = Real.exp 2 := by
      rw [← Real.exp_add]; norm_num
    nlinarith
  rw [Real.exp_neg]
  have hpos : (0 : ℝ) < Real.exp 2 := Real.exp_pos 2
  rw [inv_lt_comm₀ hpos (by norm_num : (0 : ℝ) < 1 / 4)]
  linarith

private theorem one_sixteenth_le_exp_neg_two : (1 / 16 : ℝ) ≤ Real.exp (-2 : ℝ) := by
  have h1 : (1 / 2 : ℝ) ≤ Real.exp (-1 / 2 : ℝ) := by
    have := Real.add_one_le_exp (-1 / 2 : ℝ)
    linarith
  have h2 : (1 / 4 : ℝ) ≤ Real.exp (-1 : ℝ) := by
    have hmul : Real.exp (-1 / 2 : ℝ) * Real.exp (-1 / 2 : ℝ) = Real.exp (-1 : ℝ) := by
      rw [← Real.exp_add]; norm_num
    nlinarith
  have hmul2 : Real.exp (-1 : ℝ) * Real.exp (-1 : ℝ) = Real.exp (-2 : ℝ) := by
    rw [← Real.exp_add]; norm_num
  nlinarith

/-- Non-vacuity witness for `C15`, `C15.b`, `C15.c`, and `C16` (interior crossing):
`η(r) = ½ e^{−2r}`, `τ(r) = r`, `D = 1`, `T = 4` satisfies `SmoothCurves`,
`StrictAntiOn (balanceGap ...) (Icc 0 1)`, and admits a unique interior maximizer
`r⋆ ∈ (0, 1)` where `balanceGap = 0`. -/
theorem exists_smoothCurves_interior_crossing :
    ∃ (η τ : ℝ → ℝ) (T D rstar : ℝ),
      0 < T ∧ SmoothCurves η τ D ∧
      StrictAntiOn (balanceGap η τ T D) (Icc 0 D) ∧
      rstar ∈ Ioo 0 D ∧
      balanceGap η τ T D rstar = 0 ∧
      IsMaxOn (gain η τ T) (Icc 0 D) rstar ∧
      (∀ r ∈ Icc 0 D, r ≠ rstar → gain η τ T r < gain η τ T rstar) := by
  have hanti : StrictAntiOn (balanceGap expEta linTau 4 1) (Icc 0 1) := by
    have h := strictAntiOn_balanceGap_expEta 1 4
    simpa [one_mul] using h
  have h0 : 0 < balanceGap expEta linTau 4 1 0 := by
    have h := balanceGap_expEta_scaled 1 4 (by norm_num : (0 : ℝ) ∈ Icc 0 1)
    simp only [one_mul] at h
    rw [h]
    unfold expEta
    norm_num
  have h1 : balanceGap expEta linTau 4 1 1 < 0 := by
    have h := balanceGap_expEta_scaled 1 4 (by norm_num : (1 : ℝ) ∈ Icc 0 1)
    simp only [one_mul] at h
    rw [h]
    have hu : Real.exp (-2 * (1 : ℝ)) < 1 / 4 := by simpa using exp_neg_two_lt_quarter
    have hd : 0 < 1 - expEta 1 := sub_pos.mpr (expEta_lt_one (by norm_num))
    have hfrac : Real.exp (-2 * (1 : ℝ)) / (1 - expEta 1) < 1 / 2 := by
      rw [div_lt_iff₀ hd]
      unfold expEta
      linarith
    linarith
  have hC15b := TinaV2.Assembly.C15b expEta linTau 4 1 (by norm_num)
    smoothCurves_expEta_linTau hanti
  obtain ⟨rstar, hrstar_mem, hgap, _, hstrict⟩ := hC15b.2.2 h0 h1
  refine ⟨expEta, linTau, 4, 1, rstar, by norm_num, smoothCurves_expEta_linTau, hanti,
    hrstar_mem, hgap, ?_, hstrict⟩
  intro r hr
  show gain expEta linTau 4 r ≤ gain expEta linTau 4 rstar
  by_cases heq : r = rstar
  · rw [heq]
  · exact (hstrict r hr heq).le

/-- Non-vacuity witness for `C15.c` (comparative statics & boundary sticking,
resolving parked item `C15.c/f1/d3`): increasing `T` can leave the unique
maximizer pinned at the left boundary `0` (`T = 1/2 → 1`) or at the right
boundary `D = 1` (`T = 100 → 200`). -/
theorem exists_smoothCurves_boundary_sticking :
    ∃ (η τ₀ : ℝ → ℝ) (D : ℝ),
      SmoothCurves η τ₀ D ∧
      (∀ α T : ℝ, 0 < α → 0 < T →
        StrictAntiOn (balanceGap η (fun r => α * τ₀ r) T D) (Icc 0 D)) ∧
      (∃ T₁ T₂ : ℝ, 0 < T₁ ∧ T₁ < T₂ ∧
        (∀ r ∈ Icc 0 D, r ≠ 0 → gain η τ₀ T₁ r < gain η τ₀ T₁ 0) ∧
        (∀ r ∈ Icc 0 D, r ≠ 0 → gain η τ₀ T₂ r < gain η τ₀ T₂ 0)) ∧
      (∃ T₃ T₄ : ℝ, 0 < T₃ ∧ T₃ < T₄ ∧
        (∀ r ∈ Icc 0 D, r ≠ D → gain η τ₀ T₃ r < gain η τ₀ T₃ D) ∧
        (∀ r ∈ Icc 0 D, r ≠ D → gain η τ₀ T₄ r < gain η τ₀ T₄ D)) := by
  refine ⟨expEta, linTau, 1, smoothCurves_expEta_linTau,
    fun α T _ _ => strictAntiOn_balanceGap_expEta α T, ?_, ?_⟩
  · -- Pinned at `r = 0` for `T₁ = 1/2 < T₂ = 1`
    refine ⟨(1 / 2 : ℝ), (1 : ℝ), by norm_num, by norm_num, ?_, ?_⟩
    · have hanti : StrictAntiOn (balanceGap expEta linTau (1 / 2) 1) (Icc 0 1) := by
        simpa [one_mul] using strictAntiOn_balanceGap_expEta 1 (1 / 2)
      have h0 : balanceGap expEta linTau (1 / 2) 1 0 ≤ 0 := by
        have h := balanceGap_expEta_scaled 1 (1 / 2) (by norm_num : (0 : ℝ) ∈ Icc 0 1)
        simp only [one_mul] at h
        rw [h]; unfold expEta; norm_num
      exact (TinaV2.Assembly.C15b expEta linTau (1 / 2) 1 (by norm_num)
        smoothCurves_expEta_linTau hanti).1 h0
    · have hanti : StrictAntiOn (balanceGap expEta linTau 1 1) (Icc 0 1) := by
        simpa [one_mul] using strictAntiOn_balanceGap_expEta 1 1
      have h0 : balanceGap expEta linTau 1 1 0 ≤ 0 := by
        have h := balanceGap_expEta_scaled 1 1 (by norm_num : (0 : ℝ) ∈ Icc 0 1)
        simp only [one_mul] at h
        rw [h]; unfold expEta; norm_num
      exact (TinaV2.Assembly.C15b expEta linTau 1 1 (by norm_num)
        smoothCurves_expEta_linTau hanti).1 h0
  · -- Pinned at `r = D = 1` for `T₃ = 100 < T₄ = 200`
    have hu : (1 / 16 : ℝ) ≤ Real.exp (-2 * (1 : ℝ)) := by simpa using one_sixteenth_le_exp_neg_two
    have hd : 0 < 1 - expEta 1 := sub_pos.mpr (expEta_lt_one (by norm_num))
    have hfrac : (1 / 16 : ℝ) ≤ Real.exp (-2 * (1 : ℝ)) / (1 - expEta 1) := by
      rw [le_div_iff₀ hd]
      unfold expEta
      have hpos : (0 : ℝ) < Real.exp (-2 * (1 : ℝ)) := Real.exp_pos _
      nlinarith
    refine ⟨(100 : ℝ), (200 : ℝ), by norm_num, by norm_num, ?_, ?_⟩
    · have hanti : StrictAntiOn (balanceGap expEta linTau 100 1) (Icc 0 1) := by
        simpa [one_mul] using strictAntiOn_balanceGap_expEta 1 100
      have h1 : 0 ≤ balanceGap expEta linTau 100 1 1 := by
        have h := balanceGap_expEta_scaled 1 100 (by norm_num : (1 : ℝ) ∈ Icc 0 1)
        simp only [one_mul] at h
        rw [h]; linarith
      exact (TinaV2.Assembly.C15b expEta linTau 100 1 (by norm_num)
        smoothCurves_expEta_linTau hanti).2.1 h1
    · have hanti : StrictAntiOn (balanceGap expEta linTau 200 1) (Icc 0 1) := by
        simpa [one_mul] using strictAntiOn_balanceGap_expEta 1 200
      have h1 : 0 ≤ balanceGap expEta linTau 200 1 1 := by
        have h := balanceGap_expEta_scaled 1 200 (by norm_num : (1 : ℝ) ∈ Icc 0 1)
        simp only [one_mul] at h
        rw [h]; linarith
      exact (TinaV2.Assembly.C15b expEta linTau 200 1 (by norm_num)
        smoothCurves_expEta_linTau hanti).2.1 h1

/-- Non-vacuity witness for closed-form radius hypotheses (`C16`, `C19.b`, `C20`):
positive interior regime for both `expRadius` and `canonRadius`. -/
theorem exists_expRadius_and_canonRadius_regimes :
    ∃ (η0 ℓc ℓs v T : ℝ),
      0 < η0 ∧ η0 < 1 ∧ 0 < ℓc ∧ 0 < ℓs ∧ 0 < v ∧ 0 < T ∧
      1 < η0 * (1 + v * T / ℓc) ∧ 0 < expRadius η0 ℓc v T ∧
      2 * ℓs < v * T ∧ 0 < canonRadius ℓc ℓs v T := by
  refine ⟨1 / 2, 1, 1, 1, 4, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num, ?_, by norm_num, ?_⟩
  · have h := (TinaV2.Assembly.C16 (1 / 2) 1 1 4 (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)).2.1
    exact h.mpr (by norm_num)
  · rw [RadiusCalculus.canonRadius_of_regime (by norm_num) (by norm_num) (by norm_num)]
    have hlog : 0 < Real.log (((1 : ℝ) + 1 * 4) / (1 + 2 * 1)) :=
      Real.log_pos (by norm_num)
    positivity

/-! ## 2. Uniform Rademacher space on `Bool × Bool` & aggregate-coupling model (`C12`, `C13`, `C13.b`, `C13.c`) -/

/-- Rademacher random variable `true ↦ 1`, `false ↦ −1`. -/
def rad (b : Bool) : ℝ := if b then 1 else -1

/-- Uniform probability measure on `Bool`. -/
def radMeasure : Measure Bool :=
  (1 / 2 : ENNReal) • Measure.dirac true + (1 / 2 : ENNReal) • Measure.dirac false

instance instIsProbabilityMeasureRadMeasure : IsProbabilityMeasure radMeasure := by
  refine ⟨?_⟩
  simp [radMeasure, ENNReal.inv_two_add_inv_two]

theorem integral_radMeasure (f : Bool → ℝ) :
    ∫ b, f b ∂radMeasure = (f true + f false) / 2 := by
  have : IsFiniteMeasure ((1 / 2 : ENNReal) • Measure.dirac true) := ⟨by simp⟩
  have : IsFiniteMeasure ((1 / 2 : ENNReal) • Measure.dirac false) := ⟨by simp⟩
  have h1 : Integrable f ((1 / 2 : ENNReal) • Measure.dirac true) :=
    Integrable.of_finite
  have h2 : Integrable f ((1 / 2 : ENNReal) • Measure.dirac false) :=
    Integrable.of_finite
  unfold radMeasure
  rw [integral_add_measure h1 h2, integral_smul_measure, integral_smul_measure,
    integral_dirac, integral_dirac]
  simp only [ENNReal.toReal_div, ENNReal.toReal_one, ENNReal.toReal_ofNat, smul_eq_mul]
  ring

/-- Uniform probability measure on `Bool × Bool`. -/
def rad2Measure : Measure (Bool × Bool) := radMeasure.prod radMeasure

instance instIsProbabilityMeasureRad2Measure : IsProbabilityMeasure rad2Measure := by
  unfold rad2Measure; infer_instance

theorem integral_rad2Measure (f : Bool × Bool → ℝ) :
    ∫ ω, f ω ∂rad2Measure =
      (f (true, true) + f (true, false) + f (false, true) + f (false, false)) / 4 := by
  unfold rad2Measure
  rw [MeasureTheory.integral_prod f Integrable.of_finite]
  simp only [integral_radMeasure]
  ring

/-- Independent Rademacher state vector `θ(ω) = (rad ω.1, rad ω.2)` on `Bool × Bool`. -/
def radState (ω : Bool × Bool) : Fin 2 → ℝ := ![rad ω.1, rad ω.2]

private theorem rad2Measure_preimage_fst (A : Set Bool) :
    rad2Measure (Prod.fst ⁻¹' A) = radMeasure A := by
  have h : Prod.fst ⁻¹' A = A ×ˢ (Set.univ : Set Bool) := by ext ⟨a, b⟩; simp
  rw [h, rad2Measure, Measure.prod_prod, measure_univ, mul_one]

private theorem rad2Measure_preimage_snd (B : Set Bool) :
    rad2Measure (Prod.snd ⁻¹' B) = radMeasure B := by
  have h : Prod.snd ⁻¹' B = (Set.univ : Set Bool) ×ˢ B := by ext ⟨a, b⟩; simp
  rw [h, rad2Measure, Measure.prod_prod, measure_univ, one_mul]

theorem iIndepFun_radState : iIndepFun (fun i ω => radState ω i) rad2Measure := by
  rw [iIndepFun_iff_measure_inter_preimage_eq_mul]
  intro S sets _
  by_cases h0 : (0 : Fin 2) ∈ S <;> by_cases h1 : (1 : Fin 2) ∈ S
  · have hS : S = {0, 1} := by
      ext i; fin_cases i <;> simp [h0, h1]
    subst hS
    have hinter : (⋂ i ∈ ({0, 1} : Finset (Fin 2)), (fun ω => radState ω i) ⁻¹' sets i) =
        (rad ⁻¹' sets 0) ×ˢ (rad ⁻¹' sets 1) := by
      ext ⟨a, b⟩; simp [radState]
    rw [hinter, Finset.prod_pair (by decide : (0 : Fin 2) ≠ 1)]
    have hfst : (fun ω : Bool × Bool => radState ω 0) ⁻¹' sets 0 = Prod.fst ⁻¹' (rad ⁻¹' sets 0) :=
      rfl
    have hsnd : (fun ω : Bool × Bool => radState ω 1) ⁻¹' sets 1 = Prod.snd ⁻¹' (rad ⁻¹' sets 1) :=
      rfl
    rw [hfst, hsnd, rad2Measure_preimage_fst, rad2Measure_preimage_snd, rad2Measure,
      Measure.prod_prod]
  · have hS : S = {0} := by
      ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp
  · have hS : S = {1} := by
      ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp
  · have hS : S = ∅ := by
      ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp

theorem aggregateState_radState : AggregateState rad2Measure radState 1 where
  measurable := measurable_of_finite _
  memLp := by
    refine MemLp.of_bound (measurable_of_finite _).aestronglyMeasurable 1 (Eventually.of_forall ?_)
    rintro ⟨b₁, b₂⟩
    rw [pi_norm_le_iff_of_nonneg (by norm_num)]
    intro i
    fin_cases i <;> cases b₁ <;> cases b₂ <;> simp [radState, rad]
  indep := iIndepFun_radState
  mean_zero := by
    intro i
    fin_cases i <;> rw [integral_rad2Measure] <;> simp [radState, rad]
  variance := by
    intro i
    fin_cases i <;> rw [integral_rad2Measure] <;> simp [radState, rad] <;> norm_num

/-- `Q = I + 11ᵀ` on `Fin 2` is positive definite. -/
theorem posDef_aggQ2 : (aggQ 2 1 1).PosDef := by
  refine Matrix.PosDef.of_dotProduct_mulVec_pos ?_ ?_
  · ext i j
    fin_cases i <;> fin_cases j <;> simp [aggQ]
  · intro x hx
    have hq := Aggregate.quad_aggQ 2 1 1 x
    have hstar : star x ⬝ᵥ aggQ 2 1 1 *ᵥ x = quad (aggQ 2 1 1) x := rfl
    rw [hstar, hq, Fin.sum_univ_two, Fin.sum_univ_two]
    have hne : x 0 ≠ 0 ∨ x 1 ≠ 0 := by
      by_contra h
      push Not at h
      exact hx (funext fun i => by fin_cases i <;> [exact h.1; exact h.2])
    rcases hne with h0 | h1
    · have : 0 < x 0 ^ 2 := sq_pos_of_ne_zero h0
      nlinarith [sq_nonneg (x 1), sq_nonneg (x 0 + x 1)]
    · have : 0 < x 1 ^ 2 := sq_pos_of_ne_zero h1
      nlinarith [sq_nonneg (x 0), sq_nonneg (x 0 + x 1)]

/-- Concrete 2-agent aggregate-coupling model (`q = 1, γ = 1`) on the complete
graph `K₂`. -/
def aggModel2 : Model (Fin 2) (Fin 2) (Fin 2) where
  G := ⊤
  owner := id
  actor := id
  Q := aggQ 2 1 1
  K := (aggQ 2 1 1)⁻¹
  Q_posDef := posDef_aggQ2

theorem isAggregateModel_aggModel2 : IsAggregateModel aggModel2 1 1 where
  Q_eq := rfl
  K_eq := rfl
  owner_eq := rfl
  actor_eq := rfl

theorem connected_aggModel2 : aggModel2.G.Connected :=
  SimpleGraph.connected_top

/-- Non-vacuity witness for the aggregate-coupling claims (`C12`, `C13.b`,
`C13.c`, `C6.b`, `C6.c`): `n = 2`, `q = γ = σ = 1` over `Bool × Bool`, with
`R_∞ = 2/3 > 0`, `η_S(0) = 1/4 ∈ (0, 1)`, and a connected communication graph. -/
theorem exists_aggregateModel_and_state :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ) (now : Ω → Fin 2 → ℝ),
      IsAggregateModel M 1 1 ∧ AggregateState μ now 1 ∧
      M.G.Connected ∧
      0 < M.Rinf μ now ∧
      0 < M.etaS μ 0 now ∧ M.etaS μ 0 now < 1 := by
  have hC12 := TinaV2.Assembly.C12 2 1 1 1 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) aggModel2 isAggregateModel_aggModel2 rad2Measure radState
    aggregateState_radState
  have hRinf : aggModel2.Rinf rad2Measure radState = 2 / 3 := by
    rw [hC12.2.1]; unfold aggRinf; norm_num
  have hEta : aggModel2.etaS rad2Measure 0 radState = 1 / 4 := by
    rw [hC12.2.2.2]; unfold aggEta; norm_num
  refine ⟨aggModel2, Bool × Bool, inferInstance, rad2Measure, inferInstance, radState,
    isAggregateModel_aggModel2, aggregateState_radState, connected_aggModel2,
    by rw [hRinf]; norm_num, by rw [hEta]; norm_num, by rw [hEta]; norm_num⟩

/-! ## 3. Two-sensor finite model (`η₀ = 1/2`), Hilbert projection & cost witnesses (`C1`–`C3.b`, `C5`, `C5.b`, `C6.b`, `C6.c`) -/

/-- Concrete 2-agent model mirroring the two-sensor example: `Q = I₂`,
`K = [[1/2, 1/2], [1/2, 1/2]]`, `G = K₂`. Both agents track `(θ₀ + θ₁)/2`. -/
def twoSensorModel : Model (Fin 2) (Fin 2) (Fin 2) where
  G := ⊤
  owner := id
  actor := id
  Q := 1
  K := Matrix.of fun _ _ => (1 / 2 : ℝ)
  Q_posDef := Matrix.PosDef.one

private theorem twoSensorModel_target (ω : Bool × Bool) (i : Fin 2) :
    twoSensorModel.target radState ω i = (rad ω.1 + rad ω.2) / 2 := by
  fin_cases i <;>
    simp [Model.target, twoSensorModel, Matrix.mulVec, dotProduct, Fin.sum_univ_two, radState] <;>
    ring

/-- Finite 2-agent model on `Bool × Bool` with `R_∞ = 1/2 > 0`, `R_loc = 1/4`,
and `η_S(0) = 1/2 ∈ (0, 1)`, matching the two-sensor example (`C11`, `C6.b`,
`C6.c`). -/
theorem exists_twoSensor_finite_model :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ) (now : Ω → Fin 2 → ℝ),
      M.G.Connected ∧
      Measurable now ∧ MemLp now 2 μ ∧ (∀ k, ∫ ω, now ω k ∂μ = 0) ∧
      M.Rinf μ now = 1 / 2 ∧
      M.Rloc μ now = 1 / 4 ∧
      M.etaS μ 0 now = 1 / 2 ∧
      0 < M.Rinf μ now ∧ 0 < M.etaS μ 0 now ∧ M.etaS μ 0 now < 1 := by
  have hQ1 : twoSensorModel.Q = 1 := rfl
  have hRinf : twoSensorModel.Rinf rad2Measure radState = 1 / 2 := by
    rw [Model.Rinf]
    simp_rw [hQ1, quad, Matrix.one_mulVec, dotProduct, Fin.sum_univ_two, twoSensorModel_target]
    rw [integral_rad2Measure]
    simp [rad]
    norm_num
  have hRloc : twoSensorModel.Rloc rad2Measure radState = 1 / 4 := by
    apply le_antisymm
    · -- Upper bound from the optimal local rule `g_i(θ_i) = θ_i / 2`
      let g : Rule twoSensorModel.actor (fun i => twoSensorModel.Scope 0 i → ℝ) :=
        fun c o => o ⟨c, Aggregate.self_mem_nbhd_zero twoSensorModel rfl c⟩ / 2
      have hg : Admissible rad2Measure (twoSensorModel.obs 0 radState) g :=
        ⟨fun c => (measurable_pi_apply _).div_const 2,
          MemLp.of_bound (measurable_of_finite _).aestronglyMeasurable 1 (Eventually.of_forall fun ⟨b₁, b₂⟩ => by
            rw [pi_norm_le_iff_of_nonneg (by norm_num)]
            intro i
            fin_cases i <;> cases b₁ <;> cases b₂ <;>
              simp [jointAction, g, Model.obs, Model.view, radState, rad] <;> norm_num)⟩
      calc twoSensorModel.Rloc rad2Measure radState
          ≤ excessCost rad2Measure twoSensorModel.Q (twoSensorModel.target radState)
              (jointAction g (twoSensorModel.obs 0 radState)) :=
            regret_le rad2Measure twoSensorModel.Q_posDef _ _ hg
        _ = 1 / 4 := by
            rw [excessCost]
            simp_rw [hQ1, quad, Matrix.one_mulVec, dotProduct, Fin.sum_univ_two, Pi.sub_apply,
              twoSensorModel_target]
            rw [integral_rad2Measure]
            simp [jointAction, g, Model.obs, Model.view, radState, rad]
            norm_num
    · -- Lower bound over all admissible local rules
      unfold Model.Rloc Model.R regret
      refine le_ciInf fun ⟨g, hg⟩ => ?_
      obtain ⟨φ, _, hφ⟩ := Aggregate.exists_local_rule_eq twoSensorModel rfl rfl hg.1
      rw [excessCost]
      have hj : ∀ ω c, jointAction g (twoSensorModel.obs 0 radState) ω c = φ c (radState ω c) :=
        fun ω c => hφ (radState ω) c
      simp_rw [hQ1, quad, Matrix.one_mulVec, dotProduct, Fin.sum_univ_two, Pi.sub_apply,
        hj, twoSensorModel_target]
      rw [integral_rad2Measure]
      simp only [radState, Matrix.cons_val_zero, Matrix.cons_val_one, rad,
        ↓reduceIte, Bool.false_eq_true]
      nlinarith [sq_nonneg (φ 0 1 - 1 / 2), sq_nonneg (φ 0 (-1) + 1 / 2),
        sq_nonneg (φ 1 1 - 1 / 2), sq_nonneg (φ 1 (-1) + 1 / 2)]
  have hEta : twoSensorModel.etaS rad2Measure 0 radState = 1 / 2 := by
    rw [Model.etaS, ← Model.Rloc, hRloc, hRinf]; norm_num
  refine ⟨twoSensorModel, Bool × Bool, inferInstance, rad2Measure, inferInstance, radState,
    SimpleGraph.connected_top, aggregateState_radState.measurable, aggregateState_radState.memLp,
    aggregateState_radState.mean_zero, hRinf, hRloc, hEta,
    by rw [hRinf]; norm_num, by rw [hEta]; norm_num, by rw [hEta]; norm_num⟩

/-- Non-vacuity witness for the Hilbert projection, normal-equation, common-
information, quadratic-cost, and centering hypotheses (`C1`, `C1.b`, `C1.c`,
`C2`, `C3`, `C5`, `C5.b`) on `Bool × Bool`. -/
theorem exists_projection_and_cost_bundle :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (m0 : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (𝒢 𝒢' : Fin 2 → MeasurableSpace Ω) (Z : Ω → Fin 2 → ℝ)
      (b : Ω → Fin 2 → ℝ) (c : Ω → ℝ) (B : Matrix (Fin 2) (Fin 2) ℝ) (b₀ : Fin 2 → ℝ),
      M.Q.PosDef ∧
      (∀ i, 𝒢 i ≤ 𝒢' i) ∧ (∀ i, 𝒢' i ≤ m0) ∧
      Measurable Z ∧ MemLp b 2 μ ∧ Integrable c μ ∧
      M.K = M.Q⁻¹ * B ∧
      (∀ ω, M.Q⁻¹ *ᵥ (B *ᵥ b ω + b₀) = M.target b ω) ∧
      0 < M.Rinf μ b := by
  let 𝒢 : Fin 2 → MeasurableSpace (Bool × Bool) :=
    fun i => MeasurableSpace.comap (aggModel2.obs 0 radState i) inferInstance
  let 𝒢' : Fin 2 → MeasurableSpace (Bool × Bool) := fun _ => inferInstance
  have hC12 := TinaV2.Assembly.C12 2 1 1 1 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) aggModel2 isAggregateModel_aggModel2 rad2Measure radState
    aggregateState_radState
  have hRinf : 0 < aggModel2.Rinf rad2Measure radState := by
    rw [hC12.2.1]; unfold aggRinf; norm_num
  refine ⟨aggModel2, Bool × Bool, inferInstance, rad2Measure, inferInstance,
    𝒢, 𝒢', radState, radState, fun _ => 0, 1, 0,
    aggModel2.Q_posDef, fun i => (measurable_of_finite (aggModel2.obs 0 radState i)).comap_le,
    fun _ => le_rfl,
    aggregateState_radState.measurable, aggregateState_radState.memLp, integrable_zero _ _ _,
    by simp [aggModel2], fun _ => by simp [Model.target, aggModel2], hRinf⟩

/-- Non-vacuity witness for degenerate normalization `R_∞ = 0` (`C3.b`). -/
theorem exists_degenerate_normalization_witness :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ) (now : Ω → Fin 2 → ℝ),
      Measurable now ∧ MemLp now 2 μ ∧ M.Rinf μ now = 0 := by
  refine ⟨aggModel2, Bool × Bool, inferInstance, rad2Measure, inferInstance, 0,
    measurable_const, MemLp.zero, ?_⟩
  simp [Model.Rinf, Model.target, quad]

/-! ## 4. Non-degenerate continuous-delay `TemporalAssumption` & two-sensor witness (`C7`–`C8.c`, `C10`–`C11`, `C13`, `C14`) -/

/-- Uniform probability measure on `(0, 1]`. -/
def unifMeasure : Measure ℝ := volume.restrict (Ioc (0 : ℝ) 1)

instance instIsProbabilityMeasureUnifMeasure : IsProbabilityMeasure unifMeasure := by
  refine ⟨?_⟩
  simp [unifMeasure, Real.volume_Ioc]

/-- Single-sensor probability space `ℝ × (Bool × Bool)` carrying a uniform clock
`u ∈ (0, 1]` and two independent Rademacher draws `(b₀, b₁)`. -/
abbrev SingleSpace := ℝ × (Bool × Bool)

/-- Product measure `Unif(0, 1] ⊗ Rad ⊗ Rad` on `SingleSpace`. -/
def singleMeasure : Measure SingleSpace := unifMeasure.prod rad2Measure

instance instIsProbabilityMeasureSingleMeasure : IsProbabilityMeasure singleMeasure := by
  unfold singleMeasure; infer_instance

/-- Random-refresh Rademacher process at timescale `T = 1`: equals `rad b₀` for
`s ≥ 0` or `u ≤ e^s`, and refreshes to an independent copy `rad b₁` when
`s < 0` and `e^s < u`. -/
def singleProc (s : ℝ) (ω : SingleSpace) : ℝ :=
  if s < 0 ∧ Real.exp s < ω.1 then rad ω.2.2 else rad ω.2.1

private theorem measurable_singleProc (s : ℝ) : Measurable (singleProc s) := by
  unfold singleProc
  have hset : MeasurableSet {ω : SingleSpace | s < 0 ∧ Real.exp s < ω.1} := by
    by_cases hs : s < 0
    · have heq : {ω : SingleSpace | s < 0 ∧ Real.exp s < ω.1} = Prod.fst ⁻¹' Ioi (Real.exp s) := by
        ext ω; simp [hs]
      rw [heq]
      exact (measurableSet_Ioi (a := Real.exp s)).preimage measurable_fst
    · have heq : {ω : SingleSpace | s < 0 ∧ Real.exp s < ω.1} = ∅ := by
        ext ω; simp [hs]
      rw [heq]
      exact MeasurableSet.empty
  exact Measurable.ite hset
    ((measurable_of_finite rad).comp (measurable_snd.comp measurable_snd))
    ((measurable_of_finite rad).comp (measurable_fst.comp measurable_snd))

private theorem abs_singleProc (s : ℝ) (ω : SingleSpace) : |singleProc s ω| = 1 := by
  unfold singleProc
  split_ifs <;> cases ω.2.1 <;> cases ω.2.2 <;> simp [rad]

private theorem memLp_singleProc (s : ℝ) : MemLp (singleProc s) 2 singleMeasure :=
  MemLp.of_bound (measurable_singleProc s).aestronglyMeasurable 1 (Eventually.of_forall fun ω => by
    rw [Real.norm_eq_abs, abs_singleProc])

private theorem singleProc_map_eq (s : ℝ) :
    singleMeasure.map (singleProc s) = radMeasure.map rad := by
  ext A hA
  rw [Measure.map_apply (measurable_singleProc s) hA,
    Measure.map_apply (measurable_of_finite rad) hA]
  unfold singleMeasure
  rw [Measure.prod_apply ((measurable_singleProc s) hA)]
  have hslice : ∀ u : ℝ,
      rad2Measure (Prod.mk u ⁻¹' (singleProc s ⁻¹' A)) = radMeasure (rad ⁻¹' A) := by
    intro u
    by_cases h : s < 0 ∧ Real.exp s < u
    · have heq : Prod.mk u ⁻¹' (singleProc s ⁻¹' A) = Prod.snd ⁻¹' (rad ⁻¹' A) := by
        ext ⟨b₀, b₁⟩; simp [singleProc, h]
      rw [heq, rad2Measure_preimage_snd]
    · have heq : Prod.mk u ⁻¹' (singleProc s ⁻¹' A) = Prod.fst ⁻¹' (rad ⁻¹' A) := by
        ext ⟨b₀, b₁⟩; simp [singleProc, h]
      rw [heq, rad2Measure_preimage_fst]
  simp [hslice]

private theorem identDistrib_singleProc (s s' : ℝ) :
    IdentDistrib (singleProc s) (singleProc s') singleMeasure singleMeasure where
  aemeasurable_fst := (measurable_singleProc s).aemeasurable
  aemeasurable_snd := (measurable_singleProc s').aemeasurable
  map_eq := by rw [singleProc_map_eq, singleProc_map_eq]

private theorem integral_singleProc (s : ℝ) :
    ∫ ω, singleProc s ω ∂singleMeasure = 0 := by
  have h := (identDistrib_singleProc s 0).integral_eq
  rw [h]
  have h0 : singleProc 0 = fun ω : SingleSpace => rad ω.2.1 := by
    funext ω; simp [singleProc]
  have hi : Integrable (fun ω : SingleSpace => rad ω.2.1) (unifMeasure.prod rad2Measure) := by
    simpa [h0, singleMeasure] using (memLp_singleProc 0).integrable one_le_two
  rw [h0, singleMeasure, MeasureTheory.integral_prod _ hi]
  simp [integral_rad2Measure, rad]

private theorem integral_sq_singleProc (s : ℝ) :
    ∫ ω, singleProc s ω ^ 2 ∂singleMeasure = 1 := by
  have hsq : (fun ω => singleProc s ω ^ 2) = fun _ => (1 : ℝ) := by
    funext ω
    have habs := abs_singleProc s ω
    have : singleProc s ω ^ 2 = |singleProc s ω| ^ 2 := (sq_abs _).symm
    rw [this, habs]; norm_num
  rw [hsq, integral_const]
  simp

private theorem setIntegral_singleProc_innovation {τ : ℝ} (hτ : 0 ≤ τ)
    {B : Set ℝ} (hB : MeasurableSet B) :
    ∫ ω in singleProc (-τ) ⁻¹' B,
      (singleProc 0 ω - Real.exp (-τ) * singleProc (-τ) ω) ∂singleMeasure = 0 := by
  by_cases hτ0 : τ = 0
  · subst hτ0; simp
  have hτpos : 0 < τ := lt_of_le_of_ne hτ (Ne.symm hτ0)
  have hsneg : -τ < 0 := neg_lt_zero.mpr hτpos
  set a : ℝ := Real.exp (-τ)
  have ha0 : 0 < a := Real.exp_pos _
  have ha1 : a < 1 := Real.exp_lt_one_iff.mpr hsneg
  let f : SingleSpace → ℝ := (singleProc (-τ) ⁻¹' B).indicator
    (fun ω => singleProc 0 ω - a * singleProc (-τ) ω)
  have hf_int : Integrable f singleMeasure := by
    have hdiff : Integrable (fun ω => singleProc 0 ω - a * singleProc (-τ) ω) singleMeasure :=
      ((memLp_singleProc 0).integrable one_le_two).sub
        (((memLp_singleProc (-τ)).integrable one_le_two).const_mul a)
    exact hdiff.indicator (measurable_singleProc (-τ) hB)
  rw [← integral_indicator (measurable_singleProc (-τ) hB)]
  change ∫ ω, f ω ∂singleMeasure = 0
  rw [singleMeasure, MeasureTheory.integral_prod f hf_int]
  classical
  let cB : ℝ := (if (1 : ℝ) ∈ B then 1 else 0) - (if (-1 : ℝ) ∈ B then 1 else 0)
  have hinner : ∀ u : ℝ, ∫ p, f (u, p) ∂rad2Measure =
      if a < u then -(a / 2) * cB else ((1 - a) / 2) * cB := by
    intro u
    rw [integral_rad2Measure]
    have ha_eq : Real.exp (-τ) = a := rfl
    by_cases hu : a < u <;> by_cases h1 : (1 : ℝ) ∈ B <;> by_cases hm1 : (-1 : ℝ) ∈ B <;>
      simp [f, singleProc, hsneg, ha_eq, hu, rad, cB, h1, hm1] <;> ring
  simp_rw [hinner]
  have hpiece : (fun u : ℝ => if a < u then -(a / 2) * cB else ((1 - a) / 2) * cB) =
      fun u => (Ioi a).indicator (fun _ => -(a / 2) * cB) u +
        (Iic a).indicator (fun _ => ((1 - a) / 2) * cB) u := by
    funext u
    by_cases hu : a < u
    · simp [Set.indicator, hu, not_le.mpr hu]
    · simp [Set.indicator, hu, not_lt.mp hu]
  rw [hpiece, integral_add
    ((integrable_const _).indicator measurableSet_Ioi)
    ((integrable_const _).indicator measurableSet_Iic),
    integral_indicator measurableSet_Ioi, integral_indicator measurableSet_Iic,
    setIntegral_const, setIntegral_const]
  have hIoi : (unifMeasure (Ioi a)).toReal = 1 - a := by
    unfold unifMeasure
    rw [Measure.restrict_apply measurableSet_Ioi]
    have hset : Ioi a ∩ Ioc (0 : ℝ) 1 = Ioc a 1 := by
      ext u; simp only [mem_inter_iff, mem_Ioi, mem_Ioc]; constructor
      · rintro ⟨h1, _, h3⟩; exact ⟨h1, h3⟩
      · rintro ⟨h1, h2⟩; exact ⟨h1, lt_trans ha0 h1, h2⟩
    rw [hset, Real.volume_Ioc, ENNReal.toReal_ofReal (by linarith)]
  have hIic : (unifMeasure (Iic a)).toReal = a := by
    unfold unifMeasure
    rw [Measure.restrict_apply measurableSet_Iic]
    have hset : Iic a ∩ Ioc (0 : ℝ) 1 = Ioc (0 : ℝ) a := by
      ext u; simp only [mem_inter_iff, mem_Iic, mem_Ioc]; constructor
      · rintro ⟨h1, h2, _⟩; exact ⟨h2, h1⟩
      · rintro ⟨h1, h2⟩; exact ⟨h2, h1, le_trans h2 ha1.le⟩
    rw [hset, Real.volume_Ioc, sub_zero, ENNReal.toReal_ofReal ha0.le]
  rw [Measure.real_def, Measure.real_def, hIoi, hIic, smul_eq_mul, smul_eq_mul]
  ring

private theorem condExp_singleProc_eq {τ : ℝ} (hτ : 0 ≤ τ) :
    condExp (MeasurableSpace.comap (singleProc (-τ)) inferInstance) singleMeasure (singleProc 0)
      =ᵐ[singleMeasure] fun ω => Real.exp (-τ) * singleProc (-τ) ω := by
  have hm : MeasurableSpace.comap (singleProc (-τ)) inferInstance ≤
      (inferInstance : MeasurableSpace SingleSpace) :=
    (measurable_singleProc (-τ)).comap_le
  have hg_meas : StronglyMeasurable[MeasurableSpace.comap (singleProc (-τ)) inferInstance]
      (fun ω => Real.exp (-τ) * singleProc (-τ) ω) :=
    ((comap_measurable (singleProc (-τ))).const_mul (Real.exp (-τ))).stronglyMeasurable
  have hg_int : Integrable (fun ω => Real.exp (-τ) * singleProc (-τ) ω) singleMeasure :=
    ((memLp_singleProc (-τ)).integrable one_le_two).const_mul _
  have hf_int : Integrable (singleProc 0) singleMeasure :=
    (memLp_singleProc 0).integrable one_le_two
  refine (ae_eq_condExp_of_forall_setIntegral_eq hm hf_int (fun s _ _ => hg_int.integrableOn)
    ?_ hg_meas.aestronglyMeasurable).symm
  intro s hs _
  rcases hs with ⟨B, hB, rfl⟩
  have hzero := setIntegral_singleProc_innovation hτ hB
  rw [integral_sub hf_int.integrableOn hg_int.integrableOn] at hzero
  linarith

/-- Two-sensor product probability space `SingleSpace × SingleSpace`. -/
abbrev TempSpace := SingleSpace × SingleSpace

/-- Product measure for two independent random-refresh Rademacher sensors. -/
def tempMeasure : Measure TempSpace := singleMeasure.prod singleMeasure

instance instIsProbabilityMeasureTempMeasure : IsProbabilityMeasure tempMeasure := by
  unfold tempMeasure; infer_instance

/-- First sensor process `X_s`. -/
def tempX (s : ℝ) (ω : TempSpace) : ℝ := singleProc s ω.1

/-- Second sensor process `Y_s`. -/
def tempY (s : ℝ) (ω : TempSpace) : ℝ := singleProc s ω.2

/-- 2-agent stationary state process `θ_s = (X_s, Y_s)` on `TempSpace`. -/
def tempTheta (s : ℝ) (ω : TempSpace) : Fin 2 → ℝ := ![tempX s ω, tempY s ω]

private theorem measurable_tempX (s : ℝ) : Measurable (tempX s) :=
  (measurable_singleProc s).comp measurable_fst

private theorem measurable_tempY (s : ℝ) : Measurable (tempY s) :=
  (measurable_singleProc s).comp measurable_snd

private theorem measurable_tempTheta (s : ℝ) : Measurable (tempTheta s) := by
  refine measurable_pi_lambda _ fun i => ?_
  fin_cases i
  · exact measurable_tempX s
  · exact measurable_tempY s

private theorem memLp_tempX (s : ℝ) : MemLp (tempX s) 2 tempMeasure :=
  MemLp.of_bound (measurable_tempX s).aestronglyMeasurable 1 (Eventually.of_forall fun ω => by
    rw [Real.norm_eq_abs, tempX, abs_singleProc])

private theorem memLp_tempY (s : ℝ) : MemLp (tempY s) 2 tempMeasure :=
  MemLp.of_bound (measurable_tempY s).aestronglyMeasurable 1 (Eventually.of_forall fun ω => by
    rw [Real.norm_eq_abs, tempY, abs_singleProc])

private theorem memLp_tempTheta (s : ℝ) : MemLp (tempTheta s) 2 tempMeasure :=
  memLp_pi_iff.2 fun i => by
    fin_cases i
    · exact memLp_tempX s
    · exact memLp_tempY s

private theorem tempMeasure_preimage_fst (A : Set SingleSpace) :
    tempMeasure (Prod.fst ⁻¹' A) = singleMeasure A := by
  have h : Prod.fst ⁻¹' A = A ×ˢ (Set.univ : Set SingleSpace) := by ext ⟨a, b⟩; simp
  rw [h, tempMeasure, Measure.prod_prod, measure_univ, mul_one]

private theorem tempMeasure_preimage_snd (B : Set SingleSpace) :
    tempMeasure (Prod.snd ⁻¹' B) = singleMeasure B := by
  have h : Prod.snd ⁻¹' B = (Set.univ : Set SingleSpace) ×ˢ B := by ext ⟨a, b⟩; simp
  rw [h, tempMeasure, Measure.prod_prod, measure_univ, one_mul]

private theorem indepFun_tempX_tempY_process :
    IndepFun (fun ω (s : ℝ) => tempX s ω) (fun ω (s : ℝ) => tempY s ω) tempMeasure := by
  have hfst_snd : IndepFun (Prod.fst : TempSpace → SingleSpace) Prod.snd tempMeasure := by
    rw [indepFun_iff_measure_inter_preimage_eq_mul]
    intro s t _ _
    have hinter : Prod.fst ⁻¹' s ∩ Prod.snd ⁻¹' t = s ×ˢ t := by ext ⟨a, b⟩; simp
    rw [hinter, tempMeasure_preimage_fst s, tempMeasure_preimage_snd t,
      tempMeasure, Measure.prod_prod]
  have hm : Measurable (fun (u : SingleSpace) (s : ℝ) => singleProc s u) :=
    measurable_pi_lambda _ measurable_singleProc
  exact hfst_snd.comp hm hm

private theorem identDistrib_tempTheta (s s' : ℝ) :
    IdentDistrib (tempTheta s) (tempTheta s') tempMeasure tempMeasure := by
  have hprod : IdentDistrib (Prod.map (singleProc s) (singleProc s))
      (Prod.map (singleProc s') (singleProc s')) tempMeasure tempMeasure := by
    refine ⟨((measurable_singleProc s).prodMap (measurable_singleProc s)).aemeasurable,
      ((measurable_singleProc s').prodMap (measurable_singleProc s')).aemeasurable, ?_⟩
    unfold tempMeasure
    rw [← Measure.map_prod_map _ _ (measurable_singleProc s) (measurable_singleProc s),
      ← Measure.map_prod_map _ _ (measurable_singleProc s') (measurable_singleProc s'),
      singleProc_map_eq, singleProc_map_eq]
  have hvec : Measurable (fun p : ℝ × ℝ => ![p.1, p.2]) := by
    refine measurable_pi_lambda _ fun i => ?_
    fin_cases i <;> [exact measurable_fst; exact measurable_snd]
  exact hprod.comp hvec

private theorem aggregateState_tempTheta (s : ℝ) :
    AggregateState tempMeasure (tempTheta s) 1 where
  measurable := measurable_tempTheta s
  memLp := memLp_tempTheta s
  indep := by
    rw [iIndepFun_iff_measure_inter_preimage_eq_mul]
    intro S sets _
    by_cases h0 : (0 : Fin 2) ∈ S <;> by_cases h1 : (1 : Fin 2) ∈ S
    · have hS : S = {0, 1} := by ext i; fin_cases i <;> simp [h0, h1]
      subst hS
      have hinter : (⋂ i ∈ ({0, 1} : Finset (Fin 2)), (fun ω => tempTheta s ω i) ⁻¹' sets i) =
          (singleProc s ⁻¹' sets 0) ×ˢ (singleProc s ⁻¹' sets 1) := by
        ext ⟨a, b⟩; simp [tempTheta, tempX, tempY]
      rw [hinter, Finset.prod_pair (by decide : (0 : Fin 2) ≠ 1)]
      have hfst : (fun ω : TempSpace => tempTheta s ω 0) ⁻¹' sets 0 =
          Prod.fst ⁻¹' (singleProc s ⁻¹' sets 0) := rfl
      have hsnd : (fun ω : TempSpace => tempTheta s ω 1) ⁻¹' sets 1 =
          Prod.snd ⁻¹' (singleProc s ⁻¹' sets 1) := rfl
      rw [hfst, hsnd, tempMeasure_preimage_fst, tempMeasure_preimage_snd,
        tempMeasure, Measure.prod_prod]
    · have hS : S = {0} := by ext i; fin_cases i <;> simp [h0, h1]
      subst hS; simp
    · have hS : S = {1} := by ext i; fin_cases i <;> simp [h0, h1]
      subst hS; simp
    · have hS : S = ∅ := by ext i; fin_cases i <;> simp [h0, h1]
      subst hS; simp
  mean_zero := by
    intro i
    fin_cases i
    · change ∫ ω, tempX s ω ∂(singleMeasure.prod singleMeasure) = 0
      rw [MeasureTheory.integral_prod _ ((memLp_tempX s).integrable one_le_two)]
      simp [tempX, integral_singleProc]
    · change ∫ ω, tempY s ω ∂(singleMeasure.prod singleMeasure) = 0
      rw [MeasureTheory.integral_prod _ ((memLp_tempY s).integrable one_le_two)]
      simp [tempY, integral_singleProc]
  variance := by
    intro i
    fin_cases i
    · change ∫ ω, tempX s ω ^ 2 ∂(singleMeasure.prod singleMeasure) = 1 ^ 2
      rw [MeasureTheory.integral_prod _ ((memLp_tempX s).integrable_sq)]
      simp [tempX, integral_sq_singleProc]
    · change ∫ ω, tempY s ω ^ 2 ∂(singleMeasure.prod singleMeasure) = 1 ^ 2
      rw [MeasureTheory.integral_prod _ ((memLp_tempY s).integrable_sq)]
      simp [tempY, integral_sq_singleProc]

private theorem predictionRule_tempTheta {τ : ℝ} (hτ : 0 ≤ τ) :
    PredictionRule tempMeasure (Real.exp (-τ / 1)) (tempTheta (0 - τ)) (tempTheta 0) := by
  unfold PredictionRule
  rw [div_one, zero_sub]
  set a : ℝ := Real.exp (-τ)
  have hm : MeasurableSpace.comap (tempTheta (-τ)) MeasurableSpace.pi ≤
      (inferInstance : MeasurableSpace TempSpace) :=
    (measurable_tempTheta (-τ)).comap_le
  have hf_int : Integrable (fun ω => tempTheta 0 ω - a • tempTheta (-τ) ω) tempMeasure :=
    ((memLp_tempTheta 0).sub ((memLp_tempTheta (-τ)).const_smul a)).integrable one_le_two
  have hzero_sm : StronglyMeasurable[MeasurableSpace.comap (tempTheta (-τ)) MeasurableSpace.pi]
      (0 : TempSpace → Fin 2 → ℝ) := stronglyMeasurable_zero
  refine (ae_eq_condExp_of_forall_setIntegral_eq hm hf_int (fun _ _ _ => integrableOn_zero)
    ?_ hzero_sm.aestronglyMeasurable).symm
  intro s hs _
  rw [integral_zero]
  rcases hs with ⟨B, hB, rfl⟩
  rw [← integral_indicator (measurable_tempTheta (-τ) hB)]
  funext i
  have hproj := (ContinuousLinearMap.proj (R := ℝ) i).integral_comp_comm
    (hf_int.indicator (measurable_tempTheta (-τ) hB))
  simp only [ContinuousLinearMap.proj_apply] at hproj
  rw [Pi.zero_apply, ← hproj]
  have hind : (fun ω => (tempTheta (-τ) ⁻¹' B).indicator
      (fun ω => tempTheta 0 ω - a • tempTheta (-τ) ω) ω i) =
      (tempTheta (-τ) ⁻¹' B).indicator
        (fun ω => tempTheta 0 ω i - a * tempTheta (-τ) ω i) := by
    funext ω
    by_cases hω : ω ∈ tempTheta (-τ) ⁻¹' B <;> simp [hω]
  rw [hind]
  have hf_i : Integrable ((tempTheta (-τ) ⁻¹' B).indicator
      (fun ω => tempTheta 0 ω i - a * tempTheta (-τ) ω i)) tempMeasure := by
    have hci : Integrable (fun ω => tempTheta 0 ω i - a * tempTheta (-τ) ω i) tempMeasure :=
      ((memLp_pi_iff.1 (memLp_tempTheta 0) i).integrable one_le_two).sub
        (((memLp_pi_iff.1 (memLp_tempTheta (-τ)) i).integrable one_le_two).const_mul a)
    exact hci.indicator (measurable_tempTheta (-τ) hB)
  fin_cases i
  · -- Coordinate 0: integrate over `ω.2` outside, `ω.1` inside
    symm
    rw [tempMeasure, MeasureTheory.integral_prod_symm _ hf_i]
    refine integral_eq_zero_of_ae (Eventually.of_forall fun ω₂ => ?_)
    dsimp only
    let B₁ : Set ℝ := {x : ℝ | ![x, singleProc (-τ) ω₂] ∈ B}
    have hB₁ : MeasurableSet B₁ := by
      have hm1 : Measurable (fun x : ℝ => ![x, singleProc (-τ) ω₂]) := by
        refine measurable_pi_lambda _ fun j => ?_
        fin_cases j <;> [exact measurable_id; exact measurable_const]
      exact hm1 hB
    have heq : (fun ω₁ => (tempTheta (-τ) ⁻¹' B).indicator
        (fun ω => tempTheta 0 ω 0 - a * tempTheta (-τ) ω 0) (ω₁, ω₂)) =
        (singleProc (-τ) ⁻¹' B₁).indicator
          (fun ω₁ => singleProc 0 ω₁ - a * singleProc (-τ) ω₁) := by
      funext ω₁
      by_cases h : ![singleProc (-τ) ω₁, singleProc (-τ) ω₂] ∈ B <;>
        simp [B₁, tempTheta, tempX, tempY, h]
    change ∫ ω₁, (tempTheta (-τ) ⁻¹' B).indicator
      (fun ω => tempTheta 0 ω 0 - a * tempTheta (-τ) ω 0) (ω₁, ω₂) ∂singleMeasure = 0
    rw [heq, integral_indicator (measurable_singleProc (-τ) hB₁)]
    exact setIntegral_singleProc_innovation hτ hB₁
  · -- Coordinate 1: integrate over `ω.1` outside, `ω.2` inside
    symm
    rw [tempMeasure, MeasureTheory.integral_prod _ hf_i]
    refine integral_eq_zero_of_ae (Eventually.of_forall fun ω₁ => ?_)
    dsimp only
    let B₂ : Set ℝ := {y : ℝ | ![singleProc (-τ) ω₁, y] ∈ B}
    have hB₂ : MeasurableSet B₂ := by
      have hm2 : Measurable (fun y : ℝ => ![singleProc (-τ) ω₁, y]) := by
        refine measurable_pi_lambda _ fun j => ?_
        fin_cases j <;> [exact measurable_const; exact measurable_id]
      exact hm2 hB
    have heq : (fun ω₂ => (tempTheta (-τ) ⁻¹' B).indicator
        (fun ω => tempTheta 0 ω 1 - a * tempTheta (-τ) ω 1) (ω₁, ω₂)) =
        (singleProc (-τ) ⁻¹' B₂).indicator
          (fun ω₂ => singleProc 0 ω₂ - a * singleProc (-τ) ω₂) := by
      funext ω₂
      by_cases h : ![singleProc (-τ) ω₁, singleProc (-τ) ω₂] ∈ B <;>
        simp [B₂, tempTheta, tempX, tempY, h]
    change ∫ ω₂, (tempTheta (-τ) ⁻¹' B).indicator
      (fun ω => tempTheta 0 ω 1 - a * tempTheta (-τ) ω 1) (ω₁, ω₂) ∂singleMeasure = 0
    rw [heq, integral_indicator (measurable_singleProc (-τ) hB₂)]
    exact setIntegral_singleProc_innovation hτ hB₂

theorem temporalAssumption_tempTheta {τ : ℝ} (hτ : 0 ≤ τ) :
    TemporalAssumption tempMeasure tempTheta 1 0 τ where
  stationary := ⟨measurable_tempTheta, memLp_tempTheta, identDistrib_tempTheta⟩
  T_pos := by norm_num
  τ_nonneg := hτ
  prediction := predictionRule_tempTheta hτ

private theorem condExp_tempX_eq {τ : ℝ} (hτ : 0 ≤ τ) :
    condExp (MeasurableSpace.comap (tempX (0 - τ)) inferInstance) tempMeasure (tempX 0)
      =ᵐ[tempMeasure] fun ω => Real.exp (-τ / 1) * tempX (0 - τ) ω := by
  rw [div_one, zero_sub]
  have hm : MeasurableSpace.comap (tempX (-τ)) inferInstance ≤
      (inferInstance : MeasurableSpace TempSpace) :=
    (measurable_tempX (-τ)).comap_le
  have hf_int : Integrable (tempX 0) tempMeasure := (memLp_tempX 0).integrable one_le_two
  have hg_int : Integrable (fun ω => Real.exp (-τ) * tempX (-τ) ω) tempMeasure :=
    ((memLp_tempX (-τ)).integrable one_le_two).const_mul _
  have hg_meas : StronglyMeasurable[MeasurableSpace.comap (tempX (-τ)) inferInstance]
      (fun ω => Real.exp (-τ) * tempX (-τ) ω) :=
    ((comap_measurable (tempX (-τ))).const_mul _).stronglyMeasurable
  refine (ae_eq_condExp_of_forall_setIntegral_eq hm hf_int (fun _ _ _ => hg_int.integrableOn)
    ?_ hg_meas.aestronglyMeasurable).symm
  intro s hs _
  rcases hs with ⟨B, hB, rfl⟩
  have hsub : ∫ ω in tempX (-τ) ⁻¹' B, (tempX 0 ω - Real.exp (-τ) * tempX (-τ) ω) ∂tempMeasure = 0 := by
    rw [← integral_indicator (measurable_tempX (-τ) hB)]
    have hi : Integrable ((tempX (-τ) ⁻¹' B).indicator
        (fun ω => tempX 0 ω - Real.exp (-τ) * tempX (-τ) ω)) tempMeasure :=
      (hf_int.sub hg_int).indicator (measurable_tempX (-τ) hB)
    rw [tempMeasure, MeasureTheory.integral_prod_symm _ hi]
    refine integral_eq_zero_of_ae (Eventually.of_forall fun ω₂ => ?_)
    dsimp only
    have heq : (fun ω₁ => (tempX (-τ) ⁻¹' B).indicator
        (fun ω => tempX 0 ω - Real.exp (-τ) * tempX (-τ) ω) (ω₁, ω₂)) =
        (singleProc (-τ) ⁻¹' B).indicator
          (fun ω₁ => singleProc 0 ω₁ - Real.exp (-τ) * singleProc (-τ) ω₁) := rfl
    rw [heq, integral_indicator (measurable_singleProc (-τ) hB)]
    exact setIntegral_singleProc_innovation hτ hB
  rw [integral_sub hf_int.integrableOn hg_int.integrableOn] at hsub
  linarith

private theorem condExp_tempY_eq {τ : ℝ} (hτ : 0 ≤ τ) :
    condExp (MeasurableSpace.comap (tempY (0 - τ)) inferInstance) tempMeasure (tempY 0)
      =ᵐ[tempMeasure] fun ω => Real.exp (-τ / 1) * tempY (0 - τ) ω := by
  rw [div_one, zero_sub]
  have hm : MeasurableSpace.comap (tempY (-τ)) inferInstance ≤
      (inferInstance : MeasurableSpace TempSpace) :=
    (measurable_tempY (-τ)).comap_le
  have hf_int : Integrable (tempY 0) tempMeasure := (memLp_tempY 0).integrable one_le_two
  have hg_int : Integrable (fun ω => Real.exp (-τ) * tempY (-τ) ω) tempMeasure :=
    ((memLp_tempY (-τ)).integrable one_le_two).const_mul _
  have hg_meas : StronglyMeasurable[MeasurableSpace.comap (tempY (-τ)) inferInstance]
      (fun ω => Real.exp (-τ) * tempY (-τ) ω) :=
    ((comap_measurable (tempY (-τ))).const_mul _).stronglyMeasurable
  refine (ae_eq_condExp_of_forall_setIntegral_eq hm hf_int (fun _ _ _ => hg_int.integrableOn)
    ?_ hg_meas.aestronglyMeasurable).symm
  intro s hs _
  rcases hs with ⟨B, hB, rfl⟩
  have hsub : ∫ ω in tempY (-τ) ⁻¹' B, (tempY 0 ω - Real.exp (-τ) * tempY (-τ) ω) ∂tempMeasure = 0 := by
    rw [← integral_indicator (measurable_tempY (-τ) hB)]
    have hi : Integrable ((tempY (-τ) ⁻¹' B).indicator
        (fun ω => tempY 0 ω - Real.exp (-τ) * tempY (-τ) ω)) tempMeasure :=
      (hf_int.sub hg_int).indicator (measurable_tempY (-τ) hB)
    rw [tempMeasure, MeasureTheory.integral_prod _ hi]
    refine integral_eq_zero_of_ae (Eventually.of_forall fun ω₁ => ?_)
    dsimp only
    have heq : (fun ω₂ => (tempY (-τ) ⁻¹' B).indicator
        (fun ω => tempY 0 ω - Real.exp (-τ) * tempY (-τ) ω) (ω₁, ω₂)) =
        (singleProc (-τ) ⁻¹' B).indicator
          (fun ω₂ => singleProc 0 ω₂ - Real.exp (-τ) * singleProc (-τ) ω₂) := rfl
    rw [heq, integral_indicator (measurable_singleProc (-τ) hB)]
    exact setIntegral_singleProc_innovation hτ hB
  rw [integral_sub hf_int.integrableOn hg_int.integrableOn] at hsub
  linarith

/-- Non-vacuity witness for the temporal composition, stale-global, crossover,
aggregate-crossover, and discrete-radius claims (`C7`, `C7.b`, `C8`, `C8.c`,
`C10`, `C10.b`, `C13`, `C14`): a non-degenerate 2-agent aggregate model
satisfying `TemporalAssumption` for *all* delays `τ ≥ 0`, with `R_∞ = 2/3 > 0`,
`η_S(0) = 1/4 ∈ (0, 1)`, and strictly positive crossover threshold `ρ⋆ > 0`. -/
theorem exists_temporal_and_crossover_witness :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ) (θ : ℝ → Ω → Fin 2 → ℝ) (T t : ℝ),
      IsAggregateModel M 1 1 ∧
      AggregateState μ (θ t) 1 ∧
      (∀ τ : ℝ, 0 ≤ τ → TemporalAssumption μ θ T t τ) ∧
      0 < M.Rinf μ (θ t) ∧
      0 < M.etaS μ 0 (θ t) ∧ M.etaS μ 0 (θ t) < 1 ∧
      0 < rhoStar (M.etaS μ 0 (θ t)) := by
  have hC12 := TinaV2.Assembly.C12 2 1 1 1 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) aggModel2 isAggregateModel_aggModel2 tempMeasure (tempTheta 0)
    (aggregateState_tempTheta 0)
  have hRinf : aggModel2.Rinf tempMeasure (tempTheta 0) = 2 / 3 := by
    rw [hC12.2.1]; unfold aggRinf; norm_num
  have hEta : aggModel2.etaS tempMeasure 0 (tempTheta 0) = 1 / 4 := by
    rw [hC12.2.2.2]; unfold aggEta; norm_num
  have hRho : 0 < rhoStar (aggModel2.etaS tempMeasure 0 (tempTheta 0)) := by
    rw [hEta]; unfold rhoStar
    have : 0 < Real.log (1 / (1 - (1 / 4 : ℝ))) := Real.log_pos (by norm_num)
    positivity
  refine ⟨aggModel2, TempSpace, inferInstance, tempMeasure, inferInstance, tempTheta, 1, 0,
    isAggregateModel_aggModel2, aggregateState_tempTheta 0,
    fun τ hτ => temporalAssumption_tempTheta hτ,
    by rw [hRinf]; norm_num, by rw [hEta]; norm_num, by rw [hEta]; norm_num, hRho⟩

/-- Non-vacuity witness for the two-sensor example (`C11`) at strictly positive
delay `τ = 1 > (log 2)/2` (where fresh local strictly beats stale global). -/
theorem exists_twoSensor_process_witness :
    ∃ (Ω : Type) (_ : MeasurableSpace Ω) (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (X Y : ℝ → Ω → ℝ) (σ T t τ : ℝ),
      0 < σ ∧ 0 < T ∧ 0 < τ ∧
      (∀ s, Measurable (X s)) ∧ (∀ s, Measurable (Y s)) ∧
      (∀ s, MemLp (X s) 2 μ) ∧ (∀ s, MemLp (Y s) 2 μ) ∧
      (∀ s, ∫ ω, X s ω ∂μ = 0 ∧ ∫ ω, X s ω ^ 2 ∂μ = σ ^ 2) ∧
      (∀ s, ∫ ω, Y s ω ∂μ = 0 ∧ ∫ ω, Y s ω ^ 2 ∂μ = σ ^ 2) ∧
      IndepFun (fun ω (s : ℝ) => X s ω) (fun ω (s : ℝ) => Y s ω) μ ∧
      (∀ s s', IdentDistrib (X s) (X s') μ μ) ∧
      (∀ s s', IdentDistrib (Y s) (Y s') μ μ) ∧
      condExp (MeasurableSpace.comap (X (t - τ)) inferInstance) μ (X t)
        =ᵐ[μ] (fun ω => Real.exp (-τ / T) * X (t - τ) ω) ∧
      condExp (MeasurableSpace.comap (Y (t - τ)) inferInstance) μ (Y t)
        =ᵐ[μ] (fun ω => Real.exp (-τ / T) * Y (t - τ) ω) := by
  refine ⟨TempSpace, inferInstance, tempMeasure, inferInstance, tempX, tempY, 1, 1, 0, 1,
    by norm_num, by norm_num, by norm_num,
    measurable_tempX, measurable_tempY, memLp_tempX, memLp_tempY,
    fun s => ⟨(aggregateState_tempTheta s).mean_zero 0, (aggregateState_tempTheta s).variance 0⟩,
    fun s => ⟨(aggregateState_tempTheta s).mean_zero 1, (aggregateState_tempTheta s).variance 1⟩,
    indepFun_tempX_tempY_process,
    fun s s' => (identDistrib_tempTheta s s').comp (measurable_pi_apply 0),
    fun s s' => (identDistrib_tempTheta s s').comp (measurable_pi_apply 1),
    condExp_tempX_eq (by norm_num), condExp_tempY_eq (by norm_num)⟩

/-! ## 5. Stationary discrete-time AR(1) witness (`C4.b`) -/

/-- Bi-infinite product space `ℤ → Bool` for i.i.d. Rademacher innovations. -/
abbrev AR1Space := ℤ → Bool

/-- Product probability measure of i.i.d. Rademacher draws indexed by `ℤ`. -/
def ar1Measure : Measure AR1Space := Measure.infinitePi (fun _ : ℤ => radMeasure)

instance instIsProbabilityMeasureAr1Measure : IsProbabilityMeasure ar1Measure := by
  unfold ar1Measure; infer_instance

/-- Scalar 1-agent model (`Q = 1, K = 1`) for the AR(1) witness. -/
def scalarModel : Model (Fin 1) (Fin 1) (Fin 1) where
  G := ⊤
  owner := id
  actor := id
  Q := 1
  K := 1
  Q_posDef := Matrix.PosDef.one

/-- Innovation process `ε_s(ω) = rad(ω_s)`. -/
def ar1Eps (s : ℤ) (ω : AR1Space) : Fin 1 → ℝ := fun _ => rad (ω s)

/-- Stationary AR(1) process `θ_s(ω) = ∑_{k=0}^∞ (1/2)^k rad(ω_{s-k})`. -/
def ar1Theta (s : ℤ) (ω : AR1Space) : Fin 1 → ℝ :=
  fun _ => ∑' k : ℕ, (1 / 2 : ℝ) ^ k * rad (ω (s - k))

private theorem summable_ar1 (s : ℤ) (ω : AR1Space) :
    Summable (fun k : ℕ => (1 / 2 : ℝ) ^ k * rad (ω (s - k))) := by
  refine Summable.of_norm_bounded (g := fun k : ℕ => (1 / 2 : ℝ) ^ k)
    (summable_geometric_of_lt_one (by norm_num) (by norm_num)) fun k => ?_
  rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg (by positivity)]
  have hrad : |rad (ω (s - k))| = 1 := by cases ω (s - k) <;> simp [rad]
  rw [hrad, mul_one]

private theorem norm_ar1Theta_le (s : ℤ) (ω : AR1Space) : ‖ar1Theta s ω‖ ≤ 2 := by
  rw [pi_norm_le_iff_of_nonneg (by norm_num)]
  intro i
  rw [ar1Theta, Real.norm_eq_abs]
  calc |∑' k : ℕ, (1 / 2 : ℝ) ^ k * rad (ω (s - k))|
      ≤ ∑' k : ℕ, |(1 / 2 : ℝ) ^ k * rad (ω (s - k))| := by
        simpa [Real.norm_eq_abs] using norm_tsum_le_tsum_norm (summable_ar1 s ω).norm
    _ = ∑' k : ℕ, (1 / 2 : ℝ) ^ k := by
        congr 1; funext k
        rw [abs_mul, abs_of_nonneg (by positivity)]
        have hrad : |rad (ω (s - k))| = 1 := by cases ω (s - k) <;> simp [rad]
        rw [hrad, mul_one]
    _ = 2 := tsum_geometric_two

private theorem ar1Theta_succ (s : ℤ) (ω : AR1Space) :
    ar1Theta (s + 1) ω = (1 / 2 : ℝ) • ar1Theta s ω + ar1Eps (s + 1) ω := by
  funext i
  simp only [ar1Theta, ar1Eps, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  rw [(summable_ar1 (s + 1) ω).tsum_eq_zero_add]
  simp only [pow_zero, one_mul, Nat.cast_zero, sub_zero]
  have hshift : (fun k : ℕ => (1 / 2 : ℝ) ^ (k + 1) * rad (ω (s + 1 - ↑(k + 1)))) =
      fun k : ℕ => (1 / 2 : ℝ) * ((1 / 2 : ℝ) ^ k * rad (ω (s - k))) := by
    funext k
    have hidx : s + 1 - ((k + 1 : ℕ) : ℤ) = s - (k : ℤ) := by push_cast; ring
    rw [hidx, pow_succ']
    ring
  rw [hshift, tsum_mul_left, add_comm]

private theorem measurable_ar1Theta (s : ℤ) : Measurable (ar1Theta s) := by
  refine measurable_pi_lambda _ fun _ => Measurable.tsum fun k => ?_
  exact measurable_const.mul ((measurable_of_finite rad).comp (measurable_pi_apply (s - k)))

private theorem measurable_ar1Eps (s : ℤ) : Measurable (ar1Eps s) :=
  measurable_pi_lambda _ fun _ => (measurable_of_finite rad).comp (measurable_pi_apply s)

private theorem memLp_ar1Theta (s : ℤ) : MemLp (ar1Theta s) 2 ar1Measure :=
  MemLp.of_bound (measurable_ar1Theta s).aestronglyMeasurable 2
    (Eventually.of_forall (norm_ar1Theta_le s))

private theorem memLp_ar1Eps (s : ℤ) : MemLp (ar1Eps s) 2 ar1Measure :=
  MemLp.of_bound (measurable_ar1Eps s).aestronglyMeasurable 1 (Eventually.of_forall fun ω => by
    rw [pi_norm_le_iff_of_nonneg (by norm_num)]
    intro _
    cases h : ω s <;> simp [ar1Eps, rad, h])

private theorem identDistrib_ar1Theta (s t : ℤ) :
    IdentDistrib (ar1Theta s) (ar1Theta t) ar1Measure ar1Measure := by
  let shift : AR1Space → AR1Space := fun ω n => ω (n + (s - t))
  have hshift_meas : Measurable shift :=
    measurable_pi_lambda _ fun n => measurable_pi_apply (n + (s - t))
  have hmap : ar1Measure.map shift = ar1Measure := by
    unfold ar1Measure
    exact Measure.map_infinitePi_infinitePi_of_inj (f := fun n : ℤ => n + (s - t))
      (fun _ _ h => add_right_cancel h)
  have hcomp : ar1Theta s = ar1Theta t ∘ shift := by
    funext ω i
    simp only [Function.comp_apply, ar1Theta, shift]
    congr 1; funext k
    have hidx : t - (k : ℤ) + (s - t) = s - (k : ℤ) := by ring
    rw [hidx]
  refine ⟨(measurable_ar1Theta s).aemeasurable, (measurable_ar1Theta t).aemeasurable, ?_⟩
  rw [hcomp, ← Measure.map_map (measurable_ar1Theta t) hshift_meas, hmap]

@[instance_reducible]
private def ar1Coord (n : ℤ) : MeasurableSpace AR1Space :=
  MeasurableSpace.comap (fun ω : AR1Space => ω n) inferInstance

@[instance_reducible]
private def ar1Past (s : ℤ) : MeasurableSpace AR1Space :=
  ⨆ n ∈ {n : ℤ | n ≤ s}, ar1Coord n

private theorem ar1_condExp_eps_zero (s : ℤ) :
    ar1Measure[ar1Eps (s + 1) |
      ⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (ar1Theta u) MeasurableSpace.pi]
      =ᵐ[ar1Measure] 0 := by
  have hmCoord_le : ∀ n : ℤ, ar1Coord n ≤ (inferInstance : MeasurableSpace AR1Space) := fun n =>
    (measurable_pi_apply n : Measurable fun ω : AR1Space => ω n).comap_le
  have hG_meas : Measurable (fun (x : ℕ → Bool) (_ : Fin 1) =>
      ∑' k : ℕ, (1 / 2 : ℝ) ^ k * rad (x k)) :=
    measurable_pi_lambda _ fun _ => Measurable.tsum fun k =>
      measurable_const.mul ((measurable_of_finite rad).comp (measurable_pi_apply k))
  have htheta_le_past :
      (⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (ar1Theta u) MeasurableSpace.pi) ≤
        ar1Past s := by
    refine iSup_le fun ⟨u, hu⟩ => ?_
    have hH_meas : Measurable[ar1Past s] (fun (ω : AR1Space) (k : ℕ) => ω (u - k)) := by
      rw [@measurable_pi_iff AR1Space ℕ (fun _ => Bool) (ar1Past s) _ _]
      intro k
      have hle : u - (k : ℤ) ≤ s := by omega
      have hmk : ar1Coord (u - k) ≤ ar1Past s := le_iSup₂_of_le (u - k) hle le_rfl
      exact (comap_measurable (fun ω : AR1Space => ω (u - k))).mono hmk le_rfl
    exact (hG_meas.comp hH_meas).comap_le
  have hpast_le : ar1Past s ≤ (inferInstance : MeasurableSpace AR1Space) :=
    iSup₂_le fun n _ => hmCoord_le n
  have htheta_le :
      (⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (ar1Theta u) MeasurableSpace.pi) ≤
        (inferInstance : MeasurableSpace AR1Space) :=
    le_trans htheta_le_past hpast_le
  have hind_all : iIndep ar1Coord ar1Measure :=
    (iIndepFun_infinitePi (P := fun _ : ℤ => radMeasure) (X := fun _ b => b)
      (fun _ => measurable_id)).iIndep
  have hdisj : Disjoint ({s + 1} : Set ℤ) {n : ℤ | n ≤ s} := by
    rw [Set.disjoint_singleton_left]
    change ¬ (s + 1 ≤ s)
    omega
  have hind_sup : Indep (⨆ n ∈ ({s + 1} : Set ℤ), ar1Coord n) (ar1Past s) ar1Measure :=
    indep_iSup_of_disjoint hmCoord_le hind_all hdisj
  have hind_s : Indep (ar1Coord (s + 1)) (ar1Past s) ar1Measure := by
    simpa [iSup_singleton] using hind_sup
  have hind_theta :
      Indep (ar1Coord (s + 1))
        (⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (ar1Theta u) MeasurableSpace.pi)
        ar1Measure :=
    indep_of_indep_of_le_right hind_s htheta_le_past
  have heps_sm : StronglyMeasurable[ar1Coord (s + 1)] (ar1Eps (s + 1)) := by
    have hconst : Measurable (fun (b : Bool) (_ : Fin 1) => rad b) :=
      measurable_pi_lambda _ fun _ => measurable_of_finite rad
    exact (hconst.comp (comap_measurable (fun ω : AR1Space => ω (s + 1)))).stronglyMeasurable
  have hce := condExp_indep_eq (hmCoord_le (s + 1)) htheta_le heps_sm hind_theta
  have hint0 : ∫ ω, ar1Eps (s + 1) ω ∂ar1Measure = 0 := by
    funext i
    have hproj := (ContinuousLinearMap.proj (R := ℝ) i).integral_comp_comm
      ((memLp_ar1Eps (s + 1)).integrable one_le_two)
    simp only [ContinuousLinearMap.proj_apply] at hproj
    rw [Pi.zero_apply, ← hproj]
    change ∫ ω, rad (ω (s + 1)) ∂ar1Measure = 0
    have hmap : ar1Measure.map (fun ω : AR1Space => ω (s + 1)) = radMeasure :=
      Measure.infinitePi_map_eval (fun _ : ℤ => radMeasure) (s + 1)
    rw [← integral_map (measurable_pi_apply (s + 1)).aemeasurable
      (measurable_of_finite rad).aestronglyMeasurable, hmap, integral_radMeasure]
    simp [rad]
  filter_upwards [hce] with ω hω
  rw [hω, hint0]; rfl

/-- Non-vacuity witness for discrete-time stationary AR(1) (`C4.b`) with
`c = 1/2 ∈ (0, 1)` and strictly positive no-information regret `R_∞ > 0`. -/
theorem exists_stationary_ar1_witness :
    ∃ (M : Model (Fin 1) (Fin 1) (Fin 1)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ) (θ ε : ℤ → Ω → Fin 1 → ℝ) (c : ℝ),
      0 < c ∧ c < 1 ∧
      StationaryState μ θ ∧
      (∀ s, MemLp (ε s) 2 μ) ∧
      (∀ s ω, θ (s + 1) ω = c • θ s ω + ε (s + 1) ω) ∧
      (∀ s, μ[ε (s + 1) | ⨆ u : {u : ℤ // u ≤ s},
        MeasurableSpace.comap (θ u) MeasurableSpace.pi] =ᵐ[μ] 0) ∧
      0 < M.Rinf μ (θ 0) := by
  have hRinf : 0 < scalarModel.Rinf ar1Measure (ar1Theta 0) := by
    unfold Model.Rinf quad
    simp only [scalarModel, Model.target, Matrix.one_mulVec, dotProduct, Fin.sum_univ_one]
    have hsq_int : Integrable (fun ω => ar1Theta 0 ω 0 * ar1Theta 0 ω 0) ar1Measure :=
      (memLp_pi_iff.1 (memLp_ar1Theta 0) 0).integrable_mul (memLp_pi_iff.1 (memLp_ar1Theta 0) 0)
    -- On `E = {ω | ω 0 = true ∧ ω (-1) = true}`, `θ₀(ω) ≥ 1 + 1/2 - 1/2 = 1`,
    -- and `ar1Measure E = 1/4 > 0`.
    let E : Set AR1Space := {ω | ω 0 = true ∧ ω (-1) = true}
    have hE_meas : MeasurableSet E :=
      (measurableSet_singleton true |>.preimage (measurable_pi_apply 0)).inter
        (measurableSet_singleton true |>.preimage (measurable_pi_apply (-1)))
    have hE_bound : ∀ ω ∈ E, (1 : ℝ) ≤ ar1Theta 0 ω 0 * ar1Theta 0 ω 0 := by
      intro ω ⟨h0, hm1⟩
      have hge1 : (1 : ℝ) ≤ ar1Theta 0 ω 0 := by
        simp only [ar1Theta]
        rw [(summable_ar1 0 ω).tsum_eq_zero_add]
        have hs1 : Summable (fun k : ℕ => (1 / 2 : ℝ) ^ (k + 1) * rad (ω (0 - ↑(k + 1)))) :=
          (summable_ar1 0 ω).comp_injective (add_left_injective 1)
        rw [hs1.tsum_eq_zero_add]
        simp only [pow_zero, one_mul, Nat.cast_zero, sub_zero, zero_add, pow_one, Nat.cast_one,
          zero_sub, h0, hm1, rad, ↓reduceIte]
        have htail : |∑' k : ℕ, (1 / 2 : ℝ) ^ (k + 1 + 1) * rad (ω (-↑(k + 1 + 1)))| ≤ 1 / 2 := by
          have hs2 : Summable (fun k : ℕ => (1 / 2 : ℝ) ^ (k + 1 + 1) * rad (ω (-↑(k + 1 + 1)))) := by
            simpa only [Function.comp_def, zero_sub] using hs1.comp_injective (add_left_injective 1)
          calc |∑' k : ℕ, (1 / 2 : ℝ) ^ (k + 1 + 1) * rad (ω (-↑(k + 1 + 1)))|
              ≤ ∑' k : ℕ, |(1 / 2 : ℝ) ^ (k + 1 + 1) * rad (ω (-↑(k + 1 + 1)))| := by
                simpa [Real.norm_eq_abs] using norm_tsum_le_tsum_norm hs2.norm
            _ = ∑' k : ℕ, (1 / 4 : ℝ) * (1 / 2 : ℝ) ^ k := by
                congr 1; funext k
                rw [abs_mul, abs_of_nonneg (by positivity)]
                have hrad : |rad (ω (-↑(k + 1 + 1)))| = 1 := by
                  cases ω (-↑(k + 1 + 1)) <;> simp [rad]
                rw [hrad, mul_one, pow_succ', pow_succ']
                ring
            _ = (1 / 4 : ℝ) * ∑' k : ℕ, (1 / 2 : ℝ) ^ k := tsum_mul_left
            _ = 1 / 2 := by rw [tsum_geometric_two]; norm_num
        simp only [rad] at htail
        linarith [(abs_le.mp htail).1]
      nlinarith
    have hE_pos : (0 : ℝ) < (ar1Measure E).toReal := by
      have hmap := Measure.infinitePi_map_eval_prod (P := fun _ : ℤ => radMeasure)
        (by decide : (0 : ℤ) ≠ -1)
      have hE_eq : E = (fun ω : AR1Space => (ω 0, ω (-1))) ⁻¹' {(true, true)} := by
        ext ω; simp [E]
      have hmeas : ar1Measure E = (radMeasure.prod radMeasure) {(true, true)} := by
        rw [hE_eq, ← Measure.map_apply
          ((measurable_pi_apply 0).prodMk (measurable_pi_apply (-1)))
          (measurableSet_singleton _), ← hmap]; rfl
      have hpair : ({(true, true)} : Set (Bool × Bool)) = {true} ×ˢ {true} := by
        ext ⟨a, b⟩; simp
      rw [hmeas, hpair, Measure.prod_prod]
      have htrue : radMeasure {true} = (1 / 2 : ENNReal) := by
        simp [radMeasure]
      rw [htrue]
      norm_num
    have hpos_int : 0 < ∫ ω, ar1Theta 0 ω 0 * ar1Theta 0 ω 0 ∂ar1Measure := by
      calc (0 : ℝ)
          < (ar1Measure E).toReal * 1 := by linarith
        _ = ∫ _ in E, (1 : ℝ) ∂ar1Measure := by
            rw [setIntegral_const, Measure.real_def, smul_eq_mul]
        _ ≤ ∫ ω in E, ar1Theta 0 ω 0 * ar1Theta 0 ω 0 ∂ar1Measure :=
            setIntegral_mono_on (integrableOn_const (by simp)) hsq_int.integrableOn hE_meas hE_bound
        _ ≤ ∫ ω, ar1Theta 0 ω 0 * ar1Theta 0 ω 0 ∂ar1Measure :=
            setIntegral_le_integral hsq_int (Eventually.of_forall fun ω => mul_self_nonneg _)
    positivity
  refine ⟨scalarModel, AR1Space, inferInstance, ar1Measure, inferInstance, ar1Theta, ar1Eps, 1 / 2,
    by norm_num, by norm_num,
    ⟨measurable_ar1Theta, memLp_ar1Theta, identDistrib_ar1Theta⟩,
    memLp_ar1Eps, ar1Theta_succ, ar1_condExp_eps_zero, hRinf⟩

end TinaV2.NonVacuity.FiniteModels
