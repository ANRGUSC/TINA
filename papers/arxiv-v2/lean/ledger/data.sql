-- Ledger data. Written by tools/ledger.py; edit through the CLI.

-- meta
INSERT INTO meta (key, value) VALUES ('decision_unproved_claims', '2026-11-13 (Scott): claims the paper asserts without proof get short proofs added to an appendix through tracked edits, and those proofs are then formalized.');
INSERT INTO meta (key, value) VALUES ('paper', 'tina-v2 (submissions/arxiv-v2/main-v2.tex and technical-appendices-v2.tex; called tina-v2-alt, main-alt.tex and technical-appendices-alt.tex until upstream commit 2821560)');
INSERT INTO meta (key, value) VALUES ('review_ledger', 'submissions/arxiv-v2/alt-review/claim-ledger.md');
INSERT INTO meta (key, value) VALUES ('schema_version', '1');
INSERT INTO meta (key, value) VALUES ('toolchain', 'Lean 4.33.1, Mathlib v4.33.1 (0df444a). Packages were cloned from an existing local checkout to avoid a slow download; a fresh machine runs ''lake exe cache get''.');

-- sources
INSERT INTO sources (id, path, git_commit, sha256) VALUES ('APP', 'submissions/arxiv-v2/technical-appendices-v2.tex', '6454c7422a04f7b2d1a1658a99cc515da876ac3e', 'd25adcfdb8dc404de189801fc72e39022196d29b4e807571032f719d7b72b2ec');
INSERT INTO sources (id, path, git_commit, sha256) VALUES ('MAIN', 'submissions/arxiv-v2/main-v2.tex', '6454c7422a04f7b2d1a1658a99cc515da876ac3e', '169ee1361a7af70ca1941e50db81878e8d39eb0d416ae7bb2a5b15c005e2873a');

-- claims
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1', NULL, 'lemma', 'Fixed-architecture quadratic projection', 'The admissible policy set S(A) is a closed linear subspace of L2; the unique optimal policy is the Q-weighted orthogonal projection of x* onto S(A); R(A) = (1/2)||x* - Pi x*||_Q^2.', 'APP', 'lem:radner_projection', 147, 214, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1.b', 'C1', 'remark', 'Q-orthogonality and Pythagorean form', 'The projection error is Q-orthogonal to every admissible policy; 2R(A) = ||x*||_Q^2 - ||u*_A||_Q^2.', 'APP', NULL, 216, 218, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1.c', 'C1', 'remark', 'Information inclusion', 'If G_i is contained in G''_i for all i then S(A) is contained in S(A'') and R(A'') <= R(A).', 'APP', 'eq:info_inclusion', 111, 119, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C10', NULL, 'theorem', 'Fresh-local versus stale-global crossover', 'With R_inf > 0 and 0 <= eta_S(0) < 1, fresh-local is strictly better exactly when tau/T > rho* = (1/2) log(1/(1 - eta_S(0))); equality gives equal regret; if eta_S(0) = 1 no finite delay gives a strict local advantage.', 'MAIN', 'thm:local_global_crossover', 486, 501, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C11', NULL, 'example', 'Two-sensor example', 'One fresh sensor has MSE sigma^2/4; both old readings have MSE (sigma^2/2)(1 - exp(-2 tau/T)); the fresh reading wins iff tau > T log(2)/2.', 'MAIN', NULL, 66, 92, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C12', NULL, 'proposition', 'Local explainability under aggregate coupling', 'For f = sum_i (q/2 x_i^2 - theta_i x_i) + (gamma/2)(sum_i x_i)^2 with independent mean-zero equal-variance theta_i: the optimal fresh-local policy is theta_i/(q+gamma) and eta_S(0) = gamma^2 (n-1) / ((q+gamma)(q+gamma(n-1))); R_inf and R_loc as in APP eq:aggregate_Rinf, eq:aggregate_Rloc.', 'MAIN', 'prop:aggregate_local', 563, 613, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13', NULL, 'remark', 'Explicit aggregate-coupling threshold', 'rho*(gamma,n) = (1/2) log[(q+gamma)(q+gamma(n-1)) / (q(q+gamma n))], and R_loc < R_glob(tau) iff tau/T > rho*(gamma,n).', 'MAIN', 'eq:aggregate_rho_star', 615, 647, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13.b', 'C13', 'remark', 'Large-n limit of the threshold', 'rho*(gamma,n) -> (1/2) log(1 + gamma/q) as n -> infinity; local information captures share q/(q+gamma) in the limit.', 'MAIN', 'eq:large_n_threshold', 649, 664, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13.c', 'C13', 'remark', 'Threshold behaviour in the coupling strength', 'gamma = 0 gives eta_S(0) = 0; eta_S(0) and the crossover increase with gamma.', 'MAIN', NULL, 666, 673, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C14', NULL, 'remark', 'Radius objective and one-more-hop criterion', 'With G(r) = (1 - eta_S(r)) exp(-2 tau(r)/T): R(r) = R_inf [1 - G(r)]; one more hop improves performance iff G(r+1) > G(r); R(r)/R_inf = (1 - exp(-2 tau(r)/T)) + exp(-2 tau(r)/T) eta_S(r).', 'MAIN', 'eq:snapshot_gain', 684, 717, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15', NULL, 'proposition', 'Continuous marginal-balance characterization', 'With tau, eta_S continuously differentiable on [0,D], tau'' >= 0, eta_S'' <= 0, 0 <= eta_S < 1: every interior optimal radius satisfies d/dr log[1 - eta_S(r)] = 2 tau''(r)/T.', 'MAIN', 'thm:marginal_balance', 719, 739, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15.b', 'C15', 'remark', 'Single-crossing gives the unique optimum', 'If the difference of the two sides of the balance condition is strictly decreasing in r, its sign identifies the unique optimum (0, D, or the unique interior crossing).', 'MAIN', NULL, 741, 746, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15.c', 'C15', 'remark', 'Comparative statics in T and latency scale', 'Holding the omission curve fixed under single crossing, increasing T moves the preferred radius weakly outward; increasing alpha in tau = alpha tau_0 moves it weakly inward.', 'MAIN', NULL, 747, 751, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C16', NULL, 'proposition', 'Optimal radius for exponential omission', 'For eta_S(r) = eta_0 exp(-2r/l_c), 0 < eta_0 < 1, l_c > 0, tau(r) = r/v, v > 0, continuous r >= 0: the unique global optimum is r* = (l_c/2)[log(eta_0 (1 + vT/l_c))]_+, positive iff eta_0 (1 + vT/l_c) > 1; with cap D the optimum is min{D, r*}.', 'MAIN', 'prop:generic_exponential_radius', 759, 786, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C17', NULL, 'definition', 'Canonical line model', 'Zero-mean jointly Gaussian space-time field on the infinite line with covariance sigma^2 exp(-|z-z''|/l_s) exp(-|t-s|/T); target x*(z,t) = integral of w_{l_c}(u) theta(z+u,t) du with w = exp(-|u|/l_c)/(2 l_c); loss (q/2)[x(z) - x*(z)]^2; observation of all field values within distance r; tau(r) = r/v; regret per unit length.', 'MAIN', 'subsec:canonical_line_model', 794, 837, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C17.b', 'C17', 'remark', 'Composition law holds in the continuum model', 'For the canonical field model, every location z, radius r and delay tau, with a = exp(-tau/T): E[x*(z,t) | O_r(z,t-tau)] = a E[x*(z,t-tau) | O_r(z,t-tau)], and the delayed interval retains a^2 times the gain (over acting without observations) of a fresh interval of the same radius. Equivalently, though the paper does not display it, R(r,tau) = (1 - a^2) R_inf + a^2 R(r,0). Stated and argued in an unlabelled paragraph, not a numbered result.', 'MAIN', NULL, 839, 855, 'lean', 'D', 'Was kind ''implicit'' (used but not stated) when the ledger was aligned at 4a9b87e. Upstream commit 284a0e0 added the paragraph at main-v2.tex 839-855. It has no \label.');
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C18', NULL, 'lemma', 'Exponential omission by self-similarity', 'In the canonical model eta_S(r) = eta_0 exp(-2r/l_c) with eta_0 = l_c/(l_c + 2 l_s).', 'MAIN', 'prop:canonical_eta_S', 857, 880, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C19', NULL, 'theorem', 'Optimal synchronized-snapshot radius in the canonical model', 'r* = (l_c/2)[log((l_c + vT)/(l_c + 2 l_s))]_+ is the unique optimal radius on the infinite line; r* > 0 iff vT > 2 l_s.', 'MAIN', 'thm:canonical_optimal_radius', 883, 920, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C19.b', 'C19', 'remark', 'Comparative statics of the canonical radius', 'In the interior regime r* increases with T, increases with v, decreases with l_s, and increases with l_c.', 'MAIN', NULL, 899, 920, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C2', NULL, 'corollary', 'Coupled conditional normal equations', 'The team optimum satisfies E[(Q u* - b(theta))_i | G_i] = 0 for every i; these equations are necessary and sufficient; agentwise conditional means are not optimal in general.', 'APP', 'cor:conditional_normal_equations', 220, 269, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C20', NULL, 'remark', 'Large decision-range limit', 'With vT > 2 l_s fixed, r* -> (vT - 2 l_s)/2 as l_c -> infinity.', 'MAIN', NULL, 932, 935, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C21', NULL, 'numeric', 'Fig. local-global phase', 'Monte Carlo crossover estimates agree with the exact boundary; what the estimator does and does not check.', 'MAIN', 'fig:local-global-phase', 947, 978, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C22', NULL, 'numeric', 'Fig. radius-regret', 'Three regimes with constrained optima 0, 0.62638, 2 for l_c = 1, D = 2.', 'MAIN', 'fig:radius-regret', 980, 1009, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C23', NULL, 'numeric', 'Fig. decision relevance', '64-node ring, T = 6, latency 0.12/hop, l_c = 0.7, 2, 6 gives optimal radii 1, 2, 5.', 'MAIN', 'fig:decision-relevance', 1011, 1046, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C24', NULL, 'numeric', 'Fig. general graphs', 'Path, ring, grid, random geometric graph: reference optima 2, 2, 3, 2; diameters 63, 32, 14, 8.', 'MAIN', 'fig:general-graphs', 1048, 1089, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C25', NULL, 'prose', 'Abstract and contribution list', 'Abstract: ''Using the classical Marschak--Radner decomposition, we derive the delay threshold beyond which fresh local information outperforms a complete but older global view''; ''This comparison allows non-Gaussian states and nonlinear decision rules''; ''looking beyond the local node pays only when information travels more than twice the spatial correlation length in one coherence time''; ''increasing only the reach of the decision weights from 0.7 to 6 hops shifts the optimal observation radius from one to five hops''. Three contributions posed as questions: the crossover threshold, the optimal synchronized radius, decision-dependent architectures. The introduction attributes the delayed-information decomposition to Marschak and Radner.', 'MAIN', NULL, 46, 181, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C26', NULL, 'prose', 'Related-work positioning and attribution', 'Positioning against Radner, Marschak-Radner, Krainak-Speyer-Marcus, Ballotta et al. and age of information, now including Jiang-Zhou and Munari et al. on spatial fields. Attribution: Marschak-Radner Ch. 7 Eq. (6.5) gives the marginal balance of C15, and the group-size-one case of their Eq. (6.6) gives the local information share 1 - eta_S(0) of C12.', 'MAIN', 'sec:related_work', 1091, 1199, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C27', NULL, 'prose', 'Discussion: scope, limitations, assumptions per result', 'Which assumptions each result uses (composition law: any fixed Q > 0, non-Gaussian states allowed; canonical radius: infinite line, jointly Gaussian field with separable exponential covariance, exponential decision kernel, uncoupled squared loss, tau(r) = r/v; finite-graph examples: Gaussian states and Q = I). Design implication: under the single-crossing condition an interior optimal radius balances marginal gain against delay loss; with no interior crossing the optimum is at a boundary; on a general finite graph compare all admissible radii.', 'MAIN', 'sec:discussion_conclusions', 1201, 1280, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3', NULL, 'remark', 'Common information: vector conditional mean is optimal', 'If every agent observes the same Z, m = E[x* | Z] is the unique optimum regardless of off-diagonal Q.', 'APP', NULL, 271, 276, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3.b', 'C3', 'remark', 'Degenerate normalization R_inf = 0', 'In centered coordinates R_inf = 0 and Q > 0 imply x* = 0 a.s.; the zero rule has zero regret under every architecture, so the unnormalized composition law still holds.', 'APP', NULL, 287, 292, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3.c', 'C3', 'prose', 'Delay monotonicity, stationarity versus ergodicity remarks', 'Under a stationary Markov environment prediction loss from a common old snapshot is nondecreasing in delay; stationarity makes expected snapshot regret time-invariant; sample-path averages additionally need ergodicity.', 'APP', NULL, 277, 296, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4', NULL, 'assumption', 'Common temporal prediction rule', 'Stationary state with finite second moments and, for each delay tau, theta_t = a theta_{t-tau} + eps with a = exp(-tau/T), T > 0, and E[eps | theta_{t-tau}] = 0.', 'MAIN', 'eq:state_innovation_decomposition', 328, 350, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4.b', 'C4', 'remark', 'Stationary AR(1) satisfies the prediction rule', 'A stationary AR(1) process with coefficient 0 < c < 1 and independent mean-zero finite-variance innovations has lag-k prediction coefficient c^k (composition weights 1 - c^(2k) and c^(2k)).', 'MAIN', NULL, 359, 361, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4.c', 'C4', 'remark', 'Stationary Gaussian OU satisfies the prediction rule', 'The stationary Gaussian Ornstein-Uhlenbeck process (APP eq:OU_process) has independent Gaussian innovations and Cov(theta_t, theta_s) = exp(-|t-s|/T) Sigma_S, hence satisfies C4.', 'APP', 'app:temporal-special-cases', 298, 317, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C5', NULL, 'definition', 'Quadratic cost and completing the square', 'f(x,theta) = (1/2) x''Qx - b(theta)''x + c(theta), Q symmetric positive definite, x* = Q^{-1} b(theta); f(x,theta) - f(x*,theta) = (1/2)(x-x*)''Q(x-x*).', 'APP', 'eq:complete_square', 25, 68, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C5.b', 'C5', 'remark', 'Centering the affine model is without loss', 'With b affine, translating observations and actions by known means is a bijection of admissible rules that leaves x - x* unchanged; the centered target is K theta^c.', 'APP', NULL, 87, 97, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6', NULL, 'definition', 'Architectures, admissible rules, regret, R_inf, eta_S', 'Neighborhood N_r(i); observation Z_i^(r,tau) = (theta_{j,t-tau} : j in N_r(i)); admissible rule u_i = g_i(Z_i) with finite second moment; R(A) = inf (1/2) E[(u-x*)''Q(u-x*)]; R_inf; eta_S(r) = R(A_{r,0})/R_inf.', 'MAIN', 'eq:architecture_regret', 204, 326, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6.b', 'C6', 'remark', 'No-information loss formula', 'The best no-information action is zero in centered coordinates, with loss R_inf = (1/2) E[x*''Q x*] = (1/2) tr(K''QK Sigma_S).', 'MAIN', 'eq:Rinf_general', 311, 316, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6.c', 'C6', 'remark', 'Omission share is in [0,1], nonincreasing, zero at the diameter', '0 <= eta_S(r) <= 1; larger fresh neighborhoods cannot increase it; at the diameter of a finite connected graph the fresh view is complete and omission is zero.', 'MAIN', 'eq:eta_S_definition', 317, 326, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C7', NULL, 'theorem', 'Spatio-temporal composition', 'R(A_{r,tau}) = (1 - a^2) R_inf + a^2 R(A_{r,0}), a = exp(-tau/T), for every radius r and finite delay tau >= 0, over all admissible finite-second-moment rules and any deterministic Q > 0.', 'MAIN', 'thm:spatiotemporal_composition', 379, 443, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C7.b', 'C7', 'remark', 'Normalized composition law', 'For R_inf > 0: 1 - R(A_{r,tau})/R_inf = exp(-2 tau/T) [1 - eta_S(r)].', 'MAIN', 'eq:regret_composition_normalized', 391, 396, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8', NULL, 'corollary', 'Exact stale-global regret', 'A complete snapshot of age tau gives R_glob(tau) = (1 - exp(-2 tau/T)) R_inf.', 'MAIN', 'thm:OU_stale_regret', 453, 465, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8.b', 'C8', 'remark', 'Optimal stale-global action', 'The optimal global action is a K theta_{t-tau}.', 'MAIN', NULL, 466, 466, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8.c', 'C8', 'remark', 'Small-delay expansion and large-delay limit', 'R_glob is zero at zero delay, grows as 2 (tau/T) R_inf + o(tau/T), and tends to R_inf as delay grows.', 'MAIN', NULL, 466, 469, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C9', NULL, 'remark', 'Unequal-rate formula for a complete old snapshot', 'If a complete old snapshot reveals independent stationary OU modes with coherence times T_k and w_k is the share of R_inf > 0 attributable to mode k, then 1 - R_glob(tau)/R_inf = sum_k w_k exp(-2 tau/T_k).', 'MAIN', NULL, 471, 484, 'lean', 'D', NULL);

