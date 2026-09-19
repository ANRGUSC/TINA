import LCSS.Theorem1
import LCSS.RefreshCalculus

/-! Independent components, nonlinear cross-component policies, and the
connection from the Gaussian team to the exponential mixture in Theorem 2. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

theorem informationSpace_mono {G H : MeasurableSpace Ω} (h : G ≤ H) :
    informationSpace (mΩ := mΩ) (μ := μ) G ≤ informationSpace (mΩ := mΩ) (μ := μ) H := by
  letI : MeasurableSpace Ω := mΩ
  intro f hf
  exact mem_lpMeas_iff_aestronglyMeasurable.mpr
    ((mem_lpMeas_iff_aestronglyMeasurable.mp hf).mono h)

/-- Finite families of independent Gaussian processes are jointly Gaussian,
including when their time/index types are different and uncountable. -/
theorem gaussian_independent_family {ι : Type*} [Fintype ι] {J : ι → Type*}
    [∀ i, Nonempty (J i)] (S : (i : ι) → J i → RV (μ := μ))
    (hg : ∀ i, IsGaussianProcess (fun j => (S i j : Ω → ℝ)) μ)
    (hi : iIndepFun (fun i ω j => S i j ω) μ) :
    IsGaussianProcess (fun q : Sigma J => (S q.1 q.2 : Ω → ℝ)) μ := by
  classical
  constructor
  intro I
  let pick (i : ι) (q : I) : J i :=
    if h : q.1.1 = i then h ▸ q.1.2 else Classical.choice inferInstance
  let K (i : ι) : Finset (J i) := Finset.univ.image (pick i)
  let V (i : ι) (ω : Ω) (q : I) := S i (pick i q) ω
  have hV (i : ι) : HasGaussianLaw (V i) μ := by
    let L : (K i → ℝ) →L[ℝ] (I → ℝ) :=
      { toFun := fun z q => z ⟨pick i q, Finset.mem_image.mpr ⟨q, Finset.mem_univ _, rfl⟩⟩
        map_add' := by intros; rfl
        map_smul' := by intros; rfl }
    exact ((hg i).hasGaussianLaw (K i)).map L
  have hiV : iIndepFun V μ := hi.comp (fun i f q => f (pick i q))
    (fun i => measurable_pi_lambda _ (fun q => measurable_pi_apply _))
  let L : (ι → I → ℝ) →L[ℝ] (I → ℝ) :=
    { toFun := fun z q => z q.1.1 q
      map_add' := by intros; rfl
      map_smul' := by intros; rfl }
  have h := (iIndepFun.hasGaussianLaw hV hiV).map L
  simpa [L, V, pick, Function.comp_def, Finset.restrict_def] using h

theorem inner_lin_zero {J : Type*} (S : J → RV (μ := μ)) (R : RV (μ := μ))
    (h : ∀ j, ⟪S j,R⟫_ℝ = 0) (c : J →₀ ℝ) : ⟪lin S c,R⟫_ℝ = 0 := by
  induction c using Finsupp.induction_linear with
  | zero => simp
  | add c d hc hd => simp [map_add, inner_add_left, hc, hd]
  | single j r => simp [lin, h, real_inner_smul_left]

structure PaperComponents (ι : Type*) (p : ι → Parameters) where
  model : ∀ m, PaperModel (μ := μ) (p m)
  /-- Independence of complete component processes (signal and sensors).
  Since Yᵢ=X+Eᵢ, this is the paper's independence across components. -/
  independent : iIndepFun (fun m ω q => (model m).toSensorModel.source q ω) μ

namespace PaperComponents
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable (D : PaperComponents (μ := μ) ι p)

abbrev sensor (m : ι) := (D.model m).toSensorModel
abbrev source (q : (m : ι) × SourceIndex (p m).n) := (D.sensor q.1).source q.2

theorem gaussian : IsGaussianProcess (fun q => (D.source q : Ω → ℝ)) μ := by
  apply gaussian_independent_family (fun m => (D.sensor m).source)
  · exact fun m => (D.sensor m).gaussian
  · exact D.independent

theorem centered (q : (m : ι) × SourceIndex (p m).n) : (∫ ω, D.source q ω ∂μ) = 0 :=
  (D.sensor q.1).centered q.2

theorem cross_inner {m k : ι} (hmk : m ≠ k)
    (a : SourceIndex (p m).n) (b : SourceIndex (p k).n) :
    ⟪(D.sensor m).source a, (D.sensor k).source b⟫_ℝ = 0 := by
  rw [← covariance_eq_inner _ _ ((D.sensor m).centered a) ((D.sensor k).centered b)]
  exact ((D.independent.indepFun hmk).comp (measurable_pi_apply a) (measurable_pi_apply b)).covariance_eq_zero
    (Lp.memLp _) (Lp.memLp _)

def embed (m : ι) (c : SourceIndex (p m).n →₀ ℝ) :
    ((m : ι) × SourceIndex (p m).n) →₀ ℝ := Finsupp.mapDomain (Sigma.mk m) c

@[simp] theorem lin_embed (m : ι) (c : SourceIndex (p m).n →₀ ℝ) :
    lin D.source (embed (p := p) m c) = lin (D.sensor m).source c := by
  exact Finsupp.linearCombination_mapDomain (R := ℝ) (v' := D.source) (Sigma.mk m) c

/-- We enlarge other components' data all the way to their complete processes.
This makes the lower bound apply even to nonlinear cross-component policies. -/
abbrev ExtraIndex (m : ι) := (k : {k : ι // k ≠ m}) × SourceIndex (p k).n
abbrev ObservationIndex (m : ι) (s t : ℝ) := FullIndex (p m) s t ⊕ ExtraIndex (p := p) m

def observation (m : ι) (s t : ℝ) (i : Fin (p m).n) :
    ObservationIndex (p := p) m s t → ((m : ι) × SourceIndex (p m).n) →₀ ℝ :=
  Sum.elim (fun q => embed (p := p) m (fullObservation (p m) s t i q))
    (fun q => Finsupp.single ⟨q.1.val,q.2⟩ 1)

abbrev info (m : ι) (s t : ℝ) (i : Fin (p m).n) : MeasurableSpace Ω :=
  historySigma (fun q => lin D.source (observation (p := p) m s t i q))

theorem gradient_independent (m : ι) {s t : ℝ} (hst : s ≤ t) (i : Fin (p m).n) :
    Indep (MeasurableSpace.comap
      ((gradient (p m).κ ((D.sensor m).X t) ((D.sensor m).hybrid s t) i : RV (μ := μ)) : Ω → ℝ)
      inferInstance) (D.info m s t i) μ := by
  have he : gradient (p m).κ ((D.sensor m).X t) ((D.sensor m).hybrid s t) i =
      lin D.source (embed (p := p) m (gradientForm (p m) s t i)) := by simp only [D.lin_embed, (D.sensor m).lin_gradient]
  rw [he]
  apply lin_indep_history D.source D.gaussian D.centered
  intro q
  cases q with
  | inl q =>
      simp only [observation, Sum.elim_inl, D.lin_embed, (D.sensor m).lin_gradient]
      cases q with
      | inl q => simpa [fullObservation] using
          (D.sensor m).gradient_orthogonal_past hst q.2.property i q.1
      | inr r => simpa [fullObservation] using (D.sensor m).gradient_orthogonal_local s t r i
  | inr q =>
      simp only [observation, Sum.elim_inr, D.lin_embed, lin, Finsupp.linearCombination_single, one_smul]
      apply inner_lin_zero
      intro a
      exact D.cross_inner (Ne.symm q.1.property) a q.2

theorem hybrid_feasible (m : ι) {s t : ℝ} (hst : s ≤ t) (i : Fin (p m).n) :
    (D.sensor m).hybrid s t i ∈ informationSpace (μ := μ) (D.info m s t i) := by
  have hnow := history_mem (fun q => lin D.source (observation (p := p) m s t i q))
    (Sum.inl (Sum.inr (⟨t, by simp⟩ : Set.Iic t)))
  have hthen (j : Fin (p m).n) := history_mem
    (fun q => lin D.source (observation (p := p) m s t i q))
    (Sum.inl (Sum.inl (j, (⟨s, by simp⟩ : Set.Iic s))))
  simp only [observation, Sum.elim_inl, D.lin_embed, fullObservation, Sum.elim_inr,
    (D.sensor m).lin_atom] at *
  have hpool : (D.sensor m).pool s ∈ informationSpace (μ := μ) (D.info m s t i) :=
    (informationSpace _).smul_mem _ ((informationSpace _).sum_mem (fun j _ => hthen j))
  exact (informationSpace _).add_mem ((informationSpace _).smul_mem _ hpool)
    ((informationSpace _).smul_mem _ ((informationSpace _).sub_mem hnow
      ((informationSpace _).smul_mem _ (hthen i))))

theorem hybrid_minimal (m : ι) {s t : ℝ} (hst : s ≤ t) (u : Fin (p m).n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (D.info m s t i)) :
    expectedLoss (p m).κ ((D.sensor m).X t) ((D.sensor m).hybrid s t) ≤
      expectedLoss (p m).κ ((D.sensor m).X t) u := by
  simp only [expectedLoss_eq_teamCost]
  apply teamCost_minimal_of_orthogonal (p m).n_ne (p m).hκ
  intro i
  rw [real_inner_comm]
  apply inner_eq_zero_of_indep _ _ (historySigma_le _) (D.gradient_independent m hst i)
  · rw [← (D.sensor m).lin_gradient]
    exact integral_lin_zero (D.sensor m).source (D.sensor m).centered _
  · exact mem_lpMeas_iff_aestronglyMeasurable.mp
      ((informationSpace _).sub_mem (hu i) (D.hybrid_feasible m hst i))

def totalLoss (w : ι → ℝ) (t : ℝ) (u : (m : ι) → Fin (p m).n → RV (μ := μ)) : ℝ :=
  ∑ m, w m * expectedLoss (p m).κ ((D.sensor m).X t) (u m)

theorem total_minimal (w : ι → ℝ) (hw : ∀ m, 0 ≤ w m)
    {s t : ℝ} (hst : s ≤ t) (u : (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ m i, u m i ∈ informationSpace (μ := μ) (D.info m s t i)) :
    D.totalLoss w t (fun m => (D.sensor m).hybrid s t) ≤ D.totalLoss w t u := by
  exact Finset.sum_le_sum (fun m _ => mul_le_mul_of_nonneg_left
    (D.hybrid_minimal m hst (u m) (hu m)) (hw m))

end PaperComponents

end
end LCSS
