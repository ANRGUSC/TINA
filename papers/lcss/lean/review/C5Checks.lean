import LCSS

/-! C5 correspondence checks; these supplement the paper theorems. -/
set_option autoImplicit false
namespace LCSS.C5Review
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal BigOperators Topology
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ι : Type*} [Fintype ι] [Nonempty ι] {p : ι → Parameters}
variable {D : PaperComponents (μ := μ) ι p} (B : RawRealization D)
variable {Ξ : Type*} [MeasurableSpace Ξ] (ν : Measure Ξ) [IsProbabilityMeasure ν]

/-- The common physical-agent indexing is an inhabited specialization. -/
def commonAgents {n : ℕ} (hn : ∀ m, (p m).n = n) : AgentCoordinates p where
  view m i k := ⟨i.val, by simpa only [hn] using i.isLt⟩
  self m i := by apply Fin.ext; rfl

theorem joint_realizedLoss (w : ι → ℝ)
    (u : Ξ → ℝ → (m : ι) → Fin (p m).n → Ω → ℝ)
    (hj : ∀ m i, Measurable (fun z : ℝ × (Ξ × Ω) => u z.2.1 z.1 m i z.2.2)) :
    Measurable (fun z : ℝ × (Ξ × Ω) => B.realizedLoss w z.1 (u z.2.1 z.1) z.2.2) := by
  apply Finset.measurable_sum
  intro m _
  apply Measurable.const_mul
  apply Measurable.ennreal_ofReal
  have hX : Measurable (fun z : ℝ × (Ξ × Ω) => B.X m z.1 z.2.2) :=
    (B.X_joint m).comp (measurable_fst.prodMk measurable_snd.snd)
  have hav : Measurable (fun z : ℝ × (Ξ × Ω) =>
      ((p m).n : ℝ)⁻¹ * ∑ j, u z.2.1 z.1 m j z.2.2) :=
    (Finset.measurable_sum _ (fun j _ => hj m j)).const_mul _
  unfold pointwiseLoss
  exact ((Finset.measurable_sum _ (fun i _ => ((hj m i).sub hX).pow_const 2)).add
    ((Finset.measurable_sum _ (fun i _ => ((hj m i).sub hav).pow_const 2)).const_mul _)).const_mul _

