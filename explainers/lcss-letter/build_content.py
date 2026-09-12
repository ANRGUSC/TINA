"""Build the reading guide from the manuscript's source-mapped proof steps."""
from pathlib import Path
import json
from content.detailed_explanations import DETAILS

ROOT=Path(__file__).resolve().parent
PROOFS=json.loads((ROOT/'content/formal_results.json').read_text())
NOTES={}
for line in (ROOT/'content/proof_explanations.txt').read_text().splitlines():
    if line.strip():
        key,title,note=line.split('|',2)
        NOTES[key]=(title,note)

chapters=[]
def chapter(title):
    c={'title':title,'lessons':[]};chapters.append(c);return c
def add(c,id,title,body,*explain,source='Notation and model · Section II',**extra):
    c['lessons'].append(dict(id=id,title=title,body=body,explain=list(explain),source=source,**extra))

c=chapter('1. The question')
add(c,'start','When is sharing too slow?',
    'This guide explains the six-page L-CSS submission manuscript, Too Late to Coordinate: When Local Information Beats Global Sharing. It has not been accepted for publication. It does not cover the full TINA arXiv manuscript.\n\nSeveral agents measure the same changing signal. Sharing measurements can improve their decisions, but the shared data take time to arrive.\n\nThe paper asks when fresh local information gives lower team loss, what an old shared summary adds to fresh local information, and how often updates are worth sending.',
    'Imagine several sensors tracking one changing temperature. Their readings differ because each has its own measurement error. The agents want accurate actions and also want to avoid disagreeing too much.',
    'Use Next and Back, or the left and right arrow keys. The Contents menu lets you jump to any symbol, claim, or proof step. Use A− and A+ or the size selector to adjust the text. “Why this is true” shows the intermediate algebra and reasoning. You can collapse it for a shorter view.',source='Too Late to Coordinate: When Local Information Beats Global Sharing')
add(c,'what-is-decided','What are the agents deciding?',r'Agent $i$ chooses a real-valued action $u_i(t)$ to track the common signal $X(t)$.\n\n'.replace(r'\n\n','\n\n')+'An action can be any function of the information available to that agent, provided its second moment is finite.',
    'The action might be an estimate or a tracking decision. Each agent chooses its own action. The team evaluates those actions together, including their disagreement.',
    'Actions do not change the signal or future observations. This is why the paper solves a static team problem at each time, even though the information changes over time.')
add(c,'two-comparisons','Keep the two comparisons separate',
    'Comparison 1: fresh local information versus a complete delayed pool used alone.\n\nComparison 2: fresh local information versus a hybrid that adds an old shared summary.',
    'In the first comparison, the globally shared data may be so old that the local team does better.',
    'In the second comparison, fresh local readings remain available. The old pool improves decision loss at every finite age. Whether that improvement justifies paying for updates is a separate question.',source='Introduction · Main comparisons')
add(c,'what-to-expect','The results you will reach',
    '1. Exact optimal local and pooled decisions.\n\n2. A delay threshold where local decisions beat the delayed pool alone.\n\n3. A scalar hybrid summary with an exact exponential benefit.\n\n4. Extensions to unequal sensor quality and independent components.\n\n5. Optimal refresh decisions under a communication price.',
    'The proofs follow this order. First establish the two fresh benchmarks. Then compare a delayed pool against them. Finally use the hybrid benefit to decide how often communication is worth paying for.',source='Introduction · Contributions')

c=chapter('2. Notation & assumptions')
add(c,'agents','Agents, indices, and averages',r'$n\ge2$ is the number of agents. Indices $i,j\in\{1,\ldots,n\}$ identify agents.\n\n\[\bar u=\frac1n\sum_i u_i,\qquad \bar Y=\frac1n\sum_iY_i.\]'.replace(r'\n\n','\n\n'),
    'A bar means the arithmetic average over all agents. The average action and the average sensor reading are different quantities. A sum over i includes every agent.')
add(c,'signal-and-reading','Signal, sensor error, and reading',r'\[Y_i(t)=X(t)+E_i(t).\] $X(t)$ is the common signal. $E_i(t)$ is sensor $i$’s disturbance. $Y_i(t)$ is its observed reading.',
    'All sensors are looking at the same underlying quantity. Their errors are independent of one another and of the signal. The sensors themselves are correlated because they share X.',
    'Mean zero is a statistical model assumption. It does not mean the realized signal is always zero. A current reading helps predict the current realization.')
add(c,'time','Collection time and decision time',r'$t$ is the decision time. $s$ is the time the shared measurements were collected.\[\tau=t-s\ge0.\] The letter also uses $r$ for an arbitrary observation time.',
    'Age τ measures how old the shared information is at the moment an action is chosen. In the proof, r lets us check every reading along a history rather than just two endpoints.')
