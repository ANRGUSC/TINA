# tina-v2: manuscript findings from the Lean formalization

- **Date:** 14 November 2026 (second version, rewritten against the renamed manuscript)
- **For:** Bhaskar, for edits to the manuscript
- **Manuscript:** `submissions/arxiv-v2/main-v2.tex` and `technical-appendices-v2.tex` at commit `6454c74`, which is `origin/main` on 14 November. Every line number and quotation below was rechecked against those two files at that commit.
- **Addendum:** section 7, at the end, was added later on 14 November. It reports which results are now machine-checked and adds findings F11–F14, which came from writing the proofs. Sections 1–6 are unchanged.
- **Source:** the proof ledger in `papers/arxiv-v2/lean/` (findings F1–F10). K-numbers refer to the 12 November co-author review (`submissions/arxiv-v2/alt-review/index.html`).

## Changes since the 4a9b87e version

An earlier version of this memo was written against `main-alt.tex` and `technical-appendices-alt.tex` at commit `4a9b87e`. If you have that one, this replaces it. What changed:

- **File names, commit and line numbers.** All references now point to `main-v2.tex` and `technical-appendices-v2.tex` at `6454c74`. Main-text line numbers after line 86 moved by between 32 and 92 lines; appendix lines after 270 moved by 4.
- **F1 is resolved** by your commit `284a0e0` (joint Gaussianity stated, field derivation added). Nothing more is asked under F1.
- **F10 is new** and small: it is what remains of F1 after that commit.
- **The continuum composition law is off the list of unproved assertions** (section 3), so that list is 17 items, down from 18.
- **F2–F9 are unchanged in substance.** Your edits did not touch those passages apart from the rename of "open-loop" to "no-information", which changes one quotation under F2.
- **Review items K1, K2, K3 and K4 are now addressed** in the text (section 6). The K1 attribution left the composition theorem's statement and proof unchanged, so nothing has to be redone on the formal side.
- **The review citation** now points to `alt-review/index.html`. The earlier memo cited `review-summary.md`, which is not in the repository.

The edits in `8d0ac72..90ccdee` were read in full against the ledger. They introduced no new problem other than F10. The new abstract's two quantitative statements agree with the results they summarize: "more than twice the spatial correlation length in one coherence time" is `eq:positive_radius_condition`, and "0.7 to 6 hops … one to five hops" matches the ring example.

## Bottom line

Nothing found so far says a stated result is false. Every item below is a place where the text is missing an argument, a hypothesis or a definition, or where two parts of the paper disagree.

No proof has been machine-checked yet. So far each claim in the foundations, composition, coupling and radius sections has been written as a formal statement (28 claims), and each written proof has been split into steps. The findings come from that work. The projection lemma, the normal equations and the canonical field model (C1, C2, C3, C17, C17.b, C18) have not been stated formally yet, so more may surface there.

Why small gaps matter here: the formal proofs are required to follow the paper's proofs step for step. Where the paper asserts something without an argument, there is nothing for the formal proof to follow, so the paper needs at least a sentence.

What is asked of you, in order of weight:

| # | Item | Where | Kind of edit |
|---|---|---|---|
| F3 | Unequal-rate formula: $w_k$ undefined, no proof | main 471–484 | Definition plus short proof, or a citation |
| F8 | Radius section switches from graph radii to a real radius without saying so | main 719–786 | One setup sentence; reword two "Under Theorem" openings |
| F10 | Radius theorem's proof does not cite the new field derivation; statements omit "Gaussian" | main 839–855, 859, 885, 909–913 | Label the derivation as a lemma; one sentence in the proof; two words in two statements |
| F5 | Stale-global is listed as a case of $\mathcal A_{r,\tau}$ but may need no finite radius | main 273–281, 453–465 | One sentence |
| F6 | Two definitions of admissible rule, never linked | main 282–283, app 99–109 | One sentence |
| F4 | Crossover theorem's $\eta_S(0)=1$ clause is outside its hypothesis and unproved | main 486–501 | Reword hypothesis; one sentence of proof |
| F9 | AR(1) remark does not say what the innovations are independent of | main 359–361, app 313–315 | Wording |
| F2 | Aggregate-coupling proposition is derived twice by different routes | main 591–613, app 349–403 | Cut or relabel the appendix derivation |
| F7 | Which stationarity is meant | main 331, 346 | Confirm only; no edit needed |
| — | 17 assertions with no written argument (one of them is F3) | listed in section 3 | Mostly one sentence each |
| F1 | Canonical model used the composition theorem without a bridge (same as K2) | main 797, 839–855 | None: resolved by `284a0e0` |

