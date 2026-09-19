import LCSS.PaperModel
import LCSS.Posterior
import LCSS.Objective
import LCSS.Endpoints

/-! Theorem 1 of the L-CSS letter. The four J values below are infima of
the actual expected loss over all information-measurable L² policies. -/
set_option autoImplicit false

namespace LCSS
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped InnerProductSpace ENNReal BigOperators RealInnerProductSpace ProbabilityTheory
variable {Ω : Type*} [mΩ : MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {n : ℕ}

def optimalExpectedLoss (κ : ℝ) (X : RV (μ := μ)) (G : Fin n → MeasurableSpace Ω) : ℝ :=
  ⨅ u : {u : Fin n → RV (μ := μ) // ∀ i, u i ∈ informationSpace (μ := μ) (G i)},
    expectedLoss κ X u.val

theorem expectedLoss_eq_optimalExpectedLoss (κ : ℝ) (X : RV (μ := μ))
    (G : Fin n → MeasurableSpace Ω) (u : Fin n → RV (μ := μ))
    (hu : ∀ i, u i ∈ informationSpace (μ := μ) (G i))
    (hmin : ∀ v, (∀ i, v i ∈ informationSpace (μ := μ) (G i)) →
      teamCost κ X u ≤ teamCost κ X v) :
    expectedLoss κ X u = optimalExpectedLoss κ X G := by
  let A := {v : Fin n → RV (μ := μ) // ∀ i, v i ∈ informationSpace (μ := μ) (G i)}
  letI : Nonempty A := ⟨⟨u,hu⟩⟩
  have hl (v : A) : expectedLoss κ X u ≤ expectedLoss κ X v.val := by
    rw [expectedLoss_eq_teamCost, expectedLoss_eq_teamCost]
    exact hmin v.val v.property
  have hb : BddBelow (Set.range (fun v : A => expectedLoss κ X v.val)) := by
    refine ⟨expectedLoss κ X u, ?_⟩
    rintro _ ⟨v,rfl⟩
    exact hl v
  exact le_antisymm (le_ciInf hl) (ciInf_le hb (⟨u,hu⟩ : A))

namespace SensorModel
variable {p : Parameters} (M : SensorModel (μ := μ) p)

def JL (t : ℝ) := optimalExpectedLoss p.κ (M.X t) (M.localInfo t)
def JP (t : ℝ) := optimalExpectedLoss p.κ (M.X t) (M.fullInfo t t)
def JH (t τ : ℝ) := optimalExpectedLoss p.κ (M.X t) (M.hybridInfo (t-τ) t)
def JFull (t τ : ℝ) := optimalExpectedLoss p.κ (M.X t) (M.fullInfo (t-τ) t)

theorem JL_eq (t : ℝ) : M.JL t = p.localCost := by
  rw [JL, ← expectedLoss_eq_optimalExpectedLoss _ _ _ _ (M.local_feasible t) (M.local_minimal t),
    expectedLoss_eq_teamCost, M.local_cost]
theorem JP_eq (t : ℝ) : M.JP t = p.pooledCost := by
  rw [JP, ← expectedLoss_eq_optimalExpectedLoss _ _ _ _ (M.hybrid_feasible_full le_rfl)
    (M.hybrid_minimal_full le_rfl), expectedLoss_eq_teamCost, M.pooled_cost]
theorem JH_eq (t τ : ℝ) (hτ : 0 ≤ τ) : M.JH t τ = p.hybridCost τ := by
  rw [JH, ← expectedLoss_eq_optimalExpectedLoss _ _ _ _
    (M.hybrid_feasible_hybrid (by linarith)) (M.hybrid_minimal_hybrid (by linarith)),
    expectedLoss_eq_teamCost, M.hybrid_cost_age t τ hτ]
theorem JFull_eq (t τ : ℝ) (hτ : 0 ≤ τ) : M.JFull t τ = p.hybridCost τ := by
  rw [JFull, ← expectedLoss_eq_optimalExpectedLoss _ _ _ _
    (M.hybrid_feasible_full (by linarith)) (M.hybrid_minimal_full (by linarith)),
    expectedLoss_eq_teamCost, M.hybrid_cost_age t τ hτ]

end SensorModel

/-- Every assertion in the letter's Theorem 1, including attainment,
full-history optimality, conditional variance, and actual optimized values. -/
structure Theorem1Claims {p : Parameters} (M : SensorModel (μ := μ) p) (t τ : ℝ) : Prop where
  policy_formula : ∀ i, M.hybrid (t-τ) t i =
    (p.rho τ * (p.a/p.v)) • M.pool (t-τ) +
      (p.a/p.d) • (M.Y t i - p.rho τ • M.Y (t-τ) i)
  feasible_hybrid : ∀ i, M.hybrid (t-τ) t i ∈ informationSpace (μ := μ) (M.hybridInfo (t-τ) t i)
  feasible_full : ∀ i, M.hybrid (t-τ) t i ∈ informationSpace (μ := μ) (M.fullInfo (t-τ) t i)
  attains_hybrid : expectedLoss p.κ (M.X t) (M.hybrid (t-τ) t) = M.JH t τ
  attains_full : expectedLoss p.κ (M.X t) (M.hybrid (t-τ) t) = M.JFull t τ
  posterior_variance : ∀ i, Var[(M.X t : Ω → ℝ); μ | M.hybridInfo (t-τ) t i] =ᵐ[μ]
    (fun _ => p.rho τ ^ 2 * p.pooledVariance + (1-p.rho τ ^ 2) * p.localVariance)
  team_cost : M.JH t τ = p.rho τ ^ 2 * M.JP t + (1-p.rho τ ^ 2) * M.JL t
  full_sharing_same_value : M.JFull t τ = M.JH t τ
  exponential_value : M.JL t - M.JH t τ = (M.JL t - M.JP t) * Real.exp (-2*p.rate*τ)

theorem sensorModel_theorem1 {p : Parameters} (M : SensorModel (μ := μ) p)
    (t τ : ℝ) (hτ : 0 ≤ τ) : Theorem1Claims M t τ := by
  have hst : t-τ ≤ t := by linarith
  constructor
  · intro i
    simp only [SensorModel.hybrid, SensorModel.prediction, SensorModel.innovation,
      SensorModel.kernel_age t τ hτ]
  · exact M.hybrid_feasible_hybrid hst
  · exact M.hybrid_feasible_full hst
  · rw [expectedLoss_eq_teamCost, M.hybrid_cost_age t τ hτ, M.JH_eq t τ hτ]
  · rw [expectedLoss_eq_teamCost, M.hybrid_cost_age t τ hτ, M.JFull_eq t τ hτ]
  · intro i
    exact M.posterior_condVar_age t τ hτ i
  · rw [M.JH_eq t τ hτ, M.JP_eq, M.JL_eq]
    rfl
  · rw [M.JFull_eq t τ hτ, M.JH_eq t τ hτ]
  · rw [M.JL_eq, M.JH_eq t τ hτ, M.JP_eq]
    exact p.exponential_value τ

/-- Main entry point: only the paper's primitive independent Gaussian
signal/error model is supplied. Sensor Gaussianity, sensor covariances,
history independence, and normal equations are all proved internally. -/
theorem theorem1 {p : Parameters} (D : PaperModel (μ := μ) p)
    (t τ : ℝ) (hτ : 0 ≤ τ) : Theorem1Claims D.toSensorModel t τ :=
  sensorModel_theorem1 D.toSensorModel t τ hτ

end
end LCSS
