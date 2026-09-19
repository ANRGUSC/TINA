import LCSS.RefreshCalculus
import Mathlib.MeasureTheory.Integral.Lebesgue.Basic
import Mathlib.Topology.Instances.ENNReal.Lemmas
import Mathlib.Analysis.SpecificLimits.Basic

/-! Finite-horizon reception records. Each duration runs from a reception
to the next reception or to the horizon, including the final partial interval.
The unaccounted duration precedes the first reception. More transmissions
than receptions are allowed, so fixed latency and pending messages are included.
Bounds hold for every such record, without a periodicity or renewal assumption. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open Filter Set MeasureTheory
open scoped Topology BigOperators ENNReal

structure RefreshTrace (R : ℝ) where
  received : ℕ
  duration : Fin received → ℝ
  duration_nonneg : ∀ i, 0 ≤ duration i
  coverage : (∑ i, duration i) ≤ max R 0
  sent : ℕ
  received_le_sent : received ≤ sent

namespace RefreshTrace
variable {ι : Type*} [Fintype ι] [Nonempty ι]

def cost {R : ℝ} (s : RefreshTrace R) (q : RefreshMixture ι) (baseline c : ℝ) : ℝ :=
  baseline * max R 0 + c*s.sent - ∑ i, q.benefit (s.duration i)

/-- This is the integral of the scalar age-dependent running cost, plus
communication charges at transmission. -/
theorem cost_integral {R : ℝ} (s : RefreshTrace R) (q : RefreshMixture ι) (baseline c : ℝ) :
    s.cost q baseline c = baseline * (max R 0 - ∑ i, s.duration i) + c*s.sent +
      ∑ i, ∫ t in (0 : ℝ)..s.duration i, baseline-q.value t := by
  have h (i : Fin s.received) : (∫ t in (0 : ℝ)..s.duration i, baseline-q.value t) =
      baseline*s.duration i-q.benefit (s.duration i) := by
    rw [intervalIntegral.integral_sub intervalIntegrable_const
      (q.continuous_value.intervalIntegrable _ _), q.integral_value]
    simp [mul_comm]
  simp only [h, Finset.sum_sub_distrib, ← Finset.mul_sum, cost]
  ring

theorem cost_lower_bound {R : ℝ} (s : RefreshTrace R) (q : RefreshMixture ι)
    (baseline c g : ℝ) (hc : 0 ≤ c) (hg : g ≤ 0)
    (hb : ∀ T, 0 ≤ T → g*T ≤ c-q.benefit T) :
    (baseline+g)*max R 0 ≤ s.cost q baseline c := by
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    hb (s.duration i) (s.duration_nonneg i))
  simp only [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at hsum
  have hsent : (s.received : ℝ) ≤ s.sent := by exact_mod_cast s.received_le_sent
  have hcov := mul_le_mul_of_nonpos_left s.coverage hg
  have hpay := mul_le_mul_of_nonneg_left hsent hc
  dsimp [cost]
  nlinarith

def none (R : ℝ) : RefreshTrace R where
  received := 0
  duration := Fin.elim0
  duration_nonneg := fun i => Fin.elim0 i
  coverage := by simp
  sent := 0
  received_le_sent := le_rfl

@[simp] theorem none_cost (R : ℝ) (q : RefreshMixture ι) (baseline c : ℝ) :
    (none R).cost q baseline c = baseline*max R 0 := by
  simp only [cost, none, Nat.cast_zero, mul_zero, add_zero, sub_eq_self]
  apply Finset.sum_eq_zero
  intro i _
  exact Fin.elim0 i

end RefreshTrace

namespace RefreshMixture
variable {ι : Type*} [Fintype ι] [Nonempty ι] (q : RefreshMixture ι)
variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]

/-- Extended nonnegative expectation permits infinite expected transmission counts. -/
def expectedAverage (baseline c : ℝ) (S : Ω → (R : ℝ) → RefreshTrace R) (R : ℝ) : ℝ≥0∞ :=
  (∫⁻ ω, ENNReal.ofReal ((S ω R).cost q baseline c) ∂μ) / ENNReal.ofReal R

