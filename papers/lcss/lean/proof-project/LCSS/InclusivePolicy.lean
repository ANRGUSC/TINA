import LCSS.ReceptionEndpoints

/-! Controls may use a pooled message at the instant it is received.
Replacing actions on the reception set gives a strict admissible control. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)

namespace RawRealization

omit [Fintype ι] [Nonempty ι] in
theorem receivedInfo_mono (agents : (m : ι) → Fin (p m).n) (t : ℝ)
    {A C : Set ℝ} (h : A ⊆ C) : B.receivedInfo agents t A ≤ B.receivedInfo agents t C := by
  apply sup_le_sup_left
  apply iSup_mono
  intro m
  apply iSup_le
  intro r
  exact le_iSup_of_le (⟨r,h r.property⟩ : C) le_rfl

end RawRealization

structure InclusiveRawPolicy (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ) where
  action : ℝ → (m : ι) → Fin (p m).n → Ω → ℝ
  memLp : ∀ t m i, MemLp (action t m i) (2 : ℝ≥0∞) μ
  feasible : ∀ t, 0 < t → ∀ m i,
    AEStronglyMeasurable[B.receivedInfo (a.view m i) t (S.receivedBy δ t)]
      (action t m i) μ

namespace InclusiveRawPolicy
variable (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ)
variable (P : InclusiveRawPolicy B a S δ)

def strictAction (t : ℝ) : (m : ι) → Fin (p m).n → Ω → ℝ := by
  classical
  exact if t ∈ S.receptionTimes δ then fun _ _ _ => 0 else P.action t

def toStrict : RawScheduledPolicy B a S δ where
  action := P.strictAction B a S δ
  memLp t m i := by
    classical
    by_cases ht : t ∈ S.receptionTimes δ
    · simpa only [strictAction, if_pos ht] using (memLp_const (0 : ℝ) : MemLp (fun _ : Ω => (0 : ℝ)) 2 μ)
    · simpa only [strictAction, if_neg ht] using P.memLp t m i
  feasible t ht m i := by
    classical
    by_cases he : t ∈ S.receptionTimes δ
    · simpa only [strictAction, if_pos he] using
        (aestronglyMeasurable_const : AEStronglyMeasurable[
          B.receivedInfo (a.view m i) t (S.receivedBefore δ t)] (fun _ : Ω => (0 : ℝ)) μ)
    · have hf := P.feasible t ht m i
      rw [S.receivedBy_eq_receivedBefore he] at hf
      simpa only [strictAction, if_neg he] using hf

omit [Fintype ι] [Nonempty ι] in
theorem toStrict_action_eq {t : ℝ} (ht : t ∉ S.receptionTimes δ) :
    (P.toStrict B a S δ).action t = P.action t := by
  classical
  simp only [toStrict, strictAction, if_neg ht]

omit [Nonempty ι] in
theorem toStrict_loss_ae (w : ι → ℝ) (ω : Ω) :
    (fun t => B.realizedLoss w t ((P.toStrict B a S δ).action t) ω) =ᵐ[volume]
      fun t => B.realizedLoss w t (P.action t) ω := by
  filter_upwards [S.ae_not_reception δ] with t ht
  rw [P.toStrict_action_eq B a S δ ht]

omit [Nonempty ι] in
theorem toStrict_loss_phase_ae (w : ι → ℝ) (b d : ℝ) :
    (fun z : ℝ × Ω => B.realizedLoss w (b+z.1) ((P.toStrict B a S δ).action (b+z.1)) z.2)
      =ᵐ[(volume.restrict (Ioc 0 d)).prod μ]
    fun z => B.realizedLoss w (b+z.1) (P.action (b+z.1)) z.2 := by
  filter_upwards [S.ae_not_reception_phase μ δ b d] with z hz
  rw [P.toStrict_action_eq B a S δ hz]

omit [Nonempty ι] in
theorem toStrict_integrated_loss (w : ι → ℝ) (R : ℝ) (ω : Ω) :
    (∫⁻ t in Ioc 0 R, B.realizedLoss w t ((P.toStrict B a S δ).action t) ω) =
      ∫⁻ t in Ioc 0 R, B.realizedLoss w t (P.action t) ω :=
  lintegral_congr_ae (ae_restrict_of_ae (P.toStrict_loss_ae B a S δ w ω))

end InclusiveRawPolicy

namespace RawScheduledPolicy
variable (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ)

def toInclusive (P : RawScheduledPolicy B a S δ) : InclusiveRawPolicy B a S δ where
  action := P.action
  memLp := P.memLp
  feasible t ht m i := by
    obtain ⟨g,hg,he⟩ := P.feasible t ht m i
    exact ⟨g,hg.mono (B.receivedInfo_mono (a.view m i) t
      (S.receivedBefore_subset_receivedBy δ t)),he⟩

end RawScheduledPolicy
end
end LCSS
