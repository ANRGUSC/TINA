import LCSS.Parameters
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Topology.Order.IntermediateValue

/-! The analytic part of Theorem 2 for a finite positive exponential mixture.
No optimal period, optimality condition, or scheduling bound is assumed. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open Filter Set MeasureTheory
open scoped Topology BigOperators

structure RefreshMixture (ι : Type*) where
  amplitude : ι → ℝ
  rate : ι → ℝ
  amplitude_pos : ∀ i, 0 < amplitude i
  rate_pos : ∀ i, 0 < rate i

namespace RefreshMixture
variable {ι : Type*} [Fintype ι] [Nonempty ι] (q : RefreshMixture ι)

def value (T : ℝ) : ℝ := ∑ i, q.amplitude i * Real.exp (-q.rate i * T)
def benefit (T : ℝ) : ℝ := ∑ i, q.amplitude i / q.rate i * (1-Real.exp (-q.rate i*T))
def threshold : ℝ := ∑ i, q.amplitude i / q.rate i
def marginal (T : ℝ) : ℝ := q.benefit T - T * q.value T
def periodCost (baseline c T : ℝ) : ℝ := baseline + (c-q.benefit T)/T

theorem value_pos (T : ℝ) : 0 < q.value T :=
  Finset.sum_pos (fun i _ => mul_pos (q.amplitude_pos i) (Real.exp_pos _)) Finset.univ_nonempty

theorem threshold_pos : 0 < q.threshold :=
  Finset.sum_pos (fun i _ => div_pos (q.amplitude_pos i) (q.rate_pos i)) Finset.univ_nonempty

@[simp] theorem benefit_zero : q.benefit 0 = 0 := by simp [benefit]
@[simp] theorem marginal_zero : q.marginal 0 = 0 := by simp [marginal]

theorem benefit_nonneg {T : ℝ} (hT : 0 ≤ T) : 0 ≤ q.benefit T := by
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (le_of_lt (div_pos (q.amplitude_pos i) (q.rate_pos i)))
    (sub_nonneg.mpr (Real.exp_le_one_iff.mpr (by nlinarith [q.rate_pos i])))

theorem benefit_le_threshold (T : ℝ) : q.benefit T ≤ q.threshold := by
  apply Finset.sum_le_sum
  intro i _
  have := mul_nonneg (le_of_lt (div_pos (q.amplitude_pos i) (q.rate_pos i)))
    (Real.exp_pos (-q.rate i*T)).le
  nlinarith

theorem hasDerivAt_exp (i : ι) (T : ℝ) :
    HasDerivAt (fun T => Real.exp (-q.rate i*T))
      (-q.rate i * Real.exp (-q.rate i*T)) T := by
  convert ((hasDerivAt_id T).const_mul (-q.rate i)).exp using 1 <;> (try simp only [id_eq, mul_one]) <;> first | rfl | ring

theorem hasDerivAt_value (T : ℝ) : HasDerivAt q.value
    (∑ i, -q.rate i*q.amplitude i*Real.exp (-q.rate i*T)) T := by
  apply HasDerivAt.fun_sum
  intro i _
  convert (q.hasDerivAt_exp i T).const_mul (q.amplitude i) using 1 <;> (try simp only [id_eq, mul_one]) <;> first | rfl | ring

theorem hasDerivAt_benefit (T : ℝ) : HasDerivAt q.benefit (q.value T) T := by
  apply HasDerivAt.fun_sum
  intro i _
  convert ((q.hasDerivAt_exp i T).const_sub 1).const_mul (q.amplitude i/q.rate i) using 1
  all_goals first | rfl | (field_simp [ne_of_gt (q.rate_pos i)] <;> ring)

theorem continuous_value : Continuous q.value :=
  continuous_iff_continuousAt.mpr (fun T => (q.hasDerivAt_value T).continuousAt)
theorem continuous_benefit : Continuous q.benefit :=
  continuous_iff_continuousAt.mpr (fun T => (q.hasDerivAt_benefit T).continuousAt)
theorem continuous_marginal : Continuous q.marginal :=
  q.continuous_benefit.sub (continuous_id.mul q.continuous_value)

theorem integral_value (T : ℝ) : (∫ t in (0 : ℝ)..T, q.value t) = q.benefit T := by
  have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t _ => q.hasDerivAt_benefit t) (q.continuous_value.intervalIntegrable 0 T)
  simpa using h

theorem hasDerivAt_marginal (T : ℝ) : HasDerivAt q.marginal
    (T * ∑ i, q.rate i*q.amplitude i*Real.exp (-q.rate i*T)) T := by
  convert (q.hasDerivAt_benefit T).sub ((hasDerivAt_id T).mul (q.hasDerivAt_value T)) using 1
  all_goals first | rfl | (simp only [id_eq, one_mul, neg_mul, Finset.sum_neg_distrib]; ring)

theorem marginal_strictMono : StrictMonoOn q.marginal (Ici 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 0) q.continuous_marginal.continuousOn
  intro T hT
  rw [(q.hasDerivAt_marginal T).deriv]
  simp only [interior_Ici, mem_Ioi] at hT
  exact mul_pos hT (Finset.sum_pos
    (fun i _ => mul_pos (mul_pos (q.rate_pos i) (q.amplitude_pos i)) (Real.exp_pos _))
    Finset.univ_nonempty)

