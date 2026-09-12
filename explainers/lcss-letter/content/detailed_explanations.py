"""Worked derivations for the reading guide. Each block explains an actual inference."""
DETAILS = {}

def add(key, *steps):
    assert key not in DETAILS
    DETAILS[key] = [dict(title=title, body=body) for title, body in steps]

add('proof-L-1',
('Write the objective and the allowed change', r'''The expected team loss is
\[J(u)=\frac1n\sum_{i=1}^n\E[(u_i-X)^2+\kappa(u_i-\bar u)^2].\]
Replace every action $u_i$ by $u_i+w_i$. Feasibility means $w_i\in L^2(\mathcal G_i)$: the change uses only agent $i$’s information and has finite second moment. Define $\bar w=n^{-1}\sum_iw_i$. The new average action is $\bar u+\bar w$.'''),
('Expand the tracking square', r'''Use $(A+B)^2-A^2=2AB+B^2$ with $A=u_i-X$ and $B=w_i$:
\[(u_i+w_i-X)^2-(u_i-X)^2=2w_i(u_i-X)+w_i^2.\]
The first term is linear in the change. The second is quadratic.'''),
('Expand the disagreement square', r'''Here the change is $w_i-\bar w$, because both the individual action and its team average change:
\[\begin{aligned}
&(u_i+w_i-\bar u-\bar w)^2-(u_i-\bar u)^2\\
&=2(u_i-\bar u)(w_i-\bar w)+(w_i-\bar w)^2.
\end{aligned}\]'''),
('Cancel the term involving the average change', r'''By the definition of the average,
\[\sum_i(u_i-\bar u)=\sum_i u_i-n\bar u=0.\]
Therefore, for each realization,
\[\begin{aligned}
\sum_i(u_i-\bar u)(w_i-\bar w)
&=\sum_i(u_i-\bar u)w_i-\bar w\sum_i(u_i-\bar u)\\
&=\sum_i(u_i-\bar u)w_i.
\end{aligned}\]
This cancellation happens before taking expectation.'''),
('Collect the coefficients', r'''The coefficient multiplying $w_i$ is
\[(u_i-X)+\kappa(u_i-\bar u)=(1+\kappa)u_i-\kappa\bar u-X.\]
Write this residual as $R_i$. The exact difference is
\[J(u+w)-J(u)=\frac2n\sum_i\E[w_iR_i]+Q(w),\]
where
\[Q(w)=\frac1n\sum_i\E[w_i^2+\kappa(w_i-\bar w)^2].\]
There are no higher-order terms because the original objective is quadratic. Since $\kappa\ge0$, $Q(w)\ge0$.'''))

add('proof-L-2',
('Vary one agent at a time', r'''Let $R_i=(1+\kappa)u_i-\kappa\bar u-X$. Set all perturbations except $w_i$ to zero. The linear term vanishes for every feasible vector precisely when
\[\E[w_iR_i]=0\quad\text{for every }w_i\in L^2(\mathcal G_i),\]
for each agent separately. If these individual expectations vanish, their sum also vanishes.'''),
('Condition on the information the perturbation can use', r'''The tower property first gives
\[\E[w_iR_i]=\E\big[\E[w_iR_i\mid\mathcal G_i]\big].\]
Because $w_i$ is determined by $\mathcal G_i$, it can be pulled outside the inner conditional expectation:
\[\E[w_iR_i]=\E\big[w_i\E[R_i\mid\mathcal G_i]\big].\]
The product is integrable by Cauchy–Schwarz, since both factors have finite second moment. This conditional-expectation rule also applies to these possibly unbounded $L^2$ variables, by approximation with bounded variables.'''),
('Use the conditional residual itself as a perturbation', r'''Set $q_i=\E[R_i\mid\mathcal G_i]$. It is $\mathcal G_i$-measurable. Conditional Jensen gives
\[\E[q_i^2]\le\E[R_i^2]<\infty,\]
so $w_i=q_i$ is allowed. The vanishing condition then says
\[0=\E[q_iR_i]=\E[q_i^2].\]
A nonnegative random variable with zero expectation is zero almost surely. Hence $q_i=0$ almost surely.'''),
('Check the reverse implication', r'''If $q_i=0$ almost surely, then every feasible $w_i$ satisfies
\[\E[w_iR_i]=\E[w_iq_i]=0.\]
Thus vanishing against every permitted change and a zero conditional residual are equivalent.'''),
('Expand the conditional residual', r'''Conditional expectation is linear. Also, agent $i$ knows its own action, so $\E[u_i\mid\mathcal G_i]=u_i$. Consequently,
\[0=(1+\kappa)u_i-\kappa\E[\bar u\mid\mathcal G_i]-\E[X\mid\mathcal G_i].\]
Moving the last term to the other side gives
\[(1+\kappa)u_i-\kappa\E[\bar u\mid\mathcal G_i]=\E[X\mid\mathcal G_i].\]
The agent generally does not know $\bar u$ or $X$, which is why those two conditional expectations remain.'''),
('See why a nonzero predictable residual would help', r'''If $q_i$ were nonzero, choose $w_i=-\epsilon q_i$ with $\epsilon>0$. Its linear contribution would be $-2\epsilon\E[q_i^2]/n$, while the quadratic remainder would be proportional to $\epsilon^2$. For sufficiently small $\epsilon$, the total change would be negative. The predictable part of the residual therefore has to vanish at an optimum.'''))

add('proof-L-3',
('Use the sign of each square', r'''The remainder is
\[Q(w)=\frac1n\sum_i\E[w_i^2]+\frac\kappa n\sum_i\E[(w_i-\bar w)^2].\]
Every squared quantity is nonnegative and $\kappa\ge0$. Thus
\[Q(w)\ge\frac1n\sum_i\E[w_i^2].\]'''),
('Identify when it is strictly positive', r'''“Nonzero in $L^2$” means at least one coordinate satisfies $\E[w_i^2]>0$. The last sum is then positive. Thus $Q(w)>0$ for every genuinely different feasible policy, even if $\kappa=0$. Changes only on probability-zero events do not count as different in $L^2$.'''))

add('proof-L-4',
('Prove necessity by scaling a direction', r'''Fix any feasible $w$ and let $L(w)=2n^{-1}\sum_i\E[w_iR_i]$. The expansion gives
\[J(u+\epsilon w)-J(u)=\epsilon L(w)+\epsilon^2Q(w).\]
If $L(w)\ne0$, choose the sign of $\epsilon$ opposite to $L(w)$. For small enough nonzero $|\epsilon|$, the negative linear term dominates. An optimal $u$ must therefore have $L(w)=0$ for every direction.'''),
('Prove sufficiency for a finite change', r'''If the conditional equations hold, step L.2 makes the linear term vanish for every feasible $w$. The exact expansion becomes $J(u+w)-J(u)=Q(w)\ge0$. This covers all feasible changes, not just infinitesimal ones.'''),
('Prove uniqueness', r'''If another feasible policy $v$ were also optimal, set $w=v-u$. Then $0=J(v)-J(u)=Q(w)$. Step L.3 implies every coordinate of $w$ is zero almost surely. Hence the two optimal policies agree almost surely.'''))

add('proof-P-1',
('Compute the two covariances', r'''Fix an observation time $r\le t$ and write $q_r=e^{-\lambda(t-r)}$. Since $Y_i=X+E_i$ and the signal and disturbance are independent,
\[\Cov(X(t),Y_i(r))=a q_r,\qquad \Cov(Y_i(t),Y_i(r))=(a+b)q_r.\]'''),
('Subtract the predictable part', r'''For $\epsilon_i=X(t)-aY_i(t)/(a+b)$, linearity of covariance gives
\[\Cov(\epsilon_i,Y_i(r))=a q_r-\frac a{a+b}(a+b)q_r=0.\]
The same coefficient $a/(a+b)$ cancels the covariance for every past time $r$. That is the role of the common temporal rate.'''),
('Pass from individual observations to the history', r'''The residual and every finite vector of sensor observations are jointly Gaussian. Zero cross-covariances make the residual independent of each such vector. Cylinder events from finite vectors generate the observation sigma-field, so this independence extends to $\mathcal F_i(t)$. The residual has mean zero, hence $\E[\epsilon_i\mid\mathcal F_i(t)]=0$.'''))

add('proof-P-2',
('Work out the covariance of the average', r'''For any sensor $j$ and any time $r$, put $q_r=e^{-\lambda|t-r|}$. Among the $n$ terms in $\bar Y(t)$, one shares sensor $j$’s error and all share the signal. Therefore
\[\Cov(\bar Y(t),Y_j(r))=\frac{(a+b)+(n-1)a}{n}q_r=vq_r.\]'''),
('Cancel for every sensor and every time', r'''With $\eta(t)=X(t)-(a/v)\bar Y(t)$,
\[\Cov(\eta(t),Y_j(r))=a q_r-\frac av vq_r=0.\]
This holds even for $r>t$. Joint Gaussianity therefore makes $\eta(t)$ independent of the entire sensor process, including later observations. This strong conclusion follows from the common-rate covariance structure.'''))

add('proof-P-3',
('Recover the conditional means', r'''Write $X(t)=aY_i(t)/(a+b)+\epsilon_i$. The first term is known from the local history and the residual is independent and mean zero. Taking conditional expectation leaves $aY_i(t)/(a+b)$. The same reasoning with $X(t)=(a/v)\bar Y(t)+\eta(t)$ gives the pooled mean.'''),
('Expand the local residual variance', r'''For centered variables, $\Var(A-cB)=\Var(A)-2c\Cov(A,B)+c^2\Var(B)$. Thus
\[\begin{aligned}P_1&=a-2\frac a{a+b}a+\frac{a^2}{(a+b)^2}(a+b)\\&=a-\frac{a^2}{a+b}=\frac{ab}{a+b}.\end{aligned}\]'''),
('Repeat for the pooled residual', r'''Here $\Cov(X,\bar Y)=a$ and $\Var(\bar Y)=v$. Hence
\[P_n=a-2\frac av a+\frac{a^2}{v^2}v=a-\frac{a^2}{v}=\frac{ab}{b+na}.\]
Independence of each residual from the observations makes this its conditional variance as well as its unconditional variance.'''))

add('proof-P-4',
('Form the average action', r'''The candidate has $u_j=kY_j(t)$ for every $j$, so $\bar u=k\bar Y(t)$. We need to predict this average using only agent $i$’s sensor history.'''),
('Prove the required projection', r'''At each $r\le t$, the covariances of $\bar Y(t)$ and $Y_i(t)$ with $Y_i(r)$ are $vq_r$ and $(a+b)q_r$. The residual
\[\bar Y(t)-\frac v{a+b}Y_i(t)\]
has zero covariance with every local reading. Gaussianity makes it independent of the local history. Its conditional mean is zero.'''),
('Multiply by the policy gain', r'''It follows that
\[\E[\bar u\mid\mathcal F_i(t)]=k\E[\bar Y(t)\mid\mathcal F_i(t)]=\frac{kv}{a+b}Y_i(t).\]
This calculation conditions on the full local history, so it does not presuppose that the last reading is sufficient.'''))