## 1. Gaps that need new text

### F1 (resolved): the canonical model invoked a finite-graph theorem

Resolved by `284a0e0`. Line 797 now reads "a jointly Gaussian space--time field on the infinite line", and the paragraph at main 839–855 argues the composition law for the field directly from the covariance: the innovation is uncorrelated with the old field, hence independent of it; the conditional mean of the target scales by $a$; the gain is $q/2$ times the variance of the conditional mean; stationarity equates the delayed and fresh variances. The ledger records that paragraph as a claim with a six-step proof. The loose ends are in F10.

### F10 (minor, new): the radius theorem's proof does not cite the field derivation

**Where.** The derivation paragraph at main 839–855; Proposition `prop:generic_exponential_radius` at 759–786; Lemma `prop:canonical_eta_S` at 857–880; Theorem `thm:canonical_optimal_radius` at 883–920, with its proof at 909–920; line 824.

**Problem.** Four loose ends remain after `284a0e0`.
1. The derivation is an unlabelled paragraph that ends in words: "The delayed interval therefore retains $a^2$ times the gain from a fresh interval of the same radius." The identity is never displayed, and there is nothing to cite.
2. The theorem's proof still says only "Substitution into Proposition [generic_exponential_radius] gives the radius" (911–913). That proposition opens "Under Theorem [spatiotemporal_composition]" (761), which is the finite-graph theorem. Nothing tells the reader that the paragraph at 839–855 is what licenses the substitution.
3. The lemma ("For the field [covariance equation]", 859) and the theorem ("Suppose the field obeys Eq. [covariance equation]", 885) identify the field only by its covariance. Joint Gaussianity is stated in the model paragraph (797) and in the limitations (1232–1233), but both proofs need it and neither statement says it.
4. Line 824 still says regret per unit length is "equal by stationarity to expected pointwise loss". That is asserted without argument and is not needed.

**Suggested edit.**
1. Make 839–855 a labelled lemma whose statement displays $R(r,\tau)=(1-a^2)R_\infty+a^2R(r,0)$, $a=e^{-\tau/T}$, for every location $z$, real $r\ge0$ and $\tau\ge0$. The present text is its proof.
2. Open the theorem's proof with: "By Lemma [new], $R(r)=R_\infty[1-G(r)]$ with $\tau(r)=r/v$ and $\eta_S$ from Lemma [canonical_eta_S]."
3. Write "For the jointly Gaussian field …" in the lemma and the theorem.
4. Define regret in this model as the expected pointwise loss at a location, and drop "per unit length, equal by stationarity".

### F3 (medium): unequal-rate formula

**Where.** main 471–484.

**Problem.** The formula $1-R_{\rm glob}(\tau)/R_\infty=\sum_k w_k e^{-2\tau/T_k}$ has no proof, and "the fraction of the no-information decision loss $R_\infty>0$ attributable to mode $k$" is not defined. A definition only makes sense if the cross-mode terms of $\mathbb E[(x^\star)^\top Qx^\star]$ vanish.

