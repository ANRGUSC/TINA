# Claim ledger: tina-v2-alt

Sources (all under submissions/arxiv-v2):
- MAIN = main-alt.tex (1,211 lines)
- APP  = technical-appendices-alt.tex (621 lines; appendices A-D of the paper)
- COMP = appendices-alt.tex (separate companion: toolkit, glossary; not part of the submitted paper)
- Predecessor for regression checks: main.tex, technical-appendices.tex (revision v2-h)
- Code: numerics, /tests, submissions/arxiv-v2/verify-alt.py

Dependency chain: C1 -> C2 -> C12; C5,C4 -> C7 -> {C8, C9, C10, C14}; C10 + C12 -> C13;
C14 -> C15 -> C16; C16 + C18 -> C19 -> C20; C7 -> C21..C24 (numerics evaluate the law).

| ID | Claim | Location |
|---|---|---|
| C1 | Lemma (fixed-architecture quadratic projection): admissible set is a closed subspace; optimum is the Q-weighted projection of x*; regret = half squared projection error | APP:99-218 |
| C2 | Corollary (coupled conditional normal equations): necessary and sufficient; agentwise conditional means generally not optimal with off-diagonal Q | APP:220-269 |
| C3 | Common-information paragraph: vector conditional mean optimal regardless of Q; degenerate R_inf = 0 case; data-processing monotonicity in delay under a stationary Markov environment; stationarity vs ergodicity remarks | APP:271-292 |
| C4 | Temporal assumption (theta_t = a theta_{t-tau} + eps, E[eps given theta_{t-tau}] = 0, a = exp(-tau/T), stationary) and the claim that stationary Gaussian OU and AR(1) with independent innovations satisfy it | MAIN:279-312, APP:294-313 |
| C5 | Model setup: centering is without loss; completing the square gives the tracking loss; affine target x* = K theta | MAIN:161-212, APP:1-97 |
| C6 | Architectures, regret definition, R_inf formula, eta_S(r) in [0,1], nonincreasing in r, zero at diameter | MAIN:214-277 |
| C7 | Theorem (spatio-temporal composition): R(A_{r,tau}) = (1-a^2) R_inf + a^2 R(A_{r,0}) for all admissible (nonlinear) rules, any deterministic Q > 0, non-Gaussian states | MAIN:314-391 |
| C8 | Corollary (exact stale-global regret) plus small-delay expansion and large-delay limit; optimal global action a K theta_{t-tau} | MAIN:393-412 |
| C9 | Unequal-rate formula for a complete old snapshot with independent OU modes: 1 - R_glob/R_inf = sum_k w_k exp(-2 tau/T_k) | MAIN:414-427 |
| C10 | Theorem (fresh-local vs stale-global crossover): rho* = (1/2) log(1/(1-eta_S(0))), equality and eta_S(0) = 1 cases, single crossing | MAIN:429-449 |
| C11 | Intro two-sensor example: crossover at tau > T log(2)/2 | MAIN:66-91 |
| C12 | Proposition (local explainability under aggregate coupling): optimal local rule theta_i/(q+gamma); eta_S(0) formula; R_inf and R_loc formulas | MAIN:451-556, APP:315-399 |
| C13 | Threshold rho*(gamma,n), large-n limit (1/2) log(1+gamma/q), monotonicity in gamma, "local information captures share q/(q+gamma)" | MAIN:558-616 |
| C14 | Radius setup: G(r), R(r) = R_inf[1-G(r)], one-more-hop criterion, loss decomposition, remarks on unimodality and rounding | MAIN:618-664 |
| C15 | Proposition (continuous marginal balance) plus prose: single-crossing uniqueness; comparative statics in T and latency scale | MAIN:666-698 |
| C16 | Proposition (optimal radius for exponential omission): closed form, uniqueness, positivity condition, capped optimum min(D, r*) | MAIN:700-739 |
| C17 | Canonical model setup: Gaussian field on the line with separable exponential covariance, spatial Markov property, exponential decision kernel, uncoupled loss, regret per unit length, tau(r) = r/v; implicit use of C7 in this continuum setting | MAIN:741-785 |
| C18 | Lemma (exponential omission by self-similarity): eta_S(r) = eta_0 exp(-2r/l_c), eta_0 = l_c/(l_c + 2 l_s); covariance integrals | MAIN:787-810, APP:401-478 |
| C19 | Theorem (optimal synchronized-snapshot radius): r* = (l_c/2)[log((l_c+vT)/(l_c+2 l_s))]_+; positivity iff vT > 2 l_s; four comparative statics; integral representation | MAIN:813-850, APP:480-490 |
| C20 | Prose after the theorem: interpretation of the threshold; limit r* -> (vT - 2 l_s)/2 as l_c -> infinity | MAIN:852-862 |
| C21 | Fig. local-global phase: Monte Carlo estimator and what it does and does not check | MAIN:874-905, APP:522-538 |
| C22 | Fig. radius-regret: three regimes, constrained optima 0, 0.62638, 2; what the markers check | MAIN:907-936, APP:540-548 |
| C23 | Fig. decision relevance: 64-node ring, T = 6, latency 0.12/hop, l_c = 0.7, 2, 6 gives optimal radii 1, 2, 5; covariance (kappa^2 I + L)^(-nu) with (0.75, 1.5) | MAIN:938-973, APP:550-566 |
| C24 | Fig. general graphs: optima 2, 2, 3, 2; diameters 63, 32, 14, 8; "path and ring also have local optima at l_c = 0.7"; weakly increasing sweeps | MAIN:975-1016, APP:568-602 |
| C25 | Abstract and contribution list: "exact rule", "allows non-Gaussian states and nonlinear decision rules", "gives the optimal observation radius", "one to five hops" | MAIN:46-48, 135-149 |
| C26 | Related-work positioning and attribution: Radner, Marschak-Radner, Krainak-Speyer-Marcus, Afshari-Mahajan, Ballotta et al., age-of-information and OU remote estimation; what is said to be distinctive | MAIN:93-128, 1018-1107 |
| C27 | Discussion: scope and limitations, design implication, statement of which assumptions each result uses | MAIN:1109-1181 |

## Severity bar (applies to every reviewer)
- CRITICAL: a stated result is false as stated.
- MAJOR: a proof gap that is not routine to close; a missing hypothesis that changes the scope of a result; a headline claim (abstract, contributions) that exceeds what is proven.
- MEDIUM: a true result that rests on an unstated assumption a competent referee would flag; numerics that do not match the text; a novelty or attribution overstatement.
- BELOW BAR, do not report: wording, typography, notation preferences, and regularity conditions that the field routinely leaves implicit (measurability of obviously measurable maps, exchanging expectation and finite sums, existence of regular conditional distributions on Euclidean spaces, and the like).