add('proof-P-5',
('Insert the conditional means into Lemma 1', r'''For $u_i=kY_i(t)$, the lemma requires
\[(1+\kappa)kY_i(t)-\kappa\frac{kv}{a+b}Y_i(t)=\frac a{a+b}Y_i(t).\]
Since $Y_i(t)$ has positive variance, equality almost surely requires equality of the constant coefficients. Multiplying by $a+b$ gives $k[(1+\kappa)(a+b)-\kappa v]=a$.'''),
('Simplify the bracket without skipping terms', r'''Substitute $v=a+b/n$:
\[\begin{aligned}(1+\kappa)(a+b)-\kappa v
&=a+b+\kappa a+\kappa b-\kappa a-\kappa b/n\\
&=a+b[1+\kappa(1-1/n)]=d.
\end{aligned}\]
Thus $kd=a$ and $k=a/d$. Because $d>0$, this gain is well defined.'''))

add('proof-P-6',
('Compute tracking loss', r'''For $u_i=kY_i$,
\[\E[(kY_i-X)^2]=k^2(a+b)-2ka+a.\]
The cross term uses $\E[Y_iX]=a$. All variables are centered.'''),
('Compute disagreement loss', r'''The common signal cancels from $Y_i-\bar Y=E_i-\bar E$. Its variance is
\[b-2(b/n)+b/n=b(1-1/n).\]
Thus the disagreement contribution per agent is $\kappa k^2b(1-1/n)$.'''),
('Combine and substitute the gain', r'''Adding gives $J=a-2ak+dk^2$. At $k=a/d$,
\[J_L=a-\frac{2a^2}{d}+\frac{a^2}{d}=a-\frac{a^2}{d}.\]'''))

add('proof-P-7',
('Use the squared-error decomposition', r'''Let $m=\E[X\mid\mathcal F(t)]$. For any action $u_i$ based on the pooled information,
\[\E[(u_i-X)^2]=\E[(m-X)^2]+\E[(u_i-m)^2].\]
The cross term vanishes because $u_i-m$ is known from $\mathcal F(t)$ and $\E[m-X\mid\mathcal F(t)]=0$. Thus tracking loss is at least $P_n$ for every agent.'''),
('Attain both lower bounds together', r'''Set every action to $m=(a/v)\bar Y(t)$. Each tracking loss is $P_n$, and $u_i-\bar u=0$ for every agent. The disagreement penalty reaches its lower bound of zero. Hence the total minimum is $J_P=P_n$.'''))

add('proof-P-8',
('Verify the full admissible class is covered', r'''The candidate local action is measurable from $\mathcal F_i(t)$ and has finite second moment. Steps P.4–P.5 checked the conditional equations using that entire field. Lemma 1 therefore certifies optimality among all feasible history-dependent policies, including nonlinear ones.'''),
('Check the pooled candidate in the same equations', r'''For common $m=\E[X\mid\mathcal F(t)]$, $u_i=\bar u=m$. The left side of Lemma 1 is $(1+\kappa)m-\kappa m=m$, exactly its right side. The uniqueness part of the lemma applies to both architectures.'''))

add('proof-P-9',
('Subtract the denominators', r'''Using their definitions,
\[\begin{aligned}d-v&=b-b/n+\kappa b(1-1/n)\\&=b(1+\kappa)(1-1/n)>0.\end{aligned}\]
All factors are positive because $b>0$, $\kappa\ge0$, and $n\ge2$.'''),
('Subtract the optimized losses', r'''The $a$ terms cancel:
\[\Delta=(a-a^2/d)-(a-a^2/v)=a^2\left(\frac1v-\frac1d\right)=\frac{a^2(d-v)}{vd}>0.\]
Both denominators are positive. Fresh pooling therefore strictly improves the optimum in this nondegenerate model.'''))

add('proof-P-10',
('Match the proof to each claim', r'''Steps P.1–P.3 established the conditional means and variances for full histories. P.4–P.8 gave feasible policies, verified optimality, and evaluated their losses. P.9 established the positive difference $\Delta$. These are all the quantities asserted in Proposition 1.'''),
('Keep estimation and team optimization distinct', r'''The local conditional mean uses gain $a/(a+b)$, while the local team policy uses $a/d$. They coincide when $\kappa=0$. The pooled policy is a common conditional mean, so its team cost equals its estimation-error variance.'''))

add('proof-D-1',
('Predict the signal from its old state', r'''Write $X(t)=\rho X(s)+\xi$ with $\rho=e^{-\lambda(t-s)}$. The OU innovation $\xi$ is mean zero and independent of all signal and sensor data through $s$. Hence $\E[\xi\mid\mathcal F(s)]=0$.'''),
('Condition on the actual shared observations', r'''The old state $X(s)$ is unobserved. Proposition 1 says its conditional mean is $(a/v)\bar Y(s)$. By linearity,
\[\E[X(t)\mid\mathcal F(s)]=\rho\E[X(s)\mid\mathcal F(s)]=\rho\frac av\bar Y(s).\]'''))

add('proof-D-2',
('Bound each tracking term', r'''With $m_D=\E[X(t)\mid\mathcal F(s)]$, every allowed action satisfies
\[\E[(u_i-X(t))^2]=\E[(m_D-X(t))^2]+\E[(u_i-m_D)^2].\]
The cross term is zero by conditioning on $\mathcal F(s)$. Therefore no agent can beat the first term using delayed information alone.'''),
('Make disagreement vanish', r'''All agents possess the same information. They can all choose $u_i=m_D$, attaining that tracking lower bound simultaneously. Their actions then agree exactly, so the additional nonnegative disagreement cost is zero. This proves optimality for the team.'''))

add('proof-D-3',
('Separate old estimation error from new signal uncertainty', r'''Subtract $m_D=\rho(a/v)\bar Y(s)$ from $X(t)=\rho X(s)+\xi$:
\[X(t)-m_D=\rho\left[X(s)-\frac av\bar Y(s)\right]+\xi.\]
The bracket has variance $P_n$, and $\xi$ is independent of it with variance $a(1-\rho^2)$.'''),
('Add the independent variances', r'''Thus
\[\begin{aligned}J_D&=\rho^2P_n+a(1-\rho^2)\\&=\rho^2(a-a^2/v)+a-a\rho^2\\&=a-\frac{a^2}{v}\rho^2.
\end{aligned}\]
Finally $\rho^2=e^{-2\lambda\tau}$ gives the displayed formula.'''))

add('proof-D-4',
('Subtract local cost from delayed-only cost', r'''Using the two optimized losses,
\[J_D-J_L=a^2\left(\frac1d-\frac{\rho^2}{v}\right).\]
Local operation is better exactly when this difference is positive.'''),
('Multiply only by positive quantities', r'''Since $a^2,d,v>0$,
\[J_D-J_L>0\ \Longleftrightarrow\ v-d\rho^2>0\ \Longleftrightarrow\ \rho^2<\frac vd.\]
No inequality reverses in these multiplications. Substituting $\rho^2=e^{-2\lambda\tau}$ yields the claim.'''))

add('proof-D-5',
('Take the logarithm', r'''Both sides of $e^{-2\lambda\tau}<v/d$ are positive. Logarithm is strictly increasing, so
\[-2\lambda\tau<\log(v/d)=-\log(d/v).\]'''),
('Reverse the inequality when dividing by a negative number', r'''Since $-2\lambda<0$, division reverses the sign:
\[\tau>\frac{\log(d/v)}{2\lambda}.\]
Repeating with equality gives $J_L=J_D$ at that age. Because $d>v$, the threshold is strictly positive.'''))

add('proof-D-6',
('Check the two endpoints', r'''At age zero, $J_D(0)=J_P<J_L$. At arbitrarily large age, $J_D(\tau)\to a>J_L$. The delayed-only loss is strictly increasing because $J_D'(\tau)=2\lambda a^2e^{-2\lambda\tau}/v>0$. Thus the derived equality is the only crossover.'''),
('Identify the compared information sets', r'''The delayed-only agents have all sensor data through $s$, with no readings after $s$. Local agents have their own readings through $t$. Neither set contains the other, so a change in which optimum is smaller is compatible with the rule that adding information cannot increase minimum loss.'''))

add('proof-H-1',
('Substitute zero age into the action', r'''At $\tau=0$, $s=t$ and $\rho=1$. Thus $Y_i(t)-\rho Y_i(s)=0$, leaving $u_i^H=(a/v)\bar Y(t)$, the fresh pooled optimum.'''),
('Check the claimed costs', r'''The weights become $\rho^2=1$ and $1-\rho^2=0$. The theorem therefore states $J_H=J_P$ and $P_H=P_n$, both already proved. Treating this case separately avoids division by a zero innovation variance later.'''))

add('proof-H-2',
('Record what positive age guarantees', r'''With $\tau>0$ and $\lambda>0$, $0<\rho<1$. Therefore $1-\rho^2>0$, so the new sensor innovations have nonzero variance. We may safely use their covariance ratios.'''),
('State what still needs proving', r'''We must verify the proposed action against full delayed sharing and full local history, show that the smaller hybrid information can implement it, and compute its posterior variance and team cost. Proving only an endpoint regression would not establish the full-history claim.'''))

add('proof-H-2-1',
('Compare the two feasible policy classes', r'''The hybrid agent knows the old shared mean and its own relevant readings. The enlarged field $\mathcal G_i=\mathcal F(s)\vee\mathcal F_i(t)$ includes every sensor’s history through $s$ and agent $i$’s history through $t$. It contains the hybrid information, so its minimum cost is a lower bound on hybrid minimum cost.'''),
('Remove what the old local reading predicts', r'''Define $Z_i=Y_i(t)-\rho Y_i(s)$. The old local reading predicts the fraction $\rho Y_i(s)$ of the new reading. The remainder $Z_i$ is the new innovation. Write $h=a/v$ for the pooled gain and $k=a/d$ for the local gain. The candidate is $u_i=m+kZ_i$ with common prediction $m=\rho h\bar Y(s)$.'''),
('Explain the strategy for proving equality of values', r'''If this candidate is optimal for the enlarged fields and is also feasible for the smaller hybrid fields, the hybrid can attain the lower bound. The two minimum costs must then coincide. This argument requires checking the enlarged-field normal equations first.'''))

add('proof-H-2-2',
('Decompose signal and sensor errors separately', r'''Write $X(t)=\rho X(s)+\xi$ and $E_i(t)=\rho E_i(s)+\epsilon_i$. Their innovations are independent of the joint past, and $\xi,\epsilon_1,\ldots,\epsilon_n$ are mutually independent. Then
\[Z_i=\xi+\epsilon_i,\quad \Var(\xi)=a(1-\rho^2),\quad\Var(\epsilon_i)=b(1-\rho^2).\]'''),
('Compute diagonal and off-diagonal entries', r'''For $i=j$, $\Var(Z_i)=(a+b)(1-\rho^2)$. For $i\ne j$, only the shared innovation $\xi$ contributes to covariance, giving $a(1-\rho^2)$. The covariance matrix is therefore $(1-\rho^2)(a\mathbf1\mathbf1^\top+bI)$. The whole vector is independent of $\mathcal F(s)$ because its underlying innovations are independent of the joint past.'''))