**Suggested edit.** Either cite it (the review notes Marschak–Radner Ch. 7, eqs. 3.46–3.47, cover it; your `284a0e0` added Marschak–Radner citations for the composition theorem, the marginal balance and the local share, but not here) or make it a remark with a proof along these lines:
- Setup: $\theta=(\theta^{(1)},\dots,\theta^{(m)})$ with mutually independent, centered mode processes; mode $k$ satisfies the prediction rule with $a_k=e^{-\tau/T_k}$; $x^\star=\sum_k K_k\theta^{(k)}$.
- Definition: $w_k=\mathbb E[(K_k\theta^{(k)})^\top Q(K_k\theta^{(k)})]\,/\,\mathbb E[(x^\star)^\top Qx^\star]$. These sum to one because the cross terms vanish by independence and zero means.
- Proof: with the complete old state the optimum is $\sum_k a_kK_k\theta^{(k)}_{t-\tau}$; the error is the sum of the mode innovations, whose cross terms vanish, and mode $k$ contributes $(1-a_k^2)$ times its share.

The argument does not use Gaussianity, so "Ornstein–Uhlenbeck modes" could be weakened to modes satisfying the prediction rule.

### F4 (minor): the $\eta_S(0)=1$ clause of the crossover theorem

**Where.** main 486–501.

**Problem.** The theorem assumes $0\le\eta_S(0)<1$ (488–489) and then makes a claim about $\eta_S(0)=1$ (495–496). The proof ("Rearranging gives the threshold and equality case", line 500) covers only the first range.

**Suggested edit.** Assume only $R_\infty>0$, then split the two cases in the statement. Add to the proof: "If $\eta_S(0)=1$ then $R_{\rm loc}=R_\infty$, while $R_{\rm glob}(\tau)=(1-e^{-2\tau/T})R_\infty<R_\infty$ for every finite $\tau$."

## 2. Places where the paper disagrees with itself

### F8 (minor): graph radius versus real radius

**Where.** `eq:snapshot_gain` at main 684–694; Propositions `thm:marginal_balance` (719–739) and `prop:generic_exponential_radius` (759–786); the two remarks at 741–751.

**Problem.** $\eta_S(r)$ is defined in Section 2 only for integer graph radii. From line 719 on, $\eta_S$ and $\tau$ are continuously differentiable functions on $[0,D]$ and results speak of "the optimal radius", still "Under the assumptions of Theorem [composition]" (721–722) and "Under Theorem [composition]" (761). The theorem says nothing about a real radius.

**Suggested edit.** One sentence before `thm:marginal_balance`, for example: "From here on the radius is a real variable: $\eta_S:[0,D]\to[0,1)$ and $\tau:[0,D]\to[0,\infty)$ are given curves, $G$ is defined by `eq:snapshot_gain`, $R(r):=R_\infty[1-G(r)]$, and an optimal radius is a maximizer of $G$." Then open both propositions with that setup instead of "Under Theorem …". For the canonical model, the lemma proposed under F10 is what makes $R(r)=R_\infty[1-G(r)]$ true there.

The formal statements are already written this way (pure calculus about $G$), so this edit brings the paper in line with them.

### F5 (minor): stale-global as a case of $\mathcal A_{r,\tau}$

**Where.** "The three cases are" at main 273–281; proof of Corollary `thm:OU_stale_regret` at 462–465; lines 706–707.

**Problem.** Stale-global is listed among the cases of $\mathcal A_{r,\tau}$, and the corollary's proof substitutes $R(\mathcal A_{r,0})=0$ into the composition law. That needs a radius at which every agent sees everything. On a disconnected graph there is none, and the paper never assumes connectivity; it only says "the diameter of a finite connected graph gives a complete stale-global snapshot" (706–707).

**Suggested edit (pick one).**
- (a) Recommended: allow $r=\infty$ with $\mathcal N_\infty(i)=V$, and say stale-global is $\mathcal A_{\infty,\tau}$; on a connected graph any $r\ge\operatorname{diam}(G)$ is the same architecture. This adds no assumption and matches the formal statements as drafted.
- (b) Assume $G$ connected at line 204.
- (c) State the composition theorem for arbitrary synchronized neighborhoods instead of radius balls.

