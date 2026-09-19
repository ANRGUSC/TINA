import LCSS.Model
import Mathlib.MeasureTheory.Function.ConditionalExpectation.CondexpL2

set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

abbrev informationSpace (G : MeasurableSpace Ω) : Submodule ℝ (RV (mΩ := mΩ) (μ := μ)) := by
  letI : MeasurableSpace Ω := mΩ
  exact lpMeas ℝ ℝ G (2 : ℝ≥0∞) μ

theorem history_mem {J : Type*} (Y : J → RV (μ := μ)) (j : J) :
    Y j ∈ informationSpace (μ := μ) (historySigma Y) := by
  apply mem_lpMeas_iff_aestronglyMeasurable.mpr
  exact ((comap_measurable (Y j)).mono (le_iSup (fun j =>
    MeasurableSpace.comap (Y j) inferInstance) j) le_rfl).stronglyMeasurable.aestronglyMeasurable

abbrev atom {n : ℕ} (c : Option (Fin n)) (t : ℝ) : SourceIndex n →₀ ℝ :=
  Finsupp.single (c,t) 1
def poolForm (p : Parameters) (t : ℝ) : SourceIndex p.n →₀ ℝ :=
  (p.n : ℝ)⁻¹ • ∑ i, atom (some i) t
def hybridForm (p : Parameters) (s t : ℝ) (i : Fin p.n) : SourceIndex p.n →₀ ℝ :=
  (kernel p.rate t s * (p.a / p.v)) • poolForm p s +
    (p.a / p.d) • (atom (some i) t - kernel p.rate t s • atom (some i) s)
def posteriorForm (p : Parameters) (s t : ℝ) (i : Fin p.n) : SourceIndex p.n →₀ ℝ :=
  (kernel p.rate t s * (p.a / p.v)) • poolForm p s +
    (p.a / (p.a + p.b)) • (atom (some i) t - kernel p.rate t s • atom (some i) s)
def gradientForm (p : Parameters) (s t : ℝ) (i : Fin p.n) : SourceIndex p.n →₀ ℝ :=
  (1+p.κ) • hybridForm p s t i - p.κ • ((p.n : ℝ)⁻¹ • ∑ j, hybridForm p s t j) - atom none t

abbrev FullIndex (p : Parameters) (s t : ℝ) :=
  (Fin p.n × Set.Iic s) ⊕ Set.Iic t
abbrev HybridIndex (s t : ℝ) := Set.Iic t ⊕ Set.Iic s

def fullObservation (p : Parameters) (s t : ℝ) (i : Fin p.n) :
    FullIndex p s t → SourceIndex p.n →₀ ℝ :=
  Sum.elim (fun q => atom (some q.1) q.2) (fun r => atom (some i) r)
def hybridObservation (p : Parameters) (s t : ℝ) (i : Fin p.n) :
    HybridIndex s t → SourceIndex p.n →₀ ℝ :=
  Sum.elim (fun r => atom (some i) r) (fun r => poolForm p r)

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

@[simp] theorem lin_atom (c : Option (Fin p.n)) (t : ℝ) :
    lin M.source (atom c t) = M.source (c,t) := by simp [atom]
@[simp] theorem lin_pool (t : ℝ) : lin M.source (poolForm p t) = M.pool t := by
  simp [poolForm, pool, average]
@[simp] theorem lin_hybrid (s t : ℝ) (i : Fin p.n) :
    lin M.source (hybridForm p s t i) = M.hybrid s t i := by
  simp [hybridForm, hybrid, prediction, innovation]
@[simp] theorem lin_posterior (s t : ℝ) (i : Fin p.n) :
    lin M.source (posteriorForm p s t i) = M.posterior s t i := by
  simp [posteriorForm, posterior, prediction, innovation]
@[simp] theorem lin_gradient (s t : ℝ) (i : Fin p.n) :
    lin M.source (gradientForm p s t i) = gradient p.κ (M.X t) (M.hybrid s t) i := by
  simp [gradientForm, gradient, average]

