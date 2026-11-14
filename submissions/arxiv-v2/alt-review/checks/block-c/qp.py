import numpy as np, itertools
rng=np.random.default_rng(0)
def team_opt(joint_vals, joint_p, Q, n):
    """Exact optimum over ALL local rules g_i(theta_i) for finite-support theta.
    joint_vals: (m,n) atoms; joint_p: (m,) probs. Unknowns: g_i(v) for each distinct value v of theta_i."""
    idx=[]; off=0; maps=[]
    for i in range(n):
        vals=np.unique(joint_vals[:,i]); maps.append({v:off+k for k,v in enumerate(vals)}); off+=len(vals)
    N=off
    H=np.zeros((N,N)); c=np.zeros(N)
    for a,p in zip(joint_vals,joint_p):
        S=np.zeros((n,N))
        for i in range(n): S[i,maps[i][a[i]]]=1
        H+=p*S.T@Q@S; c+=p*S.T@a      # E[1/2 u'Qu - theta'u]
    g=np.linalg.solve(H,c)
    cost=0.5*g@H@g-c@g
    return g,maps,cost
def formulas(n,q,gam,sumvar):
    Rinf=sumvar*(q+gam*(n-1))/(2*q*(q+gam*n))
    Rloc=sumvar*gam**2*(n-1)/(2*q*(q+gam)*(q+gam*n))
    eta=gam**2*(n-1)/((q+gam)*(q+gam*(n-1)))
    return Rinf,Rloc,eta
print("== independent, non-Gaussian skewed, equal variance ==")
for n,q,gam in [(2,1.0,0.5),(3,0.7,2.0),(4,2.0,0.3),(3,1.0,10.0),(5,1.3,0.0),(4,0.5,1.7)]:
    # skewed 3-point zero-mean law per agent, rescaled to unit variance
    v=np.array([-1.0,0.2,3.0]); p=np.array([0.5,0.35,0.15]); v=v-(p@v); v=v/np.sqrt(p@v**2)
    atoms=np.array(list(itertools.product(v,repeat=n))); pr=np.array([np.prod(x) for x in itertools.product(p,repeat=n)])
    Q=q*np.eye(n)+gam*np.ones((n,n))
    g,maps,cost=team_opt(atoms,pr,Q,n)
    full=-0.5*sum(pp*a@np.linalg.solve(Q,a) for a,pp in zip(atoms,pr))
    Rloc_num=cost-full; Rinf_num=0-full
    Rinf,Rloc,eta=formulas(n,q,gam,n*1.0)
    maxdev=max(abs(g[k]-vv/(q+gam)) for i in range(n) for vv,k in maps[i].items())
    print(n,q,gam,"rule dev %.2e"%maxdev,"Rinf err %.2e"%(Rinf_num-Rinf),"Rloc err %.2e"%(Rloc_num-Rloc),"eta err %.2e"%(Rloc_num/Rinf_num-eta if Rinf_num>0 else 0))
print("== independent, UNEQUAL variances and different laws ==")
for n,q,gam in [(3,0.7,2.0),(4,2.0,0.3)]:
    laws=[]
    for i in range(n):
        v=rng.normal(size=4)*(1+i); p=rng.dirichlet(np.ones(4)); v=v-p@v; laws.append((v,p))
    atoms=np.array(list(itertools.product(*[l[0] for l in laws]))); pr=np.array([np.prod(x) for x in itertools.product(*[l[1] for l in laws])])
    sumvar=sum(p@v**2 for v,p in laws)
    Q=q*np.eye(n)+gam*np.ones((n,n))
    g,maps,cost=team_opt(atoms,pr,Q,n)
    full=-0.5*sum(pp*a@np.linalg.solve(Q,a) for a,pp in zip(atoms,pr))
    Rinf,Rloc,eta=formulas(n,q,gam,sumvar)
    maxdev=max(abs(g[k]-vv/(q+gam)) for i in range(n) for vv,k in maps[i].items())
    print(n,q,gam,"rule dev %.2e"%maxdev,"eta err %.2e"%((cost-full)/(-full)-eta))
print("== uncorrelated but DEPENDENT (theta2 = theta1^2-1 type): linear rule not optimal ==")
n,q,gam=2,1.0,1.0
v=np.array([-np.sqrt(3),0,np.sqrt(3)]); p=np.array([1/6,2/3,1/6])  # mean0 var1, symmetric
atoms=np.array([[a,(a*a-1)/np.sqrt(p@((v*v-1)**2))] for a in v]); pr=p
print(" cov:",np.cov(atoms.T,aweights=pr,bias=True).round(12).tolist())
Q=q*np.eye(n)+gam*np.ones((n,n))
g,maps,cost=team_opt(atoms,pr,Q,n)
full=-0.5*sum(pp*a@np.linalg.solve(Q,a) for a,pp in zip(atoms,pr))
u=atoms/(q+gam); lin=sum(pp*(0.5*x@Q@x-a@x) for a,x,pp in zip(atoms,u,pr))
Rinf,Rloc,eta=formulas(n,q,gam,2.0)
print(" R(team opt)=%.6f  R(theta_i/(q+gam))=%.6f  formula Rloc=%.6f  Rinf=%.6f"%(cost-full,lin-full,Rloc,Rinf))
print("== agentwise conditional mean E[x*_i|theta_i]=theta_i (1/q - gam/(q(q+gam n))) vs team optimum ==")
for n,q,gam in [(3,0.7,2.0),(10,1.0,1.0)]:
    Q=q*np.eye(n)+gam*np.ones((n,n)); Qi=np.linalg.inv(Q)
    c=Qi[0,0]; M=c*np.eye(n)-Qi; Rcm=0.5*np.trace(M.T@Q@M)
    Rinf,Rloc,eta=formulas(n,q,gam,n)
    print(n,q,gam," coeff cm=%.4f team=%.4f ; R_cm=%.5f R_loc=%.5f R_inf=%.5f"%(c,1/(q+gam),Rcm,Rloc,Rinf))
print("== crossover check: independent AR(1) non-Gaussian, exact ==")
for n,q,gam in [(3,0.7,2.0),(6,1.0,0.4)]:
    Rinf,Rloc,eta=formulas(n,q,gam,n)
    rho=0.5*np.log((q+gam)*(q+gam*(n-1))/(q*(q+gam*n)))
    for r in [0.9*rho,rho,1.1*rho]:
        print(n,q,gam,"rho/rho*=%.2f"%(r/rho),"Rloc-Rglob=%.3e"%(Rloc-(1-np.exp(-2*r))*Rinf))
