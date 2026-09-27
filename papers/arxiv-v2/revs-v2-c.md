# Revision Plan for `tina-v2-c`

## Overall recommendation

Use **version C** as the basis for the arXiv v2. It has the strongest balance of rigor, clarity, and editorial discipline. The main paper already contains the essential theory, the core proofs, and the numerical evidence without the tutorial-level expansion that made version B feel too long.

The goal of the revision should therefore **not** be to expand version C. It should be to make a small number of targeted improvements that preserve its compactness while improving self-containment, reproducibility, and polish.

---

# 1. Main paper: keep the current 32-page structure

The current version C has the right overall length and organization. Retain the main architecture:

1. Introduction  
2. Networked Decisions and Information Architectures  
3. Fresh-Local versus Stale-Global Information  
4. Spatial and Temporal Predictability  
5. Optimal Coordination Scale  
6. Numerical Consistency Checks and Finite-Graph Illustrations  
7. Related Work  
8. Discussion and Conclusions  

Do **not** import the extended tutorial material from version B wholesale. In particular, do not reintroduce:

- long explanations of sigma-algebras, Hilbert spaces, conditional expectation, or OU processes;
- the full mathematical toolkit appendix;
- the glossary;
- line-by-line expansions of standard proof steps;
- repeated prose explaining what every figure or equation means after the same point has already been made.

The compact version already proves the main claims and preserves the intellectual spine of the paper.

---

# 2. Add one compact assumptions table from version B

The strongest item worth salvaging from version B is the **assumptions table**.

Add a compact table near the beginning of Section 3, or just before the main theorem sequence, summarizing which assumptions are required by which results.

Suggested columns:

| Result | Stationarity | Common-rate innovation | Affine target | Gaussianity | Additional assumptions |
|---|---|---|---|---|---|
| Lemma 1 | No, fixed epoch | No | No | No | deterministic \(Q \succ 0\), closed linear policy space |
| Lemma 2 / Theorems 1–2 | Yes | Yes | Yes | No | scalar decay / conditionally mean-zero innovation |
| Proposition 1 | No, fixed epoch | No | Yes | No | independent, zero-mean, equal-variance states |
| Theorem 3 | Yes | Yes | Yes | No | synchronized snapshots |
| Proposition 2 | Yes | Yes | Yes | No | differentiable \(\tau(r)\), \(\eta_S(r)\) |
| Lemma 3 | Spatial stationarity | No | Yes | Yes | exponential spatial covariance and kernel |
| Theorem 4 | Space/time stationarity | Yes | Yes | Yes | canonical line model and linear delay |

This table improves readability and heads off possible confusion about which assumptions are structural and which are used only for closed forms.

Keep it concise. It should not become a new explanatory subsection.

---

# 3. Preserve the early fresh-local versus stale-global result

One of version C's strengths is that the fresh-local versus stale-global crossover appears early and remains a clear first main result.

Keep this ordering.

The reader should encounter, in this order:

1. the fixed-architecture projection interpretation;
2. the temporal prediction error of stale-global information;
3. the exact crossover theorem;
4. the role of decision coupling;
5. only then the more general radius family.

Do not move the radius theory earlier at the expense of the fresh-local/stale-global result.

---

# 4. Keep the projection result concise, but make one sentence more explicit

The projection result in Section 2.4 is sufficiently rigorous as written. Do not expand it into the tutorial treatment of version B.

However, retain or slightly sharpen the following interpretive point immediately after Lemma 1:

> Architecture regret is the part of the full-information decision that cannot be reproduced using the admissible information.

This is one of the conceptual keys to the paper and helps motivate the later use of decision-relevant predictability.

A short follow-up sentence can make the transition explicit:

> Thus the relevant object is not reconstruction error for the raw state, but prediction error for the full-information action.

That idea should remain visible because it is the conceptual bridge to Sections 4 and 5.

---

# 5. Keep the synchronized-snapshot restriction very explicit

The paper depends critically on the fact that increasing radius replaces a fresher narrow snapshot with an older wider snapshot.

Keep the current explanation that the radius family is **not** a nested information family.

