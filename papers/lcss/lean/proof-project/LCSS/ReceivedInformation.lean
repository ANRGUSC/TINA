import LCSS.LocalComponents

/-! Actual pooled messages are pointwise arithmetic averages. These lemmas
handle L² representatives explicitly and compare every received-message
history with the enlarged information used for the lower bound. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

def message (s : ℝ) : Ω → ℝ := fun ω => (p.n : ℝ)⁻¹ * ∑ i, M.Y s i ω
def receivedSnapshotInfo (s t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  M.localInfo t i ⊔ MeasurableSpace.comap (M.message s) inferInstance

theorem pool_eq_message_ae (s : ℝ) : (M.pool s : Ω → ℝ) =ᵐ[μ] M.message s := average_ae _

theorem hybrid_received_snapshot_feasible {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.hybrid s t i ∈ informationSpace (μ := μ) (M.receivedSnapshotInfo s t i) := by
  have hl : informationSpace (μ := μ) (M.localInfo t i) ≤
      informationSpace (μ := μ) (M.receivedSnapshotInfo s t i) := informationSpace_mono le_sup_left
  have hn := hl (history_mem (fun r : Set.Iic t => M.Y r i) ⟨t, by simp⟩)
  have hs := hl (history_mem (fun r : Set.Iic t => M.Y r i) ⟨s,hst⟩)
  have hp : M.pool s ∈ informationSpace (μ := μ) (M.receivedSnapshotInfo s t i) := by
    apply mem_lpMeas_iff_aestronglyMeasurable.mpr
    have hm : Measurable[M.receivedSnapshotInfo s t i] (M.message s) :=
      (comap_measurable (M.message s)).mono le_sup_right le_rfl
    exact hm.stronglyMeasurable.aestronglyMeasurable.congr (M.pool_eq_message_ae s).symm
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hp)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hn
      ((informationSpace _).smul_mem _ hs)))

end SensorModel

namespace PaperComponents
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p)

theorem own_local_measurable (m : ι) (s t : ℝ) (i : Fin (p m).n) (r : Set.Iic t) :
    Measurable[D.info m s t i] ((D.sensor m).Y r i : Ω → ℝ) := by
  have h := (comap_measurable
    (lin D.source (observation (p := p) m s t i (Sum.inl (Sum.inr r))))).mono
      (le_iSup (fun q => MeasurableSpace.comap (lin D.source (observation (p := p) m s t i q))
        inferInstance) (Sum.inl (Sum.inr r))) le_rfl
  simpa only [observation, Sum.elim_inl, D.lin_embed, fullObservation, Sum.elim_inr,
    (D.sensor m).lin_atom, info, historySigma, SensorModel.Y] using h

theorem own_past_measurable (m : ι) (s t : ℝ) (i j : Fin (p m).n) (r : Set.Iic s) :
    Measurable[D.info m s t i] ((D.sensor m).Y r j : Ω → ℝ) := by
  have h := (comap_measurable
    (lin D.source (observation (p := p) m s t i (Sum.inl (Sum.inl (j,r)))))).mono
      (le_iSup (fun q => MeasurableSpace.comap (lin D.source (observation (p := p) m s t i q))
        inferInstance) (Sum.inl (Sum.inl (j,r)))) le_rfl
  simpa only [observation, Sum.elim_inl, D.lin_embed, fullObservation,
    (D.sensor m).lin_atom, info, historySigma, SensorModel.Y] using h

theorem other_measurable (m : ι) (s t : ℝ) (i : Fin (p m).n)
    (k : ι) (hkm : k ≠ m) (j : Fin (p k).n) (r : ℝ) :
    Measurable[D.info m s t i] ((D.sensor k).Y r j : Ω → ℝ) := by
  let idx : ObservationIndex (p := p) m s t := Sum.inr ⟨⟨k,hkm⟩,(some j,r)⟩
  have h := (comap_measurable (lin D.source (observation (p := p) m s t i idx))).mono
    (le_iSup (fun q => MeasurableSpace.comap (lin D.source (observation (p := p) m s t i q))
      inferInstance) idx) le_rfl
  simpa only [idx, observation, Sum.elim_inr, lin, Finsupp.linearCombination_single, one_smul, info, historySigma, SensorModel.Y, source] using h

/-- At time t, agents know local histories of all components and the pooled
messages at arbitrary previously sampled times in `samples`. -/
def receivedInfo (agents : (m : ι) → Fin (p m).n) (t : ℝ) (samples : Set ℝ) : MeasurableSpace Ω :=
  (⨆ m, (D.sensor m).localInfo t (agents m)) ⊔
    (⨆ (m : ι) (r : samples), MeasurableSpace.comap ((D.sensor m).message r) inferInstance)

theorem receivedInfo_le (agents : (m : ι) → Fin (p m).n) (s t : ℝ) (samples : Set ℝ)
    (hpast : ∀ r ∈ samples, r ≤ s) (m : ι) :
    D.receivedInfo agents t samples ≤ D.info m s t (agents m) := by
  apply sup_le
  · apply iSup_le
    intro k
    apply iSup_le
    intro r
    by_cases h : k = m
    · subst k
      exact (D.own_local_measurable m s t (agents m) r).comap_le
    · exact (D.other_measurable m s t (agents m) k h (agents k) r).comap_le
  · apply iSup_le
    intro k
    apply iSup_le
    intro r
    have hm : Measurable[D.info m s t (agents m)] ((D.sensor k).message r) := by
      apply Measurable.const_mul
      apply Finset.measurable_sum
      intro j _
      by_cases h : k = m
      · subst k
        exact D.own_past_measurable m s t (agents m) j ⟨r,hpast r r.property⟩
      · exact D.other_measurable m s t (agents m) k h j r
    exact hm.comap_le

/-- Before any reception, other components' local observations still cannot
improve a component's fresh-local optimum. -/
theorem fresh_localInfo_le (agents : (m : ι) → Fin (p m).n) (t : ℝ) (m : ι) :
    (⨆ k, (D.sensor k).localInfo t (agents k)) ≤ D.localInfo m t (agents m) := by
  apply iSup_le
  intro k
  apply iSup_le
  intro r
  by_cases hkm : k = m
  · subst k
    have h := (comap_measurable
      (lin D.source (localObservation (p := p) m t (agents m) (Sum.inl r)))).mono
      (le_iSup (fun q => MeasurableSpace.comap
        (lin D.source (localObservation (p := p) m t (agents m) q)) inferInstance) (Sum.inl r)) le_rfl
    have hm : Measurable[D.localInfo m t (agents m)] ((D.sensor m).Y r (agents m) : Ω → ℝ) := by
      simpa only [localObservation, Sum.elim_inl, D.lin_embed, (D.sensor m).lin_atom,
        localInfo, historySigma, SensorModel.Y] using h
    exact hm.comap_le
  · let idx : Set.Iic t ⊕ ExtraIndex (p := p) m := Sum.inr ⟨⟨k,hkm⟩,(some (agents k),r)⟩
    have h := (comap_measurable
      (lin D.source (localObservation (p := p) m t (agents m) idx))).mono
      (le_iSup (fun q => MeasurableSpace.comap
        (lin D.source (localObservation (p := p) m t (agents m) q)) inferInstance) idx) le_rfl
    have hm : Measurable[D.localInfo m t (agents m)] ((D.sensor k).Y r (agents k) : Ω → ℝ) := by
      simpa only [idx, localObservation, Sum.elim_inr, lin, Finsupp.linearCombination_single,
        one_smul, localInfo, historySigma, SensorModel.Y, source] using h
    exact hm.comap_le

end PaperComponents
end
end LCSS
