import LCSS

/-! An objective-correspondence check: two agents choose +1 and -1 while
tracking zero. Tracking loss and disagreement loss are both one. -/
example : LCSS.pointwiseLoss 1 (fun _ : Unit => (0 : ℝ))
    (fun (i : Fin 2) (_ : Unit) => if i = 0 then (1 : ℝ) else -1) () = 2 := by
  norm_num [LCSS.pointwiseLoss, Fin.sum_univ_two]

/-! A positive-latency check: at time 1/2 one message has been sent at 0,
but it will not arrive until time 1. Pending transmissions must be charged. -/
example : (LCSS.RefreshTrace.periodic 1 2 (by norm_num) (by norm_num) (1/2)).sent = 1 := by
  norm_num [LCSS.RefreshTrace.periodic]
example : (LCSS.RefreshTrace.periodic 1 2 (by norm_num) (by norm_num) (1/2)).received = 0 := by
  norm_num [LCSS.RefreshTrace.periodic]

/-! At horizon 3, sends at 0 and 2 arrive at 1 and 3. There is one complete
interval of length 2 and a zero-length terminal interval, with two charges. -/
example {ι : Type*} [Fintype ι] [Nonempty ι] (q : LCSS.RefreshMixture ι) (b c : ℝ) :
    (LCSS.RefreshTrace.periodic 1 2 (by norm_num) (by norm_num) 3).cost q b c =
      3*b+2*c-q.benefit 2 := by
  rw [LCSS.RefreshTrace.periodic_cost q b c 1 2 (by norm_num) (by norm_num) (by norm_num)]
  have hf : ⌊(3 : ℝ)/2⌋₊ = 1 := by
    exact (Nat.floor_eq_iff (by norm_num)).mpr (by norm_num)
  norm_num [hf]
  <;> ring

-- Boundary and semantic regression examples.

set_option autoImplicit false
noncomputable section
open LCSS

def reviewParameters : Parameters where
  n := 2
  hn := by norm_num
  a := 1
  b := 1
  rate := 1
  κ := 0
  ha := by norm_num
  hb := by norm_num
  hrate := by norm_num
  hκ := by norm_num

example : reviewParameters.localCost = 1/2 ∧
    reviewParameters.pooledCost = 1/3 ∧ reviewParameters.delta = 1/6 := by
  norm_num [reviewParameters, Parameters.localCost, Parameters.pooledCost,
    Parameters.delta, Parameters.v, Parameters.d]

example (p : Parameters) : p.n ≠ 1 := by
  have := p.hn
  omega

example (p : Parameters) : p.hybridCost 0 = p.pooledCost ∧
    p.hybridVariance 0 = p.pooledVariance :=
  ⟨p.hybridCost_zero, p.hybridVariance_zero⟩

def reviewMixture : RefreshMixture Unit where
  amplitude _ := 1
  rate _ := 1
  amplitude_pos _ := by norm_num
  rate_pos _ := by norm_num

example : reviewMixture.threshold = 1 := by
  simp [reviewMixture, RefreshMixture.threshold]

example : ∃! T : ℝ, 0 < T ∧ reviewMixture.marginal T = 1/2 := by
  apply reviewMixture.exists_unique_period (by norm_num)
  norm_num [reviewMixture, RefreshMixture.threshold]

example (T : ℝ) : 0 ≤ (1 : ℝ) - reviewMixture.benefit T := by
  apply reviewMixture.interval_bound_above_threshold
  simp [reviewMixture, RefreshMixture.threshold]

example : (RefreshTrace.periodic 0 1 (by norm_num) (by norm_num) 0).sent = 1 ∧
    (RefreshTrace.periodic 0 1 (by norm_num) (by norm_num) 0).received = 1 := by
  norm_num [RefreshTrace.periodic, RefreshTrace.periodicAfter]

example : (RefreshTrace.periodic 3 1 (by norm_num) (by norm_num) 1).sent = 2 ∧
    (RefreshTrace.periodic 3 1 (by norm_num) (by norm_num) 1).received = 0 := by
  norm_num [RefreshTrace.periodic]

example {Ω : Type*} [MeasurableSpace Ω] {μ : MeasureTheory.Measure Ω}
    [MeasureTheory.IsProbabilityMeasure μ] {p : Parameters}
    (M : SensorModel (μ := μ) p) (t : ℝ) : M.X t ≠ 0 := by
  intro h
  have hn := M.norm_X_sq t
  rw [h] at hn
  simp only [norm_zero, zero_pow (by norm_num : 2 ≠ 0)] at hn
  linarith [p.ha]

