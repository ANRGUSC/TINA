# Major revision: simplify the exposition without narrowing the main results

## Implementation brief

**Project:** `ANRGUSC/TINA`, the current arXiv-v2 manuscript.

**Task:** Implement the substantial accessibility revision described below. This is an implementation specification, not a request for another proposal. Preserve the paper's principal results, their supported generality, and the numerical evidence while making the main argument accessible to a first-year PhD student familiar with linear algebra, conditional expectation, variance, and calculus.

**Basis and precedence:** This document revises the supplied `accessibility-plan.md` and incorporates the author's subsequent decisions. It supersedes that plan where they differ. In particular, the author does **not** approve a Gaussian-only main exposition. The instructions below are self-contained; do not rely on access to the surrounding chat.

**Central editorial decision:** Remove unnecessary mathematical prerequisites from the route to the results. Do not remove the assumptions, derivations, or generality that make the results valid.

Use the latest working manuscript, not an older revision h copy if subsequent changes exist. Preserve unrelated work. Do not submit to arXiv, change publication metadata gratuitously, or push/merge changes unless separately authorized.

## 1. Decisions already made

| Item in the accessibility proposal | Revised implementation decision |
| --- | --- |
| 4.1: Remove projection machinery from the body | Adopt. Define observations, admissible rules, and regret concretely. Retain the general formulation, projection theorem, and coupled optimality conditions in an appendix bundled with the submission. Do not simply delete their only proofs. |
| 4.2: Generic exponential-omission radius result first | Adopt. Follow it with a prominent numbered canonical three-length result and its physical interpretation. Preserve the derivation of the omission curve in the technical appendix. |
| 4.3: Remove the temporal SDE | Adopt. Replace the main-line SDE with a conditional-mean transition, not a covariance-only assumption. Keep the familiar OU/Gauss-Markov identification as an optional special-case reference. |
| 4.4: Composition law before endpoint results | Adopt. Keep the introductory two-sensor example first, then state/prove the composition law and immediately derive the stale-global and crossover consequences. |
| 4.5: Gaussian-only standing model | Reject this restriction. Keep the main temporal theorem non-Gaussian and valid for all admissible rules. Center known means, simplify notation, and use tracking loss without narrowing to independent actions or scalar-only generality. |
| 4.6: Reduce notation | Adopt selectively. Keep notation used in the retained figures and the useful dimensionless ratio of delay to coherence time. Do not introduce a new symbol for every normalized quantity. |
| 4.7: Relocate qualifications | Adopt selectively. Keep the synchronized-snapshot restriction, result-specific assumptions, global-versus-local optimality distinction, radius cap interpretation, and finite-graph search rule visible in the body. |

Do not add new research claims, an age-profile law, mixed-age results, or new experiments. Do not import unreviewed results from another branch. This revision changes presentation and organization; it does not claim stronger scientific results or a resolution of any previous impact/novelty concern.

## 2. Inspect the working tree before editing

1. Read the repository's applicable `AGENTS.md` and build instructions. Record the baseline commit and relevant existing local changes.
2. Resolve the authoritative manuscript directory. The linked repository used `submissions/arxiv-v2/`; the supplied proposal mentions `papers/arxiv-v2/`. Inspect the actual tracked files and build entry point. Do not create a second manuscript tree to reconcile the names.
3. Read the complete current `main.tex`, the files it includes, the companion source, the build script, and relevant numerical documentation. Identify what is compiled into the main paper versus a separate companion. Filenames alone do not establish this.
4. Inventory the current result statements, assumptions, equation labels, proofs, figures, appendix dependencies, and external-document references. Use semantic labels rather than the proposal's obsolete line numbers or hard-coded figure numbers.
5. Record hashes of retained figure/data assets. Identify whether the previously requested noncanonical-graph experiment has already been restored.
6. Run the baseline build and existing verification checks where available. Record pre-existing failures separately from revision-induced failures.

Do not assume that previous review comments certify the current source. Check the actual statements and dependencies. If a substantive mathematical inconsistency is discovered, document it explicitly; do not silently alter a theorem or numerical result to make the restructuring work.

## 3. Target reading order

Use the following organization, with concise section titles adapted to the manuscript's style:

1. **Introduction:** the scope/freshness problem, the two-sensor example, the synchronized-snapshot scope, the contributions, and a short roadmap.
2. **Model and observations:** network, desired action, coupled tracking loss, observations, direct regret definition, and the non-Gaussian temporal assumption.
3. **How scope and freshness combine:** the main composition theorem, its elementary proof, stale-global regret, the crossover, and the shared-resource coupling example.
4. **Choosing the observation radius:** the finite-graph rule, continuous marginal balance, generic exponential-omission solution, and the canonical three-length corollary.
5. **Numerical illustrations:** retain the existing evidence, including the noncanonical-graph comparison as specified below.
6. **Related work:** preserve substantive content and citations; repair terminology and cross-references only as needed.
7. **Discussion and conclusions:** interpret the findings and state the limits without repeating the entire derivation.
8. **Technical appendices:** general formulation and projection, detailed calculations, and reproducibility information.