-- claim_deps
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C1', 'C5', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C1', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C1.b', 'C1', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C1.c', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C10', 'C6', 'setup', 'eta_S(0) = R_loc/R_inf');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C10', 'C8', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C11', 'C10', 'instantiates', 'intro example; self-contained derivation in the text');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C12', 'C1.b', 'uses', 'appendix derivation only (C12/p2)');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C12', 'C2', 'uses', 'appendix derivation only (C12/p2)');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C12', 'C5', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C12', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C13', 'C10', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C13', 'C12', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C13.b', 'C13', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C13.c', 'C13', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C14', 'C7', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C15', 'C14', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C15.b', 'C15', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C15.c', 'C15.b', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C16', 'C14', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C17', 'C4', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C17', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C17.b', 'C17', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C18', 'C17', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C19', 'C16', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C19', 'C17.b', 'uses', 'Prop. C16 is stated ''Under Theorem C7''');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C19', 'C18', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C19.b', 'C19', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C2', 'C1', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C20', 'C19', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C21', 'C13', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C22', 'C16', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C23', 'C14', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C23', 'C7', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C24', 'C14', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C24', 'C7', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C25', 'C10', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C25', 'C19', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C25', 'C23', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C25', 'C7', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C26', 'C7', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C27', 'C19', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C27', 'C7', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C3', 'C5', 'setup', 'stated for the quadratic cost; the proof does not use completing the square (decision 2026-11-14, F16)');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C3', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C3.b', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C3.c', 'C3', 'evidence', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C4.b', 'C4', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C4.c', 'C4', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C5.b', 'C5', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C6', 'C5', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C6.b', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C6.c', 'C1.c', 'uses', 'extra observations can be ignored');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C6.c', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C7', 'C4', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C7', 'C5', 'setup', 'tracking loss');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C7', 'C6', 'setup', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C7.b', 'C7', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C8', 'C7', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C8.b', 'C7', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C8.c', 'C8', 'uses', NULL);
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C9', 'C4.c', 'setup', 'independent OU modes');
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C9', 'C6', 'setup', NULL);

-- proofs
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C1/p1', 'C1', 1, NULL, 'in_paper', 1, 'Closed subspace plus Hilbert projection.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C10/p1', 'C10', 1, NULL, 'in_paper', 1, 'Normalize both regrets and rearrange.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C11/p1', 'C11', 1, NULL, 'in_paper', 1, 'Direct mean-squared-error comparison.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C12/p1', 'C12', 1, NULL, 'in_paper', 1, 'Main text: centered decomposition and pointwise minimization.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C12/p2', 'C12', 2, NULL, 'in_paper', 0, 'Appendix: coupled normal equations, Sherman-Morrison trace, Pythagorean identity.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C14/p1', 'C14', 1, NULL, 'in_paper', 1, 'Direct substitution of the composition law, then the one-more-hop criterion and the loss decomposition read off it.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C15/p1', 'C15', 1, NULL, 'in_paper', 1, 'First-order condition for log G.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C16/p1', 'C16', 1, NULL, 'in_paper', 1, 'Sign analysis of G''.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C17.b/p1', 'C17.b', 1, NULL, 'in_paper', 1, 'Innovation field is uncorrelated with, hence independent of, the whole old field; the conditional mean of the target scales by a; the gain is (q/2) times the variance of the conditional mean; stationarity equates the delayed and fresh variances.', '2026-11-14T13:50:21');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C18/p1', 'C18', 1, NULL, 'in_paper', 1, 'Appendix: variance ratio, tail split, spatial Markov property, shift invariance, covariance integrals.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C18/p2', 'C18', 2, NULL, 'in_paper', 0, 'Main-text sketch of C18/p1.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C19.b/p1', 'C19.b', 1, NULL, 'in_paper', 1, 'Two partial derivatives and an integral representation.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C19/p1', 'C19', 1, NULL, 'in_paper', 1, 'Substitute the lemma into the exponential-omission proposition.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C2/p1', 'C2', 1, NULL, 'in_paper', 1, 'First-order condition with one-agent perturbations; converse by expansion.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C3.b/p1', 'C3.b', 1, NULL, 'in_paper', 1, 'Zero target, zero rule.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C3/p1', 'C3', 1, NULL, 'in_paper', 1, 'Orthogonality by conditioning, then error expansion.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C5.b/p1', 'C5.b', 1, NULL, 'in_paper', 1, 'The centered desired action is K theta^c; translation by known means is a bijection of the admissible rules that leaves x - x* unchanged.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C6.c/p1', 'C6.c', 1, NULL, 'in_paper', 1, 'Extra observations can be ignored; complete view at the diameter.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C7/p1', 'C7', 1, NULL, 'in_paper', 1, 'Innovation split plus rescaling of the joint rule; no projection theorem used.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C8/p1', 'C8', 1, NULL, 'in_paper', 1, 'Complete fresh snapshot makes x* feasible, so the fresh term vanishes.', '2026-11-13T13:26:00');

-- steps
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C1/p1/s1', 'C1/p1', 1, 'S(A) is a linear subspace', 'Linearity of $\mathcal{S}(\mathcal{A})$ follows because
$\mathcal{G}_i$-measurability is preserved under linear combinations.', 'APP', 183, 184);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C1/p1/s2', 'C1/p1', 2, 'S(A) is closed', 'Closedness follows because an $L^2$ limit of
$\mathcal{G}_i$-measurable random variables admits a
$\mathcal{G}_i$-measurable version.', 'APP', 185, 187);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C1/p1/s3', 'C1/p1', 3, 'Excess cost is half the squared Q-norm of u - x*', 'For any admissible policy $u$, \eqref{eq:complete_square} gives
\begin{align}
    \mathbb{E}
    \left[
        f(u,\theta_t)
        -
        f(x_t^\star,\theta_t)
    \right]
    &=
    \frac{1}{2}
    \mathbb{E}
    \left[
        (u-x_t^\star)^\top
        Q
        (u-x_t^\star)
    \right]
    \nonumber\\
    &=
    \frac{1}{2}
    \|u-x_t^\star\|_Q^2.
    \label{eq:projection_proof}
\end{align}', 'APP', 189, 210);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C1/p1/s4', 'C1/p1', 4, 'Projection onto the closed subspace gives optimum and regret', 'Minimizing this expression over the closed subspace
$\mathcal{S}(\mathcal{A})$ is the standard Hilbert-space projection problem,
yielding \eqref{eq:optimal_projection} and \eqref{eq:projection_regret}.', 'APP', 211, 213);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C10/p1/s1', 'C10/p1', 1, 'Comparison is eta_S(0) < 1 - exp(-2 tau/T)', 'Divide the two regrets by $R_\infty$: the comparison is
$\eta_S(0)<1-e^{-2\tau/T}$.', 'MAIN', 499, 500);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C10/p1/s2', 'C10/p1', 2, 'Rearrange to the threshold and the equality case', 'Rearranging gives the threshold and equality case.', 'MAIN', 500, 500);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C11/p1/s1', 'C11/p1', 1, 'One fresh sensor: estimate X/2, error sigma^2/4', 'With only $X_t$, our best estimate is $X_t/2$. The error is the missing term
$Y_t/2$, so the mean squared error is $\sigma^2/4$.', 'MAIN', 72, 73);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C11/p1/s2', 'C11/p1', 2, 'Both old readings: estimate a Z_old, error Var(Z)(1 - a^2)', 'With both old readings,
we know the old average $Z_{t-\tau}$ exactly. Suppose the two signal processes are independent and stationary, and each
satisfies the scalar conditional-mean prediction rule
$\mathbb E[X_t\mid X_{t-\tau}]=e^{-\tau/T}X_{t-\tau}$ (and likewise
for $Y$), where $T$ is the coherence time. Our best estimate today is then $e^{-\tau/T}Z_{t-\tau}$.
Its mean squared error is
$\operatorname{Var}(Z_t)(1-e^{-2\tau/T})$.', 'MAIN', 73, 79);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C11/p1/s3', 'C11/p1', 3, 'Var(Z) = sigma^2/2 and the inequality is tau > T log(2)/2', 'Since
$\operatorname{Var}(Z_t)=\sigma^2/2$, the fresh reading wins when
\[
    \frac{\sigma^2}{4}
    <\frac{\sigma^2}{2}(1-e^{-2\tau/T})
    \quad\Longleftrightarrow\quad
    \tau>\frac{T\log 2}{2}\approx 0.35T.
\]', 'MAIN', 79, 86);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s1', 'C12/p1', 1, 'Split each rule into mean plus centered part', 'For any admissible $u_i=g_i(\theta_i)$, write
$u_i=\mu_i+\widetilde u_i$, where $\mu_i=\mathbb E[u_i]$ and
$\mathbb E[\widetilde u_i]=0$.', 'MAIN', 592, 594);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s2', 'C12/p1', 2, 'Expected cost under independence and zero means', 'Independence across agents and zero state
means give
\begin{align}
\mathbb E[f(u,\theta)]={}&
\sum_i\mathbb E\left[\frac{q+\gamma}{2}\widetilde u_i^2
-\theta_i\widetilde u_i\right]
+\frac q2\sum_i\mu_i^2+\frac\gamma2\left(\sum_i\mu_i\right)^2.
\label{eq:aggregate_centered_cost}
\end{align}', 'MAIN', 594, 602);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s3', 'C12/p1', 3, 'Mean terms are minimized at zero', 'The mean terms are minimized at zero.', 'MAIN', 603, 603);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s4', 'C12/p1', 4, 'Each centered term minimized pointwise by theta_i/(q+gamma)', 'Each remaining term is minimized
pointwise by $\widetilde u_i=\theta_i/(q+\gamma)$, which is feasible and
has zero mean.', 'MAIN', 603, 605);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s5', 'C12/p1', 5, 'Local cost -n sigma^2/[2(q+gamma)]; best constant cost zero', 'Thus the expected local cost is
$-n\sigma^2/[2(q+\gamma)]$, and the best constant cost is zero.', 'MAIN', 605, 606);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s6', 'C12/p1', 6, 'Eigenvalues of Q and the full-information cost', 'The eigenvalues of $Q$ are $q+\gamma n$ once and $q$ with multiplicity
$n-1$. The full-information expected cost is therefore
$-(\sigma^2/2)[(n-1)/q+1/(q+\gamma n)]$.', 'MAIN', 607, 609);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s7', 'C12/p1', 7, 'Subtract to get R_inf, R_loc; take the ratio', 'Subtracting this cost from the local and constant costs gives
Eqs.~\eqref{eq:aggregate_Rinf}--\eqref{eq:aggregate_Rloc} in
Appendix~\ref{app:technical-aggregate}; their ratio is the stated omission share.', 'MAIN', 610, 612);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s1', 'C12/p2', 1, 'Inverse of Q', 'For $Q=qI+\gamma\mathbf1\mathbf1^\top$,
\[
Q^{-1}=\frac1q\left(I-\frac{\gamma}{q+\gamma n}\mathbf1\mathbf1^\top\right).
\]', 'APP', 345, 348);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s2', 'C12/p2', 2, 'Normal equations with Q_ii = q+gamma, Q_ij = gamma, b_i = theta_i', 'Recall the coupled normal equations \eqref{eq:block_conditional_normal_equations}
from Appendix~\ref{app:technical-projection}:
\[
 Q_{ii}u_i+\sum_{j\ne i}Q_{ij}\mathbb E[u_j\mid\mathcal G_i]
 =\mathbb E[b_i(\theta_t)\mid\mathcal G_i].
\]
Here $Q_{ii}=q+\gamma$, $Q_{ij}=\gamma$ for $j\ne i$, and $b_i(\theta)=\theta_i$.', 'APP', 350, 356);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s3', 'C12/p2', 3, 'Independence gives E[u_j | G_i] = mu_j', 'Let $\mu_j=\mathbb E[u_j]$. For $j\ne i$, the policy $u_j$ is a function of $\theta_{j,t}$,
which is independent of $\theta_{i,t}$, so
\[
\mathbb E[u_j\mid\mathcal G^{\mathrm{loc}}_{i,t}]
=\mathbb E[u_j]=\mu_j,
\]
while $\theta_{i,t}$ is
$\mathcal G^{\mathrm{loc}}_{i,t}$-measurable.', 'APP', 357, 364);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s4', 'C12/p2', 4, 'Normal equation reduces to (q+gamma) u_i + gamma sum mu_j - theta_i = 0', 'The conditional normal equation
\eqref{eq:block_conditional_normal_equations} therefore gives
\[
(q+\gamma)u_i
+\gamma\sum_{j\ne i}\mu_j
-\theta_{i,t}=0.
\]', 'APP', 364, 370);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s5', 'C12/p2', 5, 'Means vanish, so u_i = theta_i/(q+gamma)', 'Taking expectations yields
\[
q\mu_i+\gamma\sum_j\mu_j=0.
\]
Summing over $i$ implies $\sum_j\mu_j=0$, hence every $\mu_i=0$ and
$u_i=\theta_{i,t}/(q+\gamma)$, which proves
\eqref{eq:optimal_local_shared}.', 'APP', 371, 377);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s6', 'C12/p2', 6, 'No-information regret from tr(Q^{-1})', '\emph{No-information regret.} Here $B=I$ and $\Sigma_S=\sigma^2I$, so by \eqref{eq:Rinf_general}, $R_\infty=\tfrac{\sigma^2}2\operatorname{tr}(Q^{-1})$. From the Sherman--Morrison formula above,

\[
\operatorname{tr}(Q^{-1})=\frac1q\Big(n-\frac{\gamma n}{q+\gamma n}\Big)=\frac{n\,(q+\gamma(n-1))}{q\,(q+\gamma n)},
\]

