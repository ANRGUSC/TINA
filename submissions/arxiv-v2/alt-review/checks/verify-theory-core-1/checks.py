import numpy as np
from numpy.linalg import solve, eigh

# ---------- D1: discretised canonical field, two time slices ----------
def d1(lc=1.0, ls=1.0, r=0.5, rho=0.3, h=0.01, L=14.0):
    z=np.arange(-L,L+h/2,h); n=len(z)
    S=np.exp(-np.abs(z[:,None]-z[None,:])/ls)
    w=np.exp(-np.abs(z)/lc)/(2*lc)*h          # target at location 0
    a=np.exp(-rho)
    obs=np.where(np.abs(z)<=r+1e-9)[0]
    var=w@S@w
    # fresh
    c=S[obs]@w; fresh=var-c@solve(S[np.ix_(obs,obs)],c)
    # delayed: observe old field on obs; cov(x*_t, theta_old(obs)) = a * S[obs] w  (jointly Gaussian separable)
    cd=a*c; delayed=var-cd@solve(S[np.ix_(obs,obs)],cd)
    eta0=lc/(lc+2*ls)
    return fresh/var, eta0*np.exp(-2*r/lc), delayed/var, 1-a*a*(1-eta0*np.exp(-2*r/lc))
for args in [(1,1,.5,.3),(2,0.5,1.0,.2),(0.5,2,0.25,.5),(1,1,0,.3)]:
    print('D1',args,['%.6f'%v for v in d1(*args)])

# ---------- E1: identity ----------
rng=np.random.default_rng(0)
a_,b_=0.37,0.21
z1=rng.standard_normal(50000); z2=rng.standard_normal(50000)
print('E1 mean',np.mean((np.sqrt(a_)*z1+np.sqrt(b_)*z2)**2),'a+b',a_+b_)

# ---------- F1: M-R (6.6) at g=1 vs manuscript 1-eta_S(0) ----------
from fractions import Fraction as F
for n,q,g in [(6,F(1),F(7,10)),(8,F(1,2),F(3,2)),(100,F(1),F(5))]:
    qm=g/(q+g); G=1
    beta=(1+(G-2)*qm)/(1+(G-1)*qm)*(1+(n-1)*qm)/(1+(n-2)*qm)
    eta=g*g*(n-1)/((q+g)*(q+g*(n-1)))
    print('F1',n,beta,1-eta,beta==1-eta)

# ---------- G1: ring, synchronized vs propagation cone ----------
n=64; kappa=0.75; nu=1.5; T=6.0; lat=0.12
Lg=2*np.eye(n)-np.roll(np.eye(n),1,0)-np.roll(np.eye(n),-1,0)
ev,U=eigh(kappa**2*np.eye(n)+Lg); S=(U*ev**(-nu))@U.T; S/=np.mean(np.diag(S))
idx=np.arange(n); d=np.minimum(np.abs(idx[:,None]-idx[None,:]),n-np.abs(idx[:,None]-idx[None,:]))
for lc in [0.7,2,6]:
    K=np.exp(-d/lc); K/=np.linalg.norm(K,axis=1,keepdims=True)
    Rinf=np.trace(K@S@K.T)
    sync=[];cone=[]
    for r in range(0,33):
        es=0;ec=0
        for i in range(n):
            O=np.where(d[i]<=r)[0]; ki=K[i]
            c=S[O]@ki; v=ki@S@ki
            es+=v-c@solve(S[np.ix_(O,O)],c)
            ages=lat*d[i,O]
            C=S[np.ix_(O,O)]*np.exp(-np.abs(ages[:,None]-ages[None,:])/T)
            cc=c*np.exp(-ages/T)
            ec+=v-cc@solve(C,cc)
        eta=es/Rinf
        sync.append(1-np.exp(-2*lat*r/T)*(1-eta)); cone.append(ec/Rinf)
    sync=np.array(sync);cone=np.array(cone)
    print('G1 lc',lc,'sync argmin',sync.argmin(),'%.4f'%sync.min(),'cone argmin',cone.argmin(),'cone full %.4f'%cone[-1],'cone monotone',bool(np.all(np.diff(cone)<=1e-12)), 'sync unimodal', bool(np.all(np.diff(np.sign(np.diff(sync)))>=0)))
