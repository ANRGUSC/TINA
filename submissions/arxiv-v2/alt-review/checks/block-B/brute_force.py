"""Brute-force check of the composition law on finite-state, non-Gaussian chains.

State theta in {-1,0,1}^n (n agents on a path graph, scalar local states), plus
optional vector actions. Transition kernel P engineered so that
E[theta' | theta] = a * theta exactly, with innovation law depending on theta.
Team optimum over ALL (nonlinear) rules = weighted least squares over indicator
bases of each agent's observed pattern.
"""
import itertools
import numpy as np
from scipy.optimize import linprog

rng = np.random.default_rng(20261112)


def make_states(n, vals=(-1.0, 0.0, 1.0)):
    return np.array(list(itertools.product(vals, repeat=n)))


def cond_mean_kernel(S, a, n_mix=4, floor=0.0):
    """Row-stochastic P with sum_j P_ij S_j = a S_i; rows are mixtures of LP
    vertices under random costs (state dependent innovations)."""
    m, n = S.shape
    P = np.zeros((m, m))
    A_eq = np.vstack([S.T, np.ones(m)])
    for i in range(m):
        b_eq = np.concatenate([a * S[i], [1.0]])
        row = np.zeros(m)
        wts = rng.dirichlet(np.ones(n_mix))
        for k in range(n_mix):
            c = rng.normal(size=m) + 0.5 * rng.normal() * (S @ S[i])  # state dependent
            res = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=[(floor, 1)] * m, method="highs")
            assert res.status == 0, res.message
            row += wts[k] * res.x
        P[i] = np.clip(row, 0, None)
        P[i] /= P[i].sum()
    return P


def stationary(P):
    w, V = np.linalg.eig(P.T)
    k = np.argmin(abs(w - 1))
    pi = np.real(V[:, k])
    pi = pi / pi.sum()
    assert np.all(pi > -1e-12)
    pi = np.clip(pi, 0, None)
    return pi / pi.sum()


def neighborhoods(n, r):
    return [[j for j in range(n) if abs(i - j) <= r] for i in range(n)]


def team_opt(obs_states, target, weights, nbrs, Q, dims):
    """min over u_i = g_i(obs_states[:, nbrs[i]]) of sum_w (u - target)^T Q (u - target).
    obs_states: (N, n) observed state per sample; target: (N, d); weights: (N,).
    dims: action dimension per agent. Returns the minimum value."""
    N = obs_states.shape[0]
    d = sum(dims)
    keep = weights > 0
    obs_states, target, weights = obs_states[keep], target[keep], weights[keep]
    N = obs_states.shape[0]
    L = np.linalg.cholesky(Q).T  # Q = L^T L
    cols = []
    off = 0
    blocks = []
    for i, nb in enumerate(nbrs):
        pats, inv = np.unique(obs_states[:, nb], axis=0, return_inverse=True)
        inv = inv.ravel()
        blocks.append((off, dims[i], inv, len(pats)))
        off += dims[i]
    ncol = sum(b[1] * b[3] for b in blocks)
    # design: u (N x d) = sum over columns; build dense (N*d) x ncol in L-coordinates
    X = np.zeros((N, d, ncol))
    c = 0
    for (o, di, inv, npat) in blocks:
        for comp in range(di):
            for p in range(npat):
                X[inv == p, o + comp, c] = 1.0
                c += 1
    sw = np.sqrt(weights)[:, None, None]
    Xl = np.einsum("ab,nbc->nac", L, X) * sw
    yl = (target @ L.T) * np.sqrt(weights)[:, None]
    Xl = Xl.reshape(N * d, ncol)
    yl = yl.reshape(N * d)
    beta, *_ = np.linalg.lstsq(Xl, yl, rcond=None)
    resid = yl - Xl @ beta
    return float(resid @ resid)


def random_Q(d):
    M = rng.normal(size=(d, d))
    return M @ M.T + 0.3 * np.eye(d)


def run_case(n, a, dims, label):
    S = make_states(n)
    m = len(S)
    P = cond_mean_kernel(S, a)
    assert np.allclose(P @ S, a * S, atol=1e-9)
    pi = stationary(P)
    assert np.allclose(pi @ S, 0, atol=1e-9)
    # innovation depends on old state? check conditional variance spread
    cv = (P @ (S ** 2)) - (P @ S) ** 2
    d = sum(dims)
    K = rng.normal(size=(d, n))
    Q = random_Q(d)
    Sigma = (S * pi[:, None]).T @ S
    Rinf = 0.5 * np.trace(K.T @ Q @ K @ Sigma)
    # joint (old,new)
    I, J = np.meshgrid(np.arange(m), np.arange(m), indexing="ij")
    I, J = I.ravel(), J.ravel()
    wj = (pi[:, None] * P).ravel()
    print(f"--- {label}: n={n}, a={a}, dims={dims}, support of pi={np.sum(pi>1e-12)}/{m}, "
          f"cond-var range per coord: [{cv.min():.3f},{cv.max():.3f}], offdiag Q max={np.abs(Q-np.diag(np.diag(Q))).max():.2f}")
    worst = 0
    for r in range(n):
        nb = neighborhoods(n, r)
        Rfresh = 0.5 * team_opt(S, S @ K.T, pi, nb, Q, dims)
        Rdel = 0.5 * team_opt(S[I], S[J] @ K.T, wj, nb, Q, dims)
        pred = (1 - a * a) * Rinf + a * a * Rfresh
        worst = max(worst, abs(Rdel - pred))
        print(f"   r={r}: R_fresh={Rfresh:.8f} eta={Rfresh/Rinf:.5f}  R_delayed(brute)={Rdel:.8f}  "
              f"law={pred:.8f}  diff={Rdel-pred:+.2e}")
    return worst, (S, P, pi, K, Q, Rinf)


if __name__ == "__main__":
    w = []
    w.append(run_case(3, 0.6, [1, 1, 1], "scalar actions")[0])
    w.append(run_case(3, 0.85, [2, 1, 2], "vector actions")[0])
    w.append(run_case(4, 0.4, [1, 1, 1, 1], "four agents")[0])
    w.append(run_case(4, 0.95, [1, 2, 1, 1], "four agents, slow decay")[0])
    print("max abs discrepancy across cases:", max(w))
