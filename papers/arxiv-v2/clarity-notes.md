# Clarity Additions for "A Theory of Information Architecture for Networked Decisions"

**Purpose.** This file makes Sections 3–5 readable for a senior undergraduate or first-year graduate student without changing any result. It has three parts:

- **Part 0:** global notation fixes.
- **Part 1:** inline additions, in manuscript order, each anchored to an equation or sentence.
- **Part 2:** a new Appendix A (mathematical toolkit).
- **Part 3:** a new Appendix B (glossary table).

**Conventions.**
- Equation numbers refer to the current manuscript.
- **INSERT AFTER / INSERT BEFORE / REPLACE** say where each block goes.
- Math is LaTeX between `$…$` / `$$…$$`, so it can be pasted into the `.tex` source with minor edits.
- New displayed equations are unnumbered unless they are referenced.
- As requested, full proofs stay in the main text (Part 1). The appendix holds only background facts.

---

## Part 0 — Global notation fixes

| Current | Problem | Proposed fix |
|---|---|---|
| $\mathcal T$ (time index set) and $T$ (coherence time) | Visually near-identical | Write the index set as $\mathbb T$. |
| $v$ as a policy in the proof of Theorem 3; $v$ as propagation speed in §5 | Same letter, different objects | Rename the policy in Theorem 3's proof to $\tilde u$ (done in item 4-F below). |
| $\kappa,\lambda$ as inverse lengths in Lemma 3; $\kappa_s$ in (117) | $\kappa$ means two things | In Lemma 3 use $\beta_c \triangleq 1/\ell_c$ and $\beta_s \triangleq 1/\ell_s$ (done in item 5-I). |
| $\eta_0$ and $\eta_S(0)$ | Same quantity, two names, first used before $\eta_S(r)$ exists | Define $\eta_0 \triangleq \eta_S(0)$ once, at (38), with a forward pointer (item 3-C). |
| $R(\mathcal A)$ and $R(r)$ | Overloaded $R$ | At (86) add: "We write $R(r)$ as shorthand for $R(\mathcal A_{r,\tau(r)})$ when the latency law is fixed." |
| $\tau$ (a delay) and $\tau(r)$ (latency law) | Overloaded $\tau$ | At (84) add: "Where a delay is a free parameter we write $\tau$; where it is determined by radius we write $\tau(r)$." |
| $\mathcal G^{(r)}_{i,t}$ in (15) and $\mathcal I^{(r)}_{i,t-\tau}$ in (69)/(71) | Same object, two symbols | Clarify at (69) (item 4-C). |
| $\mathbf 1$ | Never defined | Define at (56) (item 3-N). |

**Additions to Table 1 (notation):** $\mathbf 1$ (all-ones vector); $\eta_0=\eta_S(0)$; $\rho=\tau/T$ (staleness ratio); $\varepsilon_{t,\tau}$ (innovation); $X_t = x^\star_t-\bar x^\star$ (centered decision); $m_T(r)$, $m_S(r)$ (marginal rates); $[z]_+=\max\{z,0\}$.

---

## Part 1 — Inline additions

### Section 2 (supporting items used throughout §§3–5)

#### 2-A. INSERT AFTER (18)

> In plain terms, "$u_i$ is $\mathcal G_i$-measurable" means that $u_i$ is a function of what agent $i$ observes. For example, under $\mathcal G^{\rm loc}_{i,t}=\sigma(\theta_{i,t})$ the admissible rules are exactly the functions $u_i=g(\theta_{i,t})$. (This is the Doob–Dynkin lemma; see Appendix A.1.) Throughout, "information architecture" can be read as "a list saying which variables each agent's decision may depend on."

#### 2-B. INSERT AFTER the proof of Lemma 1

> Two consequences of Lemma 1 are used repeatedly below.
>
> *(i) Pythagorean form of regret.* The optimal error $x^\star_t-u^\star_{\mathcal A}$ is $Q$-orthogonal to every admissible policy, including $u^\star_{\mathcal A}$ itself. Hence
> $$\|x^\star_t\|_Q^2=\|u^\star_{\mathcal A}\|_Q^2+\|x^\star_t-u^\star_{\mathcal A}\|_Q^2,\qquad\text{so}\qquad 2R(\mathcal A)=\|x^\star_t\|_Q^2-\|u^\star_{\mathcal A}\|_Q^2 .$$
> Regret is the part of the full-information decision that the architecture fails to reproduce. It is often easiest to compute by evaluating the optimal policy's own norm and subtracting it.
>
> *(ii) Factor of one-half.* Regret carries the factor $\tfrac12$ from (7). Squared $Q$-norms in proofs therefore appear as $2R$; for example, $\|x^\star_t-\mathbb E x^\star_t\|_Q^2=2R_\infty$.

---

### Section 3

#### 3-A. INSERT at the start of Section 3, before §3.1

> **Roadmap for Sections 3–5.** The three sections build one formula in stages.
> - Section 3 isolates *time*. It compares an architecture that loses nothing to delay (fresh-local) with one that loses nothing to spatial restriction (stale-global).
> - Section 4 adds *space*. It shows that for a delayed neighborhood snapshot, the fraction of the decision that survives the delay and the fraction captured by the neighborhood *multiply* (Theorem 3).
> - Section 5 *optimizes* that product over the neighborhood radius.
>
> Figure 0 shows the timing convention used throughout.
>
> ```
> time ─────────────────────────────────────────────────────────▶
>         t − τ(r₂)              t − τ(r₁)                 t
>            │                       │                      │
>   snapshot of N_{r₂}(i)    snapshot of N_{r₁}(i)    agent i acts: x_{i,t}
>   (wider, older)           (narrower, fresher)      cost depends on θ_t
> ```
> *Figure 0 (suggested; redraw as a proper figure). A radius-$r$ synchronized snapshot is taken at time $t-\tau(r)$ and used for the decision at time $t$. A larger radius sees more nodes but from an earlier time, and the cost is evaluated against the current state $\theta_t$.*
>
> **Which assumptions each result uses.**
>
> | Result | Quadratic cost, deterministic $Q\succ0$ | Stationary | Common-rate innovation (OU or AR(1)) | Affine $x^\star$ | Gaussian | Other |
> |---|---|---|---|---|---|---|
> | Lemma 1, crossover observation (39) | ✓ | — | — | — | — | square-integrable |
> | Lemma 2, Theorems 1–2 | ✓ | ✓ | ✓ | ✓ | — | |
> | Proposition 1 | ✓ | — | — | ✓ | — | independent, mean-zero components |
> | Threshold (62) | ✓ | ✓ | ✓ | ✓ | — | Prop. 1 + Thm. 2 |
> | Theorem 3 | ✓ | ✓ | ✓ | ✓ | — | |
> | Proposition 2 | ✓ | ✓ | ✓ | ✓ | — | $\tau,\eta_S$ differentiable |
> | Lemma 3, Theorem 4 | ✓ ($Q=qI$) | ✓ | ✓ | ✓ | ✓ | exponential field, Laplace kernel, linear delay |

#### 3-B. INSERT AFTER (36)

> The term *open-loop* is borrowed from control, where it describes a controller that does not use measurements. Here it simply means a decision that ignores the state. The best such decision is the mean $\mathbb E[x^\star_t]$. For any constant $c$, the cross term vanishes because $x^\star_t-\mathbb E x^\star_t$ has mean zero and $Q$ is deterministic, so
> $$\|x^\star_t-c\|_Q^2=\|x^\star_t-\mathbb E x^\star_t\|_Q^2+(\mathbb E x^\star_t-c)^\top Q(\mathbb E x^\star_t-c).$$
> The second term is nonnegative and vanishes only at $c=\mathbb E x^\star_t$.

#### 3-C. INSERT AFTER (38)

