-- Ledger data. Written by tools/ledger.py; edit through the CLI.

-- meta
INSERT INTO meta (key, value) VALUES ('decision_unproved_claims', '2026-11-13 (Scott): claims the paper asserts without proof get short proofs added to an appendix through tracked edits, and those proofs are then formalized.');
INSERT INTO meta (key, value) VALUES ('paper', 'tina-v2-alt');
INSERT INTO meta (key, value) VALUES ('review_ledger', 'submissions/arxiv-v2/alt-review/claim-ledger.md');
INSERT INTO meta (key, value) VALUES ('schema_version', '1');
INSERT INTO meta (key, value) VALUES ('toolchain', 'Lean 4.33.1, Mathlib v4.33.1 (0df444a). Packages were cloned from an existing local checkout to avoid a slow download; a fresh machine runs ''lake exe cache get''.');

-- sources
INSERT INTO sources (id, path, git_commit, sha256) VALUES ('APP', 'submissions/arxiv-v2/technical-appendices-alt.tex', '4a9b87e12616ad3ba868c58f537c25e65b0f2a8a', 'c59eb65fcd1df5461ab0c3d1a9b0397079deb18cba3463416cf19e23842bde10');
INSERT INTO sources (id, path, git_commit, sha256) VALUES ('MAIN', 'submissions/arxiv-v2/main-alt.tex', '4a9b87e12616ad3ba868c58f537c25e65b0f2a8a', '09f465a4137058de83358a4ca9b76e7447337839c38cf9e546bfe4ad35a85bb8');

