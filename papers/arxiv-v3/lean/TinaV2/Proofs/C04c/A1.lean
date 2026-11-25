import TinaV2.Statements
import TinaV2.Routine.Conditioning

/-! # C4.c, attempt A1: mirrors supplement proof C4.c/p1

The paper gives no argument (technical-appendices-v3.tex 298-312). The four
steps are written in the ledger (`ledger.py supplement C4.c`), disposition
`C4.c/d1`; they are the argument of steps 1-3 and 5 of the proof of claim
C17.b, for a Gaussian process indexed by time and state coordinate. One lemma
per step, in order, then `main`.

Notation. `a = e^{−τ/T}` is written out as `exp (-τ / T)`. The innovation is
`θ_t − a θ_{t−τ}`, with coordinates `θ_{t,k} − a θ_{t−τ,k}`. -/

namespace TinaV2.C04c.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {κ Ω : Type} [Fintype κ] [mΩ : MeasurableSpace Ω] {μ : Measure Ω}
  {θ : ℝ → Ω → κ → ℝ} {S : Matrix κ κ ℝ} {T : ℝ}

omit [Fintype κ] in
/-- Step 1 (supplied). For `s ≤ t − τ` and `τ ≥ 0`, every coordinate of the
innovation is uncorrelated with every coordinate of `θ_s`:
`E[(θ_{t,k} − a θ_{t−τ,k}) θ_{s,l}] = e^{−(t−s)/T} S_{kl} − e^{−τ/T} e^{−(t−τ−s)/T} S_{kl} = 0`.
Beyond the sentence: the products are integrable because coordinates of a
Gaussian process are square integrable. -/
theorem s1_innovation_uncorrelated
    (hG : IsGaussianProcess (fun (p : ℝ × κ) ω => θ p.1 ω p.2) μ)
    (hc : ∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = exp (-|t - s| / T) * S k l)
    {t τ s : ℝ} (hτ : 0 ≤ τ) (hs : s ≤ t - τ) (k l : κ) :
    ∫ ω, (θ t ω k - exp (-τ / T) * θ (t - τ) ω k) * θ s ω l ∂μ = 0 := by
  have hL : ∀ u j, MemLp (fun ω => θ u ω j) 2 μ := fun u j =>
    (hG.hasGaussianLaw_eval (u, j)).memLp_two
  have h1 : Integrable (fun ω => θ t ω k * θ s ω l) μ := (hL t k).integrable_mul (hL s l)
  have h2 : Integrable (fun ω => exp (-τ / T) * (θ (t - τ) ω k * θ s ω l)) μ :=
    ((hL (t - τ) k).integrable_mul (hL s l)).const_mul _
  have hpt : ∀ ω, (θ t ω k - exp (-τ / T) * θ (t - τ) ω k) * θ s ω l
      = θ t ω k * θ s ω l - exp (-τ / T) * (θ (t - τ) ω k * θ s ω l) := fun ω => by ring
  have habs1 : |t - s| = t - s := abs_of_nonneg (by linarith)
  have habs2 : |t - τ - s| = t - τ - s := abs_of_nonneg (by linarith)
  have hexp : exp (-(t - s) / T) = exp (-τ / T) * exp (-(t - τ - s) / T) := by
    rw [← exp_add]; congr 1; ring
  simp_rw [hpt]
  rw [integral_sub h1 h2, integral_const_mul, hc, hc, habs1, habs2, hexp]
  ring

