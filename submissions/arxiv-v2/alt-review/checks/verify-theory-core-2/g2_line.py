import numpy as np
# Discretized 1-D line check of eta_S(r) under variations of covariance and kernel.
h=0.02; Lmax=14.0
z=np.arange(-Lmax,Lmax+h/2,h); n=len(z)
D=np.abs(z[:,None]-z[None,:])
def eta(cov,w,rs):
    S=cov(D); wv=w(z)*h
    var=wv@S@wv
    out=[]
    for r in rs:
        o=np.abs(z)<=r+1e-9
        c=S[o]@wv
        Soo=S[np.ix_(o,o)]+1e-9*np.eye(o.sum())
        out.append((var-c@np.linalg.solve(Soo,c))/var)
    return np.array(out)
ls=1.0; lc=1.5
rs=np.array([0,0.5,1.0,1.5,2.0,3.0])
expcov=lambda d: np.exp(-d/ls)
mat32=lambda d: (1+np.sqrt(3)*d/ls)*np.exp(-np.sqrt(3)*d/ls)
sqexp=lambda d: np.exp(-d**2/(2*ls**2))
expk=lambda u: np.exp(-np.abs(u)/lc)/(2*lc)
gauk=lambda u: np.exp(-u**2/(2*lc**2))/np.sqrt(2*np.pi*lc**2)
boxk=lambda u: (np.abs(u)<=2*lc)/(4*lc)
def report(name,cov,w):
    e=eta(cov,w,rs)
    print(name)
    print("  r        ",rs)
    print("  eta_S(r) ",np.round(e,5))
    print("  eta_S(r)/eta_S(0) ",np.round(e/e[0],5))
    print("  exp(-2r/lc)       ",np.round(np.exp(-2*rs/lc),5))
    with np.errstate(divide='ignore',invalid='ignore'):
        print("  implied decay length -2r/log(ratio):",np.round(-2*rs[1:]/np.log(e[1:]/e[0]),4), " (paper: lc=%.2f)"%lc)
print("closed form eta_0 = lc/(lc+2ls) =",lc/(lc+2*ls))
report("A. exponential cov + exponential kernel (paper's setting)",expcov,expk)
report("B. Matern-3/2 cov + exponential kernel",mat32,expk)
report("C. exponential cov + Gaussian kernel",expcov,gauk)
report("D. exponential cov + box kernel (half-width 2 lc)",expcov,boxk)