-- Physical schedules: negative horizons, pending messages, and exact receipt.
example (R : ℝ) : PhysicalSchedule.none.count R = 0 := PhysicalSchedule.none_count R
example : (PhysicalSchedule.periodic 2 (by norm_num)).count (-1) = 0 :=
  PhysicalSchedule.count_of_neg _ (by norm_num)
example : ((PhysicalSchedule.periodic 2 (by norm_num)).trace 1 (by norm_num) (1/2)).sent = 1 := by
  rw [PhysicalSchedule.trace_sent, PhysicalSchedule.periodic_count _ _ (by norm_num)]
  norm_num
example : ((PhysicalSchedule.periodic 2 (by norm_num)).trace 1 (by norm_num) (1/2)).received = 0 := by
  rw [PhysicalSchedule.trace_received]
  exact PhysicalSchedule.count_of_neg _ (by norm_num)
example : ((PhysicalSchedule.periodic 2 (by norm_num)).trace 1 (by norm_num) 3).received = 2 := by
  rw [PhysicalSchedule.trace_received, PhysicalSchedule.periodic_count _ _ (by norm_num)]
  norm_num
-- The finite witness has unit covariance at a real sample time, not a zero process.
example : ProbabilityTheory.covariance
    (FiniteGaussianWitness.value 1 {0,1} ⟨0, by simp⟩)
    (FiniteGaussianWitness.value 1 {0,1} ⟨0, by simp⟩)
    (FiniteGaussianWitness.law 1 {0,1}) = 1 :=
  (FiniteGaussianWitness.finite_ou_witness 1 (by norm_num) {0,1}).2.2.2.2 _

-- Strict reception: at send time 2 the sample from 2 is not yet available;
-- immediately later both the 0 and 2 samples are available (zero latency).
example : (PhysicalSchedule.periodic 2 (by norm_num)).strictCount 2 = 1 := by
  apply Nat.le_antisymm
  · by_contra h
    have hh := ((PhysicalSchedule.periodic 2 (by norm_num)).strictCount_spec 2 1).mp
      (Nat.lt_of_not_ge h)
    norm_num [PhysicalSchedule.periodic] at hh
  · apply ((PhysicalSchedule.periodic 2 (by norm_num)).strictCount_spec 2 0).mpr
    norm_num [PhysicalSchedule.periodic]

example : (PhysicalSchedule.periodic 2 (by norm_num)).strictCount (5/2) = 2 := by
  apply Nat.le_antisymm
  · by_contra h
    have hh := ((PhysicalSchedule.periodic 2 (by norm_num)).strictCount_spec (5/2) 2).mp
      (Nat.lt_of_not_ge h)
    norm_num [PhysicalSchedule.periodic] at hh
  · apply ((PhysicalSchedule.periodic 2 (by norm_num)).strictCount_spec (5/2) 1).mpr
    norm_num [PhysicalSchedule.periodic]

-- Finite, coincident transmissions: both are charged, neither is received
-- under the strict convention at time zero, and both are received later.
def reviewDuplicateSchedule : PhysicalSchedule where
  active := Set.Iio 2
  active_lower := by intro i j hij hj; exact lt_of_le_of_lt hij hj
  send _ := 0
  ordered := monotone_const
  nonnegative _ _ := le_rfl
  locally_finite _ := (Set.finite_Iio 2).subset (fun _ h => h.1)

example : reviewDuplicateSchedule.count 0 = 2 ∧ reviewDuplicateSchedule.strictCount 0 = 0 ∧
    reviewDuplicateSchedule.strictCount 1 = 2 := by
  have hc : reviewDuplicateSchedule.count 0 = 2 := by
    apply Nat.le_antisymm
    · by_contra h
      have hh := (reviewDuplicateSchedule.count_spec 0 2).mp (Nat.lt_of_not_ge h)
      norm_num [reviewDuplicateSchedule] at hh
    · exact (reviewDuplicateSchedule.count_spec 0 1).mpr (by norm_num [reviewDuplicateSchedule])
  have hz : reviewDuplicateSchedule.strictCount 0 = 0 := by
    by_contra h
    have hh := (reviewDuplicateSchedule.strictCount_spec 0 0).mp (Nat.pos_of_ne_zero h)
    norm_num [reviewDuplicateSchedule] at hh
  refine ⟨hc,hz,?_⟩
  apply Nat.le_antisymm
  · by_contra h
    have hh := (reviewDuplicateSchedule.strictCount_spec 1 2).mp (Nat.lt_of_not_ge h)
    norm_num [reviewDuplicateSchedule] at hh
  · exact (reviewDuplicateSchedule.strictCount_spec 1 1).mpr (by norm_num [reviewDuplicateSchedule])

