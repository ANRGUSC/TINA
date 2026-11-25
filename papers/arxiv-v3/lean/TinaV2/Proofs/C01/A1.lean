import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Routine.Projection
import TinaV2.Routine.QHilbert
import TinaV2.Routine.RadiusInfo

/-! # C1, attempt A1: mirrors paper proof C1/p1

Paper: `technical-appendices-v2.tex`, proof of Lemma (radner_projection),
lines 183-213. One lemma per step of the paper's proof, in the paper's order,
then `main`.

Notation. `S = policySpace μ actor 𝒢` is `𝒮(𝒜)` for `𝒜 = (𝒢_i)`; `ℋ` is the
square-integrable functions `Ω → α → ℝ`, identified when almost surely equal;
`x⋆ = fun ω => Q⁻¹ *ᵥ b ω`; `⟨u,v⟩_Q = qInner μ Q u v` and
`‖u‖_Q² = qNormSq μ Q u`. "`p = Π_S x⋆`" is `IsQProjection μ Q S x⋆ p`: `p ∈ S`
and `x⋆ − p` is `Q`-orthogonal to `S`.

Completing the square, claim C5, enters step 3 as the hypothesis
`hC5 : C05.Statement` and is passed through step 4 to step 3. The paper gives
no argument for it; the assembly supplies it from the supplement proof
(`Proofs/C05/A1.lean`). -/

namespace TinaV2.C01.A1

open MeasureTheory ProbabilityTheory Matrix Filter Topology

/-- Step 1 (technical-appendices-v2.tex 183-184). "Linearity of `𝒮(𝒜)` follows
because `𝒢_i`-measurability is preserved under linear combinations."

`𝒮(𝒜)` is a linear subspace of `ℋ`: its members are square-integrable, and it
contains `0`, sums and scalar multiples of its members. -/
theorem s1_linear_subspace {ι α Ω : Type} [Fintype α] [MeasurableSpace Ω] (μ : Measure Ω)
    (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω) :
    (∀ u ∈ policySpace μ actor 𝒢, MemLp u 2 μ) ∧
    (0 : Ω → α → ℝ) ∈ policySpace μ actor 𝒢 ∧
    (∀ u ∈ policySpace μ actor 𝒢, ∀ v ∈ policySpace μ actor 𝒢,
      u + v ∈ policySpace μ actor 𝒢) ∧
    ∀ (a : ℝ), ∀ u ∈ policySpace μ actor 𝒢, a • u ∈ policySpace μ actor 𝒢 := by
  refine ⟨fun u hu => hu.2, ⟨fun c => measurable_const, MemLp.zero⟩, ?_, ?_⟩
  · -- `u_i + v_i` is `𝒢_i`-measurable, and `u + v` has a finite second moment
    intro u hu v hv
    exact ⟨fun c => (hu.1 c).add (hv.1 c), hu.2.add hv.2⟩
  · -- `a u_i` is `𝒢_i`-measurable, and `a u` has a finite second moment
    intro a u hu
    exact ⟨fun c => (hu.1 c).const_mul a, hu.2.const_smul a⟩

/-- Step 2 (technical-appendices-v2.tex 185-187). "Closedness follows because
an `L²` limit of `𝒢_i`-measurable random variables admits a `𝒢_i`-measurable
version."

If `u_n ∈ 𝒮(𝒜)` and `E‖u_n − v‖² → 0` for some `v ∈ ℋ`, then `v` is almost
surely equal to a member of `𝒮(𝒜)`. -/
theorem s2_closed {ι α Ω : Type} [Fintype α] [m0 : MeasurableSpace Ω] (μ : Measure Ω)
    (actor : α → ι) (𝒢 : ι → MeasurableSpace Ω) (h𝒢 : ∀ i, 𝒢 i ≤ m0) :
    ∀ (u : ℕ → Ω → α → ℝ) (v : Ω → α → ℝ), (∀ n, u n ∈ policySpace μ actor 𝒢) →
      MemLp v 2 μ →
      Tendsto (fun n => ∫ ω, ∑ c, (u n ω c - v ω c) ^ 2 ∂μ) atTop (𝓝 0) →
      ∃ v' ∈ policySpace μ actor 𝒢, v' =ᵐ[μ] v := by
  intro u v hu hv hlim
  -- each coordinate `v_c` is an `L²` limit of the `𝒢_i`-measurable `u_{n,c}`, `i = actor c`,
  -- so it admits a `𝒢_i`-measurable version
  have hversion : ∀ c, ∃ g : Ω → ℝ, Measurable[𝒢 (actor c)] g ∧ g =ᵐ[μ] fun ω => v ω c := by
    intro c
    have huc : ∀ n, MemLp (fun ω => u n ω c) 2 μ := fun n => memLp_pi_iff.1 (hu n).2 c
    have hvc : MemLp (fun ω => v ω c) 2 μ := memLp_pi_iff.1 hv c
    -- `u_{n,c} → v_c` in `L²(Ω; ℝ)`
    have hLp : Tendsto (fun n => (huc n).toLp (fun ω => u n ω c)) atTop (𝓝 (hvc.toLp _)) :=
      tendsto_toLp_of_tendsto_integral_sq huc hvc
        (tendsto_integral_sq_apply (fun n => (hu n).2) hv hlim c)
    -- each `u_{n,c}` is `𝒢_i`-measurable
    have hmem : ∀ n, (huc n).toLp (fun ω => u n ω c)
        ∈ {f : Lp ℝ 2 μ | AEStronglyMeasurable[𝒢 (actor c)] f μ} := fun n =>
      ⟨fun ω => u n ω c, ((hu n).1 c).stronglyMeasurable, (huc n).coeFn_toLp⟩
    -- the classes with a `𝒢_i`-measurable version are closed in `L²`
    obtain ⟨g, hg, hvg⟩ : AEStronglyMeasurable[𝒢 (actor c)] (hvc.toLp fun ω => v ω c) μ :=
      (isClosed_aestronglyMeasurable (h𝒢 (actor c))).mem_of_tendsto hLp
        (Eventually.of_forall hmem)
    exact ⟨g, hg.measurable, hvg.symm.trans hvc.coeFn_toLp⟩
  -- put the coordinates together
  choose g hg hgv using hversion
  have hae : (fun ω c => g c ω) =ᵐ[μ] v := by
    filter_upwards [ae_all_iff.2 hgv] with ω hω
    exact funext hω
  exact ⟨fun ω c => g c ω, ⟨hg, hv.ae_eq hae.symm⟩, hae⟩