add(c,'variance-parameters','The variance parameters a and b',r'\[\Var(X(t))=a>0,\qquad\Var(E_i(t))=b>0.\]',
    'Variance measures the size of fluctuations. The parameter a measures signal variability. The parameter b measures sensor-error variability. Initially every sensor has the same error variance; the later extension allows b_i to differ.')
add(c,'rate','Temporal rate and coherence time',r'\[\Cov(X(t),X(s))=a e^{-\lambda|t-s|}.\]\[\Cov(E_i(t),E_i(s))=b e^{-\lambda|t-s|}.\] Here $\lambda>0$ is the common decay rate. The coherence time is $1/\lambda$.',
    'A larger λ means information becomes stale faster. After one coherence time, the correlation with the old signal has fallen to e⁻¹, about 0.368.',
    'The sensor errors are temporally correlated too. Their rate is the same as the signal rate within this model. This assumption is used in the full-history proofs.')
add(c,'ou','What an Ornstein–Uhlenbeck model gives',r'For $t\ge s$, write $\rho=e^{-\lambda(t-s)}$. Then\[X(t)=\rho X(s)+\xi_{s,t}.\] The new innovation $\xi_{s,t}$ is independent of the past and has variance $a(1-\rho^2)$.',
    'An Ornstein–Uhlenbeck process is a continuous-time Gaussian model that tends back toward its mean. Its current value predicts the future with an exponentially shrinking weight.',
    'The new innovation represents what happened after s that the old history could not predict. Each sensor disturbance admits the same kind of decomposition.')
add(c,'rho','The surviving correlation ρ',r'\[\rho=e^{-\lambda\tau},\qquad 0<\rho\le1.\] At zero age $\rho=1$. As age tends to infinity, $\rho$ tends to zero.',
    'Rho is the fraction of the old signal that remains in its conditional prediction. The central value law will involve ρ² because the objective is quadratic.',
    'The value ρ = 0 describes an infinite-age limit. Finite ages have strictly positive correlation.')
add(c,'expectation','Expectation and conditional expectation',r'$\mathbb E[Z]$ is the average of a random quantity $Z$.\n\n$\mathbb E[Z\mid\mathcal G]$ is its conditional expectation given information $\mathcal G$.'.replace(r'\n\n','\n\n'),
    'Conditional expectation is the best prediction of Z, under squared error, using the information in the conditioning bar.',
    'The proof often averages what an agent cannot observe. It does not assume the agent has access to the unobserved values.')
add(c,'covariance','Variance, covariance, and independence',r'\[\Var(Z)=\mathbb E[(Z-\mathbb E Z)^2].\]\[\Cov(Z,W)=\mathbb E[(Z-\mathbb E Z)(W-\mathbb E W)].\]',
    'Variance measures uncertainty in one quantity. Covariance measures how two quantities fluctuate together.',
    'In a jointly Gaussian family, a residual with zero covariance with every observed variable is independent of the information generated by those observations. The proofs repeatedly use this Gaussian property.')
add(c,'information-fields','A sigma-field represents available information',r'$\sigma\{Y_i(r):r\le t\}$ denotes all information generated by the listed observations.\n\n$\mathcal A\vee\mathcal B$ combines two information fields.'.replace(r'\n\n','\n\n'),
    'Read σ{…} as “everything the listed observations reveal.” It is a precise way to specify which decision rules an agent may use.',
    'A larger information field allows more policies. Its optimal cost can only stay the same or decrease, because an agent can ignore additional observations.')
add(c,'histories','Local history and complete sensor history',r'\[\mathcal F_i(t)=\sigma\{Y_i(r):r\le t\}.\]\[\mathcal F(t)=\bigvee_i\mathcal F_i(t).\]',
    'The subscript i means one agent’s own sensor history. Without the subscript, F(t) contains all sensors’ histories through t.',
    'These definitions permit the entire history. A proof must establish when only the latest reading is sufficient.')
add(c,'l2','Policies with finite second moment',r'$u_i\in L^2(\mathcal G_i)$ means $u_i$ is measurable using $\mathcal G_i$ and $\mathbb E[u_i^2]<\infty$.\n\n“Almost surely” means with probability one.'.replace(r'\n\n','\n\n'),
    'The information constraint and the finite-cost condition are both part of admissibility. Policies may be nonlinear and may depend on histories.',
    'Two policies can differ on a probability-zero event and still count as the same optimal policy for expected loss.')