def fullInfo (s t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  historySigma (fun q => lin M.source (fullObservation p s t i q))
def hybridInfo (s t : ℝ) (i : Fin p.n) : MeasurableSpace Ω :=
  historySigma (fun q => lin M.source (hybridObservation p s t i q))

theorem gradient_indep_full {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Indep (MeasurableSpace.comap ((gradient p.κ (M.X t) (M.hybrid s t) i : RV (μ := μ)) : Ω → ℝ) inferInstance)
      (M.fullInfo s t i) μ := by
  rw [← M.lin_gradient]
  apply lin_indep_history M.source M.gaussian M.centered
  intro q
  cases q with
  | inl q =>
      simpa [fullObservation] using M.gradient_orthogonal_past hst q.2.property i q.1
  | inr r =>
      simpa [fullObservation] using M.gradient_orthogonal_local s t r i

theorem gradient_indep_hybrid {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    Indep (MeasurableSpace.comap ((gradient p.κ (M.X t) (M.hybrid s t) i : RV (μ := μ)) : Ω → ℝ) inferInstance)
      (M.hybridInfo s t i) μ := by
  rw [← M.lin_gradient]
  apply lin_indep_history M.source M.gaussian M.centered
  intro q
  cases q with
  | inl r =>
      simpa [hybridObservation] using M.gradient_orthogonal_local s t r i
  | inr r =>
      simp only [hybridObservation, Sum.elim_inr, M.lin_gradient, M.lin_pool,
        pool, average, inner_smul_right, inner_sum]
      simp [M.gradient_orthogonal_past hst r.property]

theorem hybrid_feasible_hybrid {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.hybrid s t i ∈ informationSpace (μ := μ) (M.hybridInfo s t i) := by
  have hnow := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inl (⟨t, by simp⟩ : Set.Iic t))
  have hthen := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inl (⟨s, by simpa only [Set.mem_Iic] using hst⟩ : Set.Iic t))
  have hpool := history_mem (fun q => lin M.source (hybridObservation p s t i q))
    (Sum.inr (⟨s, by simp⟩ : Set.Iic s))
  simp only [hybridObservation, Sum.elim_inl, Sum.elim_inr, M.lin_atom, M.lin_pool] at *
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hpool)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hnow
      ((informationSpace _).smul_mem _ hthen)))

theorem hybrid_feasible_full {s t : ℝ} (hst : s ≤ t) (i : Fin p.n) :
    M.hybrid s t i ∈ informationSpace (μ := μ) (M.fullInfo s t i) := by
  have hnow := history_mem (fun q => lin M.source (fullObservation p s t i q))
    (Sum.inr (⟨t, by simp⟩ : Set.Iic t))
  have hthen (j : Fin p.n) := history_mem
    (fun q => lin M.source (fullObservation p s t i q))
    (Sum.inl (j, (⟨s, by simp⟩ : Set.Iic s)))
  simp only [fullObservation, Sum.elim_inl, Sum.elim_inr, M.lin_atom] at *
  have hpool : M.pool s ∈ informationSpace (μ := μ) (M.fullInfo s t i) :=
    (informationSpace _).smul_mem _ ((informationSpace _).sum_mem (fun j _ => hthen j))
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hpool)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hnow
      ((informationSpace _).smul_mem _ (hthen i))))

theorem hybrid_minimal_full {s t : ℝ} (hst : s ≤ t) (u : Fin p.n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (M.fullInfo s t i)) :
    teamCost p.κ (M.X t) (M.hybrid s t) ≤ teamCost p.κ (M.X t) u := by
  apply teamCost_minimal_of_orthogonal p.n_ne p.hκ
  intro i
  rw [real_inner_comm]
  apply inner_eq_zero_of_indep _ _ (historySigma_le _)
    (M.gradient_indep_full hst i)
  · rw [← M.lin_gradient]
    exact integral_lin_zero M.source M.centered _
  · exact mem_lpMeas_iff_aestronglyMeasurable.mp
      ((informationSpace _).sub_mem (hu i) (M.hybrid_feasible_full hst i))

theorem hybrid_minimal_hybrid {s t : ℝ} (hst : s ≤ t) (u : Fin p.n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (M.hybridInfo s t i)) :
    teamCost p.κ (M.X t) (M.hybrid s t) ≤ teamCost p.κ (M.X t) u := by
  apply teamCost_minimal_of_orthogonal p.n_ne p.hκ
  intro i
  rw [real_inner_comm]
  apply inner_eq_zero_of_indep _ _ (historySigma_le _)
    (M.gradient_indep_hybrid hst i)
  · rw [← M.lin_gradient]
    exact integral_lin_zero M.source M.centered _
  · exact mem_lpMeas_iff_aestronglyMeasurable.mp
      ((informationSpace _).sub_mem (hu i) (M.hybrid_feasible_hybrid hst i))

end SensorModel
end
end LCSS
