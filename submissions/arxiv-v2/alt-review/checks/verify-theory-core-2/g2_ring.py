import numpy as np
# 64-node ring of the paper (Fig. decision relevance): Q=I vs off-diagonal Q, team-optimal linear rules.
n=64; T=6.0; lat=0.12; kap=0.75; nu=1.5
idx=np.arange(n)
d=np.abs(idx[:,None]-idx[None,:]); d=np.minimum(d,n-d)
A=(d==1).astype(float); L=np.diag(A.sum(1))-A
w,V=np.linalg.eigh(kap**2*np.eye(n)+L)
S=(V*w**(-nu))@V.T; S/=np.mean(np.diag(S))
def Kop(lc):
    K=np.exp(-d/lc); return K/np.linalg.norm(K,axis=1,keepdims=True)
def eta_team(K,Q,r):
    # u_i = a_i^T theta_{N_r(i)}; U = sum_i e_i a_i^T P_i ; minimise tr((U-K) S (U-K)^T Q)
    nb=[np.where(d[i]<=r)[0] for i in range(n)]
    off=np.cumsum([0]+[len(b) for b in nb]); m=off[-1]
    H=np.zeros((m,m)); g=np.zeros(m)
    QK=Q@K@S   # (Q K S)
    for i in range(n):
        g[off[i]:off[i+1]]=QK[i,nb[i]]
        for j in range(n):
            if Q[i,j]!=0:
                H[off[i]:off[i+1],off[j]:off[j+1]]=Q[i,j]*S[np.ix_(nb[i],nb[j])]
    a=np.linalg.solve(H,g)
    Rinf=0.5*np.trace(K@S@K.T@Q)
    R=Rinf-0.5*a@g
    # agentwise conditional means evaluated under Q
    U=np.zeros((n,n))
    for i in range(n):
        U[i,nb[i]]=np.linalg.solve(S[np.ix_(nb[i],nb[i])],S[nb[i]]@K[i])
    E=U-K; Ragent=0.5*np.trace(E@S@E.T@Q)
    return R/Rinf, Ragent/Rinf
def run(Q,label,rmax=32):
    print(label)
    for lc in (0.7,2,6):
        K=Kop(lc)
        et=[];ea=[]
        for r in range(0,rmax+1):
            t,a=eta_team(K,Q,r); et.append(t); ea.append(a)
        et=np.array(et);ea=np.array(ea); r=np.arange(rmax+1)
        reg_t=1-np.exp(-2*lat*r/T)*(1-et); reg_a=1-np.exp(-2*lat*r/T)*(1-ea)
        print("  lc=%.1f  team-opt r*=%d  (agentwise-rule r*=%d)  eta_S team[0..5]=%s  agentwise[0..5]=%s  max gap=%.4f"%(lc,reg_t.argmin(),reg_a.argmin(),np.round(et[:6],4),np.round(ea[:6],4),np.max(ea-et)))
run(np.eye(n),"Q = I (paper)")
for gam in (0.5,2.0):
    run(np.eye(n)+gam*np.ones((n,n))/1.0,"Q = I + %.1f * 11^T (aggregate coupling)"%gam)
for c in (0.45,-0.45):
    run(np.eye(n)+c*A,"Q = I + %.2f * Adjacency (nearest-neighbour coupling)"%c)