/-- Step 2 (supplied). Each coordinate of the innovation is a linear
combination of two values of the process, so the innovation is Gaussian, and
jointly Gaussian with the earlier states `(θ_s : s ≤ t − τ)`. The process has
mean zero, so by step 1 the covariances vanish, and joint Gaussianity makes
the innovation independent of the family of earlier states. -/
theorem s2_gaussian_independent [IsProbabilityMeasure μ]
    (hG : IsGaussianProcess (fun (p : ℝ × κ) ω => θ p.1 ω p.2) μ)
    (hm : ∀ t, Measurable (θ t))
    (h0 : ∀ t k, ∫ ω, θ t ω k ∂μ = 0)
    (hc : ∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = exp (-|t - s| / T) * S k l)
    {t τ : ℝ} (hτ : 0 ≤ τ) :
    HasGaussianLaw (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω) μ ∧
    IndepFun (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω)
      (fun ω (s : Iic (t - τ)) => θ s ω) μ := by
  classical
  have hmk : ∀ u j, Measurable (fun ω => θ u ω j) := fun u j =>
    (measurable_pi_apply j).comp (hm u)
  have hL : ∀ u j, MemLp (fun ω => θ u ω j) 2 μ := fun u j =>
    (hG.hasGaussianLaw_eval (u, j)).memLp_two
  -- the innovation coordinates together with the earlier states form a Gaussian process
  have hJ : IsGaussianProcess
      (Sum.elim (fun (k : κ) ω => θ t ω k - exp (-τ / T) * θ (t - τ) ω k)
        (fun (p : Iic (t - τ) × κ) ω => θ p.1 ω p.2)) μ := by
    refine hG.of_isGaussianProcess fun i => ?_
    rcases i with k | p
    · refine ⟨{(t, k), (t - τ, k)},
        ContinuousLinearMap.proj (R := ℝ) (φ := fun _ => ℝ) ⟨(t, k), by simp⟩
          - exp (-τ / T) • ContinuousLinearMap.proj (R := ℝ) (φ := fun _ => ℝ)
            ⟨(t - τ, k), by simp⟩,
        fun ω => ?_⟩
      simp
    · exact ⟨{((p.1 : ℝ), p.2)},
        ContinuousLinearMap.proj (R := ℝ) (φ := fun _ => ℝ) ⟨((p.1 : ℝ), p.2), by simp⟩,
        fun ω => by simp⟩
  have hfun : (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω)
      = fun ω k => θ t ω k - exp (-τ / T) * θ (t - τ) ω k := by
    funext ω k
    simp
  rw [hfun]
  constructor
  · -- the innovation is a linear image of finitely many values of the process
    have hX : IsGaussianProcess (fun (k : κ) ω => θ t ω k - exp (-τ / T) * θ (t - τ) ω k) μ :=
      hJ.comp_right Sum.inl
    exact (hX.hasGaussianLaw Finset.univ).map_fun
      (ContinuousLinearMap.pi fun k : κ =>
        ContinuousLinearMap.proj (R := ℝ) (φ := fun _ : (Finset.univ : Finset κ) => ℝ)
          ⟨k, Finset.mem_univ k⟩)
  · have hind := hJ.indepFun_of_covariance_eq_zero
      (X := fun (k : κ) ω => θ t ω k - exp (-τ / T) * θ (t - τ) ω k)
      (Y := fun (p : Iic (t - τ) × κ) ω => θ p.1 ω p.2)
      (fun k => ((hmk t k).sub ((hmk (t - τ) k).const_mul _)).aemeasurable)
      (fun p => (hmk p.1 p.2).aemeasurable) (fun k p => by
        have hX2 : MemLp (fun ω => θ t ω k - exp (-τ / T) * θ (t - τ) ω k) 2 μ :=
          (hL t k).sub ((hL (t - τ) k).const_mul _)
        rw [covariance_eq_sub hX2 (hL p.1 p.2), h0 p.1 p.2, mul_zero, sub_zero]
        exact s1_innovation_uncorrelated hG hc hτ (mem_Iic.mp p.1.2) k p.2)
    have hψ : Measurable (fun (f : Iic (t - τ) × κ → ℝ) (s : Iic (t - τ)) (l : κ) => f (s, l)) :=
      Measurable.of_eval fun s => Measurable.of_eval fun l => measurable_pi_apply (s, l)
    exact hind.comp measurable_id hψ

