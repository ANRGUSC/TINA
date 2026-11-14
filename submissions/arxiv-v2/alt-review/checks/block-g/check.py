import numpy as np, itertools
from collections import deque

def hopdist(A):
    n=len(A); D=np.full((n,n),np.inf)
    for s in range(n):
        D[s,s]=0; q=deque([s])
        while q:
            u=q.popleft()
            for v in np.nonzero(A[u])[0]:
                if D[s,v]==np.inf: D[s,v]=D[s,u]+1; q.append(v)
    return D

def cov(A,kappa,nu):
    L=np.diag(A.sum(1))-A
    w,V=np.linalg.eigh(kappa**2*np.eye(len(A))+L)
    S=(V*w**(-nu))@V.T
    return S/np.mean(np.diag(S))

def Kop(D,lc):
    K=np.exp(-D/lc); return K/np.linalg.norm(K,axis=1,keepdims=True)

def eta_curve(S,K,D):
    n=len(S); diam=int(D.max()); tot=np.trace(K@S@K.T); out=[]
    for r in range(diam+1):
        res=0
        for i in range(n):
            O=np.nonzero(D[i]<=r)[0]
            c=S[O]@K[i]
            res+=K[i]@S@K[i]-c@np.linalg.solve(S[np.ix_(O,O)],c)
        out.append(res/tot)
    return np.array(out)

def regret(eta,T,lat):
    r=np.arange(len(eta)); return 1-np.exp(-2*lat*r/T)*(1-eta)

def ring(n):
    A=np.zeros((n,n))
    for i in range(n): A[i,(i+1)%n]=A[(i+1)%n,i]=1
    return A
def path(n):
    A=np.zeros((n,n))
    for i in range(n-1): A[i,i+1]=A[i+1,i]=1
    return A
def grid(m):
    A=np.zeros((m*m,m*m))
    for i in range(m):
        for j in range(m):
            if i+1<m: A[i*m+j,(i+1)*m+j]=A[(i+1)*m+j,i*m+j]=1
            if j+1<m: A[i*m+j,i*m+j+1]=A[i*m+j+1,i*m+j]=1
    return A
def rgg(seed=20260839,n=64,th=0.22):
    rng=np.random.default_rng(seed); P=rng.uniform(size=(n,2))
    while True:
        d=np.linalg.norm(P[:,None]-P[None],axis=2); A=((d<=th)&(d>0)).astype(float)
        if np.isfinite(hopdist(A)).all(): return A,th
        th+=0.02

def unimodal(R):
    d=np.sign(np.diff(R)); d=d[d!=0]
    return np.all(np.diff(d)>=0)  # decreasing then increasing
def greedy(R):
    r=0
    while r+1<len(R) and R[r+1]<R[r]: r+=1
    return r

print("== ring fig (kappa .75, nu 1.5, T=6, lat .12)")
A=ring(64); D=hopdist(A); S=cov(A,0.75,1.5)
for lc in (0.7,2,6):
    e=eta_curve(S,Kop(D,lc),D); R=regret(e,6,0.12)
    print(lc, "argmin",int(np.argmin(R)), "R[:8]",np.round(R[:8],4), "eta0",round(e[0],4),"unimodal",unimodal(R))

print("== general graphs (kappa .8, nu 1.5, T=5, lc=2, lat .12)")
Ar,th=rgg(); print("rgg threshold",th)
graphs={"path":path(64),"ring":ring(64),"grid":grid(8),"rgg":Ar}
cache={}
for name,A in graphs.items():
    D=hopdist(A); S=cov(A,0.8,1.5)
    e=eta_curve(S,Kop(D,2),D); R=regret(e,5,0.12)
    print(name,"diam",int(D.max()),"argmin",int(np.argmin(R)),"greedy",greedy(R),"unimodal",unimodal(R),"eta monotone",bool(np.all(np.diff(e)<=1e-12)))
    cache[name]=(D,S)
print("== sweeps")
for name,(D,S) in cache.items():
    es={lc:eta_curve(S,Kop(D,lc),D) for lc in (0.7,1.2,2,3.5,6)}
    Topt=[int(np.argmin(regret(es[2],T,0.12))) for T in (1.5,2.5,4,6,9,14)]
    Lopt=[int(np.argmin(regret(es[lc],5,0.12))) for lc in (0.7,1.2,2,3.5,6)]
    nonuni=[(lc,T) for lc in es for T in (1.5,2.5,4,6,9,14) if not unimodal(regret(es[lc],T,0.12))]
    gre=[(lc,T,greedy(regret(es[lc],T,0.12)),int(np.argmin(regret(es[lc],T,0.12)))) for lc in es for T in (1.5,2.5,4,6,9,14) if greedy(regret(es[lc],T,0.12))!=int(np.argmin(regret(es[lc],T,0.12)))]
    print(name,"T sweep",Topt,"lc sweep",Lopt,"non-unimodal settings",nonuni,"greedy!=global",gre)
