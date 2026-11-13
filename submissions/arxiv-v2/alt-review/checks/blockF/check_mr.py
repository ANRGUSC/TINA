from fractions import Fraction as F
def solve(A,b):
    n=len(A); M=[row[:]+[b[i]] for i,row in enumerate(A)]
    for c in range(n):
        p=next(r for r in range(c,n) if M[r][c]!=0); M[c],M[p]=M[p],M[c]
        pv=M[c][c]; M[c]=[x/pv for x in M[c]]
        for r in range(n):
            if r!=c and M[r][c]!=0:
                f=M[r][c]; M[r]=[x-f*y for x,y in zip(M[r],M[c])]
    return [M[i][n] for i in range(n)]
def inv(Q):
    n=len(Q); cols=[solve(Q,[F(int(i==j)) for i in range(n)]) for j in range(n)]
    return [[cols[j][i] for j in range(n)] for i in range(n)]
def share(nn,G,q,g):
    Q=[[q*(i==j)+g for j in range(nn)] for i in range(nn)]; K=inv(Q)
    grp=[i//G for i in range(nn)]
    idx=[(i,j) for i in range(nn) for j in range(nn) if grp[i]==grp[j]]
    # minimize tr((B-K)'Q(B-K)) over B with support idx (linear rules; iid unit-variance states)
    A=[[Q[i][k] if j==l else F(0) for (k,l) in idx] for (i,j) in idx]
    b=[F(int(i==j)) for (i,j) in idx]   # (QK)_{ij}=I
    x=solve(A,b); B=[[F(0)]*nn for _ in range(nn)]
    for a,(i,j) in enumerate(idx): B[i][j]=x[a]
    D=[[B[i][j]-K[i][j] for j in range(nn)] for i in range(nn)]
    quad=lambda M: sum(M[i][c]*Q[i][k]*M[k][c] for i in range(nn) for k in range(nn) for c in range(nn))
    return 1-quad(D)/quad(K)
for nn,G,q,g in [(6,1,F(1),F(7,10)),(6,2,F(1),F(7,10)),(6,3,F(2),F(3,10)),(8,4,F(1,2),F(3,2)),(8,1,F(1,2),F(3,2))]:
    qm=g/(q+g)
    beta=(1+(G-2)*qm)/(1+(G-1)*qm)*(1+(nn-1)*qm)/(1+(nn-2)*qm)
    eta0=g*g*(nn-1)/((q+g)*(q+g*(nn-1)))
    print(nn,G,'bruteforce captured share =',share(nn,G,q,g),' M-R (6.6) beta(g) =',beta, ' manuscript 1-eta_S(0) =',(1-eta0) if G==1 else '-')
