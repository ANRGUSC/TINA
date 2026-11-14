import numpy as np
from scipy import integrate, optimize

def eta_numeric(lc, ls, r, h=0.02, Lmult=14.0, sigma2=1.7):
    L = r + Lmult*lc
    n = int(round(L/h))
    u = np.arange(-n, n+1)*h
    wq = np.full(u.size, h); wq[0] = wq[-1] = h/2   # trapezoid
    w = wq*np.exp(-np.abs(u)/lc)/(2*lc)
    S = sigma2*np.exp(-np.abs(u[:,None]-u[None,:])/ls)
    obs = np.abs(u) <= r + 1e-12
    un = ~obs
    var = w@S@w
    Soo = S[np.ix_(obs,obs)]; Suo = S[np.ix_(un,obs)]; Suu = S[np.ix_(un,un)]
    # x* = w_o.theta_o + w_u.theta_u ; cond var = w_u (Suu - Suo Soo^-1 Sou) w_u
    b = Suo.T@w[un]
    if obs.sum()==1:
        red = b@b/Soo[0,0]
    else:
        red = b@np.linalg.solve(Soo + 1e-12*np.eye(obs.sum()), b)
    cv = w[un]@Suu@w[un] - red
    return cv/var, var

print("lc ls r | eta_numeric  eta_formula | var_numeric var_formula")
for lc, ls in [(1.0,1.0),(0.7,2.0),(2.0,0.5),(3.0,3.0),(1.0,0.2),(0.5,4.0)]:
    for r in [0.0, 0.3, 1.0, 2.5]:
        en, vn = eta_numeric(lc, ls, r)
        ef = lc/(lc+2*ls)*np.exp(-2*r/lc)
        bc, bs = 1/lc, 1/ls
        vf = 1.7*bc*(2*bc+bs)/(2*(bc+bs)**2)
        print(f"{lc:4} {ls:4} {r:4} | {en:.6f} {ef:.6f} | {vn:.6f} {vf:.6f}")
