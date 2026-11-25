import Mathlib.Analysis.Matrix.Order
import Mathlib.MeasureTheory.Constructions.KolmogorovExtension
import Mathlib.MeasureTheory.OuterMeasure.BorelCantelli
import Mathlib.Probability.Distributions.Gaussian.Multivariate
import TinaV2.Assembly
import TinaV2.NonVacuity.FiniteModels

/-! # Non-vacuity witnesses for Tier D (continuum Gaussian / OU processes and `CanonicalField`)

This module supplies kernel-checked existential witnesses proving that the
universally quantified hypothesis bundles of all Tier-D continuum claims in
`TinaV2` (`C4.c`, `C9`, `C17.b`, `C18`, `C19`) are simultaneously satisfiable
by concrete, non-degenerate Gaussian processes using only the three standard
Lean axioms (`propext`, `Classical.choice`, `Quot.sound`).

Kept outside `TinaV2/Proofs/` so the SQLite ledger stays 1:1 with manuscript
claims; imported by `TinaV2.lean` and axiom-audited by `tools/verify_release.py`.

Contents:
1. General centered Gaussian process construction for any positive-semidefinite
   kernel via Mathlib's native `KolmogorovExtension` (`projectiveLimit`) and
   `multivariateGaussian`.
2. Positive-semidefiniteness of the 1D exponential kernel `e^{-|t-s|/T}` and
   separable Hadamard products via `Matrix.PosSemidef.hadamard`.
3. Concrete non-degenerate Ornstein–Uhlenbeck witnesses for `C4.c` and `C9`
   (with strictly unequal mode rates `T₀ = 1 ≠ 2 = T₁` and `0 < M.Rinf`).
4. Specialized 1D Gaussian Kolmogorov–Chentsov dyadic-grid continuous
   modification (using Gaussian 4th moments and Borel–Cantelli) and the
   existence of a pathwise spatially continuous `CanonicalField`
   (`exists_canonicalField`, covering `C17.b`, `C18`, `C19`). -/

noncomputable section

namespace TinaV2.NonVacuity.GaussianModels

open MeasureTheory ProbabilityTheory Matrix Real Set Filter Topology WithLp
open scoped ENNReal NNReal MatrixOrder

/-! ## 1. Centered Gaussian process for an arbitrary PSD kernel -/

section KernelGaussian

variable {ι : Type*}

/-- Finite restriction of a kernel `K` to `I : Finset ι`. -/
def kernelCovMatrix (K : ι → ι → ℝ) (I : Finset ι) : Matrix I I ℝ :=
  Matrix.of fun i j => K i.1 j.1

/-- Centered multivariate Gaussian measure on `I → ℝ` with covariance matrix
`kernelCovMatrix K I`. -/
def kernelProjectiveFamily (K : ι → ι → ℝ) (I : Finset ι) : Measure (I → ℝ) :=
  letI := Classical.decEq ι
  (multivariateGaussian 0 (kernelCovMatrix K I)).map (MeasurableEquiv.toLp 2 (I → ℝ)).symm

private lemma kernelProjectiveFamily_eq_map_equiv (K : ι → ι → ℝ) (I : Finset ι) :
    letI := Classical.decEq ι
    kernelProjectiveFamily K I =
      (multivariateGaussian 0 (kernelCovMatrix K I)).map (EuclideanSpace.equiv I ℝ) := rfl

instance isGaussian_kernelProjectiveFamily (K : ι → ι → ℝ) (I : Finset ι) :
    IsGaussian (kernelProjectiveFamily K I) := by
  let _ := Classical.decEq ι
  rw [kernelProjectiveFamily_eq_map_equiv]
  infer_instance

instance isProbabilityMeasure_kernelProjectiveFamily (K : ι → ι → ℝ) (I : Finset ι) :
    IsProbabilityMeasure (kernelProjectiveFamily K I) :=
  inferInstance

private lemma integral_kernelProjectiveFamily {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (K : ι → ι → ℝ) (I : Finset ι) (f : (I → ℝ) → E) :
    letI := Classical.decEq ι
    ∫ x, f x ∂(kernelProjectiveFamily K I) =
      ∫ x, f (ofLp x) ∂(multivariateGaussian 0 (kernelCovMatrix K I)) := by
  classical
  simp [kernelProjectiveFamily, integral_map_equiv]

private lemma integral_eval_kernelProjectiveFamily (K : ι → ι → ℝ) (I : Finset ι) (i : I) :
    ∫ x, x i ∂(kernelProjectiveFamily K I) = 0 := by
  classical
  have h0 : ∫ x, x ∂(kernelProjectiveFamily K I) = 0 := by
    rw [integral_kernelProjectiveFamily, ← PiLp.coe_continuousLinearEquiv 2 ℝ,
      ContinuousLinearEquiv.integral_comp_id_comm, integral_id_multivariateGaussian, map_zero]
  conv => enter [1, 2]; change fun x : I → ℝ => ContinuousLinearMap.proj (R := ℝ) i x
  rw [ContinuousLinearMap.integral_comp_id_comm, h0, map_zero]
  exact IsGaussian.integrable_id

private lemma covariance_eval_kernelProjectiveFamily {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) (I : Finset ι) (i j : I) :
    cov[fun x : I → ℝ => x i, fun x : I → ℝ => x j; kernelProjectiveFamily K I] = K i.1 j.1 := by
  classical
  have hcov : cov[fun x : I → ℝ => x i, fun x : I → ℝ => x j; kernelProjectiveFamily K I] =
      cov[(fun x : I → ℝ => x i) ∘ ofLp, (fun x : I → ℝ => x j) ∘ ofLp;
        multivariateGaussian 0 (kernelCovMatrix K I)] := by
    rw [kernelProjectiveFamily, covariance_map_equiv]
    rfl
  rw [hcov]
  exact covariance_eval_multivariateGaussian (hK I) i j

/-- If every finite restriction of `K` is positive semidefinite, the centered
multivariate Gaussian laws form a projective measure family. -/
theorem isProjectiveMeasureFamily_kernel {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) :
    IsProjectiveMeasureFamily (α := fun _ : ι => ℝ) (kernelProjectiveFamily K) := by
  classical
  intro I J hJI
  nth_rw 2 [kernelProjectiveFamily]
  rw [Measure.map_map]
  · have hcomp :
        (@Finset.restrict₂ ι (fun _ => ℝ) J I hJI ∘ (MeasurableEquiv.toLp 2 (I → ℝ)).symm) =
          (ofLp : EuclideanSpace ℝ J → (J → ℝ)) ∘ EuclideanSpace.restrict₂ hJI := by
      ext x j; rfl
    have hsub : (kernelCovMatrix K I).submatrix (fun i : J => ⟨i.1, hJI i.2⟩)
        (fun i : J => ⟨i.1, hJI i.2⟩) = kernelCovMatrix K J := rfl
    have hmp1 : MeasurePreserving (EuclideanSpace.restrict₂ hJI)
        (multivariateGaussian (0 : EuclideanSpace ℝ I) (kernelCovMatrix K I))
        (multivariateGaussian (0 : EuclideanSpace ℝ J) (kernelCovMatrix K J)) := by
      simpa [hsub] using
        measurePreserving_restrict₂_multivariateGaussian (μ := (0 : EuclideanSpace ℝ I)) (hK I) hJI
    have hmp2 : MeasurePreserving (ofLp : EuclideanSpace ℝ J → (J → ℝ))
        (multivariateGaussian 0 (kernelCovMatrix K J)) (kernelProjectiveFamily K J) :=
      ⟨by fun_prop, rfl⟩
    rw [hcomp, (hmp2.comp hmp1).map_eq]
  · exact Finset.measurable_restrict₂ _
  · fun_prop

/-- Projective-limit probability measure on `ι → ℝ` for any PSD kernel `K`,
constructed via Mathlib's native `KolmogorovExtension` (`projectiveLimit`). -/
def kernelMeasure (K : ι → ι → ℝ)
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) : Measure (ι → ℝ) :=
  projectiveLimit (kernelProjectiveFamily K) (isProjectiveMeasureFamily_kernel hK)

instance isProbabilityMeasure_kernelMeasure (K : ι → ι → ℝ)
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) :
    IsProbabilityMeasure (kernelMeasure K hK) :=
  isProbabilityMeasure_projectiveLimit (isProjectiveMeasureFamily_kernel hK)

lemma hasLaw_restrict_kernelMeasure {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) (I : Finset ι) :
    HasLaw (fun ω : ι → ℝ => I.restrict ω) (kernelProjectiveFamily K I) (kernelMeasure K hK) where
  aemeasurable := I.measurable_restrict.aemeasurable
  map_eq := isProjectiveLimit_projectiveLimit (isProjectiveMeasureFamily_kernel hK) I

theorem isGaussianProcess_kernelMeasure {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) :
    IsGaussianProcess (fun (i : ι) (ω : ι → ℝ) => ω i) (kernelMeasure K hK) where
  hasGaussianLaw I := (hasLaw_restrict_kernelMeasure hK I).hasGaussianLaw

theorem integral_coord_kernelMeasure {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) (i : ι) :
    ∫ ω, ω i ∂(kernelMeasure K hK) = 0 := by
  have hlaw := hasLaw_restrict_kernelMeasure hK ({i} : Finset ι)
  have h1 := integral_map hlaw.aemeasurable
    (f := fun x : ({i} : Finset ι) → ℝ => x ⟨i, by simp⟩)
    (measurable_pi_apply _).aestronglyMeasurable
  rw [hlaw.map_eq, integral_eval_kernelProjectiveFamily] at h1
  exact h1.symm

theorem integral_mul_coord_kernelMeasure {K : ι → ι → ℝ}
    (hK : ∀ I : Finset ι, (kernelCovMatrix K I).PosSemidef) (i j : ι) :
    ∫ ω, ω i * ω j ∂(kernelMeasure K hK) = K i j := by
  classical
  have hG := isGaussianProcess_kernelMeasure hK
  have hi2 : MemLp (fun ω : ι → ℝ => ω i) 2 (kernelMeasure K hK) :=
    (hG.hasGaussianLaw_eval i).memLp_two
  have hj2 : MemLp (fun ω : ι → ℝ => ω j) 2 (kernelMeasure K hK) :=
    (hG.hasGaussianLaw_eval j).memLp_two
  have hcov_eq : cov[fun ω : ι → ℝ => ω i, fun ω : ι → ℝ => ω j; kernelMeasure K hK] =
      ∫ ω, ω i * ω j ∂(kernelMeasure K hK) := by
    rw [covariance_eq_sub hi2 hj2, integral_coord_kernelMeasure hK i,
      integral_coord_kernelMeasure hK j]
    simp
  rw [← hcov_eq]
  have hlaw := hasLaw_restrict_kernelMeasure hK ({i, j} : Finset ι)
  have h1 := hlaw.covariance_fun_comp
    (f := fun x : ({i, j} : Finset ι) → ℝ => x ⟨i, by simp⟩)
    (g := fun x : ({i, j} : Finset ι) → ℝ => x ⟨j, by simp⟩)
    (measurable_pi_apply _).aemeasurable (measurable_pi_apply _).aemeasurable
  have h2 := covariance_eval_kernelProjectiveFamily hK ({i, j} : Finset ι)
    ⟨i, by simp⟩ ⟨j, by simp⟩
  simpa using h1.trans h2

end KernelGaussian

/-! ## 2. Positive-semidefiniteness of exponential and separable kernels -/

/-- 1D stationary exponential (Ornstein–Uhlenbeck) kernel `e^{−|t − s| / T}`. -/
def expKernel (T : ℝ) (t s : ℝ) : ℝ := Real.exp (-|t - s| / T)

private lemma expKernel_eq_brownian_rescaled {T : ℝ} (hT : 0 < T) (t s : ℝ) :
    expKernel T t s =
      Real.exp (-t / T) * min (Real.exp (2 * t / T)) (Real.exp (2 * s / T)) *
        Real.exp (-s / T) := by
  unfold expKernel
  rcases le_total t s with hts | hst
  · have hmin : min (Real.exp (2 * t / T)) (Real.exp (2 * s / T)) = Real.exp (2 * t / T) :=
      min_eq_left (Real.exp_le_exp.mpr (by exact div_le_div_of_nonneg_right (by linarith) hT.le))
    rw [hmin, ← Real.exp_add, ← Real.exp_add, abs_of_nonpos (sub_nonpos.mpr hts)]
    congr 1; ring
  · have hmin : min (Real.exp (2 * t / T)) (Real.exp (2 * s / T)) = Real.exp (2 * s / T) :=
      min_eq_right (Real.exp_le_exp.mpr (by exact div_le_div_of_nonneg_right (by linarith) hT.le))
    rw [hmin, ← Real.exp_add, ← Real.exp_add, abs_of_nonneg (sub_nonneg.mpr hst)]
    congr 1; ring

