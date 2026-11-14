import numpy as np
from fractions import Fraction
n=64; kappa=0.75; nu=1.5; T=6.0; lat=0.12
idx=np.arange(n)
dist=np.abs(idx[:,None]-idx[None,:]); dist=np.minimum(dist,n-dist)
A=(dist==1).astype(float); L=np.diag(A.sum(1))-A
w,V=np.linalg.eigh(kappa**2*np.eye(n)+L)
S=(V*w**(-nu))@V.T; S/=np.mean(np.diag(S))
def Kop(ell):
    K=np.exp(-dist/ell); return K/np.linalg.norm(K,axis=1,keepdims=True)
def resid(K, r, ages):  # ages: function i,obs -> age per observed node
    tot=0.0
    for i in range(n):
        obs=np.flatnonzero(dist[i]<=r)
        s=ages(i,obs)
        C=S[np.ix_(obs,obs)]*np.exp(-np.abs(s[:,None]-s[None,:])/T)
        c=(K[i]@S[:,obs])*np.exp(-s/T)
        tot+=K[i]@S@K[i]-c@np.linalg.solve(C,c)
    return tot/np.trace(K@S@K.T)
for ell in (0.7,2,6):
    K=Kop(ell)
    sync=np.array([resid(K,r,lambda i,o,r=r: np.full(len(o),lat*r)) for r in range(33)])
    fresh=np.array([resid(K,r,lambda i,o: np.zeros(len(o))) for r in range(33)])
    law=1-np.exp(-2*lat*np.arange(33)/T)*(1-fresh)
    cone=np.array([resid(K,r,lambda i,o: lat*dist[i,o].astype(float)) for r in range(33)])
    rs=int(np.argmin(sync))
    print(f"ell={ell}: sync argmin r={rs} regret={sync[rs]:.4f}; max|sync-law|={np.abs(sync-law).max():.2e}; "
          f"cone full={cone[-1]:.4f}; cone nonincreasing={bool(np.all(np.diff(cone)<=1e-12))}; ratio={sync[rs]/cone[-1]:.2f}")
    # unimodality of sync curve
    d=np.sign(np.diff(sync)); print("   sync unimodal:", bool(np.all(np.diff((d>0).astype(int))>=0)))

# direct simulation of a delayed system (ell=2, r=2): exact OU pair, apply delayed radius-r conditional-mean rule
rng=np.random.default_rng(1); ell=2; r=2; K=Kop(ell); a=np.exp(-lat*r/T); N=200000
Lc=np.linalg.cholesky(S)
old=rng.standard_normal((N,n))@Lc.T; new=a*old+np.sqrt(1-a*a)*(rng.standard_normal((N,n))@Lc.T)
x=new@K.T; loss=np.zeros(N)
for i in range(n):
    obs=np.flatnonzero(dist[i]<=r)
    beta=np.linalg.solve(S[np.ix_(obs,obs)], S[obs,:]@K[i])*a
    loss+=(x[:,i]-old[:,obs]@beta)**2
tv=np.trace(K@S@K.T); m=loss.mean()/tv; se=loss.std(ddof=1)/np.sqrt(N)/tv
fresh2=resid(K,r,lambda i,o: np.zeros(len(o)))
print(f"simulated delayed regret (ell=2,r=2): {m:.4f} +/- {1.96*se:.4f}; law: {1-a*a*(1-fresh2):.4f}")

# MR (6.6) vs brute-force team optimum on equal partitions, exact rationals
def mr_beta(g,nn,q): return (1+(g-2)*q)/(1+(g-1)*q)*(1+(nn-1)*q)/(1+(nn-2)*q)
import sympy as sp
for nn,qm,gam in ((6,sp.Rational(1),sp.Rational(7,10)),(8,sp.Rational(2),sp.Rational(3,2))):
    Q=qm*sp.eye(nn)+gam*sp.ones(nn,nn); Vhat=(Q.inv()).trace()
    qn=gam/(qm+gam)
    for g in [d for d in range(1,nn+1) if nn%d==0]:
        # linear team rule u_i=sum_{j in group(i)} A_ij theta_j, iid unit-variance theta: value = max 2tr(A)-tr(A'QA)
        syms={}; Am=sp.zeros(nn,nn)
        for i in range(nn):
            for j in range(nn):
                if i//g==j//g:
                    syms[(i,j)]=sp.Symbol(f"a{i}_{j}"); Am[i,j]=syms[(i,j)]
        obj=2*Am.trace()-(Am.T*Q*Am).trace()
        sol=sp.solve([sp.diff(obj,s) for s in syms.values()],list(syms.values()),dict=True)[0]
        val=sp.nsimplify(obj.subs(sol))
        print(f"n={nn} g={g}: brute beta={val/Vhat}  MR(6.6)={sp.nsimplify(mr_beta(g,nn,qn))}",
              ("  1-eta_S(0)=%s"% (1-gam**2*(nn-1)/((qm+gam)*(qm+gam*(nn-1)))) ) if g==1 else "")