add(c,'loss','Accuracy and agreement share one objective',r'\[\ell(u,X)=\frac1n\sum_i(u_i-X)^2+\frac\kappa n\sum_i(u_i-\bar u)^2.\]\[\kappa\ge0.\]',
    'The first term penalizes each action’s error relative to the true signal. The second penalizes differences between the agents’ actions.',
    'Kappa sets the price of disagreement. At κ = 0, each agent only cares about accuracy. Positive κ makes coordinating the actions valuable.')
add(c,'costs','Optimal team costs and posterior variances',r'$J_L,J_P,J_D(\tau),J_H(\tau)$ are minimum expected team losses.\n\n$P_1,P_n,P_H(\tau)$ are conditional estimation-error variances.'.replace(r'\n\n','\n\n'),
    'J includes tracking error and disagreement. P measures how well the signal can be estimated from the specified information.',
    'For fresh pooling, everyone uses the same estimate, so J_P = Pₙ. For local operation with a disagreement penalty, the best team action generally differs from the best local estimate.')
add(c,'v-and-d','The two useful combinations v and d',r'\[v=a+\frac bn.\]\[d=a+b\left[1+\kappa\left(1-\frac1n\right)\right].\]',
    'The variance of the pooled mean is v. Averaging the independent sensor errors reduces their contribution from b to b/n.',
    'The quantity d is the quadratic coefficient for a common local gain. It combines tracking uncertainty and the cost of disagreement. The model gives d > v > 0.')
add(c,'delta','The value available from fresh sharing',r'\[\Delta=J_L-J_P=\frac{a^2(d-v)}{vd}>0.\]\[J_L-J_H(\tau)\quad\text{is the coordination value at age }\tau.\]',
    'Delta measures how much fresh pooling improves the team over fresh local operation. It includes both estimation and agreement benefits.',
    'The hybrid benefit is compared with this same Δ, making it meaningful to ask what fraction of fresh-sharing value survives delay.')
add(c,'matrix-notation','Vectors, matrices, and residual notation',r'$Z=(Z_1,\ldots,Z_n)$ is the sensor-innovation vector. $\mathbf1$ is the all-ones column vector, $I$ is the identity matrix, and ${}^\top$ means transpose.\n\n$\operatorname{diag}(b_i)$ is a diagonal matrix with entries $b_i$.'.replace(r'\n\n','\n\n'),
    'A covariance matrix lists every pairwise covariance. The matrix a11ᵀ puts the common-signal covariance a in every entry. Adding a diagonal matrix supplies the independent sensor errors.',
    'The symbol η denotes the signal residual after pooled estimation. The letter w in the optimality proof denotes a policy perturbation, while w_m later denotes a positive component weight.')

c=chapter('3. Four information architectures')
add(c,'fresh-local','Fresh local',r'Agent $i$ has $\mathcal F_i(t)$.\n\nIts optimal action uses $Y_i(t)$:\[u_i^L(t)=\frac adY_i(t).\]'.replace(r'\n\n','\n\n'),
    'Each agent can use its own measurements through the current time. No shared measurements are needed.',
    'The fact that the optimal action needs only the current reading is a result of the common-rate model. It is proved in Proposition 1.')
add(c,'fresh-pooled','Fresh pooled',r'Every agent has $\mathcal F(t)$.\n\nThe optimal action is common:\[u_i^P(t)=\frac av\bar Y(t).\]'.replace(r'\n\n','\n\n'),
    'Every sensor’s data are available immediately to everyone. This is the ideal fresh-sharing benchmark.',
    'The optimum uses the average reading rather than the full vector. All agents choose the same action and incur zero disagreement cost.')
add(c,'delayed-only','Delayed pool used alone',r'Every agent has $\mathcal F(s)$, where $s=t-\tau$. No measurement after $s$ is available.\[u_i^D(t)=\rho\frac av\bar Y(s).\]',
    'The shared information is complete: it contains every sensor’s history through the old timestamp s. “Pool” does not impose compression in this comparison.',
    'The optimized action predicts the old pooled estimate forward. This architecture can lose to fresh local operation because it lacks the newer local observations.')
add(c,'hybrid','Hybrid: old shared information and fresh local data',r'\[\mathcal H_i(t;s)=\mathcal F_i(t)\vee\sigma\{\bar Y(r):r\le s\}.\] Sufficient data for the optimal action are\[Y_i(t),\qquad Y_i(s),\qquad \bar Y(s).\]',
    'Each agent keeps its fresh local observations while shared data age. It also retains its own measurement from the time the shared pool was sampled.',
    'Theorem 1 proves that a single old shared mean, together with these own-sensor readings, achieves the same optimum as complete delayed sensor sharing.')