> Both shares lie in $[0,1]$. They are nonnegative because regret is nonnegative. They are at most one because constant actions are admissible under *every* architecture: each agent can ignore its information and play its component of $\mathbb E[x^\star_t]$. So no architecture can do worse than open loop, and $R(\mathcal A)\le R_\infty$. We abbreviate $\eta_0\triangleq\eta_S(0)$. The argument "$0$" anticipates Section 4, where $\eta_S(r)$ is defined for every radius $r$ and radius zero is the fresh-local architecture.

#### 3-D. REPLACE the sentence "Since all agents share the global snapshot, stale-global regret is one-half the minimum $Q$-weighted mean-square error of predicting $x^\star_t$ from $\theta_{t-\tau}$ (Corollary 1)."

> Under $\mathcal A_{\rm glob}(\tau)$ every agent has the *same* information $\sigma(\theta_{t-\tau})$. When information is common, the team problem collapses to a single-decision-maker problem (see the remark after Corollary 1 and Appendix A.2). The optimal joint policy is then the ordinary conditional expectation $\mathbb E[x^\star_t\mid\theta_{t-\tau}]$, even when $Q$ has off-diagonal blocks. Stale-global regret is therefore one-half the minimum $Q$-weighted mean-square error of predicting the *current* full-information decision from the *old* snapshot:
> $$2R_{\rm glob}(\tau)=\min_{g}\ \big\|x^\star_t-g(\theta_{t-\tau})\big\|_Q^2 .$$

#### 3-E. REPLACE the sentences from "If remote snapshots become uninformative…" through "…the OU formula below shows this explicitly."

> If the old snapshot eventually carries no information about the current decision—precisely, if $\mathbb E[x^\star_t\mid\theta_{t-\tau}]\to\mathbb E[x^\star_t]$ in mean square—then $\eta_T(\tau)\to1$. Standard "mixing" conditions (Appendix B) guarantee this.
>
> One might expect $\eta_T$ to increase with $\tau$ automatically, but information monotonicity (23) does not apply. The older snapshot $\theta_{t-\tau_2}$ is not a function of the newer one $\theta_{t-\tau_1}$, so the σ-algebras are not nested. For a *Markov* environment, monotonicity does hold. Given $\theta_{t-\tau_1}$, the older value $\theta_{t-\tau_2}$ adds nothing about $\theta_t$. Predicting from $\theta_{t-\tau_2}$ alone is therefore no better than predicting from the pair $(\theta_{t-\tau_1},\theta_{t-\tau_2})$, which is exactly as good as predicting from $\theta_{t-\tau_1}$ alone. This is the *data-processing inequality* for prediction error; the OU formula (50) below exhibits the monotonicity explicitly.

#### 3-F. INSERT AFTER (40)

> Readers unfamiliar with stochastic differential equations can read (40) as shorthand for three facts (derived in Appendix A.4), which are all the paper uses:
> 1. $\theta_t$ is a stationary Gaussian process with mean $\bar\theta$ and covariance $\Sigma_\infty$.
> 2. $\operatorname{Cov}(\theta_t,\theta_s)=e^{-|t-s|/T}\Sigma_\infty$.
> 3. For every $\tau>0$ the decomposition (44) below holds, with an explicitly known innovation covariance.
>
> The drift $-(\theta_t-\bar\theta)/T$ pulls the state back toward its mean at rate $1/T$. The noise scale $\sqrt{2/T}$ is chosen exactly so that the stationary covariance equals $\Sigma_\infty$. The key simplification is that the drift is the *scalar* $-1/T$ times the identity. Every component of $\theta$, and every linear combination of components (every "mode"), forgets its past at the same rate $1/T$. A general matrix drift would give different modes different coherence times; Section 8 discusses that case.

#### 3-G. REPLACE the sentence introducing (44) and the sentence after it

> The OU transition law [18, eqs. (8)–(10), (14)] gives the decomposition
> $$\theta_t-\bar\theta=e^{-\rho}(\theta_{t-\tau}-\bar\theta)+\varepsilon_{t,\tau},\qquad \mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]=0,\qquad \operatorname{Cov}(\varepsilon_{t,\tau})=(1-e^{-2\rho})\Sigma_\infty. \tag{44}$$
> We call $\varepsilon_{t,\tau}$ the *innovation*: the part of the current state that cannot be predicted from the state $\tau$ time units earlier. For the OU process it is Gaussian and independent of $\{\theta_s:s\le t-\tau\}$. Its covariance follows from stationarity. The two terms in (44) are uncorrelated, so $\Sigma_\infty=\operatorname{Cov}(\theta_t)=e^{-2\rho}\Sigma_\infty+\operatorname{Cov}(\varepsilon_{t,\tau})$.

#### 3-H. REPLACE the text between (45) and (46), and the sentence after (46)

> Because $x^\star(\theta)=K\theta+Q^{-1}b_0$ is affine, $\bar x^\star=K\bar\theta+Q^{-1}b_0$ and $X_t=K(\theta_t-\bar\theta)$. Applying $K$ to (44) gives
> $$X_t=e^{-\rho}X_{t-\tau}+K\varepsilon_{t,\tau},\qquad K=Q^{-1}B. \tag{46}$$
> We may work with the centered target $X_t$ without loss of generality. If $u$ is admissible, so is $u-\bar x^\star$, since each agent can subtract a known constant. Moreover $(x^\star_t-\bar x^\star)-(u-\bar x^\star)=x^\star_t-u$. The shift $u\mapsto u-\bar x^\star$ is therefore a one-to-one map of the admissible set onto itself that leaves every error unchanged. Note also that $\|X_t\|_Q^2=2R_\infty$ by (36).

#### 3-I. REPLACE the proof of Lemma 2

> *Proof.* Split the error into an "old" part and a "new" part:
> $$X_t-u=\underbrace{\big(e^{-\rho}X_{t-\tau}-u\big)}_{\triangleq\,A,\ \text{a function of }\theta_{t-\tau}}+\ K\varepsilon_{t,\tau}.$$
> *Orthogonality.* Because $A$ is a function of $\theta_{t-\tau}$, the tower property (Appendix A.2) gives
> $$\mathbb E\big[A^\top QK\varepsilon_{t,\tau}\big]=\mathbb E\big[A^\top QK\,\mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]\big]=0 .$$
> By Pythagoras, $\|X_t-u\|_Q^2=\|A\|_Q^2+\|K\varepsilon_{t,\tau}\|_Q^2$.
>
> *Size of the new part.* Setting $u=0$ in this identity gives $\|X_t\|_Q^2=e^{-2\rho}\|X_{t-\tau}\|_Q^2+\|K\varepsilon_{t,\tau}\|_Q^2$. Stationarity gives $\|X_{t-\tau}\|_Q^2=\|X_t\|_Q^2=2R_\infty$. Hence $\|K\varepsilon_{t,\tau}\|_Q^2=(1-e^{-2\rho})\,2R_\infty$.
>
> Equivalently, using (44) directly: $\|K\varepsilon\|_Q^2=\operatorname{tr}\!\big(K^\top QK\operatorname{Cov}\varepsilon\big)=(1-e^{-2\rho})\operatorname{tr}(K^\top QK\Sigma_\infty)=(1-e^{-2\rho})\,2R_\infty$. $\square$

#### 3-J. REPLACE the proof of Theorem 1

> *Proof.* The global snapshot allows any function of $\theta_{t-\tau}$. In particular it allows $u=e^{-\rho}X_{t-\tau}$, which makes the first term in (47) zero. Since that term is nonnegative, this choice is optimal. In uncentered form, the optimal stale-global action is
> $$u^\star_{\rm glob}=\bar x^\star+e^{-\tau/T}\big(x^\star_{t-\tau}-\bar x^\star\big):$$
> the old full-information decision, shrunk toward its mean. Only the innovation term remains, so $2R_{\rm glob}(\tau)=(1-e^{-2\rho})\,2R_\infty$, which is (48).
>
> For (49), use the identity $\mathbb E[Y^\top AY]=\operatorname{tr}(A\operatorname{Cov}Y)$ for mean-zero $Y$ and the cyclic property of the trace (Appendix A.6):
> $$2R_\infty=\mathbb E[X_t^\top QX_t]=\operatorname{tr}\!\big(QK\Sigma_\infty K^\top\big)=\operatorname{tr}\!\big(K^\top QK\,\Sigma_\infty\big),\qquad K^\top QK=B^\top Q^{-1}QQ^{-1}B=B^\top Q^{-1}B. \qquad\square$$

