import LCSS.IndependentOU
import LCSS.InclusiveAttainment

/-! Instantiated nonvacuity and paper results on the constructed probability
space. Only numeric parameters and the independent schedule seed are supplied. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory
variable {ι : Type*} [Fintype ι] (p : ι → Parameters)

/-- One probability space carries all real times and all independent primitives.
Continuity and the entire raw/model interface are supplied by the construction. -/
theorem full_model_witness :
    IsProbabilityMeasure (IndependentOU.law p) ∧
      ∃ D : PaperComponents (μ := IndependentOU.law p) ι p, ∃ B : RawRealization D,
        (∀ m c ω, Continuous (fun t => B.component m c t ω)) ∧
        (∀ m c, IsGaussianProcess (B.component m c) (IndependentOU.law p)) ∧
        iIndepFun (fun (q : IndependentOU.PrimitiveIndex p) ω t =>
          B.component q.1 q.2 t ω) (IndependentOU.law p) ∧
        (∀ m c t, (∫ ω, B.component m c t ω ∂IndependentOU.law p) = 0) ∧
        (∀ m c s t, cov[B.component m c s, B.component m c t; IndependentOU.law p] =
          componentVariance (p m) c * kernel (p m).rate s t) ∧
        (∀ m c t, 0 < cov[B.component m c t, B.component m c t; IndependentOU.law p]) := by
  exact ⟨inferInstance, IndependentOU.components p, IndependentOU.realization p,
    IndependentOU.raw_continuous p, IndependentOU.raw_gaussian p,
    IndependentOU.raw_all_independent p, IndependentOU.raw_centered p,
    IndependentOU.raw_covariance p, IndependentOU.raw_variance_positive p⟩

theorem theorem1_ou (m : ι) (t τ : ℝ) (hτ : 0 ≤ τ) :
    Theorem1Claims (IndependentOU.model p m).toSensorModel t τ :=
  theorem1 (IndependentOU.model p m) t τ hτ

theorem theorem2_ou_physical_attainment [Nonempty ι] (a : AgentCoordinates p)
    (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (hw : ∀ m, 0 < w m) (c : ℝ) (hc : 0 < c) :
    ((InclusiveRawStrategy.noRefresh (IndependentOU.realization p) a w δ hδ ν).timeUpperCost (IndependentOU.realization p) a w δ hδ ν c =
      ENNReal.ofReal (RefreshMixture.baseline p w)) ∧
    ((RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
      ∀ S : InclusiveRawStrategy (IndependentOU.realization p) a w δ hδ Ξ ν,
        (InclusiveRawStrategy.noRefresh (IndependentOU.realization p) a w δ hδ ν).timeUpperCost (IndependentOU.realization p) a w δ hδ ν c ≤
          S.timeUpperCost (IndependentOU.realization p) a w δ hδ ν c) ∧
    (c < (RefreshMixture.ofParameters p w hw δ).threshold →
      ∃ T : ℝ, ∃ hT : 0 < T,
        (RefreshMixture.ofParameters p w hw δ).marginal T = c ∧
        (∀ U : ℝ, 0 < U → (RefreshMixture.ofParameters p w hw δ).marginal U = c → U = T) ∧
        0 ≤ RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T ∧
        (InclusiveRawStrategy.periodic (IndependentOU.realization p) a w δ hδ ν T hT).timeUpperCost (IndependentOU.realization p) a w δ hδ ν c =
          ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ∧
        (∀ S : InclusiveRawStrategy (IndependentOU.realization p) a w δ hδ Ξ ν,
          (InclusiveRawStrategy.periodic (IndependentOU.realization p) a w δ hδ ν T hT).timeUpperCost (IndependentOU.realization p) a w δ hδ ν c ≤
            S.timeUpperCost (IndependentOU.realization p) a w δ hδ ν c)) :=
  theorem2_inclusive_physical_attainment (IndependentOU.realization p) a w δ hδ ν hw c hc

end
end LCSS
