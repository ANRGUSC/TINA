import LCSS.RawHistory
import LCSS.CanonicalStrategy

/-! Physical primitives and arithmetic formulas. The model contract is only
joint measurability and sectionwise agreement with the Gaussian L² model.
It contains no action regularity, cost identity, or optimality assumption. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

structure RawRealization (D : PaperComponents (μ := μ) ι p) where
  component : (m : ι) → Option (Fin (p m).n) → ℝ → Ω → ℝ
  joint : ∀ m c, Measurable (Function.uncurry (component m c))
  section_eq : ∀ m c t, component m c t =ᵐ[μ] ((D.model m).component c t : Ω → ℝ)

theorem raw_toLp_eq (f : Ω → ℝ) (hf : MemLp f (2 : ℝ≥0∞) μ)
    (u : RV (μ := μ)) (h : f =ᵐ[μ] (u : Ω → ℝ)) : hf.toLp f = u := by
  apply Lp.ext
  exact hf.coeFn_toLp.trans h

namespace RawRealization
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)

/-- Continuous paths and measurable sections are a sufficient primitive
interface. Constructing such paths for the OU law is a separate model task. -/
def ofContinuous (f : (m : ι) → Option (Fin (p m).n) → ℝ → Ω → ℝ)
    (hc : ∀ m c ω, Continuous (fun t => f m c t ω))
    (hm : ∀ m c t, Measurable (f m c t))
    (he : ∀ m c t, f m c t =ᵐ[μ] ((D.model m).component c t : Ω → ℝ)) : RawRealization D where
  component := f
  joint m c := measurable_uncurry_of_continuous_of_measurable (hc m c) (hm m c)
  section_eq := he

theorem component_gaussian (m : ι) (c : Option (Fin (p m).n)) :
    IsGaussianProcess (B.component m c) μ :=
  ((D.model m).gaussian c).congr (fun t => (B.section_eq m c t).symm)

