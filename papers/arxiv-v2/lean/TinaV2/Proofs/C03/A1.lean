import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection
import TinaV2.Routine.CommonInfo

/-! # C3, attempt A1: mirrors paper proof C3/p1

Paper: `technical-appendices-v2.tex`, paragraph "Common-information optimality"
(lines 271-276). Two steps: conditioning on the common observation `Z` makes the
error `x⋆ − m` of `m = E[x⋆ | Z]` `Q`-orthogonal to every admissible
perturbation; then the error expansion around `m` shows that `m` is the unique
optimum. -/

namespace TinaV2.C03.A1

open MeasureTheory ProbabilityTheory Matrix

/-- Step 1 (technical-appendices-v2.tex 272-274): "If every agent observes the
same `Z`, let `m = E[x⋆ | Z]`. For every admissible perturbation `h`,
conditioning gives `E[hᵀ Q (x⋆ − m)] = 0`." Here `m` is itself admissible, and
the admissible perturbations are the members of the policy space. -/
theorem s1_conditioning {ι α Ω O : Type} [Fintype α] [DecidableEq α] [MeasurableSpace Ω]
    [MeasurableSpace O] (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ)
    (actor : α → ι) (Z : Ω → O) (b : Ω → α → ℝ) (hZ : Measurable Z) (hb : MemLp b 2 μ) :
    let xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω
    let S := policySpace μ actor fun _ => MeasurableSpace.comap Z inferInstance
    let m : Ω → α → ℝ := μ[xstar | MeasurableSpace.comap Z inferInstance]
    m ∈ S ∧ ∀ h ∈ S, qInner μ Q h (xstar - m) = 0 := by
  intro xstar S m
  have hle : MeasurableSpace.comap Z inferInstance ≤ ‹MeasurableSpace Ω› := hZ.comap_le
  have hx : MemLp xstar 2 μ := memLp_xstar Q hb
  -- `m` is a function of `Z` with finite second moment
  have hm2 : MemLp m 2 μ := hx.condExp one_le_two
  have hmS : m ∈ S := ⟨fun c => measurable_condExp_apply μ _ xstar c, hm2⟩
  refine ⟨hmS, fun h hh => ?_⟩
  -- `hᵀ Q (x⋆ − m) = Σ_c h_c (Q (x⋆ − m))_c`
  have he : MemLp (fun ω => Q *ᵥ (xstar - m) ω) 2 μ := memLp_mulVec Q (hx.sub hm2)
  unfold qInner
  rw [integral_dotProduct_eq_sum hh.2 he]
  refine Finset.sum_eq_zero fun c _ => ?_
  -- `h_c` is a function of `Z`, and `E[(Q (x⋆ − m))_c | Z] = 0`
  have hhc : StronglyMeasurable[MeasurableSpace.comap Z inferInstance] fun ω => h ω c :=
    (hh.1 c).stronglyMeasurable
  have hec : Integrable (fun ω => (Q *ᵥ (xstar - m) ω) c) μ :=
    (memLp_pi_iff.1 he c).integrable one_le_two
  have hprod : Integrable (fun ω => h ω c * (Q *ᵥ (xstar - m) ω) c) μ :=
    (memLp_pi_iff.1 hh.2 c).integrable_mul (memLp_pi_iff.1 he c)
  have hcond : μ[fun ω => (Q *ᵥ (xstar - m) ω) c | MeasurableSpace.comap Z inferInstance]
      =ᵐ[μ] 0 :=
    condExp_mulVec_sub_condExp_apply hle (hx.integrable one_le_two) Q c
  -- condition on `Z` and pull `h_c` out
  calc ∫ ω, h ω c * (Q *ᵥ (xstar - m) ω) c ∂μ
      = ∫ ω, (μ[fun ω => h ω c * (Q *ᵥ (xstar - m) ω) c |
          MeasurableSpace.comap Z inferInstance]) ω ∂μ := (integral_condExp hle).symm
    _ = ∫ ω, h ω c * (μ[fun ω => (Q *ᵥ (xstar - m) ω) c |
          MeasurableSpace.comap Z inferInstance]) ω ∂μ :=
        integral_congr_ae (condExp_mul_of_stronglyMeasurable_left hhc hprod hec)
    _ = ∫ _, (0 : ℝ) ∂μ := integral_congr_ae (by
        filter_upwards [hcond] with ω hω
        exact mul_eq_zero_of_right _ hω)
    _ = 0 := by simp