which gives \eqref{eq:aggregate_Rinf}.', 'APP', 379, 385);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s7', 'C12/p2', 7, 'Local regret from the Pythagorean identity', '\emph{Local regret.} By the Pythagorean form of Lemma~\ref{lem:radner_projection} (the orthogonality identity in Appendix~\ref{app:technical-projection}, with both $x^\star$ and $u^{\rm loc}$ mean zero), $2R_{\rm loc}=\|x^\star\|_Q^2-\|u^{\rm loc}\|_Q^2=2R_\infty-\|u^{\rm loc}\|_Q^2$. Since $u^{\rm loc}=\theta/(q+\gamma)$ and $\operatorname{tr}(Q)=n(q+\gamma)$,

\[
\|u^{\rm loc}\|_Q^2=\frac{\sigma^2\operatorname{tr}(Q)}{(q+\gamma)^2}=\frac{n\sigma^2}{q+\gamma}.
\]

Therefore

\[
R_{\rm loc}=\frac{n\sigma^2}{2}\left[\frac{q+\gamma(n-1)}{q(q+\gamma n)}-\frac{1}{q+\gamma}\right]=\frac{n\sigma^2}{2}\cdot\frac{(q+\gamma(n-1))(q+\gamma)-q(q+\gamma n)}{q(q+\gamma)(q+\gamma n)} .
\]

The numerator reduces to $\gamma^2(n-1)$, which gives \eqref{eq:aggregate_Rloc}.', 'APP', 387, 399);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s8', 'C12/p2', 8, 'Share is the ratio', '\emph{Share.} Dividing \eqref{eq:aggregate_Rloc} by \eqref{eq:aggregate_Rinf}, the factors $n\sigma^2/2$ and $q(q+\gamma n)$ cancel, leaving \eqref{eq:aggregate_eta}.', 'APP', 401, 401);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C14/p1/s1', 'C14/p1', 1, 'R(r) = R_inf [1 - G(r)] from C7', 'Writing $R(r)=R(\mathcal A_{r,\tau(r)})$,
Theorem~\ref{thm:spatiotemporal_composition} gives
$R(r)=R_\infty[1-G(r)]$, so the best radius maximizes $G(r)$.', 'MAIN', 692, 694);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C14/p1/s2', 'C14/p1', 2, 'One more hop improves performance exactly when G(r+1) > G(r)', 'On a finite graph, one more hop improves performance exactly when
\begin{equation}
G(r+1)>G(r).
\label{eq:discrete_radius_improvement}
\end{equation}', 'MAIN', 698, 702);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C14/p1/s3', 'C14/p1', 3, 'Loss separates into the delay component and the remaining scope component', 'The loss separates into the two components plotted in
Fig.~\ref{fig:radius-regret}:
\begin{equation}
\frac{R(r)}{R_\infty}
=\underbrace{1-e^{-2\tau(r)/T}}_{\text{loss from delay}}
+\underbrace{e^{-2\tau(r)/T}\eta_S(r)}_{\text{remaining loss from limited scope}}.
\label{eq:R_decomposition}
\end{equation}', 'MAIN', 709, 716);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s1', 'C15/p1', 1, 'Maximizing G is maximizing log G', 'Since $G(r)>0$, maximizing $G$ is equivalent to maximizing $\log G$.', 'MAIN', 736, 736);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s2', 'C15/p1', 2, 'Interior optimum has (log G)'' = 0', 'At an interior optimum, $(\log G)''=0$;', 'MAIN', 737, 737);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s3', 'C15/p1', 3, 'Differentiate the snapshot gain', 'differentiating
Eq.~\eqref{eq:snapshot_gain} gives the stated equality.', 'MAIN', 737, 738);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s1', 'C16/p1', 1, 'Formula for G''(r)', 'Differentiating the captured benefit gives
\[
G''(r)=2e^{-2r/(vT)}\left[
\eta_0\left(\frac{1}{vT}+\frac{1}{\ell_c}\right)e^{-2r/\ell_c}
-\frac{1}{vT}\right].
\]', 'MAIN', 775, 780);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s2', 'C16/p1', 2, 'The bracket decreases strictly to a negative limit', 'The bracket decreases strictly to a negative limit.', 'MAIN', 781, 781);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s3', 'C16/p1', 3, 'Nonpositive at zero: G decreasing, zero is the unique maximum', 'If its value at zero
is nonpositive, $G$ decreases for all positive radii and zero is its unique
maximum, including when the initial derivative is zero.', 'MAIN', 781, 783);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s4', 'C16/p1', 4, 'Otherwise G rises to a unique crossing then falls', 'Otherwise $G$
increases up to its unique crossing and decreases thereafter.', 'MAIN', 783, 784);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s5', 'C16/p1', 5, 'Solve for the crossing', 'Solving for
the crossing gives the formula;', 'MAIN', 784, 785);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s6', 'C16/p1', 6, 'A cap truncates the maximizer', 'a cap truncates the maximizing radius.', 'MAIN', 785, 785);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s1', 'C17.b/p1', 1, 'Innovation is uncorrelated with the old field', 'Fix a location $z$, a radius $r$, and a delay $\tau$, and write
$a=e^{-\tau/T}$. By the separable covariance in
\eqref{eq:canonical_space_time_covariance}, the innovation
$\theta(y,t)-a\theta(y,t-\tau)$ is uncorrelated with
$\theta(y'',t-\tau)$ for every $y,y''$.', 'MAIN', 839, 843);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s2', 'C17.b/p1', 2, 'Joint Gaussianity gives independence from the whole old field', 'Joint Gaussianity therefore makes
the innovation field independent of the entire field at time $t-\tau$.', 'MAIN', 843, 844);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s3', 'C17.b/p1', 3, 'Conditional mean of the target scales by a', 'Integrating against the decision kernel in \eqref{eq:canonical_target}
and conditioning on the observed interval gives
\[
\mathbb E[x^\star(z,t)\mid \mathcal O_r(z,t-\tau)]
= a\,\mathbb E[x^\star(z,t-\tau)\mid \mathcal O_r(z,t-\tau)].
\]', 'MAIN', 845, 850);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s4', 'C17.b/p1', 4, 'Gain is (q/2) times the variance of the conditional mean', 'Under the pointwise squared loss, the gain over acting without observations
is $q/2$ times the variance of the conditional mean.', 'MAIN', 851, 852);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s5', 'C17.b/p1', 5, 'Stationarity: delayed and fresh conditional means have the same variance', 'By stationarity,
the conditional mean at time $t-\tau$ has the same variance as its
fresh-snapshot counterpart at time $t$.', 'MAIN', 852, 854);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C17.b/p1/s6', 'C17.b/p1', 6, 'Delayed interval retains a^2 of the fresh gain', 'The delayed interval therefore
retains $a^2$ times the gain from a fresh interval of the same radius.', 'MAIN', 854, 855);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s1', 'C18/p1', 1, 'Step 0: omission is a conditional-variance ratio', 'By spatial stationarity, take $z=0$ and suppress the time argument. Write $\beta_c\triangleq1/\ell_c$ and $\beta_s\triangleq1/\ell_s$ for the inverse lengths, so $w(u)=\tfrac{\beta_c}{2}e^{-\beta_c|u|}$ and $\operatorname{Cov}(\theta(u),\theta(u''))=\sigma^2e^{-\beta_s|u-u''|}$.

\textbf{Step 0 (omission is a variance ratio).} With $Q=qI$ the optimal policy given $\mathcal O_r$ is $\mathbb E[x^\star(0)\mid\mathcal O_r]$. Its expected loss is $\tfrac q2\,\mathbb E\big[\operatorname{Var}(x^\star(0)\mid\mathcal O_r)\big]$. For a Gaussian field the conditional variance is a deterministic number: it does not depend on the observed values (the Gaussian conditional covariance is independent of the observed values). Since $R_\infty=\tfrac q2\operatorname{Var}(x^\star(0))$,

\[
\eta_S(r)=\frac{\operatorname{Var}(x^\star(0)\mid\mathcal O_r)}{\operatorname{Var}(x^\star(0))}.
\]', 'APP', 413, 419);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s2', 'C18/p1', 2, 'Step 1: split target into observed middle and two tails', '\textbf{Step 1 (split into observed middle and two tails).} Write $x^\star(0)=M_r+T_r^++T_r^-$, where

\[
M_r=\int_{-r}^{r}w(u)\theta(u)\,du,\qquad T_r^+=\int_r^\infty w(u)\theta(u)\,du,\qquad T_r^-=\int_{-\infty}^{-r}w(u)\theta(u)\,du .
\]

The middle $M_r$ is computed from observed values, so it contributes no conditional variance.', 'APP', 421, 427);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s3', 'C18/p1', 3, 'Step 2: rewrite the right tail with weight exp(-beta_c r)', '\textbf{Step 2 (rewrite the right tail).} Substituting $u=r+s$,

\[
T_r^+=\frac{\beta_c}{2}e^{-\beta_c r}\,Y_r,\qquad Y_r\triangleq\int_0^\infty e^{-\beta_c s}\,\theta(r+s)\,ds .
\]', 'APP', 429, 433);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s4', 'C18/p1', 4, 'Step 3: spatial Markov property', '\textbf{Step 3 (spatial Markov property).} By the exponential-covariance model in Section~\ref{subsec:canonical_line_model}, the field is Markov in $z$. Given the observed segment $[-r,r]$, the right tail $\{\theta(u):u>r\}$ and the left tail $\{\theta(u):u<-r\}$ are conditionally independent, and each depends on the segment only through its adjacent endpoint $\theta(r)$ or $\theta(-r)$. Therefore

\[
\operatorname{Var}(T_r^+\mid\mathcal O_r)=\operatorname{Var}(T_r^+\mid\theta(r)),\qquad \operatorname{Var}(T_r^-\mid\mathcal O_r)=\operatorname{Var}(T_r^-\mid\theta(-r)),\qquad \operatorname{Cov}(T_r^+,T_r^-\mid\mathcal O_r)=0 .
\]', 'APP', 435, 439);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s5', 'C18/p1', 5, 'Step 4: tail variance does not depend on r; eta_S(r) = eta_S(0) exp(-2r/l_c)', '\textbf{Step 4 (the tail variance does not depend on $r$).} Define $C\triangleq\operatorname{Var}(Y_0\mid\theta(0))$. Shifting the field by $r$ does not change its law, so $\operatorname{Var}(Y_r\mid\theta(r))=C$ for every $r$. By reflection symmetry (the covariance depends only on $|u-u''|$), the left tail gives the same value. Hence

\[
\operatorname{Var}(x^\star(0)\mid\mathcal O_r)=2\Big(\frac{\beta_c}{2}\Big)^2e^{-2\beta_c r}\,C=\frac{\beta_c^2}{2}e^{-2\beta_c r}\,C .
\]

At $r=0$ the same argument applies with $\mathcal O_0=\sigma(\theta(0))$ and $M_0=0$, giving $\operatorname{Var}(x^\star(0)\mid\theta(0))=\tfrac{\beta_c^2}{2}C$. Dividing, $\eta_S(r)=\eta_S(0)\,e^{-2\beta_c r}=\eta_S(0)\,e^{-2r/\ell_c}$. The unknown constant $C$ cancels, so it never has to be computed.', 'APP', 441, 447);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s6', 'C18/p1', 6, 'Step 5a: eta_S(0) = 1 - Corr^2', '\textbf{Step 5 (the constant $\eta_S(0)$).} Conditioning on the single Gaussian variable $\theta(0)$ gives $\operatorname{Var}(x^\star(0)\mid\theta(0))=\operatorname{Var}(x^\star(0))\big(1-\operatorname{Corr}(x^\star(0),\theta(0))^2\big)$ (the Gaussian conditional covariance is independent of the observed values), so $\eta_S(0)=1-\operatorname{Corr}^2$. Two moments are needed.', 'APP', 449, 449);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s7', 'C18/p1', 7, 'Step 5b: covariance of the target with the local value', '\emph{Covariance with the local value:}

\[
\operatorname{Cov}(x^\star(0),\theta(0))=\int_{\mathbb R}w(u)\,\sigma^2e^{-\beta_s|u|}\,du=\frac{\sigma^2\beta_c}{2}\int_{\mathbb R}e^{-(\beta_c+\beta_s)|u|}\,du=\frac{\sigma^2\beta_c}{\beta_c+\beta_s}.
\]', 'APP', 451, 455);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s8', 'C18/p1', 8, 'Step 5c: variance of the target', '\emph{Variance of the target:} $\operatorname{Var}(x^\star(0))=\frac{\sigma^2\beta_c^2}{4}\,I$, where $I\triangleq\iint e^{-\beta_c(|u|+|v|)-\beta_s|u-v|}\,du\,dv$.

To evaluate $I$, define the inner integral $h(u)\triangleq\int_{\mathbb R}e^{-\beta_c|v|}e^{-\beta_s|u-v|}\,dv$. Then $h$ is even, so $I=2\int_0^\infty e^{-\beta_c u}h(u)\,du$. For $u\ge0$, split the $v$-integral at $0$ and $u$:

\[
h(u)=\underbrace{\frac{e^{-\beta_s u}}{\beta_c+\beta_s}}_{v<0}+\underbrace{\frac{e^{-\beta_c u}-e^{-\beta_s u}}{\beta_s-\beta_c}}_{0\le v\le u}+\underbrace{\frac{e^{-\beta_c u}}{\beta_c+\beta_s}}_{v>u}.
\]

(The middle term is read as $u\,e^{-\beta_c u}$ when $\beta_s=\beta_c$.) Multiply by $e^{-\beta_c u}$ and integrate over $u\ge0$ term by term:

\[
\frac{1}{(\beta_c+\beta_s)^2},\qquad \frac{1}{\beta_s-\beta_c}\Big(\frac{1}{2\beta_c}-\frac{1}{\beta_c+\beta_s}\Big)=\frac{1}{2\beta_c(\beta_c+\beta_s)},\qquad \frac{1}{2\beta_c(\beta_c+\beta_s)} .
\]

Summing and doubling,

\begin{equation}
I=2\left[\frac{1}{(\beta_c+\beta_s)^2}+\frac{1}{\beta_c(\beta_c+\beta_s)}\right]=\frac{2(2\beta_c+\beta_s)}{\beta_c(\beta_c+\beta_s)^2},\qquad \operatorname{Var}(x^\star(0))=\frac{\sigma^2\beta_c(2\beta_c+\beta_s)}{2(\beta_c+\beta_s)^2}.
\end{equation}', 'APP', 457, 475);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s9', 'C18/p1', 9, 'Step 5d: combine to eta_S(0) = l_c/(l_c + 2 l_s)', '\emph{Combine.} With $\operatorname{Var}(\theta(0))=\sigma^2$,

