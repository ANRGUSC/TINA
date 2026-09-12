"""Frozen source-mapped steps and audit decisions for the reviewed letter."""

def step(id, statement, source, deps, check, status='OK', kind='NORMALIZED', support='EXPLICIT'):
    return dict(id=id, statement=statement, source=source, deps=deps,
                check=check, status=status, kind=kind, support=support)


PROOFS = [
dict(id='L', name='Lemma 1: Team optimality', label='lem:normal', eqs='(3), (5)',
 contract=r'''For the information fields $\mathcal G_i$, optimize over $u_i\in L^2(\mathcal G_i)$, with $X\in L^2$, $n\ge2$, and $\kappa\ge0$. A feasible $u$ is optimal exactly when
\[
(1+\kappa)u_i-\kappa\E[\bar u\mid\mathcal G_i]=\E[X\mid\mathcal G_i]\quad(i=1,\ldots,n).
\]
Two optimal feasible policies agree almost surely.''',
 steps=[
step('L.1',r'For a feasible perturbation $w$, the objective difference has linear term $2n^{-1}\sum_i\E[w_i((1+\kappa)u_i-\kappa\bar u-X)]$ and a quadratic remainder.',
     'For feasible $w$', ['A-L2','D-loss'], 'K-L: expansion is an identity for square-integrable policies.'),
step('L.2',r'The linear term vanishes for every feasible $w$ if and only if the conditional normal equations (5) hold.',
     'and vanishes for all', ['L.1','B-CE'], 'K-L: conditional expectation converts testing against every local perturbation into a zero conditional residual.'),
step('L.3',r'The remainder is $n^{-1}\sum_i\E[w_i^2]+\kappa n^{-1}\sum_i\E[(w_i-\bar w)^2]$, positive whenever $w$ is nonzero in $L^2$.',
     'The remainder is', ['A-L2','D-loss'], 'K-L: the first sum is strictly positive and the second nonnegative.'),
step('L.4',r'Q.E.D. Necessity, sufficiency, and uniqueness follow.',
     'proving necessity', ['L.1','L.2','L.3'], 'A nonzero linear term admits a small improving signed perturbation; a zero linear term leaves a positive remainder.',kind='STRUCTURAL')]),

dict(id='P',name='Proposition 1: Fresh endpoints',label='prop:endpoints',eqs='(6)--(11)',
 contract=r'''Under (1)--(3), let $v=a+b/n$ and $d=a+b[1+\kappa(1-1/n)]$. For complete local and pooled histories,
\[
P_1=\frac{ab}{a+b},\quad P_n=\frac{ab}{b+na},\quad
u_i^L=\frac adY_i(t),\quad u_i^P=\frac av\bar Y(t).
\]
The optimal losses are $J_L=a-a^2/d$ and $J_P=P_n=a-a^2/v$, and $\Delta=J_L-J_P=a^2(d-v)/(vd)>0$.''',
 steps=[
step('P.1',r'$X(t)-aY_i(t)/(a+b)$ has zero covariance with every $Y_i(r)$ for $r\le t$, so it is independent of the local history.',
     'For any', ['A-G','D-Y','B-G'], 'K-P: the common exponential factor cancels for every earlier time.'),
step('P.2',r'Define $\eta(t)=X(t)-(a/v)\bar Y(t)$. It is uncorrelated with every $Y_j(r)$ and independent of the entire sensor process.',
     'Similarly,', ['A-G','D-Y','B-G'], 'K-P: Cov(bar Y(t),Y_j(r)) = v exp(-lambda |t-r|); this works for past and future r.'),
step('P.3',r'The residual variances are $P_1=ab/(a+b)$ and $P_n=ab/(b+na)$. The corresponding conditional means are $aY_i(t)/(a+b)$ and $(a/v)\bar Y(t)$.',
     'Computing the residual variances', ['P.1','P.2','B-CE'], 'K-P: subtract the explained variance from a.'),
step('P.4',r'For the candidate $u_i=kY_i(t)$, $\E[\bar u\mid\mathcal F_i(t)]=kvY_i(t)/(a+b)$.',
     'For $u_i=kY_i(t)$', ['A-G','D-Y','B-G'], 'K-P: the same regression residual is orthogonal to the full local history.'),
step('P.5',r'Equation (5) gives $k[(1+\kappa)(a+b)-\kappa v]=a$. The bracket equals $d$, so $k=a/d$.',
     'Equation~\\eqref{eq:normal}', ['L.4','P.3','P.4','D-vd'], 'K-P: d is positive under a,b>0 and kappa>=0.'),
step('P.6',r'The local loss is $a-2ak+dk^2=a-a^2/d$.',
     'Its expected loss is', ['P.5','D-loss'], 'K-P: E(Y_i^2)=a+b and average expected disagreement of the readings is b(1-1/n).'),
step('P.7',r'With pooled information all agents use the common conditional mean, with zero disagreement and loss $P_n$.',
     'With pooled information', ['P.3','B-CE','D-loss'], 'Each squared tracking error is separately minimized and the nonnegative disagreement term is zero.'),
step('P.8',r'The displayed feasible policies are optimal by Lemma 1.',
     'Lemma~\\ref{lem:normal}', ['L.4','P.5','P.7'], 'The normal equations are satisfied; linearity was a candidate construction, not a restriction on competitors.'),
step('P.9',r'$d-v=b(1+\kappa)(1-1/n)>0$ and subtraction yields the formula for $\Delta$.',
     'Finally,', ['A-G','D-vd','P.6','P.7'], 'n>=2, b>0, and kappa>=0 make the strict sign valid.'),
step('P.10',r'Q.E.D. All endpoint claims follow.', 'Finally,', ['P.3','P.6','P.7','P.8','P.9'], 'Every component of the proposition is included.',kind='STRUCTURAL',support='IMPLICIT')]),

dict(id='D',name='Corollary 1: The delay crossover',label='cor:crossover',eqs='(13), (14)',
 contract=r'''Let $\tau\ge0$ and $s=t-\tau$. Every agent has $\mathcal F(s)$ and no post-$s$ measurements. The optimal common action is $u_i^D=e^{-\lambda\tau}(a/v)\bar Y(s)$ and
\[
J_D(\tau)=a-\frac{a^2}{v}e^{-2\lambda\tau}.
\]
Then $J_L<J_D(\tau)$ exactly when $\tau>(2\lambda)^{-1}\log(d/v)$, with equality at that age.''',
 steps=[
step('D.1',r'The Markov property and Proposition 1 give $\E[X(t)\mid\mathcal F(s)]=e^{-\lambda\tau}(a/v)\bar Y(s)$.',
     'The Markov property', ['A-G','P.3','B-OU','B-CE'], 'K-D: the post-s signal innovation is independent of the old sensor history.'),
step('D.2',r'Taking this common mean minimizes tracking loss and yields zero disagreement, hence minimizes the team loss.',
     'Taking this common conditional mean', ['D.1','D-loss','B-CE'], 'The lower bound is attained simultaneously for all agents.'),
step('D.3',r'The error variance is the displayed $J_D(\tau)$.',
     'Its error variance', ['D.1','D.2','D-vd'], 'K-D: the explained variance is exp(-2 lambda tau) a^2/v.'),
step('D.4',r'Comparison with $J_L$ yields $J_L<J_D$ if and only if $e^{-2\lambda\tau}<v/d$.',
     'Comparing with', ['D.3','P.6','P.9'], 'Both denominators and a^2 are positive.'),
step('D.5',r'Taking logarithms gives the exact threshold (14), including its equality case.',
     'which is', ['D.4','A-G'], 'K-D: dividing by -2 lambda reverses the inequality.'),
step('D.6',r'Q.E.D.', 'which is', ['D.1','D.2','D.3','D.5'], 'Policy, value, strict comparison, and equality case all close.',kind='STRUCTURAL',support='IMPLICIT')]),

dict(id='H',name='Theorem 1: Hybrid policy and exponential value',label='thm:hybrid',eqs='(15)--(21)',
 contract=r'''Under (1)--(4), put $\rho=e^{-\lambda\tau}$ and $s=t-\tau$. The unique optimal hybrid action is
\[
u_i^H=\rho\frac av\bar Y(s)+\frac ad[Y_i(t)-\rho Y_i(s)].
\]
It also attains the optimum with the larger information $\mathcal F(s)\vee\mathcal F_i(t)$. Its posterior variance and team loss satisfy
\[
P_H=\rho^2P_n+(1-\rho^2)P_1,\qquad
J_H=\rho^2J_P+(1-\rho^2)J_L,
\]
and $J_L-J_H=\Delta e^{-2\lambda\tau}$.''',
 steps=[
step('H.1',r'CASE $\tau=0$. The formula is the pooled policy.',
     'For $\\tau=0$', ['P.3','P.7','P.8'], 'The local correction is zero; the posterior and cost formulas reduce to the pooled endpoints.',kind='STRUCTURAL'),
step('H.2',r'CASE $\tau>0$. Prove the remaining claims under this assumption.',
     'Suppose $\\tau>0$', ['A-G'], 'All descendants of H.2 have tau>0 in scope. This assumption is discharged at the root Q.E.D.',kind='STRUCTURAL'),
step('H.2.1',r'Enlarge each information field to $\mathcal G_i=\mathcal F(s)\vee\mathcal F_i(t)$ and define $Z_i=Y_i(t)-\rho Y_i(s)$, $h=a/v$, $k=a/d$.',
     "and enlarge each agent's information", ['D-info','D-vd'], 'This is an enlargement, so its minimum is a lower bound on the hybrid minimum.'),
step('H.2.2',r'$Z$ is independent of $\mathcal F(s)$ and has covariance $(1-\rho^2)(a\mathbf1\mathbf1^\top+bI)$.',
     'The Gaussian Markov property', ['H.2.1','A-G','B-OU','B-G'], 'K-H1: all old-history cross-covariances cancel.'),
step('H.2.3',r'$X(t)=\rho h\bar Y(s)+h\bar Z+\eta(t)$, where $\eta(t)$ is independent of all sensor data and has variance $P_n$.',
     'Equation~\\eqref{eq:eta}', ['H.2.1','P.2','P.3'], 'This is the source residual decomposition with bar Y(t)=rho bar Y(s)+bar Z.'),
step('H.2.4',r'For $s<r\le t$, define $Z_i(r)=Y_i(r)-e^{-\lambda(r-s)}Y_i(s)$. Then $\Cov(\bar Z,Z_i(r))=[v/(a+b)]\Cov(Z_i,Z_i(r))$.',
     'For $s<r\\le t$', ['H.2.1','A-G','D-vd'], 'K-H1 expands the two covariances from (1); the pooled factor v includes the own-sensor contribution.'),
step('H.2.5',r'Both covariances have the temporal factor $e^{-\lambda(t-r)}(1-e^{-2\lambda(r-s)})$.',
     'Both covariances share', ['H.2.4','A-G'], 'K-H1 computes the factor for every intermediate time, including r=t.'),
step('H.2.6',r'$\bar Z-vZ_i/(a+b)$ is orthogonal to the entire local innovation path and to $\mathcal F(s)$.',
     'Thus $\\bar Z-', ['H.2.2','H.2.4','H.2.5'], 'K-H2 checks every generator of the enlarged information field. The whole innovation path is independent of the old history.'),
step('H.2.7',r'Gaussianity gives $\E[\bar Z\mid\mathcal G_i]=vZ_i/(a+b)$.',
     'Gaussianity gives', ['H.2.1','H.2.6','B-G','B-CE'], 'K-H2: the regression residual is independent of the generated sigma-field and the proposed predictor is measurable in it.'),
step('H.2.8',r'Independence of $\eta(t)$ gives $\E[h\bar Z+\eta(t)\mid\mathcal G_i]=aZ_i/(a+b)$ and $\E[k\bar Z\mid\mathcal G_i]=kvZ_i/(a+b)$.',
     'Since $\\eta(t)$', ['H.2.3','H.2.7','B-CE'], 'K-H2: h v=a, eta is centered and independent of all observations, and k is deterministic.'),
step('H.2.9',r'Subtract the common prediction. Since $(1+\kappa)(a+b)-\kappa v=d$, the correction $kZ_i$ satisfies (5) under the full path information. Lemma 1 certifies optimality.',
     'Subtract the common prediction', ['H.2.1','H.2.3','H.2.8','D-vd','L.4'], 'K-H3 substitutes the full-history conditional means directly in the normal equation. All admissible nonlinear history-dependent competitors are covered.'),
step('H.2.10',r'The policy (15) is feasible under the hybrid field (4), so it attains the same value as complete delayed sharing.',
     'The policy \\eqref{eq:hybridpolicy}', ['H.2.1','H.2.9','D-info'], 'The policy only uses the current and retained own readings and the old pooled scalar. Feasibility gives equality of the two optimal values.'),
step('H.2.11',r'The irreducible variance is $P_n$ and the remaining quadratic cost scales by $1-\rho^2$. Thus $J_H=P_n+(1-\rho^2)(J_L-P_n)$.',
     'At one time,', ['H.2.2','H.2.3','H.2.9','P.6','P.7'], 'K-H4 scales the sensor-dependent quadratic cost and retains the independent residual variance.'),
step('H.2.12',r'The enlarged-information posterior mean is $\rho h\bar Y(s)+aZ_i/(a+b)$. It is hybrid-feasible and has error variance $P_n+(1-\rho^2)(P_1-P_n)$.',
     'The posterior mean under the enlarged information', ['H.2.2','H.2.3','H.2.8','P.3','B-CE'], 'K-H4 computes the posterior variance and checks that the same conditional mean is measurable in the smaller hybrid field.'),
step('H.2.13',r'Subtracting the cost from $J_L$ yields $\Delta e^{-2\lambda\tau}$.',
     'Equation~\\eqref{eq:exponential}', ['H.2.11','P.9'], 'The interpolation gives rho^2 Delta, with rho^2=exp(-2 lambda tau).'),
step('H.2.14',r'Q.E.D. The positive-age branch is established.',
     'Equation~\\eqref{eq:exponential}', ['H.2.10','H.2.11','H.2.12','H.2.13'], 'Exports the theorem under tau>0.',kind='STRUCTURAL',support='IMPLICIT'),
step('H.3',r'Q.E.D. The two cases cover every $\tau\ge0$.',
     'Equation~\\eqref{eq:exponential}', ['H.1','H.2','A-G'], 'Uses the completed case statements, with no reference into their private descendants.',kind='STRUCTURAL',support='IMPLICIT')]),

dict(id='U',name='Proposition 2: Unequal sensor quality',label='prop:hetero',eqs='(23)--(25)',
 contract=r'''Replace $b$ by $b_i>0$, retaining independence, stationarity, Gaussianity, and a common temporal rate. Define
\[
C_i=(1+\kappa)a+b_i[1+\kappa(1-1/n)],\qquad \theta=n^{-1}\sum_i C_i^{-1}.
\]
Then $k_i=a/[C_i(1-\kappa a\theta)]$, $J_L=a-a^2\theta/(1-\kappa a\theta)$,
\[
P=(a^{-1}+\sum_i b_i^{-1})^{-1},\quad
\mu_P(t)=P\sum_iY_i(t)/b_i,\quad J_P=P.
\]
The hybrid action is $u_i^H=\rho\mu_P(s)+k_i[Y_i(t)-\rho Y_i(s)]$ and $J_H=\rho^2J_P+(1-\rho^2)J_L$.''',
 steps=[
step('U.1',r'Substitution into (5) gives $C_i k_i-\kappa a\bar k=a$, where $\bar k=n^{-1}\sum_i k_i$.',
     'Substitution of', ['L.4','A-U','B-G'], 'K-U: the cross-agent covariance is a and the own variance a+b_i; local histories have the same scalar temporal factor.'),
step('U.2',r'Averaging $k_i=(a+\kappa a\bar k)/C_i$ yields the displayed coefficients.',
     'Averaging $k_i=', ['U.1','A-U'], 'K-U solves bar k=a theta/(1-kappa a theta); denominator positivity follows directly from A-U.'),
step('U.3',r'The denominator is positive because $C_i>(1+\kappa)a$.',
     'The denominator is positive', ['A-U'], 'kappa a theta<kappa/(1+kappa)<1, with kappa=0 handled directly.'),
step('U.4',r'Lemma 1 certifies optimality of the local policy.',
     'Lemma~\\ref{lem:normal} then', ['U.1','U.2','U.3','L.4'], 'The feasible candidate satisfies the conditional equations under the full local histories, so nonlinear competitors are covered.'),
step('U.5',r'The quadratic term equals $a\bar k$, so $J_L=a-a\bar k$.',
     'The quadratic term equals', ['U.1','U.2','U.4','D-loss'], 'K-U: multiply each normal equation by k_i and average.'),
step('U.6',r'Gaussian conditioning gives $P$ and $\mu_P$.',
     'Gaussian conditioning gives', ['A-U','B-G'], 'K-U verifies the weighted residual is orthogonal to every sensor.'),
step('U.7',r'$X(t)-\mu_P(t)$ is independent of the entire sensor process because all temporal covariances share one factor.',
     'The residual $X(t)-', ['U.6','A-U','B-G'], 'The zero same-time cross-covariances remain zero after multiplication by the common temporal factor.'),
step('U.8',r'Innovations have covariance $(1-\rho^2)\Sigma$, where $\Sigma=a\mathbf1\mathbf1^\top+\operatorname{diag}(b_i)$.',
     'Innovations over', ['A-U','B-OU'], 'The OU innovation calculation applies entry by entry.'),
step('U.9',r'For $\mathcal G_i=\mathcal F(s)\vee\mathcal F_i(t)$, the covariance argument in (21) gives $\E[Z_j\mid\mathcal G_i]=\Sigma_{ji}Z_i/\Sigma_{ii}$.',
     'For $\\mathcal G_i=', ['U.8','A-U','B-G','B-OU'], 'K-U repeats the source covariance argument with Sigma; it treats j=i separately through Sigma_ii=a+b_i. All conditional predictors are measurable and denominators positive.'),
step('U.10',r'After subtracting $\rho\mu_P(s)$, the target has conditional mean $aZ_i/(a+b_i)$.',
     'After subtracting', ['U.6','U.7','U.8','U.9','B-CE'], 'K-U uses P(a sum_j 1/b_j+1)=a to compute the residual target projection.'),
step('U.11',r'The residual normal equations are the fresh-local equations, so $k_iZ_i$ is optimal.',
     'The residual normal equations', ['U.1','U.2','U.4','U.9','U.10','L.4'], 'K-U substitutes the full-history conditional mean of the weighted action average and verifies the normal equations directly.'),
step('U.12',r'Scaling the remaining quadratic cost by $1-\rho^2$ gives $J_H=\rho^2J_P+(1-\rho^2)J_L$.',
     'Scaling the remaining', ['U.5','U.6','U.7','U.8','U.11','D-loss'], 'K-U keeps the residual variance P fixed, scales only the sensor-dependent quadratic term, and checks feasibility in the weighted-summary hybrid.'),
step('U.13',r'Q.E.D.', 'gives the stated cost law', ['U.2','U.3','U.4','U.5','U.6','U.11','U.12'], 'All stated coefficients, posteriors, actions, and cost formulas are accounted for.',kind='STRUCTURAL')]),

dict(id='C',name='Corollary 2: Additive coordination value',label='cor:modes',eqs='(26)',
 contract=r'''There are finitely many independent components $m=1,\ldots,M$ and positive weights $w_m$. Within component $m$, the signal and all disturbances share $\lambda_m>0$. Each component has a pooled summary of age $\tau_m\ge0$. Then
\[
J_L^{\rm tot}-J_H^{\rm tot}=\sum_mw_m\Delta_m e^{-2\lambda_m\tau_m},\qquad
J_L^{\rm tot}=\sum_mw_mJ_{L,m},
\]
and each component uses the corresponding hybrid policy (15).''',
 steps=[
step('C.1',r'Other components are independent of component $m$ and its observations.',
     'For component $m$', ['A-C'], 'This is independence of complete component processes, not just same-time uncorrelatedness.'),
step('C.2',r'Averaging a policy over the other components preserves the information restrictions and cannot increase the component loss.',
     'Averaging a policy', ['C.1','B-J','D-loss','A-L2'], 'K-C: integrate the joint extraneous component data; each averaged action still depends only on that agent\'s component-m information.'),
step('C.3',r'Optimization separates across components. Apply Theorem 1 to each.',
     'Optimization therefore', ['C.2','H.3','A-C'], 'An additive lower bound is attained by the collection of componentwise optimal policies.'),
step('C.4',r'Q.E.D. Sum with the positive weights $w_m$.',
     'and sum with weights', ['C.3','A-C'], 'The sum is finite; no interchange of an infinite series and a limit is involved.',kind='STRUCTURAL')]),

dict(id='R',name='Theorem 2: Optimal refresh period',label='thm:refresh',eqs='(28)--(33)',
 contract=r'''Assume fixed finite latency $\delta\ge0$, an exact joint pooled-vector refresh with price $c>0$, and locally finite schedules independent of all signal and disturbance processes. Let $\gamma_m=2\lambda_m$, $A_m=w_m\Delta_m e^{-\gamma_m\delta}>0$,
\[
B(T)=\sum_m\frac{A_m}{\gamma_m}(1-e^{-\gamma_mT}),\qquad
c_{\rm crit}=\sum_mA_m/\gamma_m.
\]
For $c\ge c_{\rm crit}$, no refreshing minimizes the limiting upper average cost at $J_L^{\rm tot}$. For $0<c<c_{\rm crit}$, a periodic schedule is optimal among all admissible schedules. Its unique period solves $B(T^*)-T^*B'(T^*)=c$, and its cost is $J_L^{\rm tot}-\sum_m A_m e^{-\gamma_mT^*}$.''',
 steps=[
step('R.1',r'Define $V_\delta(T)=B\prime(T)=\sum_m A_m e^{-\gamma_mT}$.',
     'Put $V_\\delta(T)', ['A-R','D-refresh'], 'All sums are finite and all amplitudes and rates positive.'),
step('R.2',r'Differentiate (29): $C\prime(T)=[H(T)-c]/T^2$, where $H(T)=B(T)-TV_\delta(T)$.',
     'Differentiating', ['R.1','D-refresh','B-calc'], 'K-R: the quotient rule gives the numerator with this sign.'),
step('R.3',r'$H\prime(T)=-TV_\delta\prime(T)>0$ for $T>0$, and $H$ increases from zero to $c_{\rm crit}$.',
     'Since $H', ['R.1','R.2','A-R','B-calc'], 'K-R: T exp(-gamma T) tends to zero for gamma>0.'),
step('R.4',r'ASSUME $0<c<c_{\rm crit}$. PROVE a unique minimizing positive period and its displayed value.',
     'For $0<c<c_', ['A-R'], 'This local subproof exports the whole conditional statement.',kind='STRUCTURAL'),
step('R.4.1',r'There is a unique root $H(T^*)=c$, and $C$ decreases before it and increases after it.',
     'For $0<c<c_', ['R.2','R.3','B-calc'], 'Continuity, strict monotonicity, and the endpoint limits establish existence before the root is used.'),
step('R.4.2',r'$C(T)\to\infty$ as $T\downarrow0$ and $C(T)\to J_L^{\rm tot}$ as $T\to\infty$, proving the unique global periodic minimum.',
     'Also, $C(T)', ['R.4.1','D-refresh','A-R'], 'c>0 gives divergence at zero; B is bounded at infinity.'),
step('R.4.3',r'At the root, $c-B(T^*)=-T^*V_\delta(T^*)$, giving the optimal-cost formula.',
     'At the root,', ['R.4.1','D-refresh'], 'Tstar>0 licenses division.'),
step('R.4.4',r'Q.E.D. The below-threshold periodic claims hold.',
     'proving \\eqref{eq:optimalcost}', ['R.4.1','R.4.2','R.4.3'], 'The root and its defining assumptions remain local to R.4; the conditional conclusion is exported.',kind='STRUCTURAL'),
step('R.5',r'If $c\ge c_{\rm crit}$, then $c-B(T)\ge0$ for each finite $T$, so no periodic schedule improves on no refreshing.',
     'If $c\\ge c_', ['A-R','D-refresh'], 'In fact B(T)<ccrit for every finite T, including the price equality case.'),
step('R.6',r'Every locally finite independent schedule has average cost at least the minimum of the periodic costs and the no-refresh cost. The stated candidates attain this bound.',
     'To compare general schedules', ['A-R'], 'This parent is the all-schedules lower bound and its attainment.',kind='NORMALIZED'),
step('R.6.1',r'Define $g=\min\{0,\inf_{T>0}(c-B(T))/T\}$ and condition on a realization of the reception schedule.',
     'set $g=', ['A-R','D-refresh'], 'g is finite and nonpositive. Independence leaves the conditional sensor-process law unchanged.'),
step('R.6.2',r'Every complete interval of length $T_j$ contributes at least $gT_j$ relative to local operation when assigned one communication price.',
     'Each complete reception interval', ['R.6.1','C.4','D-refresh'], 'K-R: integrate the exact conditional age gain, yielding c-B(T_j).'),
step('R.6.3',r'The last incomplete interval contributes at least $-c_{\rm crit}$, and the initial interval before the first reception has zero gain.',
     'The last incomplete interval', ['D-refresh','A-R'], 'B(L)<=ccrit uniformly in the final interval length L; the source starts without a shared update.'),
step('R.6.4',r'Because $g\le0$, the expected total cost through time $R$, conditional on the schedule, is at least $R(J_L^{\rm tot}+g)-c_{\rm crit}$.',
     'Because $g\\le0$', ['R.6.1','R.6.2','R.6.3'], 'K-R shows the complete intervals occupy at most R, so multiplication by g reverses the length comparison.'),
step('R.6.5',r'Charging transmissions at generation preserves the bound since sent messages are at least as numerous as received messages.',
     'Charging transmissions at generation', ['R.6.4','A-R'], 'The count difference contributes a nonnegative cost.'),
step('R.6.6',r'The bound is uniform over schedules. Take expectation over the schedule, divide by $R$, and then take the limiting upper average to obtain the independent-randomized-schedule bound.',
     'The bound is uniform', ['R.6.5','A-R','B-CE'], 'K-R verifies the source explicitly takes expectation before limsup. The schedule-independent remainder vanishes after division by R.'),
step('R.6.7',r'Periodic operation at $T^*$ below the threshold, or no communication otherwise, attains the bound.',
     'Periodic operation at', ['R.4','R.5','R.6.6','D-refresh'], 'Transient latency is finite; periodic time averaging gives (29). Both candidates are admissible.'),
step('R.6.8',r'Q.E.D. The all-schedules optimum is attained by the stated candidates.',
     'attains it.', ['R.6.6','R.6.7'], 'Exports the lower bound and matching construction.',kind='STRUCTURAL'),
step('R.7',r'Q.E.D. Both price regimes and every stated policy class are covered.',
     'attains it.', ['R.4','R.5','R.6'], 'No event-triggered schedule is included in the information-independent schedule class.',kind='STRUCTURAL',support='IMPLICIT')]),
]

