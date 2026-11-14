import TinaV2.Defs
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection

/-! # Routine facts about `ℋ` as a Hilbert space with `⟨u,v⟩_Q = E[uᵀQv]` (claim C1)

The appendix works in `ℋ = L²(Ω, ℱ, ℙ; ℝ^d)` with the weighted inner product
of Eq. (q_inner_product), remarks that "since `Q ≻ 0`, the induced norm is
equivalent to the ordinary `L²` norm", and then cites "the standard
Hilbert-space projection problem". `Defs/Projection.lean` writes all of this
with functions `Ω → α → ℝ` and integrals. This file is the glue between that
form and Mathlib's `L²` space, where the projection theorem lives:

* `QFibre Q hQ`: `ℝ^d` with the norm and inner product induced by `Q ≻ 0`
  (Mathlib's `Matrix.toNormedAddCommGroup`, `Matrix.toInnerProductSpace`), and
  the identity map `QFibre.equiv` from `ℝ^d` with its usual norm;
* the two norms on `ℝ^d` are equivalent (finite dimension), so
  `Σ_c v_c² ≤ C vᵀQv` and square-integrability is the same for both;
* a closed subspace `S` in the sense of `IsClosedSubspace` is a closed
  submodule of Mathlib's `L²(Ω; QFibre Q hQ)`, whose inner product is
  `⟨·,·⟩_Q`;
* `exists_isQProjection`: Mathlib's Hilbert projection theorem
  (`Submodule.exists_norm_eq_iInf_of_complete_subspace`,
  `Submodule.norm_eq_iInf_iff_real_inner_eq_zero`), read back in the form of
  `IsQProjection`;
* `E[(f_n − g)²] → 0` is convergence in Mathlib's `L²(Ω; ℝ)`, and it passes
  from a random vector to each coordinate.

Nothing here is a step of a paper proof. This file imports `Defs/` and the two
routine files above only. -/

noncomputable section

namespace TinaV2

open MeasureTheory Matrix ProbabilityTheory Filter Topology

variable {Ω : Type} [MeasurableSpace Ω] {α : Type} [Fintype α]

/-! ## `ℝ^d` with the inner product `vᵀ Q w` -/

/-- `ℝ^d` carrying the norm and inner product induced by `Q ≻ 0`. A separate
name for `α → ℝ`, so that this norm does not compete with the usual one. -/
def QFibre (Q : Matrix α α ℝ) (_hQ : Q.PosDef) : Type := α → ℝ

namespace QFibre

variable {Q : Matrix α α ℝ} {hQ : Q.PosDef}

instance : NormedAddCommGroup (QFibre Q hQ) := Q.toNormedAddCommGroup hQ

instance : InnerProductSpace ℝ (QFibre Q hQ) := Q.toInnerProductSpace hQ.posSemidef

/-- The identity map `ℝ^d → (ℝ^d, ⟨·,·⟩_Q)`, as a linear equivalence. -/
def linEquiv (Q : Matrix α α ℝ) (hQ : Q.PosDef) : (α → ℝ) ≃ₗ[ℝ] QFibre Q hQ :=
  LinearEquiv.refl ℝ _

instance : FiniteDimensional ℝ (QFibre Q hQ) := (linEquiv Q hQ).finiteDimensional

instance : CompleteSpace (QFibre Q hQ) := FiniteDimensional.complete ℝ _

/-- The identity map `ℝ^d → (ℝ^d, ⟨·,·⟩_Q)`. It is continuous in both
directions because `ℝ^d` is finite-dimensional. -/
def equiv (Q : Matrix α α ℝ) (hQ : Q.PosDef) : (α → ℝ) ≃L[ℝ] QFibre Q hQ :=
  (linEquiv Q hQ).toContinuousLinearEquiv

/-- The inner product of `QFibre Q hQ` is `vᵀ Q w`. -/
theorem inner_equiv (v w : α → ℝ) :
    inner ℝ (equiv Q hQ v) (equiv Q hQ w) = v ⬝ᵥ (Q *ᵥ w) := by
  change (Q *ᵥ w) ⬝ᵥ star v = _
  rw [star_trivial, dotProduct_comm]

/-- The squared norm of `QFibre Q hQ` is `vᵀ Q v`. -/
theorem norm_sq_equiv (v : α → ℝ) : ‖equiv Q hQ v‖ ^ 2 = quad Q v := by
  rw [← real_inner_self_eq_norm_sq, inner_equiv]
  rfl

/-- The ordinary Euclidean norm is dominated by the `Q`-norm: one half of
"the induced norm is equivalent to the ordinary norm". All norms on `ℝ^d` are
equivalent; here that is continuity of the identity `(ℝ^d, ‖·‖_Q) → ℝ^d`. -/
theorem exists_sum_sq_le_quad (Q : Matrix α α ℝ) (hQ : Q.PosDef) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ v : α → ℝ, ∑ c, v c ^ 2 ≤ C * quad Q v := by
  set L : QFibre Q hQ →L[ℝ] (α → ℝ) := ((equiv Q hQ).symm : QFibre Q hQ →L[ℝ] (α → ℝ)) with hL
  refine ⟨Fintype.card α * ‖L‖ ^ 2, by positivity, fun v => ?_⟩
  have hv : ∀ c, v c ^ 2 ≤ ‖L‖ ^ 2 * quad Q v := by
    intro c
    have h1 : |v c| ≤ ‖v‖ := by simpa using norm_le_pi_norm v c
    have h2 : ‖v‖ ≤ ‖L‖ * ‖equiv Q hQ v‖ := by
      simpa [hL] using L.le_opNorm (equiv Q hQ v)
    have h3 : |v c| ≤ ‖L‖ * ‖equiv Q hQ v‖ := h1.trans h2
    calc v c ^ 2 = |v c| ^ 2 := (sq_abs _).symm
      _ ≤ (‖L‖ * ‖equiv Q hQ v‖) ^ 2 := pow_le_pow_left₀ (abs_nonneg _) h3 2
      _ = ‖L‖ ^ 2 * quad Q v := by rw [mul_pow, norm_sq_equiv]
  calc ∑ c, v c ^ 2 ≤ ∑ _c : α, ‖L‖ ^ 2 * quad Q v := Finset.sum_le_sum fun c _ => hv c
    _ = Fintype.card α * ‖L‖ ^ 2 * quad Q v := by
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_assoc]

