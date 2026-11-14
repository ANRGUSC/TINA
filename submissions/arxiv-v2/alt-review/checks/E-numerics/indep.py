"""Independent recomputation (numpy only; no repo imports, no networkx)."""
import numpy as np
from collections import deque

def bfs_dist(adj):
    n = len(adj); D = np.full((n, n), np.inf)
    for s in range(n):
        D[s, s] = 0; dq = deque([s])
        while dq:
            u = dq.popleft()
            for v in np.flatnonzero(adj[u]):
                if D[s, v] == np.inf:
                    D[s, v] = D[s, u] + 1; dq.append(v)
    return D

def path(n):
    A = np.zeros((n, n), int)
    for i in range(n - 1): A[i, i+1] = A[i+1, i] = 1
    return A
def ring(n):
    A = path(n); A[0, n-1] = A[n-1, 0] = 1; return A
def grid(s):
    A = np.zeros((s*s, s*s), int)
    for i in range(s):
        for j in range(s):
            u = i*s + j
            if i+1 < s: A[u, u+s] = A[u+s, u] = 1
            if j+1 < s: A[u, u+1] = A[u+1, u] = 1
    return A
def geometric(n, seed, radius=0.22):
    rng = np.random.default_rng(seed)
    pos = np.array([rng.random(2) for _ in range(n)])
    E = np.linalg.norm(pos[:, None] - pos[None], axis=2)
    while True:
        A = ((E <= radius) & (E > 0)).astype(int)
        if np.all(np.isfinite(bfs_dist(A))): return A, radius
        radius += 0.02

def cov(A, kappa, nu):
    L = np.diag(A.sum(1)) - A
    w, V = np.linalg.eigh(kappa**2 * np.eye(len(A)) + L)
    S = (V * w**(-nu)) @ V.T
    S /= np.mean(np.diag(S))
    return (S + S.T) / 2

def Kop(D, lc):
    K = np.exp(-D / lc)
    return K / np.linalg.norm(K, axis=1, keepdims=True)

def eta_curve(S, K, D):
    """Residual-operator form: E|| K theta - P theta ||^2 / tr(K S K^T)."""
    tot = np.trace(K @ S @ K.T); out = []
    for r in range(int(D.max()) + 1):
        Rm = K.copy()
        for i in range(len(S)):
            o = np.flatnonzero(D[i] <= r)
            # least-squares weights via Cholesky of observed block
            c = S[o] @ K[i]
            Lc = np.linalg.cholesky(S[np.ix_(o, o)])
            w = np.linalg.solve(Lc.T, np.linalg.solve(Lc, c))
            Rm[i, o] -= w
        out.append(np.trace(Rm @ S @ Rm.T) / tot)
    return np.array(out)

def regret(eta, lat, T):
    r = np.arange(len(eta))
    return 1 - np.exp(-2 * lat * r / T) * (1 - eta)

def direct_delayed_regret(S, K, D, r, lat, T):
    """Brute force: optimal linear rule on the joint (past,current) Gaussian, no composition law."""
    n = len(S); a = np.exp(-lat * r / T)
    J = np.block([[S, a * S], [a * S, S]])   # (past, current)
    tot = np.trace(K @ S @ K.T); err = 0.0
    for i in range(n):
        o = np.flatnonzero(D[i] <= r)           # indices in past block
        tgt = np.concatenate([np.zeros(n), K[i]])  # x*_i = K_i theta_current
        c = J[o] @ tgt
        w = np.linalg.solve(J[np.ix_(o, o)], c)
        e = tgt.copy(); e[o] -= w
        err += e @ J @ e
    return err / tot