CLAIM_NOTES={
'L':['This lemma gives an exact test for team optimality. The agent balances tracking the signal against anticipating the other agents’ average action.','A proposed policy that passes this test is optimal among all allowed square-integrable policies. The proof also establishes uniqueness.'],
'P':['These are the fresh local and fresh pooled benchmarks. The formulas state both how to act and what expected loss those optimal actions achieve.','Posterior variances measure estimation uncertainty. Team losses also include the disagreement objective. Delta is the positive improvement from fresh pooling.'],
'D':['There is an exact age beyond which fresh local decisions beat optimal decisions based only on complete delayed information. Both decision rules are optimized.','Every delayed-only agent agrees perfectly. Beyond the threshold, the extra tracking error costs more than the agreement saves.'],
'H':['The action has two parts: everyone uses the same prediction from the old pool, then each agent adds a correction from its own new information.','The theorem proves this policy is optimal even against complete delayed sensor sharing. Its improvement over local operation is exactly the fresh-pooling improvement multiplied by e^(−2λτ).'],
'U':['This result allows the sensors to have different error variances. More accurate sensors receive larger weights in the shared estimate.','The same hybrid cost law survives. The signal and all sensor disturbances must still share a common temporal rate.'],
'C':['When the task contains independent components, each can use its own optimal policy. Their positive weighted gains add.','Components may have different temporal rates and different ages. Independence is what permits this separation.'],
'R':['An update’s lifetime benefit sets the critical communication price. At or above that price, no refreshing is optimal.','Below it, one positive periodic interval minimizes average cost. A periodic schedule with that interval is optimal even among all irregular or randomized schedules independent of the sensor processes.']}

def formal(c,id):
    p=next(p for p in PROOFS if p['id']==id)
    add(c,'claim-'+id,p['name'],p['contract'],*CLAIM_NOTES[id],source='Claim · Paper equations '+p['eqs'])
    for s in p['steps']:
        title,note=NOTES[s['id']]
        body=s['statement']
        if s['id']=='D.3':body=r'\[J_D(\tau)=a-\frac{a^2}{v}e^{-2\lambda\tau}.\]'
        if s['id']=='D.5':body=r'\[\tau_{\rm cross}=\frac1{2\lambda}\log\frac dv.\]\[J_L<J_D(\tau)\quad\Longleftrightarrow\quad\tau>\tau_{\rm cross}.\] At equality, the two costs coincide.'
        if s['id']=='U.2':body=r'\[\bar k=\frac{a\theta}{1-\kappa a\theta},\qquad k_i=\frac{a}{C_i(1-\kappa a\theta)}.\]'
        if s['id']=='U.6':body=r'\[P=\left(a^{-1}+\sum_i b_i^{-1}\right)^{-1}.\]\[\mu_P(t)=P\sum_i\frac{Y_i(t)}{b_i},\qquad J_P=P.\]'
        if s['id']=='R.4.3':body=r'At $H(T^*)=c$,\[c-B(T^*)=-T^*V_\delta(T^*).\] Hence\[C(T^*)=J_L^{\rm tot}-\sum_m A_m e^{-\gamma_m T^*}.\]'
        if s['id']=='D.6':body='The delayed-only policy, its minimum loss, and the exact crossover threshold are established.'
        if s['id']=='U.13':body='The unequal-quality policies, posterior variance, and hybrid cost law are established.'
        add(c,'proof-'+s['id'].replace('.','-'),title,body,note,source=p['name']+' · Proof step '+s['id'])

c=chapter('4. The optimality test');formal(c,'L')
c=chapter('5. Fresh local & fresh pooled');formal(c,'P')
add(c,'local-estimation-gap','Why local team loss exceeds local estimation error',r'\[J_L-P_1=\frac{\kappa a^2b(1-1/n)}{(a+b)d}.\]',
    'A local estimator would put gain a/(a+b) on its reading. With a disagreement penalty, the optimal local team gain is a/d instead. This reduces disagreement at the expense of some tracking accuracy.',
    'The gap is zero when κ = 0. It is positive when κ > 0 under the paper’s nondegenerate sensor model.',source='Derived claim · Equation (12)')
c=chapter('6. The delay crossover');formal(c,'D')
add(c,'threshold-dependence','What moves the crossover?',r'\[\tau_{\rm cross}=\frac{\log(d/v)}{2\lambda}.\] Increasing $\kappa$ increases $d$. Increasing $\lambda$ shortens the time scale.',
    'If disagreement is more costly, an old common estimate remains competitive for longer. If the signal changes faster, its shared information loses value sooner.',
    'These comparisons hold with the other parameters fixed. They concern delayed information used alone.',source='Section III-A · Threshold interpretation')