def upperAverage (baseline c : ℝ) (S : Ω → (R : ℝ) → RefreshTrace R) : ℝ≥0∞ :=
  limsup (q.expectedAverage μ baseline c S) atTop

theorem expectedAverage_lower_bound (baseline c g : ℝ)
    (hc : 0 ≤ c) (hg : g ≤ 0) (hb : ∀ T, 0 ≤ T → g*T ≤ c-q.benefit T)
    (S : Ω → (R : ℝ) → RefreshTrace R) {R : ℝ} (hR : 0 < R) :
    ENNReal.ofReal (baseline+g) ≤ q.expectedAverage μ baseline c S R := by
  have h : ENNReal.ofReal ((baseline+g)*R) ≤
      ∫⁻ ω, ENNReal.ofReal ((S ω R).cost q baseline c) ∂μ := by
    calc
      _ = ∫⁻ _ω : Ω, ENNReal.ofReal ((baseline+g)*R) ∂μ := by simp
      _ ≤ _ := lintegral_mono (fun ω => ENNReal.ofReal_le_ofReal
        (by simpa [max_eq_left hR.le] using
          (S ω R).cost_lower_bound q baseline c g hc hg hb))
  rw [ENNReal.ofReal_mul' hR.le] at h
  have hd := ENNReal.div_le_div_right h (ENNReal.ofReal R)
  simpa [expectedAverage, ENNReal.mul_div_cancel_right
    (ne_of_gt (ENNReal.ofReal_pos.mpr hR)) ENNReal.ofReal_ne_top] using hd

theorem upperAverage_lower_bound (baseline c g : ℝ)
    (hc : 0 ≤ c) (hg : g ≤ 0) (hb : ∀ T, 0 ≤ T → g*T ≤ c-q.benefit T)
    (S : Ω → (R : ℝ) → RefreshTrace R) :
    ENNReal.ofReal (baseline+g) ≤ q.upperAverage μ baseline c S := by
  apply le_limsup_of_frequently_le'
  apply Filter.Eventually.frequently
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
  exact q.expectedAverage_lower_bound μ baseline c g hc hg hb S hR

theorem no_refresh_average (baseline c : ℝ) :
    q.upperAverage μ baseline c (fun _ R => RefreshTrace.none R) = ENNReal.ofReal baseline := by
  have he : q.expectedAverage μ baseline c (fun _ R => RefreshTrace.none R) =ᶠ[atTop]
      (fun _ => ENNReal.ofReal baseline) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
    simp [expectedAverage, max_eq_left hR.le, ENNReal.ofReal_mul' hR.le,
      ENNReal.mul_div_cancel_right (ne_of_gt (ENNReal.ofReal_pos.mpr hR)) ENNReal.ofReal_ne_top]
  exact (Filter.limsup_congr he).trans (by simp)

theorem no_refresh_optimal {c : ℝ} (hc : q.threshold ≤ c) (baseline : ℝ)
    (S : Ω → (R : ℝ) → RefreshTrace R) :
    q.upperAverage μ baseline c (fun _ R => RefreshTrace.none R) ≤
      q.upperAverage μ baseline c S := by
  rw [q.no_refresh_average]
  simpa using q.upperAverage_lower_bound μ baseline c 0
    (q.threshold_pos.le.trans hc) le_rfl
    (fun T _ => by simpa using q.interval_bound_above_threshold hc T) S

theorem root_lower_bound {c T : ℝ} (hc : 0 < c) (hroot : q.marginal T = c)
    (baseline : ℝ) (S : Ω → (R : ℝ) → RefreshTrace R) :
    ENNReal.ofReal (baseline-q.value T) ≤ q.upperAverage μ baseline c S := by
  simpa [sub_eq_add_neg] using q.upperAverage_lower_bound μ baseline c (-q.value T)
    hc.le (neg_nonpos.mpr (q.value_pos T).le)
    (fun U _ => q.interval_bound_at_root hroot U) S

end RefreshMixture
end
end LCSS