if __name__ == "__main__":
    np.set_printoptions(precision=6, suppress=True, linewidth=200)
    print("=== Fig radius-regret (C22) ===")
    for name, eta0, vT in [("local", .25, .2), ("interior", .7, 4.), ("broad", .9, 100.)]:
        lc, Dcap = 1.0, 2.0
        rs = max(0.0, 0.5 * lc * np.log(eta0 * (1 + vT / lc)))
        rr = np.linspace(0, Dcap, 2_000_001)
        tot = 1 - np.exp(-2 * rr / vT) * (1 - eta0 * np.exp(-2 * rr / lc))
        print(name, "closed uncapped", rs, "capped", min(Dcap, rs), "fine-grid argmin", rr[np.argmin(tot)],
              "eta_S(D)", eta0 * np.exp(-2 * Dcap / lc),
              "implied ell_s", lc * (1 / eta0 - 1) / 2, "vT>2ls?", vT > lc * (1 / eta0 - 1))

    print("\n=== Fig decision-relevance (C23): ring 64, T=6, lat .12, kappa .75, nu 1.5 ===")
    A = ring(64); D = bfs_dist(A); S = cov(A, 0.75, 1.5)
    print("diameter", int(D.max()), "mean diag", np.mean(np.diag(S)), "min eig", np.linalg.eigvalsh(S).min())
    for lc in (0.7, 2.0, 6.0):
        K = Kop(D, lc); e = eta_curve(S, K, D); R = regret(e, 0.12, 6.0)
        rs = int(np.argmin(R))
        srt = np.sort(R)
        print(f"lc={lc}: r*={rs}  R[0..7]={R[:8]}  eta[0..7]={e[:8]} gap to runner-up={srt[1]-srt[0]:.5f}")
        print("   brute-force joint-Gaussian delayed regret at r*:", direct_delayed_regret(S, K, D, rs, 0.12, 6.0), "vs law", R[rs])
        # local minima of the integer curve
        lm = [r for r in range(len(R)) if (r == 0 or R[r] < R[r-1]) and (r == len(R)-1 or R[r] < R[r+1])]
        print("   strict local minima of R(r):", lm, " eta monotone:", bool(np.all(np.diff(e) <= 1e-12)))

    print("\n=== Fig general graphs (C24): kappa .8, nu 1.5, T=5, lc=2, lat .12 ===")
    G, rad = geometric(64, 20260839)
    graphs = {"path": path(64), "ring": ring(64), "grid": grid(8), "geometric": G}
    print("geometric connection radius used:", rad, "edges:", G.sum() // 2)
    Ts = [1.5, 2.5, 4, 6, 9, 14]; lcs = [0.7, 1.2, 2, 3.5, 6]; lats = [.05, .08, .12, .18, .28]; kaps = [1.5, 1, .7, .45, .3]
    for name, A in graphs.items():
        D = bfs_dist(A); S = cov(A, 0.8, 1.5); K = Kop(D, 2.0)
        e = eta_curve(S, K, D); R = regret(e, 0.12, 5.0); rs = int(np.argmin(R))
        diam = int(D.max())
        lm = [r for r in range(len(R)) if (r == 0 or R[r] < R[r-1]) and (r == len(R)-1 or R[r] < R[r+1])]
        print(f"{name}: diameter={diam} r*={rs} R(r*)={R[rs]:.6f} eta0={e[0]:.6f} eta(diam)={e[-1]:.2e} local minima={lm}")
        print("   brute-force delayed regret at r*:", direct_delayed_regret(S, K, D, rs, 0.12, 5.0))
        rT = [int(np.argmin(regret(e, 0.12, T))) for T in Ts]
        rl = []; lmins = []
        for lc in lcs:
            el = eta_curve(S, Kop(D, lc), D); Rl = regret(el, 0.12, 5.0); rl.append(int(np.argmin(Rl)))
            lmins.append([r for r in range(len(Rl)) if (r == 0 or Rl[r] < Rl[r-1]) and (r == len(Rl)-1 or Rl[r] < Rl[r+1])])
        rlat = [int(np.argmin(regret(e, la, 5.0))) for la in lats]
        rk = [int(np.argmin(regret(eta_curve(cov(A, k, 1.5), K, D), 0.12, 5.0))) for k in kaps]
        print("   r* by T    ", rT, "weakly inc:", all(np.diff(rT) >= 0))
        print("   r* by ell_c", rl, "weakly inc:", all(np.diff(rl) >= 0), " max<diam:", max(rl) < diam, " local-min sets:", lmins)
        print("   r* by lat  ", rlat, " r* by kappa", rk)
        print("   any displayed setting selects full graph:", any(x == diam for x in rT + rl))