c=chapter('7. The hybrid theorem');formal(c,'H')
add(c,'hybrid-implementation','How to compute the hybrid action',r'\[u_i^H(t)=\underbrace{\rho\frac av\bar Y(s)}_{\text{shared prediction}}+\underbrace{\frac ad\bigl[Y_i(t)-\rho Y_i(s)\bigr]}_{\text{local correction}}.\]',
    'Predict the old pooled estimate forward. Then subtract the predicted old local reading from the current local reading, and scale that innovation by the local team gain.',
    'Keeping Y_i(s) lets the agent separate its new information from the part predicted by its own old reading. A timestamped local buffer supports this when updates are in transit.',source='Implementation of Theorem 1 · Equation (15)')
add(c,'age-budget','An exact budget for information age',r'For $0<\alpha<1$,\[J_L-J_H(\tau)\ge\alpha\Delta\quad\Longleftrightarrow\quad\tau\le\frac{\log(1/\alpha)}{2\lambda}.\]',
    'Choose the fraction of fresh-sharing benefit you want to preserve. This formula gives the largest permitted age.',
    'The fraction depends only on age and temporal rate. The amount of benefit Δ still depends on sensor count, variances, and the disagreement penalty.',source='Derived claim · Equation (22)')
add(c,'half-life','The benefit has half the correlation half-life',r'\[t_{1/2}^{\rm value}=\frac{\log2}{2\lambda}.\]\[t_{1/2}^{\rm correlation}=\frac{\log2}{\lambda}.\]',
    'The signal correlation decays as e^(−λτ), while coordination value decays as its square. The value therefore falls by half in half the time needed for correlation to fall by half.',
    'Half-life and coherence time are different conventions. The coherence time 1/λ corresponds to correlation e⁻¹, rather than one half.',source='Section III-B · Half-life interpretation')

c=chapter('8. Unequal sensor quality')
add(c,'unequal-notation','The new symbols for unequal sensors',r'\[\Var(E_i(t))=b_i>0.\]\[C_i=(1+\kappa)a+b_i[1+\kappa(1-1/n)].\]\[\theta=\frac1n\sum_i C_i^{-1}.\]',
    'The common variance b becomes an individual variance b_i. The quantity C_i is a coefficient in the coupled local-gain equations. Theta averages its reciprocal across sensors.',
    'Capital C_i here is a sensor coefficient. Later C(T) will denote the total average cost of periodic refreshing. They are different quantities.',source='Section IV-A · Equation (23)')
formal(c,'U')
c=chapter('9. Independent components')
add(c,'components-notation','Several quantities on different time scales',r'$m\in\{1,\ldots,M\}$ indexes independent components. Agent $i$ chooses $(u_{i1},\ldots,u_{iM})$.\n\nComponent $m$ has parameters $(a_m,b_m,\kappa_m,\lambda_m)$, weight $w_m>0$, and summary age $\tau_m$.'.replace(r'\n\n','\n\n'),
    'For example, a task could combine a fast-changing quantity and a slowly changing independent quantity. The weight says how much each component matters in the overall loss.',
    'Each component has its own common within-component rate. The theorem allows different rates across components, not between a component’s signal and its sensor disturbances.',source='Section IV-B · Component model')
formal(c,'C')
add(c,'effective-decay','A mixture of rates changes its effective decay',r'At a common age $\tau$,\[V(\tau)=\sum_m w_m\Delta_m e^{-2\lambda_m\tau}.\]\[-\frac{V^{\prime}(\tau)}{V(\tau)}=\frac{\sum_m2\lambda_m w_m\Delta_m e^{-2\lambda_m\tau}}{\sum_m w_m\Delta_m e^{-2\lambda_m\tau}}.\]',
    'The effective rate is an average of the component rates, weighted by the benefit each component still has at that age.',
    'As information gets older, the fast-decaying components lose weight more quickly. Slow components therefore account for a growing share of the remaining benefit.',source='Derived claim · Equation (27)')

c=chapter('10. Refresh notation & cost')
add(c,'refresh-service','What one communication update contains',r'A refresh sends the pooled vector\[(\bar Y_1(s),\ldots,\bar Y_M(s)).\] All components are sampled at time $s$ and arrive after a fixed latency $\delta\ge0$.',
    'The update contains one pooled mean per component, sampled at the same time. Its age is already δ when it arrives.',
    'Agents keep using their fresh local observations while waiting. The service can support the selected transmission times without queueing, and agents retain the local samples matching each update’s timestamp.',source='Section V · Communication model')
