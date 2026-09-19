import LCSS.RefreshSchedules

/-! Actual periodic transmission counts, fixed latency, the incomplete final
interval, and convergence of the finite-horizon cost to the period formula. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open Filter Set MeasureTheory
open scoped Topology BigOperators ENNReal

namespace RefreshTrace

abbrev periodicAfter (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) (R : ℝ) (h : δ ≤ R) : RefreshTrace R :=
    { received := ⌊(R-δ)/T⌋₊+1
      duration := Fin.lastCases (R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T) (fun _ => T)
      duration_nonneg := by
        apply Fin.lastCases
        · simp only [Fin.lastCases_last]
          have hf := Nat.floor_le (div_nonneg (sub_nonneg.mpr h) hT.le)
          have hf' := (le_div_iff₀ hT).mp hf
          linarith
        · intro _; simpa only [Fin.lastCases_castSucc] using hT.le
      coverage := by
        rw [Fin.sum_univ_castSucc]
        simp only [Fin.lastCases_castSucc, Fin.lastCases_last, Finset.sum_const,
          Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        have := le_max_left R 0
        linarith
      sent := ⌊R/T⌋₊+1
      received_le_sent := Nat.add_le_add_right (Nat.floor_mono
        (div_le_div_of_nonneg_right (by linarith) hT.le)) 1 }

abbrev periodic (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) (R : ℝ) : RefreshTrace R :=
  if h : δ ≤ R then periodicAfter δ T hδ hT R h
  else
    { received := 0
      duration := Fin.elim0
      duration_nonneg := fun i => Fin.elim0 i
      coverage := by simp
      sent := ⌊R/T⌋₊+1
      received_le_sent := Nat.zero_le _ }


theorem periodic_eq_after (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) {R : ℝ} (hR : δ ≤ R) :
    periodic δ T hδ hT R = periodicAfter δ T hδ hT R hR := dif_pos hR

theorem periodic_cost {ι : Type*} [Fintype ι] [Nonempty ι] (q : RefreshMixture ι)
    (baseline c δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) {R : ℝ} (hR : δ ≤ R) :
    (periodic δ T hδ hT R).cost q baseline c = baseline*R + c*((⌊R/T⌋₊ : ℝ)+1) -
      ((⌊(R-δ)/T⌋₊ : ℝ)*q.benefit T + q.benefit (R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T)) := by
  simp only [periodic, dif_pos hR, periodicAfter]
  simp only [cost, max_eq_left (hδ.trans hR), Nat.cast_add,
    Nat.cast_one, Fin.sum_univ_castSucc, Fin.lastCases_castSucc, Fin.lastCases_last,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- The count is exactly that of send times kT with k ≥ 0. -/
theorem periodic_sent_iff (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T)
    {R : ℝ} (hR : 0 ≤ R) (k : ℕ) :
    k < (periodic δ T hδ hT R).sent ↔ (k : ℝ)*T ≤ R := by
  have he : (periodic δ T hδ hT R).sent = ⌊R/T⌋₊+1 := by
    unfold periodic
    split <;> rfl
  rw [he, Nat.lt_add_one_iff, Nat.le_floor_iff (div_nonneg hR hT.le), le_div_iff₀ hT]

/-- The count is exactly that of arrival times δ+kT. -/
theorem periodic_received_iff (δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T)
    {R : ℝ} (hR : 0 ≤ R) (k : ℕ) :
    k < (periodic δ T hδ hT R).received ↔ δ+(k : ℝ)*T ≤ R := by
  unfold periodic
  split_ifs with h
  · simp only [Nat.lt_add_one_iff, Nat.le_floor_iff (div_nonneg (sub_nonneg.mpr h) hT.le),
      le_div_iff₀ hT]
    constructor <;> intro hk <;> linarith
  · simp only [Nat.not_lt_zero, false_iff, not_le]
    nlinarith [Nat.cast_nonneg (α := ℝ) k]

end RefreshTrace

namespace RefreshMixture
variable {ι : Type*} [Fintype ι] [Nonempty ι] (q : RefreshMixture ι)

theorem floor_ratio_tendsto (δ T : ℝ) (hT : 0 < T) :
    Tendsto (fun R : ℝ => (⌊(R-δ)/T⌋₊ : ℝ)/R) atTop (𝓝 (1/T)) := by
  have lo : Tendsto (fun R : ℝ => 1/T-(δ/T+1)/R) atTop (𝓝 (1/T)) := by
    simpa only [sub_zero, id_eq] using (tendsto_const_nhds (x := 1/T)).sub
      ((tendsto_const_nhds (x := δ/T+1)).div_atTop (tendsto_id (α := ℝ)))
  have hi : Tendsto (fun R : ℝ => 1/T-(δ/T)/R) atTop (𝓝 (1/T)) := by
    simpa only [sub_zero, id_eq] using (tendsto_const_nhds (x := 1/T)).sub
      ((tendsto_const_nhds (x := δ/T)).div_atTop (tendsto_id (α := ℝ)))
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' lo hi
  · filter_upwards [eventually_gt_atTop (max δ 0)] with R hR
    have hR0 : 0 < R := lt_of_le_of_lt (le_max_right δ 0) hR
    rw [le_div_iff₀ hR0]
    have hf := (Nat.lt_floor_add_one ((R-δ)/T)).le
    have he : (1/T-(δ/T+1)/R)*R = (R-δ)/T-1 := by field_simp <;> ring
    rw [he]
    linarith
  · filter_upwards [eventually_gt_atTop (max δ 0)] with R hR
    have hR0 : 0 < R := lt_of_le_of_lt (le_max_right δ 0) hR
    have hRδ : δ ≤ R := (le_max_left δ 0).trans hR.le
    rw [div_le_iff₀ hR0]
    have he : (1/T-(δ/T)/R)*R = (R-δ)/T := by field_simp <;> ring
    rw [he]
    exact Nat.floor_le (div_nonneg (sub_nonneg.mpr hRδ) hT.le)

theorem tail_benefit_ratio_tendsto (δ T : ℝ) (hT : 0 < T) :
    Tendsto (fun R => q.benefit (R-δ-(⌊(R-δ)/T⌋₊ : ℝ)*T)/R) atTop (𝓝 0) := by
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds
    (tendsto_const_nhds.div_atTop tendsto_id)
  · filter_upwards [eventually_gt_atTop (max δ 0)] with R hR
    have hR0 : 0 < R := lt_of_le_of_lt (le_max_right δ 0) hR
    have hRδ : δ ≤ R := (le_max_left δ 0).trans hR.le
    have hf := (le_div_iff₀ hT).mp (Nat.floor_le (div_nonneg (sub_nonneg.mpr hRδ) hT.le))
    exact div_nonneg (q.benefit_nonneg (by linarith)) hR0.le
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
    exact div_le_div_of_nonneg_right (q.benefit_le_threshold _) hR.le

theorem periodic_cost_tendsto (baseline c δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) :
    Tendsto (fun R => (RefreshTrace.periodic δ T hδ hT R).cost q baseline c / R)
      atTop (𝓝 (q.periodCost baseline c T)) := by
  have hs : Tendsto (fun R : ℝ => c*((⌊R/T⌋₊ : ℝ)/R+1/R)) atTop (𝓝 (c/T)) := by
    have h := ((floor_ratio_tendsto 0 T hT).add
      ((tendsto_const_nhds (x := (1 : ℝ))).div_atTop (tendsto_id (α := ℝ)))).const_mul c
    simpa [div_eq_mul_inv] using h
  have hr := (floor_ratio_tendsto δ T hT).mul_const (q.benefit T)
  have ht := q.tail_benefit_ratio_tendsto δ T hT
  have h := ((tendsto_const_nhds (x := baseline)).add hs).sub (hr.add ht)
  have hlim : baseline+c/T-((1/T)*q.benefit T+0) = q.periodCost baseline c T := by
    dsimp [periodCost]; ring
  rw [hlim] at h
  apply h.congr'
  filter_upwards [eventually_gt_atTop (max δ 0)] with R hR
  have hR0 : 0 < R := lt_of_le_of_lt (le_max_right δ 0) hR
  have hRδ : δ ≤ R := (le_max_left δ 0).trans hR.le
  rw [RefreshTrace.periodic_cost q baseline c δ T hδ hT hRδ]
  field_simp
  <;> ring

variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]

theorem periodic_upperAverage (baseline c δ T : ℝ) (hδ : 0 ≤ δ) (hT : 0 < T) :
    q.upperAverage μ baseline c (fun _ R => RefreshTrace.periodic δ T hδ hT R) =
      ENNReal.ofReal (q.periodCost baseline c T) := by
  have h := ENNReal.continuous_ofReal.continuousAt.tendsto.comp
    (q.periodic_cost_tendsto baseline c δ T hδ hT)
  have he : (fun R => ENNReal.ofReal ((RefreshTrace.periodic δ T hδ hT R).cost q baseline c/R))
      =ᶠ[atTop] q.expectedAverage μ baseline c
        (fun _ R => RefreshTrace.periodic δ T hδ hT R) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
    simp [expectedAverage, ENNReal.ofReal_div_of_pos hR]
  exact (h.congr' he).limsup_eq

theorem periodic_optimal {c T : ℝ} (hc : 0 < c) (hT : 0 < T)
    (hroot : q.marginal T = c) (baseline δ : ℝ) (hδ : 0 ≤ δ)
    (S : Ω → (R : ℝ) → RefreshTrace R) :
    q.upperAverage μ baseline c (fun _ R => RefreshTrace.periodic δ T hδ hT R) ≤
      q.upperAverage μ baseline c S := by
  rw [q.periodic_upperAverage μ baseline c δ T hδ hT, q.period_cost_at_root hT hroot]
  exact q.root_lower_bound μ hc hroot baseline S

end RefreshMixture
end
end LCSS