### F6 (minor): two definitions of an admissible rule

**Where.** main 282–283 ($u_i=g_i(Z_{i,t}^{(r,\tau)})$ with finite second moment); app 99–109 ($u_i$ is $\mathcal G_i$-measurable, $\mathcal G_i=\sigma(Z_i)$).

**Problem.** The appendix's information-inclusion fact (`eq:info_inclusion`) is in the sigma-algebra form. The main text applies it to rules in the function form ("Larger fresh neighborhoods cannot increase it", line 323). The only link is the informal "Measurability here means that $u_i$ can be computed from those observations" (app 102).

**Suggested edit.** In the main text say $g_i$ is measurable. In the appendix after line 102 add: "By the Doob–Dynkin lemma, $u_i$ is $\sigma(Z_i)$-measurable exactly when $u_i=g_i(Z_i)$ for a measurable $g_i$, so $\mathcal S(\mathcal A)$ is the set of admissible rules of the main text."

### F9 (minor): AR(1) innovations

**Where.** main 359–361; app 313–315.

**Problem.** "Independent, mean-zero finite-variance innovations" (main) and "independent, mean-zero square-integrable innovations" (appendix) do not say independent of what. The coefficient $c^k$ needs each innovation to be independent of the earlier states.

**Suggested edit.** "…innovations $\xi_t$ that are mean-zero, square-integrable and independent of the past of the process ($\theta_s$, $s<t$)". The proof to add is in section 3.

### F2 (minor): two derivations of the aggregate-coupling result

**Where.** Proof of `prop:aggregate_local` at main 591–613; app 349–403.

**Problem.** The main-text proof finds the local rule $\theta_i/(q+\gamma)$ by a centered decomposition and gets the regrets by subtracting expected costs. The appendix, introduced as "the matrix arithmetic" (app 321), re-derives the rule from the coupled normal equations and gets $R_{\rm loc}$ from the Pythagorean identity. These are two different proofs of one proposition, and only one can be the proof the formal version follows. Both are still in the paper at `6454c74`; the only change there since `4a9b87e` is the heading "No-information regret" at app 379.

**Proposal (Scott left this to the formalization; say if you disagree).** The main-text proof is the proof. In the appendix, cut the normal-equation derivation (lines 350–377) and justify $R_{\rm loc}$ by the same cost subtraction as the main text instead of the Pythagorean identity (line 387); the arithmetic is unchanged. If you would rather keep the appendix derivation, label it as an alternative derivation.

A related point: the proposition says "For the model `eq:shared_resource_cost`", but the state assumptions it needs (independent, mean-zero, equal variance $\sigma^2>0$) are in a paragraph before it (544–545). They belong in the statement. The review found independence cannot be dropped.

## 3. Assertions with no written argument

Each of these is stated as fact with no proof. Most need one sentence, in place or in a short appendix section; your choice. The suggested arguments below were worked by hand and are not machine-checked.

### One sentence is enough

