import LCSS.Components
import Mathlib.Probability.Independence.Process.Basic

/-! Probability-preserving pullbacks for Gaussian and independent families. -/
set_option autoImplicit false
namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
variable {Ω Γ : Type*} [MeasurableSpace Ω] [MeasurableSpace Γ]
variable {μ : Measure Ω} {ν : Measure Γ} {X : Ω → Γ}

theorem map_pullback {F : Type*} [MeasurableSpace F] (hX : MeasurePreserving X μ ν)
    (g : Γ → F) (hg : Measurable g) : μ.map (g ∘ X) = ν.map g := by
  rw [← Measure.map_map hg hX.measurable, hX.map_eq]

theorem gaussian_process_pullback {T : Type*} {f : T → Γ → ℝ}
    (hX : MeasurePreserving X μ ν) (hf : ∀ t, Measurable (f t))
    (hg : IsGaussianProcess f ν) : IsGaussianProcess (fun t ω => f t (X ω)) μ := by
  constructor
  intro I
  have he : μ.map (fun ω (t : I) => f t (X ω)) = ν.map (fun y (t : I) => f t y) := by
    change μ.map ((fun y (t : I) => f t y) ∘ X) = _
    exact map_pullback hX _ (measurable_pi_lambda _ (fun (t : I) => hf t))
  constructor
  change IsGaussian (μ.map (fun ω (t : I) => f t (X ω)))
  rw [he]
  exact (hg.hasGaussianLaw I).isGaussian_map

theorem independent_pullback [IsProbabilityMeasure μ] {J : Type*} [Fintype J] {E : J → Type*}
    [∀ j, MeasurableSpace (E j)] {f : (j : J) → Γ → E j}
    (hX : MeasurePreserving X μ ν) (hf : ∀ j, Measurable (f j))
    (hi : iIndepFun f ν) : iIndepFun (fun j ω => f j (X ω)) μ := by
  apply (iIndepFun_iff_map_fun_eq_pi_map (fun j => ((hf j).comp hX.measurable).aemeasurable)).mpr
  change μ.map ((fun y j => f j y) ∘ X) = _
  rw [map_pullback hX _ (measurable_pi_lambda _ hf), hi.map_fun_eq_pi_map (fun j => (hf j).aemeasurable)]
  congr 1
  funext j
  exact (map_pullback hX (f j) (hf j)).symm

end
end LCSS
