import TinaV2.Defs

/-! # Routine: integrals of a process against a weight

Regularity the paper leaves implicit wherever it integrates a random field
against a kernel (`x⋆(z,t) = ∫ w(u) θ(z+u,t) du` and the tail integrals of the
appendix): the integral is a random variable with finite second moment, and
expectation passes under the integral sign (Fubini).

Used by the tier D claims C17.b and C18. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [MeasurableSpace Ω] {A B : Type} [MeasurableSpace A] [MeasurableSpace B]

/-- A process that can be integrated over its index: jointly measurable, with
second moments bounded uniformly in the index. -/
structure L2Process (μ : Measure Ω) (φ : A → Ω → ℝ) : Prop where
  measurable : Measurable (Function.uncurry φ)
  memLp : ∀ a, MemLp (φ a) 2 μ
  bound : ∃ C : ℝ, ∀ a, ∫ ω, φ a ω ^ 2 ∂μ ≤ C

/-- `E|XY| ≤ (E X² + E Y²) / 2`. -/
theorem integral_abs_mul_le_of_memLp {μ : Measure Ω} {X Y : Ω → ℝ} (hX : MemLp X 2 μ)
    (hY : MemLp Y 2 μ) :
    ∫ ω, |X ω * Y ω| ∂μ ≤ (∫ ω, X ω ^ 2 ∂μ + ∫ ω, Y ω ^ 2 ∂μ) / 2 := by
  have hX2 := hX.integrable_sq
  have hY2 := hY.integrable_sq
  have hXY : Integrable (fun ω => X ω * Y ω) μ := hX.integrable_mul hY
  have h2 : Integrable (fun ω => (X ω ^ 2 + Y ω ^ 2) / 2) μ := (hX2.add hY2).div_const 2
  calc ∫ ω, |X ω * Y ω| ∂μ ≤ ∫ ω, (X ω ^ 2 + Y ω ^ 2) / 2 ∂μ := by
        refine integral_mono hXY.abs h2 fun ω => ?_
        show |X ω * Y ω| ≤ (X ω ^ 2 + Y ω ^ 2) / 2
        rw [abs_mul]
        nlinarith [sq_nonneg (|X ω| - |Y ω|), sq_abs (X ω), sq_abs (Y ω)]
    _ = (∫ ω, X ω ^ 2 ∂μ + ∫ ω, Y ω ^ 2 ∂μ) / 2 := by
        rw [integral_div, integral_add hX2 hY2]

/-- Tonelli: a weight times a field whose first absolute moments are bounded
uniformly in the index is integrable on the product of the index space and the
outcome space. -/
theorem integrable_weight_mul {C : Type} [MeasurableSpace C] {μ : Measure Ω} [SFinite μ]
    {ρ : Measure C} [SFinite ρ] {k : C → ℝ} {Φ : C → Ω → ℝ} {K : ℝ} (hk : Integrable k ρ)
    (hm : AEStronglyMeasurable (fun p : C × Ω => k p.1 * Φ p.1 p.2) (ρ.prod μ))
    (hΦ : ∀ c, Integrable (Φ c) μ) (hK : ∀ c, ∫ ω, |Φ c ω| ∂μ ≤ K) :
    Integrable (fun p : C × Ω => k p.1 * Φ p.1 p.2) (ρ.prod μ) := by
  refine (integrable_prod_iff hm).2 ⟨ae_of_all _ fun c => (hΦ c).const_mul (k c), ?_⟩
  refine Integrable.mono' (hk.norm.mul_const K) hm.norm.integral_prod_right'
    (ae_of_all _ fun c => ?_)
  have h0 : 0 ≤ ∫ ω, ‖k c * Φ c ω‖ ∂μ := integral_nonneg fun ω => norm_nonneg _
  have h1 : ∫ ω, ‖k c * Φ c ω‖ ∂μ = ‖k c‖ * ∫ ω, |Φ c ω| ∂μ := by
    simp_rw [norm_mul, Real.norm_eq_abs]
    exact integral_const_mul _ _
  rw [Real.norm_of_nonneg h0, h1]
  exact mul_le_mul_of_nonneg_left (hK c) (norm_nonneg _)

namespace L2Process