add('proof-H-2-3',
('Start with the pooled residual identity', r'''Proposition 1 defines $\eta(t)=X(t)-h\bar Y(t)$, where $h=a/v$. Rearranging gives $X(t)=h\bar Y(t)+\eta(t)$. Its residual is independent of every sensor observation and has variance $P_n$.'''),
('Average the innovation identities', r'''From $Y_i(t)=\rho Y_i(s)+Z_i$, averaging gives $\bar Y(t)=\rho\bar Y(s)+\bar Z$. Substitution yields
\[X(t)=\underbrace{\rho h\bar Y(s)}_{m}+h\bar Z+\eta(t).\]
The first term is common and known. The second is new information spread across sensors. The last is error that even the full sensor process cannot reveal in this model.'''))

add('proof-H-2-4',
('Represent every intermediate local observation', r'''For $s<r\le t$, set $Z_i(r)=Y_i(r)-e^{-\lambda(r-s)}Y_i(s)$. Given $\mathcal F(s)$, knowing these innovations is equivalent to knowing the local observations after $s$. We must predict $\bar Z$ from this whole path.'''),
('Use the common temporal factor', r'''Let $f(r)=e^{-\lambda(t-r)}(1-e^{-2\lambda(r-s)})$. The next step derives this factor explicitly. Covariances then have the form
\[\Cov(Z_j(t),Z_i(r))=\begin{cases}(a+b)f(r),&j=i,\\af(r),&j\ne i.\end{cases}\]'''),
('Average over the terminal sensor index', r'''Thus $\Cov(\bar Z,Z_i(r))=[(a+b)+(n-1)a]f(r)/n=vf(r)$, whereas $\Cov(Z_i,Z_i(r))=(a+b)f(r)$. Multiplication of the latter by $v/(a+b)$ gives the former. Crucially, this multiplier is independent of $r$.'''))

add('proof-H-2-5',
('Expand the covariance into four terms', r'''Let $\Sigma_{ji}=\Cov(Y_j(s),Y_i(s))$, $\alpha=e^{-\lambda(r-s)}$, and $\beta=e^{-\lambda(t-r)}$, so $\rho=\alpha\beta$. Bilinearity gives
\[\begin{aligned}
&\Cov(Y_j(t)-\rho Y_j(s),Y_i(r)-\alpha Y_i(s))\\
&=\Sigma_{ji}\big[\beta-\alpha\rho-\rho\alpha+\rho\alpha\big].
\end{aligned}\]
The four terms come from current–intermediate, current–old, old–intermediate, and old–old covariances, in that order.'''),
('Factor the remaining expression', r'''The bracket is $\beta-\alpha\rho=\beta-\alpha^2\beta=\beta(1-\alpha^2)$. Therefore
\[\Cov(Z_j(t),Z_i(r))=\Sigma_{ji}e^{-\lambda(t-r)}(1-e^{-2\lambda(r-s)}).\]
Only the spatial coefficient $\Sigma_{ji}$ changes with sensor indices. The time dependence is shared.'''))

add('proof-H-2-6',
('Form the candidate projection residual', r'''Set $W=\bar Z-vZ_i/(a+b)$. For every $s<r\le t$, step H.2.4 gives
\[\Cov(W,Z_i(r))=vf(r)-\frac v{a+b}(a+b)f(r)=0.\]
The same $W$ is uncorrelated with every variable on the local innovation path.'''),
('Include all old sensor observations', r'''The terminal innovation vector is independent of $\mathcal F(s)$, so its linear combination $W$ has zero covariance with each old sensor observation as well. Since $Y_i(r)=e^{-\lambda(r-s)}Y_i(s)+Z_i(r)$, the old data and the innovation path together generate $\mathcal G_i$. We have checked every generator used in the enlarged information field.'''))

add('proof-H-2-7',
('Turn the covariance check into independence', r'''The residual $W$ and every finite set of old readings and local-path innovations are jointly Gaussian. Their zero cross-covariances make them independent. This extends to the sigma-field generated by all such observations, namely $\mathcal G_i$. Therefore $\E[W\mid\mathcal G_i]=0$.'''),
('Keep the observable part of the decomposition', r'''The endpoint innovation $Z_i$ is known to agent $i$. In the identity $\bar Z=vZ_i/(a+b)+W$, take conditional expectation to get
\[\E[\bar Z\mid\mathcal G_i]=\frac v{a+b}Z_i.\]
Intermediate readings do not add predictive power for this target because their covariances with the residual all vanish.'''))

add('proof-H-2-8',
('Predict the signal correction', r'''The residual $\eta(t)$ is independent of all sensor data and centered, so its conditional mean under $\mathcal G_i$ is zero. Then
\[\E[h\bar Z+\eta(t)\mid\mathcal G_i]=h\frac v{a+b}Z_i=\frac a{a+b}Z_i,\]
using $hv=a$.'''),
('Predict the average action correction', r'''The proposed corrections are $kZ_j$, so their average is $k\bar Z$. Linearity and step H.2.7 yield
\[\E[k\bar Z\mid\mathcal G_i]=\frac{kv}{a+b}Z_i.\]
Consequently $\E[X(t)\mid\mathcal G_i]=m+aZ_i/(a+b)$ and $\E[\bar u\mid\mathcal G_i]=m+kvZ_i/(a+b)$, where $m=\rho h\bar Y(s)$.'''))

add('proof-H-2-9',
('Insert both terms of the proposed action', r'''For $u_i=m+kZ_i$, the left side of Lemma 1 becomes
\[\begin{aligned}(1+\kappa)u_i-\kappa\E[\bar u\mid\mathcal G_i]
&=(1+\kappa)(m+kZ_i)-\kappa\left(m+\frac{kv}{a+b}Z_i\right)\\
&=m+\frac{k[(1+\kappa)(a+b)-\kappa v]}{a+b}Z_i.
\end{aligned}\]'''),
('Reduce to the already solved gain equation', r'''The bracket equals $d$, and $k=a/d$. The expression is therefore $m+aZ_i/(a+b)$, exactly $\E[X(t)\mid\mathcal G_i]$ from the previous step. The normal equations hold for every agent.'''),
('Apply the sufficiency part of the lemma', r'''The action is measurable from $\mathcal G_i$ and square integrable. Lemma 1 now certifies its unique optimality among all policies using complete delayed sensor sharing and full local histories. No linearity restriction has been imposed on competing policies.'''))

add('proof-H-2-10',
('List what the optimal policy actually uses', r'''The action $\rho(a/v)\bar Y(s)+(a/d)[Y_i(t)-\rho Y_i(s)]$ uses the old shared mean, the stored own-sensor reading from $s$, and the current own-sensor reading. All three are available under the hybrid information structure.'''),
('Write the two bounding inequalities', r'''Let $J_{\rm full}$ be the minimum with $\mathcal F(s)\vee\mathcal F_i(t)$. Information inclusion gives $J_{\rm full}\le J_H$. The candidate is hybrid-feasible and has cost $J_{\rm full}$, so $J_H\le J_{\rm full}$. Hence $J_H=J_{\rm full}$.'''),
('Clarify where the fresh reading enters the comparison', r'''Both sides of this equality give each agent its fresh local reading and its own history. “Complete delayed sharing” adds all old raw sensor data to that same fresh local information. The theorem says that replacing those old raw data by their scalar mean loses no decision value here. It does not compare the hybrid with the delayed-only architecture, which lacks fresh local readings.'''))

add('proof-H-2-11',
('Cancel the common prediction in the errors', r'''With $u_i=m+kZ_i$ and $X=m+h\bar Z+\eta$,
\[u_i-X=kZ_i-h\bar Z-\eta,\qquad u_i-\bar u=k(Z_i-\bar Z).\]
The old shared prediction disappears from both expressions.'''),
('Separate the irreducible residual variance', r'''The residual $\eta$ is centered and independent of $Z$, so its cross terms with $kZ_i-h\bar Z$ have zero expectation. Each tracking term contributes $P_n$ plus $\E[(kZ_i-h\bar Z)^2]$. Averaging over agents still gives one $P_n$.'''),
('Scale each remaining quadratic expectation', r'''The covariance of $Z$ is $(1-\rho^2)$ times the covariance of the fresh sensor vector $Y$. For any fixed coefficient vector $c$, $\E[(c^\top Z)^2]=c^\top\Cov(Z)c$, so every remaining quadratic term scales by $1-\rho^2$.

In the fresh problem, the same decomposition $X=h\bar Y+\eta$ gives $J_L=P_n+$ those remaining quadratic terms. Their sum for $Z$ is therefore $(1-\rho^2)(J_L-P_n)$.'''),
('Rewrite as the two endpoint costs', r'''Consequently
\[J_H=P_n+(1-\rho^2)(J_L-P_n)=\rho^2J_P+(1-\rho^2)J_L,\]
because $P_n=J_P$. This explains exactly why the old-sharing contribution is weighted by the square of correlation.'''))

add('proof-H-2-12',
('Use the full-information conditional mean', r'''Step H.2.8 established $\widehat X=m+aZ_i/(a+b)$. This estimator uses only the three hybrid quantities, so the enlarged-field optimum for squared estimation error is attainable in the smaller field too.'''),
('Write its error and remove cross terms', r'''The error is
\[X-\widehat X=h\bar Z-\frac a{a+b}Z_i+\eta.\]
The first two terms are linear in sensor innovations and independent of $\eta$. Their variance scales by $1-\rho^2$.'''),
('Identify the fresh counterpart', r'''For a fresh local estimate,
\[X-\frac a{a+b}Y_i=h\bar Y-\frac a{a+b}Y_i+\eta.\]
Its variance is $P_1$, of which $P_n$ comes from $\eta$. Thus the fresh linear part has variance $P_1-P_n$. The hybrid error variance is
\[P_H=P_n+(1-\rho^2)(P_1-P_n)=\rho^2P_n+(1-\rho^2)P_1.\]
Gaussian projection also makes this residual independent of the enlarged information, so this is the conditional posterior variance.'''))

add('proof-H-2-13',
('Subtract the interpolation formula', r'''From $J_H=\rho^2J_P+(1-\rho^2)J_L$,
\[\begin{aligned}J_L-J_H&=J_L-\rho^2J_P-J_L+\rho^2J_L\\&=\rho^2(J_L-J_P)=\rho^2\Delta.\end{aligned}\]'''),
('Substitute the temporal correlation', r'''Since $\rho=e^{-\lambda\tau}$, the gain is $\Delta e^{-2\lambda\tau}$. At every finite age it is strictly positive because $\Delta>0$ and the exponential is positive. It tends to zero as age tends to infinity.'''))

add('proof-H-2-14',
('Check each obligation in the positive-age case', r'''H.2.9 certifies the full-history optimum. H.2.10 proves the smaller hybrid field attains it. H.2.11 computes team loss, H.2.12 computes posterior variance, and H.2.13 computes the gain over local operation. Together these establish every assertion for $\tau>0$.'''),
('Keep the two types of gains distinct', r'''The posterior mean uses the correction coefficient $a/(a+b)$. The team-optimal action uses $a/d$. The latter also accounts for disagreement. The proof establishes both results without conflating estimation error with team loss.'''))

