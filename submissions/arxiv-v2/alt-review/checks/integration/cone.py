# Independent re-derivation of the synchronized vs propagation-cone comparison on the 64-node ring.
import numpy as np
n=64
A=np.zeros((n,n))
for i in range(n):
    A[i,(i+1)%n]=A[(i+1)%n,i]=1
L=np.diag(A.sum(1))-A
w,V=np.linalg.eigh(0.75**2*np.eye(n)+L)
S=(V*w**-1.5)@V.T
S=S/np.mean(np.diag(S))
idx=np.arange(n)
D=np.minimum(np.abs(idx[:,None]-idx[None,:]), n-np.abs(idx[:,None]-idx[None,:]))
T=6.0; lat=0.12
for lc in (0.7,2,6):
    K=np.exp(-D/lc); K=K/np.linalg.norm(K,axis=1,keepdims=True)
    tot=np.trace(K@S@K.T)
    sync=[];cone=[]
    for r in range(0,33):
        es=0;ec=0
        for i in range(n):
            O=np.nonzero(D[i]<=r)[0]
            c=S[O]@K[i]
            es+=K[i]@S@K[i]-c@np.linalg.solve(S[np.ix_(O,O)],c)
            ages=lat*D[i,O]
            C=S[np.ix_(O,O)]*np.exp(-np.abs(ages[:,None]-ages[None,:])/T)
            cc=c*np.exp(-ages/T)
            ec+=K[i]@S@K[i]-cc@np.linalg.solve(C,cc)
        eta=es/tot
        sync.append(1-np.exp(-2*lat*r/T)*(1-eta)); cone.append(ec/tot)
    sync=np.array(sync);cone=np.array(cone)
    print(lc,'sync argmin',sync.argmin(),round(sync.min(),4),'| cone argmin',cone.argmin(),round(cone.min(),4),'cone monotone',bool(np.all(np.diff(cone)<=1e-9)),'ratio',round(sync.min()/cone.min(),2))
