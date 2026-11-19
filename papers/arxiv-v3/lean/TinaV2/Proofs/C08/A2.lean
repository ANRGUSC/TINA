import TinaV2.Statements
import TinaV2.Routine.Regret
import TinaV2.Proofs.C07.A1

/-! # C8, attempt A2: mirrors paper proof C8/p2

Paper: `main-v3.tex`, proof of Corollary (OU_stale_regret), lines 463-466
(rewritten in arXiv v3, upstream `12a9b32`, finding F5). The corollary is no
longer read off the composition law. It is proved directly from two equations
inside the proof of the composition theorem: Eq. (innovation_split), step 3 of
C7/p1, and Eq. (innovation_energy), step 4 of C7/p1.

This file therefore imports `TinaV2.Proofs.C07.A1` and uses its lemmas
`s3_error_split` and `s4_disturbance_energy`. It is the one declared exception
to "a proof file never imports another claim's proof": the two steps are
listed in `step_deps` of `C8/p2/s2`, and `ledger.py check` and `audit` allow
exactly those. `main` takes no hypothesis.

The complete old state is radius `⊤`: every agent sees every coordinate of
`θ_{t−τ}` (reading C8/f1/d1). The two steps also state the former remark C8.b,
"the optimal global action is `aKθ_{t−τ}`": step 1 says the action is
admissible, step 2 that its cost is `R_glob`. -/

namespace TinaV2.C08.A2

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (main-v3.tex 463-464). "With the complete old state, each agent can
take its component of `u = aKθ_{t−τ}`": there is an admissible rule of the
complete (radius `⊤`) views of the old snapshot whose joint action is
`a K θ_{t−τ}`. -/
theorem s1_action_feasible (M : Model ι κ α) (μ : Measure Ω) (a : ℝ) {old : Ω → κ → ℝ}
    (hold : MemLp old 2 μ) :
    ∃ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ,
      Admissible μ (M.obs ⊤ old) g ∧
      ∀ ω, jointAction g (M.obs ⊤ old) ω = a • M.target old ω := by
  let g : Rule M.actor fun i => M.Scope ⊤ i → ℝ :=
    fun c o => a * ∑ k, M.K c k * o ⟨k, (le_top : M.G.edist (M.actor c) (M.owner k) ≤ ⊤)⟩
  have hu : jointAction g (M.obs ⊤ old) = fun ω => a • M.target old ω := by
    funext ω c
    simp [g, jointAction, Model.obs, Model.view, Model.target, mulVec, dotProduct]
  refine ⟨g, ⟨fun c => ?_, ?_⟩, fun ω => congrFun hu ω⟩
  · have hsum : Measurable fun o : M.Scope ⊤ (M.actor c) → ℝ =>
        ∑ k, M.K c k * o ⟨k, (le_top : M.G.edist (M.actor c) (M.owner k) ≤ ⊤)⟩ :=
      Finset.measurable_sum _ fun k _ => (measurable_pi_apply _).const_mul _
    exact hsum.const_mul a
  · rw [hu]
    exact (M.memLp_target hold).const_smul a