add('proof-H-3',
('Combine the two cases', r'''Every allowed age satisfies either $\tau=0$ or $\tau>0$. H.1 handles zero age directly. The positive-age proof supplies the action, optimality, posterior variance, and loss for all other ages. Therefore no allowed finite age is omitted.'''),
('Check consistency at the boundary', r'''As $\tau\downarrow0$, $\rho\to1$ and $\Var(Z_i)=(a+b)(1-\rho^2)\to0$. The innovation correction vanishes in mean square, and the cost formulas converge to $J_P$ and $P_n$, agreeing with the direct zero-age calculation.'''))

add('proof-U-1',
('Predict the other local actions', r'''Consider $u_j=k_jY_j(t)$ and $\bar k=n^{-1}\sum_jk_j$. For $j\ne i$, the common-rate covariance argument gives $\E[Y_j(t)\mid\mathcal F_i(t)]=aY_i(t)/(a+b_i)$. For $j=i$, the reading itself is known. Thus
\[\E[\bar u\mid\mathcal F_i(t)]=\frac{a\bar k+b_i k_i/n}{a+b_i}Y_i(t).\]'''),
('Insert into the conditional normal equation', r'''The conditional target mean is $aY_i(t)/(a+b_i)$. Multiply the normal equation by $a+b_i$ and equate the coefficients of $Y_i(t)$:
\[(1+\kappa)(a+b_i)k_i-\kappa(a\bar k+b_i k_i/n)=a.\]'''),
('Collect the terms multiplying the individual gain', r'''The coefficient of $k_i$ becomes $(1+\kappa)a+b_i(1+\kappa-\kappa/n)=C_i$. The remaining coupling term is $-\kappa a\bar k$. Hence $C_i k_i-\kappa a\bar k=a$.'''))

add('proof-U-2',
('Solve each equation in terms of the mean gain', r'''From $C_i k_i=a+\kappa a\bar k$, divide by $C_i>0$:
\[k_i=\frac{a+\kappa a\bar k}{C_i}.\]
The numerator is the same for every sensor.'''),
('Average and solve the single scalar equation', r'''Averaging over $i$ gives $\bar k=(a+\kappa a\bar k)\theta$. Rearrange:
\[(1-\kappa a\theta)\bar k=a\theta,\qquad \bar k=\frac{a\theta}{1-\kappa a\theta}.\]
The next step verifies positivity of this denominator.'''),
('Substitute the mean gain back', r'''Now
\[a+\kappa a\bar k=a+\frac{\kappa a^2\theta}{1-\kappa a\theta}=\frac a{1-\kappa a\theta}.\]
Dividing by $C_i$ yields $k_i=a/[C_i(1-\kappa a\theta)]$.'''))

add('proof-U-3',
('Bound the average reciprocal', r'''Because $b_i>0$ and $1+\kappa(1-1/n)>0$, $C_i>(1+\kappa)a$. Reciprocals reverse this inequality:
\[\frac1{C_i}<\frac1{(1+\kappa)a},\qquad \theta<\frac1{(1+\kappa)a}.\]'''),
('Handle zero and positive disagreement prices', r'''If $\kappa=0$, the denominator is exactly 1. If $\kappa>0$, multiplication of the previous strict inequality gives $\kappa a\theta<\kappa/(1+\kappa)<1$. In either case $1-\kappa a\theta>0$. Thus the gains are finite and well defined.'''))

add('proof-U-4',
('Verify admissibility', r'''Each $k_i$ is a finite deterministic constant and $Y_i(t)$ has finite variance $a+b_i$. Hence $k_iY_i(t)$ is in $L^2(\mathcal F_i(t))$.'''),
('Apply the optimality test already established', r'''Steps U.1–U.3 solve the conditional normal equations for the entire local information fields. Lemma 1 then certifies the policy’s optimality and uniqueness among all feasible policies. Testing a linear candidate did not restrict the optimization to linear policies.'''))

add('proof-U-5',
('Separate the objective into constant, linear, and quadratic parts', r'''For $u_i=k_iY_i$, let
\[Q(u)=\frac1n\sum_i\E[u_i^2+\kappa(u_i-\bar u)^2].\]
Because $\E[u_iX]=ak_i$, expansion of tracking loss gives $J(u)=a-2a\bar k+Q(u)$.'''),
('Use the normal equations to evaluate the quadratic part', r'''Multiply each normal equation by $u_i$ and take expectation. The conditioning can be removed because $u_i$ is measurable from the agent’s information. Average over $i$:
\[\frac{1+\kappa}{n}\sum_i\E[u_i^2]-\kappa\E[\bar u^2]=a\bar k.\]
Here $n^{-1}\sum_i u_i\bar u=\bar u^2$. Also $n^{-1}\sum_i(u_i-\bar u)^2=n^{-1}\sum_i u_i^2-\bar u^2$. The left side is exactly $Q(u)$.'''),
('Substitute and simplify', r'''Thus $Q(u)=a\bar k$ and
\[J_L=a-2a\bar k+a\bar k=a-a\bar k=a-\frac{a^2\theta}{1-\kappa a\theta}.\]'''))

add('proof-U-6',
('Write the Gaussian posterior at one time', r'''Given sensor values $y_1,\ldots,y_n$, the posterior density for the common signal is proportional to
\[\exp\left[-\frac12\left(\frac{x^2}{a}+\sum_i\frac{(y_i-x)^2}{b_i}\right)\right].\]
The prior contributes $x^2/a$. Independent sensor errors contribute one squared residual per sensor.'''),
('Collect and complete the square in x', r'''The terms involving $x$ are
\[x^2\left(a^{-1}+\sum_i b_i^{-1}\right)-2x\sum_i y_i/b_i.
\]
Set $P=(a^{-1}+\sum_i b_i^{-1})^{-1}$ and $\mu=P\sum_i y_i/b_i$. The expression is $(x-\mu)^2/P$ plus a term independent of $x$. Thus the posterior is Gaussian with mean $\mu_P$ and variance $P$.'''),
('Connect to team loss and histories', r'''All agents can choose the common mean and have zero disagreement, so endpoint pooling has loss $P$. The next step proves that the entire sensor history adds no further information beyond this weighted endpoint summary.'''))

add('proof-U-7',
('Calculate the weighted mean covariance', r'''Let $S=\sum_i b_i^{-1}$ and $q_r=e^{-\lambda|t-r|}$. Since $\Cov(Y_i(t),Y_j(r))=(a+b_j\mathbf1_{i=j})q_r$,
\[\Cov(\mu_P(t),Y_j(r))=P(aS+1)q_r=a q_r,\]
where $P(a^{-1}+S)=1$ implies $P(1+aS)=a$.'''),
('Subtract from the signal covariance', r'''Since $\Cov(X(t),Y_j(r))=a q_r$, the residual $X(t)-\mu_P(t)$ has zero covariance with every sensor at every time. Joint Gaussianity makes it independent of the full sensor process. Its variance remains $P$, proving the full-history pooled result.'''))

add('proof-U-8',
('Write the innovations with individual noise variances', r'''As before, $Z_i=\xi+\epsilon_i$, with mutually independent driving innovations. Now $\Var(\epsilon_i)=b_i(1-\rho^2)$, whereas $\Var(\xi)=a(1-\rho^2)$.'''),
('Assemble the covariance matrix', r'''Diagonal entries are $(a+b_i)(1-\rho^2)$ and off-diagonal entries are $a(1-\rho^2)$. Factoring out the common multiplier gives
\[\Cov(Z)=(1-\rho^2)\Sigma,\quad\Sigma=a\mathbf1\mathbf1^\top+\operatorname{diag}(b_i).\]
The vector remains independent of all pre-$s$ sensor data.'''))

add('proof-U-9',
('Use the same path calculation with new spatial coefficients', r'''For every $s<r\le t$, the four-term covariance expansion gives
\[\Cov(Z_j(t),Z_i(r))=\Sigma_{ji}f(r),\qquad\Cov(Z_i(t),Z_i(r))=\Sigma_{ii}f(r),\]
where $f(r)=e^{-\lambda(t-r)}(1-e^{-2\lambda(r-s)})$.'''),
('Remove the part predictable from the own-sensor endpoint', r'''The residual $Z_j-(\Sigma_{ji}/\Sigma_{ii})Z_i$ is uncorrelated with every local path innovation. It is also independent of old sensor data. By joint Gaussianity its conditional mean given $\mathcal G_i$ is zero. Therefore
\[\E[Z_j\mid\mathcal G_i]=\frac{\Sigma_{ji}}{\Sigma_{ii}}Z_i.\]
For $j=i$ the ratio is 1, and for $j\ne i$ it is $a/(a+b_i)$.'''))

add('proof-U-10',
('Separate the old weighted prediction', r'''Linearity of the pooled estimator gives
\[X(t)=\rho\mu_P(s)+P\sum_j Z_j/b_j+\eta(t),\]
where $\eta$ is the pooled residual independent of all sensor data. The old prediction $\rho\mu_P(s)$ is known in common.'''),
('Condition the remaining target', r'''Using U.9 and $\E[\eta\mid\mathcal G_i]=0$,
\[\E\left[P\sum_jZ_j/b_j+\eta\mid\mathcal G_i\right]
=\frac{P\sum_j\Sigma_{ji}/b_j}{a+b_i}Z_i.
\]
The numerator is $P(aS+1)=a$. Thus the target correction has conditional mean $aZ_i/(a+b_i)$, exactly the fresh local regression coefficient.'''))

add('proof-U-11',
('Compute the average correction conditional on agent i', r'''For corrections $k_jZ_j$, step U.9 gives
\[\E\left[\frac1n\sum_jk_jZ_j\mid\mathcal G_i\right]=\frac{a\bar k+b_i k_i/n}{a+b_i}Z_i.\]'''),
('Cancel the common prediction in the normal equations', r'''Write $m=\rho\mu_P(s)$. Inserting $u_i=m+k_iZ_i$ into Lemma 1 leaves the coefficient equation
\[(1+\kappa)(a+b_i)k_i-\kappa(a\bar k+b_i k_i/n)=a.\]
This is exactly $C_i k_i-\kappa a\bar k=a$, solved in U.1–U.3. The lemma certifies the full-information optimum. The action uses only the old weighted summary and the two own-sensor readings, so it is also hybrid-feasible.'''))

add('proof-U-12',
('Separate the irreducible variance', r'''Subtracting the common prediction leaves a linear function of $Z$ plus the independent residual $\eta$, whose variance is $P=J_P$. The residual contributes $P$ to the average tracking loss and has no cross terms with the sensor innovations.'''),
('Scale the remaining quadratic expression', r'''All remaining tracking and disagreement terms are quadratic in $Z$. Since $\Cov(Z)=(1-\rho^2)\Sigma$, their sum is $(1-\rho^2)$ times the fresh counterpart, which equals $J_L-P$. Hence
\[J_H=P+(1-\rho^2)(J_L-P)=\rho^2J_P+(1-\rho^2)J_L.\]'''))