The central law organizes the architectural comparisons. Do **not** write that every result follows from it alone: computing the coupling example and deriving the canonical spatial omission curve require additional arguments.

### Introductory two-sensor example

Retain the simple example before the general model. It need not be Gaussian. Use two independent, stationary, zero-mean processes with variance `sigma^2`, satisfying the same scalar conditional-mean prediction rule. The target is their current average.

Keep the fresh-local versus stale-global calculation and the threshold

$$
\frac{\tau}{T}>\frac{\log 2}{2}\approx 0.35.
$$

If it improves the flow, add a compact three-row table. Relative to the best constant estimate, the fractions of achievable benefit captured are:

| Observation | Fraction captured |
| --- | --- |
| One sensor now | $1/2$ |
| Both sensors at age $\tau$ | $a^2$ |
| One sensor at age $\tau$ | $a^2/2$ |

Here $a=e^{-\tau/T}$. Make the baseline clear. If the example uses mean-squared error while the general model uses half a weighted squared error, do not confuse their absolute losses; the normalized fractions and crossover are unchanged.

This example supplies the special-case intuition before the general theorem. Do not turn it into a second lengthy model section or an additional numerical experiment.

## 4. Main model: concrete, compact, and non-Gaussian

### 4.1 State, action, and tracking loss

Use stacked state and action vectors, a fixed decision matrix $K$, and a deterministic symmetric positive-definite cost matrix $Q$:

$$
x_t^\star=K\theta_t,
\qquad
\ell(x,\theta_t)=\frac12(x-K\theta_t)^\top Q(x-K\theta_t).
$$

Explain that $x_t^\star$ is the action preferred with complete current information. Off-diagonal blocks of $Q$ allow agents' actions to interact through their shared cost. $K$ describes how state changes affect the desired action. Neither structure must coincide with the communication graph.

Keep vector-valued local states/actions available without a catalogue of block dimensions. Individual examples may use scalar variables. Do not make scalar-only observations, $Q=I$, or independent state coordinates standing assumptions.

Center known means for the main exposition. State once that this is a change of coordinates, not a substantive zero-mean restriction on the affine model. Preserve the equivalence to the original cost:

$$
f(x,\theta)=\frac12x^\top Qx-b(\theta)^\top x+c(\theta),
\qquad
f(x,\theta)-f(x^\star(\theta),\theta)
=\frac12(x-x^\star(\theta))^\top Q(x-x^\star(\theta)).
$$

For $b(\theta)=B\theta+b_0$, centering the state and desired action gives $K=Q^{-1}B$. Put the full equivalence and non-affine general formulation in the appendix; the body needs only a short explanation and pointer.

State visibly that the environment evolves independently of actions, actions do not affect later observations, and actions are unconstrained Euclidean vectors. This is a repeated static-team problem, not a dynamic control or signaling result.

### 4.2 Observations and admissible rules

Define the information available to agent $i$ as an observation vector, for example

$$
Z_{i,t}^{(r,\tau)}=(\theta_{j,t-\tau}:j\in\mathcal N_r(i)).
$$

An admissible rule is $u_i=g_i(Z_{i,t}^{(r,\tau)})$ with finite second moment. Allow **all** such rules, including nonlinear rules. Do not silently replace the optimization with a best-linear-predictor problem.

Explain the three architectures plainly: current local state; a common complete old state; and a synchronized neighborhood snapshot. Introduce $r$ and $\tau$ separately before later imposing a scope-dependent delay $\tau(r)$.

Keep this restriction in the model, not only in the discussion:

> Widening a synchronized snapshot may replace nearby fresh readings with older readings so that all observations have a common timestamp. An architecture that retains fresh local readings while adding old remote readings is a different architecture. Adding usable information without discarding existing information cannot increase the optimal cost.

A small existing timing diagram may be moved from the companion if it genuinely clarifies this definition. It is not required. Do not add a large new figure or duplicate the same diagram in both places.

### 4.3 Direct definition of regret

Define

$$
R(\mathcal A)=\inf_{\{g_i\}}\frac12\mathbb E[(u-x_t^\star)^\top Q(u-x_t^\star)],
$$

where each $g_i$ uses only agent $i$'s specified observations. This is the best achievable expected excess cost, not the performance of a particular distributed algorithm.

Define the no-information benchmark and fresh spatial omission share:

$$
R_\infty=\frac12\mathbb E[(x_t^\star)^\top Qx_t^\star]
=\frac12\operatorname{tr}(K^\top QK\Sigma_S),
\qquad
\eta_S(r)=\frac{R(\mathcal A_{r,0})}{R_\infty},
$$

with $\Sigma_S=\operatorname{Cov}(\theta_t)$. The best constant action is zero in centered coordinates. Use normalized shares only when $R_\infty>0$.

Explain that $\eta_S(r)$ is the fraction of the no-information decision loss still remaining with a fresh radius-$r$ view. It is not raw state uncertainty. Larger fresh neighborhoods cannot increase it because observations can be ignored.

Do not introduce a probability-space tuple, sigma-algebra tuples, $L^2$ subspaces, or projection operators before the main theorem. Retain a brief attribution to classical static-team theory and an appendix pointer, with the existing appropriate citations.

### 4.4 Temporal assumption required by the main theorem

State a stationary state process with finite second moments and, for every delay being analyzed,

$$
\theta_t=a\theta_{t-\tau}+\varepsilon_{t,\tau},
\qquad a=e^{-\tau/T},\quad T>0,
\qquad
\mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]=0.
$$

In words:

> The best mean prediction of the current state from the complete old state is the old state multiplied by a common decay factor. The remaining disturbance has expected value zero even after the complete old state is known.

The conditioning is on the **whole old state**, not just an agent's observations or one old coordinate. This matters because a decision rule may use any information in its observed neighborhood.

Make these points explicit but brief:

- Gaussianity is not assumed. Independence of the disturbance from the old state is not assumed.
- Spatial dependence is allowed; state coordinates need not be independent.
- The scalar prediction coefficient is common to the state components. Distinct temporal rates are outside this exact factorization unless separately analyzed.
- Stationarity supplies the same one-time state distribution at the two epochs. Equal covariance matrices alone would not justify identifying the optimal errors of arbitrary nonlinear rules.

Delete the SDE from the main argument. A stationary Gaussian OU process is a sufficient special case, not the definition or full scope of the theorem. Preserve an existing discrete-time AR(1) example concisely if useful, with $a^k$ and the corresponding squared coefficient.

Do not replace this assumption by merely $\operatorname{Cov}(\theta_t,\theta_{t-\tau})=a\Sigma_S$. For non-Gaussian states, uncorrelated residuals need not have conditional mean zero, and nonlinear rules can exploit dependence that covariance does not capture.

Do not add an unrestricted "any temporal correlation function" claim. If a short general-coefficient remark is retained, require the same conditional-mean property and stationarity; covariance alone is sufficient for the relevant regression step only under suitable additional conditions such as joint Gaussianity. This optional remark should not become a new research section.

## 5. Main theorem and elementary proof

State the composition law under the non-Gaussian model above, retaining general $Q$ and all admissible rules:

$$
\boxed{R(\mathcal A_{r,\tau})=(1-a^2)R_\infty+a^2R(\mathcal A_{r,0}).}
$$

When $R_\infty>0$, also display

$$
\boxed{1-\frac{R(\mathcal A_{r,\tau})}{R_\infty}
=e^{-2\tau/T}[1-\eta_S(r)].}
$$

Interpret it immediately: the fraction of no-information loss eliminated equals the fraction captured by a fresh neighborhood times the fraction of predictive value surviving the delay.

Keep the proof in the body. It should use expansion, conditional expectation, stationarity, and policy rescaling, not a projection theorem or Gaussian independence argument.

### Required proof structure

1. From the transition, $x_t^\star=a x_{t-\tau}^\star+K\varepsilon_{t,\tau}$.
2. Every joint admissible rule $u$ is a function of the complete old state, although each component uses only its own observations. Expand the squared error. The cross term is zero because

   $$
   \mathbb E[(a x_{t-\tau}^\star-u)^\top QK\varepsilon_{t,\tau}]
   =\mathbb E[(a x_{t-\tau}^\star-u)^\top QK
   \mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]]=0.
   $$

3. Apply the same expansion with $u=0$. Stationarity gives

   $$
   \mathbb E[(K\varepsilon_{t,\tau})^\top Q(K\varepsilon_{t,\tau})]
   =(1-a^2)\mathbb E[(x_t^\star)^\top Qx_t^\star]
   =2(1-a^2)R_\infty.
   $$

4. For finite delay, $a>0$. Write $u=a\widetilde u$. This is a bijection of the admissible rule class: each component uses exactly the same observations and still has finite second moment. Therefore

   $$
   \inf_u\mathbb E[(a x_{t-\tau}^\star-u)^\top Q(a x_{t-\tau}^\star-u)]
   =a^2\inf_{\widetilde u}\mathbb E[(x_{t-\tau}^\star-\widetilde u)^\top Q(x_{t-\tau}^\star-\widetilde u)]
   =2a^2R(\mathcal A_{r,0}).
   $$

   The final equality uses stationarity and the same observation pattern at each epoch.