/-- Step 3 (supplied). The old state `θ_{t−τ}` is one of the earlier states, so
by step 2 the innovation is independent of it. The innovation is integrable
with mean zero, so its conditional mean given `θ_{t−τ}` is zero:
`E[θ_t − a θ_{t−τ} | θ_{t−τ}] = 0`. -/
theorem s3_prediction [IsProbabilityMeasure μ]
    (hG : IsGaussianProcess (fun (p : ℝ × κ) ω => θ p.1 ω p.2) μ)
    (hm : ∀ t, Measurable (θ t))
    (h0 : ∀ t k, ∫ ω, θ t ω k ∂μ = 0)
    (hc : ∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = exp (-|t - s| / T) * S k l)
    {t τ : ℝ} (hτ : 0 ≤ τ) :
    PredictionRule μ (exp (-τ / T)) (θ (t - τ)) (θ t) := by
  unfold PredictionRule
  have hL : ∀ u j, MemLp (fun ω => θ u ω j) 2 μ := fun u j =>
    (hG.hasGaussianLaw_eval (u, j)).memLp_two
  have hεm : Measurable[mΩ] (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω) :=
    (hm t).sub ((hm (t - τ)).const_smul (exp (-τ / T)))
  -- the old state is one of the earlier states
  have hind0 : IndepFun (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω) (θ (t - τ)) μ := by
    let s₀ : Iic (t - τ) := ⟨t - τ, mem_Iic.mpr le_rfl⟩
    have hψ : Measurable (fun f : Iic (t - τ) → κ → ℝ => f s₀) := measurable_pi_apply s₀
    exact (s2_gaussian_independent hG hm h0 hc hτ).2.comp measurable_id hψ
  have hce := condExp_indep_eq hεm.comap_le (hm (t - τ)).comap_le
    (comap_measurable (fun ω => θ t ω - exp (-τ / T) • θ (t - τ) ω)).stronglyMeasurable
    ((IndepFun_iff_Indep _ _ _).1 hind0)
  -- the innovation has mean zero
  have hmean : ∫ ω, (θ t ω - exp (-τ / T) • θ (t - τ) ω) ∂μ = 0 := by
    ext k
    have hi : ∀ j, Integrable (fun ω => (θ t ω - exp (-τ / T) • θ (t - τ) ω) j) μ := fun j =>
      (((hL t j).integrable one_le_two).sub
        (((hL (t - τ) j).integrable one_le_two).const_mul (exp (-τ / T)))).congr
        (Filter.Eventually.of_forall fun ω => by simp)
    rw [eval_integral hi k]
    have : ∀ ω, (θ t ω - exp (-τ / T) • θ (t - τ) ω) k
        = θ t ω k - exp (-τ / T) * θ (t - τ) ω k := fun ω => by simp
    simp_rw [this]
    rw [integral_sub ((hL t k).integrable one_le_two)
      (((hL (t - τ) k).integrable one_le_two).const_mul _), integral_const_mul, h0, h0]
    simp
  exact hce.trans (Filter.EventuallyEq.of_eq (funext fun _ => hmean))

/-- Step 4 (supplied). Stationarity with finite second moments: every `θ_t` is
a Gaussian vector, hence square integrable, and any two `θ_s`, `θ_t` are
Gaussian vectors with the same mean (zero) and the same second-moment matrix
(`S`), hence have the same law. -/
theorem s4_stationary [IsProbabilityMeasure μ]
    (hG : IsGaussianProcess (fun (p : ℝ × κ) ω => θ p.1 ω p.2) μ)
    (hm : ∀ t, Measurable (θ t))
    (h0 : ∀ t k, ∫ ω, θ t ω k ∂μ = 0)
    (hc : ∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = exp (-|t - s| / T) * S k l) :
    StationaryState μ θ where
  measurable := hm
  memLp := fun t => memLp_pi_iff.2 fun k => (hG.hasGaussianLaw_eval (t, k)).memLp_two
  identDistrib := fun s t => by
    have hs : IsGaussianProcess (fun (k : κ) ω => θ s ω k) μ := hG.comp_right fun k => (s, k)
    have ht : IsGaussianProcess (fun (k : κ) ω => θ t ω k) μ := hG.comp_right fun k => (t, k)
    exact identDistrib_of_isGaussianProcess hs ht
      (fun k => (measurable_pi_apply k).comp (hm s)) (fun k => (measurable_pi_apply k).comp (hm t))
      (fun k => by rw [h0, h0]) (fun k l => by rw [hc, hc]; simp)

/-- C4.c: a jointly Gaussian state process with mean zero and covariance
`e^{−|t−s|/T} S` has Gaussian innovations independent of the earlier states
(step 2) and satisfies the temporal assumption (steps 3 and 4). -/
theorem main : C04c.Statement := by
  intro κ Ω _ _ μ _ θ S T hT hG hm h0 hc t τ hτ
  obtain ⟨hgauss, hind⟩ := s2_gaussian_independent hG hm h0 hc hτ
  exact ⟨hgauss, hind, s4_stationary hG hm h0 hc, hT, hτ, s3_prediction hG hm h0 hc hτ⟩

end TinaV2.C04c.A1