#### 3-K. REPLACE the paragraph "Generality of the innovation argument."

> **Generality of the innovation argument.** The proof uses only three ingredients: stationarity, an affine decision, and a decomposition $\theta_t-\bar\theta=a(\theta_{t-\tau}-\bar\theta)+\varepsilon$ with a *scalar* $a$ and $\mathbb E[\varepsilon\mid\theta_{t-\tau}]=0$. Neither Gaussianity nor full independence of $\varepsilon$ from the past is needed. For example, consider the discrete-time AR(1) process $\theta_k-\bar\theta=a(\theta_{k-1}-\bar\theta)+\varepsilon_k$ with $0<a<1$ and i.i.d. mean-zero innovations. It satisfies the decomposition at lag $k$ with $a^k$ in place of $e^{-\rho}$. Writing $a=e^{-1/T}$, with $T$ measured in time steps, gives $\eta_T(k)=1-a^{2k}=1-e^{-2k/T}$.

#### 3-L. INSERT AFTER (51)

> Here we used $1-e^{-x}=x+O(x^2)$ with $x=2\tau/T$. The notation $o(\tau/T)$ denotes a term that becomes negligible relative to $\tau/T$ as $\tau/T\to0$ (Appendix A.7).

#### 3-M. In Theorem 2: REPLACE "For $\eta_S(0)=1$, define $\rho^\star=+\infty$ in the extended-real sense; …" and INSERT AFTER the proof

> Replacement sentence: *If $\eta_S(0)=1$, we set $\rho^\star=+\infty$: no finite delay makes fresh-local information strictly better.*
>
> Inserted remark: *Why a single threshold?* $R_{\rm loc}$ depends only on the distribution of the state at a single time. It involves neither the delay $\tau$ nor the coherence time $T$, because local information is current. All dependence on staleness is in $R_{\rm glob}(\tau)$, which increases in $\tau$. The comparison is therefore a flat line crossed once by an increasing curve, which is why a unique threshold exists.

#### 3-N. INSERT AFTER (56)

> Here $\mathbf 1\in\mathbb R^n$ is the all-ones vector, so $\mathbf 1\mathbf 1^\top$ is the $n\times n$ all-ones matrix and $\mathbf 1^\top x=\sum_i x_i$. Expanding confirms that (56) matches (55):
> $$\tfrac12x^\top(qI+\gamma\mathbf 1\mathbf 1^\top)x=\tfrac q2\sum_i x_i^2+\tfrac\gamma2\Big(\sum_i x_i\Big)^2 .$$

#### 3-O. REPLACE "The full-information action is" (the line introducing (57))

> The full-information action is $x^\star=Q^{-1}\theta$. The inverse of an "identity plus rank-one" matrix has a closed form (Sherman–Morrison, Appendix A.6):
> $$\big(qI+\gamma\mathbf 1\mathbf 1^\top\big)^{-1}=\frac1q\Big(I-\frac{\gamma}{q+\gamma n}\mathbf 1\mathbf 1^\top\Big),$$
> which can be checked by multiplying out. Applying it to $\theta$ gives

#### 3-P. INSERT AFTER the statement of Proposition 1 (before its proof)

> *Intuition for (58).* Agent $i$ sees only $\theta_i$. Remote states are independent of $\theta_i$ and have mean zero, so agent $i$ expects every other agent's action to be zero on average. Its own action, however, enters the aggregate penalty $\tfrac\gamma2(\sum_j x_j)^2$ directly and adds $\gamma x_i$ to its marginal cost. Its effective stiffness is therefore $q+\gamma$ rather than $q$. The full-information action (57) differs because it also reacts to the realized aggregate $\sum_j\theta_j$, which agent $i$ cannot see.

#### 3-Q. In the proof of Proposition 1: REPLACE the opening and the final paragraph

> Replace the opening with: *Recall the coupled normal equations (30): $Q_{ii}u_i+\sum_{j\neq i}Q_{ij}\,\mathbb E[u_j\mid\mathcal G_i]=\mathbb E[b_i(\theta_t)\mid\mathcal G_i]$. Here $Q_{ii}=q+\gamma$, $Q_{ij}=\gamma$ for $j\neq i$, and $b_i(\theta)=\theta_i$. Let $\mu_j=\mathbb E[u_j]$. …* (then continue as in the current proof).
>
> Replace the final paragraph ("The expressions (59) and (60) follow by substituting…") with:
>
> *Open-loop regret.* Here $B=I$ and $\Sigma_\infty=\sigma^2I$, so by (49), $R_\infty=\tfrac{\sigma^2}2\operatorname{tr}(Q^{-1})$. From the Sherman–Morrison formula above,
> $$\operatorname{tr}(Q^{-1})=\frac1q\Big(n-\frac{\gamma n}{q+\gamma n}\Big)=\frac{n\,(q+\gamma(n-1))}{q\,(q+\gamma n)},$$
> which gives (59).
>
> *Local regret.* By the Pythagorean form of Lemma 1 (item 2-B, with both $x^\star$ and $u^{\rm loc}$ mean zero), $2R_{\rm loc}=\|x^\star\|_Q^2-\|u^{\rm loc}\|_Q^2=2R_\infty-\|u^{\rm loc}\|_Q^2$. Since $u^{\rm loc}=\theta/(q+\gamma)$ and $\operatorname{tr}(Q)=n(q+\gamma)$,
> $$\|u^{\rm loc}\|_Q^2=\frac{\sigma^2\operatorname{tr}(Q)}{(q+\gamma)^2}=\frac{n\sigma^2}{q+\gamma}.$$
> Therefore
> $$R_{\rm loc}=\frac{n\sigma^2}{2}\left[\frac{q+\gamma(n-1)}{q(q+\gamma n)}-\frac{1}{q+\gamma}\right]=\frac{n\sigma^2}{2}\cdot\frac{(q+\gamma(n-1))(q+\gamma)-q(q+\gamma n)}{q(q+\gamma)(q+\gamma n)} .$$
> The numerator reduces to $\gamma^2(n-1)$, which gives (60).
>
> *Share.* Dividing (60) by (59), the factors $n\sigma^2/2$ and $q(q+\gamma n)$ cancel, leaving (61). $\square$

#### 3-R. INSERT BEFORE (62)

> From (61),
> $$1-\eta_S(0)=\frac{(q+\gamma)(q+\gamma(n-1))-\gamma^2(n-1)}{(q+\gamma)(q+\gamma(n-1))}=\frac{q\,(q+\gamma n)}{(q+\gamma)(q+\gamma(n-1))},$$
> because the numerator expands to $q^2+q\gamma(n-1)+q\gamma=q(q+\gamma n)$. Substituting into (53) gives

#### 3-S. INSERT AFTER (64)

> To see the limit, write the ratio in (62) as $\frac{q+\gamma}{q}\cdot\frac{q+\gamma(n-1)}{q+\gamma n}$; the second factor tends to one. Equivalently, (61) gives $\eta_S(0)\to\gamma/(q+\gamma)$. In a large system, local information explains the share $q/(q+\gamma)$ of decision variance. It misses the share $\gamma/(q+\gamma)$ driven by the aggregate, which only nonlocal information can supply.

#### 3-T. INSERT AFTER (65)

> The label "value of coordination" is interpretive, not a separate result. $\tfrac12\log(1+\gamma/q)$ is the staleness at which a global snapshot's temporal loss equals $\gamma/(q+\gamma)$, the large-$n$ share of decision variance that only global information can provide.

---

### Section 4

#### 4-A. INSERT AFTER (67)

