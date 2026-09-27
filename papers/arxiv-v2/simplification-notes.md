# Simplification plan: Sections 3–5

Sep 25, 2026 · Bhaskar Krishnamachari

## Overview

Make every architecture a snapshot and derive every result in Sections 3–5 from one argument. This cuts Sections 3–5 from about 18 pages to about 9, with no change to any theorem's content or any numerical result.

**Guiding principles**

1. **Snapshots everywhere.** Each agent sees current or delayed state *values*, never histories. Fresh-local and stale-global become the r = 0 and r = D members of the Section 4 radius family by definition.
2. **One toolkit.** Lemma 1 (projection) plus an innovation decomposition plus a Pythagoras step. No conditional-expectation detour, no shift operator, no snapshot-versus-history lemma.
3. **Theorem 4 generalizes Theorem 2 visibly.** Both use the same three-line proof; Theorem 4 replaces a zero-delay regret of 0 with R(A_{r,0}).
4. **Canonical radius by self-similarity and calculus.** The exponential omission law follows from memorylessness, and the optimum from a single derivative.

**The unified argument, in words.** Over a delay τ, the centered decision splits into a decayed old part plus fresh noise (the innovation). Any delayed policy's error splits into two perpendicular pieces: what could have been predicted but wasn't, and what nobody could predict. Their costs add.

**Estimated length (±1 page per section)**

| Section | Now | After |
| --- | --- | --- |
| 3 | ~6 pp | ~4.5 pp |
| 4 | ~5 pp | ~1.5–2 pp |
| 5 | ~7 pp | ~2.5–3 pp |
| Total | ~18 pp | ~9 pp |

No experiment needs rerunning. Experiments 1–2 already sample snapshot pairs and current-state draws, and Experiments 3–6 compute quantities whose definitions do not change.

## Section 3: Fresh-local versus stale-global

Section 3 keeps all its results but switches to snapshot benchmarks, states both loss shares as plain regret ratios, and proves Theorem 2 with the innovation split instead of conditional covariances.

### 3.1 + 3.2 → merge into one subsection, "Two benchmark architectures"

**Redefine the architectures as snapshots** (replace (32) and (34)):

$$
\mathcal A_{\rm loc}:\ \mathcal G_i=\sigma(\theta_{i,t}),\qquad \mathcal A_{\rm glob}(\tau):\ \mathcal G_i=\sigma(\theta_{t-\tau})\ \ \forall i.
$$

Add one sentence: these are the r = 0 and r = D members of the synchronized-snapshot family in Section 4.

**Keep** the open-loop regret R∞ (36) and the assumption R∞ > 0.

**Define both shares the same way**, as regret ratios: ηS(0) = R_loc/R∞ and ηT(τ) = R_glob(τ)/R∞.

**Delete:**

- Proposition 1, its proof, and (37)–(40). Replace with one sentence: stale-global regret is the Q-weighted mean-square error of predicting x\*_t from θ_{t−τ}.
- The claim that ηT(τ) is nondecreasing "because the available σ-algebra becomes smaller". Snapshots at different delays are not nested, so the argument fails. Replace with: for the OU model, (53) shows monotonicity explicitly; more generally it holds for Markov environments.

**Keep** ηT(0) = 0 and the mixing limit ηT(τ) → 1.

**Demote Theorem 1** to an unnumbered observation, since it is a division by R∞:

$$
R_{\rm loc}<R_{\rm glob}(\tau)\iff \eta_T(\tau)>\eta_S(0).
$$

Keep the paragraph interpreting ηS(0) as spatial loss and ηT(τ) as temporal loss.

### 3.3 Gauss–Markov model

**Keep** the OU model (45), the affine decision (46)–(47), and ρ = τ/T (48).

**Replace (49)–(50) with the innovation decomposition** as a numbered equation:

$$
\theta_t-\bar\theta=e^{-\rho}\,(\theta_{t-\tau}-\bar\theta)+\varepsilon_{t,\tau},\qquad \mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]=0.
$$

For the OU process, ε is Gaussian and independent of the past; cite [18] or the standard OU transition law. With X_t = x\*_t − E[x\*_t] and K = Q⁻¹B, the centered decision inherits the split:

$$
X_t=e^{-\rho}X_{t-\tau}+K\varepsilon_{t,\tau}.
$$

**Add a new lemma, "Innovation split".** For any policy u that is a square-integrable function of θ_{t−τ}:

$$
\mathbb E\|X_t-u\|_Q^2=\mathbb E\|e^{-\rho}X_{t-\tau}-u\|_Q^2+\left(1-e^{-2\rho}\right)2R_\infty.
$$

Proof sketch for the paper:

1. The error is (e^{−ρ}X_{t−τ} − u) + Kε. The first piece is a function of θ_{t−τ}, and E[ε | θ_{t−τ}] = 0, so the Q-cross term vanishes (Pythagoras).
2. Applying the same orthogonality with u = 0 and using stationarity: E‖X‖² = e^{−2ρ}E‖X‖² + E‖Kε‖², so E‖Kε‖²_Q = (1 − e^{−2ρ})·2R∞.

Note that step 2 needs no covariance calculation and no Σ∞.

**Theorem 2 becomes a two-line corollary.** A global snapshot at t − τ can compute e^{−ρ}X_{t−τ} exactly, so the first term is zero. Keep statement (51)–(53).

- Delete the old proof and (54)–(55).
- Keep (52) for R∞ as a separate one-line identity: R∞ = ½ tr(BᵀQ⁻¹BΣ∞).
- Keep (56) and the limit remarks.

**Add a remark on generality.** The split only needs E[ε | θ_{t−τ}] = 0 and a common decay factor, so it covers linear AR(1)-type processes with non-Gaussian innovations.

### 3.4 Crossover

Theorem 3 is unchanged. In its proof, change "By Theorem 1" to point at the observation above.

### 3.5 Role of decision coupling

Proposition 2's statement and (62)–(70) are unchanged. In the proof, replace the "full local history" step:

> For j ≠ i, u_j is a function of θ_{j,t}, which is independent of θ_{i,t}, so E[u_j | θ_{i,t}] = E[u_j] = μ_j.

The rest of the proof, including the remark that Gaussianity is not needed, stays.

## Section 4: Spatial and temporal predictability

Section 4 shrinks to the snapshot family, the definition of ηS(r), and a composition theorem proved with the Section 3 innovation split. All of Lemma 2 and the shift-operator machinery goes.

### Section intro

Shorten to two or three sentences: temporal predictability sets the freshness loss; decision-relevant spatial predictability sets the omission loss.

### 4.1 Spatial structure

- **Keep** ΣS (71) and the canonical exponential covariance (72), which Section 5 uses.
- **Move** the Laplacian covariance model (73) to Section 6.1, the only place it is used (Experiments 5–6).
- **Delete** the graph-smoothness statistic E_G, (74)–(75), and its discussion.
- **Move** the sentence "Neither ℓs nor E_G by itself determines architecture regret" into 4.4, rephrased without E_G.

Result: one short paragraph.

### 4.2 Temporal structure

- **Keep** the common-rate model (77)–(78). Note it is (45) with Σ∞ = ΣS, or simply reference (45).
- **Shorten** the separability remark to one sentence citing [22].
- **Delete** the restated definition of ηT (76); it is already defined in Section 3.

### 4.3 Snapshot architectures

**Keep:**

- the zero-delay and delayed snapshot definitions (79)–(81), with the sentence motivating common-time snapshots;
- the definition of ηS(r) (93);
- nestedness at zero delay (94)–(95), which still holds because all snapshots are taken at time t;
- the endpoints ηS(0) = R_loc/R∞ (96) and ηS(D) = 0 (97), which now hold by definition.

**Delete:**

- the history information set (82) and the sentence about "the consistently shifted history family";
- F_t, the centered subspace S₀, the shift operator U_τ, shift-consistency, and P_{r,τ}: (83)–(86) and surrounding text;
- Lemma 2, its proof (88)–(92), and Remark 2. This removes the Rao–Blackwellization, cylinder-event, monotone-class, and Moore–Penrose material;
- the sentence after (96) invoking Lemma 2.

**Optional:** one sentence noting that history-based variants exist and give the same regret under the common-rate Gaussian model, with no proof.

