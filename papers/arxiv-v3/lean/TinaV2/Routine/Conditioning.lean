import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Estimation

/-! # Routine: conditioning with one action coordinate

What the canonical model's proofs use about conditional means and variances
without saying it: the conditional mean is the best rule for the squared loss
(the paper: "There is no action coupling, so the optimal policy is the
conditional mean"), a term that is independent of the observation contributes
its unconditional mean and variance, and these quantities depend only on the
joint law of the target and the observation.

Used by the tier D claims C17.b and C18. -/

noncomputable section

namespace TinaV2

open MeasureTheory ProbabilityTheory Real Set

variable {Ω : Type} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

/-! ## A measurable part plus an independent part -/

/-- `E[A + W | m] = A + E[W]` when `A` is `m`-measurable and `W` is independent
of `m`. Here `W` is measurable for the ambient sigma-algebra `mΩ`. -/
theorem condExp_add_of_indep {m : MeasurableSpace Ω} (hm : m ≤ mΩ) {A W : Ω → ℝ}
    (hA : StronglyMeasurable[m] A) (hAi : Integrable A μ) (hW : Measurable[mΩ] W)
    (hWi : Integrable W μ) (hind : Indep (MeasurableSpace.comap W inferInstance) m μ) :
    μ[fun ω => A ω + W ω | m] =ᵐ[μ] fun ω => A ω + ∫ ω', W ω' ∂μ := by
  have hWm : StronglyMeasurable[MeasurableSpace.comap W inferInstance] W :=
    (comap_measurable W).stronglyMeasurable
  have h1 : μ[W | m] =ᵐ[μ] fun _ => ∫ ω', W ω' ∂μ :=
    condExp_indep_eq hW.comap_le hm hWm hind
  have h2 : μ[A | m] = A := condExp_of_stronglyMeasurable hm hA hAi
  filter_upwards [h1, condExp_add hAi hWi m] with ω h1 h3
  have h3' : (μ[fun ω => A ω + W ω | m]) ω = (μ[A | m]) ω + (μ[W | m]) ω := h3
  rw [h3', h2, h1]

/-- `Var(A + W | m) = Var(W)` when `A` is `m`-measurable and `W` is independent
of `m`: the conditional variance is a deterministic number. Here `W` is
measurable for the ambient sigma-algebra `mΩ`. -/
theorem condVar_add_of_indep {m : MeasurableSpace Ω} (hm : m ≤ mΩ) {A W : Ω → ℝ}
    (hA : StronglyMeasurable[m] A) (hA2 : MemLp A 2 μ) (hW : Measurable[mΩ] W)
    (hW2 : MemLp W 2 μ) (hind : Indep (MeasurableSpace.comap W inferInstance) m μ) :
    Var[fun ω => A ω + W ω; μ | m] =ᵐ[μ] fun _ => Var[W; μ] := by
  have h1 := condExp_add_of_indep (mΩ := mΩ) hm hA (hA2.integrable one_le_two) hW
    (hW2.integrable one_le_two) hind
  -- the centered variable is `W − E[W]`
  have hsq : ((fun ω => A ω + W ω) - μ[fun ω => A ω + W ω | m]) ^ 2
      =ᵐ[μ] fun ω => (W ω - ∫ ω', W ω' ∂μ) ^ 2 := by
    filter_upwards [h1] with ω hω
    simp only [Pi.pow_apply, Pi.sub_apply, hω]
    ring
  -- its square is a function of `W`, hence independent of `m`
  have hV : StronglyMeasurable[MeasurableSpace.comap W inferInstance]
      fun ω => (W ω - ∫ ω', W ω' ∂μ) ^ 2 :=
    (((measurable_id.sub_const (∫ ω', W ω' ∂μ)).pow_const 2).comp
      (comap_measurable W)).stronglyMeasurable
  have h2 : μ[fun ω => (W ω - ∫ ω', W ω' ∂μ) ^ 2 | m]
      =ᵐ[μ] fun _ => ∫ ω, (W ω - ∫ ω', W ω' ∂μ) ^ 2 ∂μ :=
    condExp_indep_eq hW.comap_le hm hV hind
  rw [variance_eq_integral hW.aemeasurable]
  exact (condExp_congr_ae hsq).trans h2

/-- `Var(A + B + D | m) = Var(B | m) + Var(D | m) + 2 Cov(B, D | m)` when `A`
is `m`-measurable. The conditional covariance is written out as
`E[(B − E[B | m])(D − E[D | m]) | m]`. -/
theorem condVar_add_add {m : MeasurableSpace Ω} (hm : m ≤ mΩ) {A B D : Ω → ℝ}
    (hA : StronglyMeasurable[m] A) (hA2 : MemLp A 2 μ) (hB : MemLp B 2 μ) (hD : MemLp D 2 μ) :
    Var[fun ω => A ω + B ω + D ω; μ | m] =ᵐ[μ] fun ω =>
      Var[B; μ | m] ω + Var[D; μ | m] ω
        + 2 * (μ[fun ω' => (B ω' - (μ[B | m]) ω') * (D ω' - (μ[D | m]) ω') | m]) ω := by
  have hAi : Integrable A μ := hA2.integrable one_le_two
  have hBi : Integrable B μ := hB.integrable one_le_two
  have hDi : Integrable D μ := hD.integrable one_le_two
  have hb2 : MemLp (B - μ[B | m]) 2 μ := hB.sub (hB.condExp one_le_two)
  have hd2 : MemLp (D - μ[D | m]) 2 μ := hD.sub (hD.condExp one_le_two)
  -- the conditional mean of the sum
  have hS : μ[fun ω => A ω + B ω + D ω | m] =ᵐ[μ] fun ω => A ω + (μ[B | m]) ω + (μ[D | m]) ω := by
    have h3 : μ[A | m] = A := condExp_of_stronglyMeasurable hm hA hAi
    filter_upwards [condExp_add (hAi.add hBi) hDi m, condExp_add hAi hBi m] with ω h1 h2
    have h1' : (μ[fun ω => A ω + B ω + D ω | m]) ω = (μ[A + B | m]) ω + (μ[D | m]) ω := h1
    have h2' : (μ[A + B | m]) ω = (μ[A | m]) ω + (μ[B | m]) ω := h2
    rw [h1', h2', h3]
  -- the centered sum is the sum of the centered `B` and `D`; expand the square
  have hsq : ((fun ω => A ω + B ω + D ω) - μ[fun ω => A ω + B ω + D ω | m]) ^ 2
      =ᵐ[μ] (B - μ[B | m]) ^ 2 + (D - μ[D | m]) ^ 2
        + (2 : ℝ) • ((B - μ[B | m]) * (D - μ[D | m])) := by
    filter_upwards [hS] with ω hω
    simp only [Pi.pow_apply, Pi.sub_apply, Pi.add_apply, Pi.smul_apply, Pi.mul_apply,
      smul_eq_mul, hω]
    ring
  have hI1 : Integrable ((B - μ[B | m]) ^ 2) μ := hb2.integrable_sq
  have hI2 : Integrable ((D - μ[D | m]) ^ 2) μ := hd2.integrable_sq
  have hI3 : Integrable ((B - μ[B | m]) * (D - μ[D | m])) μ := hb2.integrable_mul hd2
  filter_upwards [condExp_congr_ae (m := m) hsq, condExp_add (hI1.add hI2) (hI3.smul (2 : ℝ)) m,
    condExp_add hI1 hI2 m, condExp_smul (2 : ℝ) ((B - μ[B | m]) * (D - μ[D | m])) m]
    with ω e1 e2 e3 e4
  have e1' : Var[fun ω => A ω + B ω + D ω; μ | m] ω
      = (μ[(B - μ[B | m]) ^ 2 + (D - μ[D | m]) ^ 2
          + (2 : ℝ) • ((B - μ[B | m]) * (D - μ[D | m])) | m]) ω := e1
  rw [e1', e2, Pi.add_apply, e3, Pi.add_apply, e4, Pi.smul_apply, smul_eq_mul]
  rfl

/-- The law of total variance, solved for the expected conditional variance. -/
theorem integral_condVar_eq_variance_sub {m : MeasurableSpace Ω} (hm : m ≤ mΩ) {X : Ω → ℝ}
    (hX : MemLp X 2 μ) :
    ∫ ω, Var[X; μ | m] ω ∂μ = Var[X; μ] - Var[μ[X | m]; μ] :=
  eq_sub_of_add_eq (integral_condVar_add_variance_condExp hm hX)

/-! ## Regret with one action coordinate -/

omit [IsProbabilityMeasure μ] in
/-- With one agent, one action coordinate and the `1 × 1` cost `(q)`, the excess
cost of a rule `g` is `(q/2) E[(X − g(Z))²]`. -/
theorem excessCost_lineCost {O : Type} (q : ℝ) (X : Ω → ℝ) (Z : Ω → O)
    (g : Rule (fun _ : Unit => ()) (fun _ : Unit => O)) :
    excessCost μ (lineCost q) (fun ω _ => X ω) (jointAction g (fun _ => Z))
      = q / 2 * ∫ ω, (X ω - g () (Z ω)) ^ 2 ∂μ := by
  have hpt : ∀ ω, quad (lineCost q) (jointAction g (fun _ => Z) ω - fun _ => X ω)
      = q * (X ω - g () (Z ω)) ^ 2 := by
    intro ω
    simp [quad, lineCost, jointAction, dotProduct, Matrix.mulVec]
    ring
  unfold excessCost
  simp_rw [hpt]
  rw [integral_const_mul]
  ring

omit [IsProbabilityMeasure μ] in
/-- With the `1 × 1` cost `(q)` the regret of acting on the observation `Z` is
`q/2` times the smallest mean squared error in estimating `X` from `Z`. -/
theorem regret_unit_eq_bestMSE {O : Type} [MeasurableSpace O] {q : ℝ} (hq : 0 ≤ q)
    (X : Ω → ℝ) (Z : Ω → O) :
    regret μ (lineCost q) (fun _ : Unit => ()) (O := fun _ : Unit => O)
        (fun ω _ => X ω) (fun _ => Z)
      = q / 2 * bestMSE μ X Z := by
  unfold regret bestMSE
  rw [Real.mul_iInf_of_nonneg (by positivity)]
  simp_rw [excessCost_lineCost]
  have hnn : ∀ g : O → ℝ, 0 ≤ q / 2 * ∫ ω, (X ω - g (Z ω)) ^ 2 ∂μ := fun g =>
    mul_nonneg (by positivity) (integral_nonneg fun _ => sq_nonneg _)
  apply le_antisymm
  · refine le_ciInf fun g => ?_
    have hadm : Admissible (actor := fun _ : Unit => ()) (O := fun _ : Unit => O) μ
        (fun _ => Z) (fun _ => g.1) :=
      ⟨fun _ => g.2.1, memLp_pi_iff.2 fun _ => g.2.2⟩
    exact ciInf_le (f := fun g : {g : Rule (fun _ : Unit => ()) (fun _ : Unit => O) //
        Admissible μ (fun _ : Unit => Z) g} => q / 2 * ∫ ω, (X ω - g.1 () (Z ω)) ^ 2 ∂μ)
      (bddBelow_range_of_nonneg fun g => hnn _) ⟨_, hadm⟩
  · refine le_ciInf fun g => ?_
    exact ciInf_le (f := fun g : {g : O → ℝ // Measurable g ∧ MemLp (fun ω => g (Z ω)) 2 μ} =>
        q / 2 * ∫ ω, (X ω - g.1 (Z ω)) ^ 2 ∂μ)
      (bddBelow_range_of_nonneg fun g => hnn _) ⟨g.1 (), g.2.1 (), memLp_pi_iff.1 g.2.2 ()⟩

/-- The smallest mean squared error in estimating `X` from `Z` is the expected
conditional variance: the conditional mean is a measurable function of `Z`
(Doob–Dynkin) and it is the best estimate. -/
theorem bestMSE_eq_integral_condVar {O : Type} [MeasurableSpace O] {X : Ω → ℝ}
    (hX : MemLp X 2 μ) {Z : Ω → O} (hZ : Measurable Z) :
    bestMSE μ X Z = ∫ ω, Var[X; μ | MeasurableSpace.comap Z inferInstance] ω ∂μ := by
  have hm : MeasurableSpace.comap Z inferInstance ≤ mΩ := hZ.comap_le
  obtain ⟨h, hh, hcomp⟩ :=
    (stronglyMeasurable_condExp (μ := μ) (f := X)
      (m := MeasurableSpace.comap Z inferInstance)).exists_eq_measurable_comp
  have hcond : μ[X | MeasurableSpace.comap Z inferInstance] =ᵐ[μ] fun ω => h (Z ω) :=
    Filter.EventuallyEq.of_eq hcomp
  have hh2 : MemLp (fun ω => h (Z ω)) 2 μ := by
    have := hX.condExp (m := MeasurableSpace.comap Z inferInstance) one_le_two
    rwa [hcomp] at this
  rw [bestMSE_eq_of_condExp hZ hX hh.measurable hh2 hcond, condVar, integral_condExp hm, hcomp]
  rfl

/-- With the `1 × 1` cost `(q)` the regret of acting on the observation `Z` is
`(q/2) E[Var(X | Z)]`: the conditional mean is the best rule. -/
theorem regret_unit_eq_integral_condVar {O : Type} [MeasurableSpace O] {q : ℝ} (hq : 0 < q)
    {X : Ω → ℝ} (hX : MemLp X 2 μ) {Z : Ω → O} (hZ : Measurable Z) :
    regret μ (lineCost q) (fun _ : Unit => ()) (O := fun _ : Unit => O)
        (fun ω _ => X ω) (fun _ => Z)
      = q / 2 * ∫ ω, Var[X; μ | MeasurableSpace.comap Z inferInstance] ω ∂μ := by
  rw [regret_unit_eq_bestMSE hq.le, bestMSE_eq_integral_condVar hX hZ]

omit [IsProbabilityMeasure μ] in
/-- The smallest mean squared error depends only on the joint law of the target
and the observation (one inequality; apply it twice). -/
theorem bestMSE_le_of_identDistrib {O : Type} [MeasurableSpace O] {X X' : Ω → ℝ}
    {Z Z' : Ω → O}
    (h : IdentDistrib (fun ω => (X ω, Z ω)) (fun ω => (X' ω, Z' ω)) μ μ) :
    bestMSE μ X Z ≤ bestMSE μ X' Z' := by
  refine le_ciInf fun g => ?_
  obtain ⟨g, hg, hg2⟩ := g
  have h1 : IdentDistrib (fun ω => g (Z ω)) (fun ω => g (Z' ω)) μ μ :=
    h.comp (u := fun p : ℝ × O => g p.2) (hg.comp measurable_snd)
  have h2 : IdentDistrib (fun ω => (X ω - g (Z ω)) ^ 2) (fun ω => (X' ω - g (Z' ω)) ^ 2) μ μ :=
    h.comp (u := fun p : ℝ × O => (p.1 - g p.2) ^ 2)
      ((measurable_fst.sub (hg.comp measurable_snd)).pow_const 2)
  calc bestMSE μ X Z ≤ ∫ ω, (X ω - g (Z ω)) ^ 2 ∂μ :=
        bestMSE_le μ X Z hg (h1.symm.memLp_snd hg2)
    _ = ∫ ω, (X' ω - g (Z' ω)) ^ 2 ∂μ := h2.integral_eq

/-- The expected conditional variance depends only on the joint law of the
target and the observation. -/
theorem integral_condVar_congr_identDistrib {O : Type} [MeasurableSpace O] {X X' : Ω → ℝ}
    {Z Z' : Ω → O} (hX : MemLp X 2 μ) (hX' : MemLp X' 2 μ) (hZ : Measurable Z)
    (hZ' : Measurable Z')
    (h : IdentDistrib (fun ω => (X ω, Z ω)) (fun ω => (X' ω, Z' ω)) μ μ) :
    ∫ ω, Var[X; μ | MeasurableSpace.comap Z inferInstance] ω ∂μ
      = ∫ ω, Var[X'; μ | MeasurableSpace.comap Z' inferInstance] ω ∂μ := by
  rw [← bestMSE_eq_integral_condVar hX hZ, ← bestMSE_eq_integral_condVar hX' hZ']
  exact le_antisymm (bestMSE_le_of_identDistrib h) (bestMSE_le_of_identDistrib h.symm)

/-! ## The law of a Gaussian process -/

omit [IsProbabilityMeasure μ] in
/-- The mean of a finite linear combination of the coordinates of a process. -/
theorem integral_sum_mul_const {S : Type} {X : S → Ω → ℝ} (hX : ∀ s, Integrable (X s) μ)
    (I : Finset S) (c : I → ℝ) :
    ∫ ω, ∑ i : I, X i ω * c i ∂μ = ∑ i : I, (∫ ω, X i ω ∂μ) * c i := by
  rw [integral_finsetSum _ fun (i : I) _ => (hX i).mul_const (c i)]
  exact Finset.sum_congr rfl fun i _ => integral_mul_const _ _

omit [IsProbabilityMeasure μ] in
/-- The second moment of a finite linear combination of the coordinates of a
process, in terms of the second moments of the coordinates. -/
theorem integral_sq_sum_mul_const {S : Type} {X : S → Ω → ℝ} (hX : ∀ s, MemLp (X s) 2 μ)
    (I : Finset S) (c : I → ℝ) :
    ∫ ω, (∑ i : I, X i ω * c i) ^ 2 ∂μ
      = ∑ i : I, ∑ j : I, c i * c j * ∫ ω, X i ω * X j ω ∂μ := by
  have hpt : ∀ ω, (∑ i : I, X i ω * c i) ^ 2
      = ∑ i : I, ∑ j : I, c i * c j * (X i ω * X j ω) := by
    intro ω
    rw [sq, Finset.sum_mul_sum]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
  have hint : ∀ i j : I, Integrable (fun ω => c i * c j * (X i ω * X j ω)) μ := fun i j =>
    ((hX i).integrable_mul (hX j)).const_mul _
  simp_rw [hpt]
  rw [integral_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ => hint i j]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [integral_finsetSum _ fun j _ => hint i j]
  exact Finset.sum_congr rfl fun j _ => integral_const_mul _ _

/-- Two real Gaussian processes with the same means and the same second
moments have the same law. -/
theorem identDistrib_of_isGaussianProcess {S : Type} {X Y : S → Ω → ℝ}
    (hX : IsGaussianProcess X μ) (hY : IsGaussianProcess Y μ)
    (hXm : ∀ s, Measurable (X s)) (hYm : ∀ s, Measurable (Y s))
    (hmean : ∀ s, ∫ ω, X s ω ∂μ = ∫ ω, Y s ω ∂μ)
    (hcov : ∀ s s', ∫ ω, X s ω * X s' ω ∂μ = ∫ ω, Y s ω * Y s' ω ∂μ) :
    IdentDistrib (fun ω s => X s ω) (fun ω s => Y s ω) μ μ := by
  classical
  have hXa : AEMeasurable (fun ω s => X s ω) μ := (measurable_pi_lambda _ hXm).aemeasurable
  have hYa : AEMeasurable (fun ω s => Y s ω) μ := (measurable_pi_lambda _ hYm).aemeasurable
  rw [identDistrib_iff_forall_finset_identDistrib hXa hYa]
  intro I
  have hGX := hX.hasGaussianLaw I
  have hGY := hY.hasGaussianLaw I
  refine ⟨hGX.aemeasurable, hGY.aemeasurable, ?_⟩
  -- both finite-dimensional laws are Gaussian: compare characteristic functions
  apply Measure.ext_of_charFunDual
  ext L
  rw [hGX.charFunDual_map_eq_fun, hGY.charFunDual_map_eq_fun]
  have hX2 : ∀ s, MemLp (X s) 2 μ := fun s => (hX.hasGaussianLaw_eval s).memLp_two
  have hY2 : ∀ s, MemLp (Y s) 2 μ := fun s => (hY.hasGaussianLaw_eval s).memLp_two
  -- a functional on `I → ℝ` is a finite linear combination of the coordinates
  have hL : ∀ x : I → ℝ, L x = ∑ i : I, x i * L fun j => if i = j then 1 else 0 := fun x => by
    simpa [smul_eq_mul] using (L : (I → ℝ) →ₗ[ℝ] ℝ).pi_apply_eq_sum_univ x
  have hLX : (fun ω => L (I.restrict fun s => X s ω))
      = fun ω => ∑ i : I, X i ω * L fun j => if i = j then 1 else 0 :=
    funext fun ω => hL _
  have hLY : (fun ω => L (I.restrict fun s => Y s ω))
      = fun ω => ∑ i : I, Y i ω * L fun j => if i = j then 1 else 0 :=
    funext fun ω => hL _
  have hLX2 : MemLp (fun ω => L (I.restrict fun s => X s ω)) 2 μ := (hGX.map_fun L).memLp_two
  have hLY2 : MemLp (fun ω => L (I.restrict fun s => Y s ω)) 2 μ := (hGY.map_fun L).memLp_two
  have hint : ∫ ω, L (I.restrict fun s => X s ω) ∂μ = ∫ ω, L (I.restrict fun s => Y s ω) ∂μ := by
    rw [hLX, hLY, integral_sum_mul_const fun s => (hX2 s).integrable one_le_two,
      integral_sum_mul_const fun s => (hY2 s).integrable one_le_two]
    exact Finset.sum_congr rfl fun i _ => by rw [hmean]
  have hvar : Var[fun ω => L (I.restrict fun s => X s ω); μ]
      = Var[fun ω => L (I.restrict fun s => Y s ω); μ] := by
    rw [variance_eq_sub hLX2, variance_eq_sub hLY2, hint]
    congr 1
    rw [hLX, hLY]
    change ∫ ω, (∑ i : I, X i ω * L fun j => if i = j then 1 else 0) ^ 2 ∂μ
      = ∫ ω, (∑ i : I, Y i ω * L fun j => if i = j then 1 else 0) ^ 2 ∂μ
    rw [integral_sq_sum_mul_const hX2, integral_sq_sum_mul_const hY2]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [hcov]
  rw [hint, hvar]

end TinaV2