theorem marginal_formula (T : ℝ) : q.marginal T =
    ∑ i, q.amplitude i/q.rate i * (1-(1+q.rate i*T)*Real.exp (-q.rate i*T)) := by
  simp only [marginal, benefit, value, Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  field_simp [ne_of_gt (q.rate_pos i)]
  <;> ring

theorem exp_tendsto_zero (i : ι) :
    Tendsto (fun T => Real.exp (-q.rate i*T)) atTop (𝓝 0) := by
  convert Real.tendsto_exp_neg_atTop_nhds_zero.comp
    (tendsto_id.const_mul_atTop (q.rate_pos i)) using 1 <;> simp [neg_mul, Function.comp_def]

theorem mul_exp_tendsto_zero (i : ι) :
    Tendsto (fun T => T*Real.exp (-q.rate i*T)) atTop (𝓝 0) := by
  have h := (Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1).comp
    (tendsto_id.const_mul_atTop (q.rate_pos i))
  have h' := h.const_mul (q.rate i)⁻¹
  convert h' using 1
  · ext T
    simp [mul_assoc, ne_of_gt (q.rate_pos i)]
  · simp

theorem marginal_tendsto : Tendsto q.marginal atTop (𝓝 q.threshold) := by
  have hB : Tendsto q.benefit atTop (𝓝 q.threshold) := by
    apply tendsto_finset_sum
    intro i _
    simpa using (((tendsto_const_nhds (x := (1 : ℝ))).sub (q.exp_tendsto_zero i)).const_mul
      (q.amplitude i/q.rate i))
  have hV : Tendsto (fun T => T*q.value T) atTop (𝓝 0) := by
    have h := tendsto_finset_sum Finset.univ (fun i _ =>
      (q.mul_exp_tendsto_zero i).const_mul (q.amplitude i))
    simpa [value, Finset.mul_sum, mul_left_comm, mul_assoc] using h
  change Tendsto (fun T => q.benefit T-T*q.value T) atTop (𝓝 q.threshold)
  simpa only [sub_zero] using hB.sub hV

theorem exists_unique_period {c : ℝ} (hc : 0 < c) (hcrit : c < q.threshold) :
    ∃! T : ℝ, 0 < T ∧ q.marginal T = c := by
  have he : ∀ᶠ T in atTop, c < q.marginal T :=
    q.marginal_tendsto.eventually (lt_mem_nhds hcrit)
  obtain ⟨U, hU, hUc⟩ := (he.and (eventually_gt_atTop (0 : ℝ))).exists
  obtain ⟨T, hT, hTc⟩ := intermediate_value_Icc hUc.le
    q.continuous_marginal.continuousOn (show c ∈ Icc (q.marginal 0) (q.marginal U) by
      simpa using And.intro hc.le hU.le)
  have hTpos : 0 < T := by
    have hn : T ≠ 0 := by intro hz; simp [hz] at hTc; linarith
    exact lt_of_le_of_ne hT.1 (Ne.symm hn)
  refine ⟨T, ⟨hTpos,hTc⟩, ?_⟩
  intro S hS
  exact q.marginal_strictMono.injOn hS.1.le hTpos.le (hS.2.trans hTc.symm)

theorem benefit_tangent (S T : ℝ) :
    q.benefit T ≤ q.benefit S + (T-S)*q.value S := by
  simp only [benefit, value, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  have he := Real.add_one_le_exp (-q.rate i*(T-S))
  have hf : Real.exp (-q.rate i*T) = Real.exp (-q.rate i*S)*Real.exp (-q.rate i*(T-S)) := by
    rw [← Real.exp_add]
    congr 1
    ring
  have hpos := div_pos (q.amplitude_pos i) (q.rate_pos i)
  have hscaled := mul_le_mul_of_nonneg_left he
    (mul_nonneg hpos.le (Real.exp_pos (-q.rate i*S)).le)
  rw [hf]
  have hid : q.amplitude i / q.rate i * q.rate i = q.amplitude i :=
    div_mul_cancel₀ _ (ne_of_gt (q.rate_pos i))
  linear_combination hscaled + ((T-S)*Real.exp (-q.rate i*S))*hid

theorem interval_bound_at_root {c S : ℝ} (hroot : q.marginal S = c) (T : ℝ) :
    -(q.value S)*T ≤ c-q.benefit T := by
  have := q.benefit_tangent S T
  dsimp [marginal] at hroot
  nlinarith

theorem period_cost_at_root {c S : ℝ} (hS : 0 < S) (hroot : q.marginal S = c)
    (baseline : ℝ) : q.periodCost baseline c S = baseline-q.value S := by
  dsimp [periodCost, marginal] at *
  field_simp
  nlinarith

theorem period_minimal_at_root {c S : ℝ} (hS : 0 < S) (hroot : q.marginal S = c)
    (baseline : ℝ) {T : ℝ} (hT : 0 < T) :
    q.periodCost baseline c S ≤ q.periodCost baseline c T := by
  rw [q.period_cost_at_root hS hroot]
  have := (le_div_iff₀ hT).mpr (q.interval_bound_at_root hroot T)
  dsimp [periodCost]
  linarith

theorem interval_bound_above_threshold {c : ℝ} (hc : q.threshold ≤ c) (T : ℝ) :
    0 ≤ c-q.benefit T := by linarith [q.benefit_le_threshold T]

end RefreshMixture
end
end LCSS