Add, if needed, one compact clarifying sentence in Section 5.1:

> An interior optimum is possible because increasing \(r\) does not simply add information; it replaces a fresher snapshot by an older, broader one.

This is enough. Do not import the longer pedagogical discussion from version B.

---

# 6. Retain the current main-text proof lengths

The current main text has the right proof granularity.

Keep in the main paper:

- Lemma 1 proof;
- Lemma 2 proof;
- Theorem 1 proof;
- Theorem 2 proof;
- Proposition 1 proof at the current compressed level;
- Theorem 3 proof;
- Proposition 2 proof;
- Lemma 3 proof at the current high level;
- Theorem 4 proof.

Do not move the core logical steps out of the main paper.

The supplement should contain only the algebraic or calculational detail that would otherwise interrupt the flow.

---

# 7. Keep Supplement S1 and S2

The first two supplementary sections are appropriate and useful.

## S1: Aggregate-coupling calculations

Keep this section. It provides the omitted matrix arithmetic behind Proposition 1 without bloating the main paper.

The main paper should continue to state the result cleanly and point to S1 for the detailed calculation.

## S2: Canonical spatial omission calculation

Keep this section as well. The detailed covariance integral and equal-inverse-length case belong in the supplement rather than the main paper.

The main paper should retain the structural proof idea:

- split the target into observed middle and unobserved tails;
- invoke the spatial Markov property;
- obtain the exponential \(e^{-2r/\ell_c}\) dependence;
- state the resulting constant.

The supplement should carry the full integral calculation.

---

# 8. Compress Supplement S3 substantially

This is the main change to the supplement.

The current S3 is too close to a second narration of Section 6. The supplement should focus on **reproducibility and diagnostics**, not repeat the interpretation and conclusions already given in the main paper.

Target: reduce S3 from roughly 3+ pages to about **1.5–2 pages**.

Suggested structure:

## S3 Numerical reproducibility details

Begin with one short paragraph:

> This section records the numerical settings, estimators, grids, normalization conventions, and diagnostics underlying the six experiments in Section 6 of the main paper. The main paper reports the findings and their interpretation; the supplement records implementation details needed for reproduction and audit.

Then retain the reference-settings table.

After the table, use six short experiment-specific paragraphs or subsections containing only details that are not already obvious from the main paper.

---

# 9. What to retain in S3

## General numerical methodology

Keep:

- the statement that all experiments evaluate architecture regret under the information structure corresponding to the theory;
- the fact that Experiment 1 uses the common delayed snapshot;
- the fact that Experiment 2 uses the exact fresh-local rule;
- the fact that Experiments 3–4 evaluate the scalar composition law;
- the fact that Experiments 5–6 use \(Q=I\) and Gaussian conditional variances;
- normalization conventions;
- covariance construction for graph experiments;
- confidence-interval methodology;
- the location of seeds, configurations, and reproduction documentation.

This is genuine reproducibility material.

## Reference-settings table

Keep the table with:

- parameter ranges;
- graph sizes;
- sample counts;
- radius grids;
- experiment sizes.

This is probably the single most useful piece of S3.

---

# 10. What to remove from S3

Delete or sharply shorten prose that merely restates the main-paper conclusions.

Examples of material to remove from the supplement include sentences of the form:

- “the Monte Carlo curves collapse onto...”
- “stronger decision coupling therefore makes older global information worth tolerating...”
- “the three curves distinguish immediate dominance of staleness, an interior balance...”
- “moving upward increases the distance information can travel...”
- “thus changing only decision sensitivity produced substantially different preferred architectures...”

Those are **results and interpretations**, not methodology.

They already belong in Section 6 of the main paper.

The supplement should instead say what was computed and how.

---

# 11. Suggested concise S3 content by experiment

## Experiment 1: Temporal scaling

Keep only:

- 20,000 stationary OU pairs per staleness value;
- the 25 values of \(\rho=\tau/T\);
- the four system dimensions/settings;
- pair generation:
  \[
  \theta_t
  =
  e^{-\rho}\theta_{t-\tau}
  +
  \sqrt{1-e^{-2\rho}}\,\epsilon,
  \qquad
  \epsilon\sim\mathcal N(0,\Sigma_S);
  \]
