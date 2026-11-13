import numpy as np
from scipy import integrate, stats, optimize

# Part 1: discretised jointly Gaussian space-time field, two time slices.
def delayed_ratio(lc, ls, r, rho, h=0.01, L=14.0):
    z = np.arange(-L, L + h/2, h)
    S = np.exp(-np.abs(z[:, None] - z[None, :]) / ls)
    w = np.exp(-np.abs(z) / lc) / (2 * lc) * h
    a = np.exp(-rho)
    var = w @ S @ w
    obs = np.abs(z) <= r + 1e-12
    c = a * (S[obs] @ w)             # Cov(x*_t, theta_old(obs))
    resid = var - c @ np.linalg.solve(S[np.ix_(obs, obs)], c)
    return resid / var

for lc, ls, r, rho in [(1, 1, 0.5, 0.3), (1, 1, 0.0, 0.3), (2, 0.5, 1.0, 0.1), (0.7, 1.5, 0.3, 0.8), (3, 1, 2.0, 0.0)]:
    eta0 = lc / (lc + 2 * ls)
    pred = 1 - np.exp(-2 * rho) * (1 - eta0 * np.exp(-2 * r / lc))
    print(f"lc={lc} ls={ls} r={r} rho={rho}: numeric={delayed_ratio(lc, ls, r, rho):.6f} formula={pred:.6f}")

# Part 2: spatially Gaussian slices + separable lag covariance, but the
# conditional-mean property fails. theta_t = s * theta_old, P(s=+1 | theta_old) = (1+a)/2 + delta*hf(|theta_old(0)|),
# hf a step function orthogonal to 1 and x^2 under N(0,1).
phi = stats.norm.pdf
c1, c2 = 0.6, 1.4
def m(lo, hi, k):
    return 2 * integrate.quad(lambda x: x**k * phi(x), lo, hi)[0]
A = np.array([[m(0, c1, 0), m(c1, c2, 0), m(c2, np.inf, 0)],
              [m(0, c1, 2), m(c1, c2, 2), m(c2, np.inf, 2)]])
_, _, vt = np.linalg.svd(A)
hv = vt[-1] / np.abs(vt[-1]).max()
print("step values of h:", hv, "E[h]=%.2e E[h x^2]=%.2e" % (A[0] @ hv, A[1] @ hv))
a = 0.5
delta = 0.5 * (1 - a) / 2 * 0.999 * 2  # keep p in [0,1]: |delta*h| <= (1-a)/2
delta = (1 - a) / 2
Eh2x2 = sum(hv[i]**2 * A[1, i] for i in range(3))
lc = ls = 1.0
eta0 = lc / (lc + 2 * ls)
law = 1 - a**2 * (1 - eta0)
actual = 1 - (a**2 + 4 * delta**2 * Eh2x2) * (1 - eta0)
print(f"r=0, a={a}: composition-law ratio={law:.4f}; true optimal ratio in non-Gaussian-in-time field={actual:.4f}")
