import LCSS.RefreshBridge

/-! Fresh-local operation before the first reception, allowing independent
other-component information. This closes the initial-interval bound. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

namespace PaperComponents
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p)

def localObservation (m : ι) (t : ℝ) (i : Fin (p m).n) :
    Set.Iic t ⊕ ExtraIndex (p := p) m → ((m : ι) × SourceIndex (p m).n) →₀ ℝ :=
  Sum.elim (fun r => embed (p := p) m (atom (some i) r))
    (fun q => Finsupp.single ⟨q.1.val,q.2⟩ 1)

abbrev localInfo (m : ι) (t : ℝ) (i : Fin (p m).n) : MeasurableSpace Ω :=
  historySigma (fun q => lin D.source (localObservation (p := p) m t i q))

theorem local_gradient_independent (m : ι) (t : ℝ) (i : Fin (p m).n) :
    Indep (MeasurableSpace.comap
      ((gradient (p m).κ ((D.sensor m).X t) ((D.sensor m).localPolicy t) i : RV (μ := μ)) : Ω → ℝ)
      inferInstance) (D.localInfo m t i) μ := by
  have he : gradient (p m).κ ((D.sensor m).X t) ((D.sensor m).localPolicy t) i =
      lin D.source (embed (p := p) m (SensorModel.localGradientForm (p m) t i)) := by
    simp only [D.lin_embed, (D.sensor m).lin_localGradient]
  rw [he]
  apply lin_indep_history D.source D.gaussian D.centered
  intro q
  cases q with
  | inl r =>
      simp only [localObservation, Sum.elim_inl, D.lin_embed, (D.sensor m).lin_localGradient,
        (D.sensor m).lin_atom]
      exact (D.sensor m).local_gradient_orthogonal t r i
  | inr q =>
      simp only [localObservation, Sum.elim_inr, D.lin_embed, lin,
        Finsupp.linearCombination_single, one_smul]
      apply inner_lin_zero
      intro a
      exact D.cross_inner (Ne.symm q.1.property) a q.2

theorem local_feasible (m : ι) (t : ℝ) (i : Fin (p m).n) :
    (D.sensor m).localPolicy t i ∈ informationSpace (μ := μ) (D.localInfo m t i) := by
  have hnow := history_mem (fun q => lin D.source (localObservation (p := p) m t i q))
    (Sum.inl (⟨t, by simp⟩ : Set.Iic t))
  simp only [localObservation, Sum.elim_inl, D.lin_embed, (D.sensor m).lin_atom] at hnow
  exact (informationSpace _).smul_mem _ hnow

theorem local_minimal (m : ι) (t : ℝ) (u : Fin (p m).n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (D.localInfo m t i)) :
    expectedLoss (p m).κ ((D.sensor m).X t) ((D.sensor m).localPolicy t) ≤
      expectedLoss (p m).κ ((D.sensor m).X t) u := by
  simp only [expectedLoss_eq_teamCost]
  apply teamCost_minimal_of_orthogonal (p m).n_ne (p m).hκ
  intro i
  rw [real_inner_comm]
  apply inner_eq_zero_of_indep _ _ (historySigma_le _) (D.local_gradient_independent m t i)
  · rw [← (D.sensor m).lin_localGradient]
    exact integral_lin_zero (D.sensor m).source (D.sensor m).centered _
  · exact mem_lpMeas_iff_aestronglyMeasurable.mp
      ((informationSpace _).sub_mem (hu i) (D.local_feasible m t i))

theorem total_local_cost (w : ι → ℝ) (t : ℝ) :
    D.totalLoss w t (fun m => (D.sensor m).localPolicy t) = RefreshMixture.baseline p w := by
  simp only [totalLoss, expectedLoss_eq_teamCost, (D.sensor _).local_cost, RefreshMixture.baseline]

theorem local_lower_bound (w : ι → ℝ) (hw : ∀ m, 0 ≤ w m) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ m i, u m i ∈ informationSpace (μ := μ) (D.localInfo m t i)) :
    RefreshMixture.baseline p w ≤ D.totalLoss w t u := by
  rw [← D.total_local_cost w t]
  exact Finset.sum_le_sum (fun m _ => mul_le_mul_of_nonneg_left
    (D.local_minimal m t (u m) (hu m)) (hw m))

end PaperComponents
end
end LCSS
