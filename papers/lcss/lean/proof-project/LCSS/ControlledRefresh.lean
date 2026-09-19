import LCSS.LocalComponents
import LCSS.IntegralObjective
import LCSS.PeriodicRefresh

/-! Expected integrated losses of actual admissible sensor policies.
The interval representation permits arbitrary finite reception records.
Randomization is taken on a separate probability space: sensor laws remain
fixed when the refresh randomization is conditioned upon. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Filter Set
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace Topology

namespace RefreshTrace
def initial {R : ℝ} (s : RefreshTrace R) : ℝ := max R 0 - ∑ j, s.duration j
def reception {R : ℝ} (s : RefreshTrace R) (j : Fin s.received) : ℝ :=
  s.initial + ∑ k ∈ Finset.univ.filter (fun k => k < j), s.duration k
theorem initial_nonneg {R : ℝ} (s : RefreshTrace R) : 0 ≤ s.initial := sub_nonneg.mpr s.coverage

theorem cost_decomposition {ι : Type*} [Fintype ι] [Nonempty ι]
    {R : ℝ} (s : RefreshTrace R) (q : RefreshMixture ι) (baseline c : ℝ) :
    s.cost q baseline c = baseline*s.initial +
      (∑ j, (baseline*s.duration j-q.benefit (s.duration j))) + c*s.sent := by
  simp only [cost, initial, Finset.sum_sub_distrib, ← Finset.mul_sum]
  ring
end RefreshTrace

namespace RefreshMixture
variable {ι : Type*} [Fintype ι] [Nonempty ι] (q : RefreshMixture ι)

theorem lintegral_running {baseline T : ℝ} (hb : q.value 0 ≤ baseline) (hT : 0 ≤ T) :
    (∫⁻ x in Ioc (0 : ℝ) T, ENNReal.ofReal (baseline-q.value x)) =
      ENNReal.ofReal (baseline*T-q.benefit T) := by
  have hi : IntegrableOn (fun x => baseline-q.value x) (Ioc 0 T) :=
    ((continuous_const.sub q.continuous_value).intervalIntegrable 0 T).1
  have hn : 0 ≤ᵐ[volume.restrict (Ioc 0 T)] (fun x => baseline-q.value x) := by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    exact q.running_nonneg hb hx.1.le
  rw [← ofReal_integral_eq_lintegral_ofReal hi hn,
    ← intervalIntegral.integral_of_le hT,
    intervalIntegral.integral_sub intervalIntegrable_const (q.continuous_value.intervalIntegrable _ _),
    q.integral_value]
  simp [mul_comm]

end RefreshMixture

variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

/-- Controls are allowed the full own-component delayed history and all
other-component data; this enlarges the admissible class for the lower bound.
The attaining policy is separately proved feasible using just local data and
the most recently received pooled snapshot. -/
structure RefreshControls (D : PaperComponents (μ := μ) ι p) (δ : ℝ)
    {R : ℝ} (s : RefreshTrace R) where
  before : ℝ → (m : ι) → Fin (p m).n → RV (μ := μ)
  after : Fin s.received → ℝ → (m : ι) → Fin (p m).n → RV (μ := μ)
  before_feasible : ∀ x ∈ Ioc 0 s.initial, ∀ m i,
    before x m i ∈ informationSpace (μ := μ) (D.localInfo m x i)
  after_feasible : ∀ j x, x ∈ Ioc 0 (s.duration j) → ∀ m i,
    after j x m i ∈ informationSpace (μ := μ)
      (D.info m (s.reception j-δ) (s.reception j+x) i)

namespace RefreshControls
variable (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ) (hw : ∀ m, 0 < w m)
variable (δ : ℝ) (hδ : 0 ≤ δ)

def cost {R : ℝ} {s : RefreshTrace R} (u : RefreshControls D δ s) (c : ℝ) : ℝ≥0∞ :=
  (∫⁻ x in Ioc 0 s.initial, ENNReal.ofReal (D.totalLoss w x (u.before x))) +
  (∑ j, ∫⁻ x in Ioc 0 (s.duration j),
    ENNReal.ofReal (D.totalLoss w (s.reception j+x) (u.after j x))) + ENNReal.ofReal c*s.sent

def optimal {R : ℝ} (s : RefreshTrace R) : RefreshControls D δ s where
  before x m := (D.sensor m).localPolicy x
  after j x m := (D.sensor m).hybrid (s.reception j-δ) (s.reception j+x)
  before_feasible x _ m i := D.local_feasible m x i
  after_feasible j x hx m i := D.hybrid_feasible m (by linarith [hx.1]) i

theorem optimal_snapshot_feasible {R : ℝ} (s : RefreshTrace R) (j : Fin s.received)
    {x : ℝ} (hx : 0 ≤ x) (m : ι) (i : Fin (p m).n) :
    (optimal D δ hδ s).after j x m i ∈ informationSpace (μ := μ)
      ((D.sensor m).snapshotInfo (s.reception j-δ) (s.reception j+x) i) :=
  (D.sensor m).hybrid_snapshot_feasible (by linarith) i