### 4.4 Decision-relevant smoothness

Keep (98)–(101). Trim the discussion to one paragraph: ηS depends on K, not just ΣS, so raw correlation length is the wrong design statistic. Experiment 5 illustrates this.

### Theorem 4 (composition law)

**Keep** the statement (102)–(104). **Hypotheses:** the common-rate model and an affine decision. **Drop** "shift-consistent".

**Replace the proof** ((105)–(113) and text) with:

> Let u be admissible for A_{r,τ}. Every such u is a function of θ_{t−τ}, so the innovation split applies:
>
> $$\mathbb E\|X_t-u\|_Q^2=\mathbb E\|e^{-\rho}X_{t-\tau}-u\|_Q^2+\left(1-e^{-2\rho}\right)2R_\infty.$$
>
> The admissible set is a linear space containing the constants, so u = e^{−ρ}v maps it onto itself and preserves each agent's measurability. The minimum of the first term is therefore e^{−2ρ} times the minimum over v of E‖X_{t−τ} − v‖²_Q. That is the zero-delay radius-r problem posed at t − τ, which equals 2R(A_{r,0}) by stationarity. ∎

**Add one sentence after the proof:** Theorem 2 is the case r = D, where ηS(D) = 0.

**Keep** the interpretive paragraph after the theorem (temporal innovation plus discounted spatial omission), trimmed to three sentences.

**Add a remark:** the composition law needs only the innovation structure, not Gaussianity. Gaussianity enters when ηS(r) is computed as a conditional variance (Section 5 and Experiments 5–6).

## Section 5: Optimal coordination scale

Section 5 becomes two subsections: the radius family with its marginal-balance identity, then the canonical model with a self-similarity lemma and a direct proof of Theorem 6. Subsections 5.3–5.5 collapse into the second one.

### New 5.1: Radius family and marginal balance (old 5.1 + 5.2, about 0.75 pp)

**Keep:**

- τ(r) with τ(0) = 0 and monotone (114)–(115);
- R(r) (117)–(118);
- the one-hop comparison (119)–(120), used in Experiment 6;
- the endpoints (121)–(122), now true by definition. Delete the sentence citing Lemma 2;
- the split R = R_T + R_S (123)–(125), which labels the Figure 3 curves;
- m_T and m_S (126)–(128), the derivative identity (129), and the first-order condition (130). Experiment 3 reports the m_S − m_T gap;
- the verbal principle (134).

**Change:**

- Proposition 3 → a two-sentence remark: nested information cannot create an interior minimum without an explicit cost, which is why the snapshot family is non-nested.
- Theorem 5 → a proposition containing only (129)–(130).
- The unimodality cases (131)–(132), the numbered comparative-statics list, and the concave/convex latency discussion → one short remark (about three sentences: the single-crossing condition, the four comparative-statics directions, and the caveat that concave latency laws can break uniqueness).

**Keep** the continuous-relaxation paragraph, shortened to two sentences.

### New 5.2: Canonical line model and closed-form radius (old 5.3–5.5, about 2 pp)

**Model.** Keep (143)–(147) and L_T = vT (137). Keep the per-unit-length convention as one sentence. Delete Remark 3.

**Delete** 5.3 as a standalone subsection: Proposition 4, (135)–(142), and its proof. Its content is absorbed into Theorem 6's proof.

**New lemma (replaces Proposition 5): exponential omission by self-similarity.** With κ = 1/ℓc and λ = 1/ℓs:

$$
\eta_S(r)=\eta_0\,e^{-2r/\ell_c},\qquad \eta_0=\frac{\ell_c}{\ell_c+2\ell_s}.
$$

Proof, step A (the exponential form, no integrals):

1. Observe the field on [−r, r]. Split x\*(0) into the observed middle, a left tail, and a right tail.
2. By the spatial Markov property of the OU field [21], given the segment the right tail depends only on θ(r), and the two tails are conditionally independent.
3. The right tail equals (κ/2)e^{−κr} ∫₀^∞ e^{−κs} θ(r+s) ds. By stationarity, the integral's conditional variance given θ(r) is a constant C that does not depend on r.
4. So Var(x\* | O_r) = 2(κ²/4)e^{−2κr}C = e^{−2κr} Var(x\* | O_0). Dividing by Var(x\*) gives ηS(r) = ηS(0)e^{−2r/ℓc}.

