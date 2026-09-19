import LCSS.ReceivedInformation
import Mathlib.MeasureTheory.MeasurableSpace.EventuallyMeasurable
import Mathlib.MeasureTheory.Constructions.BorelSpace.Order

/-! Coordinatewise changes on null sets preserve the admissible real L² space,
even for histories with an uncountable index. The augmentation uses null sets
of the ambient measure, rather than the completion of a restricted measure. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory Set Filter
open scoped ENNReal Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

abbrev aeHistory (G : MeasurableSpace Ω) : MeasurableSpace Ω :=
  eventuallyMeasurableSpace G (ae μ)

theorem aeHistory_le_of_le {G H : MeasurableSpace Ω}
    (h : G ≤ aeHistory (mΩ := mΩ) (μ := μ) H) :
    aeHistory (mΩ := mΩ) (μ := μ) G ≤ aeHistory (mΩ := mΩ) (μ := μ) H := by
  let : MeasurableSpace Ω := mΩ
  rintro s ⟨t, ht, hst⟩
  obtain ⟨u, hu, htu⟩ := h t ht
  exact ⟨u, hu, hst.trans htu⟩

theorem aeHistory_eq_of_mutual {G H : MeasurableSpace Ω}
    (hGH : G ≤ aeHistory (mΩ := mΩ) (μ := μ) H) (hHG : H ≤ aeHistory (mΩ := mΩ) (μ := μ) G) :
    aeHistory (mΩ := mΩ) (μ := μ) G = aeHistory (mΩ := mΩ) (μ := μ) H :=
  le_antisymm (aeHistory_le_of_le (mΩ := mΩ) hGH) (aeHistory_le_of_le (mΩ := mΩ) hHG)

theorem aeHistory_mono {G H : MeasurableSpace Ω} (h : G ≤ H) :
    aeHistory (mΩ := mΩ) (μ := μ) G ≤ aeHistory (mΩ := mΩ) (μ := μ) H :=
  aeHistory_le_of_le (mΩ := mΩ) (h.trans le_eventuallyMeasurableSpace)

theorem aeHistory_iSup_congr {J : Type*} (G H : J → MeasurableSpace Ω)
    (h : ∀ j, aeHistory (mΩ := mΩ) (μ := μ) (G j) = aeHistory (mΩ := mΩ) (μ := μ) (H j)) :
    aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, G j) = aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, H j) := by
  let : MeasurableSpace Ω := mΩ
  have one (G H : J → MeasurableSpace Ω)
      (h : ∀ j, aeHistory (mΩ := mΩ) (μ := μ) (G j) = aeHistory (mΩ := mΩ) (μ := μ) (H j)) :
      (⨆ j, G j) ≤ aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, H j) := by
    let : MeasurableSpace Ω := mΩ
    apply iSup_le
    intro j
    calc G j ≤ aeHistory (mΩ := mΩ) (μ := μ) (G j) := le_eventuallyMeasurableSpace
      _ = aeHistory (mΩ := mΩ) (μ := μ) (H j) := h j
      _ ≤ aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, H j) := aeHistory_mono (le_iSup _ j)
  exact aeHistory_eq_of_mutual (one G H h) (one H G (fun j => (h j).symm))