variable {μ : Measure Ω} [IsProbabilityMeasure μ] {φ φ' : A → Ω → ℝ} {ψ : B → Ω → ℝ}
  {ν : Measure A} [SFinite ν] {ν' : Measure B} [SFinite ν'] {g : A → ℝ} {h : B → ℝ}

/-! ## Building processes -/

omit [IsProbabilityMeasure μ] in
/-- A constant process. -/
theorem const {Y : Ω → ℝ} (hY : Measurable Y) (hY2 : MemLp Y 2 μ) :
    L2Process μ (fun _ : A => Y) :=
  ⟨hY.comp measurable_snd, fun _ => hY2, ⟨∫ ω, Y ω ^ 2 ∂μ, fun _ => le_rfl⟩⟩

omit [IsProbabilityMeasure μ] in
/-- Reindexing by a measurable map. -/
theorem comp (hφ : L2Process μ φ) {ρ : B → A} (hρ : Measurable ρ) :
    L2Process μ (fun b => φ (ρ b)) := by
  obtain ⟨C, hC⟩ := hφ.bound
  exact ⟨hφ.measurable.comp ((hρ.comp measurable_fst).prodMk measurable_snd),
    fun b => hφ.memLp (ρ b), ⟨C, fun b => hC (ρ b)⟩⟩

omit [IsProbabilityMeasure μ] in
/-- Multiplying by a bounded measurable coefficient that depends on the index. -/
theorem coeff_mul (hφ : L2Process μ φ) {c : A → ℝ} (hc : Measurable c)
    (hcb : ∃ K : ℝ, ∀ a, |c a| ≤ K) : L2Process μ (fun a ω => c a * φ a ω) := by
  obtain ⟨K, hK⟩ := hcb
  obtain ⟨C, hC⟩ := hφ.bound
  refine ⟨(hc.comp measurable_fst).mul hφ.measurable, fun a => (hφ.memLp a).const_mul (c a),
    ⟨K ^ 2 * C, fun a => ?_⟩⟩
  have h1 : ∫ ω, (c a * φ a ω) ^ 2 ∂μ = c a ^ 2 * ∫ ω, φ a ω ^ 2 ∂μ := by
    simp_rw [mul_pow]
    exact integral_const_mul _ _
  have h2 : c a ^ 2 ≤ K ^ 2 := by
    rw [← sq_abs (c a)]
    exact pow_le_pow_left₀ (abs_nonneg _) (hK a) 2
  have h3 : 0 ≤ ∫ ω, φ a ω ^ 2 ∂μ := integral_nonneg fun ω => sq_nonneg _
  rw [h1]
  exact mul_le_mul h2 (hC a) h3 (sq_nonneg K)

omit [IsProbabilityMeasure μ] in
theorem add (hφ : L2Process μ φ) (hφ' : L2Process μ φ') :
    L2Process μ (fun a ω => φ a ω + φ' a ω) := by
  obtain ⟨C, hC⟩ := hφ.bound
  obtain ⟨C', hC'⟩ := hφ'.bound
  refine ⟨hφ.measurable.add hφ'.measurable, fun a => (hφ.memLp a).add (hφ'.memLp a),
    ⟨2 * C + 2 * C', fun a => ?_⟩⟩
  have i1 := (hφ.memLp a).integrable_sq
  have i2 := (hφ'.memLp a).integrable_sq
  have i3 : Integrable (fun ω => (φ a ω + φ' a ω) ^ 2) μ :=
    ((hφ.memLp a).add (hφ'.memLp a)).integrable_sq
  have i4 : Integrable (fun ω => 2 * φ a ω ^ 2 + 2 * φ' a ω ^ 2) μ :=
    (i1.const_mul 2).add (i2.const_mul 2)
  calc ∫ ω, (φ a ω + φ' a ω) ^ 2 ∂μ ≤ ∫ ω, (2 * φ a ω ^ 2 + 2 * φ' a ω ^ 2) ∂μ := by
        refine integral_mono i3 i4 fun ω => ?_
        show (φ a ω + φ' a ω) ^ 2 ≤ 2 * φ a ω ^ 2 + 2 * φ' a ω ^ 2
        nlinarith [sq_nonneg (φ a ω - φ' a ω)]
    _ = 2 * ∫ ω, φ a ω ^ 2 ∂μ + 2 * ∫ ω, φ' a ω ^ 2 ∂μ := by
        rw [integral_add (i1.const_mul 2) (i2.const_mul 2), integral_const_mul,
          integral_const_mul]
    _ ≤ 2 * C + 2 * C' := by linarith [hC a, hC' a]

omit [IsProbabilityMeasure μ] in
theorem sub (hφ : L2Process μ φ) (hφ' : L2Process μ φ') :
    L2Process μ (fun a ω => φ a ω - φ' a ω) := by
  have h := hφ.add (hφ'.coeff_mul (c := fun _ => -1) measurable_const ⟨1, fun _ => by simp⟩)
  have e : (fun a ω => φ a ω - φ' a ω) = fun a ω => φ a ω + -1 * φ' a ω := by
    funext a ω
    ring
  rw [e]
  exact h

omit [IsProbabilityMeasure μ] in
/-- The products of two values have uniformly bounded first moment. -/
theorem integrable_mul (hφ : L2Process μ φ) (hψ : L2Process μ ψ) (a : A) (b : B) :
    Integrable (fun ω => φ a ω * ψ b ω) μ :=
  (hφ.memLp a).integrable_mul (hψ.memLp b)

/-- Joint integrability behind `E[(∫ g φ) Y] = ∫ g E[φ Y]`. -/
theorem integrable_prod_mul_right (hφ : L2Process μ φ) (hgm : Measurable g)
    (hg : Integrable g ν) {Y : Ω → ℝ} (hY : MemLp Y 2 μ) :
    Integrable (fun p : A × Ω => g p.1 * (φ p.1 p.2 * Y p.2)) (ν.prod μ) := by
  obtain ⟨C, hC⟩ := hφ.bound
  have hm : AEStronglyMeasurable (fun p : A × Ω => g p.1 * (φ p.1 p.2 * Y p.2)) (ν.prod μ) :=
    (hgm.comp measurable_fst).aestronglyMeasurable.mul
      (hφ.measurable.aestronglyMeasurable.mul hY.1.comp_snd)
  refine integrable_weight_mul (Φ := fun a ω => φ a ω * Y ω) (K := (C + ∫ ω, Y ω ^ 2 ∂μ) / 2)
    hg hm (fun a => (hφ.memLp a).integrable_mul hY) fun a => ?_
  refine (integral_abs_mul_le_of_memLp (hφ.memLp a) hY).trans ?_
  linarith [hC a]

/-- Joint integrability behind `E[(∫ g φ)(∫ h ψ)] = ∫∫ g h E[φ ψ]`. -/
theorem integrable_prod_mul_mul (hφ : L2Process μ φ) (hψ : L2Process μ ψ) (hgm : Measurable g)
    (hg : Integrable g ν) (hhm : Measurable h) (hh : Integrable h ν') :
    Integrable (fun p : (A × B) × Ω => g p.1.1 * h p.1.2 * (φ p.1.1 p.2 * ψ p.1.2 p.2))
      ((ν.prod ν').prod μ) := by
  obtain ⟨C, hC⟩ := hφ.bound
  obtain ⟨C', hC'⟩ := hψ.bound
  have hm1 : Measurable fun p : (A × B) × Ω => φ p.1.1 p.2 :=
    hφ.measurable.comp ((measurable_fst.comp measurable_fst).prodMk measurable_snd)
  have hm2 : Measurable fun p : (A × B) × Ω => ψ p.1.2 p.2 :=
    hψ.measurable.comp ((measurable_snd.comp measurable_fst).prodMk measurable_snd)
  have hmk : Measurable fun p : (A × B) × Ω => g p.1.1 * h p.1.2 :=
    (hgm.comp (measurable_fst.comp measurable_fst)).mul
      (hhm.comp (measurable_snd.comp measurable_fst))
  refine integrable_weight_mul (k := fun c : A × B => g c.1 * h c.2)
    (Φ := fun c ω => φ c.1 ω * ψ c.2 ω) (K := (C + C') / 2) (hg.mul_prod hh)
    (hmk.mul (hm1.mul hm2)).aestronglyMeasurable (fun c => hφ.integrable_mul hψ c.1 c.2)
    fun c => ?_
  refine (integral_abs_mul_le_of_memLp (hφ.memLp c.1) (hψ.memLp c.2)).trans ?_
  linarith [hC c.1, hC' c.2]

/-! ## The weighted integral as a random variable -/

/-- For almost every outcome the weighted path is integrable. -/
theorem ae_integrable (hφ : L2Process μ φ) (hgm : Measurable g) (hg : Integrable g ν) :
    ∀ᵐ ω ∂μ, Integrable (fun a => g a * φ a ω) ν := by
  have h := (hφ.integrable_prod_mul_right hgm hg (memLp_const (1 : ℝ))).prod_left_ae
  simpa using h

omit [IsProbabilityMeasure μ] in
theorem measurable_integral (hφ : L2Process μ φ) (hgm : Measurable g) :
    Measurable fun ω => ∫ a, g a * φ a ω ∂ν := by
  have hm : StronglyMeasurable (fun p : Ω × A => g p.2 * φ p.2 p.1) :=
    ((hgm.comp measurable_snd).mul (hφ.measurable.comp measurable_swap)).stronglyMeasurable
  exact (hm.integral_prod_right' (ν := ν)).measurable

theorem memLp_integral (hφ : L2Process μ φ) (hgm : Measurable g) (hg : Integrable g ν) :
    MemLp (fun ω => ∫ a, g a * φ a ω ∂ν) 2 μ := by
  rw [memLp_two_iff_integrable_sq (hφ.measurable_integral (ν := ν) hgm).aestronglyMeasurable]
  have hI := (hφ.integrable_prod_mul_mul hφ hgm hg hgm hg).integral_prod_right
  refine hI.congr (ae_of_all _ fun ω => ?_)
  show ∫ c : A × A, g c.1 * g c.2 * (φ c.1 ω * φ c.2 ω) ∂(ν.prod ν)
    = (∫ a, g a * φ a ω ∂ν) ^ 2
  rw [sq, ← integral_prod_mul]
  exact integral_congr_ae (ae_of_all _ fun c => by beta_reduce; ring)

/-- The weighted integral is linear in the process, almost surely. -/
theorem integral_add_ae (hφ : L2Process μ φ) (hφ' : L2Process μ φ') (hgm : Measurable g)
    (hg : Integrable g ν) :
    (fun ω => ∫ a, g a * (φ a ω + φ' a ω) ∂ν)
      =ᵐ[μ] fun ω => (∫ a, g a * φ a ω ∂ν) + ∫ a, g a * φ' a ω ∂ν := by
  filter_upwards [hφ.ae_integrable hgm hg, hφ'.ae_integrable hgm hg] with ω h1 h2
  simp only [mul_add]
  exact integral_add h1 h2

theorem integral_sub_ae (hφ : L2Process μ φ) (hφ' : L2Process μ φ') (hgm : Measurable g)
    (hg : Integrable g ν) :
    (fun ω => ∫ a, g a * (φ a ω - φ' a ω) ∂ν)
      =ᵐ[μ] fun ω => (∫ a, g a * φ a ω ∂ν) - ∫ a, g a * φ' a ω ∂ν := by
  filter_upwards [hφ.ae_integrable hgm hg, hφ'.ae_integrable hgm hg] with ω h1 h2
  simp only [mul_sub]
  exact integral_sub h1 h2

/-! ## Expectation under the integral sign -/

/-- `E[(∫ g φ) Y] = ∫ g E[φ Y]` for `Y` with finite second moment. -/
theorem integral_integral_mul (hφ : L2Process μ φ) (hgm : Measurable g) (hg : Integrable g ν)
    {Y : Ω → ℝ} (hY : MemLp Y 2 μ) :
    ∫ ω, (∫ a, g a * φ a ω ∂ν) * Y ω ∂μ = ∫ a, g a * (∫ ω, φ a ω * Y ω ∂μ) ∂ν := by
  have hI := hφ.integrable_prod_mul_right hgm hg hY
  calc ∫ ω, (∫ a, g a * φ a ω ∂ν) * Y ω ∂μ
      = ∫ ω, ∫ a, g a * (φ a ω * Y ω) ∂ν ∂μ := by
        refine integral_congr_ae (ae_of_all _ fun ω => ?_)
        show (∫ a, g a * φ a ω ∂ν) * Y ω = ∫ a, g a * (φ a ω * Y ω) ∂ν
        rw [← integral_mul_const]
        simp only [mul_assoc]
    _ = ∫ a, ∫ ω, g a * (φ a ω * Y ω) ∂μ ∂ν :=
        (integral_integral_swap (f := fun a ω => g a * (φ a ω * Y ω)) hI).symm
    _ = ∫ a, g a * (∫ ω, φ a ω * Y ω ∂μ) ∂ν := by
        simp only [integral_const_mul]

/-- `E[∫ g φ] = ∫ g E[φ]`. -/
theorem integral_integral (hφ : L2Process μ φ) (hgm : Measurable g) (hg : Integrable g ν) :
    ∫ ω, (∫ a, g a * φ a ω ∂ν) ∂μ = ∫ a, g a * (∫ ω, φ a ω ∂μ) ∂ν := by
  have h := hφ.integral_integral_mul (ν := ν) hgm hg (memLp_const (1 : ℝ))
  simpa using h

/-- `E[(∫ g φ)(∫ h ψ)] = ∫∫ g h E[φ ψ]`. -/
theorem integral_integral_mul_integral (hφ : L2Process μ φ) (hψ : L2Process μ ψ)
    (hgm : Measurable g) (hg : Integrable g ν) (hhm : Measurable h) (hh : Integrable h ν') :
    ∫ ω, (∫ a, g a * φ a ω ∂ν) * (∫ b, h b * ψ b ω ∂ν') ∂μ
      = ∫ a, ∫ b, g a * h b * (∫ ω, φ a ω * ψ b ω ∂μ) ∂ν' ∂ν := by
  have hI := hφ.integrable_prod_mul_mul hψ hgm hg hhm hh
  calc ∫ ω, (∫ a, g a * φ a ω ∂ν) * (∫ b, h b * ψ b ω ∂ν') ∂μ
      = ∫ ω, ∫ c : A × B, g c.1 * h c.2 * (φ c.1 ω * ψ c.2 ω) ∂(ν.prod ν') ∂μ := by
        refine integral_congr_ae (ae_of_all _ fun ω => ?_)
        show (∫ a, g a * φ a ω ∂ν) * (∫ b, h b * ψ b ω ∂ν')
          = ∫ c : A × B, g c.1 * h c.2 * (φ c.1 ω * ψ c.2 ω) ∂(ν.prod ν')
        rw [← integral_prod_mul]
        exact integral_congr_ae (ae_of_all _ fun c => by beta_reduce; ring)
    _ = ∫ c : A × B, ∫ ω, g c.1 * h c.2 * (φ c.1 ω * ψ c.2 ω) ∂μ ∂(ν.prod ν') :=
        (integral_integral_swap
          (f := fun (c : A × B) ω => g c.1 * h c.2 * (φ c.1 ω * ψ c.2 ω)) hI).symm
    _ = ∫ c : A × B, g c.1 * h c.2 * (∫ ω, φ c.1 ω * ψ c.2 ω ∂μ) ∂(ν.prod ν') := by
        simp only [integral_const_mul]
    _ = ∫ a, ∫ b, g a * h b * (∫ ω, φ a ω * ψ b ω ∂μ) ∂ν' ∂ν := by
        refine integral_prod (fun c : A × B => g c.1 * h c.2 * ∫ ω, φ c.1 ω * ψ c.2 ω ∂μ) ?_
        have hJ := hI.integral_prod_left
        simpa only [integral_const_mul] using hJ

end L2Process

/-! ## Processes with continuous paths on the line -/

/-- A process on the line with measurable values and continuous paths is
jointly measurable. -/
theorem L2Process.of_continuous {μ : Measure Ω} {φ : ℝ → Ω → ℝ} (hm : ∀ a, Measurable (φ a))
    (hc : ∀ ω, Continuous fun a => φ a ω) (h2 : ∀ a, MemLp (φ a) 2 μ)
    (hb : ∃ C : ℝ, ∀ a, ∫ ω, φ a ω ^ 2 ∂μ ≤ C) : L2Process μ φ :=
  ⟨measurable_uncurry_of_continuous_of_measurable hc hm, h2, hb⟩

omit [MeasurableSpace Ω] in
/-- The weighted integral of a process with continuous paths is measurable for
any sigma-algebra that makes every value of the process measurable. -/
theorem stronglyMeasurable_integral_of_continuous {m : MeasurableSpace Ω} {ψ : ℝ → Ω → ℝ}
    (hm : ∀ a, Measurable[m] (ψ a)) (hc : ∀ ω, Continuous fun a => ψ a ω) {g : ℝ → ℝ}
    (hgm : Measurable g) (ν : Measure ℝ) [SFinite ν] :
    StronglyMeasurable[m] fun ω => ∫ a, g a * ψ a ω ∂ν := by
  let := m
  have hj : Measurable (Function.uncurry ψ) :=
    measurable_uncurry_of_continuous_of_measurable hc hm
  have hm' : StronglyMeasurable (fun p : Ω × ℝ => g p.2 * ψ p.2 p.1) :=
    ((hgm.comp measurable_snd).mul (hj.comp measurable_swap)).stronglyMeasurable
  exact hm'.integral_prod_right' (ν := ν)

end TinaV2
