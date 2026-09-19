import LCSS.RawProcess

/-! Raw controls are adapted modulo ambient null sets. Their L² sections are
feasible for exactly the same received information as in the algebraic proof. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)

structure RawScheduledPolicy (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ) where
  action : ℝ → (m : ι) → Fin (p m).n → Ω → ℝ
  memLp : ∀ t m i, MemLp (action t m i) (2 : ℝ≥0∞) μ
  feasible : ∀ t, 0 < t → ∀ m i,
    AEStronglyMeasurable[B.receivedInfo (a.view m i) t (S.receivedBefore δ t)]
      (action t m i) μ

namespace RawScheduledPolicy
variable (a : AgentCoordinates p) (S : PhysicalSchedule) (δ : ℝ)
variable (P : RawScheduledPolicy B a S δ)

def toLp : ScheduledPolicy D a S δ where
  action t m i := (P.memLp t m i).toLp (P.action t m i)
  feasible t ht m i := by
    rw [← B.receivedInfo_informationSpace]
    apply mem_lpMeas_iff_aestronglyMeasurable.mpr
    exact (P.feasible t ht m i).congr (P.memLp t m i).coeFn_toLp.symm

theorem action_eq (t : ℝ) (m : ι) (i : Fin (p m).n) :
    P.action t m i =ᵐ[μ] ((P.toLp B a S δ).action t m i : Ω → ℝ) :=
  (P.memLp t m i).coeFn_toLp.symm

def canonicalAction (t : ℝ) : (m : ι) → Fin (p m).n → Ω → ℝ :=
  match S.strictCount (t-δ) with
  | 0 => fun m => B.localAction m t
  | k+1 => fun m => B.hybrid m (S.send k) t

theorem canonicalAction_eq (t : ℝ) (m : ι) (i : Fin (p m).n) :
    canonicalAction B S δ t m i =ᵐ[μ]
      (ScheduledPolicy.canonicalAction D S δ t m i : Ω → ℝ) := by
  cases hn : S.strictCount (t-δ) with
  | zero => simpa only [canonicalAction, ScheduledPolicy.canonicalAction, hn] using B.local_eq m t i
  | succ k => simpa only [canonicalAction, ScheduledPolicy.canonicalAction, hn] using
      B.hybrid_eq m (S.send k) t i

def canonical (hδ : 0 ≤ δ) : RawScheduledPolicy B a S δ where
  action := canonicalAction B S δ
  memLp t m i := (memLp_congr_ae (canonicalAction_eq B S δ t m i)).mpr (Lp.memLp _)
  feasible t ht m i := by
    have hf := (ScheduledPolicy.canonical D a S δ hδ).feasible t ht m i
    rw [← B.receivedInfo_informationSpace] at hf
    exact (mem_lpMeas_iff_aestronglyMeasurable.mp hf).congr
      (canonicalAction_eq B S δ t m i).symm

theorem lpPolicy_ext {P Q : ScheduledPolicy D a S δ} (h : P.action = Q.action) : P = Q := by
  cases P
  cases Q
  cases h
  rfl

theorem canonical_toLp (hδ : 0 ≤ δ) :
    (canonical B a S δ hδ).toLp B a S δ = ScheduledPolicy.canonical D a S δ hδ := by
  have h : ((canonical B a S δ hδ).toLp B a S δ).action =
      (ScheduledPolicy.canonical D a S δ hδ).action := by
    funext t m i
    exact raw_toLp_eq _ ((canonical B a S δ hδ).memLp t m i) _
      (canonicalAction_eq B S δ t m i)
  exact lpPolicy_ext a S δ h

theorem canonicalAction_joint (m : ι) (i : Fin (p m).n) :
    Measurable (fun z : ℝ × Ω => canonicalAction B S δ z.1 m i z.2) := by
  let f : ℕ × (ℝ × Ω) → ℝ := fun z => match z.1 with
    | 0 => B.localAction m z.2.1 i z.2.2
    | k+1 => B.hybrid m (S.send k) z.2.1 i z.2.2
  have hf : Measurable f := measurable_from_prod_countable_right (by
    intro n
    cases n with
    | zero => exact B.local_joint m i
    | succ k => exact B.hybrid_joint m (S.send k) i)
  have hh := hf.comp ((S.strictCount_measurable.comp (measurable_fst.sub_const δ)).prodMk measurable_id)
  convert hh using 1
  funext z
  cases hn : S.strictCount (z.1-δ) <;> simp [canonicalAction, f, hn]

end RawScheduledPolicy

namespace RawRealization
variable (w : ι → ℝ)

def realizedLoss (t : ℝ) (u : (m : ι) → Fin (p m).n → Ω → ℝ) (ω : Ω) : ℝ≥0∞ :=
  ∑ m, ENNReal.ofReal (w m) * ENNReal.ofReal (pointwiseLoss (p m).κ (B.X m t) (u m) ω)

theorem realizedLoss_eq (t : ℝ) (u : (m : ι) → Fin (p m).n → Ω → ℝ)
    (v : (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ m i, u m i =ᵐ[μ] (v m i : Ω → ℝ)) :
    B.realizedLoss w t u =ᵐ[μ] D.realizedLoss w t v := by
  have hX := ae_all_iff.mpr (fun m => B.X_eq m t)
  have hU := ae_all_iff.mpr (fun m => ae_all_iff.mpr (hu m))
  filter_upwards [hX, hU] with ω hX hU
  simp only [realizedLoss, PaperComponents.realizedLoss, pointwiseLoss, hX, hU]

theorem expected_realizedLoss (hw : ∀ m, 0 ≤ w m) (t : ℝ)
    (u : (m : ι) → Fin (p m).n → Ω → ℝ)
    (v : (m : ι) → Fin (p m).n → RV (μ := μ))
    (hu : ∀ m i, u m i =ᵐ[μ] (v m i : Ω → ℝ)) :
    (∫⁻ ω, B.realizedLoss w t u ω ∂μ) = ENNReal.ofReal (D.totalLoss w t v) := by
  rw [lintegral_congr_ae (B.realizedLoss_eq w t u v hu), D.integral_realizedLoss w hw]

theorem realizedLoss_joint (u : ℝ → (m : ι) → Fin (p m).n → Ω → ℝ)
    (hu : ∀ m i, Measurable (fun z : ℝ × Ω => u z.1 m i z.2)) :
    Measurable (fun z : ℝ × Ω => B.realizedLoss w z.1 (u z.1) z.2) := by
  apply Finset.measurable_sum
  intro m _
  apply Measurable.const_mul
  apply Measurable.ennreal_ofReal
  have hX := B.X_joint m
  have hU := hu m
  unfold pointwiseLoss
  fun_prop

end RawRealization
end
end LCSS
