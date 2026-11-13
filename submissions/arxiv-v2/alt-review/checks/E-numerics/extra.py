import numpy as np, csv
from indep import ring, bfs_dist, cov, Kop, eta_curve, regret
# (1) Fig 5 vs Fig 6 at ell_c=0.7 on the 64-ring: which parameter flips r* between 1 and 0?
A = ring(64); D = bfs_dist(A)
for T in (5.0, 6.0):
    for kap in (0.75, 0.8):
        e = eta_curve(cov(A, kap, 1.5), Kop(D, 0.7), D); R = regret(e, 0.12, T)
        print(f"ring lc=0.7 T={T} kappa={kap}: r*={int(np.argmin(R))}  R0={R[0]:.5f} R1={R[1]:.5f}")
# (2) Exp 2: exact threshold from direct matrix algebra, team-optimal diagonal linear gain solved numerically,
#     and an independent MC with a different seed.
rng = np.random.default_rng(12345)
worst = 0; cover = 0; tot = 0
for n in (5, 10, 25, 100):
    for g in (0, .05, .1, .2, .5, 1, 2, 5, 10):
        Q = np.eye(n) + g * np.ones((n, n)); K = np.linalg.inv(Q)
        # optimal diagonal gains c: minimise 1/2 tr((C-K)^T Q (C-K)) over diagonal C, Sigma = I
        # normal equations: diag(Q C) = diag(Q K) = 1  ->  (Q o I) c = 1
        c = 1.0 / np.diag(Q)
        assert np.allclose(c, 1 / (1 + g))
        # check stationarity against arbitrary (non-diagonal-preserving) perturbation within the admissible class
        Rloc = 0.5 * np.trace((np.diag(c) - K).T @ Q @ (np.diag(c) - K)); Rinf = 0.5 * np.trace(K.T @ Q @ K)
        for _ in range(5):
            cp = c + 1e-3 * rng.standard_normal(n)
            assert 0.5 * np.trace((np.diag(cp) - K).T @ Q @ (np.diag(cp) - K)) >= Rloc
        rho = 0.5 * np.log(Rinf / (Rinf - Rloc))
        closed = 0.5 * np.log((1 + g) * (1 + g * (n - 1)) / (1 + g * n))
        worst = max(worst, abs(rho - closed))
        if g > 0:
            th = rng.standard_normal((30000, n)); xs = th @ K.T; el = xs - th / (1 + g)
            o = 0.5 * np.einsum('bi,ij,bj->b', xs, Q, xs); l = 0.5 * np.einsum('bi,ij,bj->b', el, Q, el)
            om, lm = o.mean(), l.mean(); est = 0.5 * np.log(om / (om - lm))
            gr = np.array([-lm / (2 * om * (om - lm)), 1 / (2 * (om - lm))]); C = np.cov(np.c_[o, l].T)
            se = np.sqrt(gr @ C @ gr / len(o)); tot += 1; cover += abs(est - closed) <= 1.96 * se
print("exp2: max |matrix rho* - closed form| =", worst, "; my MC CI coverage", cover, "/", tot)
print("large-n limit check n=1e7, g=10:", 0.5*np.log((11)*(1+10*(1e7-1))/(1+10*1e7)), 0.5*np.log(11))
# (3) archived exp02 coverage, positive coupling only
rows = list(csv.DictReader(open('/Users/scottmoeller/Documents/github/TINA/numerics/results/processed/exp02_local_global_crossover.csv')))
pos = [r for r in rows if float(r['gamma_over_q']) > 0]
print("archived: positive-coupling CIs containing exact:", sum(float(r['threshold_ci_low']) <= float(r['threshold_theory']) <= float(r['threshold_ci_high']) for r in pos), "/", len(pos),
      " max abs err", max(float(r['boundary_abs_error']) for r in rows))
rows = list(csv.DictReader(open('/Users/scottmoeller/Documents/github/TINA/numerics/results/processed/exp05_mc_checks.csv')))
for r in rows: print({k: (round(float(r[k]), 5)) for k in ('ell_c', 'radius', 'eta_theory', 'eta_mc', 'eta_mc_se')})