/-- Square-integrability for the usual norm gives it for the `Q`-norm. -/
theorem memLp_equiv {μ : Measure Ω} {u : Ω → α → ℝ} (hu : MemLp u 2 μ) :
    MemLp (fun ω => equiv Q hQ (u ω)) 2 μ :=
  (equiv Q hQ : (α → ℝ) →L[ℝ] QFibre Q hQ).comp_memLp' hu

/-- Square-integrability for the `Q`-norm gives it for the usual norm. -/
theorem memLp_equiv_symm {μ : Measure Ω} {f : Ω → QFibre Q hQ} (hf : MemLp f 2 μ) :
    MemLp (fun ω => (equiv Q hQ).symm (f ω)) 2 μ :=
  ((equiv Q hQ).symm : QFibre Q hQ →L[ℝ] (α → ℝ)).comp_memLp' hf

end QFibre

/-! ## A closed subspace of `ℋ` inside Mathlib's `L²` -/

section L2

variable {μ : Measure Ω} {Q : Matrix α α ℝ} {hQ : Q.PosDef} {S : Set (Ω → α → ℝ)}

/-- The classes of the members of `S`, as a submodule of Mathlib's
`L²(Ω; (ℝ^d, ⟨·,·⟩_Q))`. -/
def qSubmodule (μ : Measure Ω) (Q : Matrix α α ℝ) (hQ : Q.PosDef) {S : Set (Ω → α → ℝ)}
    (hS : IsClosedSubspace μ S) : Submodule ℝ (Lp (QFibre Q hQ) 2 μ) where
  carrier := {f | ∃ u ∈ S, (fun ω => QFibre.equiv Q hQ (u ω)) =ᵐ[μ] f}
  zero_mem' := by
    have h : (fun ω => QFibre.equiv Q hQ ((0 : Ω → α → ℝ) ω))
        =ᵐ[μ] ((0 : Lp (QFibre Q hQ) 2 μ) : Ω → QFibre Q hQ) := by
      filter_upwards [Lp.coeFn_zero (QFibre Q hQ) 2 μ] with ω hω
      rw [hω]
      simp only [Pi.zero_apply, map_zero]
    exact ⟨0, hS.zero_mem, h⟩
  add_mem' := by
    rintro f g ⟨u, hu, huf⟩ ⟨v, hv, hvg⟩
    have h : (fun ω => QFibre.equiv Q hQ ((u + v) ω)) =ᵐ[μ] ((f + g : Lp (QFibre Q hQ) 2 μ) :
        Ω → QFibre Q hQ) := by
      filter_upwards [huf, hvg, Lp.coeFn_add f g] with ω h1 h2 h3
      rw [h3]
      simp only [Pi.add_apply, map_add, h1, h2]
    exact ⟨u + v, hS.add_mem u hu v hv, h⟩
  smul_mem' := by
    rintro a f ⟨u, hu, huf⟩
    have h : (fun ω => QFibre.equiv Q hQ ((a • u) ω)) =ᵐ[μ] ((a • f : Lp (QFibre Q hQ) 2 μ) :
        Ω → QFibre Q hQ) := by
      filter_upwards [huf, Lp.coeFn_smul a f] with ω h1 h2
      rw [h2]
      simp only [Pi.smul_apply, map_smul, h1]
    exact ⟨a • u, hS.smul_mem a u hu, h⟩