add(c,'price-and-period','Price c, latency δ, and refresh interval T',r'$c>0$ is the price of one complete pooled-vector update. $\delta$ is its fixed communication latency. $T>0$ is the interval between consecutive periodic updates.',
    'The price is measured in units of accumulated team loss, so it can be added to the loss integrated over time.',
    'Latency and interval are different. Latency is how long a message takes to arrive. The interval is how often a new update is sent. The model allows messages in transit concurrently.',source='Section V · Communication model')
add(c,'schedule-class','Which schedules are included?',
    'Schedules may be deterministic or randomized, provided they are independent of all signal and sensor-disturbance processes.\n\nThey must be locally finite: every bounded time interval contains only finitely many transmissions.',
    'The theorem covers irregular schedules as well as periodic ones. A schedule can be selected independently of the sensor values.',
    'A rule such as “send when the current reading changes a lot” is observation-dependent and is outside this theorem. Conditioning on that kind of schedule would also reveal information about the signal.',source='Section V · Scope of Theorem 2')
add(c,'amplitudes','Benefit remaining when an update arrives',r'\[\gamma_m=2\lambda_m.\]\[A_m=w_m\Delta_m e^{-\gamma_m\delta}.\]\[V_\delta(r)=\sum_m A_m e^{-\gamma_m r}.\]',
    'Gamma is the coordination-value decay rate for a component. A_m is that component’s weighted benefit at reception, after the delivery delay.',
    'Here r is time elapsed since reception. The total age of the underlying shared data is δ + r.',source='Section V · Equation (28) and proof notation')
add(c,'integrated-benefit','Integrate the benefit over one interval',r'\[B(T)=\int_0^T V_\delta(r)\,dr=\sum_m\frac{A_m}{\gamma_m}(1-e^{-\gamma_mT}).\]',
    'An update helps throughout the interval until the next one arrives. Integrating its instantaneous improvement gives the total benefit accumulated in that interval.',
    'Because the benefit decays exponentially, even an infinitely long interval yields only a finite total benefit.',source='Section V · Equation (28)')
add(c,'periodic-cost','Average cost of periodic refreshing',r'\[C(T)=J_L^{\rm tot}+\frac{c-B(T)}{T}.\]\[J_L^{\rm tot}=\sum_m w_mJ_{L,m}.\]',
    'Start with the average loss of local operation. Every interval pays c and saves B(T). Divide their difference by the interval length to get the average adjustment.',
    'A negative adjustment means communication improves total average cost. A positive adjustment means the price exceeds the interval’s decision benefit.',source='Section V · Equation (29)')
add(c,'critical-price','The lifetime benefit sets the critical price',r'\[c_{\rm crit}=\sum_m\frac{A_m}{\gamma_m}=\int_0^\infty V_\delta(r)\,dr.\]',
    'This is the maximum total benefit a received update could provide over its remaining lifetime.',
    'If its price reaches or exceeds that amount, refreshing cannot improve the long-run objective. If the price is smaller, an appropriate refresh interval yields a net improvement.',source='Theorem 2 · Equation (30)')
add(c,'optimization-symbols','The optimization notation in the proof',r'$T^*$ is an optimal positive period. $H(T)=B(T)-TB^{\prime}(T)$. A prime denotes a derivative.\n\n$\inf$ is an infimum, or greatest lower bound. $\limsup$ is a limiting upper value. $R$ is the observation horizon and $T_j$ is the length of its $j$th complete reception interval.'.replace(r'\n\n','\n\n'),
    'H is the auxiliary function that determines whether changing the refresh interval helps. It is unrelated to the information field written as calligraphic H_i.',
    'The general-schedule proof uses longer and longer horizons R. Its auxiliary number g is the best periodic excess cost per unit time, also allowing the zero excess cost of never updating.',source='Theorem 2 · Proof notation')
c=chapter('11. The optimal refresh theorem');formal(c,'R')
add(c,'scalar-refresh','The single-component period equation',r'\[x=2\lambda T^*,\qquad\chi=\frac{c}{c_{\rm crit}}.\]\[1-(1+x)e^{-x}=\chi,\qquad0<\chi<1.\]',
    'The best interval can be found by solving one increasing scalar equation. The variables x and χ express time and price in dimensionless form.',
    'As the price approaches its critical value from below, the best interval grows without bound. Updates become increasingly rare.',source='Derived claim · Equation (34)')
add(c,'latency-cutoff','A cutoff in communication latency',r'For one component of unit weight,\[\delta_{\rm stop}=\max\left\{0,\frac1{2\lambda}\log\frac{\Delta}{2\lambda c}\right\}.\] No refreshing is optimal when $\delta\ge\delta_{\rm stop}$.',
    'Longer delivery latency consumes more of an update’s useful lifetime before it can be used. This formula turns the price condition into a latency condition.',
    'The maximum with zero handles prices so high that even instantaneous communication is not worthwhile.',source='Derived claim · Equation (35)')