\[
\operatorname{Corr}^2=\frac{\big(\sigma^2\beta_c/(\beta_c+\beta_s)\big)^2}{\sigma^2\cdot\sigma^2\beta_c(2\beta_c+\beta_s)/\big(2(\beta_c+\beta_s)^2\big)}=\frac{2\beta_c}{2\beta_c+\beta_s},\qquad \eta_S(0)=\frac{\beta_s}{2\beta_c+\beta_s}=\frac{\ell_c}{\ell_c+2\ell_s}.
\]', 'APP', 477, 481);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p2/s1', 'C18/p2', 1, 'Sketch: self-similarity of the tails', 'By stationarity, set $z=0$ and suppress time. The observed middle of the
target integral contributes no uncertainty. Conditional on the two boundary
values, the unobserved tails are independent by the spatial Markov property.
Moving each tail outward by $r$ scales its weight by $e^{-r/\ell_c}$,
while stationarity leaves its conditional variance relative to its boundary
unchanged. Squaring the weight therefore gives
$\eta_S(r)=e^{-2r/\ell_c}\eta_S(0)$.
The covariance integrals in Appendix~\ref{app:technical-canonical} give
$\eta_S(0)=\ell_c/(\ell_c+2\ell_s)$.', 'MAIN', 871, 879);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s1', 'C19.b/p1', 1, 'Derivative in vT is positive', 'In the positive-radius regime,
$\partial r^\star/\partial(vT)=\ell_c/[2(\ell_c+vT)]>0$', 'MAIN', 913, 914);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s2', 'C19.b/p1', 2, 'Derivative in l_s is negative', '$\partial r^\star/\partial\ell_s=-\ell_c/(\ell_c+2\ell_s)<0$.', 'MAIN', 915, 915);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s3', 'C19.b/p1', 3, 'Integral representation gives the increase in l_c', 'For the positive-radius regime $vT>2\ell_s$, Theorem~\ref{thm:canonical_optimal_radius}
can be written as
\begin{equation}
r^\star=\frac12\int_{2\ell_s}^{vT}\frac{\ell_c}{\ell_c+s}\,ds.
\label{eq:rstar_integral_representation}
\end{equation}
With $vT$ and $\ell_s$ fixed, the integration limits do not change and
$\ell_c/(\ell_c+s)=1-s/(\ell_c+s)$ is strictly increasing in $\ell_c$
for every $s>0$. Thus $r^\star$ increases strictly with $\ell_c$ in this
regime, proving the fourth comparative static.', 'APP', 485, 494);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19/p1/s1', 'C19/p1', 1, 'eta_0 from the lemma', 'Lemma~\ref{prop:canonical_eta_S} gives
$\eta_0=\ell_c/(\ell_c+2\ell_s)$.', 'MAIN', 910, 911);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19/p1/s2', 'C19/p1', 2, 'Substitute into C16: radius and threshold vT > 2 l_s', 'Substitution into
Proposition~\ref{prop:generic_exponential_radius} gives the radius and
the threshold $vT>2\ell_s$.', 'MAIN', 911, 913);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C2/p1/s1', 'C2/p1', 1, 'First-order condition E[h''(Qu* - b)] = 0', 'For an admissible perturbation $h$, differentiating expected quadratic cost
at the optimum gives $\mathbb E[h^\top(Qu^\star-b(\theta_t))]=0$.', 'APP', 257, 258);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C2/p1/s2', 'C2/p1', 2, 'One-agent perturbations give the conditional equations', 'Choose perturbations supported on one agent''s action block, with that block
an arbitrary square-integrable function of its observations. Conditional
expectation then gives Eq.~\eqref{eq:conditional_normal_equations}.', 'APP', 259, 261);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C2/p1/s3', 'C2/p1', 3, 'Conversely the linear term vanishes in the cost expansion', 'Conversely, these conditional equations make the linear term vanish in
\[
\mathbb E[f(u^\star+h,\theta_t)-f(u^\star,\theta_t)]
=\mathbb E[h^\top(Qu^\star-b(\theta_t))]+\tfrac12\mathbb E[h^\top Qh].
\]', 'APP', 262, 266);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C2/p1/s4', 'C2/p1', 4, 'Positive definiteness gives sufficiency and uniqueness', 'Positive definiteness makes the remaining term positive for any nonzero
$L^2$ perturbation, proving sufficiency and uniqueness up to almost-sure equality.', 'APP', 267, 268);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3.b/p1/s1', 'C3.b/p1', 1, 'R_inf = 0 and Q > 0 force x* = 0 a.s.', 'In centered coordinates, $R_\infty=0$ and $Q\succ0$
imply $x_t^\star=0$ almost surely.', 'APP', 289, 290);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3.b/p1/s2', 'C3.b/p1', 2, 'Zero rule has zero regret, so the unnormalized law holds', 'The zero rule has zero regret under
every architecture, so the unnormalized composition law remains valid
while normalized shares are undefined.', 'APP', 290, 292);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3/p1/s1', 'C3/p1', 1, 'Conditioning gives E[h''Q(x* - m)] = 0', 'If every agent observes the same $Z$, let $m=\mathbb E[x^\star\mid Z]$.
For every admissible perturbation $h$, conditioning gives
$\mathbb E[h^\top Q(x^\star-m)]=0$.', 'APP', 272, 274);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3/p1/s2', 'C3/p1', 2, 'Error expansion makes m the unique optimum', 'The error expansion then proves that
$m$ is the unique optimum, regardless of the off-diagonal entries of $Q$.', 'APP', 274, 275);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C5.b/p1/s1', 'C5.b/p1', 1, 'Centered desired action is K theta^c', 'Then the centered desired action is
$x^{\star,c}=K\theta^c$, with $K$ as in
Eq.~\eqref{eq:affine_map_and_sensitivity}.', 'APP', 90, 92);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C5.b/p1/s2', 'C5.b/p1', 2, 'Translating by known means is a bijection leaving x - x* unchanged', 'Translating each observation and
each action by its known mean gives a bijection of the admissible rules
and leaves $x-x^\star$ unchanged. Thus Eq.~\eqref{eq:complete_square}
is precisely the tracking loss of the main text in centered coordinates.', 'APP', 92, 95);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C6.c/p1/s1', 'C6.c/p1', 1, 'Larger fresh neighborhoods cannot increase eta_S', 'Larger fresh neighborhoods cannot increase it, since their
extra observations can be ignored.', 'MAIN', 323, 324);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C6.c/p1/s2', 'C6.c/p1', 2, 'At the diameter the fresh view is complete and omission is zero', 'at the diameter of a finite connected
graph the fresh view is complete and omission is zero.', 'MAIN', 325, 326);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s1', 'C7/p1', 1, 'Apply K to the transition', 'Applying $K$ to the transition gives
\begin{equation}
x_t^\star=a x_{t-\tau}^\star+K\varepsilon_{t,\tau}.
\label{eq:xstar_innovation_decomposition}
\end{equation}', 'MAIN', 404, 408);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s2', 'C7/p1', 2, 'Rules are functions of the old state; cross term vanishes', 'Every joint admissible rule $u$ is a function of the complete old state,
although its components each use only their own neighborhood. On expanding
the squared tracking error, the cross term vanishes:
\begin{align*}
&\mathbb E[(a x_{t-\tau}^\star-u)^\top QK\varepsilon_{t,\tau}]\\
&\quad=\mathbb E[(a x_{t-\tau}^\star-u)^\top QK
\mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]]=0.
\end{align*}', 'MAIN', 409, 416);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s3', 'C7/p1', 3, 'Error splits into predictable part plus disturbance', 'Thus the error is the sum of a predictable-part error and a disturbance error:
\begin{align}
\mathbb E[(x_t^\star-u)^\top Q(x_t^\star-u)]
={}&\mathbb E[(a x_{t-\tau}^\star-u)^\top Q(a x_{t-\tau}^\star-u)]\nonumber\\
&+\mathbb E[(K\varepsilon_{t,\tau})^\top Q(K\varepsilon_{t,\tau})].
\label{eq:innovation_split}
\end{align}', 'MAIN', 417, 423);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s4', 'C7/p1', 4, 'Disturbance energy is 2(1-a^2) R_inf (u = 0, stationarity)', 'Apply the same expansion with $u=0$. Stationarity gives
\begin{equation}
\mathbb E[(K\varepsilon_{t,\tau})^\top Q(K\varepsilon_{t,\tau})]
=(1-a^2)\mathbb E[(x_t^\star)^\top Qx_t^\star]=2(1-a^2)R_\infty.
\label{eq:innovation_energy}
\end{equation}', 'MAIN', 424, 429);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s5', 'C7/p1', 5, 'Rescaling u = a u~ is a bijection of admissible rules', 'For finite delay $a>0$, write $u=a\widetilde u$. This rescaling is a
bijection of the admissible rule class: each component uses exactly the
same observations and still has finite second moment. Consequently,
\begin{align}
&\inf_u\mathbb E[(a x_{t-\tau}^\star-u)^\top Q(a x_{t-\tau}^\star-u)]\nonumber\\
&\quad=a^2\inf_{\widetilde u}\mathbb E[(x_{t-\tau}^\star-\widetilde u)^\top
Q(x_{t-\tau}^\star-\widetilde u)]
=2a^2R(\mathcal A_{r,0}).
\label{eq:policy_rescaling}
\end{align}', 'MAIN', 430, 439);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s6', 'C7/p1', 6, 'Fresh problem at the old epoch equals R(A_{r,0}) by stationarity', 'The last equality uses stationarity and the same observation pattern at
each epoch.', 'MAIN', 440, 441);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s7', 'C7/p1', 7, 'Combine and divide by two; normalize when R_inf > 0', 'Combining the two errors and dividing by two proves the law;
normalization is valid when $R_\infty>0$.', 'MAIN', 441, 442);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C8/p1/s1', 'C8/p1', 1, 'Desired action feasible, R(A_{r,0}) = 0, substitute in C7', 'With a complete fresh snapshot the desired action is feasible, so
$R(\mathcal A_{r,0})=0$ in Eq.~\eqref{eq:regret_composition_unnormalized}.', 'MAIN', 463, 464);

-- step_deps
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s2', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s3', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s4', 'step', 'C1/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s4', 'step', 'C1/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C1/p1/s4', 'step', 'C1/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C10/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C10/p1/s1', 'claim', 'C8');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C10/p1/s2', 'step', 'C10/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C11/p1/s3', 'step', 'C11/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C11/p1/s3', 'step', 'C11/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s2', 'step', 'C12/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s3', 'step', 'C12/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s4', 'step', 'C12/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s5', 'step', 'C12/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s5', 'step', 'C12/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s6', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s7', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s7', 'step', 'C12/p1/s5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p1/s7', 'step', 'C12/p1/s6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s2', 'claim', 'C2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s4', 'step', 'C12/p2/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s4', 'step', 'C12/p2/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s5', 'step', 'C12/p2/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s6', 'claim', 'C6.b');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s6', 'step', 'C12/p2/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s7', 'claim', 'C1.b');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s7', 'step', 'C12/p2/s5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s7', 'step', 'C12/p2/s6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s8', 'step', 'C12/p2/s6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C12/p2/s8', 'step', 'C12/p2/s7');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C14/p1/s1', 'claim', 'C7');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C14/p1/s2', 'step', 'C14/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C14/p1/s3', 'step', 'C14/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s1', 'claim', 'C14');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s2', 'step', 'C15/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s3', 'step', 'C15/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s1', 'claim', 'C14');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s2', 'step', 'C16/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s3', 'step', 'C16/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s3', 'step', 'C16/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s4', 'step', 'C16/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s4', 'step', 'C16/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s5', 'step', 'C16/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s6', 'step', 'C16/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s6', 'step', 'C16/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s1', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s2', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s2', 'step', 'C17.b/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s3', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s3', 'step', 'C17.b/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s4', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s5', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s6', 'step', 'C17.b/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s6', 'step', 'C17.b/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C17.b/p1/s6', 'step', 'C17.b/p1/s5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s1', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s2', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s3', 'step', 'C18/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s4', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s5', 'step', 'C18/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s5', 'step', 'C18/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s5', 'step', 'C18/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s5', 'step', 'C18/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s6', 'step', 'C18/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s7', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s8', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s9', 'step', 'C18/p1/s5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s9', 'step', 'C18/p1/s6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s9', 'step', 'C18/p1/s7');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p1/s9', 'step', 'C18/p1/s8');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C18/p2/s1', 'claim', 'C17');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19.b/p1/s1', 'claim', 'C19');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19.b/p1/s2', 'claim', 'C19');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19.b/p1/s3', 'claim', 'C19');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19/p1/s1', 'claim', 'C18');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19/p1/s2', 'claim', 'C16');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19/p1/s2', 'claim', 'C17.b');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C19/p1/s2', 'step', 'C19/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C2/p1/s1', 'claim', 'C1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C2/p1/s2', 'step', 'C2/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C2/p1/s4', 'step', 'C2/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3.b/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3.b/p1/s2', 'step', 'C3.b/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3/p1/s2', 'step', 'C3/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C5.b/p1/s1', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C5.b/p1/s2', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C5.b/p1/s2', 'step', 'C5.b/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C6.c/p1/s1', 'claim', 'C1.c');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C6.c/p1/s2', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s1', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'step', 'C7/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s3', 'step', 'C7/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s3', 'step', 'C7/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s4', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s4', 'claim', 'C6.b');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s4', 'step', 'C7/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s5', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s6', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s6', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s7', 'step', 'C7/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s7', 'step', 'C7/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s7', 'step', 'C7/p1/s5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s7', 'step', 'C7/p1/s6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C8/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C8/p1/s1', 'claim', 'C7');

