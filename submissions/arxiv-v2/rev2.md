# TINA — the neighborhood radius and the value of delayed information

Use the attached *tina-v2-alt(1).pdf* as the manuscript of record. Work in `submissions/arxiv-v2/main-alt.tex` and `submissions/arxiv-v2/references.bib`. The four sections below give insertion points and proposed manuscript prose. Keep the language in the paper focused on the model, the results, and their relationship to prior work. Use the existing theorem environments, equation labels, and bibliography style.

## 1. Put the neighborhood-radius result first and attribute the decomposition at its point of use

**Abstract.** In the sentence beginning “Under these conditions, the cost reduction,” replace the opening with “Under these conditions, the Marschak–Radner decomposition implies that the cost reduction”. Continue directly with the existing wording “from a delayed snapshot, relative to acting without observations, equals …”. Use the authors’ names in the abstract and give the formal citation in the body. The abstract already states the common-time snapshot assumption, the cost baseline, the threshold on the line, and the ring result.

**Introduction, immediately after Figure 1.** Replace the three numbered contributions with the following two. Their order puts the radius calculation first and keeps the general team result visible.

~~~latex
\begin{enumerate}
\item We derive the optimal synchronized observation radius when spatial
omission decays exponentially with radius and delay grows linearly with
distance. For a Gaussian field on a line, we calculate the omission curve
and express the optimal radius in terms of the spatial
correlation length, the reach of the decision weights, and the distance
information travels in one coherence time.
\item We apply the Marschak--Radner decomposition to synchronized
neighborhoods under a common conditional-mean prediction rule. This gives
the delay at which a fresh local reading overtakes a delayed global view.
On a fixed ring, we show how changing the decision weights alone moves
the optimal radius, and we evaluate the same radius criterion on other
finite graphs.
\end{enumerate}
~~~

**Section 3, immediately before Theorem 1.** Use the following in place of the short introductory paragraph. This is the place to identify the precise classical result. The existing proof then gives the argument in the notation and under the hypotheses used in this paper.

~~~latex
Marschak and Radner derived the loss from delayed information in a
quadratic team with scalar autoregression
\cite[Ch.~7, Sec.~4, Eqs.~(4.21)--(4.22)]{marschak1972economic}.
Their $w^d$ is the prediction factor $a$ below, their $\widehat V(0)$
corresponds to $R_\infty$, and their $L(0)$ is the regret with the same
information at zero delay. We use this decomposition for synchronized
neighborhoods in continuous time, assuming that the conditional mean of
the current centered state is $a$ times the old centered state.
~~~

**Section 6.1, “Static Team Decision Theory.”** In the closing paragraph beginning “Relative to these works,” use the following in place of the general claim that coupling scope to latency is the paper’s distinctive feature. The equation numbers in the citations below refer to Chapter 7 of the book. In particular, its group information value corresponds to the fraction captured, $1-\eta_S(0)$.

~~~latex
Marschak and Radner also optimize the extent of information when more
information takes longer to obtain. Their marginal condition
\cite[Ch.~7, Eq.~(6.5)]{marschak1972economic} gives the balance in
Proposition~\ref{thm:marginal_balance}. For their identical-interaction
example, the group-size-one case of their Eq.~(6.6) gives the local
information share $1-\eta_S(0)$ in
Proposition~\ref{prop:aggregate_local}. Here the design variable is the
radius of a synchronized neighborhood. Computing how much that
neighborhood reveals about the desired action gives the radius formula
on the line and the comparison of decision weights on finite graphs.
~~~

