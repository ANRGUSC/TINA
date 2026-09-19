import LCSS.ControlledRefresh
import LCSS.ReceptionRecords
import LCSS.ReceivedInformation

/-! Theorem 2: communication threshold, unique optimal period, and global
optimality for independently randomized schedules and all admissible controls.
The objective is the upper limiting average of expected integrated sensor-team
loss plus communication cost. Infinite expected costs are permitted. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Filter Set
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

/-- The schedule randomization index Ξ is separate from the sensor space Ω.
No probability or independence conclusion is assumed as a field. Finite
horizon records may even be inconsistent across horizons; the proved lower
bound therefore applies to this larger class and, in particular, to every
locally finite schedule. -/
structure RefreshStrategy (D : PaperComponents (μ := μ) ι p) (δ : ℝ) (Ξ : Type*) where
  trace : Ξ → (R : ℝ) → RefreshTrace R
  controls : (ω : Ξ) → (R : ℝ) → RefreshControls D δ (trace ω R)

namespace RefreshStrategy
variable (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ) (δ : ℝ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

def averageCost (c : ℝ) (S : RefreshStrategy D δ Ξ) (R : ℝ) : ℝ≥0∞ :=
  (∫⁻ ω, RefreshControls.cost D w δ (S.controls ω R) c ∂ν) / ENNReal.ofReal R

def upperCost (c : ℝ) (S : RefreshStrategy D δ Ξ) : ℝ≥0∞ :=
  limsup (averageCost D w δ ν c S) atTop

def none (hδ : 0 ≤ δ) : RefreshStrategy D δ Ξ where
  trace _ R := RefreshTrace.none R
  controls _ R := RefreshControls.optimal D δ hδ _

def periodic (hδ : 0 ≤ δ) (T : ℝ) (hT : 0 < T) : RefreshStrategy D δ Ξ where
  trace _ R := RefreshTrace.periodic δ T hδ hT R
  controls _ R := RefreshControls.optimal D δ hδ _

variable (hw : ∀ m, 0 < w m) (hδ : 0 ≤ δ)
include hw hδ

theorem average_lower_bound {c : ℝ} (hc : 0 ≤ c) (S : RefreshStrategy D δ Ξ) (R : ℝ) :
    (RefreshMixture.ofParameters p w hw δ).expectedAverage ν
      (RefreshMixture.baseline p w) c S.trace R ≤ averageCost D w δ ν c S R := by
  apply ENNReal.div_le_div_right
  apply lintegral_mono
  intro ω
  exact RefreshControls.cost_lower_bound D w hw δ hδ (S.controls ω R) hc

theorem upper_lower_bound {c g : ℝ} (hc : 0 ≤ c) (hg : g ≤ 0)
    (hb : ∀ T, 0 ≤ T → g*T ≤ c-(RefreshMixture.ofParameters p w hw δ).benefit T)
    (S : RefreshStrategy D δ Ξ) :
    ENNReal.ofReal (RefreshMixture.baseline p w+g) ≤ upperCost D w δ ν c S := by
  apply le_limsup_of_frequently_le'
  apply Filter.Eventually.frequently
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
  exact ((RefreshMixture.ofParameters p w hw δ).expectedAverage_lower_bound ν _ _ _ hc hg hb
    S.trace hR).trans (average_lower_bound D w δ ν hw hδ hc S R)

theorem none_cost {c : ℝ} (hc : 0 ≤ c) :
    upperCost D w δ ν c (none D δ hδ) = ENNReal.ofReal (RefreshMixture.baseline p w) := by
  have he : averageCost D w δ ν c (none D δ hδ) =
      (RefreshMixture.ofParameters p w hw δ).expectedAverage ν
        (RefreshMixture.baseline p w) c (fun _ R => RefreshTrace.none R) := by
    funext R
    simp only [averageCost, none, RefreshControls.optimal_cost D w hw δ hδ _ hc,
      RefreshMixture.expectedAverage]
  unfold upperCost
  rw [he]
  exact (RefreshMixture.ofParameters p w hw δ).no_refresh_average ν _ _

theorem periodic_cost {c : ℝ} (hc : 0 ≤ c) (T : ℝ) (hT : 0 < T) :
    upperCost D w δ ν c (periodic D δ hδ T hT) =
      ENNReal.ofReal ((RefreshMixture.ofParameters p w hw δ).periodCost
        (RefreshMixture.baseline p w) c T) := by
  have he : averageCost D w δ ν c (periodic D δ hδ T hT) =
      (RefreshMixture.ofParameters p w hw δ).expectedAverage ν
        (RefreshMixture.baseline p w) c (fun _ R => RefreshTrace.periodic δ T hδ hT R) := by
    funext R
    simp only [averageCost, periodic, RefreshControls.optimal_cost D w hw δ hδ _ hc,
      RefreshMixture.expectedAverage]
  unfold upperCost
  rw [he]
  exact (RefreshMixture.ofParameters p w hw δ).periodic_upperAverage ν _ _ δ T hδ hT

theorem none_optimal {c : ℝ} (hc : 0 < c)
    (hcrit : (RefreshMixture.ofParameters p w hw δ).threshold ≤ c)
    (S : RefreshStrategy D δ Ξ) :
    upperCost D w δ ν c (none D δ hδ) ≤ upperCost D w δ ν c S := by
  rw [none_cost D w δ ν hw hδ hc.le]
  simpa using upper_lower_bound D w δ ν hw hδ hc.le (g := 0) le_rfl
    (fun T _ => by simpa using (RefreshMixture.ofParameters p w hw δ).interval_bound_above_threshold hcrit T) S

theorem periodic_optimal {c T : ℝ} (hc : 0 < c) (hT : 0 < T)
    (hroot : (RefreshMixture.ofParameters p w hw δ).marginal T = c)
    (S : RefreshStrategy D δ Ξ) :
    upperCost D w δ ν c (periodic D δ hδ T hT) ≤ upperCost D w δ ν c S := by
  rw [periodic_cost D w δ ν hw hδ hc.le T hT,
    (RefreshMixture.ofParameters p w hw δ).period_cost_at_root hT hroot]
  simpa [sub_eq_add_neg] using upper_lower_bound D w δ ν hw hδ hc.le
    (neg_nonpos.mpr ((RefreshMixture.ofParameters p w hw δ).value_pos T).le)
    (fun U _ => (RefreshMixture.ofParameters p w hw δ).interval_bound_at_root hroot U) S

end RefreshStrategy

variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

/-- Exact assertions of Theorem 2, with actual policy costs rather than a
postulated scalar cost law. The closed-form mixture is derived in RefreshBridge. -/
structure Theorem2Claims (D : PaperComponents (μ := μ) ι p)
    (w : ι → ℝ) (hw : ∀ m, 0 < w m) (δ : ℝ) (hδ : 0 ≤ δ) (c : ℝ) : Prop where
  period_equation_expansion : ∀ T, (RefreshMixture.ofParameters p w hw δ).marginal T =
    ∑ m, (RefreshMixture.ofParameters p w hw δ).amplitude m /
      (RefreshMixture.ofParameters p w hw δ).rate m *
      (1-(1+(RefreshMixture.ofParameters p w hw δ).rate m*T)*
        Real.exp (-(RefreshMixture.ofParameters p w hw δ).rate m*T))
  latest_message_suffices : ∀ (r x : ℝ), 0 ≤ x → ∀ m i,
    (D.sensor m).hybrid (r-δ) (r+x) i ∈ informationSpace (μ := μ)
      ((D.sensor m).receivedSnapshotInfo (r-δ) (r+x) i)
  critical_cost_positive : 0 < (RefreshMixture.ofParameters p w hw δ).threshold
  no_refresh_cost : RefreshStrategy.upperCost D w δ ν c (RefreshStrategy.none D δ hδ) =
    ENNReal.ofReal (RefreshMixture.baseline p w)
  no_refresh_optimal : (RefreshMixture.ofParameters p w hw δ).threshold ≤ c →
    ∀ S : RefreshStrategy D δ Ξ,
      RefreshStrategy.upperCost D w δ ν c (RefreshStrategy.none D δ hδ) ≤
        RefreshStrategy.upperCost D w δ ν c S
  finite_period : c < (RefreshMixture.ofParameters p w hw δ).threshold →
    ∃ T : ℝ, ∃ hT : 0 < T,
      (RefreshMixture.ofParameters p w hw δ).marginal T = c ∧
      (∀ U : ℝ, 0 < U → (RefreshMixture.ofParameters p w hw δ).marginal U = c → U = T) ∧
      0 ≤ RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T ∧
      RefreshStrategy.upperCost D w δ ν c (RefreshStrategy.periodic D δ hδ T hT) =
        ENNReal.ofReal (RefreshMixture.baseline p w - (RefreshMixture.ofParameters p w hw δ).value T) ∧
      (∀ S : RefreshStrategy D δ Ξ,
        RefreshStrategy.upperCost D w δ ν c (RefreshStrategy.periodic D δ hδ T hT) ≤
          RefreshStrategy.upperCost D w δ ν c S)

/-- Main Theorem 2. Randomization is independent of sensors by the product
model: ν indexes the schedule and policies, while all conditional sensor losses
are evaluated against the unchanged law μ. -/
theorem theorem2 (D : PaperComponents (μ := μ) ι p)
    (w : ι → ℝ) (hw : ∀ m, 0 < w m) (δ : ℝ) (hδ : 0 ≤ δ) (c : ℝ) (hc : 0 < c) :
    Theorem2Claims ν D w hw δ hδ c := by
  let q := RefreshMixture.ofParameters p w hw δ
  refine ⟨q.marginal_formula,
    (fun r x hx m i => (D.sensor m).hybrid_received_snapshot_feasible (by linarith) i),
    q.threshold_pos, RefreshStrategy.none_cost D w δ ν hw hδ hc.le,
    (fun hcrit S => RefreshStrategy.none_optimal D w δ ν hw hδ hc hcrit S), ?_⟩
  intro hcrit
  obtain ⟨T, hT, huniq⟩ := q.exists_unique_period hc hcrit
  refine ⟨T, hT.1, hT.2, (fun U hU hroot => huniq U ⟨hU,hroot⟩), ?_, ?_, ?_⟩
  · exact q.running_nonneg (RefreshMixture.baseline_ge_value p w hw hδ) hT.1.le
  · rw [RefreshStrategy.periodic_cost D w δ ν hw hδ hc.le T hT.1,
      q.period_cost_at_root hT.1 hT.2]
  · exact fun S => RefreshStrategy.periodic_optimal D w δ ν hw hδ hc hT.1 hT.2 S

end
end LCSS