The point to stress in the text: the result is exact because both the OU field and the exponential weight are memoryless.

Proof, step B (the constant): η₀ = 1 − corr(x\*(0), θ(0))². Two integrals:

$$
\operatorname{Cov}(x^\star,\theta(0))=\frac{\sigma^2\kappa}{\kappa+\lambda},\qquad \operatorname{Var}(x^\star)=\frac{\sigma^2\kappa(2\kappa+\lambda)}{2(\kappa+\lambda)^2}.
$$

These give η₀ = λ/(2κ + λ) = ℓc/(ℓc + 2ℓs). Delete (150)–(153), (155), and the exterior-residual computation (151)–(152). Keep (154) as the one double integral.

**Theorem 6.** Keep statement (158)–(160) and the four comparative statics. **Replace the proof:**

> With τ = r/v, minimizing R(r) is maximizing
>
> $$g(r)=e^{-2r/L_T}-\eta_0\,e^{-2r(1/L_T+1/\ell_c)}.$$
>
> $$g'(r)=2e^{-2r/L_T}\left[\eta_0\left(\tfrac{1}{L_T}+\tfrac{1}{\ell_c}\right)e^{-2r/\ell_c}-\tfrac{1}{L_T}\right].$$
>
> The bracket is strictly decreasing, so g′ changes sign at most once and R is unimodal. Setting it to zero gives η₀(1 + L_T/ℓc)e^{−2r/ℓc} = 1, hence
>
> $$r^\star=\frac{\ell_c}{2}\Big[\log\big(\eta_0(1+L_T/\ell_c)\big)\Big]_+ .$$
>
> If the bracket is nonpositive at r = 0, then r\* = 0. A cap D gives min(D, r\*). Substituting η₀ gives (159).

Keep the general-η₀ formula as a numbered equation (old (138)–(139)); Experiment 3 uses it with arbitrary η₀.

**Comparative statics.** L_T (so v and T) and ℓs follow by inspection of (159). For ℓc keep the integral form (163). Delete (161)–(162) or keep them inline.

**Add three interpretive points** after the theorem, replacing most of the current closing prose:

- **Threshold.** At r = 0, m_S(0) = 1/ℓs and m_T = 2/L_T. The first increment of radius pays off iff L_T > 2ℓs, which does not depend on ℓc.
- **Long decision range** (ℓc ≫ L_T, ℓs): r\* ≈ (L_T − 2ℓs)/2, half the excess propagation length.
- **Short decision range** (ℓc ≪ ℓs, L_T): r\* ≈ (ℓc/2) log(L_T/2ℓs).

Keep the three-length display (164) and the final sentence on finite graphs.

## Changes elsewhere in the paper

Outside Sections 3–5 the edits are small: snapshot definitions in 2.2, one limitation paragraph in Section 8, a moved covariance model in Section 6, and cross-references.

### Section 1 (Introduction)

- Where architectures are first described, add half a sentence: every architecture studied is a synchronized snapshot of current or delayed state.
- Contribution 2: optionally add that the composition law follows from a single innovation-orthogonality argument that also yields the stale-global law.
- Update the roadmap paragraph if the Section 5 subsection structure changes.

### Section 2.2 (Information architectures)

- Redefine fresh-local (13) as σ(θ_{i,t}) and stale-global (14) as σ(θ_{t−τ}).
- Delete the sentence saying the radius-D snapshot "is a delayed global snapshot, not the complete delayed global history in (14)". The two now coincide.
- Hybrid architecture (17): change to σ(θ_{i,t}) ∨ σ(z_{t−τz}). The following sentences still hold.
- Keep the paragraph on mixed-age architectures being outside scope.

### Section 2.4 and Table 1

- Lemma 1, Corollary 1, and Remark 1 are unchanged. Corollary 1 is still used in Proposition 2's proof.
- Table 1: no symbols are removed. Optionally add ε (innovation) and η₀ (radius-zero omission share).