-- claims
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1', NULL, 'lemma', 'Fixed-architecture quadratic projection', 'The admissible policy set S(A) is a closed linear subspace of L2; the unique optimal policy is the Q-weighted orthogonal projection of x* onto S(A); R(A) = (1/2)||x* - Pi x*||_Q^2.', 'APP', 'lem:radner_projection', 147, 214, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1.b', 'C1', 'remark', 'Q-orthogonality and Pythagorean form', 'The projection error is Q-orthogonal to every admissible policy; 2R(A) = ||x*||_Q^2 - ||u*_A||_Q^2.', 'APP', NULL, 216, 218, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C1.c', 'C1', 'remark', 'Information inclusion', 'If G_i is contained in G''_i for all i then S(A) is contained in S(A'') and R(A'') <= R(A).', 'APP', 'eq:info_inclusion', 111, 119, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C10', NULL, 'theorem', 'Fresh-local versus stale-global crossover', 'With R_inf > 0 and 0 <= eta_S(0) < 1, fresh-local is strictly better exactly when tau/T > rho* = (1/2) log(1/(1 - eta_S(0))); equality gives equal regret; if eta_S(0) = 1 no finite delay gives a strict local advantage.', 'MAIN', 'thm:local_global_crossover', 429, 444, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C11', NULL, 'example', 'Two-sensor example', 'One fresh sensor has MSE sigma^2/4; both old readings have MSE (sigma^2/2)(1 - exp(-2 tau/T)); the fresh reading wins iff tau > T log(2)/2.', 'MAIN', NULL, 66, 91, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C12', NULL, 'proposition', 'Local explainability under aggregate coupling', 'For f = sum_i (q/2 x_i^2 - theta_i x_i) + (gamma/2)(sum_i x_i)^2 with independent mean-zero equal-variance theta_i: the optimal fresh-local policy is theta_i/(q+gamma) and eta_S(0) = gamma^2 (n-1) / ((q+gamma)(q+gamma(n-1))); R_inf and R_loc as in APP eq:aggregate_Rinf, eq:aggregate_Rloc.', 'MAIN', 'prop:aggregate_local', 506, 556, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13', NULL, 'remark', 'Explicit aggregate-coupling threshold', 'rho*(gamma,n) = (1/2) log[(q+gamma)(q+gamma(n-1)) / (q(q+gamma n))], and R_loc < R_glob(tau) iff tau/T > rho*(gamma,n).', 'MAIN', 'eq:aggregate_rho_star', 558, 590, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13.b', 'C13', 'remark', 'Large-n limit of the threshold', 'rho*(gamma,n) -> (1/2) log(1 + gamma/q) as n -> infinity; local information captures share q/(q+gamma) in the limit.', 'MAIN', 'eq:large_n_threshold', 592, 607, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C13.c', 'C13', 'remark', 'Threshold behaviour in the coupling strength', 'gamma = 0 gives eta_S(0) = 0; eta_S(0) and the crossover increase with gamma.', 'MAIN', NULL, 609, 616, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C14', NULL, 'remark', 'Radius objective and one-more-hop criterion', 'With G(r) = (1 - eta_S(r)) exp(-2 tau(r)/T): R(r) = R_inf [1 - G(r)]; one more hop improves performance iff G(r+1) > G(r); R(r)/R_inf = (1 - exp(-2 tau(r)/T)) + exp(-2 tau(r)/T) eta_S(r).', 'MAIN', 'eq:snapshot_gain', 627, 664, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15', NULL, 'proposition', 'Continuous marginal-balance characterization', 'With tau, eta_S continuously differentiable on [0,D], tau'' >= 0, eta_S'' <= 0, 0 <= eta_S < 1: every interior optimal radius satisfies d/dr log[1 - eta_S(r)] = 2 tau''(r)/T.', 'MAIN', 'thm:marginal_balance', 666, 686, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15.b', 'C15', 'remark', 'Single-crossing gives the unique optimum', 'If the difference of the two sides of the balance condition is strictly decreasing in r, its sign identifies the unique optimum (0, D, or the unique interior crossing).', 'MAIN', NULL, 688, 693, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C15.c', 'C15', 'remark', 'Comparative statics in T and latency scale', 'Holding the omission curve fixed under single crossing, increasing T moves the preferred radius weakly outward; increasing alpha in tau = alpha tau_0 moves it weakly inward.', 'MAIN', NULL, 694, 698, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C16', NULL, 'proposition', 'Optimal radius for exponential omission', 'For eta_S(r) = eta_0 exp(-2r/l_c), 0 < eta_0 < 1, l_c > 0, tau(r) = r/v, v > 0, continuous r >= 0: the unique global optimum is r* = (l_c/2)[log(eta_0 (1 + vT/l_c))]_+, positive iff eta_0 (1 + vT/l_c) > 1; with cap D the optimum is min{D, r*}.', 'MAIN', 'prop:generic_exponential_radius', 706, 733, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C17', NULL, 'definition', 'Canonical line model', 'Zero-mean Gaussian field on the line with covariance sigma^2 exp(-|z-z''|/l_s) exp(-|t-s|/T); target x*(z,t) = integral of w_{l_c}(u) theta(z+u,t) du with w = exp(-|u|/l_c)/(2 l_c); loss (q/2)[x(z) - x*(z)]^2; observation of all field values within distance r; tau(r) = r/v; regret per unit length.', 'MAIN', 'subsec:canonical_line_model', 741, 785, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C17.b', 'C17', 'implicit', 'Composition law holds in the continuum model', 'Used but not stated: the composition law (C7), proved for a finite-dimensional stacked state, applies per location to the canonical field model with continuous radius.', 'MAIN', NULL, 813, 843, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C18', NULL, 'lemma', 'Exponential omission by self-similarity', 'In the canonical model eta_S(r) = eta_0 exp(-2r/l_c) with eta_0 = l_c/(l_c + 2 l_s).', 'MAIN', 'prop:canonical_eta_S', 787, 810, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C19', NULL, 'theorem', 'Optimal synchronized-snapshot radius in the canonical model', 'r* = (l_c/2)[log((l_c + vT)/(l_c + 2 l_s))]_+ is the unique optimal radius on the infinite line; r* > 0 iff vT > 2 l_s.', 'MAIN', 'thm:canonical_optimal_radius', 813, 850, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C19.b', 'C19', 'remark', 'Comparative statics of the canonical radius', 'In the interior regime r* increases with T, increases with v, decreases with l_s, and increases with l_c.', 'MAIN', NULL, 829, 850, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C2', NULL, 'corollary', 'Coupled conditional normal equations', 'The team optimum satisfies E[(Q u* - b(theta))_i | G_i] = 0 for every i; these equations are necessary and sufficient; agentwise conditional means are not optimal in general.', 'APP', 'cor:conditional_normal_equations', 220, 269, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C20', NULL, 'remark', 'Large decision-range limit', 'With vT > 2 l_s fixed, r* -> (vT - 2 l_s)/2 as l_c -> infinity.', 'MAIN', NULL, 859, 862, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C21', NULL, 'numeric', 'Fig. local-global phase', 'Monte Carlo crossover estimates agree with the exact boundary; what the estimator does and does not check.', 'MAIN', 'fig:local-global-phase', 874, 905, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C22', NULL, 'numeric', 'Fig. radius-regret', 'Three regimes with constrained optima 0, 0.62638, 2 for l_c = 1, D = 2.', 'MAIN', 'fig:radius-regret', 907, 936, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C23', NULL, 'numeric', 'Fig. decision relevance', '64-node ring, T = 6, latency 0.12/hop, l_c = 0.7, 2, 6 gives optimal radii 1, 2, 5.', 'MAIN', 'fig:decision-relevance', 938, 973, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C24', NULL, 'numeric', 'Fig. general graphs', 'Path, ring, grid, random geometric graph: reference optima 2, 2, 3, 2; diameters 63, 32, 14, 8.', 'MAIN', 'fig:general-graphs', 975, 1016, 'numeric', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C25', NULL, 'prose', 'Abstract and contribution list', '''Exact rule'', ''allows non-Gaussian states and nonlinear decision rules'', ''gives the optimal observation radius'', ''one to five hops''.', 'MAIN', NULL, 46, 149, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C26', NULL, 'prose', 'Related-work positioning and attribution', 'Positioning against Radner, Marschak-Radner, Krainak-Speyer-Marcus, Ballotta et al., age of information.', 'MAIN', 'sec:related_work', 1018, 1107, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C27', NULL, 'prose', 'Discussion: scope, limitations, assumptions per result', 'Which assumptions each result uses; design implication.', 'MAIN', 'sec:discussion_conclusions', 1109, 1181, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3', NULL, 'remark', 'Common information: vector conditional mean is optimal', 'If every agent observes the same Z, m = E[x* | Z] is the unique optimum regardless of off-diagonal Q.', 'APP', NULL, 271, 276, 'lean', 'C', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3.b', 'C3', 'remark', 'Degenerate normalization R_inf = 0', 'In centered coordinates R_inf = 0 and Q > 0 imply x* = 0 a.s.; the zero rule has zero regret under every architecture, so the unnormalized composition law still holds.', 'APP', NULL, 284, 288, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C3.c', 'C3', 'prose', 'Delay monotonicity, stationarity versus ergodicity remarks', 'Under a stationary Markov environment prediction loss from a common old snapshot is nondecreasing in delay; stationarity makes expected snapshot regret time-invariant; sample-path averages additionally need ergodicity.', 'APP', NULL, 277, 292, 'prose', NULL, NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4', NULL, 'assumption', 'Common temporal prediction rule', 'Stationary state with finite second moments and, for each delay tau, theta_t = a theta_{t-tau} + eps with a = exp(-tau/T), T > 0, and E[eps | theta_{t-tau}] = 0.', 'MAIN', 'eq:state_innovation_decomposition', 279, 301, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4.b', 'C4', 'remark', 'Stationary AR(1) satisfies the prediction rule', 'A stationary AR(1) process with coefficient 0 < c < 1 and independent mean-zero finite-variance innovations has lag-k prediction coefficient c^k (composition weights 1 - c^(2k) and c^(2k)).', 'MAIN', NULL, 310, 312, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C4.c', 'C4', 'remark', 'Stationary Gaussian OU satisfies the prediction rule', 'The stationary Gaussian Ornstein-Uhlenbeck process (APP eq:OU_process) has independent Gaussian innovations and Cov(theta_t, theta_s) = exp(-|t-s|/T) Sigma_S, hence satisfies C4.', 'APP', 'app:temporal-special-cases', 294, 313, 'lean', 'D', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C5', NULL, 'definition', 'Quadratic cost and completing the square', 'f(x,theta) = (1/2) x''Qx - b(theta)''x + c(theta), Q symmetric positive definite, x* = Q^{-1} b(theta); f(x,theta) - f(x*,theta) = (1/2)(x-x*)''Q(x-x*).', 'APP', 'eq:complete_square', 25, 68, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C5.b', 'C5', 'remark', 'Centering the affine model is without loss', 'With b affine, translating observations and actions by known means is a bijection of admissible rules that leaves x - x* unchanged; the centered target is K theta^c.', 'APP', NULL, 87, 97, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6', NULL, 'definition', 'Architectures, admissible rules, regret, R_inf, eta_S', 'Neighborhood N_r(i); observation Z_i^(r,tau) = (theta_{j,t-tau} : j in N_r(i)); admissible rule u_i = g_i(Z_i) with finite second moment; R(A) = inf (1/2) E[(u-x*)''Q(u-x*)]; R_inf; eta_S(r) = R(A_{r,0})/R_inf.', 'MAIN', 'eq:architecture_regret', 172, 277, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6.b', 'C6', 'remark', 'No-information loss formula', 'The best no-information action is zero in centered coordinates, with loss R_inf = (1/2) E[x*''Q x*] = (1/2) tr(K''QK Sigma_S).', 'MAIN', 'eq:Rinf_general', 262, 267, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C6.c', 'C6', 'remark', 'Omission share is in [0,1], nonincreasing, zero at the diameter', '0 <= eta_S(r) <= 1; larger fresh neighborhoods cannot increase it; at the diameter of a finite connected graph the fresh view is complete and omission is zero.', 'MAIN', 'eq:eta_S_definition', 268, 277, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C7', NULL, 'theorem', 'Spatio-temporal composition', 'R(A_{r,tau}) = (1 - a^2) R_inf + a^2 R(A_{r,0}), a = exp(-tau/T), for every radius r and finite delay tau >= 0, over all admissible finite-second-moment rules and any deterministic Q > 0.', 'MAIN', 'thm:spatiotemporal_composition', 322, 386, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C7.b', 'C7', 'remark', 'Normalized composition law', 'For R_inf > 0: 1 - R(A_{r,tau})/R_inf = exp(-2 tau/T) [1 - eta_S(r)].', 'MAIN', 'eq:regret_composition_normalized', 334, 339, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8', NULL, 'corollary', 'Exact stale-global regret', 'A complete snapshot of age tau gives R_glob(tau) = (1 - exp(-2 tau/T)) R_inf.', 'MAIN', 'thm:OU_stale_regret', 396, 408, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8.b', 'C8', 'remark', 'Optimal stale-global action', 'The optimal global action is a K theta_{t-tau}.', 'MAIN', NULL, 409, 409, 'lean', 'B', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C8.c', 'C8', 'remark', 'Small-delay expansion and large-delay limit', 'R_glob is zero at zero delay, grows as 2 (tau/T) R_inf + o(tau/T), and tends to R_inf as delay grows.', 'MAIN', NULL, 409, 412, 'lean', 'A', NULL);
INSERT INTO claims (id, parent, kind, title, statement, source, label, line_start, line_end, scope, tier, notes) VALUES ('C9', NULL, 'remark', 'Unequal-rate formula for a complete old snapshot', 'If a complete old snapshot reveals independent stationary OU modes with coherence times T_k and w_k is the share of R_inf > 0 attributable to mode k, then 1 - R_glob(tau)/R_inf = sum_k w_k exp(-2 tau/T_k).', 'MAIN', NULL, 414, 427, 'lean', 'D', NULL);

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
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C17.b', 'C7', 'uses', NULL);
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
INSERT INTO claim_deps (claim_id, depends_on, kind, note) VALUES ('C3', 'C5', 'uses', 'error expansion');
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
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C14/p1', 'C14', 1, NULL, 'in_paper', 1, 'Direct substitution of the composition law.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C15/p1', 'C15', 1, NULL, 'in_paper', 1, 'First-order condition for log G.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C16/p1', 'C16', 1, NULL, 'in_paper', 1, 'Sign analysis of G''.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C18/p1', 'C18', 1, NULL, 'in_paper', 1, 'Appendix: variance ratio, tail split, spatial Markov property, shift invariance, covariance integrals.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C18/p2', 'C18', 2, NULL, 'in_paper', 0, 'Main-text sketch of C18/p1.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C19.b/p1', 'C19.b', 1, NULL, 'in_paper', 1, 'Two partial derivatives and an integral representation.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C19/p1', 'C19', 1, NULL, 'in_paper', 1, 'Substitute the lemma into the exponential-omission proposition.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C2/p1', 'C2', 1, NULL, 'in_paper', 1, 'First-order condition with one-agent perturbations; converse by expansion.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C3.b/p1', 'C3.b', 1, NULL, 'in_paper', 1, 'Zero target, zero rule.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C3/p1', 'C3', 1, NULL, 'in_paper', 1, 'Orthogonality by conditioning, then error expansion.', '2026-11-13T13:26:00');
INSERT INTO proofs (id, claim_id, version, parent, status, is_primary, summary, created) VALUES ('C5.b/p1', 'C5.b', 1, NULL, 'in_paper', 1, 'Translation bijection.', '2026-11-13T13:26:00');
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
$\eta_S(0)<1-e^{-2\tau/T}$.', 'MAIN', 442, 443);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C10/p1/s2', 'C10/p1', 2, 'Rearrange to the threshold and the equality case', 'Rearranging gives the threshold and equality case.', 'MAIN', 443, 443);
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
$\mathbb E[\widetilde u_i]=0$.', 'MAIN', 535, 537);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s2', 'C12/p1', 2, 'Expected cost under independence and zero means', 'Independence across agents and zero state
means give
\begin{align}
\mathbb E[f(u,\theta)]={}&
\sum_i\mathbb E\left[\frac{q+\gamma}{2}\widetilde u_i^2
-\theta_i\widetilde u_i\right]
+\frac q2\sum_i\mu_i^2+\frac\gamma2\left(\sum_i\mu_i\right)^2.
\label{eq:aggregate_centered_cost}
\end{align}', 'MAIN', 537, 545);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s3', 'C12/p1', 3, 'Mean terms are minimized at zero', 'The mean terms are minimized at zero.', 'MAIN', 546, 546);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s4', 'C12/p1', 4, 'Each centered term minimized pointwise by theta_i/(q+gamma)', 'Each remaining term is minimized
pointwise by $\widetilde u_i=\theta_i/(q+\gamma)$, which is feasible and
has zero mean.', 'MAIN', 546, 548);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s5', 'C12/p1', 5, 'Local cost -n sigma^2/[2(q+gamma)]; best constant cost zero', 'Thus the expected local cost is
$-n\sigma^2/[2(q+\gamma)]$, and the best constant cost is zero.', 'MAIN', 548, 549);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s6', 'C12/p1', 6, 'Eigenvalues of Q and the full-information cost', 'The eigenvalues of $Q$ are $q+\gamma n$ once and $q$ with multiplicity
$n-1$. The full-information expected cost is therefore
$-(\sigma^2/2)[(n-1)/q+1/(q+\gamma n)]$.', 'MAIN', 550, 552);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p1/s7', 'C12/p1', 7, 'Subtract to get R_inf, R_loc; take the ratio', 'Subtracting this cost from the local and constant costs gives
Eqs.~\eqref{eq:aggregate_Rinf}--\eqref{eq:aggregate_Rloc} in
Appendix~\ref{app:technical-aggregate}; their ratio is the stated omission share.', 'MAIN', 553, 555);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s1', 'C12/p2', 1, 'Inverse of Q', 'For $Q=qI+\gamma\mathbf1\mathbf1^\top$,
\[
Q^{-1}=\frac1q\left(I-\frac{\gamma}{q+\gamma n}\mathbf1\mathbf1^\top\right).
\]', 'APP', 341, 344);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s2', 'C12/p2', 2, 'Normal equations with Q_ii = q+gamma, Q_ij = gamma, b_i = theta_i', 'Recall the coupled normal equations \eqref{eq:block_conditional_normal_equations}
from Appendix~\ref{app:technical-projection}:
\[
 Q_{ii}u_i+\sum_{j\ne i}Q_{ij}\mathbb E[u_j\mid\mathcal G_i]
 =\mathbb E[b_i(\theta_t)\mid\mathcal G_i].
\]
Here $Q_{ii}=q+\gamma$, $Q_{ij}=\gamma$ for $j\ne i$, and $b_i(\theta)=\theta_i$.', 'APP', 346, 352);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s3', 'C12/p2', 3, 'Independence gives E[u_j | G_i] = mu_j', 'Let $\mu_j=\mathbb E[u_j]$. For $j\ne i$, the policy $u_j$ is a function of $\theta_{j,t}$,
which is independent of $\theta_{i,t}$, so
\[
\mathbb E[u_j\mid\mathcal G^{\mathrm{loc}}_{i,t}]
=\mathbb E[u_j]=\mu_j,
\]
while $\theta_{i,t}$ is
$\mathcal G^{\mathrm{loc}}_{i,t}$-measurable.', 'APP', 353, 360);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s4', 'C12/p2', 4, 'Normal equation reduces to (q+gamma) u_i + gamma sum mu_j - theta_i = 0', 'The conditional normal equation
\eqref{eq:block_conditional_normal_equations} therefore gives
\[
(q+\gamma)u_i
+\gamma\sum_{j\ne i}\mu_j
-\theta_{i,t}=0.
\]', 'APP', 360, 366);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s5', 'C12/p2', 5, 'Means vanish, so u_i = theta_i/(q+gamma)', 'Taking expectations yields
\[
q\mu_i+\gamma\sum_j\mu_j=0.
\]
Summing over $i$ implies $\sum_j\mu_j=0$, hence every $\mu_i=0$ and
$u_i=\theta_{i,t}/(q+\gamma)$, which proves
\eqref{eq:optimal_local_shared}.', 'APP', 367, 373);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s6', 'C12/p2', 6, 'Open-loop regret from tr(Q^{-1})', '\emph{Open-loop regret.} Here $B=I$ and $\Sigma_S=\sigma^2I$, so by \eqref{eq:Rinf_general}, $R_\infty=\tfrac{\sigma^2}2\operatorname{tr}(Q^{-1})$. From the Sherman--Morrison formula above,

\[
\operatorname{tr}(Q^{-1})=\frac1q\Big(n-\frac{\gamma n}{q+\gamma n}\Big)=\frac{n\,(q+\gamma(n-1))}{q\,(q+\gamma n)},
\]

which gives \eqref{eq:aggregate_Rinf}.', 'APP', 375, 381);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s7', 'C12/p2', 7, 'Local regret from the Pythagorean identity', '\emph{Local regret.} By the Pythagorean form of Lemma~\ref{lem:radner_projection} (the orthogonality identity in Appendix~\ref{app:technical-projection}, with both $x^\star$ and $u^{\rm loc}$ mean zero), $2R_{\rm loc}=\|x^\star\|_Q^2-\|u^{\rm loc}\|_Q^2=2R_\infty-\|u^{\rm loc}\|_Q^2$. Since $u^{\rm loc}=\theta/(q+\gamma)$ and $\operatorname{tr}(Q)=n(q+\gamma)$,

\[
\|u^{\rm loc}\|_Q^2=\frac{\sigma^2\operatorname{tr}(Q)}{(q+\gamma)^2}=\frac{n\sigma^2}{q+\gamma}.
\]

Therefore

\[
R_{\rm loc}=\frac{n\sigma^2}{2}\left[\frac{q+\gamma(n-1)}{q(q+\gamma n)}-\frac{1}{q+\gamma}\right]=\frac{n\sigma^2}{2}\cdot\frac{(q+\gamma(n-1))(q+\gamma)-q(q+\gamma n)}{q(q+\gamma)(q+\gamma n)} .
\]

The numerator reduces to $\gamma^2(n-1)$, which gives \eqref{eq:aggregate_Rloc}.', 'APP', 383, 395);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C12/p2/s8', 'C12/p2', 8, 'Share is the ratio', '\emph{Share.} Dividing \eqref{eq:aggregate_Rloc} by \eqref{eq:aggregate_Rinf}, the factors $n\sigma^2/2$ and $q(q+\gamma n)$ cancel, leaving \eqref{eq:aggregate_eta}.', 'APP', 397, 397);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C14/p1/s1', 'C14/p1', 1, 'R(r) = R_inf [1 - G(r)] from C7', 'Writing $R(r)=R(\mathcal A_{r,\tau(r)})$,
Theorem~\ref{thm:spatiotemporal_composition} gives
$R(r)=R_\infty[1-G(r)]$, so the best radius maximizes $G(r)$.', 'MAIN', 635, 637);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s1', 'C15/p1', 1, 'Maximizing G is maximizing log G', 'Since $G(r)>0$, maximizing $G$ is equivalent to maximizing $\log G$.', 'MAIN', 683, 683);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s2', 'C15/p1', 2, 'Interior optimum has (log G)'' = 0', 'At an interior optimum, $(\log G)''=0$;', 'MAIN', 684, 684);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C15/p1/s3', 'C15/p1', 3, 'Differentiate the snapshot gain', 'differentiating
Eq.~\eqref{eq:snapshot_gain} gives the stated equality.', 'MAIN', 684, 685);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s1', 'C16/p1', 1, 'Formula for G''(r)', 'Differentiating the captured benefit gives
\[
G''(r)=2e^{-2r/(vT)}\left[
\eta_0\left(\frac{1}{vT}+\frac{1}{\ell_c}\right)e^{-2r/\ell_c}
-\frac{1}{vT}\right].
\]', 'MAIN', 722, 727);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s2', 'C16/p1', 2, 'The bracket decreases strictly to a negative limit', 'The bracket decreases strictly to a negative limit.', 'MAIN', 728, 728);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s3', 'C16/p1', 3, 'Nonpositive at zero: G decreasing, zero is the unique maximum', 'If its value at zero
is nonpositive, $G$ decreases for all positive radii and zero is its unique
maximum, including when the initial derivative is zero.', 'MAIN', 728, 730);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s4', 'C16/p1', 4, 'Otherwise G rises to a unique crossing then falls', 'Otherwise $G$
increases up to its unique crossing and decreases thereafter.', 'MAIN', 730, 731);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s5', 'C16/p1', 5, 'Solve for the crossing', 'Solving for
the crossing gives the formula;', 'MAIN', 731, 732);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C16/p1/s6', 'C16/p1', 6, 'A cap truncates the maximizer', 'a cap truncates the maximizing radius.', 'MAIN', 732, 732);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s1', 'C18/p1', 1, 'Step 0: omission is a conditional-variance ratio', 'By spatial stationarity, take $z=0$ and suppress the time argument. Write $\beta_c\triangleq1/\ell_c$ and $\beta_s\triangleq1/\ell_s$ for the inverse lengths, so $w(u)=\tfrac{\beta_c}{2}e^{-\beta_c|u|}$ and $\operatorname{Cov}(\theta(u),\theta(u''))=\sigma^2e^{-\beta_s|u-u''|}$.

\textbf{Step 0 (omission is a variance ratio).} With $Q=qI$ the optimal policy given $\mathcal O_r$ is $\mathbb E[x^\star(0)\mid\mathcal O_r]$. Its expected loss is $\tfrac q2\,\mathbb E\big[\operatorname{Var}(x^\star(0)\mid\mathcal O_r)\big]$. For a Gaussian field the conditional variance is a deterministic number: it does not depend on the observed values (the Gaussian conditional covariance is independent of the observed values). Since $R_\infty=\tfrac q2\operatorname{Var}(x^\star(0))$,

\[
\eta_S(r)=\frac{\operatorname{Var}(x^\star(0)\mid\mathcal O_r)}{\operatorname{Var}(x^\star(0))}.
\]', 'APP', 409, 415);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s2', 'C18/p1', 2, 'Step 1: split target into observed middle and two tails', '\textbf{Step 1 (split into observed middle and two tails).} Write $x^\star(0)=M_r+T_r^++T_r^-$, where

\[
M_r=\int_{-r}^{r}w(u)\theta(u)\,du,\qquad T_r^+=\int_r^\infty w(u)\theta(u)\,du,\qquad T_r^-=\int_{-\infty}^{-r}w(u)\theta(u)\,du .
\]

The middle $M_r$ is computed from observed values, so it contributes no conditional variance.', 'APP', 417, 423);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s3', 'C18/p1', 3, 'Step 2: rewrite the right tail with weight exp(-beta_c r)', '\textbf{Step 2 (rewrite the right tail).} Substituting $u=r+s$,

\[
T_r^+=\frac{\beta_c}{2}e^{-\beta_c r}\,Y_r,\qquad Y_r\triangleq\int_0^\infty e^{-\beta_c s}\,\theta(r+s)\,ds .
\]', 'APP', 425, 429);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s4', 'C18/p1', 4, 'Step 3: spatial Markov property', '\textbf{Step 3 (spatial Markov property).} By the exponential-covariance model in Section~\ref{subsec:canonical_line_model}, the field is Markov in $z$. Given the observed segment $[-r,r]$, the right tail $\{\theta(u):u>r\}$ and the left tail $\{\theta(u):u<-r\}$ are conditionally independent, and each depends on the segment only through its adjacent endpoint $\theta(r)$ or $\theta(-r)$. Therefore

\[
\operatorname{Var}(T_r^+\mid\mathcal O_r)=\operatorname{Var}(T_r^+\mid\theta(r)),\qquad \operatorname{Var}(T_r^-\mid\mathcal O_r)=\operatorname{Var}(T_r^-\mid\theta(-r)),\qquad \operatorname{Cov}(T_r^+,T_r^-\mid\mathcal O_r)=0 .
\]', 'APP', 431, 435);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s5', 'C18/p1', 5, 'Step 4: tail variance does not depend on r; eta_S(r) = eta_S(0) exp(-2r/l_c)', '\textbf{Step 4 (the tail variance does not depend on $r$).} Define $C\triangleq\operatorname{Var}(Y_0\mid\theta(0))$. Shifting the field by $r$ does not change its law, so $\operatorname{Var}(Y_r\mid\theta(r))=C$ for every $r$. By reflection symmetry (the covariance depends only on $|u-u''|$), the left tail gives the same value. Hence

\[
\operatorname{Var}(x^\star(0)\mid\mathcal O_r)=2\Big(\frac{\beta_c}{2}\Big)^2e^{-2\beta_c r}\,C=\frac{\beta_c^2}{2}e^{-2\beta_c r}\,C .
\]

At $r=0$ the same argument applies with $\mathcal O_0=\sigma(\theta(0))$ and $M_0=0$, giving $\operatorname{Var}(x^\star(0)\mid\theta(0))=\tfrac{\beta_c^2}{2}C$. Dividing, $\eta_S(r)=\eta_S(0)\,e^{-2\beta_c r}=\eta_S(0)\,e^{-2r/\ell_c}$. The unknown constant $C$ cancels, so it never has to be computed.', 'APP', 437, 443);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s6', 'C18/p1', 6, 'Step 5a: eta_S(0) = 1 - Corr^2', '\textbf{Step 5 (the constant $\eta_S(0)$).} Conditioning on the single Gaussian variable $\theta(0)$ gives $\operatorname{Var}(x^\star(0)\mid\theta(0))=\operatorname{Var}(x^\star(0))\big(1-\operatorname{Corr}(x^\star(0),\theta(0))^2\big)$ (the Gaussian conditional covariance is independent of the observed values), so $\eta_S(0)=1-\operatorname{Corr}^2$. Two moments are needed.', 'APP', 445, 445);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s7', 'C18/p1', 7, 'Step 5b: covariance of the target with the local value', '\emph{Covariance with the local value:}

\[
\operatorname{Cov}(x^\star(0),\theta(0))=\int_{\mathbb R}w(u)\,\sigma^2e^{-\beta_s|u|}\,du=\frac{\sigma^2\beta_c}{2}\int_{\mathbb R}e^{-(\beta_c+\beta_s)|u|}\,du=\frac{\sigma^2\beta_c}{\beta_c+\beta_s}.
\]', 'APP', 447, 451);
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
\end{equation}', 'APP', 453, 471);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p1/s9', 'C18/p1', 9, 'Step 5d: combine to eta_S(0) = l_c/(l_c + 2 l_s)', '\emph{Combine.} With $\operatorname{Var}(\theta(0))=\sigma^2$,

\[
\operatorname{Corr}^2=\frac{\big(\sigma^2\beta_c/(\beta_c+\beta_s)\big)^2}{\sigma^2\cdot\sigma^2\beta_c(2\beta_c+\beta_s)/\big(2(\beta_c+\beta_s)^2\big)}=\frac{2\beta_c}{2\beta_c+\beta_s},\qquad \eta_S(0)=\frac{\beta_s}{2\beta_c+\beta_s}=\frac{\ell_c}{\ell_c+2\ell_s}.
\]', 'APP', 473, 477);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C18/p2/s1', 'C18/p2', 1, 'Sketch: self-similarity of the tails', 'By stationarity, set $z=0$ and suppress time. The observed middle of the
target integral contributes no uncertainty. Conditional on the two boundary
values, the unobserved tails are independent by the spatial Markov property.
Moving each tail outward by $r$ scales its weight by $e^{-r/\ell_c}$,
while stationarity leaves its conditional variance relative to its boundary
unchanged. Squaring the weight therefore gives
$\eta_S(r)=e^{-2r/\ell_c}\eta_S(0)$.
The covariance integrals in Appendix~\ref{app:technical-canonical} give
$\eta_S(0)=\ell_c/(\ell_c+2\ell_s)$.', 'MAIN', 801, 809);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s1', 'C19.b/p1', 1, 'Derivative in vT is positive', 'In the positive-radius regime,
$\partial r^\star/\partial(vT)=\ell_c/[2(\ell_c+vT)]>0$', 'MAIN', 843, 844);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s2', 'C19.b/p1', 2, 'Derivative in l_s is negative', '$\partial r^\star/\partial\ell_s=-\ell_c/(\ell_c+2\ell_s)<0$.', 'MAIN', 845, 845);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19.b/p1/s3', 'C19.b/p1', 3, 'Integral representation gives the increase in l_c', 'For the positive-radius regime $vT>2\ell_s$, Theorem~\ref{thm:canonical_optimal_radius}
can be written as
\begin{equation}
r^\star=\frac12\int_{2\ell_s}^{vT}\frac{\ell_c}{\ell_c+s}\,ds.
\label{eq:rstar_integral_representation}
\end{equation}
With $vT$ and $\ell_s$ fixed, the integration limits do not change and
$\ell_c/(\ell_c+s)=1-s/(\ell_c+s)$ is strictly increasing in $\ell_c$
for every $s>0$. Thus $r^\star$ increases strictly with $\ell_c$ in this
regime, proving the fourth comparative static.', 'APP', 481, 490);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19/p1/s1', 'C19/p1', 1, 'eta_0 from the lemma', 'Lemma~\ref{prop:canonical_eta_S} gives
$\eta_0=\ell_c/(\ell_c+2\ell_s)$.', 'MAIN', 840, 841);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C19/p1/s2', 'C19/p1', 2, 'Substitute into C16: radius and threshold vT > 2 l_s', 'Substitution into
Proposition~\ref{prop:generic_exponential_radius} gives the radius and
the threshold $vT>2\ell_s$.', 'MAIN', 841, 843);
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
imply $x_t^\star=0$ almost surely.', 'APP', 285, 286);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3.b/p1/s2', 'C3.b/p1', 2, 'Zero rule has zero regret, so the unnormalized law holds', 'The zero rule has zero regret under
every architecture, so the unnormalized composition law remains valid
while normalized shares are undefined.', 'APP', 286, 288);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3/p1/s1', 'C3/p1', 1, 'Conditioning gives E[h''Q(x* - m)] = 0', 'If every agent observes the same $Z$, let $m=\mathbb E[x^\star\mid Z]$.
For every admissible perturbation $h$, conditioning gives
$\mathbb E[h^\top Q(x^\star-m)]=0$.', 'APP', 272, 274);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C3/p1/s2', 'C3/p1', 2, 'Error expansion makes m the unique optimum', 'The error expansion then proves that
$m$ is the unique optimum, regardless of the off-diagonal entries of $Q$.', 'APP', 274, 275);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C5.b/p1/s1', 'C5.b/p1', 1, 'Translating by known means is a bijection leaving x - x* unchanged', 'Translating each observation and
each action by its known mean gives a bijection of the admissible rules
and leaves $x-x^\star$ unchanged. Thus Eq.~\eqref{eq:complete_square}
is precisely the tracking loss of the main text in centered coordinates.', 'APP', 92, 95);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C6.c/p1/s1', 'C6.c/p1', 1, 'Larger fresh neighborhoods cannot increase eta_S', 'Larger fresh neighborhoods cannot increase it, since their
extra observations can be ignored.', 'MAIN', 274, 275);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C6.c/p1/s2', 'C6.c/p1', 2, 'At the diameter the fresh view is complete and omission is zero', 'at the diameter of a finite connected
graph the fresh view is complete and omission is zero.', 'MAIN', 276, 277);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s1', 'C7/p1', 1, 'Apply K to the transition', 'Applying $K$ to the transition gives
\begin{equation}
x_t^\star=a x_{t-\tau}^\star+K\varepsilon_{t,\tau}.
\label{eq:xstar_innovation_decomposition}
\end{equation}', 'MAIN', 347, 351);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s2', 'C7/p1', 2, 'Rules are functions of the old state; cross term vanishes', 'Every joint admissible rule $u$ is a function of the complete old state,
although its components each use only their own neighborhood. On expanding
the squared tracking error, the cross term vanishes:
\begin{align*}
&\mathbb E[(a x_{t-\tau}^\star-u)^\top QK\varepsilon_{t,\tau}]\\
&\quad=\mathbb E[(a x_{t-\tau}^\star-u)^\top QK
\mathbb E[\varepsilon_{t,\tau}\mid\theta_{t-\tau}]]=0.
\end{align*}', 'MAIN', 352, 359);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s3', 'C7/p1', 3, 'Error splits into predictable part plus disturbance', 'Thus the error is the sum of a predictable-part error and a disturbance error:
\begin{align}
\mathbb E[(x_t^\star-u)^\top Q(x_t^\star-u)]
={}&\mathbb E[(a x_{t-\tau}^\star-u)^\top Q(a x_{t-\tau}^\star-u)]\nonumber\\
&+\mathbb E[(K\varepsilon_{t,\tau})^\top Q(K\varepsilon_{t,\tau})].
\label{eq:innovation_split}
\end{align}', 'MAIN', 360, 366);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s4', 'C7/p1', 4, 'Disturbance energy is 2(1-a^2) R_inf (u = 0, stationarity)', 'Apply the same expansion with $u=0$. Stationarity gives
\begin{equation}
\mathbb E[(K\varepsilon_{t,\tau})^\top Q(K\varepsilon_{t,\tau})]
=(1-a^2)\mathbb E[(x_t^\star)^\top Qx_t^\star]=2(1-a^2)R_\infty.
\label{eq:innovation_energy}
\end{equation}', 'MAIN', 367, 372);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s5', 'C7/p1', 5, 'Rescaling u = a u~ is a bijection of admissible rules', 'For finite delay $a>0$, write $u=a\widetilde u$. This rescaling is a
bijection of the admissible rule class: each component uses exactly the
same observations and still has finite second moment. Consequently,
\begin{align}
&\inf_u\mathbb E[(a x_{t-\tau}^\star-u)^\top Q(a x_{t-\tau}^\star-u)]\nonumber\\
&\quad=a^2\inf_{\widetilde u}\mathbb E[(x_{t-\tau}^\star-\widetilde u)^\top
Q(x_{t-\tau}^\star-\widetilde u)]
=2a^2R(\mathcal A_{r,0}).
\label{eq:policy_rescaling}
\end{align}', 'MAIN', 373, 382);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s6', 'C7/p1', 6, 'Fresh problem at the old epoch equals R(A_{r,0}) by stationarity', 'The last equality uses stationarity and the same observation pattern at
each epoch.', 'MAIN', 383, 384);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C7/p1/s7', 'C7/p1', 7, 'Combine and divide by two; normalize when R_inf > 0', 'Combining the two errors and dividing by two proves the law;
normalization is valid when $R_\infty>0$.', 'MAIN', 384, 385);
INSERT INTO steps (id, proof_id, ordinal, title, tex, source, line_start, line_end) VALUES ('C8/p1/s1', 'C8/p1', 1, 'Desired action feasible, R(A_{r,0}) = 0, substitute in C7', 'With a complete fresh snapshot the desired action is feasible, so
$R(\mathcal A_{r,0})=0$ in Eq.~\eqref{eq:regret_composition_unnormalized}.', 'MAIN', 406, 407);

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
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s1', 'claim', 'C14');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s2', 'step', 'C15/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C15/p1/s3', 'step', 'C15/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s1', 'claim', 'C14');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s2', 'step', 'C16/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s3', 'step', 'C16/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s4', 'step', 'C16/p1/s2');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s5', 'step', 'C16/p1/s4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s6', 'step', 'C16/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C16/p1/s6', 'step', 'C16/p1/s4');
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
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C2/p1/s3', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C2/p1/s4', 'step', 'C2/p1/s3');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3.b/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3.b/p1/s2', 'step', 'C3.b/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3/p1/s1', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3/p1/s2', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C3/p1/s2', 'step', 'C3/p1/s1');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C5.b/p1/s1', 'claim', 'C5');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C6.c/p1/s1', 'claim', 'C1.c');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C6.c/p1/s2', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s1', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'claim', 'C4');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'claim', 'C6');
INSERT INTO step_deps (step_id, dep_kind, dep_id) VALUES ('C7/p1/s2', 'step', 'C7/p1/s1');
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

-- findings
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F1', 'C17.b', NULL, 'medium', 'Continuum model uses the finite-graph composition theorem without a bridge', 'C16 is stated ''Under Theorem C7'' and C19 is proved by substitution into C16, but C7 is stated and proved for a finite-dimensional stacked state with matrices K and Q. The canonical model has a field-valued state, an integral target and continuous radius, and the temporal conditional-mean assumption is not verified for the field (needs joint Gaussianity in space and time). The Lean proof of C19 cannot be closed without a stated bridge, so the paper needs an edit that adds one. Same issue as K2 in the co-author review.', 'open', NULL, '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F2', 'C12', NULL, 'minor', 'Two different derivations of the optimal local rule', 'The main-text proof (C12/p1) finds theta_i/(q+gamma) by a centered decomposition and pointwise minimization; the appendix (C12/p2), introduced as ''the matrix arithmetic'', re-derives it from the coupled normal equations. Under the 1:1 rule one derivation must be the proof Lean mirrors. C12/p1 is marked primary for now; p2 additionally needs C2 and C1.b (tier C). Decision needed: keep both (and formalize both) or reduce the appendix to the arithmetic.', 'open', 'Decision 2026-11-13 (left to Claude''s judgement): C12/p1 (main text) is the proof Lean mirrors. When C12 is formalized, a tracked edit reduces the appendix to the arithmetic for R_inf and R_loc and removes the normal-equation re-derivation, so C12 does not depend on C2 or C1.b. Finding stays open until that edit is applied.', '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F3', 'C9', NULL, 'medium', 'Unequal-rate formula has no proof and an informal hypothesis', 'The formula is asserted without proof, and ''the fraction of the no-information decision loss attributable to mode k'' is not defined (it needs the cross-mode terms of x*''Qx* to vanish, which independence of the modes provides once stated). A Lean statement needs a precise definition of w_k, and the 1:1 rule needs a written proof.', 'open', NULL, '2026-11-13T13:26:00');
INSERT INTO findings (id, claim_id, step_id, severity, title, body, status, resolution, created) VALUES ('F4', 'C10', 'C10/p1/s2', 'minor', 'Crossover proof does not mention the eta_S(0) = 1 clause', 'The theorem states that for eta_S(0) = 1 no finite delay gives a strict local advantage, but the theorem''s hypothesis is 0 <= eta_S(0) < 1 and the proof (''Rearranging gives the threshold and equality case'') covers only that range. The Lean statement has to either drop the clause or prove it as a separate step, which then needs a sentence in the paper.', 'open', NULL, '2026-11-13T13:26:00');

-- notes
INSERT INTO notes (id, ts, target, kind, body) VALUES (1, '2026-11-13T13:43:04', 'C12', 'decision', 'F2: main-text derivation C12/p1 is primary; appendix normal-equation derivation C12/p2 to be removed by a tracked edit when C12 is formalized.');
INSERT INTO notes (id, ts, target, kind, body) VALUES (2, '2026-11-13T13:55:41', 'C4.c', 'todo', 'Before attempting: bump Lean and Mathlib to v4.35.0 (about 1 GB download, see README ''Libraries''). atlas-lean MathlibExt/Probability/OrnsteinUhlenbeck.lean at commit 8e813e6 gives the stationary scalar OU process as a Gaussian process with covariance (sigma^2/2theta) exp(-theta|t-s|), with existence, stationarity, condExp_natural and condDistrib_eval; closure is 3 files (plus KolmogorovExtension, GaussianConditioning), which do not compile on Mathlib v4.33.1. Scalar only: the paper''s vector form with Sigma_S is not covered. Also relevant to C9.');