add('proof-U-13',
('Verify the equal-quality limit', r'''If every $b_i=b$, then $C_i=d+\kappa a$, so $\theta=1/(d+\kappa a)$. Substitution gives $k_i=a/d$. Also $P=(a^{-1}+n/b)^{-1}=P_n$ and $\mu_P=(a/v)\bar Y$. Thus the unequal-quality expressions reduce to the original formulas.'''),
('List the established parts', r'''The coupled local gains and their admissibility were proved in U.1–U.4, their cost in U.5, and the full-history pooled result in U.6–U.7. U.8–U.12 established hybrid optimality and its cost law under the same common-rate assumption.'''))

add('proof-C-1',
('Specify what independence includes', r'''A component contains its signal, all of its sensor disturbances, and the observations they generate over time. The model assumes these entire collections are independent across components. Thus observations of component $j\ne m$ do not change the conditional distribution of component $m$ given its own observations.'''),
('Identify the possible extra role of other observations', r'''An agent could still use unrelated component observations to randomize its action for $m$. Different agents could even share some of that randomness. The next step proves such randomization cannot improve this convex component objective.'''))

add('proof-C-2',
('Average out the unrelated processes', r'''Fix the entire realization of component $m$ and integrate a proposed action vector for $m$ over all the other component processes. Denote the resulting vector by $\widetilde u_m$. By independence, the distribution being integrated does not depend on the fixed component-$m$ realization.'''),
('Check that each averaged action is still feasible', r'''The original action of agent $i$ only uses its allowed component-$m$ observations and its allowed other-component observations. Integrating out the latter leaves a function of the former. It does not reveal any new component-$m$ observation. Jensen also gives $\E[\widetilde u_{im}^2]\le\E[u_{im}^2]$, so square integrability is preserved.'''),
('Apply convexity to the whole action vector', r'''For fixed $X_m$, the component loss is a sum of squares of affine functions of the action vector, with nonnegative coefficients. It is therefore convex. Jensen’s inequality gives
\[\ell_m(\widetilde u_m,X_m)\le\E_{-m}[\ell_m(u_m,X_m)],\]
where $\E_{-m}$ averages over the other components. Averaging this inequality over component $m$ proves that removing the extraneous randomness cannot increase expected loss.'''))

add('proof-C-3',
('Bound each component separately', r'''By C.2, allowing observations from other independent components cannot beat the optimum using only component $m$’s permitted information. Thus every joint policy has component loss at least $J_{H,m}$.'''),
('Attain all component bounds at once', r'''The total loss is $\sum_m w_mJ_m$, and there are no cross-component constraints on the actions. Choose each component’s hybrid optimum simultaneously. This attains $\sum_m w_mJ_{H,m}$. Theorem 1 gives
\[J_{H,m}=J_{L,m}-\Delta_m e^{-2\lambda_m\tau_m}.\]'''))

add('proof-C-4',
('Subtract the weighted totals', r'''Since the finite sum separates,
\[\begin{aligned}J_L^{\rm tot}-J_H^{\rm tot}
&=\sum_m w_m(J_{L,m}-J_{H,m})\\
&=\sum_m w_m\Delta_m e^{-2\lambda_m\tau_m}.
\end{aligned}\]
Positive weights preserve each lower-bound inequality used in the proof.'''),
('State where rates may differ', r'''The formula allows different $\lambda_m$ across components and different summary ages $\tau_m$. Within each component, the signal and its sensor disturbances still share a single rate. This is what justified the componentwise use of Theorem 1.'''))

add('proof-R-1',
('Interpret the elapsed time after reception', r'''An update is already $\delta$ old on arrival. After another $T$ units of time, its component-$m$ benefit is
\[w_m\Delta_m e^{-\gamma_m(\delta+T)}=A_m e^{-\gamma_mT}.\]
Sum these terms to get the instantaneous total benefit $V_\delta(T)$.'''),
('Differentiate the accumulated benefit', r'''For each component,
\[\frac{d}{dT}\left[\frac{A_m}{\gamma_m}(1-e^{-\gamma_mT})\right]=A_m e^{-\gamma_mT}.\]
There are finitely many terms, so differentiation commutes with summation and $B'(T)=\sum_m A_m e^{-\gamma_mT}=V_\delta(T)$.'''))

add('proof-R-2',
('Apply the quotient rule carefully', r'''The constant baseline $J_L^{\rm tot}$ has derivative zero. For the other term,
\[\frac{d}{dT}\frac{c-B(T)}{T}=\frac{-B'(T)T-[c-B(T)]}{T^2}.\]
The minus sign in front of the bracket comes from differentiating the denominator.'''),
('Collect the numerator into H', r'''The numerator is $B(T)-TB'(T)-c$. Set $H(T)=B(T)-TV_\delta(T)$ and use $B'=V_\delta$. Then
\[C'(T)=\frac{H(T)-c}{T^2}.\]
Since $T^2>0$, the sign of $C'$ is exactly the sign of $H-c$.'''))

add('proof-R-3',
('Differentiate using the product rule', r'''From $H=B-TV_\delta$,
\[H'=B'-V_\delta-TV_\delta'=-TV_\delta',\]
because $B'=V_\delta$. Also
\[V_\delta'(T)=-\sum_m\gamma_m A_m e^{-\gamma_mT}.\]
Thus $H'(T)=T\sum_m\gamma_m A_m e^{-\gamma_mT}>0$ for every $T>0$. Every factor in every summand is positive.'''),
('Evaluate the endpoint values explicitly', r'''Substituting $B$ and $V_\delta$ gives
\[H(T)=\sum_m\frac{A_m}{\gamma_m}\left[1-(1+\gamma_mT)e^{-\gamma_mT}\right].\]
At $T=0$ every bracket is zero. As $T\to\infty$, both $e^{-\gamma_mT}$ and $T e^{-\gamma_mT}$ tend to zero. Hence $H(T)\to\sum_m A_m/\gamma_m=c_{\rm crit}$.'''),
('Explain why strict monotonicity matters', r'''A continuous, strictly increasing function rising from 0 to $c_{\rm crit}$ crosses each price strictly between them exactly once. This will give a unique candidate period and determine the cost’s slope on either side.'''))

add('proof-R-4',
('Locate the price in the range of H', r'''Assume $0<c<c_{\rm crit}$. Step R.3 shows the increasing function $H$ starts below $c$ and eventually exceeds it. We can therefore find a finite positive time at which $H=c$.'''),
('Separate periodic optimality from general scheduling', r'''The next steps establish that this time minimizes $C(T)$ over positive constant periods. A further interval-accounting argument is still needed to show that irregular or independently randomized schedules cannot do better.'''))

add('proof-R-4-1',
('Establish existence and uniqueness of the root', r'''Continuity gives a solution $T^*>0$ to $H(T^*)=c$ by the intermediate value theorem. Strict increase makes that solution unique.'''),
('Read the direction of improvement from the derivative', r'''For $T<T^*$, $H(T)<c$, so $C'(T)<0$. For $T>T^*$, $H(T)>c$, so $C'(T)>0$. The periodic cost decreases up to $T^*$ and increases afterward. Thus this root is a minimum, rather than a maximum or a flat stationary point.'''))

add('proof-R-4-2',
('Examine very frequent communication', r'''Since $B(0)=0$ and $B'(0)=\sum_m A_m$, differentiability gives $B(T)=T\sum_m A_m+o(T)$. Therefore
\[C(T)=J_L^{\rm tot}+\frac cT-\sum_m A_m+o(1)\to\infty\quad(T\downarrow0),\]
because $c>0$. Paying a fixed positive price arbitrarily frequently is costly.'''),
('Examine arbitrarily rare communication', r'''The numerator $c-B(T)$ remains bounded because $0\le B(T)\le c_{\rm crit}$. Dividing by $T\to\infty$ makes the adjustment vanish. Hence $C(T)\to J_L^{\rm tot}$. Combined with the strict slope signs, these limits confirm the unique global minimum over positive periods.'''))

add('proof-R-4-3',
('Rearrange the root equation', r'''At $T^*$,
\[c=H(T^*)=B(T^*)-T^*V_\delta(T^*).\]
Subtracting $B(T^*)$ yields $c-B(T^*)=-T^*V_\delta(T^*)$.'''),
('Insert into the periodic cost', r'''Then
\[C(T^*)=J_L^{\rm tot}+\frac{-T^*V_\delta(T^*)}{T^*}=J_L^{\rm tot}-\sum_m A_m e^{-\gamma_mT^*}.\]
The subtracted sum is strictly positive. Thus this periodic schedule strictly improves on no refreshing when the price is below threshold.'''))

add('proof-R-4-4',
('Collect the periodic conclusions', r'''There is one finite positive root, its derivative signs establish the unique minimizing period, and substitution gives its attained cost. The optimum is strictly below the local baseline. All of these conclusions use $0<c<c_{\rm crit}$.'''),
('Identify the remaining competitor class', r'''We have optimized over periodic schedules so far. The proof now handles high prices and then bounds every allowed irregular or randomized schedule, completing the larger optimization claim.'''))

add('proof-R-5',
('Bound the benefit in a finite interval', r'''Each $1-e^{-\gamma_mT}<1$ for finite $T>0$, so
\[B(T)<\sum_m A_m/\gamma_m=c_{\rm crit}.\]
If $c\ge c_{\rm crit}$, then $c-B(T)>0$ for every finite positive interval.'''),
('Compare with no communication', r'''Therefore $C(T)=J_L^{\rm tot}+[c-B(T)]/T>J_L^{\rm tot}$ for every finite period. Never refreshing attains $J_L^{\rm tot}$ directly. At the threshold as well as above it, a finite period cannot improve the baseline. The general-schedule argument below shows that irregular timing cannot improve it either.'''))

add('proof-R-6',
('Express an arbitrary schedule as intervals', r'''A received update resets every component’s age to $\delta$. Between two receptions the benefit therefore follows the same curve $V_\delta(r)$, regardless of when that interval occurs. An interval of length $T$ saves $B(T)$ and is assigned one communication price $c$.'''),
('Bound each interval by a common rate', r'''Let $g$ be the smallest periodic excess cost per unit time, also allowing 0 for no updates. By definition $c-B(T)\ge gT$ for every $T>0$. Apply this inequality to every complete reception interval in a finite horizon. The only unfinished interval has bounded total possible benefit.'''),
('Let the boundary effect disappear', r'''Summing the interval inequalities gives a lower bound equal to horizon length times $J_L^{\rm tot}+g$, minus a fixed constant. Dividing by the horizon makes that constant vanish. The following substeps justify conditioning, boundary accounting, and attainment individually.'''))

add('proof-R-6-1',
('Define the best candidate excess rate', r'''Set
\[g=\min\left\{0,\inf_{T>0}\frac{c-B(T)}T\right\}.\]
The value 0 includes no refreshing. The infimum includes all constant positive periods. In particular $g\le0$. Also $B(T)\le V_\delta(0)T$, so every quotient is at least $-V_\delta(0)$ and $g$ is finite.'''),
('Condition on a fixed schedule realization', r'''A randomized schedule can first be viewed as a deterministic sequence of reception times after conditioning on its realization. Because the schedule is independent of all signal and disturbance processes, conditioning does not change their distributions. The previously derived expected benefit $V_\delta(r)$ therefore still applies in each interval.'''),
('Explain the independence restriction', r'''If transmission times were chosen from sensor values, learning the schedule could itself reveal information about the signal. Conditional decision losses could then change. The present interval bound uses the stated observation-independent schedule class.'''))

