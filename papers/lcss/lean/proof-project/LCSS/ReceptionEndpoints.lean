import LCSS.RawAttainment

/-! Reception endpoints are null in Lebesgue time. The information comparison
holds away from them for every schedule, without a seed-independent null set. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory Set Filter
open scoped ENNReal

namespace PhysicalSchedule
variable (S : PhysicalSchedule)

def receivedBy (δ t : ℝ) : Set ℝ :=
  {r | ∃ k, k ∈ S.active ∧ S.send k + δ ≤ t ∧ r = S.send k}

def receptionTimes (δ : ℝ) : Set ℝ := (fun k => S.send k + δ) '' S.active

theorem receptionTimes_countable (δ : ℝ) : (S.receptionTimes δ).Countable :=
  S.active.to_countable.image _

theorem receivedBefore_subset_receivedBy (δ t : ℝ) :
    S.receivedBefore δ t ⊆ S.receivedBy δ t := by
  rintro r ⟨k,hk,ht,he⟩
  exact ⟨k,hk,ht.le,he⟩

theorem receivedBy_eq_receivedBefore {δ t : ℝ} (ht : t ∉ S.receptionTimes δ) :
    S.receivedBy δ t = S.receivedBefore δ t := by
  apply Set.Subset.antisymm _ (S.receivedBefore_subset_receivedBy δ t)
  rintro r ⟨k,hk,hkt,he⟩
  refine ⟨k,hk,lt_of_le_of_ne hkt ?_,he⟩
  intro h
  exact ht ⟨k,hk,h⟩

theorem ae_not_reception (δ : ℝ) : ∀ᵐ t ∂volume, t ∉ S.receptionTimes δ :=
  (S.receptionTimes_countable δ).ae_notMem volume

theorem ae_not_reception_translate (δ b : ℝ) :
    ∀ᵐ x ∂volume, b+x ∉ S.receptionTimes δ := by
  have h := ((S.receptionTimes_countable δ).image (fun t => t-b)).ae_notMem volume
  filter_upwards [h] with x hx
  intro ht
  exact hx ⟨b+x,ht,by ring⟩

theorem ae_not_reception_phase {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (δ b d : ℝ) :
    ∀ᵐ z : ℝ × Ω ∂(volume.restrict (Ioc 0 d)).prod μ,
      b+z.1 ∉ S.receptionTimes δ :=
  (Measure.quasiMeasurePreserving_fst (μ := volume.restrict (Ioc 0 d)) (ν := μ)).ae
    (ae_restrict_of_ae (S.ae_not_reception_translate δ b))

end PhysicalSchedule
end
end LCSS