-- Coordinatewise equality does not permit an uncountable intersection.
section RawHistoryRegression
open MeasureTheory Filter
open scoped ENNReal
variable {μ : Measure ℝ} [IsProbabilityMeasure μ] [NullSingletonClass μ]

example : (∀ t : ℝ, (fun ω : ℝ => if ω = t then (1 : ℝ) else 0) =ᵐ[μ] (fun _ => 0)) ∧
    ¬ (∀ᵐ ω ∂μ, ∀ t : ℝ, (if ω = t then (1 : ℝ) else 0) = 0) := by
  constructor
  · intro t
    filter_upwards [μ.ae_ne t] with ω hω
    simp [hω]
  · intro h
    obtain ⟨ω, hω⟩ := h.exists
    simpa using hω ω

example : informationSpace (μ := μ)
      (⨆ t : ℝ, MeasurableSpace.comap (fun ω : ℝ => if ω = t then (1 : ℝ) else 0) inferInstance) =
    informationSpace (μ := μ)
      (⨆ _t : ℝ, MeasurableSpace.comap (fun _ω : ℝ => (0 : ℝ)) inferInstance) := by
  apply informationSpace_iSup_comap_congr
  intro t
  filter_upwards [μ.ae_ne t] with ω hω
  simp [hω]

-- The raw interface derives section integrability and preserves primitive classes.
example {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
    {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)
    (m : ι) (c : Option (Fin (p m).n)) (t : ℝ) :
    (B.component_memLp m c t).toLp (B.component m c t) = (D.model m).component c t :=
  B.component_toLp m c t
end RawHistoryRegression

-- Non-strict receipt differs at the delayed endpoint; the latest sample is usable.
example : (2 : ℝ) ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receivedBy 1 3 ∧
    (2 : ℝ) ∉ (PhysicalSchedule.periodic 2 (by norm_num)).receivedBefore 1 3 := by
  constructor
  · exact ⟨1, by trivial, by norm_num [PhysicalSchedule.periodic], by norm_num [PhysicalSchedule.periodic]⟩
  · rintro ⟨k,_,hk,he⟩
    linarith

-- Empty schedules supply neither received samples nor endpoint exceptions.
example : PhysicalSchedule.none.receivedBy 0 0 = ∅ ∧
    PhysicalSchedule.none.receptionTimes 0 = ∅ := by
  simp [PhysicalSchedule.receivedBy, PhysicalSchedule.receptionTimes, PhysicalSchedule.none]

-- Duplicate transmissions give one observed sample value, while retaining two charges.
example : reviewDuplicateSchedule.receivedBy 0 0 = {0} ∧
    reviewDuplicateSchedule.receptionTimes 0 = {0} ∧ reviewDuplicateSchedule.count 0 = 2 := by
  have hr : reviewDuplicateSchedule.receivedBy 0 0 = {0} := by
    ext r
    constructor
    · rintro ⟨k,_,_,he⟩
      simpa [reviewDuplicateSchedule] using he
    · intro h
      exact ⟨0, by norm_num [reviewDuplicateSchedule], by norm_num [reviewDuplicateSchedule],
        by simpa [reviewDuplicateSchedule] using h⟩
  have he : reviewDuplicateSchedule.receptionTimes 0 = {0} := by
    ext t
    constructor
    · rintro ⟨k,_,rfl⟩
      simp [reviewDuplicateSchedule]
    · intro h
      exact ⟨0, by norm_num [reviewDuplicateSchedule], by simpa [reviewDuplicateSchedule] using h.symm⟩
  refine ⟨hr,he,?_⟩
  apply Nat.le_antisymm
  · by_contra h
    have hh := (reviewDuplicateSchedule.count_spec 0 2).mp (Nat.lt_of_not_ge h)
    norm_num [reviewDuplicateSchedule] at hh
  · exact (reviewDuplicateSchedule.count_spec 0 1).mpr (by norm_num [reviewDuplicateSchedule])

-- Zero-delay receipt at startup is allowed by the new set, while strict receipt is empty.
example : (0 : ℝ) ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receivedBy 0 0 ∧
    (PhysicalSchedule.periodic 2 (by norm_num)).receivedBefore 0 0 = ∅ := by
  constructor
  · exact ⟨0, by trivial, by norm_num [PhysicalSchedule.periodic], by norm_num [PhysicalSchedule.periodic]⟩
  · apply Set.eq_empty_iff_forall_notMem.mpr
    rintro r ⟨k,hk,ht,_⟩
    have hn := (PhysicalSchedule.periodic 2 (by norm_num)).nonnegative k hk
    linarith

open scoped ENNReal Classical

-- Infinite endpoint values do not change a finite running integral.
open MeasureTheory Filter Set in
example : (∫⁻ t in Ioc (0 : ℝ) 5,
    if t ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receptionTimes 1
    then (⊤ : ℝ≥0∞) else 1) = 5 := by
  have h : (fun t : ℝ => if t ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receptionTimes 1
      then (⊤ : ℝ≥0∞) else 1) =ᵐ[volume] fun _ => 1 := by
    filter_upwards [(PhysicalSchedule.periodic 2 (by norm_num)).ae_not_reception 1] with t ht
    simp [ht]
  rw [lintegral_congr_ae (ae_restrict_of_ae h)]
  norm_num [Real.volume_Ioc]

-- Removing the countable endpoint set does not make an infinite objective finite.
open MeasureTheory Filter Set in
example : (∫⁻ t in Ioc (0 : ℝ) 5,
    if t ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receptionTimes 1
    then (0 : ℝ≥0∞) else ⊤) = ⊤ := by
  have h : (fun t : ℝ => if t ∈ (PhysicalSchedule.periodic 2 (by norm_num)).receptionTimes 1
      then (0 : ℝ≥0∞) else ⊤) =ᵐ[volume] fun _ => ⊤ := by
    filter_upwards [(PhysicalSchedule.periodic 2 (by norm_num)).ae_not_reception 1] with t ht
    simp [ht]
  rw [lintegral_congr_ae (ae_restrict_of_ae h)]
  norm_num [Real.volume_Ioc]

open scoped ProbabilityTheory

-- C3: a concrete two-component, two-agent probability model, without model inputs.
def reviewFamily (_ : Fin 2) : Parameters := reviewParameters

example : ∃ D : PaperComponents (μ := IndependentOU.law reviewFamily) (Fin 2) reviewFamily,
    Nonempty (RawRealization D) := by
  exact ⟨IndependentOU.components reviewFamily, ⟨IndependentOU.realization reviewFamily⟩⟩

-- Negative times belong to the same nondegenerate probability model.
example : cov[IndependentOU.raw reviewFamily 0 none (-7),
    IndependentOU.raw reviewFamily 0 none (-7); IndependentOU.law reviewFamily] = 1 := by
  rw [IndependentOU.raw_covariance]
  norm_num [componentVariance, reviewFamily, reviewParameters, kernel]

-- Covariance across the origin has the prescribed exponential decay.
example : cov[IndependentOU.raw reviewFamily 1 (some ⟨0, by decide⟩) (-1),
    IndependentOU.raw reviewFamily 1 (some ⟨0, by decide⟩) 1; IndependentOU.law reviewFamily] =
      Real.exp (-2) := by
  rw [IndependentOU.raw_covariance]
  norm_num [componentVariance, reviewFamily, reviewParameters, kernel]

-- Distinct signal/error and component paths share one fully independent family.
example : ProbabilityTheory.iIndepFun
    (fun (q : IndependentOU.PrimitiveIndex reviewFamily) ω t =>
      IndependentOU.raw reviewFamily q.1 q.2 t ω) (IndependentOU.law reviewFamily) :=
  IndependentOU.raw_all_independent reviewFamily

-- A nonempty paper claim is instantiated on the constructed model.
example : Theorem1Claims (IndependentOU.model reviewFamily 0).toSensorModel (-3) 2 :=
  theorem1_ou reviewFamily 0 (-3) 2 (by norm_num)