/-- Step 3 (technical-appendices-v2.tex 189-210). "For any admissible policy
`u`, Eq. (complete_square) gives
`E[f(u,θ_t) − f(x_t⋆,θ_t)] = ½ E[(u − x_t⋆)ᵀ Q (u − x_t⋆)] = ½ ‖u − x_t⋆‖_Q²`"
(Eq. (projection_proof)). Stated for every square-integrable `u`. -/
theorem s3_complete_square (hC5 : C05.Statement) {α Ω : Type} [Fintype α] [DecidableEq α]
    [MeasurableSpace Ω] (μ : Measure Ω) (Q : Matrix α α ℝ) (b : Ω → α → ℝ) (c : Ω → ℝ)
    (hQ : Q.PosDef) (hb : MemLp b 2 μ) (hc : Integrable c μ) (u : Ω → α → ℝ)
    (hu : MemLp u 2 μ) :
    expectedCost μ Q b c u - expectedCost μ Q b c (fun ω => Q⁻¹ *ᵥ b ω)
      = 1 / 2 * qNormSq μ Q (u - fun ω => Q⁻¹ *ᵥ b ω) := by
  -- the difference of the expected costs is the expectation of the difference
  have h1 : expectedCost μ Q b c u - expectedCost μ Q b c (fun ω => Q⁻¹ *ᵥ b ω)
      = ∫ ω, (quadCost Q (b ω) (c ω) (u ω) - quadCost Q (b ω) (c ω) (Q⁻¹ *ᵥ b ω)) ∂μ :=
    (integral_sub (integrable_quadCost Q hb hc hu)
      (integrable_quadCost Q hb hc (memLp_xstar Q hb))).symm
  -- `½ ‖u − x⋆‖_Q² = ½ E[(u − x⋆)ᵀ Q (u − x⋆)]` by definition
  have h2 : 1 / 2 * qNormSq μ Q (u - fun ω => Q⁻¹ *ᵥ b ω)
      = ∫ ω, 1 / 2 * quad Q (u ω - Q⁻¹ *ᵥ b ω) ∂μ := by
    rw [integral_const_mul]
    rfl
  -- Eq. (complete_square), state by state
  rw [h1, h2]
  exact integral_congr_ae (ae_of_all _ fun ω => (hC5 Q (b ω) (c ω) hQ).1 (u ω))

/-- Step 4 (technical-appendices-v2.tex 211-213). "Minimizing this expression
over the closed subspace `𝒮(𝒜)` is the standard Hilbert-space projection
problem, yielding Eq. (optimal_projection) and Eq. (projection_regret)."