5. Combine the terms, divide by two, and normalize only when permitted.

This remains valid when $Q$ couples actions. It does not assert that each agent independently takes the conditional mean of its own desired action. State that distinction where useful; separate conditional means generally do not solve a coupled team problem with different observations.

The existing innovation-split lemma may be absorbed into this proof rather than presented as another prerequisite. Preserve its mathematical content and repair all references to its former statement. The unnormalized theorem covers $R_\infty=0$; explain that degenerate case briefly in the appendix instead of dividing by zero.

## 6. Consequences: crossover and decision coupling

### 6.1 Stale-global loss and crossover

Immediately after the composition theorem, set fresh spatial omission to zero for a complete snapshot:

$$
R_{\rm glob}(\tau)=(1-e^{-2\tau/T})R_\infty.
$$

Give this as a short corollary, not a repeated proof. Then keep a prominent numbered fresh-local/stale-global crossover result:

$$
\boxed{\frac{\tau}{T}>\frac12\log\frac{1}{1-\eta_S(0)}}.
$$

For $0\leq\eta_S(0)<1$, this is the condition for fresh-local information to be **strictly** better. Equality means equal regret. Preserve the endpoint interpretations: omission zero gives a zero threshold; omission one gives no finite strict crossover. A short parenthetical or appendix note is sufficient for the latter.

Do not move the non-Gaussian scope of these consequences to an appendix: they inherit it from the main theorem. Retain the decision-weighted interpretation of the benchmark, not a claim that raw-state correlation alone determines the architecture.

### 6.2 Shared-resource example: replace the proof, not the result

Retain the model

$$
f(x,\theta)=\sum_{i=1}^n\left(\frac q2x_i^2-\theta_ix_i\right)
+\frac\gamma2\left(\sum_i x_i\right)^2,
\qquad Q=qI+\gamma\mathbf1\mathbf1^\top,
$$

with $n\geq2$, $q>0$, $\gamma\geq0$, and independent zero-mean states of equal finite variance $\sigma^2>0$. This local-policy calculation is a one-epoch result; it does not itself need a temporal model or Gaussianity. The subsequent temporal crossover uses the common-rate assumption.

Use the elementary mean/centered-part proof. For $u_i=g_i(\theta_i)$, write $u_i=\mu_i+\widetilde u_i$ with $\mathbb E\widetilde u_i=0$. Independence and zero state means give

$$
\mathbb E f=
\sum_i\mathbb E\left[\frac{q+\gamma}{2}\widetilde u_i^2-\theta_i\widetilde u_i\right]
+\frac q2\sum_i\mu_i^2+\frac\gamma2\left(\sum_i\mu_i\right)^2.
$$

The mean terms are minimized at zero. The pointwise optimum of the remaining terms is feasible and has zero mean:

$$
u_i=\frac{\theta_i}{q+\gamma}.
$$

The expected local cost is $-n\sigma^2/[2(q+\gamma)]$. The best constant cost is zero. The eigenvalues of $Q$ are $q+\gamma n$ once and $q$ with multiplicity $n-1$, giving the full-information expected cost $-(\sigma^2/2)\operatorname{tr}(Q^{-1})$.

Preserve the existing exact quantities, relocating routine algebra if helpful:

$$
R_\infty=\frac{n\sigma^2[q+\gamma(n-1)]}{2q(q+\gamma n)},
\qquad
R_{\rm loc}=\frac{n\sigma^2\gamma^2(n-1)}{2q(q+\gamma)(q+\gamma n)},
$$

$$
\eta_S(0)=\frac{\gamma^2(n-1)}{(q+\gamma)[q+\gamma(n-1)]},
\qquad
\rho^\star=\frac12\log\frac{(q+\gamma)[q+\gamma(n-1)]}{q(q+\gamma n)}.
$$

Keep the large-$n$ limit $\rho^\star\to\tfrac12\log(1+\gamma/q)$ and the supported interpretation that stronger action coupling increases the staleness worth tolerating for a global view. If $\rho$ notation is retained here because of the figures, define $\rho=\tau/T$ once.

The general appendix may retain coupled normal equations, but this main-text example should no longer depend on them or on the projection lemma. Consolidate duplicate appendix algebra only after the replacement argument and all formulas have been checked.

## 7. Radius selection: elementary optimization without demoting the spatial result

### 7.1 General radius selection

For a nondecreasing delay function $\tau(r)$ with $\tau(0)=0$, choosing a radius is equivalent to maximizing

$$
[1-\eta_S(r)]e^{-2\tau(r)/T}.
$$

Keep $G(r)$ as a shorthand only if it genuinely improves the following derivation; do not insist on deleting a useful symbol merely to reduce the symbol count.

On a finite graph, one more hop helps exactly when