-- formalizations
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C1.b/f1', 'C1.b', 1, NULL, 'TinaV2.C01b.Statement', 'TinaV2/Statements/C01b.lean', 'draft', 'For any square-integrable target x* (no cost data needed) and any p with IsQProjection. The first conjunct, Q-orthogonality of the error to every admissible policy, is the defining property of IsQProjection restated, as in the paper where it is a reminder. The second is 2 R(A) = ||x*||_Q^2 - ||p||_Q^2 with R(A) = sigmaRegret.', '2026-11-14T16:37:06');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C1.c/f1', 'C1.c', 1, NULL, 'TinaV2.C01c.Statement', 'TinaV2/Statements/C01c.lean', 'draft', 'Appendix sigma-algebra form (SigmaAdmissible, sigmaRegret), any square-integrable target. Adds G''_i <= F, which the paper has by definition of an architecture. Not yet linked to the function-form regret used elsewhere (F6).', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C1/f1', 'C1', 1, NULL, 'TinaV2.C01.Statement', 'TinaV2/Statements/C01.lean', 'draft', 'Appendix sigma-algebra form: the architecture is a family G_i <= F and S(A) is policySpace (SigmaAdmissible as a set). Elements of H are functions, identified when almost surely equal. Cost data are the random variables b = b(theta_t) in L2 and c = c(theta_t) in L1, as the appendix assumes; x* = Q^{-1} b. Five parts. (1) ''Closed linear subspace of H'' is IsClosedSubspace: members are square-integrable, 0, sums and scalar multiples stay in S, and an L2 limit (E||u_n - v||^2 -> 0, ordinary Euclidean norm) of members is a.s. equal to a member; the paper''s remark that the Q-norm is equivalent to the L2 norm is what makes this the same as closed in the Q-norm. (2) The projection exists; the lemma takes this for granted. (3)-(5) hold for every p with IsQProjection, i.e. p in S with x* - p Q-orthogonal to S (the defining property of orthogonal projection; the nearest-point property is then part 3). ''Optimal policy under the quadratic cost'' = minimizes expectedCost E[f(u, theta_t)] over S; ''unique up to a.s. equality'' = any member of S that costs no more is a.s. equal to p. R(A) is sigmaRegret (the infimum of the tracking loss, Eq. architecture_regret, in sigma-algebra form). Not linked to the function-form regret of the main text (F6).', '2026-11-14T16:37:06');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C10/f1', 'C10', 1, NULL, 'TinaV2.C10.Statement', 'TinaV2/Statements/C10.lean', 'draft', '0 <= eta_S(0) is not a hypothesis (it always holds). Third conjunct is the eta_S(0) = 1 clause, which the paper''s proof does not cover (F4). rho* = +infinity is not represented; the clause is stated as ''no tau gives R_loc < R_glob''.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C11/f1', 'C11', 1, NULL, 'TinaV2.C11.Statement', 'TinaV2/Statements/C11.lean', 'draft', 'Standalone (bestMSE, not the Model). sigma > 0 added (implicit in the paper; clause 3 is false for sigma = 0). ''Independent signals/processes'' is independence of the two whole processes. Mean zero and variance sigma^2 are assumed at every time, so the stationarity hypothesis is redundant but kept. Each of clauses 1, 2 states both the value of the best error and that the named estimate attains it.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C12/f1', 'C12', 1, NULL, 'TinaV2.C12.Statement', 'TinaV2/Statements/C12.lean', 'draft', 'Model instance: any Model on Fin n with Q = qI + gamma 11'', K = Q^{-1}, one scalar state and action per agent, any graph. sigma > 0, n >= 2, q > 0, gamma >= 0 as in the paper. Optimal local policy stated as existence of an admissible rule with action theta_i/(q+gamma) attaining R_loc (no uniqueness). Regret is the tracking-loss regret; its equality with excess expected f is C5.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C13.b/f1', 'C13.b', 1, NULL, 'TinaV2.C13b.Statement', 'TinaV2/Statements/C13b.lean', 'draft', 'Pure limits of the closed forms aggRhoStar and aggEta as n -> infinity; gamma = 0 allowed.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C13.c/f1', 'C13.c', 1, NULL, 'TinaV2.C13c.Statement', 'TinaV2/Statements/C13c.lean', 'draft', '''Increase'' is read as strictly increasing on gamma >= 0, for the closed forms.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C13/f1', 'C13', 1, NULL, 'TinaV2.C13.Statement', 'TinaV2/Statements/C13.lean', 'draft', 'Same model as C12, with the temporal assumption at (t, tau) and the aggregate state hypotheses at epoch t. First conjunct identifies rho* of C10 with the closed form.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C14/f1', 'C14', 1, NULL, 'TinaV2.C14.Statement', 'TinaV2/Statements/C14.lean', 'draft', 'Graph radii in N union {top} with a delay tau(r) per radius; r + 1 at top is top. Assumes only tau(r) >= 0 (inside TemporalAssumption) and R_inf > 0; the paper''s ''tau nondecreasing, tau(0) = 0, r <= D'' are not needed for these identities and are omitted. ''Improves performance'' = strictly lower regret.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C15.b/f1', 'C15.b', 1, NULL, 'TinaV2.C15b.Statement', 'TinaV2/Statements/C15b.lean', 'draft', 'Same setting as C15 (F8). The gap is balanceGap (one-sided derivatives at endpoints). ''Unique optimum'' is stated as a strict maximum over [0, D].', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C15.c/f1', 'C15.c', 1, NULL, 'TinaV2.C15c.Statement', 'TinaV2/Statements/C15c.lean', 'draft', 'Same setting as C15 (F8). ''Preserving single crossing'' = the gap is strictly decreasing before and after the change. Stated for any maximizers r, r'' (unique under single crossing). ''The optimum can stay unchanged at a boundary'' is covered by the weak inequalities.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C15/f1', 'C15', 1, NULL, 'TinaV2.C15.Statement', 'TinaV2/Statements/C15.lean', 'draft', 'Pure real analysis about G = gain eta tau T for abstract curves on [0, D] (F8). ''Optimal radius'' = maximizer of G on [0, D]. tau'' >= 0, eta'' <= 0, 0 <= eta are kept as in the paper though the conclusion needs only differentiability and eta < 1. Derivative hypotheses are one-sided at the endpoints (derivWithin); the conclusion uses the ordinary derivative at the interior point.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C16/f1', 'C16', 1, NULL, 'TinaV2.C16.Statement', 'TinaV2/Statements/C16.lean', 'draft', 'Pure real analysis about G with eta(r) = eta_0 exp(-2r/l_c), tau(r) = r/v (F8). ''Unique global optimal radius'' = strict maximizer of G over r >= 0. Cap D >= 0.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C19.b/f1', 'C19.b', 1, NULL, 'TinaV2.C19b.Statement', 'TinaV2/Statements/C19b.lean', 'draft', 'About the closed form canonRadius. ''Within the interior regime'' = the base point satisfies vT > 2 l_s; ''increases/decreases'' = strict inequality for any larger value of the parameter.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C19/f1', 'C19', 1, NULL, 'TinaV2.C19.Statement', 'TinaV2/Statements/C19.lean', 'draft', 'ALGEBRAIC FORM ONLY. States the radius formula, uniqueness and the threshold for the gain function with eta_0 = l_c/(l_c + 2 l_s). It does not mention the Gaussian field, the integral target or regret per unit length: that link is C17, C18, C17.b (tier D, F1). A full statement replaces this one (new formalization version) when tier D definitions exist.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C2/f1', 'C2', 1, NULL, 'TinaV2.C02.Statement', 'TinaV2/Statements/C02.lean', 'draft', 'Same setting as C1/f1. Three conjuncts. (1) Necessity: ''the unique team optimum in the Lemma'' is any p with IsQProjection; it satisfies NormalEquations, which is E[(Q u - b)_c | G_{actor c}] = 0 a.s. for every action coordinate c (agent i''s block is the coordinates with actor c = i). (2) Sufficiency and uniqueness (''strict convexity makes them sufficient for the unique team optimum''): a member of S satisfying the equations minimizes expectedCost over S, and any member that costs no more is a.s. equal to it. (3) The block form Eq. (block_conditional_normal_equations) is equivalent for members of S: coordinates of the same agent enter as u, coordinates of other agents as E[u | G_i]. NOT stated: ''one generally does not have u_i* = E[x_i* | G_i]'' (a statement about what fails in general, with no example in this corollary; the numeric check finds a strict gap in every trial, and C12 is an instance); the last sentence (common information) is C3.', '2026-11-14T16:37:06');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C20/f1', 'C20', 1, NULL, 'TinaV2.C20.Statement', 'TinaV2/Statements/C20.lean', 'draft', 'About the closed form canonRadius: limit as l_c -> infinity with l_s, v, T fixed and vT > 2 l_s.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C3.b/f1', 'C3.b', 1, NULL, 'TinaV2.C03b.Statement', 'TinaV2/Statements/C03b.lean', 'draft', 'Three conjuncts: x* = 0 a.s.; zero regret for every observation family (not only radius architectures); composition identity for any weight a. ''Centered coordinates'' is carried by the definition R_inf = (1/2) E[x*''Q x*].', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C3/f1', 'C3', 1, NULL, 'TinaV2.C03.Statement', 'TinaV2/Statements/C03.lean', 'draft', 'Same cost setting as C1/f1. ''Every agent observes the same Z'': Z is a measurable map into any measurable space and every agent''s sigma-algebra is sigma(Z) (any common sub-sigma-algebra of F has this form, with Z the identity). m = E[x* | Z] is Mathlib''s vector-valued conditional expectation. Three conjuncts: m is in S; m minimizes expectedCost over S; any member of S that costs no more is a.s. equal to m. ''Regardless of the off-diagonal entries of Q'' is the quantifier over every positive definite Q. The regret value is not stated here (the paragraph ''Delayed common snapshots'', C3.c, states it).', '2026-11-14T16:37:06');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C4.b/f1', 'C4.b', 1, NULL, 'TinaV2.C04b.Statement', 'TinaV2/Statements/C04b.lean', 'draft', 'Integer time. ''Independent innovations'' is read as: each innovation is independent of every earlier state (F9); mutual independence of the innovations is not assumed. Second conjunct states the composition law with weights 1 - c^(2k), c^(2k) for the model.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C4/f1', 'C4', 1, NULL, 'TinaV2.TemporalAssumption', 'TinaV2/Defs/Temporal.lean', 'draft', 'An assumption, so a predicate, not a Prop to prove: StationaryState + T > 0 + tau >= 0 + PredictionRule at one epoch t and one delay tau (''for every delay analyzed'' = each tau a statement uses). Stationarity is equality of one-time laws only (F7). Disturbance is defined as theta_t - a theta_{t-tau}; conditioning is on the sigma-algebra of the whole old state. Measurability of each theta_t added as routine regularity. Centering is not assumed: it follows from the rule when tau > 0.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C5.b/f1', 'C5.b', 1, NULL, 'TinaV2.C05b.Statement', 'TinaV2/Statements/C05b.lean', 'draft', 'Two conjuncts: centered target equals K theta^c pointwise; regret of the uncentered problem (target Q^{-1}(B theta + b0), observations of the uncentered snapshot) equals M.R for the centered snapshots. The ''bijection of admissible rules'' is the proof, not part of the statement. Stated for radius architectures.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C5/f1', 'C5', 1, NULL, 'TinaV2.C05.Statement', 'TinaV2/Statements/C05.lean', 'draft', 'Pointwise in the state: b, c are the values b(theta), c(theta). Second conjunct adds ''x* is the unique minimizer'' (appendix, sentence before Eq. clairvoyant), which the ledger claim text did not list.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C6.b/f1', 'C6.b', 1, NULL, 'TinaV2.C06b.Statement', 'TinaV2/Statements/C06b.lean', 'draft', 'Centering is an explicit hypothesis (E[theta_k] = 0). ''Best no-information action is zero'' is stated as: no constant action costs less than R_inf, and zero costs R_inf. Sigma_S is the covariance matrix of the snapshot.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C6.c/f1', 'C6.c', 1, NULL, 'TinaV2.C06c.Statement', 'TinaV2/Statements/C06c.lean', 'draft', 'Needs R_inf > 0 as in the paper. Monotonicity over all radii including top. Diameter clause: finite connected graph, radius = diam. ''eta_S(0) = R_loc/R_inf'' is true by definition and omitted.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C6/f1', 'C6', 1, NULL, 'TinaV2.Model', 'TinaV2/Defs/Architecture.lean', 'draft', 'Definitions only: Model, nbhd, Scope, obs, target, Rule, Admissible, regret, R, Rloc, Rglob, Rinf, etaS. State and action coordinates are index types with owner/actor maps (the paper''s blocks theta_i, x_i). A rule gives each action coordinate as a function of its agent''s observation; measurability of g added as routine regularity. Regret is a real infimum (well defined: zero rule, cost >= 0). Radius is in N union {top}; stale-global is radius top (F5). etaS divides by R_inf, so statements using it assume R_inf > 0.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C7.b/f1', 'C7.b', 1, NULL, 'TinaV2.C07b.Statement', 'TinaV2/Statements/C07b.lean', 'draft', 'Snapshot form: R(A_{r,tau}) at epoch t is M.R mu r (theta (t - tau)) (theta t); the paper suppresses t. Radius ranges over N union {top}. Same hypotheses as C7 plus R_inf > 0.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C7/f1', 'C7', 1, NULL, 'TinaV2.C07.Statement', 'TinaV2/Statements/C07.lean', 'draft', 'Snapshot form: R(A_{r,tau}) at epoch t is M.R mu r (theta (t - tau)) (theta t); the paper suppresses t. Radius ranges over N union {top}. Hypothesis is TemporalAssumption at (t, tau): weaker than the paper''s process-level stationarity (F7). Q > 0 is a field of Model. ''All admissible finite-second-moment rules'' is the infimum in regret.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C8.b/f1', 'C8.b', 1, NULL, 'TinaV2.C08b.Statement', 'TinaV2/Statements/C08b.lean', 'draft', 'States existence of an admissible rule of the complete old snapshot whose action is a K theta_{t-tau} everywhere and whose cost equals R_glob. Does not state almost-sure uniqueness, which ''the optimal action'' may be read to include.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C8.c/f1', 'C8.c', 1, NULL, 'TinaV2.C08c.Statement', 'TinaV2/Statements/C08c.lean', 'draft', 'Assumes the temporal assumption for every tau >= 0 at the fixed epoch t. ''Grows initially as'' is little-o as tau decreases to 0 from the right; the limit is as tau -> infinity.', '2026-11-13T14:16:11');
INSERT INTO formalizations (id, claim_id, version, parent, lean_decl, lean_file, status, fidelity, created) VALUES ('C8/f1', 'C8', 1, NULL, 'TinaV2.C08.Statement', 'TinaV2/Statements/C08.lean', 'draft', 'R_glob is M.R at radius top, i.e. every agent sees every state coordinate of the old snapshot (F5). No connectivity assumed.', '2026-11-13T14:16:11');

-- attempts
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C1/a1', 'C1/f1', 'C1/p1', NULL, 'TinaV2/Proofs/C01/A1.lean', 'Steps 1-2 on functions: sums and multiples coordinate by coordinate; closedness from Mathlib''s closedness of sub-sigma-algebra-measurable classes in L2 (isClosed_aestronglyMeasurable), one coordinate at a time. Step 3 integrates C5 (hypothesis) state by state. Step 4: existence from Mathlib''s Hilbert projection theorem in L2(Omega; (R^d, <.,.>_Q)) through Routine/QHilbert.lean (exists_isQProjection); optimality, uniqueness and the regret value from the Pythagorean identity for a projection.', 'proved', 1, 4.5, 184, '2026-11-14T17:54:54', '2026-11-14T17:54:54');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C10/a1', 'C10/f1', 'C10/p1', NULL, 'TinaV2/Proofs/C10/A1.lean', 'Divide by R_inf using C8 as a hypothesis; rearrange through log. The eta_S(0) = 1 clause is one line in main (finding F4).', 'proved', 1, 3.9, 66, '2026-11-14T16:00:50', '2026-11-14T16:00:50');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C11/a1', 'C11/f1', 'C11/p1', NULL, 'TinaV2/Proofs/C11/A1.lean', 'Conditional mean attains the smallest mean squared error (orthogonality by the pull-out property); E[Y_t | X_t] = 0 by independence; conditioning on the pair of old readings reduces to conditioning on one by independence of the whole processes; error formula by orthogonality and stationarity.', 'proved', 1, 3.7, 261, '2026-11-14T16:10:38', '2026-11-14T16:10:38');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C12/a1', 'C12/f1', 'C12/p1', NULL, 'TinaV2/Proofs/C12/A1.lean', 'Main-text proof: split each local rule into mean plus centered part, expand the expected cost using independence, minimize the mean terms and each centered term, compute the full-information cost from the two eigenspaces of Q, and subtract costs; the bridge from cost differences to regret is C5, taken as a hypothesis.', 'proved', 1, 5.2, 461, '2026-11-14T16:11:09', '2026-11-14T16:11:09');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C14/a1', 'C14/f1', 'C14/p1', NULL, 'TinaV2/Proofs/C14/A1.lean', 'Substitute C7 (hypothesis) and eta_S = R/R_inf; the criterion and the decomposition are arithmetic on step 1.', 'proved', 1, 3.8, 64, '2026-11-14T16:00:50', '2026-11-14T16:00:50');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C15/a1', 'C15/f1', 'C15/p1', NULL, 'TinaV2/Proofs/C15/A1.lean', 'log is monotone on G > 0; interior maximizer is a local maximizer so deriv (log G) = 0; differentiate log G near the point.', 'proved', 1, 3.8, 70, '2026-11-14T16:00:50', '2026-11-14T16:00:50');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C16/a1', 'C16/f1', 'C16/p1', NULL, 'TinaV2/Proofs/C16/A1.lean', 'HasDerivAt formula for G; bracket strictly decreasing with negative limit; sign of the bracket gives monotonicity of G; crossing by the intermediate value theorem; solve for the crossing; truncate at the cap.', 'proved', 1, 4.8, 211, '2026-11-14T16:00:50', '2026-11-14T16:00:50');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C19.b/a1', 'C19.b/f1', 'C19.b/p1', NULL, 'TinaV2/Proofs/C19b/A1.lean', 'Items 1-3 through HasDerivAt of canonRadius inside the regime and the sign of the derivative; item 4 through the integral representation (fundamental theorem of calculus) and a strict integral inequality.', 'proved', 1, 4.4, 166, '2026-11-14T16:00:51', '2026-11-14T16:00:51');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C19/a1', 'C19/f1', 'C19/p1', NULL, 'TinaV2/Proofs/C19/A1.lean', 'Algebraic form: eta_0 is an admissible prefactor; substitute into C16 (hypothesis) and simplify eta_0 (1 + vT/l_c).', 'proved', 1, 4.2, 58, '2026-11-14T16:00:51', '2026-11-14T16:00:51');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C2/a1', 'C2/f1', 'C2/p1', NULL, 'TinaV2/Proofs/C02/A1.lean', 'Necessity by the first-order condition: a projection is optimal (C1, hypothesis), the cost along p + t h is t L + (1/2) t^2 ||h||_Q^2 >= 0, so the derivative L at t = 0 vanishes; one-coordinate indicator perturbations and uniqueness of conditional expectation give the equations. Sufficiency: tower property and pull-out remove the linear term of the expansion, positive definiteness does the rest. Block form from a routine lemma (no paper step).', 'proved', 1, 1.9, 185, '2026-11-14T16:50:34', '2026-11-14T16:50:34');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C3.b/a1', 'C3.b/f1', 'C3.b/p1', NULL, 'TinaV2/Proofs/C03b/A1.lean', 'Integral of a nonnegative integrable function is zero iff it vanishes a.e.; zero rule gives regret zero; every term of the law is zero.', 'proved', 1, 3.7, 74, '2026-11-14T16:00:51', '2026-11-14T16:00:51');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C3/a1', 'C3/f1', 'C3/p1', NULL, 'TinaV2/Proofs/C03/A1.lean', 'Step 1: m = E[x* | Z] is in S, and E[h'' Q (x* - m)] = 0 coordinate by coordinate, pulling the sigma(Z)-measurable h_c out of the conditional expectation. Step 2: expansion of the expected cost around m (Routine expectedCost_add); the linear term is -<h, x* - m>_Q = 0 by step 1 and Q x* = b; positive definiteness gives optimality and uniqueness. No use of C5.', 'proved', 1, 2.4, 112, '2026-11-14T16:50:34', '2026-11-14T16:50:34');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C5.b/a1', 'C5.b/f1', 'C5.b/p1', NULL, 'TinaV2/Proofs/C05b/A1.lean', 'Linearity of expectation for the centered target; explicit Equiv on rules (translate observation and action) preserving admissibility and x - x*; Equiv.iInf_congr.', 'proved', 1, 4.0, 93, '2026-11-14T16:00:51', '2026-11-14T16:00:51');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C7/a1', 'C7/f1', 'C7/p1', NULL, 'TinaV2/Proofs/C07/A1.lean', 'Steps stated for a general weight a and a pair of snapshots; cross term by the conditional-expectation pull-out; rescaling and stationarity as bijections of the admissible rule class (Equiv.iInf_congr).', 'proved', 1, 4.0, 238, '2026-11-14T16:00:49', '2026-11-14T16:00:49');
INSERT INTO attempts (id, formalization_id, proof_id, parent, lean_file, strategy, status, selected, build_seconds, lean_lines, created, updated) VALUES ('C8/a1', 'C8/f1', 'C8/p1', NULL, 'TinaV2/Proofs/C08/A1.lean', 'Exhibit the rule u = K theta on the complete (radius top) view, so the fresh regret is zero; substitute in C7, taken as a hypothesis.', 'proved', 1, 4.0, 54, '2026-11-14T16:00:50', '2026-11-14T16:00:50');

-- step_map
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C1/a1', 'C1/p1/s1', 'TinaV2.C01.A1.s1_linear_subspace', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C1/a1', 'C1/p1/s2', 'TinaV2.C01.A1.s2_closed', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C1/a1', 'C1/p1/s3', 'TinaV2.C01.A1.s3_complete_square', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C1/a1', 'C1/p1/s4', 'TinaV2.C01.A1.s4_projection', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C10/a1', 'C10/p1/s1', 'TinaV2.C10.A1.s1_comparison', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C10/a1', 'C10/p1/s2', 'TinaV2.C10.A1.s2_rearrange', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C11/a1', 'C11/p1/s1', 'TinaV2.C11.A1.s1_fresh_reading', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C11/a1', 'C11/p1/s2', 'TinaV2.C11.A1.s2_old_readings', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C11/a1', 'C11/p1/s3', 'TinaV2.C11.A1.s3_crossover', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s1', 'TinaV2.C12.A1.s1_mean_plus_centered', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s2', 'TinaV2.C12.A1.s2_centered_cost', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s3', 'TinaV2.C12.A1.s3_mean_terms_min', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s4', 'TinaV2.C12.A1.s4_pointwise_min', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s5', 'TinaV2.C12.A1.s5_local_and_constant_cost', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s6', 'TinaV2.C12.A1.s6_eigen_full_info_cost', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C12/a1', 'C12/p1/s7', 'TinaV2.C12.A1.s7_subtract_and_ratio', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C14/a1', 'C14/p1/s1', 'TinaV2.C14.A1.s1_objective', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C14/a1', 'C14/p1/s2', 'TinaV2.C14.A1.s2_one_more_hop', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C14/a1', 'C14/p1/s3', 'TinaV2.C14.A1.s3_decomposition', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C15/a1', 'C15/p1/s1', 'TinaV2.C15.A1.s1_max_log', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C15/a1', 'C15/p1/s2', 'TinaV2.C15.A1.s2_interior_deriv_zero', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C15/a1', 'C15/p1/s3', 'TinaV2.C15.A1.s3_differentiate_gain', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s1', 'TinaV2.C16.A1.s1_deriv_formula', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s2', 'TinaV2.C16.A1.s2_bracket_decreases', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s3', 'TinaV2.C16.A1.s3_nonpositive_at_zero', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s4', 'TinaV2.C16.A1.s4_positive_at_zero', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s5', 'TinaV2.C16.A1.s5_solve_crossing', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C16/a1', 'C16/p1/s6', 'TinaV2.C16.A1.s6_cap_truncates', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C19.b/a1', 'C19.b/p1/s1', 'TinaV2.C19b.A1.s1_deriv_vT', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C19.b/a1', 'C19.b/p1/s2', 'TinaV2.C19b.A1.s2_deriv_ls', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C19.b/a1', 'C19.b/p1/s3', 'TinaV2.C19b.A1.s3_integral_rep', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C19/a1', 'C19/p1/s1', 'TinaV2.C19.A1.s1_eta0', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C19/a1', 'C19/p1/s2', 'TinaV2.C19.A1.s2_substitute', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C2/a1', 'C2/p1/s1', 'TinaV2.C02.A1.s1_first_order', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C2/a1', 'C2/p1/s2', 'TinaV2.C02.A1.s2_conditional_equations', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C2/a1', 'C2/p1/s3', 'TinaV2.C02.A1.s3_linear_term_vanishes', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C2/a1', 'C2/p1/s4', 'TinaV2.C02.A1.s4_sufficient_unique', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C3.b/a1', 'C3.b/p1/s1', 'TinaV2.C03b.A1.s1_target_zero', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C3.b/a1', 'C3.b/p1/s2', 'TinaV2.C03b.A1.s2_zero_rule', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C3/a1', 'C3/p1/s1', 'TinaV2.C03.A1.s1_conditioning', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C3/a1', 'C3/p1/s2', 'TinaV2.C03.A1.s2_unique_optimum', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C5.b/a1', 'C5.b/p1/s1', 'TinaV2.C05b.A1.s1_centered_target', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C5.b/a1', 'C5.b/p1/s2', 'TinaV2.C05b.A1.s2_translation_bijection', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s1', 'TinaV2.C07.A1.s1_apply_K', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s2', 'TinaV2.C07.A1.s2_cross_term_vanishes', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s3', 'TinaV2.C07.A1.s3_error_split', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s4', 'TinaV2.C07.A1.s4_disturbance_energy', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s5', 'TinaV2.C07.A1.s5_rescaling', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s6', 'TinaV2.C07.A1.s6_fresh_at_old_epoch', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C7/a1', 'C7/p1/s7', 'TinaV2.C07.A1.s7_combine', 'proved');
INSERT INTO step_map (attempt_id, step_id, lean_decl, status) VALUES ('C8/a1', 'C8/p1/s1', 'TinaV2.C08.A1.s1_feasible_substitute', 'proved');

-- findings
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F1', 'C17.b', NULL, 'medium', 'Continuum model uses the finite-graph composition theorem without a bridge', 'C16 is stated ''Under Theorem C7'' and C19 is proved by substitution into C16, but C7 is stated and proved for a finite-dimensional stacked state with matrices K and Q. The canonical model has a field-valued state, an integral target and continuous radius, and the temporal conditional-mean assumption is not verified for the field (needs joint Gaussianity in space and time). The Lean proof of C19 cannot be closed without a stated bridge, so the paper needs an edit that adds one. Same issue as K2 in the co-author review.', 'resolved', 'Resolved by upstream commit 284a0e0 (confirmed by Scott 2026-11-14): the canonical field is now stated as jointly Gaussian in space and time, and a paragraph at main-v2.tex 839-855 argues the continuum composition law directly from the covariance (C17.b/p1). What is left is in F10.', '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F10', 'C19', 'C19/p1/s2', 'minor', 'The proof of the canonical radius theorem does not cite the new continuum composition paragraph', 'Upstream 284a0e0 added the continuum composition law as an unlabelled paragraph (main-v2.tex 839-855, claim C17.b). The proof of C19 still reads ''Substitution into Proposition [generic_exponential_radius] gives the radius'', and that proposition still opens ''Under Theorem [spatiotemporal_composition]'', the finite-graph theorem. The proof of C19 does not say that the canonical model satisfies R(r) = R_inf [1 - G(r)], which is what the new paragraph supplies, and the paragraph has no label to cite. The paragraph also ends in words (''retains a^2 times the gain from a fresh interval of the same radius'') and never displays the identity. Separately, ''We measure regret per unit length, equal by stationarity to expected pointwise loss'' (line 824) is still asserted without an argument; it is not needed if regret in this model is defined as the expected pointwise loss. Also, the statements of C18 (''For the field [covariance equation]'') and C19 (''Suppose the field obeys Eq. [covariance equation]'') identify the field only by its covariance; joint Gaussianity is stated in the model paragraph (line 797) and in the limitations, but both proofs need it. Suggested edit: make the paragraph a labelled lemma with the identity displayed, cite it in the proof of C19, and say ''jointly Gaussian field'' in the two statements. This is what remains of F1; related to F8.', 'open', NULL, '2026-11-14T13:50:24');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F11', 'C19.b', 'C19.b/p1/s2', 'minor', 'Comparative static in l_s: the Lean statement lets the larger l_s leave the interior regime, where the derivative argument does not apply', 'The theorem says ''Within the interior regime, r* decreases with the spatial correlation length l_s'' and the proof gives the derivative -l_c/(l_c + 2 l_s) < 0 ''in the positive-radius regime''. The draft Lean statement C19.b/f1 starts from a point with vT > 2 l_s and compares it with every l_s'' > l_s, including l_s'' with 2 l_s'' >= vT, where r* = 0 by the positive part. The inequality is still true there (r*(l_s'') = 0 < r*(l_s)), but not by the derivative. In C19.b/a1 that case is closed inside s2_deriv_ls from the definition of canonRadius, in about eight lines marked ''Case not in the paper''s step''. Items 1, 2 and 4 have no such case: raising T or v stays in the regime and the regime does not depend on l_c. Options: (a) restrict item 3 of the Lean statement to 2 l_s'' < vT, which is the paper''s sentence read with both points in the regime; s2 is then exactly the paper''s step and no paper change is needed. (b) Keep the wider statement and add to the paper: ''once 2 l_s >= vT the radius is zero''. Recommendation: (a), as a new formalization version at statement review.', 'open', NULL, '2026-11-14T16:01:45');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F12', 'C16', 'C16/p1/s4', 'minor', 'Exponential-omission proof: existence of the crossing, the positivity criterion and the link to the positive part are left unsaid', 'Three small things the Lean proof C16/a1 needed that the proof at main 774-786 does not say. (1) ''Otherwise G increases up to its unique crossing'': that the bracket has a zero is not argued. Lean uses continuity of the bracket, its positive value at zero and its negative limit (intermediate value theorem), inside s4_positive_at_zero. (2) ''It is positive exactly when eta_0 (1 + vT/l_c) > 1'' is in the statement and no proof sentence addresses it. Lean reads it off the closed form (Routine/ExpRadius.lean, expRadius_pos_iff), used in main. (3) The proof splits on the sign of the bracket at zero while the boxed formula uses a positive part. The link is the identity vT * bracket(c) = eta_0 (1 + vT/l_c) e^{-2c/l_c} - 1, which the paper does not write; at c = 0 it says the bracket at zero has the sign of eta_0 (1 + vT/l_c) - 1. Lean proves it inside s5_solve_crossing, which therefore also states that the nonpositive case gives r* = 0. Also: the hypothesis eta_0 < 1 is never used; the result holds for every eta_0 > 0. Suggested edit: after ''The bracket decreases strictly to a negative limit'' add ''and at zero it has the sign of eta_0(1 + vT/l_c) - 1''; nothing else is needed.', 'open', NULL, '2026-11-14T16:01:45');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F13', 'C11', 'C11/p1/s2', 'minor', 'Two-sensor example: best estimate taken to be the conditional mean, and the use of process independence when conditioning on both old readings is left unsaid', 'What the Lean proof C11/a1 needed that the paragraph at main 66-86 does not say. The hypotheses are all stated (independent, mean-zero, stationary processes; the scalar prediction rule); what is missing is where they are used. (1) ''Our best estimate is X_t/2'' and ''our best estimate today is then ...'' use that the conditional mean attains the smallest mean squared error among square-integrable functions of the observation. The example neither argues nor cites it; the appendix proves the general fact (C3, common information). In Lean it is Routine/Estimation.lean, bestMSE_eq_of_condExp, a judgment call: when C3 has a Lean statement this should become a use of C3. (2) Step 1 does not say why X_t/2 is the conditional mean: E[Y_t | X_t] = 0 by independence and mean zero. (3) Step 2 gives E[X_t | X_{t-tau}] and concludes about the best estimate from both old readings. That needs E[X_t | X_{t-tau}, Y_{t-tau}] = E[X_t | X_{t-tau}], which holds because (X_t, X_{t-tau}) is independent of Y_{t-tau}. This is where ''the two signal processes are independent'' (line 74) is used, and it has to be independence of the processes: independence of X_s and Y_s at each single time would not be enough. Mathlib has no lemma for this; Routine/Estimation.lean proves it (condExp_sup_of_indep, about 70 lines). (4) The error Var(Z_t)(1 - e^{-2 tau/T}) is asserted; Lean derives it from orthogonality, stationarity of each process with their independence, and mean zero. (5) Var(Z_t) = sigma^2/2 uses E[X_t Y_t] = 0. Suggested edit: one sentence after the prediction rule, ''Because the processes are independent, the old reading of one does not help predict the other, so the conditional mean of Z_t given both old readings is e^{-tau/T} Z_{t-tau}.'' Hypothesis 0 <= tau is unused.
', 'open', 'Decision 2026-11-14 (Scott, on Claude''s recommendation), item 2 only: the best-estimate fact is treated as standard and stays in Routine; C11 does not use C3 and the example gets no pointer to the appendix. Item 1 (where independence of the processes is used) still asks for one sentence, so the finding stays open.', '2026-11-14T16:10:38');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F14', 'C12', 'C12/p1/s7', 'minor', 'Aggregate-coupling proof: ''subtracting'' relies on completing the square, and the full-information cost hides three steps', 'What the Lean proof C12/a1 needed that the proof at main 591-613 does not say. (1) Step 7 ''subtracting'' turns expected-cost differences into regrets. That is the completed-square identity (1/2) E[(u - x*)'' Q (u - x*)] = E f(u, theta) - E f(x*, theta), claim C5, which the step does not cite. In Lean C5 is a hypothesis of steps 6 and 7 and of main; step_deps for step 7 now lists C5. C5 itself has no proof in the paper yet. (2) Step 6 ''therefore'' hides: f(x*, theta) = -(1/2) x*'' Q x* (C5 at x = 0); the explicit x* = Q^{-1} theta (Eq. (shared_resource_xstar), stated before the proposition without proof); and E[(sum theta_i)^2] = n sigma^2, which uses independence, zero means and equal variance. ''Multiplicity n-1'' is used as the eigenspace {v : sum v_i = 0}; the paper presumably intends E[theta'' Q^{-1} theta] = sigma^2 tr Q^{-1}, and Lean reaches the same number by decomposing theta along the two eigenspaces, without a trace. (3) Step 2: the cross terms between means and centered parts vanish because E[u~_i] = 0 (step 1), not for the two reasons named; independence of u~_i and u~_j also needs each u~_i to be a function of theta_i alone. The expansion of the cost at u = mean + centered part is in Routine/Aggregate.lean (aggCost_split) as a ring identity. (4) The statement''s ''the rule attains R_loc'' is proved in step 7, since it needs the bridge in (1); the paper''s steps 4-5 establish optimality in cost terms. (5) As noted under F2, the state assumptions (independent, mean zero, equal variance) are in the paragraph before the proposition, not in its statement. Suggested edit: in the last sentence write ''Subtracting, by Eq. (complete_square), gives ...''.', 'open', NULL, '2026-11-14T16:11:09');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F15', 'C2', NULL, 'minor', 'Normal equations: the block form is asserted as equivalent without argument, and the justification leaves its conditional-expectation steps unsaid', 'What the Lean proof C2/a1 needed that the corollary and its justification (appendix 220-269) do not say. (1) ''With Q partitioned into action blocks, this is equivalently'' Eq. (block_conditional_normal_equations): the justification has no step for it. It needs linearity of conditional expectation over (Qu)_i, and E[u_i | G_i] = u_i, which uses that u_i is G_i-measurable, i.e. u in S(A); for a u outside S(A) the two forms are not equivalent. In Lean it is Routine/NormalEq.lean, normalEquations_iff_block, used in main, and the statement restricts the equivalence to members of S(A). (2) Step 1 ''differentiating expected quadratic cost at the optimum'' uses the expansion E[f(u*+h) - f(u*)] = E[h''(Qu* - b)] + (1/2) E[h''Qh], which the text displays only two sentences later, and uses that the projection of the lemma is optimal (C1) and that u* + t h is admissible (linearity of S(A)); neither is cited. (3) Step 2 ''conditional expectation then gives'': the content is that E[1_A g] = 0 for every A in G_i characterizes E[g | G_i] = 0. Lean uses indicator perturbations on one coordinate, a special case of ''an arbitrary square-integrable function of its observations''. (4) Step 3 does not say why the equations make the linear term vanish: E[h_i''(Qu - b)_i] = E[h_i'' E[(Qu - b)_i | G_i]], the tower property with h_i pulled out, which uses that h_i is G_i-measurable. In this converse direction u* denotes any admissible solution of the equations, not yet known to be the optimum. (5) Step 3 is listed as using C5 (completing the square); the displayed expansion is a ring identity for f and Lean does not use C5. Decision needed: drop C5 from step_deps of C2/p1/s3. (6) Not in the Lean statement: ''one generally does not have u_i* = E[x_i* | G_i]''. The paper gives no example here; the aggregate-coupling model (C12) is one. Suggested edit: after Eq. (block_conditional_normal_equations) add ''because u_i is G_i-measurable and conditional expectation is linear'', and in step 3 ''by the tower property, since h_i is G_i-measurable''.', 'open', 'Decision 2026-11-14 (Scott, on Claude''s recommendation), item 5 only: C5 dropped from step_deps of C2/p1/s3. Items 1-4 still ask for paper edits, so the finding stays open.', '2026-11-14T16:50:34');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F16', 'C3', 'C3/p1/s2', 'minor', 'Common-information paragraph: ''the error expansion'' has no stated referent, and the link to it needs Q x* = b', 'What the Lean proof C3/a1 needed that the paragraph (appendix 271-276) does not say. (1) ''The error expansion then proves'' does not say which expansion. Two readings work: Eq. (complete_square) followed by expanding ||u - x*||_Q^2 around m (uses C5, as the ledger''s step_deps lists), or the display in the justification of the normal equations, E[f(m+h) - f(m)] = E[h''(Qm - b)] + (1/2) E[h''Qh]. Lean uses the second, through the routine lemma expectedCost_add, so C3 does not depend on C5. Decision needed: drop C5 from step_deps of C3/p1/s2 and from the claim''s dependencies, or keep the first reading. (2) Step 1 gives E[h''Q(x* - m)] = 0 while the linear term of the expansion is E[h''(Qm - b)]; they agree up to sign because Q x* = b, which the paragraph does not say. (3) That m is admissible (sigma(Z)-measurable and square-integrable) is not stated; it is the first conjunct of the Lean statement. (4) Uniqueness uses ''positive definiteness makes the remaining term positive'', stated for the corollary and not repeated, and writing a competitor as m + h uses linearity of S(A) from the lemma. Suggested edit: ''The expansion in the justification of Corollary (conditional_normal_equations), with Q x* = b, then proves ...''.', 'open', 'Decision 2026-11-14 (Scott, on Claude''s recommendation), item 1: the expansion is read as the display in the justification of the normal equations; C5 dropped from step_deps of C3/p1/s2 and C3''s dependency on C5 changed to setup. The wording fix in the paper is still asked for (ideally an equation label on that display), so the finding stays open.', '2026-11-14T16:50:34');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F17', 'C1', 'C1/p1/s4', 'minor', 'Projection lemma: the projection step rests on the uncited norm-equivalence remark, existence is implicit, and the lemma is conditional on completing the square', 'What the Lean proof C1/a1 needed that the proof at appendix 181-214 does not say. (1) Step 4, ''the standard Hilbert-space projection problem'', needs S(A) to be closed, hence complete, for the Q-norm, while step 2 argues closedness for the ordinary L2 norm (''an L2 limit ...''). The bridge is the sentence before the lemma, ''Since Q > 0, the induced norm is equivalent to the ordinary L2 norm'' (appendix 145), which is asserted without proof and not cited in the proof. Lean uses one direction, sum_c v_c^2 <= C v''Qv (Routine/QHilbert.lean, exists_sum_sq_le_quad, from finite dimension), and completeness of L2 over R^d with the Q inner product. (2) The lemma says ''the unique optimal policy ... is Pi x*'': existence of the projection, and so of an optimal policy, is part of what the projection theorem delivers and is not stated separately; the Lean statement has it as its own conjunct. (3) Uniqueness up to a.s. equality uses ||u - p||_Q = 0 => u = p a.s. (positive definiteness), and the regret value uses the Pythagorean identity ||u - x*||_Q^2 = ||u - p||_Q^2 + ||p - x*||_Q^2 for u in S(A); both are inside ''standard''. (4) Step 3 cites Eq. (complete_square), claim C5, which has no proof in the paper, so C1 and C2 are conditional on C5 in the assembly. Step 3 also needs E||b||^2 < infinity and E|c| < infinity for the two expected costs to be finite and subtractable; the appendix assumes both at line 39. (5) The orthogonality sentence after the proof (C1.b, first half) is the defining property of the projection in the Lean statement. Suggested edit: in step 4, ''By the norm equivalence above, S(A) is also closed for the Q-norm, so minimizing ...''.', 'open', NULL, '2026-11-14T17:54:55');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F2', 'C12', NULL, 'minor', 'Two different derivations of the optimal local rule', 'The main-text proof (C12/p1) finds theta_i/(q+gamma) by a centered decomposition and pointwise minimization; the appendix (C12/p2), introduced as ''the matrix arithmetic'', re-derives it from the coupled normal equations. Under the 1:1 rule one derivation must be the proof Lean mirrors. C12/p1 is marked primary for now; p2 additionally needs C2 and C1.b (tier C). Decision needed: keep both (and formalize both) or reduce the appendix to the arithmetic.', 'open', 'Decision 2026-11-13 (left to Claude''s judgement): C12/p1 (main text) is the proof Lean mirrors. When C12 is formalized, a tracked edit reduces the appendix to the arithmetic for R_inf and R_loc and removes the normal-equation re-derivation, so C12 does not depend on C2 or C1.b. Finding stays open until that edit is applied.', '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F3', 'C9', NULL, 'medium', 'Unequal-rate formula has no proof and an informal hypothesis', 'The formula is asserted without proof, and ''the fraction of the no-information decision loss attributable to mode k'' is not defined (it needs the cross-mode terms of x*''Qx* to vanish, which independence of the modes provides once stated). A Lean statement needs a precise definition of w_k, and the 1:1 rule needs a written proof.', 'open', NULL, '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F4', 'C10', 'C10/p1/s2', 'minor', 'Crossover proof does not mention the eta_S(0) = 1 clause', 'The theorem states that for eta_S(0) = 1 no finite delay gives a strict local advantage, but the theorem''s hypothesis is 0 <= eta_S(0) < 1 and the proof (''Rearranging gives the threshold and equality case'') covers only that range. The Lean statement has to either drop the clause or prove it as a separate step, which then needs a sentence in the paper.', 'open', NULL, '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F5', 'C8', NULL, 'minor', 'Stale-global is presented as a case of A_{r,tau}, which needs a radius that reaches every agent', 'Section ''What each agent observes'' lists stale-global among ''the three cases'' of A_{r,tau}, and the proof of C8 substitutes R(A_{r,0}) = 0 into the composition law for A_{r,tau}. On a disconnected graph no finite radius gives the complete view, and the paper only says ''the diameter of a finite connected graph gives a complete stale-global snapshot''. Lean draft: the radius ranges over N union {top}, top being the complete view, so R_glob = R(A_{top,tau}) and C7 covers it. Options for the paper: (a) say the radius may be ''complete'' (r = infinity); (b) assume G connected; (c) state C7 for arbitrary synchronized neighborhoods.', 'open', NULL, '2026-11-13T14:16:11');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F6', 'C1.c', NULL, 'minor', 'Two definitions of admissible rule with no stated link', 'The main text defines an admissible rule as u_i = g_i(Z_i); the appendix as G_i-measurable u_i with G_i = sigma(Z_i), adding ''measurability here means that u_i can be computed from those observations''. C1.c is stated in the appendix form, and C6.c step s1 applies it to radius architectures defined in the main-text form. The link is the Doob-Dynkin lemma. Lean has both definitions (regret, sigmaRegret). Decision needed: treat regret Z = sigmaRegret sigma(Z) as a Routine lemma, or as a one-sentence claim in the appendix with its own step. README open decision 3.', 'open', NULL, '2026-11-13T14:16:11');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F7', 'C4', NULL, 'minor', 'Which stationarity the assumption means, and R(A_{r,tau}) written without the epoch', 'The assumption says ''a stationary state process''. The proof of C7 uses only that theta_{t-tau} and theta_t have the same law (the paper: ''Stationarity supplies the same one-time distribution at the two epochs''). Lean draft assumes equality of one-time laws for all pairs of times, which strict stationarity implies. Under that weaker hypothesis R(A_{r,tau}) can depend on the epoch t when tau > 0 before the theorem is applied, so the Lean statements carry t explicitly. Decision needed: keep the weaker hypothesis (and optionally say so in the paper) or define strict stationarity of the process.', 'open', NULL, '2026-11-13T14:16:11');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F8', 'C15', NULL, 'minor', 'Continuous-radius results are stated ''under Theorem C7'' but eta_S and tau are functions of a real radius', 'C14 defines G on graph radii. C15, its two remarks (C15.b, C15.c) and C16 then treat eta_S(r) and tau(r) as continuously differentiable functions of r in [0, D] and speak of the ''optimal radius'', while the model of C6/C7 only defines eta_S at integer radii. Lean draft states these four claims as real analysis about G(r) = (1 - eta(r)) exp(-2 tau(r)/T) for given curves eta, tau, with ''optimal'' meaning ''maximizes G''. The paper could say this in one sentence before C15 (e.g. ''for an omission curve eta_S and delay curve tau defined for real r, with R(r) := R_inf [1 - G(r)]''). For the canonical model the paragraph added by upstream 284a0e0 (C17.b) now supplies R(r) = R_inf [1 - G(r)]. Related to F1 (resolved) and F10.', 'open', NULL, '2026-11-13T14:16:11');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F9', 'C4.b', NULL, 'minor', 'AR(1) remark does not say what the innovations are independent of', '''Independent, mean-zero finite-variance innovations'' can mean an independent sequence, or innovations independent of the past of the state. The prediction coefficient c^k needs each innovation xi_u to be independent of the earlier states theta_s, s < u (true for the causal stationary solution driven by an independent sequence, but that is an argument). Lean draft assumes independence from earlier states directly. Since C4.b has no proof in the paper, the appendix proof to be added should fix the reading.', 'open', NULL, '2026-11-13T14:16:11');