| Claim | Where | Suggested argument |
|---|---|---|
| Completing the square (`eq:complete_square`), and $x^\star$ is the unique minimizer | app 44–66 | With $b=Qx^\star$ and $Q$ symmetric, $f(x)-f(x^\star)=\tfrac12x^\top Qx-x^{\star\top}Qx+\tfrac12x^{\star\top}Qx^\star$, which is the square; $Q\succ0$ gives uniqueness. |
| Information inclusion (`eq:info_inclusion`) | app 111–118 | A $\mathcal G_i$-measurable $u_i$ is $\mathcal G_i'$-measurable, so $\mathcal S(\mathcal A)\subseteq\mathcal S(\mathcal A')$; an infimum over a larger set is no larger. |
| Projection error is $Q$-orthogonal; $2R=\|x^\star\|_Q^2-\|u^\star\|_Q^2$ | app 216–218 | The residual of a projection onto a closed subspace is orthogonal to it; apply Pythagoras with $u^\star\in\mathcal S(\mathcal A)$. |
| Best no-information action is zero; $R_\infty=\tfrac12\operatorname{tr}(K^\top QK\Sigma_S)$ | main 311–316 | For a constant $c$, $\mathbb E[(c-x^\star)^\top Q(c-x^\star)]=c^\top Qc+\mathbb E[x^{\star\top}Qx^\star]$ since $\mathbb E x^\star=0$; and $x^{\star\top}Qx^\star=\operatorname{tr}(K^\top QK\theta\theta^\top)$. |
| $0\le\eta_S(r)\le1$ | main 319 | $R\ge0$ since $Q\succ0$; $R\le R_\infty$ since the zero rule is admissible. |
| Normalized composition law (`eq:regret_composition_normalized`) | main 391–396, 442 | Divide the law by $R_\infty$ and substitute $\eta_S(r)=R(\mathcal A_{r,0})/R_\infty$. The proof's last sentence only says normalization "is valid". |
| Optimal global action is $aK\theta_{t-\tau}$ | main 466 | It is admissible for a complete snapshot and makes the first term of `eq:innovation_split` zero; the second term does not depend on $u$. |
| $R_{\rm glob}$: zero at zero delay, $2(\tau/T)R_\infty+o(\tau/T)$, tends to $R_\infty$ | main 466–469 | $1-e^{-2\rho}=2\rho+o(\rho)$ as $\rho\to0$, and $e^{-2\rho}\to0$ as $\rho\to\infty$. |
| Explicit threshold $\rho^\star(\gamma,n)$ (`eq:aggregate_rho_star`) and the equivalence after it | main 615–647 | $1-\eta_S(0)=\dfrac{q(q+\gamma n)}{(q+\gamma)(q+\gamma(n-1))}$, which is positive, so the crossover theorem applies. |
| Large-$n$ limit (`eq:large_n_threshold`); local share $q/(q+\gamma)$ | main 649–664 | $(q+\gamma(n-1))/(q+\gamma n)\to1$. |
| $\gamma=0$ gives $\eta_S(0)=0$; $\eta_S(0)$ and the crossover increase with $\gamma$ | main 666–673 | $\dfrac1{1-\eta_S(0)}=1+\dfrac{\gamma^2(n-1)}{q(q+\gamma n)}$, and $\gamma^2/(q+\gamma n)$ is increasing in $\gamma\ge0$. |
| $r^\star\to(vT-2\ell_s)/2$ as $\ell_c\to\infty$ | main 932–933 | $r^\star=\tfrac{\ell_c}2\log\!\big(1+\tfrac{vT-2\ell_s}{\ell_c+2\ell_s}\big)$ and $x\log(1+c/(x+d))\to c$. |

### Needs a short proof

**AR(1) satisfies the prediction rule** (main 359–361; app 313–315). Iterating $\theta_t=c\theta_{t-1}+\xi_t$ gives $\theta_t=c^k\theta_{t-k}+\sum_{j=0}^{k-1}c^j\xi_{t-j}$. Each $\xi_{t-j}$ with $j<k$ is independent of $\theta_{t-k}$ and has mean zero, so the conditional mean of the sum given $\theta_{t-k}$ is zero. The weights follow from the composition theorem with $a=c^k$. See F9 for the hypothesis this needs.

**Gaussian Ornstein–Uhlenbeck satisfies the prediction rule** (app 298–312). Asserted: "Its centered transition has independent Gaussian innovations" (308) and `eq:separable_space_time_covariance`. There is also a choice to make here. The example is defined by a stochastic differential equation, which the proof library cannot express at present. If the example were instead *defined* as the stationary Gaussian process with mean $\bar\theta$ and covariance $e^{-|t-s|/T}\Sigma_S$, with the differential equation kept as a description, the proof is three lines: $\varepsilon=\theta_t-a\theta_{t-\tau}$ has $\operatorname{Cov}(\varepsilon,\theta_{t-\tau})=a\Sigma_S-a\Sigma_S=0$; jointly Gaussian and uncorrelated means independent; so $\mathbb E[\varepsilon\mid\theta_{t-\tau}]=\mathbb E[\varepsilon]=0$ in centered coordinates. This is the same argument your new field derivation at main 839–844 uses. Is that redefinition acceptable to you?