BACKGROUND = [
('A-G','hypothesis',r'$n\ge2$, $a,b,\lambda>0$, $\kappa\ge0$; mutually independent, stationary, mean-zero Gaussian signal and disturbances with the common exponential covariance (1).'),
('A-L2','hypothesis',r'Admissible actions and perturbations are measurable with respect to their assigned information and have finite second moment. $X\in L^2$ under (1).'),
('A-U','hypothesis',r'The A-G assumptions hold with disturbance variances $b_i>0$ and unchanged common rate. The definitions $C_i,\theta$ are those in (23).'),
('A-C','hypothesis',r'A finite number of mutually independent component processes with weights $w_m>0$, componentwise common rates $\lambda_m>0$, and ages $\tau_m\ge0$.'),
('A-R','hypothesis',r'Fixed finite latency, exact joint vectors of componentwise pooled means sampled at the same time, price $c>0$, no queueing, and schedules independent of the sensor processes. Local finiteness means finitely many transmissions in each bounded interval. The proof uses an initially unshared state.'),
('D-loss','definition',r'$\ell(u,X)=n^{-1}\sum_i(u_i-X)^2+\kappa n^{-1}\sum_i(u_i-\bar u)^2$ and $\bar u=n^{-1}\sum_i u_i$.'),
('D-Y','definition',r'$Y_i=X+E_i$ and $\bar Y=n^{-1}\sum_iY_i$.'),
('D-vd','definition',r'$v=a+b/n$ and $d=a+b[1+\kappa(1-1/n)]$.'),
('D-info','definition',r'The local, pooled, delayed-only, and hybrid information fields are exactly those in Section II-B of the letter.'),
('D-refresh','definition',r'$\gamma_m=2\lambda_m$, $A_m=w_m\Delta_m e^{-\gamma_m\delta}$, $B(T)=\sum_m A_m(1-e^{-\gamma_mT})/\gamma_m$, and $C(T)=J_L^{\rm tot}+[c-B(T)]/T$.'),
('B-G','named theorem',r'Gaussian regression and orthogonality: a jointly Gaussian residual with zero cross-covariance with every observation is independent of the observation sigma-field. For a nonsingular Gaussian observation vector, the conditional mean is its linear regression; the residual covariance is the corresponding Schur complement.'),
('B-CE','named theorem',r'Conditional expectation is the $L^2$ orthogonal projection. It minimizes mean-square error, is characterized by testing against measurable $L^2$ variables, satisfies the tower property, and is an $L^2$ contraction.'),
('B-OU','named theorem',r'For the stated stationary common-rate Gaussian process, the innovation over $[s,t]$ is independent of the past and has covariance $(1-e^{-2\lambda(t-s)})\Sigma$. Its cross-covariances are computed directly from (1).'),
('B-J','named theorem',r'Conditional Jensen: $\phi(\E[U\mid\mathcal A])\le\E[\phi(U)\mid\mathcal A]$ for an integrable vector and convex function when the expectations exist. The audit checks information feasibility separately.'),
('B-calc','algebraic/logical step',r'Finite-dimensional real algebra and order, differentiation, integration of exponentials, and the intermediate value theorem for continuous scalar functions, with signs and domains checked at each use.'),
('E-eta','proved earlier',r'The globally quantified residual statement accompanying source equation (11): $\eta(t)=X(t)-(a/v)\bar Y(t)$ is independent of the entire sensor process and has variance $P_n$. Theorem 1 explicitly cites this source result. Its covariance calculation is checked separately in K-P.'),
]

# Separate theorem audits cite earlier public results, not private descendants
# of a closed Lamport proof. The source's explicit citation to equation (11)
# is retained as the named residual dependency E-eta.
for proof in PROOFS:
    for s in proof['steps']:
        s['statement'] = s['statement'].replace(r'\prime', r'^{\prime}')
        public = []
        for dependency in s['deps']:
            if '.' in dependency and dependency.split('.')[0] != proof['id']:
                dependency = ('E-eta' if dependency == 'P.2' and proof['id'] == 'H'
                              else dependency.split('.')[0])
            if dependency not in public:
                public.append(dependency)
        s['deps'] = public