/-- Step 2 (main-v3.tex 464-466). "This makes the first term in
Eq. (innovation_split) zero, its minimum, so the regret is half the innovation
energy in Eq. (innovation_energy)." For a rule with action `aKθ_{t−τ}` the
first term of the split is zero and its cost is `R_glob`; and
`R_glob(τ) = (1 − e^{−2τ/T}) R_∞`. -/
theorem s2_half_innovation_energy (M : Model ι κ α) (μ : Measure Ω) [IsProbabilityMeasure μ]
    (θ : ℝ → Ω → κ → ℝ) (T t τ : ℝ) (hA : TemporalAssumption μ θ T t τ) :
    (∀ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ, Admissible μ (M.obs ⊤ (θ (t - τ))) g →
      (∀ ω, jointAction g (M.obs ⊤ (θ (t - τ))) ω = exp (-τ / T) • M.target (θ (t - τ)) ω) →
      ∫ ω, quad M.Q (exp (-τ / T) • M.target (θ (t - τ)) ω
          - jointAction g (M.obs ⊤ (θ (t - τ))) ω) ∂μ = 0 ∧
        excessCost μ M.Q (M.target (θ t)) (jointAction g (M.obs ⊤ (θ (t - τ))))
          = M.Rglob μ (θ (t - τ)) (θ t)) ∧
      M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t) := by
  have hmeas := hA.stationary.measurable (t - τ)
  have hold := hA.stationary.memLp (t - τ)
  have hnow := hA.stationary.memLp t
  have hpred := hA.prediction
  have hid := hA.stationary.identDistrib (t - τ) t
  have hsq : exp (-τ / T) ^ 2 = exp (-2 * τ / T) := by
    rw [← exp_nat_mul]
    congr 1
    push_cast
    ring
  -- Eq. (innovation_split) and Eq. (innovation_energy), halved: the cost of an
  -- admissible rule is half its first term plus half the innovation energy
  have hsplit : ∀ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ,
      Admissible μ (M.obs ⊤ (θ (t - τ))) g →
      excessCost μ M.Q (M.target (θ t)) (jointAction g (M.obs ⊤ (θ (t - τ))))
        = 1 / 2 * ∫ ω, quad M.Q (exp (-τ / T) • M.target (θ (t - τ)) ω
            - jointAction g (M.obs ⊤ (θ (t - τ))) ω) ∂μ
          + (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t) := by
    intro g hg
    have h3 := C07.A1.s3_error_split M μ (exp (-τ / T)) ⊤ hmeas hold hnow hpred hg
    have h4 := (C07.A1.s4_disturbance_energy M μ (exp (-τ / T)) hmeas hold hnow hpred hid).2
    rw [hsq] at h4
    unfold excessCost
    simp_rw [quad_sub_comm M.Q (jointAction g (M.obs ⊤ (θ (t - τ))) _) (M.target (θ t) _)]
    linarith
  -- the first term is zero for the action of step 1 ...
  have hzero : ∀ g : Rule M.actor fun i => M.Scope ⊤ i → ℝ,
      (∀ ω, jointAction g (M.obs ⊤ (θ (t - τ))) ω = exp (-τ / T) • M.target (θ (t - τ)) ω) →
      ∫ ω, quad M.Q (exp (-τ / T) • M.target (θ (t - τ)) ω
          - jointAction g (M.obs ⊤ (θ (t - τ))) ω) ∂μ = 0 := by
    intro g hu
    simp [hu, quad]
  -- ... and zero is its minimum, so the regret is half the innovation energy
  have hval : M.Rglob μ (θ (t - τ)) (θ t) = (1 - exp (-2 * τ / T)) * M.Rinf μ (θ t) := by
    obtain ⟨g, hg, hu⟩ := s1_action_feasible M μ (exp (-τ / T)) hold
    apply le_antisymm
    · have hle := regret_le μ M.Q_posDef (M.target (θ t)) (M.obs ⊤ (θ (t - τ))) hg
      rw [hsplit g hg, hzero g hu] at hle
      simpa [Model.Rglob, Model.R] using hle
    · refine le_ciInf fun g => ?_
      rw [hsplit g.1 g.2]
      have hnn : 0 ≤ ∫ ω, quad M.Q (exp (-τ / T) • M.target (θ (t - τ)) ω
          - jointAction g.1 (M.obs ⊤ (θ (t - τ))) ω) ∂μ :=
        integral_nonneg fun ω => quad_nonneg M.Q_posDef _
      linarith
  refine ⟨fun g hg hu => ⟨hzero g hu, ?_⟩, hval⟩
  rw [hsplit g hg, hzero g hu, hval]
  ring

/-- Corollary (OU_stale_regret), Eq. (OU_exact_regret). -/
theorem main : C08.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ T t τ hA
  exact (s2_half_innovation_energy M μ θ T t τ hA).2

end TinaV2.C08.A2