include hδ in
theorem cost_lower_bound {R : ℝ} {s : RefreshTrace R} (u : RefreshControls D δ s)
    {c : ℝ} (hc : 0 ≤ c) :
    ENNReal.ofReal (s.cost (RefreshMixture.ofParameters p w hw δ) (RefreshMixture.baseline p w) c) ≤
      cost D w δ u c := by
  let q := RefreshMixture.ofParameters p w hw δ
  let b := RefreshMixture.baseline p w
  have hb : q.value 0 ≤ b := RefreshMixture.baseline_ge_value p w hw hδ
  have hb0 : 0 ≤ b := (q.value_pos 0).le.trans hb
  have hbefore : ENNReal.ofReal (b*s.initial) ≤
      ∫⁻ x in Ioc 0 s.initial, ENNReal.ofReal (D.totalLoss w x (u.before x)) := by
    calc
      _ = ∫⁻ _x in Ioc 0 s.initial, ENNReal.ofReal b := by
        simp [Real.volume_Ioc, ENNReal.ofReal_mul hb0]
      _ ≤ _ := lintegral_mono_ae (by
        filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
        exact ENNReal.ofReal_le_ofReal (D.local_lower_bound w (fun m => (hw m).le) x
          (u.before x) (u.before_feasible x hx)))
  have hafter (j : Fin s.received) : ENNReal.ofReal (b*s.duration j-q.benefit (s.duration j)) ≤
      ∫⁻ x in Ioc 0 (s.duration j),
        ENNReal.ofReal (D.totalLoss w (s.reception j+x) (u.after j x)) := by
    rw [← q.lintegral_running hb (s.duration_nonneg j)]
    apply lintegral_mono_ae
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    exact ENNReal.ofReal_le_ofReal (D.running_lower_bound w hw (s.reception j) δ x hδ hx.1.le
      (u.after j x) (u.after_feasible j x hx))
  rw [s.cost_decomposition]
  rw [ENNReal.ofReal_add (add_nonneg (mul_nonneg hb0 s.initial_nonneg)
    (Finset.sum_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j))))
    (mul_nonneg hc (Nat.cast_nonneg _)),
    ENNReal.ofReal_add (mul_nonneg hb0 s.initial_nonneg)
      (Finset.sum_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j))),
    ENNReal.ofReal_sum_of_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j)),
    ENNReal.ofReal_mul hc, ENNReal.ofReal_natCast]
  exact add_le_add (add_le_add hbefore (Finset.sum_le_sum (fun j _ => hafter j))) le_rfl

theorem optimal_cost {R : ℝ} (s : RefreshTrace R) {c : ℝ} (hc : 0 ≤ c) :
    cost D w δ (optimal D δ hδ s) c =
      ENNReal.ofReal (s.cost (RefreshMixture.ofParameters p w hw δ) (RefreshMixture.baseline p w) c) := by
  let q := RefreshMixture.ofParameters p w hw δ
  let b := RefreshMixture.baseline p w
  have hb : q.value 0 ≤ b := RefreshMixture.baseline_ge_value p w hw hδ
  have hb0 : 0 ≤ b := (q.value_pos 0).le.trans hb
  have ha (j : Fin s.received) :
      (∫⁻ x in Ioc 0 (s.duration j), ENNReal.ofReal
        (D.totalLoss w (s.reception j+x) ((optimal D δ hδ s).after j x))) =
      ENNReal.ofReal (b*s.duration j-q.benefit (s.duration j)) := by
    rw [← q.lintegral_running hb (s.duration_nonneg j)]
    apply lintegral_congr_ae
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    rw [optimal, D.total_hybrid_cost w hw (s.reception j) δ x hδ hx.1.le]
  have hbefore : (∫⁻ x in Ioc 0 s.initial, ENNReal.ofReal
      (D.totalLoss w x ((optimal D δ hδ s).before x))) = ENNReal.ofReal (b*s.initial) := by
    simp only [optimal, D.total_local_cost]
    simp [b, Real.volume_Ioc, ENNReal.ofReal_mul hb0]
  simp only [cost, hbefore, ha]
  rw [s.cost_decomposition, ENNReal.ofReal_add
    (add_nonneg (mul_nonneg hb0 s.initial_nonneg)
      (Finset.sum_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j))))
    (mul_nonneg hc (Nat.cast_nonneg _)),
    ENNReal.ofReal_add (mul_nonneg hb0 s.initial_nonneg)
      (Finset.sum_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j))),
    ENNReal.ofReal_sum_of_nonneg (fun j _ => q.interval_running_nonneg hb (s.duration_nonneg j)),
    ENNReal.ofReal_mul hc, ENNReal.ofReal_natCast]

end RefreshControls
end
end LCSS