/-- Joint measurability supplies the analytic fields. Conditional square
integrability is still required for every seed and fixed time. -/
def ofJoint (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (Q : Ξ → PhysicalSchedule)
    (u : Ξ → ℝ → (m : ι) → Fin (p m).n → Ω → ℝ)
    (hj : ∀ m i, Measurable (fun z : ℝ × (Ξ × Ω) => u z.2.1 z.1 m i z.2.2))
    (hL2 : ∀ ξ t m i, MemLp (u ξ t m i) (2 : ℝ≥0∞) μ)
    (hf : ∀ ξ t, 0 < t → ∀ m i,
      AEStronglyMeasurable[B.receivedInfo (a.view m i) t ((Q ξ).receivedBy δ t)]
        (u ξ t m i) μ)
    (hcount : ∀ R, Measurable (fun ξ => (Q ξ).count R)) :
    InclusiveRawStrategy B a w δ hδ Ξ ν := by
  have hl := joint_realizedLoss B w u hj
  have hs (ξ : Ξ) : Measurable (fun z : ℝ × Ω => B.realizedLoss w z.1 (u ξ z.1) z.2) := by
    have hm : Measurable (fun z : ℝ × Ω => (z.1, (ξ, z.2))) :=
      measurable_fst.prodMk (measurable_const.prodMk measurable_snd)
    have hh := hl.comp hm
    exact hh
  have hi (R : ℝ) : Measurable (fun z : Ξ × Ω =>
      ∫⁻ t in Ioc 0 R, B.realizedLoss w t (u z.1 t) z.2) :=
    hl.lintegral_prod_left' (μ := volume.restrict (Ioc 0 R))
  let P (ξ : Ξ) : InclusiveRawPolicy B a (Q ξ) δ :=
    { action := u ξ, memLp := hL2 ξ, feasible := hf ξ }
  refine {
    schedule := Q
    policy := P
    before_measurable := ?_
    after_measurable := ?_
    count_measurable := hcount
    loss_measurable := ?_ }
  · intro ξ R
    exact (hs ξ).aemeasurable
  · intro ξ R j
    exact (measurable_time_translate _ (hs ξ)
      (((Q ξ).trace δ hδ R).reception j)).aemeasurable
  · intro R
    exact (hi R).aemeasurable

omit [IsProbabilityMeasure ν] in
/-- The joint adapter keeps the specified action exactly. -/
theorem ofJoint_action (a : AgentCoordinates p) (w : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (Q : Ξ → PhysicalSchedule)
    (u : Ξ → ℝ → (m : ι) → Fin (p m).n → Ω → ℝ)
    (hj : ∀ m i, Measurable (fun z : ℝ × (Ξ × Ω) => u z.2.1 z.1 m i z.2.2))
    (hL2 : ∀ ξ t m i, MemLp (u ξ t m i) (2 : ℝ≥0∞) μ)
    (hf : ∀ ξ t, 0 < t → ∀ m i,
      AEStronglyMeasurable[B.receivedInfo (a.view m i) t ((Q ξ).receivedBy δ t)]
        (u ξ t m i) μ)
    (hcount : ∀ R, Measurable (fun ξ => (Q ξ).count R)) (ξ : Ξ) :
    ((ofJoint B ν a w δ hδ Q u hj hL2 hf hcount).policy ξ).action = u ξ := rfl

/-- Seed/time quantifier diagnostic; it is not a paper-theorem premise. -/
def diagonalSpike (f : Ω → ℝ) (t ξ : ℝ) (ω : Ω) : ℝ :=
  if t = ξ then f ω else 0

omit [IsProbabilityMeasure μ] in
theorem diagonalSpike_section_ae_zero (ρ : Measure ℝ) [NullSingletonClass ρ]
    (f : Ω → ℝ) (t : ℝ) :
    (fun z : ℝ × Ω => diagonalSpike f t z.1 z.2) =ᵐ[ρ.prod μ] (fun _ => 0) := by
  have ht : ∀ᵐ ξ ∂ρ, ξ ≠ t := by
    simpa only [Set.mem_singleton_iff] using (Set.countable_singleton t).ae_notMem ρ
  filter_upwards [(Measure.quasiMeasurePreserving_fst (μ := ρ) (ν := μ)).ae ht] with z hz
  simp [diagonalSpike, Ne.symm hz]

omit [IsProbabilityMeasure μ] in
theorem diagonalSpike_joint_memLp (ρ : Measure ℝ) [NullSingletonClass ρ]
    (f : Ω → ℝ) (t : ℝ) :
    MemLp (fun z : ℝ × Ω => diagonalSpike f t z.1 z.2) (2 : ℝ≥0∞) (ρ.prod μ) :=
  (memLp_congr_ae (diagonalSpike_section_ae_zero ρ f t)).mpr (by simp)

omit [IsProbabilityMeasure μ] in
theorem diagonalSpike_bad_conditional (f : Ω → ℝ)
    (hbad : ¬ MemLp f (2 : ℝ≥0∞) μ) (ξ : ℝ) :
    ¬ MemLp (diagonalSpike f ξ ξ) (2 : ℝ≥0∞) μ := by
  have he : diagonalSpike f ξ ξ = f := by
    funext ω
    simp [diagonalSpike]
  rw [he]
  exact hbad

omit [IsProbabilityMeasure μ] mΩ in
theorem diagonalSpike_time_ae_zero (f : Ω → ℝ) (ξ : ℝ) (ω : Ω) :
    (fun t : ℝ => diagonalSpike f t ξ ω) =ᵐ[volume] (fun _ => 0) := by
  have ht : ∀ᵐ t ∂(volume : Measure ℝ), t ≠ ξ := by
    simpa only [Set.mem_singleton_iff] using (Set.countable_singleton ξ).ae_notMem volume
  filter_upwards [ht] with t ht
  simp [diagonalSpike, ht]

end
end LCSS.C5Review

#print axioms LCSS.C5Review.commonAgents
#print axioms LCSS.C5Review.joint_realizedLoss
#print axioms LCSS.C5Review.ofJoint
#print axioms LCSS.C5Review.ofJoint_action
#print axioms LCSS.C5Review.diagonalSpike_section_ae_zero
#print axioms LCSS.C5Review.diagonalSpike_joint_memLp
#print axioms LCSS.C5Review.diagonalSpike_bad_conditional

#print axioms LCSS.C5Review.diagonalSpike_time_ae_zero
