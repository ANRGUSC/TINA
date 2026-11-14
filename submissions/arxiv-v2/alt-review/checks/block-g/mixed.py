import numpy as np
from check import *
# Gaussian common-rate OU: Cov(theta_{j,t-s}, theta_{k,t-u}) = exp(-|s-u|/T) S_jk
def mixed_regret(S,K,D,T,lat,r,mode):
    n=len(S); tot=np.trace(K@S@K.T); res=0
    for i in range(n):
        O=np.nonzero(D[i]<=r)[0]
        if mode=="cone":      # each node read at its own propagation age
            ages=lat*D[i,O]
        elif mode=="local+snap":  # fresh own reading + synchronized radius-r snapshot of age lat*r
            O=np.concatenate([[i],O]); ages=np.concatenate([[0.0],np.full(len(O)-1,lat*r)])
        C=S[np.ix_(O,O)]*np.exp(-np.abs(ages[:,None]-ages[None,:])/T)
        c=(S[O]@K[i])*np.exp(-ages/T)
        if mode=="local+snap" and r==0:
            C=C[:1,:1]; c=c[:1]
        res+=K[i]@S@K[i]-c@np.linalg.solve(C+1e-12*np.eye(len(C)),c)
    return res/tot
A=ring(64); D=hopdist(A); S=cov(A,0.75,1.5); T=6; lat=0.12
for lc in (0.7,2,6):
    K=Kop(D,lc); e=eta_curve(S,K,D); R=regret(e,T,lat)
    cone=[mixed_regret(S,K,D,T,lat,r,"cone") for r in range(0,33)]
    ls=[mixed_regret(S,K,D,T,lat,r,"local+snap") for r in range(0,33)]
    print("lc",lc,"sync opt r",int(np.argmin(R)),"R",round(R.min(),4),
          "| cone: argmin",int(np.argmin(cone)),"R",round(min(cone),4),"monotone",bool(np.all(np.diff(cone)<=1e-9)),
          "| local+snap: argmin",int(np.argmin(ls)),"R",round(min(ls),4))
    print("   cone[:8]",np.round(cone[:8],4)," cone[32]",round(cone[32],4))
