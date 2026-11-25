import TinaV2.Routine.ProcessIntegral

/-! # Routine: the weighted integral of a process is a function of its law

If two processes on the line with continuous paths have the same law, then
their weighted integrals, taken together with the processes themselves, have
the same joint law. This is the measurability behind "by stationarity" in the
continuum model (claim C17.b): the target `x⋆(z,t) = ∫ w(u) θ(z+u,t) du` is a
fixed functional of the spatial field at time `t`, so its joint law with the
observation of that field does not depend on `t`. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Two processes on the line with the same law and continuous paths: the pair
(weighted integral, process) has the same law for both. -/
theorem identDistrib_integral_prodMk {φ ψ : ℝ → Ω → ℝ} (hφ : L2Process μ φ) (hψ : L2Process μ ψ)
    (hφm : ∀ a, Measurable (φ a)) (hψm : ∀ a, Measurable (ψ a))
    (hφc : ∀ ω, Continuous fun a => φ a ω)
    (hlaw : IdentDistrib (fun ω a => φ a ω) (fun ω a => ψ a ω) μ μ)
    {g : ℝ → ℝ} (hgm : Measurable g) (ν : Measure ℝ) [SFinite ν] (hg : Integrable g ν) :
    IdentDistrib (fun ω => (∫ a, g a * φ a ω ∂ν, fun a => φ a ω))
      (fun ω => (∫ a, g a * ψ a ω ∂ν, fun a => ψ a ω)) μ μ := by
  set Φ : Ω → ℝ → ℝ := fun ω a => φ a ω with hΦ
  set Ψ : Ω → ℝ → ℝ := fun ω a => ψ a ω with hΨ
  set X : Ω → ℝ := fun ω => ∫ a, g a * φ a ω ∂ν with hX
  set X' : Ω → ℝ := fun ω => ∫ a, g a * ψ a ω ∂ν with hX'
  have hΦm : Measurable Φ := Measurable.of_eval hφm
  have hΨm : Measurable Ψ := Measurable.of_eval hψm
  -- the integral is a measurable function `F` of the path
  have hXm : StronglyMeasurable[MeasurableSpace.comap Φ MeasurableSpace.pi] X := by
    refine stronglyMeasurable_integral_of_continuous (fun a => ?_) hφc hgm ν
    exact (measurable_pi_apply a).comp (comap_measurable Φ)
  obtain ⟨F, hF, hXF⟩ := hXm.exists_eq_measurable_comp
  have hFm : Measurable F := hF.measurable
  have hXF' : ∀ ω, X ω = F (Φ ω) := fun ω => congrFun hXF ω
  -- second moments
  have hX2 : MemLp X 2 μ := hφ.memLp_integral hgm hg
  have hX'2 : MemLp X' 2 μ := hψ.memLp_integral hgm hg
  have hFΦ2 : MemLp (fun ω => F (Φ ω)) 2 μ := by
    have : (fun ω => F (Φ ω)) = X := funext fun ω => (hXF' ω).symm
    rw [this]; exact hX2
  have hFlaw : IdentDistrib (fun ω => F (Φ ω)) (fun ω => F (Ψ ω)) μ μ := hlaw.comp hFm
  have hFΨ2 : MemLp (fun ω => F (Ψ ω)) 2 μ := hFlaw.memLp_snd hFΦ2
  -- the three second moments agree
  have e1 : ∫ ω, X' ω * X' ω ∂μ = ∫ ω, X ω * X ω ∂μ := by
    rw [hψ.integral_integral_mul_integral hψ hgm hg hgm hg,
      hφ.integral_integral_mul_integral hφ hgm hg hgm hg]
    refine integral_congr_ae (Filter.Eventually.of_forall fun a => ?_)
    refine integral_congr_ae (Filter.Eventually.of_forall fun b => ?_)
    have hm : Measurable fun f : ℝ → ℝ => f a * f b :=
      (measurable_pi_apply a).mul (measurable_pi_apply b)
    have := (hlaw.comp hm).integral_eq
    simp only [Function.comp_def, hΦ, hΨ] at this
    simp only [this]
  have e2 : ∫ ω, X' ω * F (Ψ ω) ∂μ = ∫ ω, X ω * F (Φ ω) ∂μ := by
    rw [hψ.integral_integral_mul hgm hg hFΨ2, hφ.integral_integral_mul hgm hg hFΦ2]
    refine integral_congr_ae (Filter.Eventually.of_forall fun a => ?_)
    have hm : Measurable fun f : ℝ → ℝ => f a * F f := (measurable_pi_apply a).mul hFm
    have := (hlaw.comp hm).integral_eq
    simp only [Function.comp_def, hΦ, hΨ] at this
    exact congrArg (fun x => g a * x) this.symm
  have e3 : ∫ ω, F (Ψ ω) * F (Ψ ω) ∂μ = ∫ ω, F (Φ ω) * F (Φ ω) ∂μ := by
    have hm : Measurable fun f : ℝ → ℝ => F f * F f := hFm.mul hFm
    have := (hlaw.comp hm).integral_eq
    simp only [Function.comp_def] at this
    exact this.symm
  -- hence `X' = F ∘ Ψ` almost surely
  have hint1 : Integrable (fun ω => X' ω * X' ω) μ := hX'2.integrable_mul hX'2
  have hint2 : Integrable (fun ω => X' ω * F (Ψ ω)) μ := hX'2.integrable_mul hFΨ2
  have hint3 : Integrable (fun ω => F (Ψ ω) * F (Ψ ω)) μ := hFΨ2.integrable_mul hFΨ2
  have hzero : ∫ ω, (X' ω - F (Ψ ω)) ^ 2 ∂μ = 0 := by
    have hexp : (fun ω => (X' ω - F (Ψ ω)) ^ 2)
        = fun ω => X' ω * X' ω - 2 * (X' ω * F (Ψ ω)) + F (Ψ ω) * F (Ψ ω) := by
      funext ω; ring
    have hint12 : Integrable (fun ω => X' ω * X' ω - 2 * (X' ω * F (Ψ ω))) μ :=
      hint1.sub (hint2.const_mul 2)
    rw [hexp, integral_add hint12 hint3,
      integral_sub hint1 (hint2.const_mul 2), integral_const_mul, e1, e2, e3]
    have : ∀ ω, X ω * F (Φ ω) = X ω * X ω := fun ω => by rw [hXF' ω]
    have h' : ∀ ω, F (Φ ω) * F (Φ ω) = X ω * X ω := fun ω => by rw [hXF' ω]
    simp only [this, h']
    ring
  have hae : X' =ᵐ[μ] fun ω => F (Ψ ω) := by
    have hsq : Integrable (fun ω => (X' ω - F (Ψ ω)) ^ 2) μ := (hX'2.sub hFΨ2).integrable_sq
    have := (integral_eq_zero_iff_of_nonneg (fun ω => sq_nonneg _) hsq).1 hzero
    filter_upwards [this] with ω hω
    have : X' ω - F (Ψ ω) = 0 := by simpa using hω
    linarith
  -- assemble
  have hpair : Measurable fun f : ℝ → ℝ => (F f, f) := hFm.prodMk measurable_id
  have h1 : IdentDistrib (fun ω => (F (Φ ω), Φ ω)) (fun ω => (F (Ψ ω), Ψ ω)) μ μ :=
    hlaw.comp hpair
  have h0 : (fun ω => (X ω, Φ ω)) = fun ω => (F (Φ ω), Φ ω) := funext fun ω => by rw [hXF' ω]
  have h2 : (fun ω => (F (Ψ ω), Ψ ω)) =ᵐ[μ] fun ω => (X' ω, Ψ ω) := by
    filter_upwards [hae] with ω hω
    rw [hω]
  rw [h0]
  exact h1.trans (IdentDistrib.of_ae_eq ((hFm.comp hΨm).prodMk hΨm).aemeasurable h2)

end TinaV2
