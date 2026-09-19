import LCSS.History

/-! Direct bridge from the paper's independent Gaussian signal/error processes.
None indexes X; some i indexes Eᵢ. Independence is process-level. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace ProbabilityTheory
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

def componentVariance (p : Parameters) : Option (Fin p.n) → ℝ
  | none => p.a
  | some _ => p.b

structure PaperModel (p : Parameters) where
  component : Option (Fin p.n) → ℝ → RV (μ := μ)
  gaussian : ∀ c, IsGaussianProcess (fun t => (component c t : Ω → ℝ)) μ
  independent : iIndepFun (fun c ω t => component c t ω) μ
  centered : ∀ c t, ∫ ω, component c t ω ∂μ = 0
  covariance : ∀ c t r, cov[component c t, component c r; μ] =
    componentVariance p c * kernel p.rate t r

namespace PaperModel
variable {p : Parameters} (D : PaperModel (μ := μ) p)

abbrev primitive (q : SourceIndex p.n) : RV (μ := μ) := D.component q.1 q.2

theorem primitive_gaussian : IsGaussianProcess (fun q => (D.primitive q : Ω → ℝ)) μ := by
  classical
  constructor
  intro I
  let times : Finset ℝ := I.image Prod.snd
  let V (c : Option (Fin p.n)) (ω : Ω) (r : times) := D.component c r ω
  have hV (c : Option (Fin p.n)) : HasGaussianLaw (V c) μ :=
    (D.gaussian c).hasGaussianLaw times
  have hiV : iIndepFun V μ := by
    exact D.independent.comp (fun _ (f : ℝ → ℝ) (r : times) => f r)
      (fun _ => measurable_pi_lambda _ (fun r => measurable_pi_apply (r : ℝ)))
  have hg := iIndepFun.hasGaussianLaw hV hiV
  let L : (Option (Fin p.n) → times → ℝ) →L[ℝ] (I → ℝ) :=
    { toFun := fun z q => z q.1.1 ⟨q.1.2, Finset.mem_image.mpr ⟨q.1,q.2,rfl⟩⟩
      map_add' := by intros; rfl
      map_smul' := by intros; rfl }
  exact hg.map L

theorem primitive_inner (c d : Option (Fin p.n)) (t r : ℝ) :
    ⟪D.component c t, D.component d r⟫_ℝ =
      if c = d then componentVariance p c * kernel p.rate t r else 0 := by
  rw [← covariance_eq_inner _ _ (D.centered c t) (D.centered d r)]
  by_cases h : c = d
  · subst d
    simp [D.covariance]
  · rw [if_neg h]
    have hi := (D.independent.indepFun h).comp (measurable_pi_apply t) (measurable_pi_apply r)
    exact hi.covariance_eq_zero (Lp.memLp _) (Lp.memLp _)

def observationForm (q : SourceIndex p.n) : SourceIndex p.n →₀ ℝ :=
  match q.1 with
  | none => atom none q.2
  | some i => atom none q.2 + atom (some i) q.2

def toSensorModel : SensorModel (μ := μ) p where
  source := fun q => lin D.primitive (observationForm q)
  gaussian := lin_gaussian D.primitive D.primitive_gaussian observationForm
  centered := fun q => integral_lin_zero D.primitive (fun q => D.centered q.1 q.2) _
  secondMoment := by
    intro c d t r
    cases c <;> cases d
    all_goals simp only [observationForm, lin, atom, map_add,
      Finsupp.linearCombination_single, one_smul, primitive, inner_add_left, inner_add_right,
      D.primitive_inner, spatial, componentVariance]
    all_goals simp <;> split_ifs <;> ring

@[simp] theorem signal (t : ℝ) : D.toSensorModel.X t = D.component none t := by
  simp [toSensorModel, SensorModel.X, observationForm, atom]
@[simp] theorem sensor (i : Fin p.n) (t : ℝ) :
    D.toSensorModel.Y t i = D.component none t + D.component (some i) t := by
  simp [toSensorModel, SensorModel.Y, observationForm, atom]

end PaperModel
end
end LCSS
