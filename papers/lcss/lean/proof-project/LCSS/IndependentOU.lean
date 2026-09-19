import LCSS.OUProcess
import LCSS.RawProcess
import Mathlib.Probability.Independence.InfinitePi

/-! Independent full-time OU families on an explicit finite product space.
The L² model is constructed from raw sections; independence survives this
coordinatewise change by the process-congruence theorem. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory
namespace IndependentOU

abbrev ComponentSample (p : Parameters) := Option (Fin p.n) → OUProcess.Sample
abbrev componentLaw (p : Parameters) : Measure (ComponentSample p) :=
  Measure.pi (fun _ => OUProcess.law)
abbrev Sample {ι : Type*} (p : ι → Parameters) := (m : ι) → ComponentSample (p m)
abbrev PrimitiveIndex {ι : Type*} (p : ι → Parameters) := (m : ι) × Option (Fin (p m).n)
abbrev law {ι : Type*} [Fintype ι] (p : ι → Parameters) : Measure (Sample p) :=
  Measure.pi (fun m => componentLaw (p m))

variable {ι : Type*} [Fintype ι] (p : ι → Parameters)

def raw (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) (ω : Sample p) : ℝ :=
  OUProcess.value (componentVariance (p m) c) (p m).rate t (ω m c)

theorem coordinate_preserving (m : ι) (c : Option (Fin (p m).n)) :
    MeasurePreserving (fun ω : Sample p => ω m c) (law p) OUProcess.law :=
  (measurePreserving_eval (fun _ : Option (Fin (p m).n) => OUProcess.law) c).comp
    (measurePreserving_eval (fun k => componentLaw (p k)) m)

