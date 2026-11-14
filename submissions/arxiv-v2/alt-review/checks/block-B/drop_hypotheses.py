import itertools
import numpy as np
from scipy.linalg import null_space
import brute_force as bf
from brute_force import make_states, cond_mean_kernel, stationary, neighborhoods, team_opt, random_Q

rng = bf.rng
n, a = 3, 0.7
dims = [1, 1, 1]
S = make_states(n)
m = len(S)
P = cond_mean_kernel(S, a, floor=0.004)
pi = stationary(P)
K = rng.normal(size=(3, n))
Q = random_Q(3)
I, J = [x.ravel() for x in np.meshgrid(np.arange(m), np.arange(m), indexing="ij")]


def regrets(P, mu, target_fn, label, a=a):
    """mu = law at snapshot epoch; current-time law = mu P."""
    mu_now = mu @ P
    wj = (mu[:, None] * P).ravel()
    X = target_fn(S)
    Rinf_now = 0.5 * np.einsum("n,na,ab,nb->", mu_now, X, Q, X)
    Rinf_old = 0.5 * np.einsum("n,na,ab,nb->", mu, X, Q, X)
    print(f"=== {label}")
    for r in range(n):
        nb = neighborhoods(n, r)
        Rfresh_now = 0.5 * team_opt(S, X, mu_now, nb, Q, dims)
        Rfresh_old = 0.5 * team_opt(S, X, mu, nb, Q, dims)
        Rdel = 0.5 * team_opt(S[I], X[J], wj, nb, Q, dims)
        law = (1 - a * a) * Rinf_now + a * a * Rfresh_now
        red_lhs = Rinf_now - Rdel
        red_rhs = a * a * (Rinf_old - Rfresh_old)
        print(f"   r={r}: brute={Rdel:.6f} stated-law={law:.6f} diff={Rdel-law:+.3e} | "
              f"time-indexed reduction form diff={red_lhs-red_rhs:+.3e}")


lin = lambda S_: S_ @ K.T

# A. nonlinearity matters in the baseline: best LINEAR rule vs unrestricted (fresh, r=0,1)
Sigma = (S * pi[:, None]).T @ S
print("baseline pi skewness per coord:", (pi @ S**3))
for r in range(n):
    nb = neighborhoods(n, r)
    Rfull = 0.5 * team_opt(S, lin(S), pi, nb, Q, dims)
    # linear rules u_i = c_i^T Z_i: least squares with linear basis
    cols = []
    L = np.linalg.cholesky(Q).T
    for i, nbi in enumerate(nb):
        for j in nbi:
            U = np.zeros((m, 3)); U[:, i] = S[:, j]; cols.append(U)
    X = np.stack(cols, axis=2)
    Xl = (np.einsum("ab,nbc->nac", L, X) * np.sqrt(pi)[:, None, None]).reshape(m * 3, -1)
    yl = ((lin(S) @ L.T) * np.sqrt(pi)[:, None]).reshape(-1)
    beta, *_ = np.linalg.lstsq(Xl, yl, rcond=None)
    Rlin = 0.5 * np.sum((yl - Xl @ beta) ** 2)
    print(f"   fresh r={r}: unrestricted={Rfull:.6f}  best-linear={Rlin:.6f}  (gap {Rlin-Rfull:.3e})")

regrets(P, pi, lin, "0. baseline (all hypotheses hold)")

# B. non-stationary snapshot law
mu = rng.dirichlet(np.ones(m) * 0.3)
regrets(P, mu, lin, "B. cond-mean rule holds, NOT stationary (mu != pi)")

# C. innovation only uncorrelated with old state (linear prediction coefficient a, cond mean nonlinear)
rows = []
for i in range(m):  # Delta 1 = 0
    E = np.zeros((m, m)); E[i, :] = 1; rows.append(E.ravel())
for j in range(m):  # pi^T Delta = 0
    E = np.zeros((m, m)); E[:, j] = pi; rows.append(E.ravel())
for p in range(n):
    for q in range(n):  # S^T diag(pi) Delta S = 0
        E = np.outer(pi * S[:, p], S[:, q]); rows.append(E.ravel())