add('proof-R-6-2',
('Apply the definition of the infimum', r'''For any complete interval with positive length $T_j$,
\[g\le\frac{c-B(T_j)}{T_j}.\]
Multiplying by $T_j>0$ gives $gT_j\le c-B(T_j)$.'''),
('Interpret the right-hand side as interval cost', r'''Relative to local operation, the update provides integrated decision benefit $B(T_j)$ until the next reception and costs $c$. Its net contribution is therefore $c-B(T_j)$, at least $gT_j$. Summing this bound permits intervals of different lengths. If receptions coincide, a zero-length interval provides no benefit and has cost $c\ge0=g\cdot0$.'''))

add('proof-R-6-3',
('Bound the unfinished final interval', r'''Suppose the last received update has been used for $L$ units of time when the horizon ends. Its accumulated benefit is $B(L)\le c_{\rm crit}$. Even if we discard its nonnegative communication charge when forming a lower bound, its net contribution is at least $-c_{\rm crit}$.'''),
('Account for the initial interval', r'''Before the first reception, the agents operate locally, so the decision benefit relative to the local baseline is zero. With the no-initial-pool convention used in this accounting, there is no initial benefit to subtract. Local finiteness guarantees that only finitely many intervals need to be summed on any finite horizon.'''))

add('proof-R-6-4',
('Sum complete and unfinished intervals', r'''Let $S$ be the total length of the complete reception intervals within horizon $R$. The conditional expected excess cost is at least
\[gS-c_{\rm crit}.\]
The initial local interval contributes zero and the final interval contributes the stated bounded remainder.'''),
('Use the sign of g in the correct direction', r'''We have $S\le R$ and $g\le0$. Multiplication by a nonpositive number gives $gS\ge gR$. Thus excess cost is at least $gR-c_{\rm crit}$. Adding the baseline over the whole horizon gives
\[\E[\text{total cost through }R\mid\text{schedule}]\ge R(J_L^{\rm tot}+g)-c_{\rm crit}.\]'''))

add('proof-R-6-5',
('Compare the two charging conventions', r'''Every message received by time $R$ must have been generated by time $R$, because latency $\delta\ge0$. Thus the number sent by $R$ is at least the number received by $R$.'''),
('Preserve a lower bound when adding charges', r'''The interval proof assigned prices only to received updates, and even dropped a final price. Charging at generation can add charges for messages still in flight. Since $c>0$, those extra charges cannot decrease cost. Therefore the same lower bound remains valid under the paper’s actual transmission-time charging convention.'''))

add('proof-R-6-6',
('Average over the schedule randomness', r'''The bound $R(J_L^{\rm tot}+g)-c_{\rm crit}$ does not depend on which schedule realization occurred. Taking expectation over schedules preserves it:
\[\E[\text{total cost through }R]\ge R(J_L^{\rm tot}+g)-c_{\rm crit}.\]'''),
('Divide before taking the long-run limit', r'''For $R>0$,
\[\frac1R\E[\text{total cost through }R]\ge J_L^{\rm tot}+g-\frac{c_{\rm crit}}R.\]
The final term tends to zero. Hence the limiting upper average cost is at least $J_L^{\rm tot}+g$. No exchange of expectation and a limiting upper value is needed: the expectation was taken at each finite horizon first.'''))

add('proof-R-6-7',
('Attain the bound below threshold', r'''When $c<c_{\rm crit}$, the periodic minimizer has negative excess rate $[c-B(T^*)]/T^*$, so this rate equals $g$. Periodic operation repeats the same interval indefinitely. Its finite initial delay and final partial interval vanish in the long-run average, leaving exactly $C(T^*)=J_L^{\rm tot}+g$.'''),
('Attain the bound at and above threshold', r'''If $c\ge c_{\rm crit}$, every periodic excess rate is nonnegative, so $g=0$. Sending no updates gives the local cost $J_L^{\rm tot}$ exactly. Thus a feasible policy attains the lower bound in each price regime.'''))

add('proof-R-6-8',
('Combine a universal lower bound with an attaining policy', r'''Steps R.6.1–R.6.6 show every admissible independent schedule has long-run cost at least $J_L^{\rm tot}+g$. Step R.6.7 exhibits an admissible schedule achieving that value. Therefore it is the minimum over the whole allowed schedule class.'''),
('Distinguish the unique period from uniqueness of every schedule', r'''Below threshold the best constant period $T^*$ is unique. The theorem does not assert that every optimal infinite schedule must be identical at every time: changing finitely many updates can leave a long-run average unchanged. The claimed existence of an optimal periodic schedule is the conclusion proved here.'''))

add('proof-R-7',
('Check both price regimes', r'''For $0<c<c_{\rm crit}$, the root of $H(T)=c$ gives an optimal periodic schedule and its attained cost. For $c\ge c_{\rm crit}$, no communication is optimal. Since the assumptions require $c>0$, these two cases cover all allowed prices.'''),
('Check the schedule class', r'''The interval argument covers every locally finite deterministic schedule and every independently randomized schedule. Fixed latency makes each reception reset age to the same $\delta$. These are the assumptions needed to pass from a one-period calculation to the all-schedules result.'''))

add('signal-and-reading',
('Compute a reading’s variance', r'''From $Y_i=X+E_i$, $\Var(Y_i)=\Var(X)+\Var(E_i)+2\Cov(X,E_i)$. Independence makes the covariance zero, leaving $a+b$.'''),
('Compute the covariance of two sensors', r'''For $i\ne j$, expanding $\Cov(X+E_i,X+E_j)$ gives four terms. Only $\Cov(X,X)=a$ survives, because the errors are mutually independent and independent of $X$. Thus different readings have covariance $a$ even though their disturbances are independent.'''))

add('ou',
('Obtain the prediction coefficient', r'''For jointly Gaussian $X(t),X(s)$, the centered regression coefficient is $\Cov(X(t),X(s))/\Var(X(s))=a\rho/a=\rho$. Define the prediction error $\xi=X(t)-\rho X(s)$.'''),
('Compute the innovation variance and past independence', r'''Its variance is $a-2\rho(a\rho)+\rho^2a=a(1-\rho^2)$. For every $r\le s$,
\[\Cov(\xi,X(r))=a e^{-\lambda(t-r)}-\rho a e^{-\lambda(s-r)}=0.\]
Gaussianity makes the innovation independent of the signal’s past. Independence from sensor disturbances gives independence from the joint past used by the paper.'''))

add('expectation',
('Express what conditional expectation preserves', r'''The variable $m=\E[Z\mid\mathcal G]$ is determined by $\mathcal G$. For every square-integrable quantity $v$ determined by the same information, $\E[v(Z-m)]=0$. The error has no component predictable from the available information.'''),
('Derive the least-squares property', r'''Write $Z-v=(Z-m)+(m-v)$ and expand its square. The cross term is zero by the preceding identity, so
\[\E[(Z-v)^2]=\E[(Z-m)^2]+\E[(m-v)^2].\]
The last term is nonnegative. Therefore $m$ has the smallest squared prediction error among estimates based on $\mathcal G$.'''))

add('covariance',
('Explain the Gaussian independence step', r'''A centered jointly Gaussian vector with covariance matrix $\Sigma$ has characteristic function $\exp(-z^\top\Sigma z/2)$. If the cross-covariance between two blocks is zero, $\Sigma$ is block diagonal, so this exponential factors into the product of the two blocks’ characteristic functions. That factorization is independence.'''),
('Explain its use for histories', r'''The proof first shows a residual has zero covariance with every observed variable. It is then independent of every finite vector of those observations by the Gaussian block argument. Events described by finite vectors generate the observation sigma-field, so the independence extends to the full history. Without joint Gaussianity, zero covariance alone would not justify that conclusion.'''))

add('information-fields',
('Translate measurability into a policy restriction', r'''If $u_i$ is $\mathcal G_i$-measurable, its value is determined by the information agent $i$ possesses. A formula involving an unobserved quantity is not feasible merely because it has a small cost.'''),
('Derive the information-inclusion inequality', r'''If $\mathcal G_i\subseteq\mathcal H_i$ for every agent, every policy feasible under $\mathcal G$ is feasible under $\mathcal H$. Taking an infimum over a larger set can only lower or preserve its value. Thus $J^*(\mathcal H)\le J^*(\mathcal G)$. Equality requires a separate sufficiency argument.'''))

add('v-and-d',
('Derive v from averaging sensor errors', r'''Since $\bar Y=X+n^{-1}\sum_iE_i$ and errors are independent,
\[\Var(\bar Y)=a+\frac1{n^2}\sum_i b=a+\frac bn=v.\]'''),
('Derive d from the team objective', r'''For a common local gain $u_i=kY_i$, tracking loss is $a-2ak+k^2(a+b)$. Disagreement adds $\kappa k^2b(1-1/n)$. The coefficient of $k^2$ is therefore $a+b+\kappa b(1-1/n)=d$. Thus $v$ is a variance, while $d$ also includes the decision penalty.'''))

add('loss',
('Show how the two penalties interact', r'''For each realization, write $u_i-X=(u_i-\bar u)+(\bar u-X)$ and sum the expanded squares. The cross terms cancel because $\sum_i(u_i-\bar u)=0$. Hence
\[\frac1n\sum_i(u_i-X)^2=(\bar u-X)^2+\frac1n\sum_i(u_i-\bar u)^2.\]'''),
('Rewrite the complete objective', r'''The instantaneous team loss can also be written
\[\ell(u,X)=(\bar u-X)^2+\frac{1+\kappa}{n}\sum_i(u_i-\bar u)^2.\]
The team therefore cares about the accuracy of its average action and the spread around that average. This equivalent expression also makes convexity visible.'''))

add('local-estimation-gap',
('Subtract using the two exact losses', r'''Since $P_1=a-a^2/(a+b)$ and $J_L=a-a^2/d$,
\[J_L-P_1=\frac{a^2[d-(a+b)]}{(a+b)d}.\]'''),
('Insert the extra term in d', r'''The difference $d-(a+b)=\kappa b(1-1/n)$. Thus
\[J_L-P_1=\frac{\kappa a^2b(1-1/n)}{(a+b)d}.\]
All factors except $\kappa$ are strictly positive. The gap is zero at $\kappa=0$ and positive at $\kappa>0$.'''))

add('threshold-dependence',
('Differentiate with respect to the disagreement penalty', r'''Only $d$ depends on $\kappa$, with $\partial d/\partial\kappa=b(1-1/n)$. The chain rule gives
\[\frac{\partial\tau_{\rm cross}}{\partial\kappa}=\frac{b(1-1/n)}{2\lambda d}>0.\]
More expensive disagreement extends the age range in which a common delayed decision remains competitive.'''),
('Differentiate with respect to the temporal rate', r'''Holding $a,b,n,\kappa$ fixed,
\[\frac{\partial\tau_{\rm cross}}{\partial\lambda}=-\frac{\log(d/v)}{2\lambda^2}<0.\]
The numerator is positive because $d>v$. Faster temporal change shortens the allowable delay.'''))

