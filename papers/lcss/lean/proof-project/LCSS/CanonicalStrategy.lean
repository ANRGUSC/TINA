import LCSS.CanonicalPolicy

/-! Joint loss regularity is explicit and contains no cost or attainment claim.
It is used to construct genuine scheduled strategies, with all horizon losses
derived from one physical action path. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}

theorem measurable_time_translate (f : ℝ × Ω → ℝ≥0∞) (hf : Measurable f) (r : ℝ) :
    Measurable (fun z : ℝ × Ω => f (r+z.1,z.2)) :=
  hf.comp ((measurable_const.add measurable_fst).prodMk measurable_snd)

/-- A regularity hypothesis on the actual chosen representatives in the
existing realized-loss objective. Pointwise-in-time L2 specifications alone
do not imply it. There is no feasibility, cost equality, or optimality field. -/
structure CanonicalLossRegularity (D : PaperComponents (μ := μ) ι p)
    (w : ι → ℝ) : Prop where
  local_loss : Measurable (fun z : ℝ × Ω =>
    D.realizedLoss w z.1 (fun m => (D.sensor m).localPolicy z.1) z.2)
  hybrid_loss : ∀ s : ℝ, Measurable (fun z : ℝ × Ω =>
    D.realizedLoss w z.1 (fun m => (D.sensor m).hybrid s z.1) z.2)

namespace PaperComponents
theorem joint_realizedLoss_measurable (D : PaperComponents (μ := μ) ι p)
    (w : ι → ℝ) (u : ℝ → (m : ι) → Fin (p m).n → RV (μ := μ))
    (hX : ∀ m, Measurable (fun z : ℝ × Ω => (D.sensor m).X z.1 z.2))
    (hu : ∀ m i, Measurable (fun z : ℝ × Ω => u z.1 m i z.2)) :
    Measurable (fun z : ℝ × Ω => D.realizedLoss w z.1 (u z.1) z.2) := by
  apply Finset.measurable_sum
  intro m _
  apply Measurable.const_mul
  apply Measurable.ennreal_ofReal
  unfold pointwiseLoss
  fun_prop
end PaperComponents

namespace CanonicalLossRegularity
/-- A sufficient condition expressed only as joint measurability of the
chosen signal and action coordinates; it contains no objective identity. -/
theorem of_measurable_coordinates (D : PaperComponents (μ := μ) ι p) (w : ι → ℝ)
    (hX : ∀ m, Measurable (fun z : ℝ × Ω => (D.sensor m).X z.1 z.2))
    (hL : ∀ m i, Measurable (fun z : ℝ × Ω => (D.sensor m).localPolicy z.1 i z.2))
    (hH : ∀ s m i, Measurable (fun z : ℝ × Ω => (D.sensor m).hybrid s z.1 i z.2)) :
    CanonicalLossRegularity D w :=
  ⟨D.joint_realizedLoss_measurable w (fun t m => (D.sensor m).localPolicy t) hX hL,
    fun s => D.joint_realizedLoss_measurable w (fun t m => (D.sensor m).hybrid s t) hX (hH s)⟩
end CanonicalLossRegularity

namespace ScheduledPolicy
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (w : ι → ℝ) (reg : CanonicalLossRegularity D w)
variable (S : PhysicalSchedule) (δ : ℝ) (hδ : 0 ≤ δ)

include reg in
theorem canonical_loss_measurable : Measurable (fun z : ℝ × Ω =>
    D.realizedLoss w z.1 ((canonical D a S δ hδ).action z.1) z.2) := by
  let f : ℕ × (ℝ × Ω) → ℝ≥0∞ := fun z => match z.1 with
    | 0 => D.realizedLoss w z.2.1 (fun m => (D.sensor m).localPolicy z.2.1) z.2.2
    | k+1 => D.realizedLoss w z.2.1 (fun m => (D.sensor m).hybrid (S.send k) z.2.1) z.2.2
  have hf : Measurable f := measurable_from_prod_countable_right (by
    intro n
    cases n with
    | zero => exact reg.local_loss
    | succ k => exact reg.hybrid_loss (S.send k))
  have hh := hf.comp ((S.strictCount_measurable.comp (measurable_fst.sub_const δ)).prodMk
    measurable_id)
  convert hh using 1
  funext z
  cases hn : S.strictCount (z.1-δ) <;> simp [canonical,canonicalAction,f,hn]