N = null_space(np.array(rows))
D = (N @ rng.normal(size=N.shape[1])).reshape(m, m)
scale = 0.9 * P.min() / np.abs(D).max()
P1 = P + scale * D
assert P1.min() > 0 and np.allclose(P1.sum(1), 1) and np.allclose(pi @ P1, pi)
C1 = (S * pi[:, None]).T @ (P1 @ S)  # E[theta theta'^T]
print("C: cross-cov equals a*Sigma:", np.allclose(C1, a * Sigma), "| max |E[eps|theta]| =", np.abs(P1 @ S - a * S).max())
regrets(P1, pi, lin, "C. stationary, covariance decay a*Sigma, but E[eps|theta_old] != 0")

# D. non-affine target
nonaff = lambda S_: S_ @ K.T + 0.8 * (S_ ** 2 - pi @ S ** 2) @ rng.normal(size=(n, 3))
M = rng.normal(size=(n, 3))
nonaff = lambda S_: S_ @ K.T + 0.8 * (S_ ** 2 - pi @ S ** 2) @ M
regrets(P, pi, nonaff, "D. non-affine (centered) target")

# E. unequal rates, independent non-Gaussian modes, invertible mixing
def coord_kernel(ak, p0):
    # states -1,0,1 ; E[x'|x] = ak x ; from +-1 stay prob s, to 0 prob q, flip prob f: s - f = ak
    f = 0.03; s = ak + f; q = max(1 - s - f, 0.0)
    assert 1 - s - f > -1e-12
    return np.array([[s, q, f], [p0, 1 - 2 * p0, p0], [f, q, s]])

aks = [0.9, 0.5, 0.2]
ks = [coord_kernel(aks[0], 0.1), coord_kernel(aks[1], 0.3), coord_kernel(aks[2], 0.25)]
Pm = np.einsum("ab,cd,ef->acebdf", *ks).reshape(27, 27)
pim = stationary(Pm)
Mm = make_states(3)                      # mode values
V = rng.normal(size=(3, 3))              # theta = V m (invertible => snapshot reveals modes)
Th = Mm @ V.T
Xs = Th @ K.T
Dm = np.diag(pim @ Mm ** 2)
print("E: modes uncorrelated:", np.allclose((Mm * pim[:, None]).T @ Mm, Dm))
KV = K @ V
wk = np.array([0.5 * KV[:, k] @ Q @ KV[:, k] * Dm[k, k] for k in range(3)])
Rinf = 0.5 * np.einsum("n,na,ab,nb->", pim, Xs, Q, Xs)
print("   sum of mode shares / Rinf =", wk.sum() / Rinf)
wj = (pim[:, None] * Pm).ravel()
full = [[0, 1, 2]] * 3
Rglob = 0.5 * team_opt(Th[I], Xs[J], wj, full, Q, dims)
print(f"   global: 1-Rglob/Rinf={1-Rglob/Rinf:.8f}  sum w_k a_k^2={(wk/Rinf) @ np.square(aks):.8f}")
# partial neighborhoods (theta coordinates) -- no factorization expected
for r in range(2):
    nb = neighborhoods(3, r)
    Rf = 0.5 * team_opt(Th, Xs, pim, nb, Q, dims)
    Rd = 0.5 * team_opt(Th[I], Xs[J], wj, nb, Q, dims)
    naive = ((wk / Rinf) @ np.square(aks)) * (1 - Rf / Rinf)
    print(f"   r={r}: 1-R_del/Rinf={1-Rd/Rinf:.6f}  naive [sum w a^2](1-eta)={naive:.6f}")

# E2. snapshot does NOT reveal the modes: scalar state = m1 + m2 (two rates)
Pm2 = np.einsum("ab,cd->acbd", ks[0], ks[2]).reshape(9, 9)
pi2 = stationary(Pm2)
M2 = make_states(2)
th = M2.sum(1)
v = pi2 @ M2 ** 2
w2 = v / v.sum()
I2, J2 = [x.ravel() for x in np.meshgrid(np.arange(9), np.arange(9), indexing="ij")]
wj2 = (pi2[:, None] * Pm2).ravel()
# best predictor of th_new from th_old (scalar)
num = 0.0
for val in np.unique(th):
    idx = th[I2] == val
    pm = wj2[idx].sum()
    cm = (wj2[idx] @ th[J2][idx]) / pm
    num += pm * cm ** 2
Rinf2 = 0.5 * pi2 @ th ** 2
Rg2 = Rinf2 - 0.5 * num
print(f"E2 (sum of two modes observed only): 1-Rglob/Rinf={1-Rg2/Rinf2:.6f}  sum w_k a_k^2={w2 @ np.square([aks[0], aks[2]]):.6f}")