Source for the equation locators: Jacob Marschak and Roy Radner, *Economic Theory of Teams*, Yale University Press, 1972, Cowles Foundation Monograph 22, Chapter 7, “The Team in a Dynamic Environment.” The delayed-rule rescaling appears on printed p. 254, the value and loss identities on p. 256, and the marginal condition and group example on p. 262. Reuse the existing bibliography entry. [Cowles Foundation record](https://cowles.yale.edu/research/cfm-22-economic-theory-teams) · [Book scan](https://cowles.yale.edu/sites/default/files/2022-09/m22-all.pdf)

## 2. Derive the delayed-snapshot identity for the field on the line

**Section 4.3, opening sentence.** Introduce joint Gaussianity at the point where the field is defined: “We now specialize to a jointly Gaussian space–time field on the infinite line, with spatial coordinate \(z\in\mathbb R\).”

**Section 4.3, after Eq. (35) and its explanation of \(vT\), before Lemma 1.** Insert this pointwise argument. It uses the covariance and kernel already defined in the section. The display can stay unnumbered.

~~~latex
Fix a location $z$, a radius $r$, and a delay $\tau$, and write
$a=e^{-\tau/T}$. By the separable covariance in
\eqref{eq:canonical_space_time_covariance}, the innovation
$\theta(y,t)-a\theta(y,t-\tau)$ is uncorrelated with
$\theta(y',t-\tau)$ for every $y,y'$. Joint Gaussianity therefore makes
the innovation field independent of the entire field at time $t-\tau$.
Integrating against the decision kernel in \eqref{eq:canonical_target}
and conditioning on the observed interval gives
\[
\mathbb E[x^\star(z,t)\mid O_r(z,t-\tau)]
= a\,\mathbb E[x^\star(z,t-\tau)\mid O_r(z,t-\tau)].
\]
Under the pointwise squared loss, the gain over acting without observations
is $q/2$ times the variance of the conditional mean. By stationarity,
the conditional mean at time $t-\tau$ has the same variance as its
fresh-snapshot counterpart at time $t$. The delayed interval therefore
retains $a^2$ times the gain from a fresh interval of the same radius.
~~~

The field calculation uses uncoupled pointwise loss. Its role is to supply the temporal factor for the continuum radius calculation. Lemma 1 supplies the spatial omission curve.

## 3. State the scope of the radius results in the discussion

**Section 7, assumptions paragraph.** Replace the sentence beginning “Gaussianity is used to evaluate spatial prediction errors” and ending “linear propagation delay.” Use these three sentences directly after the sentence stating the conditional-mean hypothesis:

~~~latex
The composition law allows coupled actions through any fixed $Q\succ0$
and applies to non-Gaussian states. The closed-form radius in
Theorem~\ref{thm:canonical_optimal_radius} uses an infinite line, a jointly
Gaussian field with the separable exponential covariance in
\eqref{eq:canonical_space_time_covariance}, an exponential decision
kernel, uncoupled squared loss, and propagation delay $\tau(r)=r/v$.
The finite-graph examples in
Sections~\ref{subsec:numerical-decision-relevance}
and~\ref{subsec:numerical-general-graphs} use Gaussian states and $Q=I$,
so each agent predicts its own weighted target.
~~~

Attach these assumptions specifically to Theorem 3 and the graph examples. Proposition 3 takes an exponential omission curve as an input. Theorem 3 derives that curve from the field and decision kernel.

## 4. Place the radius problem in the spatial age-of-information literature

**Section 6.3, final paragraph.** After the sentence on Li et al., replace the passage beginning “Those works optimize” through the end of the paragraph. Jiang and Zhou are the closest comparison because they use the same form of space–time covariance and choose a spatial design parameter. Munari et al. provide a concise reference for communication-range selection. Use both in the following passage:

~~~latex
Jiang and Zhou \cite{jiang2019status} study a one-dimensional
Gauss--Markov field with exponential correlation in space and time.
They choose the sampling density to minimize remote field-estimation
error when the density also affects queueing delay.
Munari et al.~\cite{munari2025spatiotemporal} study how spatial
correlation and update freshness affect the choice of communication
range for remote monitoring. Here the design variable is the radius
of a synchronized snapshot. Its value depends on how strongly the
states inside that radius predict the agent's desired action.
~~~

**Bibliography.** Insert these entries in `references.bib`. The manuscript’s existing key for the 1972 book is `marschak1972economic`.

~~~bibtex
@inproceedings{jiang2019status,
  author    = {Zhiyuan Jiang and Sheng Zhou},
  title     = {Status from a Random Field: How Densely Should One Update?},
  booktitle = {2019 IEEE International Symposium on Information Theory (ISIT)},
  year      = {2019},
  url       = {https://arxiv.org/abs/1901.05096}
}

@inproceedings{munari2025spatiotemporal,
  author    = {Andrea Munari and Federico Chiariotti and Leonardo Badia
               and Petar Popovski},
  title     = {Spatio-Temporal Information Freshness for Remote Source
               Monitoring in {IoT} Systems},
  booktitle = {2025 IEEE 26th International Workshop on Signal Processing
               and Artificial Intelligence for Wireless Communications (SPAWC)},
  year      = {2025},
  pages     = {1--5},
  doi       = {10.1109/SPAWC66079.2025.11143489}
}
~~~

Jiang and Zhou’s paper gives the exponential space–time correlation in Eq. (9) and the density optimization in Sec. IV. [Paper](https://arxiv.org/abs/1901.05096) · [ISIT publication record](https://network.ee.tsinghua.edu.cn/niulab/?p=3789)

Munari et al. analyze conditional entropy and the choice of communication range in remote monitoring. [Published paper](https://doi.org/10.1109/SPAWC66079.2025.11143489) · [Open manuscript](https://arxiv.org/abs/2506.04804)

**Compilation check.** Build the alt manuscript with its usual bibliography pass. Check that the book citations display their chapter and equation locators, both conference papers appear in the references, the cross-references resolve, and the field identity appears between Eq. (35) and Lemma 1.