/-- A subspace that is closed in the sense of `IsClosedSubspace` (limits in the
ordinary `L²` norm) is closed in `L²(Ω; (ℝ^d, ⟨·,·⟩_Q))`: convergence in the
`Q`-norm implies convergence in the ordinary norm. -/
theorem isClosed_qSubmodule (hS : IsClosedSubspace μ S) :
    IsClosed (qSubmodule μ Q hQ hS : Set (Lp (QFibre Q hQ) 2 μ)) := by
  obtain ⟨C, -, hC⟩ := QFibre.exists_sum_sq_le_quad Q hQ
  refine IsSeqClosed.isClosed fun f g hf hfg => ?_
  choose u huS huf using hf
  -- the limit, as a function into `ℝ^d`
  set v : Ω → α → ℝ := fun ω => (QFibre.equiv Q hQ).symm (g ω) with hv
  have hvLp : MemLp v 2 μ := QFibre.memLp_equiv_symm (Lp.memLp g)
  have huLp : ∀ n, MemLp (u n) 2 μ := fun n => hS.memLp _ (huS n)
  -- `‖f n − g‖² = E[(u n − v)ᵀ Q (u n − v)]`
  have hnorm : ∀ n, ‖f n - g‖ ^ 2 = ∫ ω, quad Q (u n ω - v ω) ∂μ := by
    intro n
    rw [← real_inner_self_eq_norm_sq, L2.inner_def]
    refine integral_congr_ae ?_
    filter_upwards [huf n, Lp.coeFn_sub (f n) g] with ω h1 h2
    rw [h2, Pi.sub_apply, ← h1, ← QFibre.norm_sq_equiv (hQ := hQ), real_inner_self_eq_norm_sq,
      map_sub, hv]
    simp
  -- so `E‖u n − v‖² ≤ C ‖f n − g‖² → 0`
  have hlim : Tendsto (fun n => ∫ ω, ∑ c, (u n ω c - v ω c) ^ 2 ∂μ) atTop (𝓝 0) := by
    have h0 : Tendsto (fun n => C * ‖f n - g‖ ^ 2) atTop (𝓝 0) := by
      simpa using ((tendsto_iff_norm_sub_tendsto_zero.1 hfg).pow 2).const_mul C
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds h0
      (fun n => integral_nonneg fun ω => Finset.sum_nonneg fun c _ => sq_nonneg _) fun n => ?_
    change ∫ ω, ∑ c, (u n ω c - v ω c) ^ 2 ∂μ ≤ C * ‖f n - g‖ ^ 2
    rw [hnorm n, ← integral_const_mul]
    refine integral_mono ?_ ((integrable_quad Q ((huLp n).sub hvLp)).const_mul C)
      fun ω => hC (u n ω - v ω)
    exact integrable_finsetSum _ fun c _ =>
      ((memLp_pi_iff.1 (huLp n) c).sub (memLp_pi_iff.1 hvLp c)).integrable_sq
  -- closedness of `S` gives a member of `S` in the class of the limit
  obtain ⟨v', hv'S, hv'⟩ := hS.closed u v huS hvLp hlim
  refine ⟨v', hv'S, ?_⟩
  filter_upwards [hv'] with ω hω
  rw [hω, hv]
  simp

/-- The Hilbert projection theorem in `ℋ` with `⟨·,·⟩_Q`: every `x ∈ ℋ` has an
orthogonal projection onto a closed subspace `S`. This is Mathlib's theorem in
`L²(Ω; (ℝ^d, ⟨·,·⟩_Q))`, which is complete because `ℝ^d` is. -/
theorem exists_isQProjection (hQ : Q.PosDef) (hS : IsClosedSubspace μ S) {x : Ω → α → ℝ}
    (hx : MemLp x 2 μ) : ∃ p, IsQProjection μ Q S x p := by
  set K := qSubmodule μ Q hQ hS with hK
  -- Mathlib: a nearest point of `K` exists, and the error is orthogonal to `K`
  obtain ⟨P, hPK, hmin⟩ := K.exists_norm_eq_iInf_of_complete_subspace
    (isClosed_qSubmodule hS).isComplete ((QFibre.memLp_equiv hx).toLp _)
  have horth := (K.norm_eq_iInf_iff_real_inner_eq_zero hPK).1 hmin
  -- read it back as functions `Ω → α → ℝ`
  obtain ⟨p, hpS, hpP⟩ := hPK
  refine ⟨p, hpS, fun h hh => ?_⟩
  have hhLp := hS.memLp h hh
  have hhK : (QFibre.memLp_equiv (hQ := hQ) hhLp).toLp _ ∈ K :=
    ⟨h, hh, (MemLp.coeFn_toLp _).symm⟩
  have key := horth _ hhK
  rw [L2.inner_def] at key
  rw [← key]
  unfold qInner
  refine integral_congr_ae ?_
  filter_upwards [hpP, Lp.coeFn_sub ((QFibre.memLp_equiv hx).toLp _) P,
    MemLp.coeFn_toLp (QFibre.memLp_equiv (hQ := hQ) hx),
    MemLp.coeFn_toLp (QFibre.memLp_equiv (hQ := hQ) hhLp)] with ω h1 h2 h3 h4
  rw [h2, Pi.sub_apply, Pi.sub_apply, h3, h4, ← h1, ← map_sub, QFibre.inner_equiv]
  exact dotProduct_mulVec_comm hQ.isHermitian _ _

end L2

/-! ## `L²` convergence written with integrals -/

/-- If `E‖u_n − v‖² → 0` then `E[(u_{n,c} − v_c)²] → 0` for each coordinate `c`. -/
theorem tendsto_integral_sq_apply {μ : Measure Ω} {u : ℕ → Ω → α → ℝ} {v : Ω → α → ℝ}
    (hu : ∀ n, MemLp (u n) 2 μ) (hv : MemLp v 2 μ)
    (h : Tendsto (fun n => ∫ ω, ∑ c, (u n ω c - v ω c) ^ 2 ∂μ) atTop (𝓝 0)) (c : α) :
    Tendsto (fun n => ∫ ω, (u n ω c - v ω c) ^ 2 ∂μ) atTop (𝓝 0) := by
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds h
    (fun n => integral_nonneg fun ω => sq_nonneg _) fun n => ?_
  have hint : ∀ c, Integrable (fun ω => (u n ω c - v ω c) ^ 2) μ := fun c =>
    ((memLp_pi_iff.1 (hu n) c).sub (memLp_pi_iff.1 hv c)).integrable_sq
  exact integral_mono (hint c) (integrable_finsetSum _ fun c _ => hint c) fun ω =>
    Finset.single_le_sum (f := fun c => (u n ω c - v ω c) ^ 2) (fun c _ => sq_nonneg _)
      (Finset.mem_univ c)

/-- `E[(f_n − g)²] → 0` is convergence of the classes of `f_n` to the class of
`g` in Mathlib's `L²(Ω; ℝ)`. -/
theorem tendsto_toLp_of_tendsto_integral_sq {μ : Measure Ω} {f : ℕ → Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, MemLp (f n) 2 μ) (hg : MemLp g 2 μ)
    (h : Tendsto (fun n => ∫ ω, (f n ω - g ω) ^ 2 ∂μ) atTop (𝓝 0)) :
    Tendsto (fun n => (hf n).toLp (f n)) atTop (𝓝 (hg.toLp g)) := by
  rw [tendsto_iff_norm_sub_tendsto_zero]
  have hnorm : ∀ n, ‖(hf n).toLp (f n) - hg.toLp g‖ = √(∫ ω, (f n ω - g ω) ^ 2 ∂μ) := by
    intro n
    rw [← Real.sqrt_sq (norm_nonneg ((hf n).toLp (f n) - hg.toLp g)),
      ← real_inner_self_eq_norm_sq, L2.inner_def]
    congr 1
    refine integral_congr_ae ?_
    filter_upwards [Lp.coeFn_sub ((hf n).toLp (f n)) (hg.toLp g), (hf n).coeFn_toLp,
      hg.coeFn_toLp] with ω h1 h2 h3
    rw [h1, Pi.sub_apply, h2, h3, real_inner_self_eq_norm_sq, Real.norm_eq_abs, sq_abs]
  simp only [hnorm]
  have h0 := (Real.continuous_sqrt.tendsto 0).comp h
  rw [Real.sqrt_zero] at h0
  exact h0

end TinaV2
