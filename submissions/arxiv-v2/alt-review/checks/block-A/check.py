import numpy as np, itertools
rng=np.random.default_rng(0)

# ---------- C1/C2: finite probability space, 3 agents, non-affine b, heterogeneous info
# Omega = product of 3 discrete coords (theta1,theta2,theta3) with a random joint pmf
L=4; n=3
omega=list(itertools.product(range(L),repeat=n)); N=len(omega)
p=rng.random(N); p/=p.sum()
A=rng.standard_normal((n,n)); Q=A@A.T+0.5*np.eye(n)
# non-affine b(theta)
vals=rng.standard_normal((n,L))
def b(w): 
    t=np.array([vals[i,w[i]] for i in range(n)])
    return np.array([t[0]*t[1]+t[2], np.sin(t[1])+t[0]**2, t[2]*t[0]-t[1]])
Bm=np.array([b(w) for w in omega]); X=Bm@np.linalg.inv(Q)   # x* rows
# agent i observes coordinates obs[i]
obs=[(0,),(0,1),(2,)]
# parametrize u_i as table over observed values
cols=[]; 
for i in range(n):
    keys=sorted(set(tuple(w[j] for j in obs[i]) for w in omega))
    for k in keys:
        cols.append((i,k))
P=len(cols)
# u(w) = sum_c coef_c * e_i * 1{obs_i(w)=k}; minimize E (u-x*)'Q(u-x*)
Lq=np.linalg.cholesky(Q).T  # Q = Lq' Lq
M=np.zeros((N*n,P)); y=np.zeros(N*n)
for a,w in enumerate(omega):
    sp=np.sqrt(p[a])
    for c,(i,k) in enumerate(cols):
        if tuple(w[j] for j in obs[i])==k:
            M[a*n:(a+1)*n,c]=sp*Lq[:,i]
    y[a*n:(a+1)*n]=sp*Lq@X[a]
coef,res,rk,sv=np.linalg.lstsq(M,y,rcond=None)
U=np.zeros((N,n))
for a,w in enumerate(omega):
    for c,(i,k) in enumerate(cols):
        if tuple(w[j] for j in obs[i])==k: U[a,i]=coef[c]
R=0.5*np.sum(p*np.einsum('ai,ij,aj->a',U-X,Q,U-X))
nx=np.sum(p*np.einsum('ai,ij,aj->a',X,Q,X)); nu=np.sum(p*np.einsum('ai,ij,aj->a',U,Q,U))
print("rank",rk,"of",P,"  R=",R," Pythagoras 0.5(|x*|^2-|u|^2)=",0.5*(nx-nu))
# normal equations: E[(Qu-b)_i | G_i]=0
G=U@Q-Bm
mx=0
for i in range(n):
    keys={}
    for a,w in enumerate(omega):
        k=tuple(w[j] for j in obs[i]); keys.setdefault(k,[0,0])
        keys[k][0]+=p[a]*G[a,i]; keys[k][1]+=p[a]
    mx=max(mx,max(abs(v[0]/v[1]) for v in keys.values()))
print("max |E[(Qu-b)_i|G_i]| =",mx)
# agentwise conditional mean rule
V=np.zeros((N,n))
for i in range(n):
    keys={}
    for a,w in enumerate(omega):
        k=tuple(w[j] for j in obs[i]); keys.setdefault(k,[0,0])
        keys[k][0]+=p[a]*X[a,i]; keys[k][1]+=p[a]
    for a,w in enumerate(omega):
        k=tuple(w[j] for j in obs[i]); V[a,i]=keys[k][0]/keys[k][1]
Rv=0.5*np.sum(p*np.einsum('ai,ij,aj->a',V-X,Q,V-X))
print("agentwise cond-mean regret",Rv," >= optimum",R, " max|U-V|",abs(U-V).max())
# sufficiency: solve normal equations as linear system directly & compare (same as lstsq normal eqs) -- uniqueness via full rank
# common info: all observe coord 0 -> vector conditional mean
keys={}
for a,w in enumerate(omega):
    keys.setdefault(w[0],[np.zeros(n),0]); keys[w[0]][0]+=p[a]*X[a]; keys[w[0]][1]+=p[a]