The projection of `x⋆` onto `𝒮(𝒜)` exists; every projection `p` is optimal,
is the only optimal policy up to almost-sure equality, and
`R(𝒜) = ½ ‖x⋆ − p‖_Q²`. -/
theorem s4_projection (hC5 : C05.Statement) {ι α Ω : Type} [Fintype α] [DecidableEq α]
    [m0 : MeasurableSpace Ω] (μ : Measure Ω) (Q : Matrix α α ℝ) (actor : α → ι)
    (𝒢 : ι → MeasurableSpace Ω) (b : Ω → α → ℝ) (c : Ω → ℝ) (hQ : Q.PosDef)
    (h𝒢 : ∀ i, 𝒢 i ≤ m0) (hb : MemLp b 2 μ) (hc : Integrable c μ) :
    (∃ p, IsQProjection μ Q (policySpace μ actor 𝒢) (fun ω => Q⁻¹ *ᵥ b ω) p) ∧
    ∀ p, IsQProjection μ Q (policySpace μ actor 𝒢) (fun ω => Q⁻¹ *ᵥ b ω) p →
      (∀ u ∈ policySpace μ actor 𝒢, expectedCost μ Q b c p ≤ expectedCost μ Q b c u) ∧
      (∀ u ∈ policySpace μ actor 𝒢,
        expectedCost μ Q b c u ≤ expectedCost μ Q b c p → u =ᵐ[μ] p) ∧
      sigmaRegret μ Q actor (fun ω => Q⁻¹ *ᵥ b ω) 𝒢
        = 1 / 2 * qNormSq μ Q ((fun ω => Q⁻¹ *ᵥ b ω) - p) := by
  set xstar : Ω → α → ℝ := fun ω => Q⁻¹ *ᵥ b ω with hxstar
  set S : Set (Ω → α → ℝ) := policySpace μ actor 𝒢 with hS_def
  have hx : MemLp xstar 2 μ := memLp_xstar Q hb
  -- steps 1 and 2: `S` is a closed linear subspace of `ℋ`
  obtain ⟨hmem, hzero, hadd, hsmul⟩ := s1_linear_subspace μ actor 𝒢
  have hS : IsClosedSubspace μ S := ⟨hmem, hzero, hadd, hsmul, s2_closed μ actor 𝒢 h𝒢⟩
  -- step 3: the expression to minimize over `S` is `½ ‖u − x⋆‖_Q²`, up to a constant
  have hcost : ∀ u ∈ S, expectedCost μ Q b c u - expectedCost μ Q b c xstar
      = 1 / 2 * qNormSq μ Q (u - xstar) := fun u hu =>
    s3_complete_square hC5 μ Q b c hQ hb hc u (hmem u hu)
  -- the projection problem: for a projection `p` and `u ∈ S`, `u − p ∈ S` is
  -- `Q`-orthogonal to `p − x⋆`, so `‖u − x⋆‖_Q² = ‖u − p‖_Q² + ‖p − x⋆‖_Q²`
  have hpyth : ∀ p, IsQProjection μ Q S xstar p → ∀ u ∈ S,
      qNormSq μ Q (u - xstar) = qNormSq μ Q (u - p) + qNormSq μ Q (p - xstar) := by
    intro p hp u hu
    have hd : u - p ∈ S := by
      have h := hadd u hu _ (hsmul (-1) p hp.1)
      rwa [neg_one_smul, ← sub_eq_add_neg] at h
    have horth : qInner μ Q (u - p) (p - xstar) = 0 := by
      have h1 : p - xstar = (-1 : ℝ) • (xstar - p) := by rw [neg_one_smul, neg_sub]
      rw [h1, qInner_smul_right, hp.2 _ hd, mul_zero]
    have h2 : u - xstar = (u - p) + (p - xstar) := (sub_add_sub_cancel u p xstar).symm
    rw [h2, qNormSq_add hQ.isHermitian ((hmem u hu).sub (hmem p hp.1)) ((hmem p hp.1).sub hx),
      horth]
    ring
  -- the projection exists because `S` is a closed subspace of the Hilbert space `ℋ`
  refine ⟨exists_isQProjection hQ hS hx, fun p hp => ⟨?_, ?_, ?_⟩⟩
  · -- Eq. (optimal_projection): `p` is optimal
    intro u hu
    have h1 := hcost u hu
    have h2 := hcost p hp.1
    have h3 := hpyth p hp u hu
    have h4 := qNormSq_nonneg μ hQ (u - p)
    linarith
  · -- and it is the only optimal policy, up to almost-sure equality
    intro u hu hle
    have h1 := hcost u hu
    have h2 := hcost p hp.1
    have h3 := hpyth p hp u hu
    have h4 := qNormSq_nonneg μ hQ (u - p)
    have h0 : qNormSq μ Q (u - p) = 0 := by linarith
    filter_upwards [ae_eq_zero_of_qNormSq_eq_zero hQ ((hmem u hu).sub (hmem p hp.1)) h0]
      with ω hω
    exact sub_eq_zero.1 hω
  · -- Eq. (projection_regret): the infimum of `½ ‖u − x⋆‖_Q²` over `S` is attained at `p`
    rw [qNormSq_sub_comm μ Q xstar p]
    apply le_antisymm
    · exact sigmaRegret_le hQ xstar hp.1
    · refine le_sigmaRegret xstar fun u hu => ?_
      rw [excessCost_eq_qNormSq, hpyth p hp u hu]
      linarith [qNormSq_nonneg μ hQ (u - p)]

theorem main (hC5 : C05.Statement) : C01.Statement := by
  refine ⟨?_, fun M μ r snap now => M.R_eq_sigmaRegret μ r snap now⟩
  intro ι α Ω _ _ m0 μ _ Q actor 𝒢 b c hQ h𝒢 hb hc xstar S
  obtain ⟨hmem, hzero, hadd, hsmul⟩ := s1_linear_subspace μ actor 𝒢
  exact ⟨⟨hmem, hzero, hadd, hsmul, s2_closed μ actor 𝒢 h𝒢⟩,
    s4_projection hC5 μ Q actor 𝒢 b c hQ h𝒢 hb hc⟩

end TinaV2.C01.A1