add('hybrid-implementation',
('Calculate the shared prediction', r'''From the received mean $\bar Y(s)$, form the old pooled estimate $(a/v)\bar Y(s)$. Multiply by $\rho=e^{-\lambda(t-s)}$ to predict it forward to the current time.'''),
('Calculate the new private information', r'''Predict the old own-sensor reading as $\rho Y_i(s)$, then subtract it from the current reading to get $Z_i=Y_i(t)-\rho Y_i(s)$. Multiply by $a/d$ to account for the tracking and disagreement tradeoff, then add this correction to the shared prediction.'''),
('Explain why the stored local sample matters', r'''The old shared mean already incorporates information correlated with the old local sample. Subtracting $\rho Y_i(s)$ isolates the new innovation and prevents treating the entire current reading as new information. The formula’s proof relies on this innovation being independent of the old sensor history.'''))

add('age-budget',
('Cancel the positive fresh benefit', r'''The desired gain inequality is $\Delta e^{-2\lambda\tau}\ge\alpha\Delta$. Since $\Delta>0$, divide by it to obtain $e^{-2\lambda\tau}\ge\alpha$.'''),
('Solve for the maximum age', r'''Logarithm preserves the inequality, giving $-2\lambda\tau\ge\log\alpha$. Dividing by the negative number $-2\lambda$ reverses the direction:
\[\tau\le-\frac{\log\alpha}{2\lambda}=\frac{\log(1/\alpha)}{2\lambda}.\]
The right side is positive because $0<\alpha<1$.'''))

add('half-life',
('Solve for a halving of correlation', r'''Set $e^{-\lambda t}=1/2$. Taking logarithms gives $-\lambda t=-\log2$, hence $t=\log2/\lambda$.'''),
('Solve for a halving of coordination value', r'''Set $\Delta e^{-2\lambda t}=\Delta/2$. Cancel $\Delta>0$ and take logarithms to get $t=\log2/(2\lambda)$. Dividing this by the correlation half-life gives exactly $1/2$.'''))

add('effective-decay',
('Differentiate the sum of benefits', r'''Write $\gamma_m=2\lambda_m$ and $b_m(\tau)=w_m\Delta_m e^{-\gamma_m\tau}$. Then $V=\sum_m b_m$ and $V'=-\sum_m\gamma_m b_m$. Since $V>0$,
\[-V'/V=\sum_m p_m\gamma_m,\qquad p_m=b_m/V.\]
The weights are positive and sum to one, making the effective rate a weighted average.'''),
('Show why slower components gain relative weight', r'''For a faster component $f$ and a slower component $s$, with $\gamma_f>\gamma_s$,
\[\frac{b_f(\tau)}{b_s(\tau)}=\frac{w_f\Delta_f}{w_s\Delta_s}e^{-(\gamma_f-\gamma_s)\tau}.\]
This ratio decreases with age. Thus the slower component’s share relative to the faster one increases.'''))

add('integrated-benefit',
('Integrate one exponential term', r'''An antiderivative of $A_m e^{-\gamma_m r}$ is $-(A_m/\gamma_m)e^{-\gamma_m r}$. Evaluating between 0 and $T$ gives
\[\int_0^T A_m e^{-\gamma_m r}\,dr=\frac{A_m}{\gamma_m}(1-e^{-\gamma_mT}).\]'''),
('Sum the accumulated benefits', r'''Linearity of the integral gives $B(T)$ by summing the component formulas. The result measures accumulated loss saved, rather than the instantaneous loss reduction. Its units therefore match the per-update communication price $c$.'''))

add('periodic-cost',
('Account for one complete reception interval', r'''Local operation would accumulate loss $TJ_L^{\rm tot}$. Using the received summary saves $B(T)$ over that interval. Assign one update price $c$. Total interval cost is therefore $TJ_L^{\rm tot}-B(T)+c$.'''),
('Convert accumulated cost to average cost', r'''Divide by interval length $T$ to get
\[C(T)=J_L^{\rm tot}+\frac{c-B(T)}T.\]
Every complete periodic interval has this same expected cost. Finite initial and final boundary intervals do not change the long-run average.'''))

add('critical-price',
('Compute the benefit of one update over its remaining lifetime', r'''Let $T\to\infty$ in the integral formula. Since $e^{-\gamma_mT}\to0$,
\[B(\infty)=\sum_m A_m/\gamma_m=c_{\rm crit}.\]'''),
('Check both sides of the price threshold', r'''If $c\ge c_{\rm crit}$, no finite interval can recover its price in decision benefit. If $c<c_{\rm crit}$, continuity and convergence of $B(T)$ imply $B(T)>c$ for some sufficiently long finite $T$. That period has $(c-B(T))/T<0$ and beats the local baseline. Theorem 2 strengthens this comparison to all permitted schedules.'''))

add('scalar-refresh',
('Substitute the one-component expressions', r'''With one component, $c_{\rm crit}=A/\gamma$, $B(T)=(A/\gamma)(1-e^{-\gamma T})$, and $TB'(T)=TAe^{-\gamma T}$. The root condition becomes
\[\frac A\gamma[1-(1+\gamma T)e^{-\gamma T}]=c.\]'''),
('Make time and price dimensionless', r'''Divide by $c_{\rm crit}=A/\gamma$ and set $x=\gamma T=2\lambda T$, $\chi=c/c_{\rm crit}$. This yields $1-(1+x)e^{-x}=\chi$. Its derivative in $x$ is $xe^{-x}>0$ for $x>0$, so every $0<\chi<1$ has one positive root.'''))

add('latency-cutoff',
('Write the price threshold as an inequality in latency', r'''For one unit-weight component, no refreshing is optimal precisely when
\[c\ge\frac{\Delta e^{-2\lambda\delta}}{2\lambda}.\]
Multiply by $2\lambda/\Delta>0$ to get $e^{-2\lambda\delta}\le2\lambda c/\Delta$.'''),
('Handle whether the right side is at least one', r'''If $2\lambda c/\Delta\ge1$, the inequality holds for every $\delta\ge0$. Otherwise take logarithms and divide by $-2\lambda$, reversing the inequality, to get
\[\delta\ge\frac1{2\lambda}\log\frac{\Delta}{2\lambda c}.\]
Combining these two cases gives the maximum-with-zero formula.'''))

add('minimum-interval',
('Use the shape of the periodic cost', r'''Below threshold, $C(T)$ decreases up to $T^*$ and increases afterward. If $T_{\min}\le T^*$, the unconstrained minimum remains feasible. If $T_{\min}>T^*$, the whole feasible interval lies on the increasing branch, whose minimum is its left endpoint $T_{\min}$.'''),
('Check the no-refresh alternative', r'''For $T\ge T^*$, $C(T)$ increases toward $J_L^{\rm tot}$ from below, so any finite constrained minimizer on this branch still improves on no refreshing. This gives $\max\{T_{\min},T^*\}$ when $c<c_{\rm crit}$. At or above threshold, the original no-refresh conclusion remains valid.'''))

add('discrete-model',
('Choose the stationary innovation variance', r'''In $X_{t+1}=qX_t+\xi_t$, independence of the innovation gives $\Var(X_{t+1})=q^2a+\Var(\xi_t)$. To keep stationary variance $a$, choose $\Var(\xi_t)=a(1-q^2)$. Each disturbance uses the corresponding $b_i(1-q^2)$.'''),
('Iterate the recursion across k slots', r'''Repeated substitution gives $X_{t+k}=q^kX_t+\sum_{j=0}^{k-1}q^j\xi_{t+k-1-j}$. The sum is independent of the past and has variance
\[a(1-q^2)\sum_{j=0}^{k-1}q^{2j}=a(1-q^{2k}).\]
Thus the same prediction and innovation decomposition holds with $\rho=q^k$.'''))

add('discrete-proof',
('Repeat the four-term covariance expansion', r'''Let $\alpha=q^{r-s}$ and $\beta=q^{t-r}$, so $\rho=\alpha\beta$. Subtracting the predicted old readings gives
\[\Cov(Z_j(t),Z_i(r))=\Sigma_{ji}[\beta-\alpha\rho-\rho\alpha+\rho\alpha]=\Sigma_{ji}\beta(1-\alpha^2).\]
This is $\Sigma_{ji}q^{t-r}(1-q^{2(r-s)})$.'''),
('Follow the same projection and cost argument', r'''The temporal factor cancels in covariance ratios at every integer observation time. The Gaussian projection and conditional normal-equation checks therefore remain valid. The innovation covariance scales by $1-q^{2k}$, giving $J_H(k)=q^{2k}J_P+(1-q^{2k})J_L$.'''))

add('discrete-refresh',
('Sum benefits over the slots in an interval', r'''At elapsed slots $r=0,\ldots,N-1$, one component contributes $A_m(q_m^2)^r$. Let $x=q_m^2$. The finite sum $S=1+x+\cdots+x^{N-1}$ satisfies $(1-x)S=1-x^N$.'''),
('Divide and add components', r'''Since $0<x<1$, $S=(1-x^N)/(1-x)$. Multiplication by $A_m$ and summation over components gives the displayed accumulated benefit. For these reception-slot conventions, the periodic excess cost is price minus this sum, divided by $N$. Optimization is over positive integers, so the continuous derivative equation is not applied verbatim.'''))

add('white-noise',
('Calculate the covariances with yesterday’s reading', r'''In this alternative discrete model the sensor errors are independent across time. Therefore $\Cov(X_t,Y_{i,t-1})=aq$ and $\Cov(Y_{i,t},Y_{i,t-1})=aq$. The second expression has no temporally correlated error term.'''),
('Evaluate the residual covariance', r'''The endpoint-only estimation residual has covariance
\[aq-\frac a{a+b}aq=\frac{abq}{a+b}>0\]
with yesterday’s reading. It is therefore not independent of the observed past. Additional history can improve the estimate, so the common-rate endpoint sufficiency proof does not carry over to this alternative model.'''))

add('numerical-endpoints',
('Substitute the eight-sensor parameters', r'''With $n=8$, $a=b=\kappa=1$, $v=1+1/8=9/8$ and $d=1+1+(1-1/8)=23/8$. Therefore $P_1=1/2$, $J_P=1-8/9=1/9$, and $J_L=1-8/23=15/23$.'''),
('Compute the benefit and crossover', r'''Subtract to get $\Delta=15/23-1/9=(135-23)/207=112/207$. With $\lambda=1$, the crossover is $\tfrac12\log[(23/8)/(9/8)]=\tfrac12\log(23/9)\simeq0.4691$.'''),
('Check the percentage improvement at age one', r'''The delayed-only loss is $J_D(1)=1-(8/9)e^{-2}\simeq0.8797$. The percentage reduction from using local operation is $(J_D(1)-J_L)/J_D(1)\simeq0.2586$, or about 25.9%. The denominator is the delayed-only loss being improved upon.'''))