> The kernel in (67) is the same exponential that describes the OU process in time (68), now applied in space. On a line this is more than an analogy. A Gaussian field with covariance $\sigma^2e^{-|z-z'|/\ell_s}$ *is* a stationary OU process indexed by position $z$, and it therefore has the **spatial Markov property**: given the value at a point $z_0$, the field to the left of $z_0$ and the field to the right are independent. As a consequence, observing a segment tells you about the field outside it only through the segment's nearest endpoint. Lemma 3 relies on exactly this. On general graphs the analogous objects are Gaussian Markov random fields (Appendix A.5).

#### 4-B. INSERT AFTER (68)

> A space–time covariance is *separable* if it factors as (a function of time lag) × (a spatial covariance), as in (68). Separability means spatial patterns keep their shape as they decorrelate in time. Many physical fields are *nonseparable*: for example, large-scale patterns may persist longer than small-scale ones [20]. Section 8 discusses the consequences.

#### 4-C. INSERT AFTER (69)

> $\mathcal I^{(r)}_{i,t}$ is the σ-algebra $\mathcal G^{(r)}_{i,t}$ of (15) with the delay set to zero. We use a separate symbol because, in this section, the delay $\tau$ is a free parameter rather than the latency law $\tau(r)$. Section 5 reconnects them by setting $\tau=\tau(r)$.

#### 4-D. INSERT AFTER (73)

> Nesting holds because $N_{r_1}(i)\subseteq N_{r_2}(i)$ whenever $r_1\le r_2$, and both snapshots carry the same time stamp. Inequality (74) then follows from information monotonicity (23).

#### 4-E. REPLACE the word-equation (80) and the two sentences after it

> The function $\eta_S(r)$ therefore depends on four ingredients at once: (i) the state covariance $\Sigma_S$; (ii) the decision-sensitivity operator $K$; (iii) the cost metric $Q$; and (iv) the observation geometry $\{N_r(i)\}$.
>
> A spatial correlation length alone does not determine regret. By a *mode* we mean a direction $\xi$ in state space—a spatial pattern of variation, such as an eigenvector of $\Sigma_S$. A pattern in the null space of $K$ ($K\xi=0$) changes the state without changing the desired decision, so failing to observe it costs nothing. Conversely, a pattern with large $\|K\xi\|_Q$ is amplified into the decision, so even small residual uncertainty about it can dominate regret. Experiment 5 illustrates this dependence with the covariance held fixed.

#### 4-F. REPLACE the proof of Theorem 3

> *Proof.* **Step 1 (centering).** As in Section 3.2, subtract $\bar x^\star$ from the target and from each admissible policy. This preserves admissibility and leaves every error unchanged.
>
> **Step 2 (reduce to Lemma 2).** Under $\mathcal A_{r,\tau}$, agent $i$'s policy is a function of $\{\theta_{j,t-\tau}:j\in N_r(i)\}$, a subset of $\theta_{t-\tau}$. The joint policy $u$ is therefore a function of $\theta_{t-\tau}$, and Lemma 2 applies:
> $$\|X_t-u\|_Q^2=\|e^{-\rho}X_{t-\tau}-u\|_Q^2+(1-e^{-2\rho})\,2R_\infty .$$
> The second term does not depend on $u$, so only the first term is minimized.
>
> **Step 3 (rescale).** Write $u=e^{-\rho}\tilde u$. The admissible set is a linear subspace and $e^{-\rho}\neq0$. Hence $u$ is admissible exactly when $\tilde u$ is, and $\tilde u_i$ depends on the same variables as $u_i$. Then
> $$\|e^{-\rho}X_{t-\tau}-e^{-\rho}\tilde u\|_Q^2=e^{-2\rho}\,\|X_{t-\tau}-\tilde u\|_Q^2 .$$
>
> **Step 4 (stationarity).** Minimizing $\|X_{t-\tau}-\tilde u\|_Q^2$ over $\tilde u$ is precisely the zero-delay radius-$r$ problem posed at time $t-\tau$: predict the decision at $t-\tau$ from neighborhood data at $t-\tau$. By stationarity its minimum equals the same problem's minimum at time $t$, namely $2R(\mathcal A_{r,0})$.
>
> **Step 5 (combine).** $2R(\mathcal A_{r,\tau})=e^{-2\rho}\,2R(\mathcal A_{r,0})+(1-e^{-2\rho})\,2R_\infty$. Dividing by two gives (81); dividing further by $R_\infty$ gives (82)–(83). $\square$

#### 4-G. INSERT AFTER (83)

> **Explained shares multiply.** Subtracting (83) from one gives the cleanest reading of the composition law:
> $$1-\eta_{ST}(r,\tau)=\big(1-\eta_T(\tau)\big)\big(1-\eta_S(r)\big)=e^{-2\tau/T}\big(1-\eta_S(r)\big).$$
> The share of the decision that a delayed snapshot explains is the share that survives the delay times the share its spatial scope captures. Temporal and spatial losses do not simply add; the retained shares multiply. Section 5 optimizes exactly this product.

#### 4-H. REPLACE the paragraph "Generality of the composition law."

> **Generality of the composition law.** The proof of (81) uses only the conditionally mean-zero, common-rate innovation of Lemma 2; Gaussianity is not needed. Gaussianity is needed only to *compute* $\eta_S(r)$ from covariances. For jointly Gaussian variables, the conditional mean is linear and the conditional covariance is a Schur complement (Appendix A.3). In the canonical model and Experiments 5–6, the cost matrix is $Q=qI$ or $I$, so there is no action coupling and each agent's optimal policy is simply its own conditional mean $\mathbb E[x^\star_i\mid\mathcal G_i]$. When $Q$ has off-diagonal blocks, (81) still holds, but $\eta_S(r)$ must be computed from the *joint* team solution of the coupled normal equations (30) rather than agent by agent.

---

### Section 5

#### 5-A. REPLACE the sentence "By information monotonicity (23), nested information cannot produce a strict interior minimum without an explicit acquisition cost."

> Why is an interior optimum possible at all? If the radius family were *nested*—if a larger radius always provided everything a smaller one did, at the same age—then by (23) regret could only decrease with radius, and the best choice would always be the largest radius. An interior optimum would then require charging explicitly for information. The synchronized-snapshot family avoids this because it is *not* nested. At radius $r_2>r_1$, agent $i$ gives up the fresher values $\theta_{j,t-\tau(r_1)}$, $j\in N_{r_1}(i)$, in exchange for older values over a wider neighborhood.

#### 5-B. INSERT AFTER "Rounding the continuous optimum to a neighboring integer is justified only when the interpolated regret curve is unimodal."

> *Unimodal* means that the curve decreases up to a single minimum and increases after it. In that case the best integer radius is one of the two integers bracketing the continuous optimum $r^\star$, so it suffices to compare $R(\lfloor r^\star\rfloor)$ and $R(\lceil r^\star\rceil)$. If the curve has several local minima, the best integer can lie in a different valley altogether.

#### 5-C. INSERT AFTER (89)

> Inequality (89) is (88) with logarithms taken of both sides and the terms rearranged. If $1-\eta_S(r)=0$ (radius $r$ explains nothing), the logarithm is undefined. Condition (88) then simply says that moving to $r+1$ helps if and only if $1-\eta_S(r+1)>0$.

#### 5-D. INSERT BEFORE (95)

> The marginal rates below come from the multiplicative structure of Section 4 (item 4-G). Minimizing $R(r)$ is equivalent to maximizing the explained share $E(r)\triangleq e^{-2\tau(r)/T}\big(1-\eta_S(r)\big)$, and hence its logarithm:
> $$\log E(r)=\log\big(1-\eta_S(r)\big)-\frac{2\tau(r)}{T}.$$
> The two terms are a spatial gain and a temporal penalty. Their radius-derivatives are the two rates defined next. Both have units of 1/length and can be read as "percent change per unit radius."

#### 5-E. INSERT AFTER the proof of Proposition 2, and REPLACE the following paragraph ("If $m_S$ is strictly decreasing … break uniqueness.")

> Inserted note: *Condition (99) is a first-order necessary condition. It identifies candidate radii; whether a candidate is the minimum depends on the shape of $m_S-m_T$, discussed next.*
>
> Replacement paragraph:
>
> **When is the balance point the unique optimum?** Let $\Delta(r)\triangleq m_S(r)-m_T(r)$. By (98), $R'(r)$ has the sign of $-\Delta(r)$: regret falls where the spatial gain rate exceeds the freshness-loss rate, and rises where it does not.
>
> Suppose $m_S$ is strictly decreasing (each extra unit of radius adds proportionally less) and $m_T$ is nondecreasing (each extra unit of radius costs at least as much freshness). Then $\Delta$ is strictly decreasing and crosses zero at most once, so $R$ is unimodal. There are three cases:
> - the optimum is $r^\star=0$ if $\Delta(0)\le0$;
> - it is $r^\star=D$ if $\Delta(D)\ge0$;
> - otherwise it is the unique crossing.
>
> *Comparative statics follow from shifting the curves.*
> - Increasing $T$ lowers $m_T=2\tau'/T$ pointwise, which raises $\Delta$ pointwise. A decreasing function that is raised crosses zero later, so $r^\star$ moves outward (weakly).
> - Scaling latency up, $\tau\mapsto c\,\tau$ with $c>1$, raises $m_T$ and moves $r^\star$ inward.
> - Raising $m_S$ pointwise moves $r^\star$ outward; lowering it moves $r^\star$ inward.
>
> The conditions on $m_S$ concern decision-relevant predictability. They are not automatic consequences of changing raw covariance parameters. If the latency law is concave (for example, latency that grows quickly for the first few hops and then levels off), $m_T$ decreases in $r$, $\Delta$ need not be monotone, and multiple local optima can occur.
>
> *Figure 5.1 (suggested).* Plot $m_S(r)$ (decreasing) and $m_T(r)$ (flat, for linear latency) against $r$ for the canonical model of §5.2, with the crossing marked $r^\star$. Add two more horizontal $m_T$ lines for larger and smaller $L_T$ to show $r^\star$ moving. Mark the region $m_S>m_T$ "expand radius" and $m_S<m_T$ "shrink radius."

#### 5-F. INSERT AFTER "This is also the continuum approximation of a sufficiently long path graph away from its boundaries."

> Formally, the observation σ-algebra (104) is generated by uncountably many values. Because the exponential-covariance field has continuous sample paths, it is generated equally well by the values at countably many points (for example, rational locations), so all conditional expectations below are well defined. Nothing in the argument depends on this technicality.

#### 5-G. INSERT AFTER (102)

> $w_{\ell_c}$ is the Laplace (two-sided exponential) density: it integrates to one, so $x^\star(z,t)$ is a weighted average of the field around $z$. The weight falls by a factor $e$ for each $\ell_c$ of distance, and the average distance $\mathbb E|u|$ under this weight equals $\ell_c$.

#### 5-H. REPLACE the paragraph beginning "We measure regret per unit length…" through "…general composition law or Proposition 2."

> In this canonical model, all nonlocal dependence enters through the *target*, not through interaction between actions. The pointwise cost (103) has no cross terms between $x(z)$ and $x(z')$; this is the continuum analogue of a diagonal $Q=qI$. The linear term is $b(\theta)(z)=q\,x^\star(z,\theta)$, which depends on the field over a range of order $\ell_c$. Each location's optimal policy is therefore just its own conditional mean, $\mathbb E[x^\star(z,t)\mid\text{information at }z]$.
>
> Because the line is infinite, total regret is infinite. We therefore measure regret *per unit length*, which by stationarity equals the expected pointwise loss at any single location $z$. With this convention, $R_\infty=(q/2)\operatorname{Var}(x^\star(z,t))$. Direct action coupling would change the form of $\eta_S(r)$, but not the composition law (81) or Proposition 2.

#### 5-I. REPLACE the proof of Lemma 3

> *Proof.* By spatial stationarity, take $z=0$ and suppress the time argument. Write $\beta_c\triangleq1/\ell_c$ and $\beta_s\triangleq1/\ell_s$ for the inverse lengths, so $w(u)=\tfrac{\beta_c}{2}e^{-\beta_c|u|}$ and $\operatorname{Cov}(\theta(u),\theta(u'))=\sigma^2e^{-\beta_s|u-u'|}$.
>
> **Step 0 (omission is a variance ratio).** With $Q=qI$ the optimal policy given $\mathcal O_r$ is $\mathbb E[x^\star(0)\mid\mathcal O_r]$. Its expected loss is $\tfrac q2\,\mathbb E\big[\operatorname{Var}(x^\star(0)\mid\mathcal O_r)\big]$. For a Gaussian field the conditional variance is a deterministic number: it does not depend on the observed values (Appendix A.3). Since $R_\infty=\tfrac q2\operatorname{Var}(x^\star(0))$,
> $$\eta_S(r)=\frac{\operatorname{Var}(x^\star(0)\mid\mathcal O_r)}{\operatorname{Var}(x^\star(0))}.$$
>
> **Step 1 (split into observed middle and two tails).** Write $x^\star(0)=M_r+T_r^++T_r^-$, where
> $$M_r=\int_{-r}^{r}w(u)\theta(u)\,du,\qquad T_r^+=\int_r^\infty w(u)\theta(u)\,du,\qquad T_r^-=\int_{-\infty}^{-r}w(u)\theta(u)\,du .$$
> The middle $M_r$ is computed from observed values, so it contributes no conditional variance.
>
> **Step 2 (rewrite the right tail).** Substituting $u=r+s$,
> $$T_r^+=\frac{\beta_c}{2}e^{-\beta_c r}\,Y_r,\qquad Y_r\triangleq\int_0^\infty e^{-\beta_c s}\,\theta(r+s)\,ds .$$
>
> **Step 3 (spatial Markov property).** By item 4-A, the field is Markov in $z$. Given the observed segment $[-r,r]$, the right tail $\{\theta(u):u>r\}$ and the left tail $\{\theta(u):u<-r\}$ are conditionally independent, and each depends on the segment only through its adjacent endpoint $\theta(r)$ or $\theta(-r)$. Therefore
> $$\operatorname{Var}(T_r^+\mid\mathcal O_r)=\operatorname{Var}(T_r^+\mid\theta(r)),\qquad \operatorname{Var}(T_r^-\mid\mathcal O_r)=\operatorname{Var}(T_r^-\mid\theta(-r)),\qquad \operatorname{Cov}(T_r^+,T_r^-\mid\mathcal O_r)=0 .$$
>
> **Step 4 (the tail variance does not depend on $r$).** Define $C\triangleq\operatorname{Var}(Y_0\mid\theta(0))$. Shifting the field by $r$ does not change its law, so $\operatorname{Var}(Y_r\mid\theta(r))=C$ for every $r$. By reflection symmetry (the covariance depends only on $|u-u'|$), the left tail gives the same value. Hence
> $$\operatorname{Var}(x^\star(0)\mid\mathcal O_r)=2\Big(\frac{\beta_c}{2}\Big)^2e^{-2\beta_c r}\,C=\frac{\beta_c^2}{2}e^{-2\beta_c r}\,C .$$
> At $r=0$ the same argument applies with $\mathcal O_0=\sigma(\theta(0))$ and $M_0=0$, giving $\operatorname{Var}(x^\star(0)\mid\theta(0))=\tfrac{\beta_c^2}{2}C$. Dividing, $\eta_S(r)=\eta_S(0)\,e^{-2\beta_c r}=\eta_S(0)\,e^{-2r/\ell_c}$. The unknown constant $C$ cancels, so it never has to be computed.
>
> **Step 5 (the constant $\eta_S(0)$).** Conditioning on the single Gaussian variable $\theta(0)$ gives $\operatorname{Var}(x^\star(0)\mid\theta(0))=\operatorname{Var}(x^\star(0))\big(1-\operatorname{Corr}(x^\star(0),\theta(0))^2\big)$ (Appendix A.3), so $\eta_S(0)=1-\operatorname{Corr}^2$. Two moments are needed.
>
> *Covariance with the local value:*
> $$\operatorname{Cov}(x^\star(0),\theta(0))=\int_{\mathbb R}w(u)\,\sigma^2e^{-\beta_s|u|}\,du=\frac{\sigma^2\beta_c}{2}\int_{\mathbb R}e^{-(\beta_c+\beta_s)|u|}\,du=\frac{\sigma^2\beta_c}{\beta_c+\beta_s}.$$
>
> *Variance of the target:* $\operatorname{Var}(x^\star(0))=\frac{\sigma^2\beta_c^2}{4}\,I$, where $I\triangleq\iint e^{-\beta_c(|u|+|v|)-\beta_s|u-v|}\,du\,dv$.
>
> To evaluate $I$, define the inner integral $h(u)\triangleq\int_{\mathbb R}e^{-\beta_c|v|}e^{-\beta_s|u-v|}\,dv$. Then $h$ is even, so $I=2\int_0^\infty e^{-\beta_c u}h(u)\,du$. For $u\ge0$, split the $v$-integral at $0$ and $u$:
> $$h(u)=\underbrace{\frac{e^{-\beta_s u}}{\beta_c+\beta_s}}_{v<0}+\underbrace{\frac{e^{-\beta_c u}-e^{-\beta_s u}}{\beta_s-\beta_c}}_{0\le v\le u}+\underbrace{\frac{e^{-\beta_c u}}{\beta_c+\beta_s}}_{v>u}.$$
> (The middle term is read as $u\,e^{-\beta_c u}$ when $\beta_s=\beta_c$.) Multiply by $e^{-\beta_c u}$ and integrate over $u\ge0$ term by term:
> $$\frac{1}{(\beta_c+\beta_s)^2},\qquad \frac{1}{\beta_s-\beta_c}\Big(\frac{1}{2\beta_c}-\frac{1}{\beta_c+\beta_s}\Big)=\frac{1}{2\beta_c(\beta_c+\beta_s)},\qquad \frac{1}{2\beta_c(\beta_c+\beta_s)} .$$
> Summing and doubling,
> $$I=2\left[\frac{1}{(\beta_c+\beta_s)^2}+\frac{1}{\beta_c(\beta_c+\beta_s)}\right]=\frac{2(2\beta_c+\beta_s)}{\beta_c(\beta_c+\beta_s)^2},\qquad \operatorname{Var}(x^\star(0))=\frac{\sigma^2\beta_c(2\beta_c+\beta_s)}{2(\beta_c+\beta_s)^2}. \tag{107}$$
>
> *Combine.* With $\operatorname{Var}(\theta(0))=\sigma^2$,
> $$\operatorname{Corr}^2=\frac{\big(\sigma^2\beta_c/(\beta_c+\beta_s)\big)^2}{\sigma^2\cdot\sigma^2\beta_c(2\beta_c+\beta_s)/\big(2(\beta_c+\beta_s)^2\big)}=\frac{2\beta_c}{2\beta_c+\beta_s},\qquad \eta_S(0)=\frac{\beta_s}{2\beta_c+\beta_s}=\frac{\ell_c}{\ell_c+2\ell_s}. \qquad\square$$
>
> *(Optional footnote.)* $I$ can also be computed in the frequency domain as $\frac1{2\pi}\int|\hat f(\omega)|^2\hat k(\omega)\,d\omega$, with $\hat f(\omega)=2\beta_c/(\beta_c^2+\omega^2)$ and $\hat k(\omega)=2\beta_s/(\beta_s^2+\omega^2)$. The direct route above avoids contour integration.

#### 5-J. Theorem 4 and its proof: four insertions

> **(a) INSERT at the start of the proof:** *With $\tau(r)=r/v$ we have $2\tau(r)/T=2r/L_T$. Substituting this and $\eta_S(r)=\eta_0e^{-2r/\ell_c}$ into (87) gives*
> $$\frac{R(r)}{R_\infty}=1-e^{-2r/L_T}\big(1-\eta_0e^{-2r/\ell_c}\big)=1-g(r),$$
> *so minimizing $R$ is the same as maximizing $g$.*
>
> **(b) INSERT BEFORE (113):** *Setting the bracket in $g'(r)$ to zero gives $e^{2r/\ell_c}=\eta_0\,L_T\big(\tfrac1{L_T}+\tfrac1{\ell_c}\big)=\eta_0\big(1+\tfrac{L_T}{\ell_c}\big)$. Taking logarithms gives the stationary point below. It is positive exactly when $\eta_0(1+L_T/\ell_c)>1$. Substituting $\eta_0=\ell_c/(\ell_c+2\ell_s)$ turns this product into $(\ell_c+L_T)/(\ell_c+2\ell_s)$, which exceeds one exactly when $L_T>2\ell_s$; this is (112).*
>
> **(c) REPLACE** "The cap restricts observation radius on the same infinite-line model; it does not turn that model into a finite graph." **with:** *The cap $D$ limits how far each agent may look, but the environment remains an infinite line. In particular $\eta_S(D)=\eta_0e^{-2D/\ell_c}>0$. Unlike the finite-graph endpoint $r=\operatorname{diam}(G)$, the capped radius still omits decision-relevant state (compare Figure 3, right panel).*
>
> **(d) REPLACE** "Finally, when $L_T>2\ell_s$," (the lead-in to (115)) **with:** *Finally, monotonicity in $\ell_c$ is not obvious from (111), because $\ell_c$ appears both as the prefactor and inside the logarithm. To separate the two, write the difference of logarithms as an integral, $\log(\ell_c+L_T)-\log(\ell_c+2\ell_s)=\int_{2\ell_s}^{L_T}\frac{ds}{\ell_c+s}$. When $L_T>2\ell_s$ this gives*
>
> *and after (115) add:* *The integrand $\ell_c/(\ell_c+s)=1-s/(\ell_c+s)$ increases with $\ell_c$ for every $s>0$.*

#### 5-K. REPLACE the paragraph "Three consequences clarify how these lengths determine the optimum. …"

> Three consequences clarify how these lengths determine the optimum.
>
> **(1) The threshold does not depend on $\ell_c$.** At radius zero, using $\eta_S'(r)=-(2/\ell_c)\eta_S(r)$ and $\eta_0/(1-\eta_0)=\ell_c/(2\ell_s)$,
> $$m_S(0)=\frac{2}{\ell_c}\cdot\frac{\eta_0}{1-\eta_0}=\frac{1}{\ell_s},\qquad m_T=\frac{2}{L_T}.$$
> The first increment of radius pays off exactly when $1/\ell_s>2/L_T$, that is, $L_T>2\ell_s$. The decision range $\ell_c$ cancels because it has two offsetting effects at $r=0$. A longer decision range makes the local observation less complete (larger $\eta_0$), which raises the value of looking farther. But it also makes omission decay more slowly with radius (rate $2/\ell_c$), which lowers the value of each extra unit of radius.
>
> **(2) Long decision range**, $\ell_c\gg L_T,\ell_s$. Using $\log\frac{1+a}{1+b}=\log(1+a)-\log(1+b)\approx a-b$ for small $a,b$,
> $$r^\star\approx\frac{\ell_c}{2}\Big(\frac{L_T}{\ell_c}-\frac{2\ell_s}{\ell_c}\Big)=\frac{L_T-2\ell_s}{2},$$
> half the excess propagation length.
>
> **(3) Short decision range**, $\ell_c\ll\ell_s,L_T$. Then $\ell_c+L_T\approx L_T$ and $\ell_c+2\ell_s\approx2\ell_s$, so $r^\star\approx(\ell_c/2)\log\big(L_T/(2\ell_s)\big)$ when $L_T>2\ell_s$, and $r^\star=0$ otherwise.

#### 5-L. INSERT AFTER item 5-K

> **Why does stronger spatial correlation shrink the optimal radius?** This can seem backwards: more correlation sounds like it should make neighbors more useful. But $\eta_0=\ell_c/(\ell_c+2\ell_s)$ falls as $\ell_s$ grows. When the field is smooth, the local value $\theta(z)$ already predicts the field well over the whole decision range, so little is left for a wider snapshot to add. Extra radius mostly reports values the agent could already have predicted. Its marginal value $m_S(r)=\frac{2}{\ell_c}\frac{\eta_S(r)}{1-\eta_S(r)}$ is therefore smaller at every radius, while its freshness cost $m_T$ is unchanged, and the balance point moves inward. Correlation makes neighbors informative, but it also makes them redundant with what the agent already knows.

---

## Part 2 — Appendix A: Mathematical Toolkit

*Suggested placement: after the References, as "Appendix A." Each subsection states only what the main text uses.*

### A.1 Information as σ-algebras

- **σ-algebra generated by a variable.** For a random vector $Y$, $\sigma(Y)$ is the collection of all events whose occurrence can be decided by looking at $Y$. It formalizes "what is known if one observes $Y$."
- **Measurability means "a function of".** By the Doob–Dynkin lemma, a random variable $u$ is $\sigma(Y)$-measurable if and only if $u=g(Y)$ for some (measurable) function $g$. So "$u_i$ is $\mathcal G_i$-measurable" means "$u_i$ is computed from agent $i$'s observations."
- **Combining information.** $\sigma(Y)\vee\sigma(Z)=\sigma(Y,Z)$ is the information from observing both.
- **Nesting.** $\mathcal G\subseteq\mathcal G'$ means that whoever knows $\mathcal G'$ knows at least everything in $\mathcal G$. Every $\mathcal G$-measurable rule is then also $\mathcal G'$-measurable.

### A.2 Geometry of square-integrable random vectors

- **The space $L^2$.** Random vectors $u$ with $\mathbb E\|u\|^2<\infty$, with inner product $\langle u,v\rangle_Q=\mathbb E[u^\top Qv]$ for a fixed positive-definite $Q$. This is a Hilbert space: an inner-product space in which limits of Cauchy sequences stay in the space.
- **Projection theorem.** For a closed linear subspace $S$ and any $x$, there is a unique $\Pi x\in S$ closest to $x$. It is characterized by orthogonality: $\langle x-\Pi x,\,s\rangle_Q=0$ for all $s\in S$.
- **Pythagoras.** $\|x\|^2=\|\Pi x\|^2+\|x-\Pi x\|^2$. More generally, for any $s\in S$, $\|x-s\|^2=\|x-\Pi x\|^2+\|\Pi x-s\|^2$.
- **Conditional expectation is a projection.** $\mathbb E[x\mid\mathcal G]$ is the orthogonal projection of $x$ onto $\{\mathcal G\text{-measurable }L^2\text{ variables}\}$. It is therefore the best mean-square predictor of $x$ among *all* functions of the information, not only linear ones.
- **Tower property.** For any $g$, $\mathbb E[g(Y)^\top Z]=\mathbb E\big[g(Y)^\top\mathbb E[Z\mid Y]\big]$. *Consequence:* if $\mathbb E[\varepsilon\mid Y]=0$, then $\varepsilon$ is orthogonal to every function of $Y$. This is the step used in Lemma 2.
- **Common information removes $Q$.** If every component of the policy may depend on the same σ-algebra $\mathcal G$, the $Q$-projection of $x$ is simply $\mathbb E[x\mid\mathcal G]$, for any positive-definite $Q$. The error $e=x-\mathbb E[x\mid\mathcal G]$ satisfies $\mathbb E[s^\top Qe]=\mathbb E\big[s^\top Q\,\mathbb E[e\mid\mathcal G]\big]=0$ for every $\mathcal G$-measurable $s$. With *different* information per agent, this fails and the coupled equations (30) are needed.
- **Mean-square convergence.** $Y_n\to Y$ in $L^2$ means $\mathbb E\|Y_n-Y\|^2\to0$.

### A.3 Gaussian facts

- **Conditioning.** If $(X,Y)$ is jointly Gaussian,
  $$\mathbb E[X\mid Y]=\mu_X+\Sigma_{XY}\Sigma_{YY}^{-1}(Y-\mu_Y),\qquad \operatorname{Cov}(X\mid Y)=\Sigma_{XX}-\Sigma_{XY}\Sigma_{YY}^{-1}\Sigma_{YX}.$$
  The conditional mean is linear in $Y$. The conditional covariance (a *Schur complement*) does **not** depend on the observed value of $Y$.
- **Scalar case.** $\operatorname{Var}(X\mid Y)=\operatorname{Var}(X)\big(1-\operatorname{Corr}(X,Y)^2\big)$.
- **Uncorrelated implies independent** for jointly Gaussian variables. This is used to go from "the innovation has conditional mean zero" to "the innovation is independent of the past" for the OU process.
- **Linear functionals stay Gaussian.** Integrals such as $\int w(u)\theta(u)\,du$ of a Gaussian field are Gaussian, so the facts above apply to $x^\star$ in §5.2.

### A.4 The Ornstein–Uhlenbeck process in time

- **Scalar SDE.** $d\theta_t=-\tfrac1T(\theta_t-\bar\theta)\,dt+\sigma\sqrt{2/T}\,dW_t$, where $W$ is Brownian motion (continuous paths, independent Gaussian increments with variance equal to elapsed time). A useful mental model is the small-step recursion
  $$\theta_{t+\Delta}\approx\theta_t-\tfrac{\Delta}{T}(\theta_t-\bar\theta)+\sigma\sqrt{2\Delta/T}\,Z,\qquad Z\sim N(0,1)\text{ fresh at each step}.$$
- **Solution over a lag $\tau$.**
  $$\theta_t-\bar\theta=e^{-\tau/T}(\theta_{t-\tau}-\bar\theta)+\underbrace{\sigma\sqrt{2/T}\int_{t-\tau}^{t}e^{-(t-s)/T}dW_s}_{\varepsilon_{t,\tau}} .$$
  The innovation is Gaussian with mean zero, independent of the past, and has variance $\sigma^2\tfrac2T\int_0^\tau e^{-2s/T}ds=\sigma^2(1-e^{-2\tau/T})$. This shows why the factor $\sqrt{2/T}$ makes the stationary variance equal $\sigma^2$.
- **Correlation.** In stationarity, $\operatorname{Corr}(\theta_t,\theta_s)=e^{-|t-s|/T}$. The coherence time $T$ is the lag at which correlation falls to $1/e\approx0.37$.
- **Multivariate, common rate (40).** Replace $\sigma$ by $\Sigma_\infty^{1/2}$, the symmetric positive-semidefinite matrix whose square is $\Sigma_\infty$. Every formula above holds with $\sigma^2$ replaced by $\Sigma_\infty$, because the drift $-\tfrac1T I$ treats all directions alike.
- **Markov property.** The future after time $s$ depends on the past only through $\theta_s$.
- **Discrete-time analogue.** AR(1): $\theta_k-\bar\theta=a(\theta_{k-1}-\bar\theta)+\varepsilon_k$, with correlation $a^{|k|}$ at lag $k$.

### A.5 Exponential covariance in space; fields on graphs

- **1-D spatial OU.** A Gaussian field on the line with covariance $\sigma^2e^{-|z-z'|/\ell_s}$ is an OU process in the spatial coordinate. It is Markov in $z$: given $\theta(z_0)$, the field on either side of $z_0$ is conditionally independent of the other side. Given a whole segment, the outside depends only on the nearer endpoint.
- **Gaussian Markov random fields (GMRFs).** On a graph, a Gaussian vector is Markov with respect to the graph when each node, given its neighbors, is independent of all other nodes. Equivalently, the precision matrix $\Sigma^{-1}$ has zeros for non-adjacent pairs.
- **Graph Laplacian.** $L_G=D-A$, where $D$ is the diagonal degree matrix and $A$ the adjacency matrix. For a signal $x$, $x^\top L_Gx=\sum_{(i,j)\in E}(x_i-x_j)^2$ measures roughness. Eigenvectors of $L_G$ with small eigenvalues ("low graph frequencies") vary slowly across edges.
- **Covariance (117).** $\Sigma_S=\sigma^2(\kappa_s^2I+L_G)^{-\nu}$ puts large variance on low-frequency (smooth) patterns. Smaller $\kappa_s$ or larger $\nu$ gives smoother fields.

### A.6 Matrix facts

- **Quadratic-form expectation.** For a random vector $Y$ with mean $\mu$, $\mathbb E[Y^\top AY]=\operatorname{tr}(A\operatorname{Cov}Y)+\mu^\top A\mu$.
- **Cyclic trace.** $\operatorname{tr}(ABC)=\operatorname{tr}(BCA)=\operatorname{tr}(CAB)$ whenever the products are defined.
- **Sherman–Morrison.** For invertible $A$ and vectors $a,c$ with $1+c^\top A^{-1}a\neq0$,
  $$(A+ac^\top)^{-1}=A^{-1}-\frac{A^{-1}ac^\top A^{-1}}{1+c^\top A^{-1}a}.$$
  With $A=qI$ and $a=\gamma\mathbf 1$, $c=\mathbf 1$ this gives $(qI+\gamma\mathbf 1\mathbf 1^\top)^{-1}=\frac1q\big(I-\frac{\gamma}{q+\gamma n}\mathbf 1\mathbf 1^\top\big)$. Also $\operatorname{tr}(qI+\gamma\mathbf 1\mathbf 1^\top)=n(q+\gamma)$.
- **Positive-definite weighting.** $Q\succ0$ means $x^\top Qx>0$ for all $x\neq0$. Then $\lambda_{\min}(Q)\|x\|^2\le x^\top Qx\le\lambda_{\max}(Q)\|x\|^2$, so the $Q$-norm and the ordinary norm are equivalent.
- **Null space and modes.** The null space of $K$ is $\{\xi:K\xi=0\}$. A "mode" of the state is a direction $\xi$, often an eigenvector of $\Sigma_S$. Its contribution to decision variance is governed by $\|K\xi\|_Q$.

### A.7 Calculus, asymptotics, and optimization

- **Log-derivative.** $\frac{d}{dr}\log f(r)=f'(r)/f(r)$ is the *relative* growth rate of $f$, the fractional change per unit $r$. Both $m_S$ and $m_T$ are of this form.
- **First-order conditions.** At an interior minimum of a differentiable function the derivative vanishes. The converse fails: a zero derivative identifies candidates only.
- **Single crossing.** If $\Delta(r)$ is strictly decreasing, it has at most one zero. The function whose derivative has the sign of $-\Delta$ is then unimodal, with its minimum at that zero, or at an endpoint if there is no zero.
- **Continuous relaxation.** Solving an integer problem (radius in hops) by first allowing real values. When the continuous objective is unimodal, the integer optimum is the better of the two integers bracketing the continuous optimum.
- **Taylor approximations used.** $1-e^{-x}\approx x$ and $\log(1+x)\approx x$ for small $x$.
- **Asymptotic notation.** $f=O(g)$ means $|f|\le Cg$ near the limit; $f=o(g)$ means $f/g\to0$.
- **Positive part and extended reals.** $[z]_+=\max\{z,0\}$. Writing $\rho^\star=+\infty$ means that no finite value satisfies the condition.

---

## Part 3 — Appendix B: Glossary

| Term | Meaning in this paper | First use |
|---|---|---|
| Information architecture | Specification of which variables, at which ages, each agent's decision may depend on; formally a tuple of σ-algebras $(\mathcal G_1,\dots,\mathcal G_n)$ | §2.2 |
| σ-algebra $\sigma(Y)$ | "What is known from observing $Y$" | §2.2, A.1 |
| Measurable ($\mathcal G_i$-measurable) | Computable from agent $i$'s information | (18), A.1 |
| Admissible policy | A joint rule in which each agent uses only its own information | (18) |
| Static team | Several decision makers with one shared objective, each acting on its own information, whose actions do not affect anyone's later information | §1, §7.1 |
| Person-by-person (stationarity) conditions | Each agent's rule is optimal given the others' rules; here, equations (29)–(30) | Cor. 1 |
| Full-information (clairvoyant) decision | $x^\star_t=Q^{-1}b(\theta_t)$, optimal with complete current state | (9) |
| Architecture regret | Extra expected cost versus the full-information decision, after optimizing over admissible policies | (21) |
| $Q$-weighted norm | $\|u\|_Q^2=\mathbb E[u^\top Qu]$; the metric in which regret is a squared distance | (25) |
| Projection | Closest point in a subspace; here, the best admissible policy | Lemma 1, A.2 |
| Open-loop | Using no state information; the best constant action | (36) |
| Open-loop regret $R_\infty$ | Regret of the best constant; the normalizer for all shares | (36) |
| Omission share $\eta_S$ | Fraction of decision variance not captured by current information in a given scope | (38), (72) |
| Temporal unpredictability $\eta_T$ | Fraction of decision variance not predictable from a complete snapshot of age $\tau$ | (37) |
| Staleness ratio $\rho$ | $\tau/T$, delay measured in coherence times | (43) |
| Stationary | Statistical properties do not change over time (or space) | (5) |
| Ergodic | Time averages along one realization converge to expectations | §2.3 |
| Square-integrable | Finite second moment, $\mathbb E\|Y\|^2<\infty$ | (5) |
| Gauss–Markov | Gaussian and Markov; here, the OU process | §3.2 |
| Ornstein–Uhlenbeck (OU) process | Stationary Gaussian Markov process that reverts to its mean with exponential correlation | (40), A.4 |
| Coherence time $T$ | Time lag at which correlation falls to $1/e$ | (40) |
| Common-rate model | All components and modes decorrelate with the same time constant $T$ | §1, (40) |
| Innovation | Part of the current state not predictable from an earlier snapshot | (44) |
| Mixing | The dependence between the distant past and the present vanishes as the gap grows | §3.1 |
| Data-processing inequality | Processing or aging information along a Markov chain cannot improve prediction | §3.1 |
| Nested (architectures) | One architecture's information contains the other's, at every agent | (22), (73) |
| Synchronized snapshot | All observations used in a decision share one time stamp | §2.2 |
| Mode | A direction or spatial pattern in state space, often an eigenvector of $\Sigma_S$ | §4.4 |
| Null space of $K$ | State directions that do not change the desired decision | §4.4, A.6 |
| Decision-sensitivity operator $K$ | $Q^{-1}B$; maps state to desired action | (10) |
| Separable covariance | Space–time covariance that factors into a time part times a space part | (68) |
| Spatial correlation length $\ell_s$ | Distance over which the state stays correlated | (67) |
| Decision-relevance length $\ell_c$ | Distance over which remote state affects the desired local action | (101) |
| Temporal propagation length $L_T$ | $vT$: how far information travels in one coherence time | (109) |
| Spatial Markov property | Given the field at a point, the two sides are independent | §4.1, A.5 |
| Gaussian Markov random field | Gaussian vector with graph-based conditional independence | A.5 |
| Graph Laplacian $L_G$ | $D-A$; measures roughness of signals on a graph | (117), A.5 |
| Graph frequency | Eigenvalue of $L_G$; low values correspond to smooth patterns | §7.5, A.5 |
| Continuous relaxation | Treating the integer radius as a real number | §5 |
| Unimodal | Decreasing, then increasing; a single minimum | §5 |
| Marginal balance | Optimal radius where the spatial gain rate equals the freshness-loss rate | (99) |
| Comparative statics | How the optimum moves when a parameter changes | Thm. 4 |
| Extended reals | Real numbers together with $\pm\infty$ | Thm. 2 |
| Age of Information (AoI) | Time since the freshest received update was generated | §7.3 |
| Witsenhausen's counterexample | Classic example in which actions that also signal information break linear/projection solutions | §1, §8 |