### Section 6 (Numerics)

- **6.1:** add the Laplacian covariance ΣS = σ²(κs²I + L_G)^{−ν}, moved from (73). Experiments 5 and 6 already restate it, so a single definition here suffices.
- **Experiment 1:** optionally rephrase "delayed conditional mean" as "the optimal delayed-snapshot action". The computation is unchanged.
- **Experiments 3 and 4:** update equation references. They cite (103), (123), (138), and (158), and use m_S and m_T; all survive under new numbers.
- **Experiment 6:** update the reference to (119).
- **Figure 4 caption:** update the reference to Eq. (158).

No numbers, figures, or runs change.

### Section 7 (Related work)

No substantive changes.

### Section 8 (Discussion)

- "What the theory establishes": update theorem names and numbers. Theorem 5 is now a proposition.
- "Scope and limitations": delete the sentence "Under the common-rate Gaussian model, Lemma 2 makes current snapshots sufficient…". Replace with: architectures are snapshot-based; history-based and mixed-age variants are outside the main family.
- Same paragraph: soften "the explicit stale-global and composition laws additionally require … a common-rate Gaussian or Gauss–Markov process". They require affine decisions and a common-rate innovation structure; Gaussianity is used only to compute ηS(r) as a conditional variance.

### Reproduction repository

If the TINA documentation or figure scripts cite equation or theorem numbers, update them after renumbering.

## Numbering map and checklist

The numbered results drop from 13 to 9. Suggested new numbering is below; LaTeX labels will handle the rest.

| Old | New | Change |
| --- | --- | --- |
| Lemma 1 | Lemma 1 | Unchanged |
| Proposition 1 | — | Replaced by one sentence |
| Theorem 1 | — | Unnumbered observation |
| — | Lemma 2 (innovation split) | New, in 3.3 |
| Theorem 2 | Theorem 1 | Two-line proof from Lemma 2 |
| Theorem 3 | Theorem 2 | Unchanged |
| Proposition 2 | Proposition 1 | Proof uses snapshots |
| Lemma 2 (snapshot–history) | — | Deleted |
| Theorem 4 | Theorem 3 | New short proof |
| Proposition 3 | — | Remark |
| Theorem 5 | Proposition 2 | Identity (129)–(130) only |
| Proposition 4 | — | Absorbed into Theorem 4 proof |
| Proposition 5 | Lemma 3 (self-similarity) | New proof |
| Theorem 6 | Theorem 4 | Direct calculus proof |

**Implementation checklist**

- [ ] 2.2: snapshot definitions (13), (14), (17); delete the history sentence
- [ ] 3.1–3.2: merge; regret-ratio shares; delete Proposition 1; fix the ηT monotonicity claim; demote Theorem 1
- [ ] 3.3: innovation decomposition; new Lemma 2; new Theorem 2 proof; generality remark
- [ ] 3.5: snapshot step in Proposition 2's proof
- [ ] 4.1–4.2: cut E_G; move (73) to 6.1; shorten remarks
- [ ] 4.3: delete (82)–(86), Lemma 2, Remark 2
- [ ] Theorem 4: drop shift-consistency; new proof; add the "Theorem 2 is r = D" sentence
- [ ] 5.1: merge old 5.1–5.2; demote Proposition 3 and Theorem 5
- [ ] 5.2: self-similarity lemma; direct Theorem 6 proof; keep the general-η₀ formula; add the three interpretive points
- [ ] Section 6: move the Laplacian model; update equation references and the Figure 4 caption
- [ ] Section 8: replace the Lemma 2 sentence; soften the Gaussianity claim; update theorem names
- [ ] Recompile and check every cross-reference to a deleted label
- [ ] Verify numerically: the Lemma 3 formula against old (148), and the Theorem 4 formula against Experiment 4's grid minima

**Two things to double-check while writing the proofs**

- In the Theorem 4 proof, the rescaling u = e^{−ρ}v must preserve agentwise measurability. It does, because scaling acts on each agent's action separately.
- In the self-similarity lemma, the r = 0 case uses the same tail decomposition with an empty observed middle, so the ratio e^{−2κr} is exact.