add(c,'minimum-interval','If the service limits the update rate',r'When $0<c<c_{\rm crit}$ and intervals must satisfy $T\ge T_{\min}>0$, the optimal feasible period is\[\max\{T_{\min},T^*\}.\]',
    'If the unconstrained best interval is already allowed, use it. If it is too short for the service, use the shortest permitted interval.',
    'The no-refresh price threshold stays the same. Below it, sufficiently long feasible intervals can still provide a net improvement.',source='Section V · Minimum-interval consequence')

c=chapter('12. Discrete time & model limits')
add(c,'discrete-model','The discrete-time counterpart',r'For stationary Gaussian AR(1) processes with a common coefficient $q\in(0,1)$,\[X_{t+1}=qX_t+\xi_t.\] At integer age $k\ge0$, replace $\rho$ by $q^k$.',
    'An AR(1) process is the discrete-time analogue used here: next time’s value is a fraction of the current value plus a new independent Gaussian innovation.',
    'The sensor disturbances must share the same coefficient within the component. Their innovation variances are chosen to keep the stated stationary variances.',source='Section III-B · Discrete-time extension')
add(c,'discrete-proof','Why the endpoint and hybrid laws carry over',r'For integer $s<r\le t$,\[\Cov(Z_j(t),Z_i(r))=\Sigma_{ji}q^{t-r}(1-q^{2(r-s)}).\]\[J_H(k)=q^{2k}J_P+(1-q^{2k})J_L.\]',
    'The same covariance proportionality holds at every intermediate integer time. The projection and team-equation argument therefore goes through with q^k replacing the continuous exponential.',
    'The coordination gain is Δq^(2k). The symbol k here denotes an integer age; in the hybrid proof, k = a/d denoted a policy gain. These uses occur in different contexts.',source='Section III-B · Discrete-time proof consequence')
add(c,'discrete-refresh','Refresh sums replace refresh integrals',r'For a discrete reception interval of $N$ slots, the accumulated benefit is\[\sum_m A_m\frac{1-q_m^{2N}}{1-q_m^2}.\]',
    'In discrete time, add the benefits slot by slot. This geometric sum replaces the continuous-time integral B(T).',
    'The paper transfers the endpoint and pooling laws to discrete time. Its continuous positive-period equation is not asserted unchanged for integer refresh periods.',source='Section III-B · Scope of the discrete-time extension')
add(c,'white-noise','Why white measurement noise changes the problem',r'With temporally independent measurement noise and a signal with one-step correlation $q>0$,\[\Cov\left(X_t-\frac{a}{a+b}Y_{i,t},Y_{i,t-1}\right)=\frac{abq}{a+b}>0.\]',
    'The error after using only the current reading is still correlated with an older reading. That older reading contains useful information, so the one-reading reduction fails in this model.',
    'A Gaussian recursive estimator generally needs to carry forward information from past readings. This explains why the paper specifies temporally correlated errors with the common rate.',source='Section II-A · Model qualification')
add(c,'scope','What the results assume',
    'A common Gaussian signal, independent sensor disturbances, and a common temporal rate within each component.\n\nQuadratic tracking and disagreement loss. Actions do not affect observations.\n\nExact real-valued summaries. Independent components in the multirate extension. Observation-independent schedules in the refresh theorem.',
    'These assumptions make the exact formulas possible. Unequal sensor quality is covered. Different signal and disturbance rates within one component require further analysis.',
    'The scalar result is about sufficient information for this model. It does not optimize finite-bit encodings or observation-triggered communication protocols.',source='Conclusion · Scope of the letter')

c=chapter('13. Numerical examples')
add(c,'numerical-endpoints','The eight-sensor example',r'$n=8$, $a=b=1$, $\kappa=1$, and $\lambda=1$.\[P_1=0.5,\qquad J_P=\frac19.\]\[J_L=\frac{15}{23}\simeq0.6522,\qquad\Delta=\frac{112}{207}\simeq0.5411.\]',
    'These numbers give the fresh endpoints used in the plots. Fresh pooling substantially lowers loss in this example.',
    'The crossover occurs at age about 0.4691. At age one, the delayed-only cost is about 0.8797. Fresh local loss is about 25.9% lower than that delayed-only loss.',source='Section VI · First example')