-- notes
INSERT INTO notes (id, ts, target, kind, body) VALUES (1, '2026-11-13T13:43:04', 'C12', 'decision', 'F2: main-text derivation C12/p1 is primary; appendix normal-equation derivation C12/p2 to be removed by a tracked edit when C12 is formalized.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (2, '2026-11-13T13:55:41', 'C4.c', 'todo', 'Before attempting: bump Lean and Mathlib to v4.35.0 (about 1 GB download, see README ''Libraries''). atlas-lean MathlibExt/Probability/OrnsteinUhlenbeck.lean at commit 8e813e6 gives the stationary scalar OU process as a Gaussian process with covariance (sigma^2/2theta) exp(-theta|t-s|), with existence, stationarity, condExp_natural and condDistrib_eval; closure is 3 files (plus KolmogorovExtension, GaussianConditioning), which do not compile on Mathlib v4.33.1. Scalar only: the paper''s vector form with Sigma_S is not covered. Also relevant to C9.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (3, '2026-11-13T14:16:11', 'C19', 'todo', 'C19/f1 is the algebraic form only. Write the full statement (new formalization version) once tier D definitions for C17 exist and F1 is resolved.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (4, '2026-11-13T14:16:11', 'C6', 'decision', 'Defs take snapshots (random state vectors), not a process and a time; radius is in N union {top}; rules are coordinatewise functions of the agent''s observation. All drafts pending Scott''s review.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (5, '2026-11-13T14:16:11', 'C5', 'todo', 'C5 has no English proof in the ledger (''Completing the square gives'' is the whole argument). Add a one-step proof row before phase 2, or a short appendix proof through an edit.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (6, '2026-11-14T13:50:23', 'C17.b', 'decision', '2026-11-14 (Scott): upstream 284a0e0 added the continuum composition law as a paragraph with an argument. Kept the ID, kind implicit -> remark, added the in-paper proof C17.b/p1 (6 verbatim steps). Removed the edge ''C17.b uses C7'': the paragraph argues directly from the field covariance and does not invoke the finite-graph theorem. ''C17.b setup C17'' and ''C19 uses C17.b'' stay.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (7, '2026-11-14T13:50:23', 'C17', 'insight', 'Realigned to 6454c74. Upstream 284a0e0 changed ''a Gaussian spatial field on a dense one-dimensional network, represented by locations z'' to ''a jointly Gaussian space--time field on the infinite line, with spatial coordinate z''. Ledger statement updated to match (approved by Scott 2026-11-14). No Lean definition of C17 exists yet, so nothing is invalidated.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (8, '2026-11-14T13:50:23', 'C25', 'insight', 'Realigned to 6454c74. Abstract and contribution list rewritten upstream (8d0ac72, 7bace26, d087a87, df99ee3): ''exact rule'' is gone and the composition law is attributed to Marschak-Radner. Ledger statement updated (approved by Scott 2026-11-14). The range is now 46-181 so that it still covers the introductory attribution and literature paragraphs, which moved to after the contribution list. The new explanatory figure fig:snapshot-architectures (propagation cone, lines 102-114, 8d0ac72) lies in this range; it is an illustration and gets no claim ID (Scott 2026-11-14).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (9, '2026-11-14T13:50:23', 'C6', 'insight', 'Realigned to 6454c74. The definition text is identical to 4a9b87e. The new explanatory figure fig:field-and-cost (lines 237-248, upstream 8d0ac72) lies inside this range; it is an illustration and gets no claim ID (Scott 2026-11-14).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (10, '2026-11-14T13:50:23', 'C26', 'insight', 'Realigned to 6454c74. Upstream 284a0e0 added the Marschak-Radner attribution paragraph (Eqs. (6.5), (6.6)) and the Jiang-Zhou and Munari et al. comparison, removed the ''distinctive object'' paragraph and added paragraph headings. Ledger statement updated (approved by Scott 2026-11-14). The two attributions have not been checked against the book.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (11, '2026-11-14T13:50:23', 'C27', 'insight', 'Realigned to 6454c74. Upstream 284a0e0 rewrote the assumptions-per-result paragraph and 886659b the closing design implication. Ledger statement updated (approved by Scott 2026-11-14).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (12, '2026-11-14T13:50:23', 'C12/p2/s6', 'insight', 'Step text updated to the paper as of 6454c74: upstream 886659b renamed ''\emph{Open-loop regret.}'' to ''\emph{No-information regret.}'' (a terminology change made throughout the paper). The mathematics is unchanged. This is the paper changing on its own, not a Lean-driven edit, so there is no edits row. The secondary derivation C12/p2 is still in the paper in full; upstream has not removed or shortened it (see F2).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (13, '2026-11-14T13:50:23', 'C7', 'insight', 'Realigned to 6454c74. Upstream 284a0e0 now introduces the theorem as Marschak and Radner''s delayed-information decomposition (Ch. 7, Sec. 4, Eqs. (4.21)-(4.22), with a notation footnote) at main-v2.tex 367-377, just before this claim''s range. The theorem statement and proof are identical to 4a9b87e, so C7/f1 and C7/p1 are unaffected. This is review item K1 (README open decision 4).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (14, '2026-11-14T13:50:23', 'C3.b', 'insight', 'Realigned to 6454c74. Upstream 886659b split the appendix paragraph ''Common information and degenerate normalization'' into three: ''Common-information optimality'' (C3), ''Delayed common snapshots'' (C3.c) and ''Degenerate normalization'' (C3.b). Both steps of C3.b/p1 are verbatim.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (15, '2026-11-14T13:50:23', 'C11', 'insight', 'Realigned to 6454c74. Upstream 7bace26 rewrote the closing remark of the example (''one current reading predicts the two-sensor average better than both readings once the pair is more than about 0.35T old''). The displayed inequality and the three steps are verbatim; C11/f1 is unaffected.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (16, '2026-11-14T13:50:23', 'C14', 'insight', 'Realigned to 6454c74. Upstream 886659b changed ''open-loop loss'' to ''no-information loss'' in the sentence defining G and replaced the five-line motivating paragraph with one sentence. G, the one-more-hop criterion and the decomposition are verbatim; C14/f1 is unaffected.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (17, '2026-11-14T13:50:24', 'F2', 'insight', 'Rechecked against 6454c74: both derivations are still in the paper. Upstream did not remove or shorten the appendix derivation C12/p2; its only change there is the heading of step s6 (''No-information regret'').');
INSERT INTO notes (id, ts, target, kind, body) VALUES (18, '2026-11-14T16:01:45', 'F4', 'insight', 'C10/a1 is proved. Steps 1 and 2 mirror the two sentences of the proof. The eta_S(0) = 1 clause has no sentence in the paper''s proof; in Lean it is one line in main, read off step 1 (the comparison would be 1 < 1 - e^{-2 tau/T}). When the paper gains the sentence proposed in the findings memo, that line becomes step 3. The Lean statement already has the hypothesis in the reworded form (R_inf > 0, then the two cases).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (19, '2026-11-14T16:01:45', 'C7/a1', 'success', 'Proved 2026-11-14 against the draft statement C7/f1: 7 step lemmas for the 7 paper steps, main is a one-line instantiation. 238 lines, 4.0 s, axioms propext, Classical.choice, Quot.sound. Hypotheses of the statement that the proof never uses: T > 0 and tau >= 0 (a = e^{-tau/T} > 0 is all step 5 needs). Step 4 did not need C6.b: R_inf is by definition (1/2) E[x*'' Q x*]. Step 3 needs step 1 (step_deps corrected).');
INSERT INTO notes (id, ts, target, kind, body) VALUES (20, '2026-11-14T16:01:45', 'C7/a1', 'insight', 'Routine/Regret.lean holds what the paper leaves unsaid here: expansion of the quadratic form, measurability, integrability of products of L2 vectors, the zero rule is admissible, scalar multiples of admissible rules are admissible, admissibility depends only on the law of the snapshot, a constant moves out of an infimum, and linearity of conditional expectation applied coordinatewise to the prediction rule. The pull-out and tower property that make the cross term vanish are inside the step lemma, not in Routine, because they are the content of the paper''s step 2.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (21, '2026-11-14T16:01:45', 'C8/a1', 'success', 'Proved 2026-11-14 against draft C8/f1 with C7 as a hypothesis. 54 lines, 4.0 s. The complete snapshot is radius top (finding F5): the rule u = K theta is admissible there.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (22, '2026-11-14T16:01:45', 'C10/a1', 'success', 'Proved 2026-11-14 against draft C10/f1 with C8 as a hypothesis. 66 lines, 3.9 s. See the note on F4 for the one line in main that has no paper sentence.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (23, '2026-11-14T16:01:45', 'C14/a1', 'success', 'Proved 2026-11-14 against draft C14/f1 with C7 as a hypothesis. 64 lines, 3.8 s.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (24, '2026-11-14T16:01:46', 'C14/p1', 'decision', '2026-11-14: steps s2 (main 698-702, the one-more-hop criterion) and s3 (main 709-716, the loss decomposition) added to the step list. Both sentences are in the paper verbatim and are part of the claim; the first extraction had only the sentence that cites the theorem, which left two conjuncts of the statement with no step. No paper change.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (25, '2026-11-14T16:01:46', 'C5.b/p1', 'decision', '2026-11-14: the proof is now two steps. s1 is the sentence ''Then the centered desired action is x^{*,c} = K theta^c'' (app 90-92), which is the first conjunct of the statement and was not a step; the translation sentence (app 92-95) is s2. Text is verbatim from the paper; no paper change.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (26, '2026-11-14T16:01:46', 'C5.b/a1', 'success', 'Proved 2026-11-14 against draft C5.b/f1. 93 lines, 4.0 s. The paper''s step covers translating both observations and actions, and Lean translates both. Wording to tighten some day: ''each action by its known mean'' means by E[x*], not by the mean of the action. Needs a probability measure and integrable theta; Measurable snap, MemLp snap and Measurable now in the statement are unused.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (27, '2026-11-14T16:01:46', 'C3.b/a1', 'success', 'Proved 2026-11-14 against draft C3.b/f1. 74 lines, 3.7 s. Step 1 needs theta in L2 (so x*'' Q x* is integrable). Step 2 uses Q > 0 a second time, for ''no rule costs less than zero'', which the paper leaves unsaid. The third conjunct is 0 = 0 for every a.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (28, '2026-11-14T16:01:46', 'C15/a1', 'success', 'Proved 2026-11-14 against draft C15/f1. 70 lines, 3.8 s. Hypotheses never used: 0 < T, 0 < D, tau'' >= 0, eta'' <= 0, 0 <= eta. Only C1 on [0, D] and eta < 1 are needed.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (29, '2026-11-14T16:01:46', 'C16/a1', 'success', 'Proved 2026-11-14 against draft C16/f1. 211 lines, 4.8 s. The statement was tested numerically first (4000 random parameter sets with boundary and cap cases, no violation). Steps 3 and 4 need step 1 (step_deps corrected). See F12 for what the paper leaves unsaid.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (30, '2026-11-14T16:01:46', 'C19/a1', 'success', 'Proved 2026-11-14 against draft C19/f1 (algebraic form) with C16 as a hypothesis. 58 lines, 4.2 s. No hypothesis for C18 or C17.b: the algebraic statement fixes eta_0 and does not mention the field model. The full statement still waits on tier D and F10.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (31, '2026-11-14T16:01:46', 'C19.b/a1', 'success', 'Proved 2026-11-14 against draft C19.b/f1. 166 lines, 4.4 s. Items 1-3 through the derivative, item 4 through the integral representation, as in the paper. The paper states only the sign of each derivative; ''hence strictly monotone'' goes through a Routine wrapper around Mathlib''s strictMonoOn_of_deriv_pos. See F11 for the case outside the regime.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (32, '2026-11-14T16:01:46', 'C16/a1', 'todo', 'Routine/ExpRadius.lean and Routine/RadiusCalculus.lean each have a HasDerivAt wrapper for strict monotonicity from the sign of the derivative. Merge them into one file.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (33, '2026-11-14T16:10:38', 'C11/a1', 'success', 'Proved 2026-11-14 against draft C11/f1. 261 lines, 3.7 s; Routine/Estimation.lean is 275 lines and imports Mathlib.Probability.ConditionalExpectation. A Gaussian AR(1) pair simulated at three parameter sets matched the coefficients, both errors, Var(Z) and the crossover. Step 3 carries a middle conjunct comparing the two best errors so that it uses steps 1 and 2 as the ledger lists; main discards it. main has one rewrite (Var(Z_t) = sigma^2/2 from step 3 into step 2''s error). See F13.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (34, '2026-11-14T16:11:09', 'C12/a1', 'success', 'Proved 2026-11-14 against draft C12/f1, with C5 as a hypothesis (C5 has no paper proof yet, so the assembled theorem is conditional on it). 461 lines, 5.2 s; Routine/Aggregate.lean is 217 lines. Closed forms checked in exact rational arithmetic for 8 random (n, q, gamma, sigma^2), n from 2 to 6, before proving. Mirrors the main-text proof only (decision on F2). Step 4 does not use step 2 in Lean; step 5''s clause ''every constant has nonnegative expected cost'' is proved but unused, because R_inf is defined as (1/2) E[x*'' Q x*]. See F14.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (35, '2026-11-14T16:37:06', 'C1', 'insight', 'Statements C1/f1, C1.b/f1, C2/f1, C3/f1 tested numerically before any proof (finite probability space, partitions as sigma-algebras, random Q, b, c, 40 trials, two block layouts): projection exists, costs strictly less than random members of S, regret = (1/2)||x* - p||_Q^2, C1.b Pythagorean form, C2 normal equations and block form at p and violated off p, C3 conditional mean optimal. Agentwise conditional means cost strictly more than the optimum in every trial.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (36, '2026-11-14T16:50:34', 'C2/a1', 'success', 'Proved 2026-11-14 against draft C2/f1, with C1 as a hypothesis of steps 1-2 and of main. 185 lines, 1.9 s; Routine/NormalEq.lean is 147 lines. Step 1 mirrors the paper''s first-order condition (IsLocalMin.hasDerivAt_eq_zero) although the orthogonality in IsQProjection would give the same equation directly. Step 2 uses indicator perturbations on one coordinate, a special case of the paper''s ''arbitrary square-integrable function''. Step 3 does not use C5: the displayed expansion is the routine lemma expectedCost_add. Conjunct 3 (block form) comes from Routine normalEquations_iff_block in main, because the paper''s proof has no step for it. See F15.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (37, '2026-11-14T16:50:34', 'C3/a1', 'success', 'Proved 2026-11-14 against draft C3/f1, unconditionally. 112 lines, 2.4 s; Routine/CommonInfo.lean is 67 lines. Step 1 holds for any matrix Q and any square-integrable target. Step 2 uses the expansion around m (expectedCost_add), not completing the square, so C5 is not used although step_deps lists it. Z enters only through sigma(Z) <= F. See F16.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (38, '2026-11-14T17:54:55', 'C1/a1', 'success', 'Proved 2026-11-14 against draft C1/f1, with C5 as a hypothesis of steps 3-4 and of main (C5 has no paper proof yet, so the assembled theorem is conditional on it). 184 lines, 4.5 s; Routine/QHilbert.lean is 250 lines, Routine/Projection.lean (shared with C2, C3) 226. Existence of the projection is Mathlib''s theorem (Submodule.exists_norm_eq_iInf_of_complete_subspace with norm_eq_iInf_iff_real_inner_eq_zero) in Mathlib''s L2 over R^d with the Q inner product (Matrix.toNormedAddCommGroup, Matrix.toInnerProductSpace on a type synonym), which is complete because R^d is; nothing about the projection theorem is re-proved. The one inequality used from ''the induced norm is equivalent to the ordinary L2 norm'' is sum_c v_c^2 <= C v''Qv. IsProbabilityMeasure is not used by any step. The agent that wrote the files was cut off by a network error after its first draft of the attempt file; the draft compiled unchanged and was reviewed in the main session. See F17.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (39, '2026-11-14T18:07:30', 'C2/p1/s3', 'decision', '2026-11-14, Scott on Claude''s recommendation: C5 removed from this step''s dependencies. The displayed expansion E[f(u*+h) - f(u*)] = E[h''(Qu* - b)] + (1/2) E[h''Qh] is algebra on the quadratic cost, not Eq. (complete_square), and the sentence does not cite that equation. Listing C5 was an over-attribution in the first step extraction. See F15 item 5.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (40, '2026-11-14T18:07:30', 'C3/p1/s2', 'decision', '2026-11-14, Scott on Claude''s recommendation: ''the error expansion'' is read as the display in the justification of the normal equations (appendix 263-266), not as Eq. (complete_square) followed by an expansion around m. C5 removed from this step''s dependencies, and the claim''s dependency on C5 is now ''setup'' (C3 is stated for the quadratic cost). Reasons: the display is four lines above the paragraph; C3 stays unconditional instead of resting on the unproved C5; the Lean proof C3/a1 already follows this reading. The paper still needs the wording fix of F16, preferably by giving that display an equation label that C2''s steps 1 and 3 and this step can cite.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (41, '2026-11-14T18:07:30', 'C11', 'decision', '2026-11-14, Scott on Claude''s recommendation (F13 item 2): ''the conditional mean is the best mean-squared-error estimate'' is treated as a standard fact in the two-sensor example. It stays in Routine/Estimation.lean (bestMSE_eq_of_condExp); C11 is not rewired to use C3 and the example gets no forward pointer to the appendix. Reasons: it is a textbook fact in an introductory example; using C3 in Lean without a citation in the paper would add a dependency the text does not have. Revisit only if the paper''s example comes to cite the common-information paragraph. C3''s natural place to be cited is the optimal stale-global action (C8.b), which has no proof; that route is unchecked in Lean and needs the F6 link between the two definitions of admissible rule. F13 item 1 (the independence sentence) still asks for an edit.');