**Single crossing gives the unique optimum** (main 741–746). Let $d(r)=\frac{d}{dr}\log[1-\eta_S(r)]-2\tau'(r)/T=(\log G)'(r)$, continuous because the curves are $C^1$. If $d$ is strictly decreasing: $d(0)\le0$ makes $d<0$ on $(0,D]$, so the maximum is at $0$; $d(D)\ge0$ makes $d>0$ on $[0,D)$, so the maximum is at $D$; otherwise the intermediate value theorem gives one zero, with $G$ increasing before it and decreasing after.

**Comparative statics in $T$ and the latency scale** (main 747–751). Raising $T$ raises $d$ pointwise because $\tau'\ge0$. If the old optimum $r$ is positive then $d>0$ on $[0,r)$ before the change, hence after it, so $G$ is still increasing on $[0,r]$ and the new optimum is at least $r$. The argument for $\alpha$ in $\tau=\alpha\tau_0$ is the mirror image.

**The unequal-rate formula** — see F3.

## 4. To confirm, no edit required

**F7: stationarity.** The assumption says "a stationary state process" (main 331), and line 346 says stationarity "supplies the same one-time distribution at the two epochs". The formal version assumes exactly that: $\theta_s$ and $\theta_t$ have the same law for all $s,t$. This is weaker than strict stationarity of the process, so it proves the theorem as you state it. One consequence: under the weaker reading $R(\mathcal A_{r,\tau})$ could depend on the epoch $t$ before the theorem is applied, so the formal statements carry $t$. If you want the paper to claim the weaker hypothesis, say so at line 346; otherwise nothing changes.

## 5. Small items

- **$R_\infty>0$ in Section 4.** $G(r)$ at main 688 is built from $\eta_S$, which is defined only for $R_\infty>0$. Say once that $R_\infty>0$ throughout the section.
- **Two-sensor example** (main 66–92). The strict inequality needs $\sigma^2>0$; "variance $\sigma^2>0$" at line 68 would cover it.

## 6. Items from the 12 November review

| Item | State at `6454c74` |
|---|---|
| K1: the composition law is in Marschak–Radner | Addressed in `284a0e0` and the abstract rewrites: abstract (line 47), introduction (161–168), the paragraph before the theorem (367–377, with the notation footnote), related work (1102–1111). The theorem's statement and proof (379–443) are unchanged, so the formal statement and the seven proof steps stand as they are. |
| K2: continuum bridge | Addressed in `284a0e0`. See F1 and F10. |
| K3: limitations understate what the radius results assume | Addressed in `284a0e0` (1230–1239). |
| K4: spatial-field age-of-information work not cited | Addressed in `284a0e0`: Jiang–Zhou and Munari et al. (1173–1181). |
| K6: Monte Carlo markers test an identity | Text unchanged apart from "open-loop" becoming "no-information" (959–966). |

The formalization has not checked the three new Marschak–Radner attributions (Eqs. 4.21–4.22, 6.5, 6.6) against the book.

## 7. Addendum: machine-checked results and findings F11–F14

Added later on 14 November, against the same manuscript commit `6454c74`. Line numbers below were rechecked against that commit.

### What is now machine-checked

The "Bottom line" above says no proof had been machine-checked. Twelve now are, each as one formal lemma per sentence of your proof, in the order you wrote them:

| Result | Label |
|---|---|
| Spatio-temporal composition | `thm:spatiotemporal_composition` (the unnormalized law) |
| Exact stale-global regret | `thm:OU_stale_regret` |
| Fresh-local versus stale-global crossover | `thm:local_global_crossover` |
| Two-sensor example | main 66–86 |
| Local explainability under aggregate coupling | `prop:aggregate_local` |
| Radius objective, one-more-hop criterion, loss decomposition | `eq:snapshot_gain`, `eq:discrete_radius_improvement`, `eq:R_decomposition` |
| Continuous marginal balance | `thm:marginal_balance` |
| Optimal radius for exponential omission | `prop:generic_exponential_radius` |
| Canonical optimal radius and its four comparative statics | `thm:canonical_optimal_radius` |
| Degenerate normalization; centering the affine model | app 287–292; app 87–95 |

Nothing found says a stated result is false. Three limits on what "checked" means:

- The formal statements are drafts that Scott has not yet reviewed against the paper. A result counts as verified only after that review.
- The aggregate-coupling proposition is checked on the assumption that completing the square (`eq:complete_square`) holds, because the paper does not prove it (first row of the table in section 3).
- The canonical radius theorem is checked as algebra: given the omission curve $\eta_0e^{-2r/\ell_c}$ with $\eta_0=\ell_c/(\ell_c+2\ell_s)$, the radius, the threshold and the comparative statics follow. That this curve is the regret of the field model (the lemma at 857–880 and the derivation at 839–855) is not checked yet.

The composition theorem's proof went through exactly as written: seven sentences, seven lemmas, no added step.

### What is asked of you

| # | Item | Where | Kind of edit |
|---|---|---|---|
| F14 | Aggregate-coupling proof: "subtracting" uses completing the square without citing it; "therefore" hides three steps | main 607–612 | Cite `eq:complete_square`; one sentence |
| F13 | Two-sensor example does not say where independence of the processes is used | main 72–79 | One sentence |
| F12 | Exponential-omission proof: the crossing's existence and the link to $[\cdot]_+$ are unsaid | main 781–785 | Half a sentence |
| F11 | Decrease in $\ell_s$: which pairs of points the statement compares | main 899–906, 913–915 | Confirm only; no edit needed |

### F14 (minor): aggregate-coupling proof

**Where.** Proof of `prop:aggregate_local`, main 591–613.

**Problem.**
1. "Subtracting this cost from the local and constant costs gives [the regrets]" (610–612). Regret is defined as $\tfrac12\mathbb E[(u-x^\star)^\top Q(u-x^\star)]$; turning a difference of expected costs into that needs $f(u,\theta)-f(x^\star,\theta)=\tfrac12(u-x^\star)^\top Q(u-x^\star)$, which is `eq:complete_square`. The sentence does not cite it.
2. "The full-information expected cost is therefore …" (607–609). Between the eigenvalues and that number sit three facts: $f(x^\star,\theta)=-\tfrac12x^{\star\top}Qx^\star$; $x^\star=Q^{-1}\theta$ explicitly (`eq:shared_resource_xstar`, stated at 547–557 without derivation); and $\mathbb E[(\sum_i\theta_i)^2]=n\sigma^2$, which uses independence, zero means and equal variance.
3. In the first display, the cross terms between the means $\mu_i$ and the centered parts vanish because $\mathbb E[\widetilde u_i]=0$, not because of "independence across agents and zero state means" (594–595). Those two reasons are what kill $\mathbb E[\widetilde u_i\widetilde u_j]$ and $\mathbb E[\theta_i\widetilde u_j]$ for $i\ne j$.

**Suggested edit.** At 610: "Subtracting this cost from the local and constant costs, by Eq. `eq:complete_square`, gives …". At 607–609: "Since $f(x^\star,\theta)=-\tfrac12\theta^\top Q^{-1}\theta$ and the $\theta_i$ are uncorrelated with variance $\sigma^2$, the full-information expected cost is $-(\sigma^2/2)\operatorname{tr}Q^{-1}=\dots$". The formal proof gets the same number by splitting $\theta$ along the two eigenspaces; if you write the trace form it will follow that instead.

### F13 (minor): two-sensor example