- evaluation under the known optimal delayed-snapshot action;
- loss measured in the corresponding \(Q\)-metric;
- any confidence-interval formula if not documented elsewhere.

Do not repeat the observed numerical agreement with theory unless it is needed as a diagnostic.

## Experiment 2: Fresh-local/stale-global crossover

Keep:

- \(q=1\);
- \(n\in\{5,10,25,100\}\);
- 9 values of \(\gamma/q\);
- 30,000 paired draws per setting;
- the estimator
  \[
  \hat\rho^\star
  =
  \frac12
  \log
  \frac{\hat R_\infty}
       {\hat R_\infty-\hat R_{\mathrm{loc}}};
  \]
- the use of paired samples;
- the delta-method interval construction.

Delete the discussion of how the boundary moves with coupling; that belongs in the main paper.

## Experiment 3: Three radius regimes

Keep:

- \(\eta_S(r)=\eta_0e^{-2r/\ell_c}\);
- \(\tau(r)=r/v\);
- \(D/\ell_c=2\);
- the three parameter settings;
- grid spacing;
- 50,000 scalar checks per point;
- the fact that this is a scalar variance check rather than simulation of a spatial field.

Delete the interpretation of the three regimes.

## Experiment 4: Canonical regime map

Keep:

- the 72 x 68 parameter grid;
- \(vT/\ell_c\in[0.1,20]\);
- \(\ell_s/\ell_c\in[0.05,5]\);
- \(r/\ell_c\in[0,4]\);
- \(\Delta r=0.0016\);
- direct scalar minimization at each grid point;
- the fact that no adaptive radius range or covariance simulation was used;
- optional grid-error diagnostics.

Delete prose explaining the visual meaning of moving up/right in the figure.

## Experiment 5: Decision relevance

Keep:

- the 64-node ring;
- fixed covariance and graph;
- \(T=6\);
- latency 0.12 per hop;
- \(\ell_c\in\{0.7,2,6\}\);
- the row-\(\ell_2\)-normalized operator
  \[
  K_{ij}
  =
  \frac{e^{-d_G(i,j)/\ell_c}}
       {\|e^{-d_G(i,\cdot)/\ell_c}\|_2};
  \]
- \(Q=I\);
- exact Gaussian conditioning;
- 12,000-sample numerical check.

Delete the interpretive conclusion that decision sensitivity changes the preferred architecture; this is already in the main paper.

## Experiment 6: Finite graphs

Keep:

- path, ring, grid, geometric graph;
- 64 nodes;
- fixed geometric-graph seed;
- covariance construction;
- average marginal variance normalization;
- \(Q=I\), \(T=5\), \(\ell_c=2\);
- latency 0.12 per hop;
- exact integer-radius evaluation;
- the fact that no canonical-line fit or graph-ensemble averaging was used;
- where the archived neighbor differences are stored.

Delete the prose summary of how optima moved across parameter sweeps.

---

# 12. Replace process-oriented wording in the supplement

Replace:

> “The original detailed methodology and diagnostics follow; figure references point to that paper. No experiments have been regenerated.”

with something publication-facing, for example:

> “This section records the numerical settings and diagnostics underlying the experiments in Section 6 of the main paper.”

Avoid wording that sounds like internal revision history.

---

# 13. Make the relationship among main paper, supplement, companion, and repository explicit

The paper currently refers to:

- a supplementary document;
- a mathematical companion;
- the public TINA repository.

Make these roles unmistakable.

Suggested wording near the end of the introduction or in the code/data statement:

> “Detailed algebraic derivations and numerical reproducibility information are provided in the supplementary material. A separate mathematical companion provides background on the projection and stochastic-process tools used in the paper. Source code, configurations, processed results, and figure-generation scripts are available in the public TINA repository.”

Then make sure all three are actually accessible when the arXiv v2 is posted.

---

# 14. Check every supplementary cross-reference

Before posting, do a mechanical pass over every occurrence of:

- “Supplementary Section S1”;
- “Supplementary Section S2”;
- “Supplementary Section S3”;
- “companion”;
- “repository”;
- figure references;
- equation numbers referenced from the supplement.