$$
[1-\eta_S(r+1)]e^{-2\tau(r+1)/T}
>[1-\eta_S(r)]e^{-2\tau(r)/T}.
$$

State plainly that finding the optimum on a general finite graph requires comparing all admissible integer radii. Stopping at the first decline is not justified without unimodality. Rounding a continuous optimum is not a general substitute for this search.

For differentiable curves with $\eta_S(r)<1$, retain the continuous marginal-balance proposition:

$$
\left.\frac{d}{dr}\log[1-\eta_S(r)]\right|_{r=r^\star}
=\frac{2\tau'(r^\star)}{T}.
$$

This is a **necessary condition for an interior optimum**, not an unconditional characterization of a unique global optimum. Keep the additional single-crossing condition and boundary interpretation where uniqueness or comparative statics are claimed. Do not imply that every graph or omission curve is unimodal.

Retain the interpretation that the proportional benefit of more scope balances the proportional loss from delay. Any comparative statics about increasing coherence time or scaling latency must keep their original conditions and allow a boundary optimum to stay unchanged.

### 7.2 Generic exponential-omission result

Present the generic formula before the canonical field calculation. Assume

$$
\eta_S(r)=\eta_0e^{-2r/\ell_c},\qquad
0<\eta_0<1,\quad \ell_c>0,\qquad
\tau(r)=r/v,\quad v>0.
$$

For continuous $r\geq0$, state and prove

$$
\boxed{r^\star=\frac{\ell_c}{2}
\left[\log\left(\eta_0\left(1+\frac{vT}{\ell_c}\right)\right)\right]_+.}
$$

Use a named proposition or theorem, not a formula buried inside another proof. Retain the definition $[z]_+=\max\{z,0\}$.

The proof may use the logarithmic derivative or the derivative of the captured benefit. It must establish the global optimum, not only solve a stationary-point equation. For example, the sign of the derivative is the sign of

$$
\eta_0\left(\frac1{vT}+\frac1{\ell_c}\right)e^{-2r/\ell_c}
-\frac1{vT},
$$

which is strictly decreasing and eventually negative. Thus zero is optimal if it starts nonpositive; otherwise there is a unique positive maximizer. The positive-radius condition in this generic model is

$$
\eta_0(1+vT/\ell_c)>1.
$$

Keep the finite continuous cap in one line:

$$
r_D^\star=\min\{D,r^\star\}.
$$

Do not confuse a cap on an infinite field with the diameter of a finite graph. At an infinite-field cap, omitted information may remain. At the diameter of a finite connected graph, the fresh neighborhood is global and its omission is zero.

### 7.3 Canonical three-length result: retain prominently

Follow the generic result with a compact, clearly identified Gaussian spatial specialization. Gaussianity belongs here, not in the standing assumptions for the composition theorem.

Retain enough model detail in the body to make the result interpretable:

$$
\mathbb E[\theta(z,t)\theta(z',s)]
=\sigma^2e^{-|z-z'|/\ell_s}e^{-|t-s|/T},
$$

$$
x^\star(z,t)=\int_{\mathbb R}\frac{1}{2\ell_c}e^{-|u|/\ell_c}\theta(z+u,t)\,du,
\qquad
\ell_z=\frac q2[x(z)-x^\star(z,t)]^2.
$$

Define $\ell_s$ as the spatial-correlation length, $\ell_c$ as the decision-relevance length, and $vT$ as the distance information propagates in one coherence time. Observe the interval of radius $r$ at a common age $r/v$. Explain that this example has no action coupling and uses pointwise regret, equivalently regret per unit length by spatial stationarity.

Retain the **derived**, not assumed, omission curve:

$$
\eta_S(r)=\frac{\ell_c}{\ell_c+2\ell_s}e^{-2r/\ell_c}.
$$

Give a short proof explanation in the body: the observed middle contributes no uncertainty; the spatial Markov property reduces the two unobserved tails to boundary-conditioned problems; shifting a tail scales its weight by $e^{-r/\ell_c}$; squaring gives the exponential factor; the covariance calculation determines the constant. Keep the complete derivation in the appendix.

Do not suggest the field assumptions are used only to obtain one constant. They justify both the spatial omission calculation and the tail argument leading to its exponential form.

Keep the following as a prominent **numbered corollary or theorem**, with an explicit pointer to its assumptions:

$$
\boxed{r^\star=\frac{\ell_c}{2}
\left[\log\frac{\ell_c+vT}{\ell_c+2\ell_s}\right]_+,}
\qquad
\boxed{r^\star>0\iff vT>2\ell_s.}
$$

Do not reduce it to an unnumbered aside or hide it in the appendix. The contribution is the connection from a concrete spatial/decision model to the architecture, not merely optimizing an assumed error curve.

Preserve the supported comparative statics in the interior regime: $r^\star$ increases with $T$, $v$, and $\ell_c$, and decreases with $\ell_s$. Retain the limiting result

$$
r^\star\longrightarrow\frac{vT-2\ell_s}{2}
\quad\text{as }\ell_c\to\infty\text{ with }vT>2\ell_s\text{ fixed}.
$$

Keep the monotonicity justification for $\ell_c$ in the appendix, for example the existing integral representation

$$
r^\star=\frac12\int_{2\ell_s}^{vT}\frac{\ell_c}{\ell_c+s}\,ds.
$$

Do not transfer these canonical comparative statics automatically to the generic model with fixed $\eta_0$: in the canonical specialization, $\eta_0$ itself depends on $\ell_c$ and $\ell_s$.

## 8. What stays in the body, what moves, and what must not disappear

### Keep visible in the body

- The non-Gaussian conditional-mean assumption and all-rules scope of the main theorem.
- The synchronized-snapshot restriction and why retaining fresh local data is a different architecture.
- Constant positive-definite $Q$, affine desired actions for the composition law, and unconstrained actions.
- The distinction between a necessary marginal-balance condition and sufficient conditions for a unique/global optimum.
- The need to compare all integer radii on general finite graphs.
- The radius cap interpretation relevant to the retained plots.
- Result-specific assumptions: independence in the coupling example; smoothness for the derivative condition; Gaussian spatial structure for the canonical calculation.

### Move or consolidate in the technical appendices

- Probability-space and sigma-algebra definitions, measurable policy spaces, the weighted Hilbert-space construction, and the projection proof.
- The broader fixed-epoch cost formulation, non-affine targets, vector-block details, and the formal centering/equivalence argument.
- Coupled conditional normal equations and the common-information special case.
- Detailed canonical covariance integrals, including coincident inverse-length cases and the continuum observation interpretation.
- Routine aggregate algebra that is not needed after the elementary replacement proof.
- Ergodicity qualifications for sample-path averages, degenerate normalization cases, and other peripheral technical caveats already supported by the manuscript.

**Preserve the general formulation rather than deleting it.** The fixed-epoch projection result has broader scope than the temporal composition theorem. Keep its assumptions, existence/uniqueness statement (up to almost-sure equality), proof, and classical attribution. Do not incorrectly extend the scalar temporal composition law to arbitrary non-affine targets merely because the fixed-epoch projection formulation allows them.

Do not conflate the manuscript's technical appendices with its separate mathematical companion. Essential proofs and assumptions must remain in the submission, not exist only in an optional repository tutorial. The companion may remain as supplementary pedagogical material; it must not be required to follow the main argument. Update its references, eliminate contradictory descriptions, and avoid a wholesale rewrite of its toolkit unless necessary for consistency.

Delete the large body-level assumptions table if the baseline model and local result-specific assumptions make it redundant. A small dependency table may remain in the appendix if genuinely useful. Do not replace it with the false statement that every result needs exactly the same assumptions.

Do not assert that a latest snapshot is sufficient relative to an entire observation history. The two-time conditional-mean assumption used here does not establish that claim. Mixed-age and history-based architectures remain outside the analyzed family unless an existing separately proved result is explicitly retained with its own assumptions.

## 9. Numerical evidence and figures

This is an exposition revision, not a reason to redesign the numerical section or rerun published experiments with different settings.

Preserve the following evidence, identified semantically rather than by renumbered figure numbers:

1. The shared-resource fresh-local/stale-global crossover (`fig:local-global-phase` in the reviewed source).
2. The local, interior, and capped radius regimes (`fig:radius-regret`).
3. The fixed-network decision-relevance comparison (`fig:decision-relevance`).
4. The noncanonical finite-graph comparison across path, ring, grid, and random geometric graph (`fig:general-graphs` where already restored).

If the fourth experiment is already present, leave its results and assets intact. If absent, carry out the previously requested **targeted restoration** from the original archived experiment: reuse its verified code, settings, figure, and concise supporting discussion after the fixed-network comparison. Recover and check the original material rather than inventing results or guessing a filename. Preserve its reproducibility details. Report any unavailable source or mismatch explicitly.

The graph comparison illustrates application of the general composition law on finite noncanonical graphs; it does not establish that the canonical infinite-line radius formula holds on those graphs. Retain the Gaussian assumptions and $Q=I$ specialization used in those particular conditioning calculations, without implying that they are required by the main theorem.

Do not restore other previously removed experiments merely because sections have been reorganized. In particular, this task does not reverse the decisions to omit the original temporal-scaling and canonical-regime-map figures.

Maintain accurate descriptions of what numerical checks do:

- The crossover estimates obtained from sampled local and open-loop losses are not independent delayed-process simulations at every age.
- Prescribed scalar-variance checks illustrate variance composition; they are not simulations of the full canonical spatial field.
- Exact Gaussian conditioning on graphs is an evaluation within a model, not evidence covering nonlinear decisions, heterogeneous temporal rates, mixed-age architectures, or arbitrary non-Gaussian distributions.

Keep existing figure/data assets byte-identical where possible. Repair prose and LaTeX references rather than regenerating figures just to change notation. If an embedded label truly becomes inconsistent, make and document only the necessary change; do not silently alter plotted data or analysis settings.

Retain all parameters, sampling descriptions, uncertainty-interval methods, graph construction details, and reproduction commands needed for the displayed evidence. Descriptions may be consolidated, but reproducibility must not be lost.

## 10. Notation, prose, framing, and references

Use a small vocabulary consistently: desired/full-information action, observations, admissible rule, regret, omission share, and captured benefit. Explain each in ordinary terms before relying on its symbol.

Keep $R$, $R_\infty$, $\eta_S(r)$, and $R/R_\infty$. Remove redundant $\eta_T$ notation if no longer useful. Keep $\rho=\tau/T$ where it supports existing plots or compact threshold statements. Avoid defining a new symbol for a quantity used only once. Do not rename every symbol just to make the manuscript look different.

If an expectation-containing weighted norm is used, define it once and do not accidentally place another expectation around it. Explicit expectations may be clearer in the central proof.

Update the abstract and contributions to describe a common scalar temporal prediction model and affine desired decisions, **not** a Gaussian-only theory. Mention Gaussianity where the spatial and numerical specializations need it. Preserve the distinction between the general composition law and the specialized three-length formula.

Keep a short explanation that architecture performance depends on prediction of the desired action, not just prediction of the raw state. Preserve the role of $K$, $Q$, covariance, and observation geometry; do not replace this by a scalar correlation slogan.

Keep appropriate attribution to the classical static-team framework even after moving the formal theorem. Do not present that projection characterization as a new contribution. Preserve related-work comparisons and citations, changing only references and terminology necessary for the new organization.

Use semantic LaTeX labels where possible. If a theorem becomes a corollary, update textual references accordingly. If a lemma is absorbed into a proof, redirect references to the appropriate equation/result rather than attaching its old label to an unrelated counter. Update cross-document links and any summaries of result numbering.

Aim for less prerequisite material and less repetition, not an arbitrary page count. Report actual main-body and appendix changes after compiling. Do not claim success solely because pages were moved into another PDF.

## 11. Implementation sequence

1. Establish the baseline and a result/assumption/figure preservation ledger.
2. Rewrite the model using tracking loss, concrete observations, direct regret, and the non-Gaussian conditional-mean assumption.
3. Put the composition theorem first, with the elementary proof above. Derive the stale-global and crossover corollaries immediately afterward.
4. Replace the aggregate-coupling proof and verify every retained formula.
5. Reorganize radius selection: discrete rule, continuous marginal balance, generic exponential result, prominent canonical corollary.
6. Move/consolidate the formal machinery and detailed calculations into the correct submission appendices. Repair references in both main paper and companion.
7. Preserve or finish restoring the specified graph experiment, without redesigning the other evidence.
8. Update the introduction, abstract, roadmap, notation, and conclusion after the technical structure is stable.
9. Run mathematical regression checks, compilation, reference checks, figure/data integrity checks, and a final reader-focused pass.

Do not stop after writing a plan or ask the author to re-decide the resolved editorial choices. If a required result cannot be preserved without a substantive correction, isolate the issue and report what remains unresolved rather than obscuring it in the rewrite.

## 12. Verification requirements

### 12.1 Result-preservation ledger

Provide a table mapping each baseline result to its new location and status. At minimum include:

| Result/content | Required outcome |
| --- | --- |
| General fixed-architecture projection | Preserved with proof in submission appendix; broader fixed-epoch scope intact. |
| Innovation decomposition | Preserved inside the main elementary proof or a short supporting statement. |
| Exact stale-global regret | Preserved as a non-Gaussian consequence. |
| Fresh-local/stale-global crossover | Prominent numbered result; strict/equality/endpoint meanings intact. |
| Aggregate coupling | Same policy, regrets, omission share, finite-size threshold, large-$n$ limit, and interpretation. |
| Spatiotemporal composition | Main theorem, non-Gaussian, general $Q$, all admissible rules. |
| Decision relevance | Retained in model/interpretation and supported numerical evidence. |
| General radius selection | Integer comparison and correctly qualified continuous marginal balance. |
| Generic exponential radius | Explicit result with boundary/global-optimum argument and cap. |
| Canonical omission and radius | Derived omission curve, three-length formula, threshold, comparative statics, and asymptote preserved. |
| Numerical evidence | Intended four illustrations and their reproducibility details preserved. |

Distinguish "moved," "proof simplified," and "special-case consequence" from "deleted." Verify actual assumptions, not only identical boxed expressions.

### 12.2 Mathematical regression checks

Use the existing test framework where practical. Keep new checks small and deterministic; do not create new publication experiments.

- Check the composition law at zero delay, complete scope, and nonzero partial omission. Check the no-information limit under the exponential model without treating infinite delay as a finite invertible rescaling.
- Check the aggregate formulas against direct finite-dimensional quadratic calculations for several $n,q,\gamma$, including $\gamma=0$ and positive coupling.
- Check generic radius solutions in local, interior, and capped regimes against direct maximization. Include a boundary case where the derivative at zero is zero.
- Check canonical substitution and the threshold $vT=2\ell_s$. Check the canonical comparative statics while allowing $\eta_0$ to change with the lengths as defined.
- Check finite-graph routines still compare all admissible integer radii rather than assuming unimodality.

Include at least one **non-Gaussian, all-policy** check of the composition law with a non-diagonal positive-definite $Q$. A suitable finite-state construction is:

1. Choose a finite stationary distribution $\pi$ on state vectors and center it.
2. From an old state $s$, retain $s$ with probability $a$ and otherwise draw a new state independently from $\pi$:
   $P(s,s')=a\mathbf1_{s=s'}+(1-a)\pi(s')$.
3. This has stationary distribution $\pi$ and conditional mean $a s$. The innovation is generally **not** independent of the old state, so the check does not inadvertently assume more than the theorem.
4. Represent each agent's rule by an unrestricted table over its finite observation values. Solve the resulting finite quadratic minimization and compare delayed regret against $(1-a^2)R_\infty+a^2R_{\rm fresh}$.

One concrete choice is the nine raw states in $\{-1,0,1\}^2$, with probabilities proportional to the row-major weights `(5,1,2, 2,3,4, 1,2,5)`, centered by their mean; each agent observes its own coordinate. For example use

$$
Q=\begin{pmatrix}2&0.4\\0.4&1.5\end{pmatrix},
\qquad
K=\begin{pmatrix}1&0.7\\-0.3&1.2\end{pmatrix}.
$$

Compare several $a\in(0,1]$. This is a development regression, not material that must be added to the manuscript. A successful numerical check is not a substitute for reviewing the proof.

### 12.3 Negative checks against accidental weakening or overclaiming

Search the revised source and inspect every relevant occurrence to ensure it does **not**:

- Require Gaussianity or independent innovations for the main composition/crossover statements.
- Restrict the main optimization to linear rules.
- Infer conditional independence from zero covariance without appropriate joint-Gaussian assumptions.
- Infer the all-rules non-Gaussian law from covariance alone.
- Replace general $Q$ with identity/diagonal $Q$ outside explicitly identified examples.
- Imply that separate agentwise conditional means always solve a coupled team.
- Present the canonical omission curve as merely postulated in the canonical model.
- Apply the canonical radius formula to arbitrary finite graphs.
- Claim a stationary point is automatically a unique global optimum.
- Claim that more retained information makes the optimum worse, or that synchronized-snapshot results cover mixed-age/history architectures.

### 12.4 Build, references, and artifact integrity

Run the repository's supported build and `verify_revision.py` if present. Rebuild main and companion as needed for external references. Resolve undefined citations, labels, duplicate labels, and incorrect theorem-type references. Inspect the compiled layout for broken tables, misplaced figures, and unreadable equations.

Existing checks may encode old section numbers or theorem counts. Update structure-specific assertions transparently, while retaining substantive mathematical and figure-integrity checks. Do not disable a failing semantic check merely to report a pass.

Compare hashes of retained figure/data files with the baseline and explain every difference. Record commands, pass/fail results, pre-existing problems, and checks that could not run. Do not claim an independent human review or a completed reproduction that did not occur.

## 13. Deliverables and completion criteria

Deliver the edited manuscript and necessary supporting files, not just this specification:

1. Updated main source and submission appendices, plus companion updates where affected.
2. Compiled main PDF and companion PDF where applicable, using the repository's normal version/naming convention.
3. A concise change summary with the result-preservation ledger, old-to-new locations, any substantive exceptions, and actual body/appendix length changes.
4. Verification results: mathematical checks, build/reference checks, and figure/data integrity comparison.
5. An explicit list of unresolved issues or unavailable checks; do not conceal limitations behind a general statement that everything is unchanged.

The revision is successful when a reader can understand the problem, model, composition proof, crossover, and radius optimization without first learning Hilbert-space projection or stochastic calculus; the central theorem remains non-Gaussian and valid for all admissible rules; and the canonical three-length result, broader formal framework, and numerical evidence remain intact.

**Final priority:** Simplify the route to the contribution, not the contribution itself.