include reg in
theorem canonical_shifted_loss_measurable (r : ℝ) : Measurable
    (fun z : ℝ × Ω => D.realizedLoss w (r+z.1)
      ((canonical D a S δ hδ).action (r+z.1)) z.2) :=
  measurable_time_translate _ (canonical_loss_measurable D a w reg S δ hδ) r

end ScheduledPolicy

namespace ScheduledStrategy
variable (D : PaperComponents (μ := μ) ι p) (a : AgentCoordinates p)
variable (w : ι → ℝ) (reg : CanonicalLossRegularity D w)
variable (δ : ℝ) (hδ : 0 ≤ δ)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

/-- A deterministic physical schedule embedded in any independent seed space.
The action is independent of both the seed and the horizon. -/
def canonical (Q : PhysicalSchedule) : ScheduledStrategy D a w δ hδ Ξ ν where
  schedule _ := Q
  policy _ := ScheduledPolicy.canonical D a Q δ hδ
  before_measurable _ _ :=
    (ScheduledPolicy.canonical_loss_measurable D a w reg Q δ hδ).aemeasurable
  after_measurable _ R j :=
    (ScheduledPolicy.canonical_shifted_loss_measurable D a w reg Q δ hδ
      ((Q.trace δ hδ R).reception j)).aemeasurable
  count_measurable _ := measurable_const
  loss_measurable R := by
    have hb : Measurable (fun ω => ∫⁻ x in Ioc 0 (Q.trace δ hδ R).initial,
        D.realizedLoss w x ((ScheduledPolicy.canonical D a Q δ hδ).action x) ω) :=
      (ScheduledPolicy.canonical_loss_measurable D a w reg Q δ hδ).lintegral_prod_left
    have ha (j : Fin (Q.count (R-δ))) : Measurable (fun ω =>
        ∫⁻ x in Ioc 0 ((Q.trace δ hδ R).duration j),
          D.realizedLoss w ((Q.trace δ hδ R).reception j+x)
            ((ScheduledPolicy.canonical D a Q δ hδ).action ((Q.trace δ hδ R).reception j+x)) ω) :=
      (ScheduledPolicy.canonical_shifted_loss_measurable D a w reg Q δ hδ
        ((Q.trace δ hδ R).reception j)).lintegral_prod_left
    exact ((hb.add (Finset.measurable_sum _ (fun j _ => ha j))).comp measurable_snd).aemeasurable

theorem canonical_average (Q : PhysicalSchedule) (hw : ∀ m, 0 < w m)
    {c : ℝ} (hc : 0 ≤ c) (R : ℝ) :
    (canonical D a w reg δ hδ ν Q).timeAverage D a w δ hδ ν c R =
      ENNReal.ofReal ((Q.trace δ hδ R).cost (RefreshMixture.ofParameters p w hw δ)
        (RefreshMixture.baseline p w) c) / ENNReal.ofReal R := by
  have he : (canonical D a w reg δ hδ ν Q).timeAverage D a w δ hδ ν c R =
      ((canonical D a w reg δ hδ ν Q).toMeasured D a w δ hδ ν).physicalAverage D w δ ν c R := by
    unfold timeAverage MeasuredRefreshStrategy.physicalAverage
    congr 1
    apply lintegral_congr
    intro z
    rw [← (canonical D a w reg δ hδ ν Q).accumulatedLoss_eq D a w δ hδ ν z.1 R z.2]
    rfl
  rw [he, MeasuredRefreshStrategy.physicalAverage_eq D w δ ν _ (fun m => (hw m).le)]
  change (∫⁻ _ξ, RefreshControls.cost D w δ
    ((ScheduledPolicy.canonical D a Q δ hδ).toControls D a Q δ hδ R) c ∂ν) / _ = _
  rw [ScheduledPolicy.canonical_controls_cost D a Q δ hδ w hw R hc]
  simp

end ScheduledStrategy
end
end LCSS