theorem aeHistory_sup_congr {G H G' H' : MeasurableSpace Ω}
    (hG : aeHistory (mΩ := mΩ) (μ := μ) G = aeHistory (mΩ := mΩ) (μ := μ) G')
    (hH : aeHistory (mΩ := mΩ) (μ := μ) H = aeHistory (mΩ := mΩ) (μ := μ) H') :
    aeHistory (mΩ := mΩ) (μ := μ) (G ⊔ H) = aeHistory (mΩ := mΩ) (μ := μ) (G' ⊔ H') := by
  let : MeasurableSpace Ω := mΩ
  have one {A C A' C' : MeasurableSpace Ω}
      (hA : aeHistory (mΩ := mΩ) (μ := μ) A = aeHistory (mΩ := mΩ) (μ := μ) A')
      (hC : aeHistory (mΩ := mΩ) (μ := μ) C = aeHistory (mΩ := mΩ) (μ := μ) C') :
      A ⊔ C ≤ aeHistory (mΩ := mΩ) (μ := μ) (A' ⊔ C') := by
    let : MeasurableSpace Ω := mΩ
    apply sup_le
    · calc A ≤ aeHistory (mΩ := mΩ) (μ := μ) A := le_eventuallyMeasurableSpace
        _ = aeHistory (mΩ := mΩ) (μ := μ) A' := hA
        _ ≤ aeHistory (mΩ := mΩ) (μ := μ) (A' ⊔ C') := aeHistory_mono le_sup_left
    · calc C ≤ aeHistory (mΩ := mΩ) (μ := μ) C := le_eventuallyMeasurableSpace
        _ = aeHistory (mΩ := mΩ) (μ := μ) C' := hC
        _ ≤ aeHistory (mΩ := mΩ) (μ := μ) (A' ⊔ C') := aeHistory_mono le_sup_right
  exact aeHistory_eq_of_mutual (one hG hH) (one hG.symm hH.symm)

theorem aeHistory_iSup_comap {J : Type*} (f g : J → Ω → ℝ)
    (h : ∀ j, f j =ᵐ[μ] g j) :
    aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, MeasurableSpace.comap (f j) inferInstance) =
      aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, MeasurableSpace.comap (g j) inferInstance) := by
  let : MeasurableSpace Ω := mΩ
  have one (f g : J → Ω → ℝ) (h : ∀ j, f j =ᵐ[μ] g j) :
      (⨆ j, MeasurableSpace.comap (f j) inferInstance) ≤
        aeHistory (mΩ := mΩ) (μ := μ) (⨆ j, MeasurableSpace.comap (g j) inferInstance) := by
    let : MeasurableSpace Ω := mΩ
    apply iSup_le
    intro j
    have hg : Measurable[⨆ j, MeasurableSpace.comap (g j) inferInstance] (g j) :=
      (comap_measurable (g j)).mono (le_iSup (fun k => MeasurableSpace.comap (g k) inferInstance) j) le_rfl
    exact (hg.eventuallyMeasurable_of_eventuallyEq (h j)).comap_le
  exact aeHistory_eq_of_mutual (one f g h) (one g f (fun j => (h j).symm))

/-- A countable limit of real functions having measurable versions again has
a measurable version. The measure need not be defined on the smaller space. -/
theorem real_version_limit (G : MeasurableSpace Ω) {f : ℕ → Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, AEStronglyMeasurable[G] (f n) μ)
    (ht : ∀ ω, Tendsto (fun n => f n ω) atTop (𝓝 (g ω))) :
    AEStronglyMeasurable[G] g μ := by
  let : MeasurableSpace Ω := mΩ
  let v : ℕ → Ω → ℝ := fun n => (hf n).mk (f n)
  have hv : ∀ n, Measurable[G] (v n) := fun n => (hf n).stronglyMeasurable_mk.measurable
  refine ⟨fun ω => limsup (fun n => v n ω) atTop, (Measurable.limsup hv).stronglyMeasurable, ?_⟩
  have he : ∀ᵐ ω ∂μ, ∀ n, f n ω = v n ω := ae_all_iff.mpr (fun n => (hf n).ae_eq_mk)
  filter_upwards [he] with ω hω
  have hlim : Tendsto (fun n => v n ω) atTop (𝓝 (g ω)) := by
    simpa only [← hω] using ht ω
  exact hlim.limsup_eq.symm

theorem stronglyMeasurable_aeHistory_version (G : MeasurableSpace Ω) (f : Ω → ℝ)
    (hf : StronglyMeasurable[aeHistory (mΩ := mΩ) (μ := μ) G] f) :
    AEStronglyMeasurable[G] f μ := by
  let : MeasurableSpace Ω := mΩ
  induction f, hf using StronglyMeasurable.induction with
  | @ind c s hs =>
    obtain ⟨t, ht, hst⟩ := hs
    refine ⟨t.indicator (fun _ => c), stronglyMeasurable_const.indicator ht, ?_⟩
    filter_upwards [hst] with ω hω
    simp only [Set.indicator]
    change (ω ∈ s) = (ω ∈ t) at hω
    by_cases h : ω ∈ s
    · have h' : ω ∈ t := Eq.mp hω h
      simp only [if_pos h, if_pos h']
    · have h' : ω ∉ t := fun ht => h (Eq.mpr hω ht)
      simp only [if_neg h, if_neg h']
  | add hf hg hfg hd ihf ihg => exact ihf.add ihg
  | lim hf hg ih ht => exact real_version_limit G ih ht

theorem informationSpace_aeHistory (G : MeasurableSpace Ω) :
    informationSpace (mΩ := mΩ) (μ := μ) (aeHistory (mΩ := mΩ) (μ := μ) G) = informationSpace (mΩ := mΩ) (μ := μ) G := by
  let : MeasurableSpace Ω := mΩ
  apply le_antisymm
  · intro u hu
    have h := mem_lpMeas_iff_aestronglyMeasurable.mp hu
    apply mem_lpMeas_iff_aestronglyMeasurable.mpr
    exact (stronglyMeasurable_aeHistory_version G (h.mk u) h.stronglyMeasurable_mk).congr
      h.ae_eq_mk.symm
  · exact informationSpace_mono le_eventuallyMeasurableSpace

theorem informationSpace_eq_of_aeHistory_eq {G H : MeasurableSpace Ω}
    (h : aeHistory (mΩ := mΩ) (μ := μ) G = aeHistory (mΩ := mΩ) (μ := μ) H) :
    informationSpace (mΩ := mΩ) (μ := μ) G = informationSpace (mΩ := mΩ) (μ := μ) H := by
  let : MeasurableSpace Ω := mΩ
  rw [← informationSpace_aeHistory G, h, informationSpace_aeHistory H]

theorem informationSpace_iSup_comap_congr {J : Type*} (f g : J → Ω → ℝ)
    (h : ∀ j, f j =ᵐ[μ] g j) :
    informationSpace (mΩ := mΩ) (μ := μ) (⨆ j, MeasurableSpace.comap (f j) inferInstance) =
      informationSpace (mΩ := mΩ) (μ := μ) (⨆ j, MeasurableSpace.comap (g j) inferInstance) :=
  informationSpace_eq_of_aeHistory_eq (aeHistory_iSup_comap f g h)

end
end LCSS