Mc=np.array([keys[w[0]][0]/keys[w[0]][1] for w in omega])
cols2=[(i,k) for i in range(n) for k in range(L)]
M2=np.zeros((N*n,len(cols2)))
for a,w in enumerate(omega):
    for c,(i,k) in enumerate(cols2):
        if w[0]==k: M2[a*n:(a+1)*n,c]=np.sqrt(p[a])*Lq[:,i]
c2=np.linalg.lstsq(M2,y,rcond=None)[0]
U2=np.array([[c2[i*L+w[0]] for i in range(n)] for w in omega])
print("common info: max|team opt - vector cond mean| =",abs(U2-Mc).max())

# ---------- C3: data-processing monotonicity, finite stationary Markov chain, nonlinear target
S=6; Pm=rng.random((S,S)); Pm/=Pm.sum(1,keepdims=True)
ev,evec=np.linalg.eig(Pm.T); pi=np.real(evec[:,np.argmin(abs(ev-1))]); pi/=pi.sum()
xs=rng.standard_normal((S,2)); Q2=np.array([[2,.9],[.9,1]])
def loss(k):
    Pk=np.linalg.matrix_power(Pm,k); m=Pk@xs   # E[x*(theta_t)|theta_{t-k}=s]
    tot=0
    for s in range(S):
        for s2 in range(S):
            e=xs[s2]-m[s]; tot+=pi[s]*Pk[s,s2]*e@Q2@e
    return 0.5*tot
ls=[loss(k) for k in range(0,12)]
mu=pi@xs; Rinf=0.5*sum(pi[s]*(xs[s]-mu)@Q2@(xs[s]-mu) for s in range(S))
print("Markov losses nondecreasing:",np.all(np.diff(ls)>=-1e-12), ls[:5], "Rinf",Rinf)

# ---------- C4: non-Gaussian vector AR(1), independent skewed innovations, nonlinear check of E[eps|theta_old]=0
c=0.7; T_=200000; burn=500; d=2
Lm=np.array([[1,0],[.6,.8]])
w=(rng.exponential(1,(T_+burn,d))-1)@Lm.T
th=np.zeros((T_+burn,d))
for t in range(1,T_+burn): th[t]=c*th[t-1]+w[t]
th=th[burn:]
for k in (1,3):
    old=th[:-k]; new=th[k:]; eps=new-c**k*old
    feats=np.column_stack([old,old**2,old[:,:1]*old[:,1:],np.tanh(old),np.ones(len(old))])
    feats=(feats-feats.mean(0))/np.where(feats.std(0)>0,feats.std(0),1)
    print("k",k,"max |corr-type E[eps * phi(old)]| =",abs(eps.T@feats/len(old)).max(),
          " Cov(new,old)/Cov(old) coef:",np.round(np.linalg.lstsq(old,new,rcond=None)[0].T,3).tolist(),"c^k",c**k)
# counter-illustration: uncorrelated but dependent innovations break the conditional-mean property
z=rng.standard_normal(T_+burn+1)
w2=z[1:]*z[:-1]          # white (uncorrelated, mean zero) but not independent
th2=np.zeros(T_+burn)
for t in range(1,T_+burn): th2[t]=c*th2[t-1]+w2[t]
th2=th2[burn:]; w2=w2[burn:]
old=th2[:-1]; eps=th2[1:]-c*old
print("dependent white innovations: E[eps*old]=",np.mean(eps*old)," E[eps*old^2]=",np.mean(eps*old**2), "(nonzero => E[eps|old]!=0)")

# ---------- OU: stationary covariance and lag covariance
T=2.0; Sg=Lm@Lm.T
print("Lyapunov residual:",abs(-2/T*Sg+2/T*Sg).max())