theorem component_memLp (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    MemLp (B.component m c t) (2 : ℝ≥0∞) μ :=
  (memLp_congr_ae (B.section_eq m c t)).mpr (Lp.memLp _)

theorem component_toLp (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    (B.component_memLp m c t).toLp (B.component m c t) = (D.model m).component c t :=
  raw_toLp_eq _ _ _ (B.section_eq m c t)

def X (m : ι) (t : ℝ) : Ω → ℝ := B.component m none t
def Y (m : ι) (t : ℝ) (i : Fin (p m).n) : Ω → ℝ :=
  fun ω => B.component m none t ω + B.component m (some i) t ω
def message (m : ι) (s : ℝ) : Ω → ℝ :=
  fun ω => ((p m).n : ℝ)⁻¹ * ∑ i, B.Y m s i ω
def localAction (m : ι) (t : ℝ) (i : Fin (p m).n) : Ω → ℝ :=
  fun ω => ((p m).a / (p m).d) * B.Y m t i ω
def hybrid (m : ι) (s t : ℝ) (i : Fin (p m).n) : Ω → ℝ :=
  fun ω => (kernel (p m).rate t s * ((p m).a / (p m).v)) * B.message m s ω +
    ((p m).a / (p m).d) * (B.Y m t i ω - kernel (p m).rate t s * B.Y m s i ω)

theorem X_eq (m : ι) (t : ℝ) : B.X m t =ᵐ[μ] ((D.sensor m).X t : Ω → ℝ) := by
  simpa only [X, PaperComponents.sensor, PaperModel.signal] using B.section_eq m none t

theorem Y_eq (m : ι) (t : ℝ) (i : Fin (p m).n) :
    B.Y m t i =ᵐ[μ] ((D.sensor m).Y t i : Ω → ℝ) := by
  have ha := Lp.coeFn_add ((D.model m).component none t) ((D.model m).component (some i) t)
  rw [PaperComponents.sensor, PaperModel.sensor]
  filter_upwards [B.section_eq m none t, B.section_eq m (some i) t, ha] with ω hx he ha
  simp only [Y, Pi.add_apply] at *
  rw [ha, hx, he]

theorem message_eq (m : ι) (s : ℝ) :
    B.message m s =ᵐ[μ] (D.sensor m).message s := by
  have h := ae_all_iff.mpr (fun i => B.Y_eq m s i)
  filter_upwards [h] with ω hω
  simp only [message, SensorModel.message, hω]

theorem local_eq (m : ι) (t : ℝ) (i : Fin (p m).n) :
    B.localAction m t i =ᵐ[μ] ((D.sensor m).localPolicy t i : Ω → ℝ) := by
  filter_upwards [B.Y_eq m t i, Lp.coeFn_smul ((p m).a / (p m).d) ((D.sensor m).Y t i)]
    with ω hy hu
  simpa only [localAction, SensorModel.localPolicy, hu, Pi.smul_apply, smul_eq_mul, hy]

theorem hybrid_eq (m : ι) (s t : ℝ) (i : Fin (p m).n) :
    B.hybrid m s t i =ᵐ[μ] ((D.sensor m).hybrid s t i : Ω → ℝ) := by
  let M := D.sensor m
  filter_upwards [B.Y_eq m t i, B.Y_eq m s i, B.message_eq m s,
    M.pool_eq_message_ae s,
    Lp.coeFn_add (M.prediction s t) (((p m).a / (p m).d) • M.innovation s t i),
    Lp.coeFn_smul (kernel (p m).rate t s * ((p m).a / (p m).v)) (M.pool s),
    Lp.coeFn_smul ((p m).a / (p m).d) (M.innovation s t i),
    Lp.coeFn_sub (M.Y t i) (kernel (p m).rate t s • M.Y s i),
    Lp.coeFn_smul (kernel (p m).rate t s) (M.Y s i)] with ω ht hs hm hp ha hb hc hd he
  change _ = (M.prediction s t + ((p m).a / (p m).d) • M.innovation s t i) ω
  simp only [Pi.add_apply, Pi.sub_apply, Pi.smul_apply, smul_eq_mul] at ha hb hc hd he
  rw [ha, hc]
  change B.hybrid m s t i ω =
    ((kernel (p m).rate t s * ((p m).a / (p m).v)) • M.pool s) ω +
    ((p m).a / (p m).d) * (M.Y t i - kernel (p m).rate t s • M.Y s i) ω
  rw [hb, hd, he]
  simp only [hybrid, ht, hs, hm, hp]
  rfl

theorem X_joint (m : ι) : Measurable (fun z : ℝ × Ω => B.X m z.1 z.2) := B.joint m none
theorem Y_joint (m : ι) (i : Fin (p m).n) :
    Measurable (fun z : ℝ × Ω => B.Y m z.1 i z.2) :=
  (B.joint m none).add (B.joint m (some i))
theorem Y_measurable (m : ι) (t : ℝ) (i : Fin (p m).n) : Measurable (B.Y m t i) :=
  (B.Y_joint m i).comp (measurable_const.prodMk measurable_id)
theorem message_measurable (m : ι) (s : ℝ) : Measurable (B.message m s) := by
  exact (Finset.measurable_sum _ (fun i _ => B.Y_measurable m s i)).const_mul _
theorem local_joint (m : ι) (i : Fin (p m).n) :
    Measurable (fun z : ℝ × Ω => B.localAction m z.1 i z.2) := (B.Y_joint m i).const_mul _
theorem hybrid_joint (m : ι) (s : ℝ) (i : Fin (p m).n) :
    Measurable (fun z : ℝ × Ω => B.hybrid m s z.1 i z.2) := by
  have hY := B.Y_joint m i
  have hYs : Measurable (fun z : ℝ × Ω => B.Y m s i z.2) :=
    (B.Y_measurable m s i).comp measurable_snd
  have hM : Measurable (fun z : ℝ × Ω => B.message m s z.2) :=
    (B.message_measurable m s).comp measurable_snd
  unfold hybrid kernel
  fun_prop

abbrev localInfo (m : ι) (t : ℝ) (i : Fin (p m).n) : MeasurableSpace Ω :=
  ⨆ r : Iic t, MeasurableSpace.comap (B.Y m r i) inferInstance
abbrev receivedInfo (agents : (m : ι) → Fin (p m).n) (t : ℝ) (samples : Set ℝ) :
    MeasurableSpace Ω :=
  (⨆ m, B.localInfo m t (agents m)) ⊔
    (⨆ (m : ι) (r : samples), MeasurableSpace.comap (B.message m r) inferInstance)

theorem localInfo_aeHistory (m : ι) (t : ℝ) (i : Fin (p m).n) :
    aeHistory (μ := μ) (B.localInfo m t i) =
      aeHistory (μ := μ) ((D.sensor m).localInfo t i) :=
  aeHistory_iSup_comap _ _ (fun r => B.Y_eq m r i)

theorem receivedInfo_aeHistory (agents : (m : ι) → Fin (p m).n) (t : ℝ) (samples : Set ℝ) :
    aeHistory (μ := μ) (B.receivedInfo agents t samples) =
      aeHistory (μ := μ) (D.receivedInfo agents t samples) := by
  apply aeHistory_sup_congr
  · exact aeHistory_iSup_congr _ _ (fun m => B.localInfo_aeHistory m t (agents m))
  · apply aeHistory_iSup_congr
    intro m
    exact aeHistory_iSup_comap _ _ (fun r => B.message_eq m r)

theorem receivedInfo_informationSpace (agents : (m : ι) → Fin (p m).n) (t : ℝ)
    (samples : Set ℝ) :
    informationSpace (μ := μ) (B.receivedInfo agents t samples) =
      informationSpace (μ := μ) (D.receivedInfo agents t samples) :=
  informationSpace_eq_of_aeHistory_eq (B.receivedInfo_aeHistory agents t samples)

end RawRealization
end
end LCSS