/-- Step 2 (technical-appendices-v2.tex 274-275): "The error expansion then
proves that `m` is the unique optimum, regardless of the off-diagonal entries
of `Q`." For `u` admissible and `h = u − m`,
`E[f(u) − f(m)] = E[hᵀ(Qm − b)] + ½ E[hᵀQh] = ½ ‖u − m‖_Q²`, since the linear
term is `−E[hᵀ Q (x⋆ − m)] = 0` by step 1. -/
theorem s2_unique_optimum {ι α Ω O : Type} [Fintype α] [DecidableEq α] [MeasurableSpace Ω]
    [MeasurableSpace O] (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Matrix α α ℝ)
    (actor : α → ι) (Z : Ω → O) (b : Ω → α → ℝ) (c : Ω → ℝ) (hQ : Q.PosDef)
    (hZ : Measurable Z) (hb : MemLp b 2 μ) (hc : Integrable c μ) :
    let xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω
    let S := policySpace μ actor fun _ => MeasurableSpace.comap Z inferInstance
    let m : Ω → α → ℝ := μ[xstar | MeasurableSpace.comap Z inferInstance]
    (∀ u ∈ S, expectedCost μ Q b c m ≤ expectedCost μ Q b c u) ∧
    (∀ u ∈ S, expectedCost μ Q b c u ≤ expectedCost μ Q b c m → u =ᵐ[μ] m) := by
  intro xstar S m
  obtain ⟨hmS, horth⟩ := s1_conditioning μ Q actor Z b hZ hb
  -- the error expansion around `m`: `E[f(u) − f(m)] = ½ ‖u − m‖_Q²`
  have key : ∀ u ∈ S,
      expectedCost μ Q b c u - expectedCost μ Q b c m = 1 / 2 * qNormSq μ Q (u - m) := by
    intro u hu
    have hh : u - m ∈ S := SigmaAdmissible.sub hu hmS
    have hexp := expectedCost_add (c := c) hQ.isHermitian hb hc hmS.2 hh.2
    -- the linear term is `−⟨h, x⋆ − m⟩_Q`, because `Q x⋆ = b`
    have hlin : ∫ ω, (u - m) ω ⬝ᵥ (Q *ᵥ m ω - b ω) ∂μ = -qInner μ Q (u - m) (xstar - m) := by
      unfold qInner
      rw [← integral_neg]
      refine integral_congr_ae (ae_of_all _ fun ω => ?_)
      change (u - m) ω ⬝ᵥ (Q *ᵥ m ω - b ω) = -((u - m) ω ⬝ᵥ (Q *ᵥ (Q⁻¹ *ᵥ b ω - m ω)))
      rw [mulVec_sub_eq hQ, ← dotProduct_neg, ← mulVec_neg, neg_sub]
    rw [add_sub_cancel, hlin, horth _ hh] at hexp
    rw [hexp]
    ring
  refine ⟨fun u hu => ?_, fun u hu hle => ?_⟩
  · -- `‖u − m‖_Q² ≥ 0`
    have h1 := key u hu
    have h2 := qNormSq_nonneg μ hQ (u - m)
    linarith
  · -- equality of costs forces `‖u − m‖_Q = 0`, and `Q ≻ 0` gives `u = m` a.s.
    have h1 := key u hu
    have h2 := qNormSq_nonneg μ hQ (u - m)
    have h0 : qNormSq μ Q (u - m) = 0 := by linarith
    have hae := ae_eq_zero_of_qNormSq_eq_zero hQ (hu.2.sub hmS.2) h0
    filter_upwards [hae] with ω hω
    exact sub_eq_zero.1 hω

theorem main : C03.Statement := by
  intro ι α Ω O _ _ _ _ μ _ Q actor Z b c hQ hZ hb hc
  exact ⟨(s1_conditioning μ Q actor Z b hZ hb).1, s2_unique_optimum μ Q actor Z b c hQ hZ hb hc⟩

end TinaV2.C03.A1