/-- Any finite Gram matrix of the 1D exponential kernel `e^{−|f(i) − f(j)| / T}`
(`T > 0`) is positive semidefinite, proved by diagonal congruence from the
Brownian covariance matrix `min(e^{2 f(i)/T}, e^{2 f(j)/T})`. -/
theorem posSemidef_expKernel {α : Type*} [Fintype α] {T : ℝ} (hT : 0 < T) (f : α → ℝ) :
    (Matrix.of fun i j : α => expKernel T (f i) (f j)).PosSemidef := by
  classical
  let u : α → ℝ := fun i => Real.exp (2 * f i / T)
  let c : α → ℝ := fun i => Real.exp (-f i / T)
  let B : Matrix α α ℝ := Matrix.of fun i j => min (u i) (u j)
  have hB : B.PosSemidef := by
    have hBeq : B = Matrix.of fun i j => volume.real (Icc (0 : ℝ) (u i) ∩ Icc (0 : ℝ) (u j)) := by
      ext i j
      have hnn : (0 : ℝ) ≤ min (u i) (u j) := le_min (Real.exp_pos _).le (Real.exp_pos _).le
      simp only [B, Matrix.of_apply, Icc_inter_Icc, max_self, Real.volume_real_Icc_of_le hnn, sub_zero]
    rw [hBeq]
    exact posSemidef_matrix_measure_inter (fun _ => measurableSet_Icc)
      (fun _ => isCompact_Icc.measure_ne_top)
  let D : Matrix α α ℝ := Matrix.diagonal c
  have hD : (D * B * Dᴴ).PosSemidef := hB.mul_mul_conjTranspose_same D
  have hEq : Matrix.of (fun i j : α => expKernel T (f i) (f j)) = D * B * Dᴴ := by
    ext i j
    simp only [Matrix.of_apply, D, B, Matrix.mul_apply,
      Matrix.conjTranspose_apply, Matrix.diagonal_apply, star_trivial, mul_ite, mul_zero,
      Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte, ite_mul, zero_mul]
    simpa [u, c] using expKernel_eq_brownian_rescaled hT (f i) (f j)
  rw [hEq]
  exact hD

/-- Separable product of two PSD kernels is PSD, by the Schur product theorem
(`Matrix.PosSemidef.hadamard`). -/
theorem posSemidef_mul_kernel {α : Type*} [Fintype α] {K₁ K₂ : α → α → ℝ}
    (h₁ : (Matrix.of K₁).PosSemidef) (h₂ : (Matrix.of K₂).PosSemidef) :
    (Matrix.of fun i j => K₁ i j * K₂ i j).PosSemidef := by
  simpa [Matrix.hadamard] using h₁.hadamard h₂

/-! ## 3. Step 5a — Stationary Gaussian / OU witnesses for `C4.c` and `C9` -/

/-- 1D stationary centered Ornstein–Uhlenbeck measure on `ℝ → ℝ` with coherence
time `T > 0` and unit variance: `E[X_t X_s] = e^{−|t − s| / T}`. -/
def ou1dMeasure (T : ℝ) (hT : 0 < T) : Measure (ℝ → ℝ) :=
  kernelMeasure (expKernel T) (fun I => posSemidef_expKernel hT (fun i : I => i.1))

instance isProbabilityMeasure_ou1dMeasure (T : ℝ) (hT : 0 < T) :
    IsProbabilityMeasure (ou1dMeasure T hT) :=
  isProbabilityMeasure_kernelMeasure _ _

/-- Stationary 2-sensor centered Gaussian Ornstein–Uhlenbeck kernel on `ℝ × Fin 2`
with coherence time `T = 1` and spatial covariance `S = I₂`. -/
def ou2Kernel (p q : ℝ × Fin 2) : ℝ :=
  expKernel 1 p.1 q.1 * (1 : Matrix (Fin 2) (Fin 2) ℝ) p.2 q.2

lemma posSemidef_ou2Kernel (I : Finset (ℝ × Fin 2)) :
    (kernelCovMatrix ou2Kernel I).PosSemidef := by
  have h1 : (Matrix.of fun i j : I => expKernel 1 i.1.1 j.1.1).PosSemidef :=
    posSemidef_expKernel (by norm_num) (fun i : I => i.1.1)
  have h2 : (Matrix.of fun i j : I => (1 : Matrix (Fin 2) (Fin 2) ℝ) i.1.2 j.1.2).PosSemidef := by
    have h := (Matrix.PosSemidef.one (n := Fin 2) (R := ℝ)).submatrix (fun i : I => i.1.2)
    exact h
  exact posSemidef_mul_kernel h1 h2

/-- Probability measure for the 2-sensor unit-rate centered OU process. -/
def ou2Measure : Measure ((ℝ × Fin 2) → ℝ) :=
  kernelMeasure ou2Kernel posSemidef_ou2Kernel

instance isProbabilityMeasure_ou2Measure : IsProbabilityMeasure ou2Measure :=
  isProbabilityMeasure_kernelMeasure _ _

/-- Coordinate process `θ_t(ω)(k) = ω(t, k)` for the 2-sensor OU witness. -/
def ou2Theta (t : ℝ) (ω : (ℝ × Fin 2) → ℝ) (k : Fin 2) : ℝ := ω (t, k)

private lemma rinf_twoSensor_of_unit_cov {Ω : Type} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (X : Ω → Fin 2 → ℝ)
    (h02 : MemLp (fun ω => X ω 0) 2 μ) (h12 : MemLp (fun ω => X ω 1) 2 μ)
    (h00 : ∫ ω, X ω 0 * X ω 0 ∂μ = 1)
    (h11 : ∫ ω, X ω 1 * X ω 1 ∂μ = 1)
    (h01 : ∫ ω, X ω 0 * X ω 1 ∂μ = 0) :
    FiniteModels.twoSensorModel.Rinf μ X = 1 / 2 := by
  have htarget : ∀ ω i, FiniteModels.twoSensorModel.target X ω i = (X ω 0 + X ω 1) / 2 := by
    intro ω i
    fin_cases i <;>
      simp [Model.target, FiniteModels.twoSensorModel, Matrix.mulVec, dotProduct,
        Fin.sum_univ_two] <;> ring
  have hQ1 : FiniteModels.twoSensorModel.Q = 1 := rfl
  rw [Model.Rinf]
  have hpt : ∀ ω, quad FiniteModels.twoSensorModel.Q (FiniteModels.twoSensorModel.target X ω) =
      (1 / 2 : ℝ) * (X ω 0 * X ω 0) + (X ω 0 * X ω 1) + (1 / 2 : ℝ) * (X ω 1 * X ω 1) := by
    intro ω
    rw [hQ1, quad, Matrix.one_mulVec, dotProduct, Fin.sum_univ_two, htarget, htarget]
    ring
  simp_rw [hpt]
  have i00 : Integrable (fun ω => X ω 0 * X ω 0) μ := h02.integrable_mul h02
  have i01 : Integrable (fun ω => X ω 0 * X ω 1) μ := h02.integrable_mul h12
  have i11 : Integrable (fun ω => X ω 1 * X ω 1) μ := h12.integrable_mul h12
  have hint :
      ∫ ω, ((1 / 2 : ℝ) * (X ω 0 * X ω 0) + X ω 0 * X ω 1 + (1 / 2 : ℝ) * (X ω 1 * X ω 1)) ∂μ = 1 := by
    have i12 : Integrable (fun ω => (1 / 2 : ℝ) * (X ω 0 * X ω 0) + X ω 0 * X ω 1) μ :=
      (i00.const_mul _).add i01
    rw [integral_add i12 (i11.const_mul _), integral_add (i00.const_mul _) i01,
      integral_const_mul, integral_const_mul, h00, h01, h11]
    norm_num
  rw [hint]
  norm_num

/-- Non-vacuity witness for `C4.c`: a concrete stationary centered 2-sensor
Gaussian Ornstein–Uhlenbeck process (`T = 1`, `S = I₂`) with `R_∞ = 1/2 > 0`
satisfying all hypotheses (and conclusions) of `TinaV2.C04c.Statement`. -/
theorem exists_stationary_ou_witness :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (θ : ℝ → Ω → Fin 2 → ℝ) (S : Matrix (Fin 2) (Fin 2) ℝ) (T : ℝ),
      0 < T ∧
      IsGaussianProcess (fun (p : ℝ × Fin 2) ω => θ p.1 ω p.2) μ ∧
      (∀ t, Measurable (θ t)) ∧
      (∀ t k, ∫ ω, θ t ω k ∂μ = 0) ∧
      (∀ t s k l, ∫ ω, θ t ω k * θ s ω l ∂μ = Real.exp (-|t - s| / T) * S k l) ∧
      (∀ t, 0 < M.Rinf μ (θ t)) ∧
      (∀ t τ : ℝ, 0 ≤ τ → TemporalAssumption μ θ T t τ) := by
  have hG : IsGaussianProcess (fun (p : ℝ × Fin 2) ω => ou2Theta p.1 ω p.2) ou2Measure :=
    isGaussianProcess_kernelMeasure posSemidef_ou2Kernel
  have hmeas : ∀ t, Measurable (ou2Theta t) := fun t =>
    Measurable.of_eval fun k => measurable_pi_apply (t, k)
  have hmean : ∀ t k, ∫ ω, ou2Theta t ω k ∂ou2Measure = 0 := fun t k =>
    integral_coord_kernelMeasure posSemidef_ou2Kernel (t, k)
  have hcov : ∀ t s k l, ∫ ω, ou2Theta t ω k * ou2Theta s ω l ∂ou2Measure =
      Real.exp (-|t - s| / 1) * (1 : Matrix (Fin 2) (Fin 2) ℝ) k l := fun t s k l =>
    integral_mul_coord_kernelMeasure posSemidef_ou2Kernel (t, k) (s, l)
  have hRinf : ∀ t, 0 < FiniteModels.twoSensorModel.Rinf ou2Measure (ou2Theta t) := by
    intro t
    have hr := rinf_twoSensor_of_unit_cov ou2Measure (ou2Theta t)
      (hG.hasGaussianLaw_eval (t, 0)).memLp_two
      (hG.hasGaussianLaw_eval (t, 1)).memLp_two
      (by simpa [expKernel] using hcov t t 0 0)
      (by simpa [expKernel] using hcov t t 1 1)
      (by simpa [expKernel] using hcov t t 0 1)
    rw [hr]; norm_num
  have hTA : ∀ t τ : ℝ, 0 ≤ τ → TemporalAssumption ou2Measure ou2Theta 1 t τ := fun t τ hτ =>
    (TinaV2.Assembly.C04c ou2Measure ou2Theta 1 1 (by norm_num) hG hmeas hmean hcov t τ hτ).2.2
  exact ⟨FiniteModels.twoSensorModel, (ℝ × Fin 2) → ℝ, inferInstance, ou2Measure, inferInstance,
    ou2Theta, 1, 1, by norm_num, hG, hmeas, hmean, hcov, hRinf, hTA⟩

/-- Product space for two independent 1D OU modes with unequal coherence times
`T₀ = 1` and `T₁ = 2`. -/
abbrev ModesSpace := (ℝ → ℝ) × (ℝ → ℝ)

/-- Product probability measure `OU(T = 1) ⊗ OU(T = 2)` on `ModesSpace`. -/
def modesMeasure : Measure ModesSpace :=
  (ou1dMeasure 1 (by norm_num)).prod (ou1dMeasure 2 (by norm_num))

instance isProbabilityMeasure_modesMeasure : IsProbabilityMeasure modesMeasure := by
  unfold modesMeasure; infer_instance

/-- 2-mode state process `θ_t(ω₀, ω₁) = (ω₀(t), ω₁(t))`. -/
def modesTheta (t : ℝ) (ω : ModesSpace) : Fin 2 → ℝ := ![ω.1 t, ω.2 t]

/-- Coordinate mode projection matrices `P₀ = diag(1, 0)`, `P₁ = diag(0, 1)`. -/
def modeProj : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ :=
  ![Matrix.diagonal ![1, 0], Matrix.diagonal ![0, 1]]

/-- Distinct mode coherence times `T₀ = 1`, `T₁ = 2`. -/
def modeTc : Fin 2 → ℝ := ![1, 2]