theorem raw_measurable (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    Measurable (raw p m c t) :=
  (OUProcess.measurable_section _ _ _).comp (coordinate_preserving p m c).measurable

omit [Fintype ι] in
theorem raw_continuous (m : ι) (c : Option (Fin (p m).n)) (ω : Sample p) :
    Continuous (fun t => raw p m c t ω) := OUProcess.continuous_path _ _ _

theorem raw_joint (m : ι) (c : Option (Fin (p m).n)) :
    Measurable (Function.uncurry (raw p m c)) :=
  measurable_uncurry_of_continuous_of_measurable (raw_continuous p m c) (raw_measurable p m c)

theorem raw_gaussian (m : ι) (c : Option (Fin (p m).n)) :
    IsGaussianProcess (raw p m c) (law p) :=
  gaussian_process_pullback (f := OUProcess.value (componentVariance (p m) c) (p m).rate)
    (X := fun ω : Sample p => ω m c) (coordinate_preserving p m c)
    (OUProcess.measurable_section _ _) (OUProcess.gaussian _ _)

theorem raw_memLp (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    MemLp (raw p m c t) (2 : ℝ≥0∞) (law p) :=
  ((raw_gaussian p m c).hasGaussianLaw_eval t).memLp_two

theorem raw_centered (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    (∫ ω, raw p m c t ω ∂law p) = 0 := by
  have h : HasLaw (fun ω : Sample p => ω m c) OUProcess.law (law p) :=
    ⟨(coordinate_preserving p m c).measurable.aemeasurable, (coordinate_preserving p m c).map_eq⟩
  rw [show raw p m c t = OUProcess.value _ _ t ∘ (fun ω : Sample p => ω m c) from rfl,
    h.integral_comp (OUProcess.measurable_section _ _ _).aestronglyMeasurable,
    OUProcess.centered]

theorem raw_covariance (m : ι) (c : Option (Fin (p m).n)) (s t : ℝ) :
    cov[raw p m c s, raw p m c t; law p] = componentVariance (p m) c * kernel (p m).rate s t := by
  have h : HasLaw (fun ω : Sample p => ω m c) OUProcess.law (law p) :=
    ⟨(coordinate_preserving p m c).measurable.aemeasurable, (coordinate_preserving p m c).map_eq⟩
  change cov[OUProcess.value _ _ s ∘ (fun ω : Sample p => ω m c),
    OUProcess.value _ _ t ∘ (fun ω : Sample p => ω m c); law p] = _
  rw [h.covariance_comp (OUProcess.measurable_section _ _ _).aemeasurable
    (OUProcess.measurable_section _ _ _).aemeasurable]
  apply OUProcess.covariance _ _ _ (p m).hrate.le
  cases c
  · exact (p m).ha.le
  · exact (p m).hb.le

theorem raw_independent (m : ι) : iIndepFun (fun c ω t => raw p m c t ω) (law p) := by
  let f (c : Option (Fin (p m).n)) (η : OUProcess.Sample) (t : ℝ) :=
    OUProcess.value (componentVariance (p m) c) (p m).rate t η
  have hf (c : Option (Fin (p m).n)) : Measurable (f c) :=
    measurable_pi_lambda _ (fun t => OUProcess.measurable_section _ _ t)
  have hi := iIndepFun_pi (μ := fun _ : Option (Fin (p m).n) => OUProcess.law)
    (fun c => (hf c).aemeasurable)
  exact independent_pullback (measurePreserving_eval (fun k => componentLaw (p k)) m)
    (fun c => (hf c).comp (measurable_pi_apply c)) hi

theorem raw_groups_independent :
    iIndepFun (fun m (ω : Sample p) c t => raw p m c t ω) (law p) := by
  exact iIndepFun_pi (μ := fun m => componentLaw (p m))
    (fun m => (measurable_pi_lambda _ (fun c => measurable_pi_lambda _ (fun t =>
      (OUProcess.measurable_section (componentVariance (p m) c) (p m).rate t).comp
        (measurable_pi_apply c)))).aemeasurable)

theorem raw_all_independent :
    iIndepFun (fun (q : PrimitiveIndex p) (ω : Sample p) t => raw p q.1 q.2 t ω) (law p) :=
  iIndepFun_uncurry (fun m c => measurable_pi_lambda _ (raw_measurable p m c))
    (raw_groups_independent p) (raw_independent p)

theorem raw_variance_positive (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    0 < cov[raw p m c t, raw p m c t; law p] := by
  rw [raw_covariance]
  simp only [kernel, sub_self, abs_zero, mul_zero, Real.exp_zero, mul_one]
  cases c
  · exact (p m).ha
  · exact (p m).hb

def component (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) : RV (μ := law p) :=
  (raw_memLp p m c t).toLp (raw p m c t)

theorem component_eq (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    (component p m c t : Sample p → ℝ) =ᵐ[law p] raw p m c t :=
  (raw_memLp p m c t).coeFn_toLp

def model (m : ι) : PaperModel (μ := law p) (p m) where
  component := component p m
  gaussian c := (raw_gaussian p m c).congr (fun t => (component_eq p m c t).symm)
  independent := (raw_independent p m).process_congr (fun c t => (component_eq p m c t).symm)
  centered c t := (integral_congr_ae (component_eq p m c t)).trans (raw_centered p m c t)
  covariance c s t := by
    unfold ProbabilityTheory.covariance
    rw [integral_congr_ae (component_eq p m c s), integral_congr_ae (component_eq p m c t)]
    have he : (∫ ω, (component p m c s ω - ∫ y, raw p m c s y ∂law p) *
        (component p m c t ω - ∫ y, raw p m c t y ∂law p) ∂law p) =
        cov[raw p m c s, raw p m c t; law p] := by
      apply integral_congr_ae
      filter_upwards [component_eq p m c s, component_eq p m c t] with ω hs ht
      rw [hs,ht]
    exact he.trans (raw_covariance p m c s t)

/-- Actual signal/observation coordinates for a single component sample. -/
def observed (m : ι) (q : SourceIndex (p m).n) (η : ComponentSample (p m)) : ℝ :=
  match q.1 with
  | none => OUProcess.value (p m).a (p m).rate q.2 (η none)
  | some i => OUProcess.value (p m).a (p m).rate q.2 (η none) +
      OUProcess.value (p m).b (p m).rate q.2 (η (some i))

omit [Fintype ι] in
theorem observed_measurable (m : ι) (q : SourceIndex (p m).n) : Measurable (observed p m q) := by
  rcases q with ⟨c,t⟩
  cases c with
  | none =>
    exact (OUProcess.measurable_section (p m).a (p m).rate t).comp (measurable_pi_apply none)
  | some i =>
    exact ((OUProcess.measurable_section (p m).a (p m).rate t).comp
      (measurable_pi_apply (none : Option (Fin (p m).n)))).add
      ((OUProcess.measurable_section (p m).b (p m).rate t).comp (measurable_pi_apply (some i)))

theorem source_eq (m : ι) (q : SourceIndex (p m).n) :
    ((model p m).toSensorModel.source q : Sample p → ℝ) =ᵐ[law p]
      fun ω => observed p m q (ω m) := by
  rcases q with ⟨c,t⟩
  cases c with
  | none =>
    change ((model p m).toSensorModel.X t : Sample p → ℝ) =ᵐ[law p] _
    rw [PaperModel.signal]
    exact component_eq p m none t
  | some i =>
    change ((model p m).toSensorModel.Y t i : Sample p → ℝ) =ᵐ[law p] _
    rw [PaperModel.sensor]
    filter_upwards [Lp.coeFn_add (component p m none t) (component p m (some i) t),
      component_eq p m none t, component_eq p m (some i) t] with ω ha hs he
    change (component p m none t + component p m (some i) t) ω = _
    rw [ha]
    change component p m none t ω + component p m (some i) t ω = _
    rw [hs,he]
    rfl

def components : PaperComponents (μ := law p) ι p where
  model := model p
  independent := by
    have hi := iIndepFun_pi (μ := fun m => componentLaw (p m))
      (fun m => (measurable_pi_lambda _ (observed_measurable p m)).aemeasurable)
    exact hi.process_congr (fun m q => (source_eq p m q).symm)

def realization : RawRealization (components p) where
  component := raw p
  joint := raw_joint p
  section_eq m c t := (component_eq p m c t).symm

end IndependentOU
end
end LCSS
