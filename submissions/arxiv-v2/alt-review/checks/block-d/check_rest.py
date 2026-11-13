import numpy as np, sympy as sp
from scipy import optimize

# ---- (A) space-time composition in the discretized field: Var(x*(t) | O_r(t-tau)) ----
def delayed_ratio(lc, ls, r, tau, T, h=0.025, Lmult=12.0):
    L = r + Lmult*lc
    n = int(round(L/h)); u = np.arange(-n, n+1)*h
    wq = np.full(u.size, h); wq[0]=wq[-1]=h/2
    w = wq*np.exp(-np.abs(u)/lc)/(2*lc)
    S = np.exp(-np.abs(u[:,None]-u[None,:])/ls)
    a = np.exp(-tau/T)
    obs = np.abs(u) <= r+1e-12
    # target x*(t) = w.theta_t ; observe theta_{t-tau}[obs]; Cov(theta_t, theta_{t-tau}) = a S
    c = a*(S[np.ix_(obs, np.ones(u.size,bool))]@w)       # Cov(obs_old, x*_t)
    Soo = S[np.ix_(obs,obs)]
    red = c@np.linalg.solve(Soo+1e-12*np.eye(obs.sum()), c) if obs.sum()>1 else c@c/Soo[0,0]
    var = w@S@w
    return (var-red)/var
print("(A) delayed regret ratio: numeric vs 1 - a^2 (1 - eta0 e^{-2r/lc})")
for lc, ls, r, tau, T in [(1,1,0.5,0.3,1.0),(2,0.5,1.0,1.0,2.0),(0.7,2,0.0,0.4,0.9),(3,3,2,0.2,5)]:
    num = delayed_ratio(lc, ls, r, tau, T)
    f = 1-np.exp(-2*tau/T)*(1-lc/(lc+2*ls)*np.exp(-2*r/lc))
    print(f"  lc={lc} ls={ls} r={r} tau={tau} T={T}: {num:.6f} vs {f:.6f}")

# ---- (B) generic exponential optimum vs brute-force maximization ----
rng = np.random.default_rng(0)
maxerr = 0; n_int=0; n_zero=0
for _ in range(20000):
    eta0 = rng.uniform(0.001, 0.999); lc = 10**rng.uniform(-2,2); vT = 10**rng.uniform(-2,2)
    G = lambda r: (1-eta0*np.exp(-2*r/lc))*np.exp(-2*r/vT)
    rstar = lc/2*max(np.log(eta0*(1+vT/lc)),0)
    # brute force on fine grid + local refine
    hi = max(5*rstar, 5*min(lc,vT), 1e-3)
    grid = np.linspace(0, hi, 20001); k = np.argmax(G(grid))
    lo_, hi_ = grid[max(k-1,0)], grid[min(k+1,grid.size-1)]
    res = optimize.minimize_scalar(lambda r:-G(r), bounds=(lo_,hi_), method='bounded', options={'xatol':1e-12})
    rb = res.x if G(res.x) > G(grid[k]) else grid[k]
    if rstar>0: n_int+=1
    else: n_zero+=1
    maxerr = max(maxerr, abs(rb-rstar)/max(1e-9, max(rstar, min(lc,vT))))
    # capped
    D = rng.uniform(0, 2*max(rstar,0.1))
    g2 = np.linspace(0, D, 4001); kb = g2[np.argmax(G(g2))]
    assert abs(kb-min(D,rstar)) <= D/4000*1.01+1e-12, (kb, D, rstar)
print(f"(B) generic optimum: max relative error {maxerr:.2e}; interior {n_int}, boundary {n_zero}; capped optimum = min(D,r*) OK")

# ---- (C) symbolic ----
r, lc, ls, v, T, e0, s = sp.symbols('r l_c l_s v T eta_0 s', positive=True)
G = (1-e0*sp.exp(-2*r/lc))*sp.exp(-2*r/(v*T))
Gp_paper = 2*sp.exp(-2*r/(v*T))*(e0*(1/(v*T)+1/lc)*sp.exp(-2*r/lc)-1/(v*T))
print("(C) G' matches paper:", sp.simplify(sp.diff(G,r)-Gp_paper)==0)
rs_gen = lc/2*sp.log(e0*(1+v*T/lc))
print("    G'(r*)=0:", sp.simplify(sp.diff(G,r).subs(r, rs_gen))==0)
rs = lc/2*sp.log((lc+v*T)/(lc+2*ls))
print("    canonical r* = generic with eta0=lc/(lc+2ls):", sp.simplify(sp.expand_log(rs_gen.subs(e0, lc/(lc+2*ls))-rs, force=True))==0)
print("    d r*/d(vT):", sp.simplify(sp.diff(rs, T)/v - lc/(2*(lc+v*T)))==0, " d r*/d ls:", sp.simplify(sp.diff(rs, ls)+lc/(lc+2*ls))==0)
integ = sp.Rational(1,2)*sp.integrate(lc/(lc+s),(s,2*ls,v*T))
print("    integral repr:", sp.simplify(sp.expand_log(integ-rs, force=True))==0)
x = sp.symbols('x', positive=True)
print("    limit lc->oo:", sp.limit(rs, lc, sp.oo))
# covariance integrals
bc, bs, u, vv, sig = sp.symbols('beta_c beta_s u v_ sigma', positive=True)
cov = sp.integrate(bc/2*sp.exp(-bc*u)*sig**2*sp.exp(-bs*u),(u,0,sp.oo))*2
print("    Cov(x*,theta0):", sp.simplify(cov - sig**2*bc/(bc+bs))==0)
# I for generic bs != bc: do region integrals explicitly
def I_val(bcv, bsv):
    from scipy import integrate
    f = lambda y,x_: np.exp(-bcv*(abs(x_)+abs(y))-bsv*abs(x_-y))
    val,_ = integrate.dblquad(f, -60, 60, lambda x_:-60, lambda x_:60, epsabs=1e-10, epsrel=1e-10)
    return val
for bcv, bsv in [(1.0,1.0),(0.5,2.0),(2.0,0.3)]:
    print(f"    I numeric {I_val(bcv,bsv):.8f} vs formula {2*(2*bcv+bsv)/(bcv*(bcv+bsv)**2):.8f}")
# monotonicity in lc numerically, and d r*/d lc sign symbolic via integral
print("    d/dlc of integrand:", sp.simplify(sp.diff(lc/(lc+s), lc)))