private lemma modesMeasure_preimage_fst (A : Set (ℝ → ℝ)) :
    modesMeasure (Prod.fst ⁻¹' A) = ou1dMeasure 1 (by norm_num) A := by
  have h : Prod.fst ⁻¹' A = A ×ˢ (Set.univ : Set (ℝ → ℝ)) := by ext ⟨a, b⟩; simp
  rw [h, modesMeasure, Measure.prod_prod, measure_univ, mul_one]

private lemma modesMeasure_preimage_snd (B : Set (ℝ → ℝ)) :
    modesMeasure (Prod.snd ⁻¹' B) = ou1dMeasure 2 (by norm_num) B := by
  have h : Prod.snd ⁻¹' B = (Set.univ : Set (ℝ → ℝ)) ×ˢ B := by ext ⟨a, b⟩; simp
  rw [h, modesMeasure, Measure.prod_prod, measure_univ, one_mul]

private lemma isGaussianProcess_fst_modesMeasure :
    IsGaussianProcess (fun (t : ℝ) (ω : ModesSpace) => ω.1 t) modesMeasure where
  hasGaussianLaw I := by
    have hmp : MeasurePreserving (Prod.fst : ModesSpace → (ℝ → ℝ))
        modesMeasure (ou1dMeasure 1 (by norm_num)) :=
      ⟨measurable_fst, by ext s hs; rw [Measure.map_apply measurable_fst hs, modesMeasure_preimage_fst]⟩
    have h1 := (isGaussianProcess_kernelMeasure
      (fun J => posSemidef_expKernel (by norm_num : (0 : ℝ) < 1) (fun i : J => i.1))).hasGaussianLaw I
    refine ⟨(I.measurable_restrict.comp measurable_fst).aemeasurable, ?_⟩
    have hmap : modesMeasure.map (fun ω : ModesSpace => I.restrict ω.1) =
        (ou1dMeasure 1 (by norm_num)).map (fun x : ℝ → ℝ => I.restrict x) := by
      rw [← hmp.map_eq, Measure.map_map I.measurable_restrict measurable_fst]
      rfl
    rw [hmap]
    exact h1.isGaussian_map

private lemma isGaussianProcess_snd_modesMeasure :
    IsGaussianProcess (fun (t : ℝ) (ω : ModesSpace) => ω.2 t) modesMeasure where
  hasGaussianLaw I := by
    have hmp : MeasurePreserving (Prod.snd : ModesSpace → (ℝ → ℝ))
        modesMeasure (ou1dMeasure 2 (by norm_num)) :=
      ⟨measurable_snd, by ext s hs; rw [Measure.map_apply measurable_snd hs, modesMeasure_preimage_snd]⟩
    have h1 := (isGaussianProcess_kernelMeasure
      (fun J => posSemidef_expKernel (by norm_num : (0 : ℝ) < 2) (fun i : J => i.1))).hasGaussianLaw I
    refine ⟨(I.measurable_restrict.comp measurable_snd).aemeasurable, ?_⟩
    have hmap : modesMeasure.map (fun ω : ModesSpace => I.restrict ω.2) =
        (ou1dMeasure 2 (by norm_num)).map (fun x : ℝ → ℝ => I.restrict x) := by
      rw [← hmp.map_eq, Measure.map_map I.measurable_restrict measurable_snd]
      rfl
    rw [hmap]
    exact h1.isGaussian_map

private lemma modeProj_mulVec_modesTheta (k : Fin 2) (s : ℝ) (ω : ModesSpace) :
    modeProj k *ᵥ modesTheta s ω =
      match k with
      | 0 => ![ω.1 s, 0]
      | 1 => ![0, ω.2 s] := by
  fin_cases k <;> ext j <;> fin_cases j <;>
    simp [modeProj, modesTheta, Matrix.mulVec, dotProduct, Fin.sum_univ_two]

private lemma iIndepFun_modes :
    iIndepFun (fun (k : Fin 2) (ω : ModesSpace) (s : ℝ) => modeProj k *ᵥ modesTheta s ω)
      modesMeasure := by
  have hfst_snd : IndepFun (Prod.fst : ModesSpace → (ℝ → ℝ)) Prod.snd modesMeasure := by
    rw [indepFun_iff_measure_inter_preimage_eq_mul]
    intro A B _ _
    have hinter : Prod.fst ⁻¹' A ∩ Prod.snd ⁻¹' B = A ×ˢ B := by ext ⟨a, b⟩; simp
    rw [hinter, modesMeasure_preimage_fst, modesMeasure_preimage_snd, modesMeasure, Measure.prod_prod]
  let φ0 : (ℝ → ℝ) → (ℝ → Fin 2 → ℝ) := fun x s => ![x s, 0]
  let φ1 : (ℝ → ℝ) → (ℝ → Fin 2 → ℝ) := fun y s => ![0, y s]
  have hφ0 : Measurable φ0 :=
    Measurable.of_eval fun s => Measurable.of_eval fun j => by
      fin_cases j
      · exact measurable_pi_apply s
      · exact measurable_const
  have hφ1 : Measurable φ1 :=
    Measurable.of_eval fun s => Measurable.of_eval fun j => by
      fin_cases j
      · exact measurable_const
      · exact measurable_pi_apply s
  have hind01 : IndepFun (φ0 ∘ Prod.fst) (φ1 ∘ Prod.snd) modesMeasure :=
    hfst_snd.comp hφ0 hφ1
  have h0eq : (fun (ω : ModesSpace) (s : ℝ) => modeProj 0 *ᵥ modesTheta s ω) = φ0 ∘ Prod.fst := by
    funext ω s; exact modeProj_mulVec_modesTheta 0 s ω
  have h1eq : (fun (ω : ModesSpace) (s : ℝ) => modeProj 1 *ᵥ modesTheta s ω) = φ1 ∘ Prod.snd := by
    funext ω s; exact modeProj_mulVec_modesTheta 1 s ω
  rw [iIndepFun_iff_measure_inter_preimage_eq_mul]
  intro S sets hsets
  by_cases h0 : (0 : Fin 2) ∈ S <;> by_cases h1 : (1 : Fin 2) ∈ S
  · have hS : S = {0, 1} := by ext i; fin_cases i <;> simp [h0, h1]
    subst hS
    rw [Finset.prod_pair (by decide : (0 : Fin 2) ≠ 1)]
    have hinter :
        (⋂ i ∈ ({0, 1} : Finset (Fin 2)),
          (fun ω s => modeProj i *ᵥ modesTheta s ω) ⁻¹' sets i) =
          (φ0 ∘ Prod.fst) ⁻¹' sets 0 ∩ (φ1 ∘ Prod.snd) ⁻¹' sets 1 := by
      ext ω; simp [h0eq, h1eq]
    rw [hinter, h0eq, h1eq]
    exact (indepFun_iff_measure_inter_preimage_eq_mul.mp hind01) _ _
      (hsets 0 (by simp)) (hsets 1 (by simp))
  · have hS : S = {0} := by ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp
  · have hS : S = {1} := by ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp
  · have hS : S = ∅ := by ext i; fin_cases i <;> simp [h0, h1]
    subst hS; simp

/-- Non-vacuity witness for `C9`: a 2-mode unequal-rate independent Gaussian OU
system (`T₀ = 1 ≠ 2 = T₁`) on `twoSensorModel` with `R_∞ = 1/2 > 0`, satisfying
all hypotheses (and the unequal-rate formula) of `TinaV2.C09.Statement`. -/
theorem exists_unequal_rate_ou_modes_witness :
    ∃ (M : Model (Fin 2) (Fin 2) (Fin 2)) (Ω : Type) (_ : MeasurableSpace Ω)
      (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (θ : ℝ → Ω → Fin 2 → ℝ) (P : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ)
      (Tc : Fin 2 → ℝ) (S : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ),
      (∀ t, Measurable (θ t)) ∧
      ∑ k, P k = 1 ∧
      Tc 0 ≠ Tc 1 ∧
      iIndepFun (fun k ω (s : ℝ) => P k *ᵥ θ s ω) μ ∧
      (∀ k, 0 < Tc k ∧
        IsGaussianProcess (fun (p : ℝ × Fin 2) ω => (P k *ᵥ θ p.1 ω) p.2) μ ∧
        (∀ t j, ∫ ω, (P k *ᵥ θ t ω) j ∂μ = 0) ∧
        (∀ t s j l, ∫ ω, (P k *ᵥ θ t ω) j * (P k *ᵥ θ s ω) l ∂μ =
          Real.exp (-|t - s| / Tc k) * S k j l)) ∧
      (∀ t, 0 < M.Rinf μ (θ t)) := by
  have hmeas : ∀ t, Measurable (modesTheta t) := fun t =>
    Measurable.of_eval fun j => by
      fin_cases j
      · exact (measurable_pi_apply t).comp measurable_fst
      · exact (measurable_pi_apply t).comp measurable_snd
  have hsumP : ∑ k : Fin 2, modeProj k = 1 := by
    ext i j
    fin_cases i <;> fin_cases j <;> simp [modeProj, Fin.sum_univ_two]
  have hmp1 : MeasurePreserving (Prod.fst : ModesSpace → (ℝ → ℝ))
      modesMeasure (ou1dMeasure 1 (by norm_num)) :=
    ⟨measurable_fst, by ext s hs; rw [Measure.map_apply measurable_fst hs, modesMeasure_preimage_fst]⟩
  have hmp2 : MeasurePreserving (Prod.snd : ModesSpace → (ℝ → ℝ))
      modesMeasure (ou1dMeasure 2 (by norm_num)) :=
    ⟨measurable_snd, by ext s hs; rw [Measure.map_apply measurable_snd hs, modesMeasure_preimage_snd]⟩
  have hmean1 : ∀ t, ∫ ω : ModesSpace, ω.1 t ∂modesMeasure = 0 := fun t => by
    have h1 := integral_map (μ := modesMeasure) measurable_fst.aemeasurable
      (f := fun x : ℝ → ℝ => x t) (measurable_pi_apply t).aestronglyMeasurable
    have h0 : ∫ y : ℝ → ℝ, y t ∂(ou1dMeasure 1 (by norm_num)) = 0 :=
      integral_coord_kernelMeasure _ t
    rw [hmp1.map_eq, h0] at h1
    exact h1.symm
  have hmean2 : ∀ t, ∫ ω : ModesSpace, ω.2 t ∂modesMeasure = 0 := fun t => by
    have h1 := integral_map (μ := modesMeasure) measurable_snd.aemeasurable
      (f := fun x : ℝ → ℝ => x t) (measurable_pi_apply t).aestronglyMeasurable
    have h0 : ∫ y : ℝ → ℝ, y t ∂(ou1dMeasure 2 (by norm_num)) = 0 :=
      integral_coord_kernelMeasure _ t
    rw [hmp2.map_eq, h0] at h1
    exact h1.symm
  have hcov1 : ∀ t s, ∫ ω : ModesSpace, ω.1 t * ω.1 s ∂modesMeasure = Real.exp (-|t - s| / 1) :=
    fun t s => by
      have h1 := integral_map (μ := modesMeasure) measurable_fst.aemeasurable
        (f := fun x : ℝ → ℝ => x t * x s)
        ((measurable_pi_apply t).mul (measurable_pi_apply s)).aestronglyMeasurable
      have h0 : ∫ y : ℝ → ℝ, y t * y s ∂(ou1dMeasure 1 (by norm_num)) = Real.exp (-|t - s| / 1) :=
        integral_mul_coord_kernelMeasure _ t s
      rw [hmp1.map_eq, h0] at h1
      exact h1.symm
  have hcov2 : ∀ t s, ∫ ω : ModesSpace, ω.2 t * ω.2 s ∂modesMeasure = Real.exp (-|t - s| / 2) :=
    fun t s => by
      have h1 := integral_map (μ := modesMeasure) measurable_snd.aemeasurable
        (f := fun x : ℝ → ℝ => x t * x s)
        ((measurable_pi_apply t).mul (measurable_pi_apply s)).aestronglyMeasurable
      have h0 : ∫ y : ℝ → ℝ, y t * y s ∂(ou1dMeasure 2 (by norm_num)) = Real.exp (-|t - s| / 2) :=
        integral_mul_coord_kernelMeasure _ t s
      rw [hmp2.map_eq, h0] at h1
      exact h1.symm
  have hmodes : ∀ k : Fin 2, 0 < modeTc k ∧
      IsGaussianProcess (fun (p : ℝ × Fin 2) ω => (modeProj k *ᵥ modesTheta p.1 ω) p.2) modesMeasure ∧
      (∀ t j, ∫ ω, (modeProj k *ᵥ modesTheta t ω) j ∂modesMeasure = 0) ∧
      (∀ t s j l, ∫ ω, (modeProj k *ᵥ modesTheta t ω) j * (modeProj k *ᵥ modesTheta s ω) l ∂modesMeasure =
        Real.exp (-|t - s| / modeTc k) * modeProj k j l) := by
    intro k
    fin_cases k
    · change 0 < modeTc 0 ∧
        IsGaussianProcess (fun (p : ℝ × Fin 2) ω => (modeProj 0 *ᵥ modesTheta p.1 ω) p.2) modesMeasure ∧
        (∀ t j, ∫ ω, (modeProj 0 *ᵥ modesTheta t ω) j ∂modesMeasure = 0) ∧
        (∀ t s j l, ∫ ω, (modeProj 0 *ᵥ modesTheta t ω) j * (modeProj 0 *ᵥ modesTheta s ω) l ∂modesMeasure =
          Real.exp (-|t - s| / modeTc 0) * modeProj 0 j l)
      refine ⟨by simp [modeTc], ?_, ?_, ?_⟩
      · refine isGaussianProcess_fst_modesMeasure.of_isGaussianProcess fun p => ?_
        refine ⟨{p.1}, if p.2 = 0 then ContinuousLinearMap.proj ⟨p.1, by simp⟩ else 0, fun ω => ?_⟩
        rw [modeProj_mulVec_modesTheta 0]
        rcases p with ⟨t, j⟩
        fin_cases j <;> simp
      · intro t j
        simp_rw [modeProj_mulVec_modesTheta 0]
        fin_cases j
        · simpa using hmean1 t
        · simp
      · intro t s j l
        simp_rw [modeProj_mulVec_modesTheta 0]
        fin_cases j <;> fin_cases l
        · simpa [modeTc, modeProj] using hcov1 t s
        · simp [modeProj]
        · simp [modeProj]
        · simp [modeProj]
    · change 0 < modeTc 1 ∧
        IsGaussianProcess (fun (p : ℝ × Fin 2) ω => (modeProj 1 *ᵥ modesTheta p.1 ω) p.2) modesMeasure ∧
        (∀ t j, ∫ ω, (modeProj 1 *ᵥ modesTheta t ω) j ∂modesMeasure = 0) ∧
        (∀ t s j l, ∫ ω, (modeProj 1 *ᵥ modesTheta t ω) j * (modeProj 1 *ᵥ modesTheta s ω) l ∂modesMeasure =
          Real.exp (-|t - s| / modeTc 1) * modeProj 1 j l)
      refine ⟨by simp [modeTc], ?_, ?_, ?_⟩
      · refine isGaussianProcess_snd_modesMeasure.of_isGaussianProcess fun p => ?_
        refine ⟨{p.1}, if p.2 = 1 then ContinuousLinearMap.proj ⟨p.1, by simp⟩ else 0, fun ω => ?_⟩
        rw [modeProj_mulVec_modesTheta 1]
        rcases p with ⟨t, j⟩
        fin_cases j <;> simp
      · intro t j
        simp_rw [modeProj_mulVec_modesTheta 1]
        fin_cases j
        · simp
        · simpa using hmean2 t
      · intro t s j l
        simp_rw [modeProj_mulVec_modesTheta 1]
        fin_cases j <;> fin_cases l
        · simp [modeProj]
        · simp [modeProj]
        · simp [modeProj]
        · simpa [modeTc, modeProj] using hcov2 t s
  have hRinf : ∀ t, 0 < FiniteModels.twoSensorModel.Rinf modesMeasure (modesTheta t) := by
    intro t
    have h01 : ∫ ω : ModesSpace, modesTheta t ω 0 * modesTheta t ω 1 ∂modesMeasure = 0 := by
      have hprod : (fun ω : ModesSpace => modesTheta t ω 0 * modesTheta t ω 1) =
          fun ω => ω.1 t * ω.2 t := by funext ω; simp [modesTheta]
      rw [hprod, modesMeasure, MeasureTheory.integral_prod_mul (f := fun x : ℝ → ℝ => x t)
        (g := fun y : ℝ → ℝ => y t)]
      have hz : ∫ x : ℝ → ℝ, x t ∂(ou1dMeasure 1 (by norm_num)) = 0 :=
        integral_coord_kernelMeasure _ t
      rw [hz, zero_mul]
    have hr := rinf_twoSensor_of_unit_cov modesMeasure (modesTheta t)
      (isGaussianProcess_fst_modesMeasure.hasGaussianLaw_eval t).memLp_two
      (isGaussianProcess_snd_modesMeasure.hasGaussianLaw_eval t).memLp_two
      (by simpa [modesTheta] using hcov1 t t)
      (by simpa [modesTheta] using hcov2 t t)
      h01
    rw [hr]; norm_num
  exact ⟨FiniteModels.twoSensorModel, ModesSpace, inferInstance, modesMeasure, inferInstance,
    modesTheta, modeProj, modeTc, modeProj, hmeas, hsumP, by norm_num [modeTc], iIndepFun_modes,
    hmodes, hRinf⟩

/-! ## 4. Step 5b — Specialized 1D Gaussian Kolmogorov–Chentsov & `CanonicalField` (`C17.b`, `C18`, `C19`) -/

section GaussianFourthMoment

private lemma fourth_moment_gaussianReal (v : ℝ≥0) :
    ∫ x, x ^ 4 ∂(gaussianReal 0 v) = 3 * (v : ℝ) ^ 2 := by
  have hiter : ∫ x, x ^ 4 ∂(gaussianReal 0 v) =
      iteratedDeriv 4 (mgf (fun x => x) (gaussianReal 0 v)) 0 := by
    simpa using (iteratedDeriv_mgf_zero (X := fun x : ℝ => x) (μ := gaussianReal 0 v) (by simp) 4).symm
  rw [hiter, mgf_fun_id_gaussianReal]
  let a : ℝ := (v : ℝ)
  let g : ℝ → ℝ := fun t => Real.exp (a * t ^ 2 / 2)
  have hg_eq : (fun t => Real.exp (0 * t + (v : ℝ) * t ^ 2 / 2)) = g := by
    funext t; simp [g, a]
  rw [hg_eq]
  have hd_g : ∀ t, HasDerivAt g (a * t * g t) t := by
    intro t
    have h1 : HasDerivAt (fun x : ℝ => a * x ^ 2 / 2) (a * t) t := by
      have hp : HasDerivAt (fun x : ℝ => x ^ 2) (2 * t) t := by
        simpa using hasDerivAt_pow 2 t
      convert (hp.const_mul a).div_const 2 using 1
      ring
    simpa [g, mul_comm] using h1.exp
  have hd1 : deriv g = fun t => a * t * g t := funext fun t => (hd_g t).deriv
  have hd_g2 : ∀ t, HasDerivAt (fun t => a * t * g t) ((a + a ^ 2 * t ^ 2) * g t) t := by
    intro t
    have h1 : HasDerivAt (fun x : ℝ => a * x) a t := by
      simpa using (hasDerivAt_id t).const_mul a
    convert h1.mul (hd_g t) using 1
    ring
  have hd2 : deriv (deriv g) = fun t => (a + a ^ 2 * t ^ 2) * g t := by
    rw [hd1]; exact funext fun t => (hd_g2 t).deriv
  have hd_g3 : ∀ t, HasDerivAt (fun t => (a + a ^ 2 * t ^ 2) * g t)
      ((3 * a ^ 2 * t + a ^ 3 * t ^ 3) * g t) t := by
    intro t
    have h1 : HasDerivAt (fun x : ℝ => a + a ^ 2 * x ^ 2) (2 * a ^ 2 * t) t := by
      have hp : HasDerivAt (fun x : ℝ => x ^ 2) (2 * t) t := by
        simpa using hasDerivAt_pow 2 t
      convert (hasDerivAt_const t a).add (hp.const_mul (a ^ 2)) using 1
      ring
    convert h1.mul (hd_g t) using 1
    ring
  have hd3 : deriv (deriv (deriv g)) = fun t => (3 * a ^ 2 * t + a ^ 3 * t ^ 3) * g t := by
    rw [hd2]; exact funext fun t => (hd_g3 t).deriv
  have hd_g4 : HasDerivAt (fun t => (3 * a ^ 2 * t + a ^ 3 * t ^ 3) * g t) (3 * a ^ 2) 0 := by
    have h1 : HasDerivAt (fun x : ℝ => 3 * a ^ 2 * x + a ^ 3 * x ^ 3) (3 * a ^ 2) 0 := by
      have hp1 : HasDerivAt (fun x : ℝ => 3 * a ^ 2 * x) (3 * a ^ 2) 0 := by
        simpa using (hasDerivAt_id (0 : ℝ)).const_mul (3 * a ^ 2)
      have hp3 : HasDerivAt (fun x : ℝ => a ^ 3 * x ^ 3) 0 0 := by
        have hp : HasDerivAt (fun x : ℝ => x ^ 3) (3 * (0 : ℝ) ^ 2) 0 := by
          simpa using hasDerivAt_pow 3 (0 : ℝ)
        simpa using hp.const_mul (a ^ 3)
      convert hp1.add hp3 using 1
      ring
    have hmul := h1.mul (hd_g 0)
    convert hmul using 1
    simp [g]
  have h4 : iteratedDeriv 4 g 0 = deriv (deriv (deriv (deriv g))) 0 := by
    simp [iteratedDeriv_succ, iteratedDeriv_zero]
  rw [h4, hd3, hd_g4.deriv]

private lemma fourth_moment_of_hasGaussianLaw {Ω : Type*} [MeasurableSpace Ω]
    {μ : Measure Ω} [IsProbabilityMeasure μ] {Z : Ω → ℝ}
    (hZ : HasGaussianLaw Z μ) (hmean : ∫ ω, Z ω ∂μ = 0) :
    ∫ ω, Z ω ^ 4 ∂μ = 3 * (∫ ω, Z ω ^ 2 ∂μ) ^ 2 := by
  have hmap : μ.map Z = gaussianReal 0 Var[Z; μ].toNNReal := by
    simpa [hmean] using hZ.map_eq_gaussianReal
  have hvar_eq : Var[Z; μ] = ∫ ω, Z ω ^ 2 ∂μ := by
    rw [variance_eq_integral hZ.aemeasurable, hmean]
    simp
  have hvar_nn : 0 ≤ Var[Z; μ] := variance_nonneg Z μ
  have hint : ∫ ω, Z ω ^ 4 ∂μ = ∫ x, x ^ 4 ∂(μ.map Z) := by
    symm
    exact integral_map hZ.aemeasurable (by fun_prop)
  rw [hint, hmap, fourth_moment_gaussianReal, Real.coe_toNNReal _ hvar_nn, hvar_eq]

private lemma measure_abs_gt_le_of_pow {Ω : Type*} [MeasurableSpace Ω]
    {μ : Measure Ω} {f : Ω → ℝ} (hfm : Measurable f) {p : ℕ}
    (hfp : Integrable (fun ω => |f ω| ^ p) μ) {ε : ℝ} (hε : 0 < ε) :
    μ {ω | ε < |f ω|} ≤ ENNReal.ofReal ((∫ ω, |f ω| ^ p ∂μ) / ε ^ p) := by
  have hsub : {ω | ε < |f ω|} ⊆ {ω | ENNReal.ofReal (ε ^ p) ≤ ENNReal.ofReal (|f ω| ^ p)} := by
    intro ω hω
    exact ENNReal.ofReal_le_ofReal (pow_le_pow_left₀ hε.le hω.le p)
  have hmarkov := mul_meas_ge_le_lintegral₀ (μ := μ)
    (((continuous_abs.measurable.comp hfm).pow_const p).ennreal_ofReal.aemeasurable)
    (ENNReal.ofReal (ε ^ p))
  simp only [Function.comp_apply] at hmarkov
  have hlint : ∫⁻ ω, ENNReal.ofReal (|f ω| ^ p) ∂μ = ENNReal.ofReal (∫ ω, |f ω| ^ p ∂μ) :=
    (ofReal_integral_eq_lintegral_ofReal hfp (Eventually.of_forall fun _ => by positivity)).symm
  rw [hlint] at hmarkov
  have hεp : 0 < ε ^ p := pow_pos hε p
  have hεp_ne0 : ENNReal.ofReal (ε ^ p) ≠ 0 := (ENNReal.ofReal_pos.mpr hεp).ne'
  have hεp_top : ENNReal.ofReal (ε ^ p) ≠ ∞ := ENNReal.ofReal_ne_top
  calc μ {ω | ε < |f ω|}
      ≤ μ {ω | ENNReal.ofReal (ε ^ p) ≤ ENNReal.ofReal (|f ω| ^ p)} := measure_mono hsub
    _ ≤ ENNReal.ofReal (∫ ω, |f ω| ^ p ∂μ) / ENNReal.ofReal (ε ^ p) :=
        ENNReal.le_div_iff_mul_le (Or.inl hεp_ne0) (Or.inl hεp_top) |>.mpr
          (by simpa [mul_comm] using hmarkov)
    _ = ENNReal.ofReal ((∫ ω, |f ω| ^ p ∂μ) / ε ^ p) := by
        rw [ENNReal.ofReal_div_of_pos hεp]

end GaussianFourthMoment

section DyadicKC

/-- Dyadic floor approximation `⌊z · 2^n⌋ / 2^n` of `z : ℝ` at scale `2^{-n}`. -/
def dyadicApprox (n : ℕ) (z : ℝ) : ℝ :=
  (⌊z * (2 : ℝ) ^ n⌋ : ℝ) / (2 : ℝ) ^ n

private lemma dyadicApprox_le (n : ℕ) (z : ℝ) : dyadicApprox n z ≤ z := by
  unfold dyadicApprox
  have h2 : (0 : ℝ) < (2 : ℝ) ^ n := by positivity
  rw [div_le_iff₀ h2]
  exact Int.floor_le (z * (2 : ℝ) ^ n)

private lemma sub_dyadicApprox_lt (n : ℕ) (z : ℝ) :
    z - dyadicApprox n z < (1 / 2 : ℝ) ^ n := by
  unfold dyadicApprox
  have h2 : (0 : ℝ) < (2 : ℝ) ^ n := by positivity
  have hlt : z * (2 : ℝ) ^ n - 1 < (⌊z * (2 : ℝ) ^ n⌋ : ℝ) := Int.sub_one_lt_floor _
  have h1 : z - (⌊z * (2 : ℝ) ^ n⌋ : ℝ) / (2 : ℝ) ^ n < 1 / (2 : ℝ) ^ n := by
    rw [sub_lt_iff_lt_add, ← add_div, lt_div_iff₀ h2]
    linarith
  simpa [one_div, inv_pow] using h1

private lemma abs_dyadicApprox_sub_le (n : ℕ) (z : ℝ) :
    |dyadicApprox n z - z| ≤ (1 / 2 : ℝ) ^ n := by
  rw [abs_sub_comm, abs_of_nonneg (sub_nonneg.mpr (dyadicApprox_le n z))]
  exact (sub_dyadicApprox_lt n z).le

private lemma floor_mul_two_cases (x : ℝ) :
    ⌊x * 2⌋ = 2 * ⌊x⌋ ∨ ⌊x * 2⌋ = 2 * ⌊x⌋ + 1 := by
  have hlo : (2 * ⌊x⌋ : ℤ) ≤ ⌊x * 2⌋ := by
    rw [Int.le_floor]
    push_cast
    linarith [Int.floor_le x]
  have hhi : ⌊x * 2⌋ < (2 * ⌊x⌋ + 2 : ℤ) := by
    rw [Int.floor_lt]
    push_cast
    linarith [Int.lt_floor_add_one x]
  omega

private lemma dyadic_step_bound {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {n : ℕ} (hn : M ≤ n) {z : ℝ} (hzlo : -(N : ℝ) ≤ z) (hzhi : z ≤ (N : ℝ)) :
    |f (dyadicApprox (n + 1) z) - f (dyadicApprox n z)| ≤ (7 / 8 : ℝ) ^ (n + 1) := by
  set q : ℤ := ⌊z * (2 : ℝ) ^ n⌋
  have hmul : z * (2 : ℝ) ^ (n + 1) = (z * (2 : ℝ) ^ n) * 2 := by rw [pow_succ]; ring
  rcases floor_mul_two_cases (z * (2 : ℝ) ^ n) with h0 | h1
  · have hEq : dyadicApprox (n + 1) z = dyadicApprox n z := by
      unfold dyadicApprox
      rw [hmul, h0]
      push_cast
      rw [pow_succ]
      have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
      field_simp [h2]
    rw [hEq, sub_self, abs_zero]
    positivity
  · have hq_lo : -(N : ℤ) * (2 : ℤ) ^ n ≤ q := by
      rw [Int.le_floor]
      push_cast
      have h2 : (0 : ℝ) ≤ (2 : ℝ) ^ n := by positivity
      nlinarith
    have hq_lt : q < (N : ℤ) * (2 : ℤ) ^ n := by
      by_contra hge
      push Not at hge
      have hle : q ≤ (N : ℤ) * (2 : ℤ) ^ n := by
        have h2 : (0 : ℝ) ≤ (2 : ℝ) ^ n := by positivity
        have h1' : z * (2 : ℝ) ^ n ≤ ((N : ℤ) * (2 : ℤ) ^ n : ℤ) := by
          push_cast; nlinarith
        exact Int.floor_le_iff.mpr (by
          have : z * (2 : ℝ) ^ n < (((N : ℤ) * (2 : ℤ) ^ n : ℤ) : ℝ) + 1 := by linarith
          exact this)
      have hq_eq : q = (N : ℤ) * (2 : ℤ) ^ n := le_antisymm hle hge
      have hz_eq : z * (2 : ℝ) ^ n = ((N : ℤ) * (2 : ℤ) ^ n : ℤ) := by
        have hlo' : (q : ℝ) ≤ z * (2 : ℝ) ^ n := Int.floor_le _
        have hhi' : z * (2 : ℝ) ^ n ≤ ((N : ℤ) * (2 : ℤ) ^ n : ℤ) := by
          push_cast
          have h2 : (0 : ℝ) ≤ (2 : ℝ) ^ n := by positivity
          nlinarith
        rw [hq_eq] at hlo'
        exact le_antisymm hhi' hlo'
      have hf2 : ⌊z * (2 : ℝ) ^ n * 2⌋ = 2 * q := by
        rw [hz_eq]
        have : (((N : ℤ) * (2 : ℤ) ^ n : ℤ) : ℝ) * 2 = ((2 * ((N : ℤ) * (2 : ℤ) ^ n) : ℤ) : ℝ) := by
          push_cast; ring
        rw [this, Int.floor_intCast, hq_eq]
      omega
    have hk_lo : -(N : ℤ) * (2 : ℤ) ^ (n + 1) ≤ 2 * q := by rw [pow_succ]; nlinarith
    have hk_lt : 2 * q < (N : ℤ) * (2 : ℤ) ^ (n + 1) := by rw [pow_succ]; nlinarith
    have hb := hbound (n + 1) (by omega) (2 * q) hk_lo hk_lt
    have hEq1 : dyadicApprox (n + 1) z = (((2 * q : ℤ) : ℝ) + 1) / (2 : ℝ) ^ (n + 1) := by
      unfold dyadicApprox
      rw [hmul, h1]
      push_cast; rfl
    have hEq0 : dyadicApprox n z = ((2 * q : ℤ) : ℝ) / (2 : ℝ) ^ (n + 1) := by
      unfold dyadicApprox
      push_cast
      rw [pow_succ]
      have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
      field_simp [h2]
      ring
    rw [hEq1, hEq0]
    exact hb

private lemma dyadic_chain_bound {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {m : ℕ} (hm : M ≤ m) {z : ℝ} (hzlo : -(N : ℝ) ≤ z) (hzhi : z ≤ (N : ℝ)) :
    ∀ d : ℕ, |f (dyadicApprox (m + d) z) - f (dyadicApprox m z)| ≤
      7 * (7 / 8 : ℝ) ^ m - 7 * (7 / 8 : ℝ) ^ (m + d) := by
  intro d
  induction d with
  | zero => simp
  | succ d ih =>
    have hstep := dyadic_step_bound hbound (n := m + d) (by omega) hzlo hzhi
    have htri : |f (dyadicApprox (m + (d + 1)) z) - f (dyadicApprox m z)| ≤
        |f (dyadicApprox (m + d + 1) z) - f (dyadicApprox (m + d) z)| +
          |f (dyadicApprox (m + d) z) - f (dyadicApprox m z)| := by
      have : m + (d + 1) = m + d + 1 := by omega
      rw [this]
      exact abs_sub_le _ _ _
    have halg : (7 / 8 : ℝ) ^ (m + d + 1) + (7 * (7 / 8 : ℝ) ^ m - 7 * (7 / 8 : ℝ) ^ (m + d)) =
        7 * (7 / 8 : ℝ) ^ m - 7 * (7 / 8 : ℝ) ^ (m + (d + 1)) := by
      have : m + (d + 1) = m + d + 1 := by omega
      rw [this, pow_succ]
      ring
    linarith

private lemma dyadic_tail_bound {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {m n : ℕ} (hm : M ≤ m) (hmn : m ≤ n) {z : ℝ} (hzlo : -(N : ℝ) ≤ z) (hzhi : z ≤ (N : ℝ)) :
    |f (dyadicApprox n z) - f (dyadicApprox m z)| ≤ 7 * (7 / 8 : ℝ) ^ m := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hmn
  have h := dyadic_chain_bound hbound hm hzlo hzhi d
  have hnn : (0 : ℝ) ≤ 7 * (7 / 8 : ℝ) ^ (m + d) := by positivity
  linarith

private lemma dyadic_same_level_bound {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {m : ℕ} (hm : M ≤ m) {z₁ z₂ : ℝ}
    (h1lo : -(N : ℝ) ≤ z₁) (h1hi : z₁ ≤ (N : ℝ))
    (h2lo : -(N : ℝ) ≤ z₂) (h2hi : z₂ ≤ (N : ℝ))
    (hdist : |z₁ - z₂| ≤ (1 / 2 : ℝ) ^ m) :
    |f (dyadicApprox m z₁) - f (dyadicApprox m z₂)| ≤ (7 / 8 : ℝ) ^ m := by
  set q₁ : ℤ := ⌊z₁ * (2 : ℝ) ^ m⌋
  set q₂ : ℤ := ⌊z₂ * (2 : ℝ) ^ m⌋
  have h2pos : (0 : ℝ) < (2 : ℝ) ^ m := by positivity
  have hdiff : |z₁ * (2 : ℝ) ^ m - z₂ * (2 : ℝ) ^ m| ≤ 1 := by
    rw [← sub_mul, abs_mul, abs_of_pos h2pos]
    calc |z₁ - z₂| * (2 : ℝ) ^ m
        ≤ (1 / 2 : ℝ) ^ m * (2 : ℝ) ^ m := mul_le_mul_of_nonneg_right hdist h2pos.le
      _ = 1 := by rw [one_div, inv_pow, inv_mul_cancel₀ h2pos.ne']
  have hq_diff : q₁ = q₂ ∨ q₁ = q₂ + 1 ∨ q₂ = q₁ + 1 := by
    have h1a : (q₁ : ℝ) ≤ z₁ * (2 : ℝ) ^ m := Int.floor_le _
    have h1b : z₁ * (2 : ℝ) ^ m < (q₁ : ℝ) + 1 := Int.lt_floor_add_one _
    have h2a : (q₂ : ℝ) ≤ z₂ * (2 : ℝ) ^ m := Int.floor_le _
    have h2b : z₂ * (2 : ℝ) ^ m < (q₂ : ℝ) + 1 := Int.lt_floor_add_one _
    have hd1 : z₁ * (2 : ℝ) ^ m - z₂ * (2 : ℝ) ^ m ≤ 1 := (abs_le.mp hdiff).2
    have hd2 : -1 ≤ z₁ * (2 : ℝ) ^ m - z₂ * (2 : ℝ) ^ m := (abs_le.mp hdiff).1
    have hlt1 : (q₁ : ℝ) < (q₂ : ℝ) + 2 := by linarith
    have hlt2 : (q₂ : ℝ) < (q₁ : ℝ) + 2 := by linarith
    have hi1 : q₁ < q₂ + 2 := by exact_mod_cast hlt1
    have hi2 : q₂ < q₁ + 2 := by exact_mod_cast hlt2
    omega
  have hq1_lo : -(N : ℤ) * (2 : ℤ) ^ m ≤ q₁ := by
    rw [Int.le_floor]; push_cast; nlinarith
  have hq2_lo : -(N : ℤ) * (2 : ℤ) ^ m ≤ q₂ := by
    rw [Int.le_floor]; push_cast; nlinarith
  have hq1_hi : q₁ ≤ (N : ℤ) * (2 : ℤ) ^ m := by
    have : z₁ * (2 : ℝ) ^ m < (((N : ℤ) * (2 : ℤ) ^ m : ℤ) : ℝ) + 1 := by push_cast; nlinarith
    exact Int.floor_le_iff.mpr this
  have hq2_hi : q₂ ≤ (N : ℤ) * (2 : ℤ) ^ m := by
    have : z₂ * (2 : ℝ) ^ m < (((N : ℤ) * (2 : ℤ) ^ m : ℤ) : ℝ) + 1 := by push_cast; nlinarith
    exact Int.floor_le_iff.mpr this
  rcases hq_diff with hEq | h1 | h2
  · have : dyadicApprox m z₁ = dyadicApprox m z₂ := by unfold dyadicApprox; simp [q₁, q₂, hEq]
    rw [this, sub_self, abs_zero]; positivity
  · have hq2_lt : q₂ < (N : ℤ) * (2 : ℤ) ^ m := by omega
    have hb := hbound m hm q₂ hq2_lo hq2_lt
    have heq1 : dyadicApprox m z₁ = ((q₂ : ℝ) + 1) / (2 : ℝ) ^ m := by
      unfold dyadicApprox; rw [show ⌊z₁ * (2 : ℝ) ^ m⌋ = q₂ + 1 from h1]; push_cast; rfl
    have heq2 : dyadicApprox m z₂ = (q₂ : ℝ) / (2 : ℝ) ^ m := rfl
    rw [heq1, heq2]; exact hb
  · have hq1_lt : q₁ < (N : ℤ) * (2 : ℤ) ^ m := by omega
    have hb := hbound m hm q₁ hq1_lo hq1_lt
    have heq1 : dyadicApprox m z₁ = (q₁ : ℝ) / (2 : ℝ) ^ m := rfl
    have heq2 : dyadicApprox m z₂ = ((q₁ : ℝ) + 1) / (2 : ℝ) ^ m := by
      unfold dyadicApprox; rw [show ⌊z₂ * (2 : ℝ) ^ m⌋ = q₁ + 1 from h2]; push_cast; rfl
    rw [heq1, heq2, abs_sub_comm]; exact hb

private lemma dyadic_cauchySeq {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {z : ℝ} (hzlo : -(N : ℝ) ≤ z) (hzhi : z ≤ (N : ℝ)) :
    CauchySeq (fun n => f (dyadicApprox n z)) := by
  rw [Metric.cauchySeq_iff]
  intro ε hε
  have htend : Tendsto (fun m : ℕ => 14 * (7 / 8 : ℝ) ^ m) atTop (𝓝 (14 * 0)) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)).const_mul 14
  rw [mul_zero] at htend
  obtain ⟨K, hK⟩ := Metric.tendsto_atTop.mp htend ε hε
  refine ⟨max M K, fun n₁ hn₁ n₂ hn₂ => ?_⟩
  set m := max M K
  have h1 := dyadic_tail_bound hbound (le_max_left M K) hn₁ hzlo hzhi
  have h2 := dyadic_tail_bound hbound (le_max_left M K) hn₂ hzlo hzhi
  have htri : |f (dyadicApprox n₁ z) - f (dyadicApprox n₂ z)| ≤ 14 * (7 / 8 : ℝ) ^ m := by
    have := abs_sub_le (f (dyadicApprox n₁ z)) (f (dyadicApprox m z)) (f (dyadicApprox n₂ z))
    rw [abs_sub_comm (f (dyadicApprox m z)) (f (dyadicApprox n₂ z))] at this
    linarith
  have hm_lt : 14 * (7 / 8 : ℝ) ^ m < ε := by
    have hdist := hK m (le_max_right M K)
    rw [Real.dist_eq, sub_zero, abs_of_nonneg (by positivity)] at hdist
    exact hdist
  rw [Real.dist_eq]
  linarith

private lemma dyadic_limit_modulus {f : ℝ → ℝ} {N M : ℕ}
    (hbound : ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
      |f (((k : ℝ) + 1) / (2 : ℝ) ^ n) - f ((k : ℝ) / (2 : ℝ) ^ n)| ≤ (7 / 8 : ℝ) ^ n)
    {m : ℕ} (hm : M ≤ m) {z₁ z₂ : ℝ}
    (h1lo : -(N : ℝ) ≤ z₁) (h1hi : z₁ ≤ (N : ℝ))
    (h2lo : -(N : ℝ) ≤ z₂) (h2hi : z₂ ≤ (N : ℝ))
    (hdist : |z₁ - z₂| ≤ (1 / 2 : ℝ) ^ m) :
    |limUnder atTop (fun n => f (dyadicApprox n z₁)) -
      limUnder atTop (fun n => f (dyadicApprox n z₂))| ≤ 15 * (7 / 8 : ℝ) ^ m := by
  obtain ⟨L₁, hL₁⟩ := cauchySeq_tendsto_of_complete (dyadic_cauchySeq hbound h1lo h1hi)
  obtain ⟨L₂, hL₂⟩ := cauchySeq_tendsto_of_complete (dyadic_cauchySeq hbound h2lo h2hi)
  rw [hL₁.limUnder_eq, hL₂.limUnder_eq]
  have hsub : Tendsto (fun n => |f (dyadicApprox n z₁) - f (dyadicApprox n z₂)|)
      atTop (𝓝 |L₁ - L₂|) := (hL₁.sub hL₂).abs
  refine le_of_tendsto hsub (Filter.eventually_atTop.mpr ⟨m, fun n hn => ?_⟩)
  have ht1 := dyadic_tail_bound hbound hm hn h1lo h1hi
  have ht2 := dyadic_tail_bound hbound hm hn h2lo h2hi
  have hs := dyadic_same_level_bound hbound hm h1lo h1hi h2lo h2hi hdist
  have htri1 := abs_sub_le (f (dyadicApprox n z₁)) (f (dyadicApprox m z₁)) (f (dyadicApprox n z₂))
  have htri2 := abs_sub_le (f (dyadicApprox m z₁)) (f (dyadicApprox m z₂)) (f (dyadicApprox n z₂))
  rw [abs_sub_comm (f (dyadicApprox m z₂)) (f (dyadicApprox n z₂))] at htri2
  linarith

/-- Bad event on `[-N, N]` at dyadic scale `n`: some adjacent dyadic step of
length `2^{-n}` has increment exceeding `(7/8)^n`. -/
def badEvent {Ω : Type*} (Y : ℝ → Ω → ℝ) (N n : ℕ) : Set Ω :=
  ⋃ k ∈ Finset.Ico (-(N : ℤ) * (2 : ℤ) ^ n) ((N : ℤ) * (2 : ℤ) ^ n),
    {ω | (7 / 8 : ℝ) ^ n < |Y (((k : ℝ) + 1) / (2 : ℝ) ^ n) ω - Y ((k : ℝ) / (2 : ℝ) ^ n) ω|}

/-- Good event on `[-N, N]`: eventually every adjacent dyadic increment on
`[-N, N]` is bounded by `(7/8)^n`. -/
def goodOn {Ω : Type*} (Y : ℝ → Ω → ℝ) (N : ℕ) : Set Ω :=
  ⋃ M : ℕ, ⋂ n : ℕ, ⋂ (_ : M ≤ n), (badEvent Y N n)ᶜ

/-- Global good event: `goodOn Y (N + 1)` holds for every `N : ℕ`. -/
def goodGlobal {Ω : Type*} (Y : ℝ → Ω → ℝ) : Set Ω :=
  ⋂ N : ℕ, goodOn Y (N + 1)

open Classical in
/-- Dyadic-limit continuous modification of a 1D process `Y`. -/
def dyadicMod {Ω : Type*} (Y : ℝ → Ω → ℝ) (z : ℝ) (ω : Ω) : ℝ :=
  if ω ∈ goodGlobal Y then limUnder atTop (fun n : ℕ => Y (dyadicApprox n z) ω) else 0

private lemma measurableSet_badEvent {Ω : Type*} [MeasurableSpace Ω]
    {Y : ℝ → Ω → ℝ} (hmeas : ∀ z, Measurable (Y z)) (N n : ℕ) :
    MeasurableSet (badEvent Y N n) := by
  refine Finset.measurableSet_biUnion _ fun k _ => ?_
  exact measurableSet_lt measurable_const (continuous_abs.measurable.comp ((hmeas _).sub (hmeas _)))

private lemma measurableSet_goodGlobal {Ω : Type*} [MeasurableSpace Ω]
    {Y : ℝ → Ω → ℝ} (hmeas : ∀ z, Measurable (Y z)) :
    MeasurableSet (goodGlobal Y) :=
  MeasurableSet.iInter fun N =>
    MeasurableSet.iUnion fun _ =>
      MeasurableSet.iInter fun n =>
        MeasurableSet.iInter fun _ => (measurableSet_badEvent hmeas (N + 1) n).compl

private lemma mem_goodOn_iff {Ω : Type*} {Y : ℝ → Ω → ℝ} {N : ℕ} {ω : Ω} :
    ω ∈ goodOn Y N ↔
      ∃ M : ℕ, ∀ n ≥ M, ∀ k : ℤ, -(N : ℤ) * (2 : ℤ) ^ n ≤ k → k < (N : ℤ) * (2 : ℤ) ^ n →
        |Y (((k : ℝ) + 1) / (2 : ℝ) ^ n) ω - Y ((k : ℝ) / (2 : ℝ) ^ n) ω| ≤ (7 / 8 : ℝ) ^ n := by
  simp only [goodOn, badEvent, mem_iUnion, mem_iInter, mem_compl_iff, not_exists, mem_ofPred_eq,
    Finset.mem_Ico, not_lt, and_imp]

/-- Specialized 1D Gaussian Kolmogorov–Chentsov theorem: any centered 1D process
whose increments are Gaussian with variance `≤ L |z − z'|` admits a measurable,
everywhere continuous modification. -/
theorem exists_continuous_modification_1d
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    (Y : ℝ → Ω → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hmeas : ∀ z, Measurable (Y z))
    (hgauss : ∀ z z', HasGaussianLaw (fun ω => Y z ω - Y z' ω) μ)
    (hmean : ∀ z z', ∫ ω, (Y z ω - Y z' ω) ∂μ = 0)
    (hvar : ∀ z z', ∫ ω, (Y z ω - Y z' ω) ^ 2 ∂μ ≤ L * |z - z'|) :
    ∃ Y' : ℝ → Ω → ℝ,
      (∀ z, Measurable (Y' z)) ∧
      (∀ ω, Continuous (fun z => Y' z ω)) ∧
      (∀ z, Y' z =ᵐ[μ] Y z) := by
  refine ⟨dyadicMod Y, ?_, ?_, ?_⟩
  · -- Measurability of `dyadicMod Y z`
    intro z
    unfold dyadicMod
    refine Measurable.ite (measurableSet_goodGlobal hmeas) ?_ measurable_const
    exact (StronglyMeasurable.limUnder fun n => (hmeas (dyadicApprox n z)).stronglyMeasurable).measurable
  · -- Everywhere continuity of `z ↦ dyadicMod Y z ω`
    intro ω
    by_cases hω : ω ∈ goodGlobal Y
    · have hEq : (fun z => dyadicMod Y z ω) =
          fun z => limUnder atTop (fun n => Y (dyadicApprox n z) ω) := by
        funext z; simp [dyadicMod, hω]
      rw [hEq, Metric.continuous_iff]
      intro z₀ ε hε
      let N : ℕ := Nat.ceil |z₀| + 1
      have hωN : ω ∈ goodOn Y (N + 1) := mem_iInter.mp hω N
      obtain ⟨M, hbound⟩ := mem_goodOn_iff.mp hωN
      have htend : Tendsto (fun m : ℕ => 15 * (7 / 8 : ℝ) ^ m) atTop (𝓝 (15 * 0)) :=
        (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)).const_mul 15
      rw [mul_zero] at htend
      obtain ⟨K, hK⟩ := Metric.tendsto_atTop.mp htend ε hε
      let m : ℕ := max M K
      have hm_lt : 15 * (7 / 8 : ℝ) ^ m < ε := by
        have hdist := hK m (le_max_right M K)
        rw [Real.dist_eq, sub_zero, abs_of_nonneg (by positivity)] at hdist
        exact hdist
      refine ⟨min 1 ((1 / 2 : ℝ) ^ m), lt_min zero_lt_one (by positivity), fun z hz => ?_⟩
      rw [Real.dist_eq] at hz ⊢
      have h1 : |z - z₀| < 1 := lt_of_lt_of_le hz (min_le_left _ _)
      have h2 : |z - z₀| ≤ (1 / 2 : ℝ) ^ m := (lt_of_lt_of_le hz (min_le_right _ _)).le
      have hz0_abs : |z₀| ≤ (N : ℝ) := by
        have : |z₀| ≤ (Nat.ceil |z₀| : ℝ) := Nat.le_ceil _
        push_cast [N]; linarith
      have hz0_lo : -((N + 1 : ℕ) : ℝ) ≤ z₀ := by
        have := (abs_le.mp hz0_abs).1; push_cast; linarith
      have hz0_hi : z₀ ≤ ((N + 1 : ℕ) : ℝ) := by
        have := (abs_le.mp hz0_abs).2; push_cast; linarith
      have hz_abs : |z| ≤ ((N + 1 : ℕ) : ℝ) := by
        have := abs_sub_abs_le_abs_sub z z₀
        push_cast; linarith
      have hmod := dyadic_limit_modulus (f := fun z => Y z ω) hbound (le_max_left M K)
        (abs_le.mp hz_abs).1 (abs_le.mp hz_abs).2 hz0_lo hz0_hi h2
      linarith
    · have hEq : (fun z => dyadicMod Y z ω) = fun _ => 0 := by
        funext z; simp [dyadicMod, hω]
      rw [hEq]
      exact continuous_const
  · -- Modification: `dyadicMod Y z =ᵐ[μ] Y z` for every `z`
    -- Step 1: `goodGlobal Y` holds `μ`-almost surely via 4th-moment Borel–Cantelli
    have hgood : ∀ᵐ ω ∂μ, ω ∈ goodGlobal Y := by
      have hgoodN : ∀ N : ℕ, ∀ᵐ ω ∂μ, ω ∈ goodOn Y (N + 1) := by
        intro N
        have hsum : ∑' n : ℕ, μ (badEvent Y (N + 1) n) ≠ ∞ := by
          let C : ℝ := 6 * ((N + 1 : ℕ) : ℝ) * L ^ 2
          have hC : 0 ≤ C := by positivity
          have hterm : ∀ n : ℕ, μ (badEvent Y (N + 1) n) ≤
              ENNReal.ofReal C * (ENNReal.ofReal (2048 / 2401 : ℝ)) ^ n := by
            intro n
            have hbound_k : ∀ k : ℤ,
                μ {ω | (7 / 8 : ℝ) ^ n <
                    |Y (((k : ℝ) + 1) / (2 : ℝ) ^ n) ω - Y ((k : ℝ) / (2 : ℝ) ^ n) ω|} ≤
                  ENNReal.ofReal (3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n) := by
              intro k
              set z₁ : ℝ := ((k : ℝ) + 1) / (2 : ℝ) ^ n
              set z₀ : ℝ := (k : ℝ) / (2 : ℝ) ^ n
              set Z : Ω → ℝ := fun ω => Y z₁ ω - Y z₀ ω
              have hZg : HasGaussianLaw Z μ := hgauss z₁ z₀
              have hZ4_int : Integrable (fun ω => |Z ω| ^ 4) μ := by
                have hlp := hZg.memLp (p := (4 : ℝ≥0∞)) (by simp)
                have hi := hlp.integrable_norm_rpow (by simp) (by simp)
                simpa [Real.norm_eq_abs] using hi
              have hmark := measure_abs_gt_le_of_pow ((hmeas z₁).sub (hmeas z₀))
                hZ4_int (by positivity : (0 : ℝ) < (7 / 8 : ℝ) ^ n)
              have habs4 : (fun ω => |Z ω| ^ 4) = fun ω => Z ω ^ 4 := by
                funext ω
                have : |Z ω| ^ 4 = (|Z ω| ^ 2) ^ 2 := by ring
                rw [this, sq_abs]; ring
              have hdist : |z₁ - z₀| = (1 / 2 : ℝ) ^ n := by
                have hsub : z₁ - z₀ = 1 / (2 : ℝ) ^ n := by
                  simp only [z₁, z₀]; rw [← sub_div]; ring
                rw [hsub, abs_of_pos (by positivity), one_div, one_div, inv_pow]
              have hvar_le : ∫ ω, Z ω ^ 2 ∂μ ≤ L * (1 / 2 : ℝ) ^ n := by
                rw [← hdist]; exact hvar z₁ z₀
              have hvar_nn : 0 ≤ ∫ ω, Z ω ^ 2 ∂μ := integral_nonneg fun _ => sq_nonneg _
              have h4_le : ∫ ω, |Z ω| ^ 4 ∂μ ≤ 3 * L ^ 2 * (1 / 4 : ℝ) ^ n := by
                rw [habs4, fourth_moment_of_hasGaussianLaw hZg (hmean z₁ z₀)]
                have hsq : (∫ ω, Z ω ^ 2 ∂μ) ^ 2 ≤ (L * (1 / 2 : ℝ) ^ n) ^ 2 :=
                  pow_le_pow_left₀ hvar_nn hvar_le 2
                have hpow : (L * (1 / 2 : ℝ) ^ n) ^ 2 = L ^ 2 * (1 / 4 : ℝ) ^ n := by
                  rw [mul_pow, ← pow_mul, mul_comm n 2, pow_mul]; norm_num
                linarith
              have hdiv : (∫ ω, |Z ω| ^ 4 ∂μ) / ((7 / 8 : ℝ) ^ n) ^ 4 ≤
                  3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n := by
                have hden : (0 : ℝ) < ((7 / 8 : ℝ) ^ n) ^ 4 := by positivity
                rw [div_le_iff₀ hden]
                calc ∫ ω, |Z ω| ^ 4 ∂μ
                    ≤ 3 * L ^ 2 * (1 / 4 : ℝ) ^ n := h4_le
                  _ = 3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n * ((7 / 8 : ℝ) ^ n) ^ 4 := by
                      rw [mul_assoc (3 * L ^ 2), ← pow_mul, mul_comm n 4, pow_mul, ← mul_pow]
                      norm_num
              exact hmark.trans (ENNReal.ofReal_le_ofReal hdiv)
            have hcard :
                (Finset.Ico (-(((N + 1 : ℕ) : ℤ)) * (2 : ℤ) ^ n)
                  (((N + 1 : ℕ) : ℤ) * (2 : ℤ) ^ n)).card = 2 * (N + 1) * 2 ^ n := by
              rw [Int.card_Ico]
              have hdiff : ((N + 1 : ℕ) : ℤ) * (2 : ℤ) ^ n - -(((N + 1 : ℕ) : ℤ)) * (2 : ℤ) ^ n =
                  ((2 * (N + 1) * 2 ^ n : ℕ) : ℤ) := by
                push_cast; ring
              rw [hdiff, Int.toNat_natCast]
            calc μ (badEvent Y (N + 1) n)
                ≤ ∑ k ∈ Finset.Ico (-(((N + 1 : ℕ) : ℤ)) * (2 : ℤ) ^ n)
                    (((N + 1 : ℕ) : ℤ) * (2 : ℤ) ^ n),
                    μ {ω | (7 / 8 : ℝ) ^ n <
                      |Y (((k : ℝ) + 1) / (2 : ℝ) ^ n) ω - Y ((k : ℝ) / (2 : ℝ) ^ n) ω|} :=
                  measure_biUnion_finset_le _ _
              _ ≤ ∑ _k ∈ Finset.Ico (-(((N + 1 : ℕ) : ℤ)) * (2 : ℤ) ^ n)
                    (((N + 1 : ℕ) : ℤ) * (2 : ℤ) ^ n),
                    ENNReal.ofReal (3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n) :=
                  Finset.sum_le_sum fun k _ => hbound_k k
              _ = (2 * (N + 1) * 2 ^ n : ℕ) *
                    ENNReal.ofReal (3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n) := by
                  rw [Finset.sum_const, nsmul_eq_mul, hcard]
              _ = ENNReal.ofReal (((2 * (N + 1) * 2 ^ n : ℕ) : ℝ) *
                    (3 * L ^ 2 * (1024 / 2401 : ℝ) ^ n)) := by
                  rw [← ENNReal.ofReal_natCast, ← ENNReal.ofReal_mul (by positivity)]
              _ = ENNReal.ofReal (C * (2048 / 2401 : ℝ) ^ n) := by
                  congr 1
                  push_cast [C]
                  rw [show (2048 / 2401 : ℝ) ^ n = (2 : ℝ) ^ n * (1024 / 2401 : ℝ) ^ n by
                    rw [← mul_pow]; norm_num]
                  ring
              _ = ENNReal.ofReal C * (ENNReal.ofReal (2048 / 2401 : ℝ)) ^ n := by
                  rw [ENNReal.ofReal_mul hC, ENNReal.ofReal_pow (by norm_num)]
          have htsum_le : ∑' n : ℕ, μ (badEvent Y (N + 1) n) ≤
              ENNReal.ofReal C * ∑' n : ℕ, (ENNReal.ofReal (2048 / 2401 : ℝ)) ^ n := by
            rw [← ENNReal.tsum_mul_left]
            exact tsum_le_tsum hterm
          have hlt : ENNReal.ofReal (2048 / 2401 : ℝ) < 1 := by
            rw [← ENNReal.ofReal_one]
            exact (ENNReal.ofReal_lt_ofReal_iff zero_lt_one).mpr (by norm_num)
          have hfin : ∑' n : ℕ, (ENNReal.ofReal (2048 / 2401 : ℝ)) ^ n ≠ ∞ := by
            rw [ENNReal.tsum_geometric]
            exact ENNReal.inv_ne_top.mpr (tsub_pos_of_lt hlt).ne'
          exact ne_top_of_le_ne_top (ENNReal.mul_ne_top ENNReal.ofReal_ne_top hfin) htsum_le
        have hae := ae_eventually_notMem hsum
        filter_upwards [hae] with ω hω
        rw [Filter.eventually_atTop] at hω
        obtain ⟨M, hM⟩ := hω
        simp only [goodOn, mem_iUnion, mem_iInter, mem_compl_iff]
        exact ⟨M, fun n hn => hM n hn⟩
      filter_upwards [ae_all_iff.mpr hgoodN] with ω hω
      exact mem_iInter.mpr hω
    -- Step 2: For fixed `z`, `Y (dyadicApprox n z) → Y z` a.s. via 2nd-moment Borel–Cantelli
    intro z
    let errSet : ℕ → Set Ω := fun n => {ω | (3 / 4 : ℝ) ^ n < |Y (dyadicApprox n z) ω - Y z ω|}
    have herr_sum : ∑' n : ℕ, μ (errSet n) ≠ ∞ := by
      have hterm : ∀ n : ℕ, μ (errSet n) ≤
          ENNReal.ofReal L * (ENNReal.ofReal (8 / 9 : ℝ)) ^ n := by
        intro n
        set Z : Ω → ℝ := fun ω => Y (dyadicApprox n z) ω - Y z ω
        have hZ2 : Integrable (fun ω => |Z ω| ^ 2) μ := by
          have := (hgauss (dyadicApprox n z) z).memLp_two.integrable_sq
          simpa [sq_abs] using this
        have hmark := measure_abs_gt_le_of_pow ((hmeas _).sub (hmeas _))
          hZ2 (by positivity : (0 : ℝ) < (3 / 4 : ℝ) ^ n)
        have hint_le : ∫ ω, |Z ω| ^ 2 ∂μ ≤ L * (1 / 2 : ℝ) ^ n := by
          simp_rw [sq_abs]
          calc ∫ ω, Z ω ^ 2 ∂μ
              ≤ L * |dyadicApprox n z - z| := hvar (dyadicApprox n z) z
            _ ≤ L * (1 / 2 : ℝ) ^ n := mul_le_mul_of_nonneg_left (abs_dyadicApprox_sub_le n z) hL
        have hdiv : (∫ ω, |Z ω| ^ 2 ∂μ) / ((3 / 4 : ℝ) ^ n) ^ 2 ≤ L * (8 / 9 : ℝ) ^ n := by
          have hden : (0 : ℝ) < ((3 / 4 : ℝ) ^ n) ^ 2 := by positivity
          rw [div_le_iff₀ hden]
          calc ∫ ω, |Z ω| ^ 2 ∂μ
              ≤ L * (1 / 2 : ℝ) ^ n := hint_le
            _ = L * (8 / 9 : ℝ) ^ n * ((3 / 4 : ℝ) ^ n) ^ 2 := by
                rw [mul_assoc L, ← pow_mul, mul_comm n 2, pow_mul, ← mul_pow]; norm_num
        calc μ (errSet n)
            ≤ ENNReal.ofReal ((∫ ω, |Z ω| ^ 2 ∂μ) / ((3 / 4 : ℝ) ^ n) ^ 2) := hmark
          _ ≤ ENNReal.ofReal (L * (8 / 9 : ℝ) ^ n) := ENNReal.ofReal_le_ofReal hdiv
          _ = ENNReal.ofReal L * (ENNReal.ofReal (8 / 9 : ℝ)) ^ n := by
              rw [ENNReal.ofReal_mul hL, ENNReal.ofReal_pow (by norm_num)]
      have htsum_le : ∑' n : ℕ, μ (errSet n) ≤
          ENNReal.ofReal L * ∑' n : ℕ, (ENNReal.ofReal (8 / 9 : ℝ)) ^ n := by
        rw [← ENNReal.tsum_mul_left]
        exact tsum_le_tsum hterm
      have hlt : ENNReal.ofReal (8 / 9 : ℝ) < 1 := by
        rw [← ENNReal.ofReal_one]
        exact (ENNReal.ofReal_lt_ofReal_iff zero_lt_one).mpr (by norm_num)
      have hfin : ∑' n : ℕ, (ENNReal.ofReal (8 / 9 : ℝ)) ^ n ≠ ∞ := by
        rw [ENNReal.tsum_geometric]
        exact ENNReal.inv_ne_top.mpr (tsub_pos_of_lt hlt).ne'
      exact ne_top_of_le_ne_top (ENNReal.mul_ne_top ENNReal.ofReal_ne_top hfin) htsum_le
    have hae_conv := ae_eventually_notMem herr_sum
    filter_upwards [hgood, hae_conv] with ω hωg hωe
    have htend : Tendsto (fun n : ℕ => Y (dyadicApprox n z) ω) atTop (𝓝 (Y z ω)) := by
      rw [Metric.tendsto_atTop]
      intro ε hε
      have h34 : Tendsto (fun n : ℕ => (3 / 4 : ℝ) ^ n) atTop (𝓝 0) :=
        tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
      obtain ⟨N₁, hN₁⟩ := Metric.tendsto_atTop.mp h34 ε hε
      obtain ⟨N₂, hN₂⟩ := Filter.eventually_atTop.mp hωe
      refine ⟨max N₁ N₂, fun n hn => ?_⟩
      have hle : |Y (dyadicApprox n z) ω - Y z ω| ≤ (3 / 4 : ℝ) ^ n := by
        have := hN₂ n (le_trans (le_max_right N₁ N₂) hn)
        simpa [errSet] using this
      have hlt : (3 / 4 : ℝ) ^ n < ε := by
        have := hN₁ n (le_trans (le_max_left N₁ N₂) hn)
        rw [Real.dist_eq, sub_zero, abs_of_nonneg (by positivity)] at this
        exact this
      rw [Real.dist_eq]
      linarith
    simp only [dyadicMod, hωg, ↓reduceIte]
    exact htend.limUnder_eq

end DyadicKC

/-! ## 5. Existence of `CanonicalField` (`C17.b`, `C18`, `C19`) -/

/-- Separable space-time canonical covariance kernel
`K((z, t), (z', s)) = σ² e^{−|z − z'| / ℓ_s} e^{−|t − s| / T}`. -/
def canonKernel (σ ℓs T : ℝ) (p q : ℝ × ℝ) : ℝ :=
  σ ^ 2 * expKernel ℓs p.1 q.1 * expKernel T p.2 q.2

lemma posSemidef_canonKernel (σ : ℝ) {ℓs T : ℝ} (hℓs : 0 < ℓs) (hT : 0 < T)
    (I : Finset (ℝ × ℝ)) :
    (kernelCovMatrix (canonKernel σ ℓs T) I).PosSemidef := by
  have h1 : (Matrix.of fun i j : I => expKernel ℓs i.1.1 j.1.1).PosSemidef :=
    posSemidef_expKernel hℓs (fun i : I => i.1.1)
  have h2 : (Matrix.of fun i j : I => expKernel T i.1.2 j.1.2).PosSemidef :=
    posSemidef_expKernel hT (fun i : I => i.1.2)
  have h12 : (Matrix.of fun i j : I => expKernel ℓs i.1.1 j.1.1 * expKernel T i.1.2 j.1.2).PosSemidef :=
    posSemidef_mul_kernel h1 h2
  have hsmul : ((σ ^ 2 : ℝ) • Matrix.of fun i j : I =>
      expKernel ℓs i.1.1 j.1.1 * expKernel T i.1.2 j.1.2).PosSemidef :=
    h12.smul (sq_nonneg σ)
  convert hsmul using 1
  ext i j
  simp [kernelCovMatrix, canonKernel, mul_assoc]

/-- Non-vacuity witness for `CanonicalField` (`C17.b`, `C18`, `C19`): for every
`σ ≠ 0`, `ℓ_s > 0`, and `T > 0`, there exists a probability space `(Ω, μ)` and a
centered jointly Gaussian space-time field `θ : ℝ → ℝ → Ω → ℝ` with separable
exponential covariance `σ² e^{−|z−z'|/ℓ_s} e^{−|t−s|/T}`, measurable point
evaluations, and everywhere spatially continuous sample paths `z ↦ θ(z, t, ω)`. -/
theorem exists_canonicalField {σ ℓs T : ℝ} (_hσ : σ ≠ 0) (hℓs : 0 < ℓs) (hT : 0 < T) :
    ∃ (Ω : Type) (_ : MeasurableSpace Ω) (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (θ : ℝ → ℝ → Ω → ℝ), CanonicalField μ θ σ ℓs T := by
  let μ : Measure ((ℝ × ℝ) → ℝ) :=
    kernelMeasure (canonKernel σ ℓs T) (posSemidef_canonKernel σ hℓs hT)
  have hG : IsGaussianProcess (fun (p : ℝ × ℝ) (ω : (ℝ × ℝ) → ℝ) => ω p) μ :=
    isGaussianProcess_kernelMeasure (posSemidef_canonKernel σ hℓs hT)
  have hmean0 : ∀ z t, ∫ ω, ω (z, t) ∂μ = 0 := fun z t =>
    integral_coord_kernelMeasure (posSemidef_canonKernel σ hℓs hT) (z, t)
  have hcov0 : ∀ z z' t s, ∫ ω, ω (z, t) * ω (z', s) ∂μ =
      σ ^ 2 * Real.exp (-|z - z'| / ℓs) * Real.exp (-|t - s| / T) := fun z z' t s =>
    integral_mul_coord_kernelMeasure (posSemidef_canonKernel σ hℓs hT) (z, t) (z', s)
  have hmod_exists : ∀ t : ℝ, ∃ Y' : ℝ → ((ℝ × ℝ) → ℝ) → ℝ,
      (∀ z, Measurable (Y' z)) ∧
      (∀ ω, Continuous (fun z => Y' z ω)) ∧
      (∀ z, Y' z =ᵐ[μ] fun ω => ω (z, t)) := by
    intro t
    refine exists_continuous_modification_1d (μ := μ) (fun z ω => ω (z, t))
      (2 * σ ^ 2 / ℓs) (by positivity)
      (fun z => measurable_pi_apply (z, t))
      (fun z z' => hG.hasGaussianLaw_fun_sub (s := (z, t)) (t := (z', t)))
      (fun z z' => by
        rw [integral_sub (hG.hasGaussianLaw_eval (z, t)).integrable
          (hG.hasGaussianLaw_eval (z', t)).integrable, hmean0, hmean0, sub_self])
      (fun z z' => ?_)
    have h1 : MemLp (fun ω : (ℝ × ℝ) → ℝ => ω (z, t)) 2 μ :=
      (hG.hasGaussianLaw_eval (z, t)).memLp_two
    have h2 : MemLp (fun ω : (ℝ × ℝ) → ℝ => ω (z', t)) 2 μ :=
      (hG.hasGaussianLaw_eval (z', t)).memLp_two
    have hexpand : ∀ ω : (ℝ × ℝ) → ℝ,
        (ω (z, t) - ω (z', t)) ^ 2 =
          ω (z, t) * ω (z, t) - 2 * (ω (z, t) * ω (z', t)) + ω (z', t) * ω (z', t) := fun ω => by
      ring
    simp_rw [hexpand]
    have i11 : Integrable (fun ω : (ℝ × ℝ) → ℝ => ω (z, t) * ω (z, t)) μ := h1.integrable_mul h1
    have i12 : Integrable (fun ω : (ℝ × ℝ) → ℝ => ω (z, t) * ω (z', t)) μ := h1.integrable_mul h2
    have i22 : Integrable (fun ω : (ℝ × ℝ) → ℝ => ω (z', t) * ω (z', t)) μ := h2.integrable_mul h2
    have isub : Integrable (fun ω : (ℝ × ℝ) → ℝ =>
        ω (z, t) * ω (z, t) - 2 * (ω (z, t) * ω (z', t))) μ :=
      i11.sub (i12.const_mul 2)
    rw [integral_add isub i22, integral_sub i11 (i12.const_mul 2),
      integral_const_mul, hcov0 z z t t, hcov0 z z' t t, hcov0 z' z' t t]
    simp only [sub_self, abs_zero, neg_zero, zero_div, Real.exp_zero, mul_one]
    have hexp_bound : 1 - Real.exp (-|z - z'| / ℓs) ≤ |z - z'| / ℓs := by
      have := Real.add_one_le_exp (-(|z - z'| / ℓs))
      rw [neg_div]
      linarith
    have hsq_nn : 0 ≤ 2 * σ ^ 2 := by positivity
    calc σ ^ 2 - 2 * (σ ^ 2 * Real.exp (-|z - z'| / ℓs)) + σ ^ 2
        = 2 * σ ^ 2 * (1 - Real.exp (-|z - z'| / ℓs)) := by ring
      _ ≤ 2 * σ ^ 2 * (|z - z'| / ℓs) := mul_le_mul_of_nonneg_left hexp_bound hsq_nn
      _ = 2 * σ ^ 2 / ℓs * |z - z'| := by ring
  let θ : ℝ → ℝ → ((ℝ × ℝ) → ℝ) → ℝ := fun z t ω => Classical.choose (hmod_exists t) z ω
  have hθ_meas : ∀ z t, Measurable (θ z t) := fun z t =>
    (Classical.choose_spec (hmod_exists t)).1 z
  have hθ_cont : ∀ t ω, Continuous (fun z => θ z t ω) := fun t ω =>
    (Classical.choose_spec (hmod_exists t)).2.1 ω
  have hθ_ae : ∀ z t, θ z t =ᵐ[μ] fun ω => ω (z, t) := fun z t =>
    (Classical.choose_spec (hmod_exists t)).2.2 z
  refine ⟨(ℝ × ℝ) → ℝ, inferInstance, μ, inferInstance, θ, ?_⟩
  exact
    { ℓs_pos := hℓs
      T_pos := hT
      gaussian := hG.congr fun p => (hθ_ae p.1 p.2).symm
      mean := fun z t => (integral_congr_ae (hθ_ae z t)).trans (hmean0 z t)
      cov := fun z z' t s =>
        (integral_congr_ae ((hθ_ae z t).mul (hθ_ae z' s))).trans (hcov0 z z' t s)
      measurable := hθ_meas
      continuous := hθ_cont }

/-- Concrete parameter witness for the full canonical-model theorems (`C17.b`,
`C18`, `C19`) in the positive interior-radius regime (`σ = 1`, `ℓ_s = 1`,
`T = 4`, `ℓ_c = 1`, `q = 1`, `v = 1`, so `2 ℓ_s < v T` and `r⋆ > 0`). -/
theorem exists_canonicalField_interior_regime :
    ∃ (Ω : Type) (_ : MeasurableSpace Ω) (μ : Measure Ω) (_ : IsProbabilityMeasure μ)
      (θ : ℝ → ℝ → Ω → ℝ) (σ ℓs T ℓc q v : ℝ),
      CanonicalField μ θ σ ℓs T ∧
      σ ≠ 0 ∧ 0 < ℓc ∧ 0 < q ∧ 0 < v ∧
      2 * ℓs < v * T ∧ 0 < canonRadius ℓc ℓs v T := by
  obtain ⟨Ω, mΩ, μ, hμ, θ, hCF⟩ :=
    exists_canonicalField (σ := 1) (ℓs := 1) (T := 4) (by norm_num) (by norm_num) (by norm_num)
  refine ⟨Ω, mΩ, μ, hμ, θ, 1, 1, 4, 1, 1, 1, hCF, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, ?_⟩
  exact (TinaV2.Assembly.C19 μ θ 1 1 4 1 1 1 hCF (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) 0 0).2.mpr (by norm_num)

end TinaV2.NonVacuity.GaussianModels
