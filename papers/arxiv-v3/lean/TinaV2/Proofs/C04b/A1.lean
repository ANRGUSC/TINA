import TinaV2.Statements

/-! # C4.b, attempt A1: mirrors paper proof C4.b/p1

Paper: `technical-appendices-v3.tex`, Section "Temporal special cases", lines
316-320 (added in arXiv v3, upstream `12a9b32`). The composition theorem C7
enters as the hypothesis `hC7 : C07.Statement`. -/

namespace TinaV2.C04b.A1

open MeasureTheory ProbabilityTheory Matrix Real Set

variable {ι κ α Ω : Type} [Fintype ι] [Fintype κ] [Fintype α] [MeasurableSpace Ω]

/-- Step 1 (appendix 316-320). "Iterating the recursion over `k` steps and
conditioning on `θ_{t−k}` gives `E[θ_t | θ_{t−k}] = c^k θ_{t−k}`, since each
intervening innovation has conditional mean zero given `θ_{t−k}` by the tower
property." -/
theorem s1_iterate_tower (μ : Measure Ω) [IsProbabilityMeasure μ] (θ ε : ℤ → Ω → κ → ℝ)
    (c : ℝ) (hθ : StationaryState μ θ) (hε : ∀ s, MemLp (ε s) 2 μ)
    (hrec : ∀ s ω, θ (s + 1) ω = c • θ s ω + ε (s + 1) ω)
    (hcond : ∀ s, μ[ε (s + 1) |
      ⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (θ u) MeasurableSpace.pi] =ᵐ[μ] 0)
    (t : ℤ) (k : ℕ) :
    PredictionRule μ (c ^ k) (θ (t - k)) (θ t) := by
  -- iterating the recursion: `θ_t − c^k θ_{t−k} = Σ_{j<k} c^j ε_{t−j}`
  have hiter : ∀ k : ℕ, ∀ ω,
      θ t ω - c ^ k • θ (t - k) ω = ∑ j ∈ Finset.range k, c ^ j • ε (t - j) ω := by
    intro k
    induction k with
    | zero => intro ω; simp
    | succ k ih =>
      intro ω
      rw [Finset.sum_range_succ, ← ih ω]
      have h := hrec (t - ((k + 1 : ℕ) : ℤ)) ω
      have e : t - ((k + 1 : ℕ) : ℤ) + 1 = t - (k : ℤ) := by push_cast; ring
      rw [e] at h
      rw [h]
      module
  have hint : ∀ s, Integrable (ε s) μ := fun s => (hε s).integrable one_le_two
  -- each intervening innovation has conditional mean zero given `θ_{t−k}`
  have h0 : ∀ j ∈ Finset.range k,
      μ[ε (t - j) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi] =ᵐ[μ] 0 := by
    intro j hj
    have hjk : j < k := Finset.mem_range.1 hj
    have hmF : MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi
        ≤ ⨆ u : {u : ℤ // u ≤ t - j - 1}, MeasurableSpace.comap (θ u) MeasurableSpace.pi :=
      le_iSup (fun u : {u : ℤ // u ≤ t - j - 1} =>
        MeasurableSpace.comap (θ u) MeasurableSpace.pi) ⟨t - k, by omega⟩
    have hF : (⨆ u : {u : ℤ // u ≤ t - j - 1}, MeasurableSpace.comap (θ u) MeasurableSpace.pi)
        ≤ ‹MeasurableSpace Ω› := iSup_le fun u => (hθ.measurable u).comap_le
    have hc := hcond (t - j - 1)
    rw [show t - (j : ℤ) - 1 + 1 = t - j by ring] at hc
    calc μ[ε (t - j) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi]
        =ᵐ[μ] μ[μ[ε (t - j) | ⨆ u : {u : ℤ // u ≤ t - j - 1},
            MeasurableSpace.comap (θ u) MeasurableSpace.pi] |
            MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi] :=
          (condExp_condExp_of_le hmF hF).symm
      _ =ᵐ[μ] μ[(0 : Ω → κ → ℝ) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi] :=
          condExp_congr_ae hc
      _ = 0 := condExp_zero
  unfold PredictionRule
  have hfun : (fun ω => θ t ω - c ^ k • θ (t - k) ω)
      = ∑ j ∈ Finset.range k, c ^ j • ε (t - j) := by
    funext ω
    rw [hiter k ω, Finset.sum_apply]
    rfl
  rw [hfun]
  calc μ[∑ j ∈ Finset.range k, c ^ j • ε (t - j) |
        MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi]
      =ᵐ[μ] ∑ j ∈ Finset.range k, μ[c ^ j • ε (t - j) |
        MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi] :=
        condExp_finsetSum (fun j _ => (hint _).smul _) _
    _ =ᵐ[μ] 0 := by
        have hall : ∀ᵐ ω ∂μ, ∀ j ∈ Finset.range k,
            (μ[c ^ j • ε (t - j) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi]) ω
              = 0 := by
          refine (Filter.eventually_all_finset _).2 fun j hj => ?_
          calc μ[c ^ j • ε (t - j) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi]
              =ᵐ[μ] c ^ j • μ[ε (t - j) | MeasurableSpace.comap (θ (t - k)) MeasurableSpace.pi] :=
                condExp_smul _ _ _
            _ =ᵐ[μ] c ^ j • (0 : Ω → κ → ℝ) := (h0 j hj).const_smul _
            _ = 0 := smul_zero _
        filter_upwards [hall] with ω hω
        rw [Finset.sum_apply, Finset.sum_eq_zero hω]
        rfl

/-- Step 2 (appendix 320). "The composition weights are `1 − c^{2k}` and
`c^{2k}`": the composition theorem with decay factor `a = c^k`. Integer time
is read into the theorem's real time through `s ↦ θ_{⌊s⌋}`, with `T = −1/log c`
and delay `k`, so that `e^{−k/T} = c^k`. -/
theorem s2_weights (hC7 : C07.Statement) (M : Model ι κ α) (μ : Measure Ω)
    [IsProbabilityMeasure μ] (θ ε : ℤ → Ω → κ → ℝ) (c : ℝ) (hc0 : 0 < c) (hc1 : c < 1)
    (hθ : StationaryState μ θ) (hε : ∀ s, MemLp (ε s) 2 μ)
    (hrec : ∀ s ω, θ (s + 1) ω = c • θ s ω + ε (s + 1) ω)
    (hcond : ∀ s, μ[ε (s + 1) |
      ⨆ u : {u : ℤ // u ≤ s}, MeasurableSpace.comap (θ u) MeasurableSpace.pi] =ᵐ[μ] 0)
    (t : ℤ) (k : ℕ) (r : ℕ∞) :
    M.R μ r (θ (t - k)) (θ t)
      = (1 - c ^ (2 * k)) * M.Rinf μ (θ t) + c ^ (2 * k) * M.R μ r (θ t) (θ t) := by
  have hpred := s1_iterate_tower μ θ ε c hθ hε hrec hcond t k
  have hlog : log c < 0 := log_neg hc0 hc1
  have hT : 0 < -1 / log c := div_pos_of_neg_of_neg (by norm_num) hlog
  have ha : exp (-(k : ℝ) / (-1 / log c)) = c ^ k := by
    rw [show -(k : ℝ) / (-1 / log c) = k * log c by field_simp, exp_nat_mul, exp_log hc0]
  have e1 : ⌊(t : ℝ) - (k : ℝ)⌋ = t - k := by
    rw [show (t : ℝ) - (k : ℝ) = ((t - k : ℤ) : ℝ) by push_cast; ring, Int.floor_intCast]
  have hA : TemporalAssumption μ (fun s : ℝ => θ ⌊s⌋) (-1 / log c) (t : ℝ) (k : ℝ) :=
    { stationary := ⟨fun s => hθ.measurable _, fun s => hθ.memLp _,
        fun s s' => hθ.identDistrib _ _⟩
      T_pos := hT
      τ_nonneg := by positivity
      prediction := by
        simp only [e1, Int.floor_intCast, ha]
        exact hpred }
  have h := hC7 M μ (fun s : ℝ => θ ⌊s⌋) (-1 / log c) (t : ℝ) (k : ℝ) r hA
  simp only [e1, Int.floor_intCast, ha] at h
  rw [h, ← pow_mul, mul_comm k 2]

/-- The AR(1) remark: both parts. -/
theorem main (hC7 : C07.Statement) : C04b.Statement := by
  intro ι κ α Ω _ _ _ _ M μ _ θ ε c hc0 hc1 hθ hε hrec hcond t k
  exact ⟨s1_iterate_tower μ θ ε c hθ hε hrec hcond t k,
    fun r => s2_weights hC7 M μ θ ε c hc0 hc1 hθ hε hrec hcond t k r⟩

end TinaV2.C04b.A1