add(c,'numerical-decay','Read the crossover and decay figure',r'\[\lambda\tau_{\rm cross}\simeq0.4691.\]\[J_H(0.5)\simeq0.4531.\] At age $0.5$, the remaining fraction of fresh-sharing value is $e^{-1}\simeq36.8\%$.',
    'The top panel compares optimized team losses. The delayed-only curve crosses above the fresh-local benchmark. The hybrid curve remains below the local benchmark.',
    'The lower panel divides the hybrid improvement by Δ. Different parameter settings follow the same exponential fraction. The markers are Monte Carlo estimates.',source='Section VI · Figure 1',image='pooling_decay.svg',alt='Top panel: delayed-only loss crosses the local benchmark while hybrid loss stays below it. Bottom panel: normalized hybrid benefit follows an exponential curve.')
add(c,'numerical-refresh','Read the periodic-refresh figure',r'For $\delta=0.1$,\[c_{\rm crit}\simeq0.2215.\] At half this price,\[T^*\simeq0.8392,\qquad C(T^*)\simeq0.5695.\]',
    'Each curve is total average cost for the hybrid architecture at a different price. The dashed line is local operation with no updates.',
    'Prices below the threshold give a finite minimizing interval. The curve above the threshold never beats the no-refresh benchmark.',source='Section VI · Figure 2',image='refresh_cost.svg',alt='Average hybrid loss plus communication price versus refresh interval, with finite minima below the critical price and a no-refresh reference line.')
add(c,'numerical-multirate','A slower component can dominate the refresh decision',r'Add an independent component with $(a_2,b_2,\lambda_2)=(0.4,0.8,0.12)$, $\kappa_2=1$, and unit weights.\n\nAt latency $0.1$,\[c_{\rm crit}\simeq1.1807.\] At half that price,\[T^*\simeq5.5513,\qquad C(T^*)\simeq0.9072.\]'.replace(r'\n\n','\n\n'),
    'The slow component supplies 34.2% of the benefit at reception but 81.2% of its lifetime integral. Its benefit lasts longer.',
    'This is why the refresh decision depends on both the amount of information value and how long it persists.',source='Section VI · Two-component example')
add(c,'numerical-checks','What the numerical checks establish',
    'The manuscript solves 83 Gaussian-team systems from observation covariances. The maximum cost discrepancy is below 2.7 × 10⁻¹⁵.\n\nEach simulation marker uses 120,000 independent stationary Gaussian sample pairs.',
    'The linear-system checks independently compare optimized finite-dimensional policies with the formulas. They are a useful check on algebra and implementation.',
    'The proofs establish the claims about full observation histories and all permitted schedules. Numerical examples alone would not establish those universal statements.',source='Section VI · Reproducibility')

c=chapter('14. Review the main ideas')
add(c,'review','Three results to keep in view',r'\[\tau>\frac{\log(d/v)}{2\lambda}\quad\Longrightarrow\quad J_L<J_D(\tau).\]\[J_L-J_H(\tau)=\Delta e^{-2\lambda\tau}.\]\[c_{\rm crit}=\sum_m\frac{w_m\Delta_m e^{-2\lambda_m\delta}}{2\lambda_m}.\]',
    'Fresh local decisions can beat complete delayed information used alone. Keeping fresh local information alongside an old shared summary gives an exactly quantified improvement.',
    'Integrating that improvement determines whether communication is worth its price and, below the threshold, how often to refresh.',source='Review · Corollary 1, Theorem 1, and Theorem 2')
add(c,'finish','You have reached the end of the guide',
    'The Contents menu lets you return directly to a definition, theorem, or proof step.\n\nThe six-page manuscript and the full Lamport proof report are available from the same menu.',
    'The main mathematical work is now connected: conditional team optimality gives the policies, Gaussian covariance gives the history reductions, and interval accounting gives the scheduling theorem.',
    'The guide follows the current manuscript and its verified proof structure. The linked report records the exact mathematical assumptions and proof dependencies.',source='End of guided reading')

assert set(NOTES)=={s['id'] for p in PROOFS for s in p['steps']}
ids=[s['id'] for c in chapters for s in c['lessons']]
assert len(ids)==len(set(ids))
assert all(s['explain'] and all(s['explain']) for c in chapters for s in c['lessons'])
for c in chapters:
    for lesson in c['lessons']:
        if lesson['id'] in DETAILS:
            lesson['details']=DETAILS[lesson['id']]
assert set(DETAILS).issubset(ids)
assert all('proof-'+s['id'].replace('.','-') in DETAILS for p in PROOFS for s in p['steps'])
(ROOT/'dist/lessons.js').write_text('window.GUIDE = '+json.dumps({'chapters':chapters,'manuscript':json.loads((ROOT/'manuscript.json').read_text())},ensure_ascii=False,indent=2)+';\n')
print(json.dumps({'chapters':len(chapters),'lessons':len(ids),'formal_results':len(PROOFS),'proof_steps':len(NOTES)},indent=2))