add('numerical-decay',
('Evaluate the hybrid curve at age one half', r'''At $\lambda=1$ and $\tau=0.5$, $e^{-2\lambda\tau}=e^{-1}$. Thus
\[J_H(0.5)=\frac{15}{23}-\frac{112}{207}e^{-1}\simeq0.4531.\]'''),
('Interpret the normalized lower panel', r'''Dividing $J_L-J_H(\tau)=\Delta e^{-2\lambda\tau}$ by $\Delta$ leaves $e^{-2\lambda\tau}$. At age one half this is about 0.3679. The curve reports the fraction of fresh-sharing benefit remaining, rather than a percentage reduction in the total loss.'''))

add('numerical-refresh',
('Compute the reception amplitude and critical price', r'''For the same example, $\gamma=2$ and $\delta=0.1$. Hence $A=(112/207)e^{-0.2}$ and $c_{\rm crit}=A/2\simeq0.2215$.'''),
('Solve the normalized period equation', r'''At half the critical price, solve $1-(1+x)e^{-x}=0.5$. Its positive root is approximately $x=1.67835$. Since $x=2T^*$, $T^*\simeq0.83917$.'''),
('Evaluate the attained cost', r'''The optimal-cost identity gives $C(T^*)=15/23-Ae^{-2T^*}\simeq0.5695$. This value already includes the communication price through the optimizing-period equation.'''))

add('numerical-multirate',
('Calculate the second component’s endpoints', r'''With $n=8$, $a_2=0.4$, $b_2=0.8$, and $\kappa_2=1$, $v_2=0.5$ and $d_2=1.9$. Thus $J_{P,2}=0.4-0.16/0.5=0.08$, $J_{L,2}=0.4-0.16/1.9$, and $\Delta_2=J_{L,2}-0.08\simeq0.23579$.'''),
('Account for latency and lifetime', r'''The rates are $\gamma_1=2$ and $\gamma_2=0.24$. At $\delta=0.1$, $A_1=\Delta_1e^{-0.2}$ and $A_2=\Delta_2e^{-0.024}$. The critical price is $A_1/2+A_2/0.24\simeq1.1807$. The slow component’s reception share is $A_2/(A_1+A_2)\simeq34.2\%$, while its lifetime share is $(A_2/0.24)/c_{\rm crit}\simeq81.2\%$.'''),
('Evaluate the joint period and cost', r'''At $c=c_{\rm crit}/2$, solve
\[\sum_{m=1}^2\frac{A_m}{\gamma_m}[1-(1+\gamma_mT)e^{-\gamma_mT}]=c.\]
The root is $T^*\simeq5.5513$. Substituting into $J_{L,1}+J_{L,2}-A_1e^{-2T^*}-A_2e^{-0.24T^*}$ gives about $0.9072$.'''))

# The claim pages provide an explicit reading of their scope before the full derivation.
add('claim-L',
('Read the equation as a conditional residual test', r'''Move its right-hand side to the left. The equation says $\E[(1+\kappa)u_i-\kappa\bar u-X\mid\mathcal G_i]=0$, because $u_i$ is already known to agent $i$.'''),
('Follow the two directions of the proof', r'''The following steps expand $J(u+w)-J(u)$ exactly, show why feasible perturbations introduce conditional expectations, and prove that a zero conditional residual is both necessary and sufficient. Positivity of the quadratic remainder supplies uniqueness.'''))
add('claim-P',
('Identify the two separate optimizations', r'''Local policies may use each agent’s entire own-sensor history. Pooled policies may use all sensor histories. In each class the proof first derives the relevant conditional means, then checks the team-optimal policy using Lemma 1.'''),
('Read the positive benefit from the formulas', r'''The local cost subtracts $a^2/d$ from $a$, whereas pooling subtracts $a^2/v$. Since $d>v>0$, $a^2/v>a^2/d$, so the pooled cost is smaller. The following proof derives both denominators and evaluates their difference.'''))
add('claim-D',
('Identify what has become unavailable', r'''At decision time $t$, the delayed-only agents see all sensors’ observations through $s=t-\tau$ and none after that time. Predicting the old pooled estimate forward therefore multiplies it by $\rho=e^{-\lambda\tau}$.'''),
('See the algebra behind the threshold', r'''The difference is $J_D-J_L=a^2(1/d-e^{-2\lambda\tau}/v)$. Its sign changes when $e^{-2\lambda\tau}=v/d$. The proof below derives the cost and solves this equality, including the direction of the strict inequality.'''))
add('claim-H',
('Read the two information sets being compared', r'''Both the hybrid and complete delayed-sharing benchmark retain fresh local information. The benchmark has all old raw sensor histories through $s$. The hybrid action needs only their old mean and the agent’s own readings at $s$ and $t$.'''),
('Separate the proof’s two tasks', r'''First verify the proposed policy against the larger full-history class. Then observe that the smaller hybrid class can implement it. This establishes equality of optimized decision values. It does not assert that the mean reproduces every old sensor reading.'''),
('Read the cost as a weighted combination', r'''The weights $\rho^2$ and $1-\rho^2$ are nonnegative and sum to one. At zero age only $J_P$ contributes. As age grows, the weight shifts toward $J_L$. The proof derives those weights from independent residuals and scaled innovation covariance.'''))
add('claim-U',
('Explain why sensor-dependent gains appear', r'''An agent with different error variance has a different conditional estimate and a different predicted relationship to other actions. The normal equations therefore produce individual gains $k_i$ coupled through their average $\bar k$.'''),
('Explain why one shared scalar still suffices', r'''With unequal variances, Gaussian conditioning gives the precision-weighted mean $\mu_P=P\sum_iY_i/b_i$. The common temporal rate makes its residual independent of all sensor histories. This is the property used to preserve the hybrid cost law.'''))
add('claim-C',
('Explain what prevents cross-component improvement', r'''The objective adds component losses, the action constraints do not couple components, and the underlying component processes are independent. Averaging away other-component observations preserves feasibility and cannot increase a convex quadratic component loss.'''),
('Add the separately attained improvements', r'''Each component can simultaneously use its own optimal hybrid rule. Therefore its weighted improvement $w_m\Delta_m e^{-2\lambda_m\tau_m}$ contributes directly to the total. The following proof justifies the averaging step even for policies that initially depend on observations from multiple components.'''))
add('claim-R',
('Interpret the two thresholds in the theorem', r'''The price threshold $c_{\rm crit}$ is the total benefit an update could provide over its remaining lifetime. Below that price, the optimal period balances $c$ against $H(T)=B(T)-TB'(T)$. These compare accumulated loss with a communication price, so their units agree.'''),
('Identify why the theorem covers irregular schedules', r'''Every complete interval satisfies $c-B(T)\ge gT$, where $g$ is the best periodic excess rate including no refreshing. Adding this inequality over arbitrary intervals gives a common long-run lower bound. A periodic schedule or no communication attains that bound. The following proof handles the leftover interval and independently randomized schedules explicitly.'''))

add('fresh-local',
('Separate allowed information from the eventual implementation', r'''The optimization allows $u_i$ to depend on the complete own-sensor history $\mathcal F_i(t)$. The optimal policy happens to use only $Y_i(t)$. That reduction follows from the common-rate Gaussian projections and Lemma 1, rather than from a restriction imposed on policies.'''),
('Distinguish the posterior estimate from the team action', r'''The posterior estimate is $aY_i(t)/(a+b)$. The team action is $aY_i(t)/d$. When $\kappa>0$, $d>a+b$, so the team action puts less weight on an individual noisy reading to reduce disagreement with other agents.'''))
add('fresh-pooled',
('Explain what pooling includes', r'''The pooled benchmark gives all agents the complete sensor histories through the current time. It therefore includes the exact readings, rather than only prescribing an aggregate as the available information.'''),
('Explain why the average achieves that benchmark', r'''The residual $X(t)-(a/v)\bar Y(t)$ has zero covariance with every sensor reading at every time. Joint Gaussianity makes it independent of all that sensor information. Thus the extra raw readings cannot improve the posterior estimate beyond the mean. Choosing that same estimate at every agent also eliminates disagreement.'''))
add('delayed-only',
('Identify the missing new information', r'''All sensor readings through time $s$ are available, but every reading after $s$ is excluded. The agents must therefore predict across the time gap $\tau=t-s$ using only the old pool.'''),
('Explain why local information can beat this benchmark', r'''Fresh local information contains one current sensor history. Delayed-only information contains many histories ending earlier. These information sets are not nested. More sensors can reduce old estimation error, while the delay introduces new signal uncertainty. The crossover proof evaluates the exact tradeoff.'''))
add('hybrid',
('Read the complete-sharing comparison literally', r'''The full delayed-sharing benchmark has $\mathcal F(s)\vee\mathcal F_i(t)$. Thus agent $i$ has every sensor’s old history and its own fresh history. The hybrid keeps that fresh local information and uses the scalar old shared mean to implement the optimal policy.'''),
('Explain why the hybrid improves on delayed-only information', r'''Theorem 1’s formula gives $J_H=\rho^2P_n+(1-\rho^2)J_L$. The delayed-only cost is $J_D=\rho^2P_n+(1-\rho^2)a$. Subtracting gives
\[J_D-J_H=(1-\rho^2)(a-J_L)=(1-\rho^2)\frac{a^2}{d}>0\]
at positive age. Fresh local information does help relative to delayed-only operation. It is already present on both sides of the theorem’s scalar-versus-complete-sharing equality.'''))
add('costs',
('Define posterior variance through a conditional estimate', r'''For information $\mathcal G$, let $\widehat X=\E[X\mid\mathcal G]$. The posterior variance is $\E[(X-\widehat X)^2\mid\mathcal G]$. In this jointly Gaussian model with fixed observation times, the projection residual is independent of the observations, so that variance is a deterministic number.'''),
('Explain why J can differ from P', r'''An agent’s posterior mean minimizes its own squared estimation error. The team objective also penalizes differences between actions. A team-optimal action may therefore depart from that posterior mean. With shared information, everyone can use the same posterior mean and have zero disagreement, giving $J_P=P_n$.'''))
add('l2',
('Check that the policy space allows perturbations', r'''If $u_i,w_i\in L^2(\mathcal G_i)$, their sum uses the same information and satisfies $\E[(u_i+w_i)^2]\le2\E[u_i^2]+2\E[w_i^2]<\infty$. Multiplying $w_i$ by any finite real number also preserves feasibility. This is what permits the positive and negative perturbations in Lemma 1.'''),
('Check the products used in the proof', r'''Cauchy–Schwarz gives $\E[|AB|]\le\sqrt{\E[A^2]\E[B^2]}$ for any two $L^2$ variables. Thus the residual–perturbation products in the expansion have finite expectation, even though the individual variables need not be bounded.'''))
add('amplitudes',
('Separate delivery delay from time since arrival', r'''At elapsed time $r$ after reception, the shared data have age $\delta+r$. The component benefit is $w_m\Delta_m e^{-\gamma_m(\delta+r)}$. The exponential identity $e^{x+y}=e^xe^y$ separates this into $[w_m\Delta_m e^{-\gamma_m\delta}]e^{-\gamma_mr}$.'''),
('Identify the reception amplitude', r'''The bracket is $A_m$, the benefit immediately after reception. Summing over components gives $V_\delta(r)=\sum_m A_m e^{-\gamma_mr}$. This separates the benefit already lost in transit from the decay that continues after arrival.'''))