Make sure numbering agrees with the final v2-c main paper.

This is especially important because the supplement currently states that unqualified equation and theorem references use the v2-c numbering.

---

# 15. Keep Section 6 concise and results-focused

Section 6 of the main paper should carry:

- the reason for each experiment;
- the key setup;
- the key numerical outcome;
- the interpretation.

It should **not** absorb the numerical details removed from S3.

Conversely, S3 should not repeat the interpretation.

A clean division is:

**Main paper:** what was tested, what happened, why it matters.  
**Supplement:** exact settings, estimators, grids, seeds, normalizations, and diagnostics.

---

# 16. Preserve the strongest conceptual framing

The paper is strongest when it emphasizes that the architecture should be designed around **decision-relevant predictability**, not state reconstruction.

Keep this theme prominent in:

- the introduction;
- Section 2.4 after the projection result;
- Section 4.4;
- Experiment 5;
- the discussion.

Avoid adding more conceptual labels than necessary.

The main message can remain:

> Broader information is valuable only to the extent that it predicts components of the current full-information decision, and that value decays with the age required to obtain it.

---

# 17. Retain the related-work precision

Version C's related-work section is already appropriately differentiated from:

- static team theory;
- distributed optimization;
- networked control;
- Age of Information;
- organizational economics;
- spatial statistics and graph signal processing.

Do not expand it substantially.

The key distinction should remain:

> prior work studies related scope, delay, or information-structure questions, while this paper studies an exogenous-state static-team problem in which an architecture is valued through prediction error of the current full-information action.

That is enough to position the work.

---

# 18. Keep the discussion limitations explicit

Retain the current limitations:

- exogenous state;
- static teams;
- quadratic cost;
- deterministic positive-definite Hessian;
- affine full-information decision for the closed forms;
- common-rate temporal innovation;
- Gaussianity only where covariance-based spatial calculations require it;
- synchronized snapshots;
- no action-dependent signaling;
- no general mixed-age architecture;
- no general nonseparable space-time process.

This restraint is a strength.

Do not dilute the paper by adding speculative extensions in much greater detail.

---

# 19. Final cleanup pass

Before posting, perform a final pass specifically for:

### Cross-reference consistency
- theorem numbers;
- equation numbers;
- figure numbers;
- supplement references;
- repository references.

### Terminology consistency
Use the same terms everywhere:

- fresh-local;
- stale-global;
- synchronized snapshot;
- architecture regret;
- open-loop regret;
- temporal unpredictability;
- spatial omission;
- decision-relevant predictability;
- decision-sensitivity operator;
- temporal propagation length.

### Compression artifacts
Check for places where shortening from version B may have left:

- a symbol introduced too late;
- a statement referring to omitted explanatory material;
- a dangling phrase like “as discussed above” with no clear antecedent;
- a proof step that became too abrupt after deletion.

### Publication-facing tone
Remove language that sounds like:
- revision history;
- internal drafting notes;
- implementation diary;
- “original detailed methodology”;
- “no experiments have been regenerated.”

---

# 20. Target final package

A strong final arXiv package would be approximately:

- **Main paper:** 32 pages, essentially current version C;
- **Supplement:** about 4–5 pages;
  - S1 aggregate-coupling calculations;
  - S2 detailed canonical spatial-omission calculation;
  - compressed S3 reproducibility details;
- **Optional mathematical companion:** separate document linked from the repository rather than embedded into the paper;
- **Repository:** source, code, configurations, processed numerical results, and figure-generation pipeline.

This preserves the rigor and auditability of version B without sacrificing the much better focus of version C.

---

# Bottom line

The revision should be **surgical, not expansive**.

Version C already contains the correct research paper. The main improvements are:

1. add a compact assumptions table;
2. keep the synchronized-snapshot non-nesting point explicit;
3. retain the current proof granularity;
4. keep S1 and S2;
5. compress S3 to reproducibility-only material;
6. make the paper/supplement/companion/repository relationship explicit;
7. perform a careful final cross-reference and terminology pass.

Do not re-expand version C toward version B.
