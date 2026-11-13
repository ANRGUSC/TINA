import numpy as np
def mr_beta(g,nn,q): return (1+(g-2)*q)/(1+(g-1)*q)*(1+(nn-1)*q)/(1+(nn-2)*q)
for nn,qm,gam in ((6,1.0,0.7),(8,2.0,1.5),(12,0.5,3.0)):
    Q=qm*np.eye(nn)+gam*np.ones((nn,nn)); Vhat=np.trace(np.linalg.inv(Q)); qn=gam/(qm+gam)
    for g in [d for d in range(1,nn+1) if nn%d==0]:
        sup=[(i,j) for i in range(nn) for j in range(nn) if i//g==j//g]
        pos={p:k for k,p in enumerate(sup)}
        M=np.zeros((len(sup),len(sup))); b=np.zeros(len(sup))
        for (i,j),k in pos.items():           # (QA)_ij = delta_ij on support
            for m in range(nn):
                if (m,j) in pos: M[k,pos[(m,j)]]+=Q[i,m]
            b[k]=1.0 if i==j else 0.0
        a=np.linalg.solve(M,b); A=np.zeros((nn,nn))
        for p,k in pos.items(): A[p]=a[k]
        val=2*np.trace(A)-np.trace(A.T@Q@A)
        # normalize Q to unit diagonal as in MR: value ratio is scale invariant
        extra=f" 1-eta_S(0)={1-gam**2*(nn-1)/((qm+gam)*(qm+gam*(nn-1))):.12f}" if g==1 else ""
        print(f"n={nn} g={g}: brute beta={val/Vhat:.12f}  MR(6.6)={mr_beta(g,nn,qn):.12f}{extra}")
print(104/153)