**Where.** main 72–79.

**Problem.** The hypotheses are all there (independent, mean-zero, stationary processes; the scalar prediction rule). What is missing is where they are used.
1. Line 75–77 gives $\mathbb E[X_t\mid X_{t-\tau}]$, and the next sentence concludes about the best estimate from *both* old readings. That needs $\mathbb E[X_t\mid X_{t-\tau},Y_{t-\tau}]=\mathbb E[X_t\mid X_{t-\tau}]$, which is where independence of the two processes enters. Independence of $X_s$ and $Y_s$ at each single time would not be enough; the text's "the two signal processes are independent" is the right hypothesis.
2. "Our best estimate is …" (72, 77) uses, both times, that the conditional mean has the smallest mean squared error. The appendix proves this (common information, app 271–275); the example does not point there.
3. The error $\operatorname{Var}(Z_t)(1-e^{-2\tau/T})$ (78–79) is asserted. It follows from orthogonality of the prediction error, stationarity and zero means.

**Suggested edit.** After the prediction rule: "Because the processes are independent, the old reading of one does not help predict the other, so the conditional mean of $Z_t$ given both old readings is $e^{-\tau/T}Z_{t-\tau}$." This is an introductory example, so you may judge items 2 and 3 fine as they are.

### F12 (minor): exponential-omission proof

**Where.** Proof of `prop:generic_exponential_radius`, main 774–786; the sentence "It is positive exactly when $\eta_0(1+vT/\ell_c)>1$" at 770–771.

**Problem.**
1. "Otherwise $G$ increases up to its unique crossing" (783–784): that the bracket has a zero is not argued. It does (positive at zero, continuous, negative limit), and the formal proof says so.
2. The proof splits on the sign of the bracket at zero; the boxed formula uses $[\cdot]_+$, and the statement's positivity criterion is in terms of $\eta_0(1+vT/\ell_c)$. The link is $vT\cdot\text{bracket}(0)=\eta_0(1+vT/\ell_c)-1$, which the proof does not write.

**Suggested edit.** At 781: "The bracket decreases strictly to a negative limit, and at zero it has the sign of $\eta_0(1+vT/\ell_c)-1$."

An observation, no edit needed: the hypothesis $\eta_0<1$ is never used. The result holds for every $\eta_0>0$.

### F11 (minor): decrease in $\ell_s$

**Where.** Items at main 899–906; proof at 913–915.

**Question.** "Within the interior regime, $r^\star$ decreases with the spatial correlation length $\ell_s$", proved by $\partial r^\star/\partial\ell_s<0$ in the positive-radius regime. The formal statement as first drafted compared a point in the regime with *every* larger $\ell_s$, including values with $2\ell_s\ge vT$, where $r^\star=0$. The inequality is still true there, but the derivative does not show it. The plan is to restrict the formal statement to pairs that are both in the regime, which is how the sentence reads. Say if you meant the wider claim; it would need "once $2\ell_s\ge vT$ the radius is zero" in the proof.

### Hypotheses the proofs never used (no edit required)

- Composition theorem: beyond $a=e^{-\tau/T}>0$, neither $\tau\ge0$ nor $T>0$ is used.
- Marginal balance: $\tau'\ge0$, $\eta_S'\le0$ and $\eta_S\ge0$ are not used; only continuous differentiability and $\eta_S<1$ are.
- Two-sensor example: $\tau\ge0$ is not used.

### F4, update

The crossover theorem's formal proof needed exactly the sentence proposed under F4 for the case $\eta_S(0)=1$. It is currently the one line of that proof with no counterpart in the paper.

## Working notes

- Line numbers will shift as you edit; that is fine. The ledger stores the proof text and is re-aligned afterwards, as it was for this version.
- Please note which IDs you addressed (F2–F14, or the claim name for section 3) and which you chose to leave, so the ledger can be closed out item by item.
- Where you prefer a different argument from the one suggested, use yours: the formal proof follows whatever the paper says.
