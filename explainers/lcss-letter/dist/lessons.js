window.GUIDE = {
  "chapters": [
    {
      "title": "1. The question",
      "lessons": [
        {
          "id": "start",
          "title": "When is sharing too slow?",
          "body": "This guide explains the six-page L-CSS submission manuscript, Too Late to Coordinate: When Local Information Beats Global Sharing. It has not been accepted for publication. It does not cover the full TINA arXiv manuscript.\n\nSeveral agents measure the same changing signal. Sharing measurements can improve their decisions, but the shared data take time to arrive.\n\nThe paper asks when fresh local information gives lower team loss, what an old shared summary adds to fresh local information, and how often updates are worth sending.",
          "explain": [
            "Imagine several sensors tracking one changing temperature. Their readings differ because each has its own measurement error. The agents want accurate actions and also want to avoid disagreeing too much.",
            "Use Next and Back, or the left and right arrow keys. The Contents menu lets you jump to any symbol, claim, or proof step. Use A− and A+ or the size selector to adjust the text. “Why this is true” shows the intermediate algebra and reasoning. You can collapse it for a shorter view."
          ],
          "source": "Too Late to Coordinate: When Local Information Beats Global Sharing"
        },
        {
          "id": "what-is-decided",
          "title": "What are the agents deciding?",
          "body": "Agent $i$ chooses a real-valued action $u_i(t)$ to track the common signal $X(t)$.\n\nAn action can be any function of the information available to that agent, provided its second moment is finite.",
          "explain": [
            "The action might be an estimate or a tracking decision. Each agent chooses its own action. The team evaluates those actions together, including their disagreement.",
            "Actions do not change the signal or future observations. This is why the paper solves a static team problem at each time, even though the information changes over time."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "two-comparisons",
          "title": "Keep the two comparisons separate",
          "body": "Comparison 1: fresh local information versus a complete delayed pool used alone.\n\nComparison 2: fresh local information versus a hybrid that adds an old shared summary.",
          "explain": [
            "In the first comparison, the globally shared data may be so old that the local team does better.",
            "In the second comparison, fresh local readings remain available. The old pool improves decision loss at every finite age. Whether that improvement justifies paying for updates is a separate question."
          ],
          "source": "Introduction · Main comparisons"
        },
        {
          "id": "what-to-expect",
          "title": "The results you will reach",
          "body": "1. Exact optimal local and pooled decisions.\n\n2. A delay threshold where local decisions beat the delayed pool alone.\n\n3. A scalar hybrid summary with an exact exponential benefit.\n\n4. Extensions to unequal sensor quality and independent components.\n\n5. Optimal refresh decisions under a communication price.",
          "explain": [
            "The proofs follow this order. First establish the two fresh benchmarks. Then compare a delayed pool against them. Finally use the hybrid benefit to decide how often communication is worth paying for."
          ],
          "source": "Introduction · Contributions"
        }
      ]
    },
    {
      "title": "2. Notation & assumptions",
      "lessons": [
        {
          "id": "agents",
          "title": "Agents, indices, and averages",
          "body": "$n\\ge2$ is the number of agents. Indices $i,j\\in\\{1,\\ldots,n\\}$ identify agents.\n\n\\[\\bar u=\\frac1n\\sum_i u_i,\\qquad \\bar Y=\\frac1n\\sum_iY_i.\\]",
          "explain": [
            "A bar means the arithmetic average over all agents. The average action and the average sensor reading are different quantities. A sum over i includes every agent."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "signal-and-reading",
          "title": "Signal, sensor error, and reading",
          "body": "\\[Y_i(t)=X(t)+E_i(t).\\] $X(t)$ is the common signal. $E_i(t)$ is sensor $i$’s disturbance. $Y_i(t)$ is its observed reading.",
          "explain": [
            "All sensors are looking at the same underlying quantity. Their errors are independent of one another and of the signal. The sensors themselves are correlated because they share X.",
            "Mean zero is a statistical model assumption. It does not mean the realized signal is always zero. A current reading helps predict the current realization."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Compute a reading’s variance",
              "body": "From $Y_i=X+E_i$, $\\Var(Y_i)=\\Var(X)+\\Var(E_i)+2\\Cov(X,E_i)$. Independence makes the covariance zero, leaving $a+b$."
            },
            {
              "title": "Compute the covariance of two sensors",
              "body": "For $i\\ne j$, expanding $\\Cov(X+E_i,X+E_j)$ gives four terms. Only $\\Cov(X,X)=a$ survives, because the errors are mutually independent and independent of $X$. Thus different readings have covariance $a$ even though their disturbances are independent."
            }
          ]
        },
        {
          "id": "time",
          "title": "Collection time and decision time",
          "body": "$t$ is the decision time. $s$ is the time the shared measurements were collected.\\[\\tau=t-s\\ge0.\\] The letter also uses $r$ for an arbitrary observation time.",
          "explain": [
            "Age τ measures how old the shared information is at the moment an action is chosen. In the proof, r lets us check every reading along a history rather than just two endpoints."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "variance-parameters",
          "title": "The variance parameters a and b",
          "body": "\\[\\Var(X(t))=a>0,\\qquad\\Var(E_i(t))=b>0.\\]",
          "explain": [
            "Variance measures the size of fluctuations. The parameter a measures signal variability. The parameter b measures sensor-error variability. Initially every sensor has the same error variance; the later extension allows b_i to differ."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "rate",
          "title": "Temporal rate and coherence time",
          "body": "\\[\\Cov(X(t),X(s))=a e^{-\\lambda|t-s|}.\\]\\[\\Cov(E_i(t),E_i(s))=b e^{-\\lambda|t-s|}.\\] Here $\\lambda>0$ is the common decay rate. The coherence time is $1/\\lambda$.",
          "explain": [
            "A larger λ means information becomes stale faster. After one coherence time, the correlation with the old signal has fallen to e⁻¹, about 0.368.",
            "The sensor errors are temporally correlated too. Their rate is the same as the signal rate within this model. This assumption is used in the full-history proofs."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "ou",
          "title": "What an Ornstein–Uhlenbeck model gives",
          "body": "For $t\\ge s$, write $\\rho=e^{-\\lambda(t-s)}$. Then\\[X(t)=\\rho X(s)+\\xi_{s,t}.\\] The new innovation $\\xi_{s,t}$ is independent of the past and has variance $a(1-\\rho^2)$.",
          "explain": [
            "An Ornstein–Uhlenbeck process is a continuous-time Gaussian model that tends back toward its mean. Its current value predicts the future with an exponentially shrinking weight.",
            "The new innovation represents what happened after s that the old history could not predict. Each sensor disturbance admits the same kind of decomposition."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Obtain the prediction coefficient",
              "body": "For jointly Gaussian $X(t),X(s)$, the centered regression coefficient is $\\Cov(X(t),X(s))/\\Var(X(s))=a\\rho/a=\\rho$. Define the prediction error $\\xi=X(t)-\\rho X(s)$."
            },
            {
              "title": "Compute the innovation variance and past independence",
              "body": "Its variance is $a-2\\rho(a\\rho)+\\rho^2a=a(1-\\rho^2)$. For every $r\\le s$,\n\\[\\Cov(\\xi,X(r))=a e^{-\\lambda(t-r)}-\\rho a e^{-\\lambda(s-r)}=0.\\]\nGaussianity makes the innovation independent of the signal’s past. Independence from sensor disturbances gives independence from the joint past used by the paper."
            }
          ]
        },
        {
          "id": "rho",
          "title": "The surviving correlation ρ",
          "body": "\\[\\rho=e^{-\\lambda\\tau},\\qquad 0<\\rho\\le1.\\] At zero age $\\rho=1$. As age tends to infinity, $\\rho$ tends to zero.",
          "explain": [
            "Rho is the fraction of the old signal that remains in its conditional prediction. The central value law will involve ρ² because the objective is quadratic.",
            "The value ρ = 0 describes an infinite-age limit. Finite ages have strictly positive correlation."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "expectation",
          "title": "Expectation and conditional expectation",
          "body": "$\\mathbb E[Z]$ is the average of a random quantity $Z$.\n\n$\\mathbb E[Z\\mid\\mathcal G]$ is its conditional expectation given information $\\mathcal G$.",
          "explain": [
            "Conditional expectation is the best prediction of Z, under squared error, using the information in the conditioning bar.",
            "The proof often averages what an agent cannot observe. It does not assume the agent has access to the unobserved values."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Express what conditional expectation preserves",
              "body": "The variable $m=\\E[Z\\mid\\mathcal G]$ is determined by $\\mathcal G$. For every square-integrable quantity $v$ determined by the same information, $\\E[v(Z-m)]=0$. The error has no component predictable from the available information."
            },
            {
              "title": "Derive the least-squares property",
              "body": "Write $Z-v=(Z-m)+(m-v)$ and expand its square. The cross term is zero by the preceding identity, so\n\\[\\E[(Z-v)^2]=\\E[(Z-m)^2]+\\E[(m-v)^2].\\]\nThe last term is nonnegative. Therefore $m$ has the smallest squared prediction error among estimates based on $\\mathcal G$."
            }
          ]
        },
        {
          "id": "covariance",
          "title": "Variance, covariance, and independence",
          "body": "\\[\\Var(Z)=\\mathbb E[(Z-\\mathbb E Z)^2].\\]\\[\\Cov(Z,W)=\\mathbb E[(Z-\\mathbb E Z)(W-\\mathbb E W)].\\]",
          "explain": [
            "Variance measures uncertainty in one quantity. Covariance measures how two quantities fluctuate together.",
            "In a jointly Gaussian family, a residual with zero covariance with every observed variable is independent of the information generated by those observations. The proofs repeatedly use this Gaussian property."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Explain the Gaussian independence step",
              "body": "A centered jointly Gaussian vector with covariance matrix $\\Sigma$ has characteristic function $\\exp(-z^\\top\\Sigma z/2)$. If the cross-covariance between two blocks is zero, $\\Sigma$ is block diagonal, so this exponential factors into the product of the two blocks’ characteristic functions. That factorization is independence."
            },
            {
              "title": "Explain its use for histories",
              "body": "The proof first shows a residual has zero covariance with every observed variable. It is then independent of every finite vector of those observations by the Gaussian block argument. Events described by finite vectors generate the observation sigma-field, so the independence extends to the full history. Without joint Gaussianity, zero covariance alone would not justify that conclusion."
            }
          ]
        },
        {
          "id": "information-fields",
          "title": "A sigma-field represents available information",
          "body": "$\\sigma\\{Y_i(r):r\\le t\\}$ denotes all information generated by the listed observations.\n\n$\\mathcal A\\vee\\mathcal B$ combines two information fields.",
          "explain": [
            "Read σ{…} as “everything the listed observations reveal.” It is a precise way to specify which decision rules an agent may use.",
            "A larger information field allows more policies. Its optimal cost can only stay the same or decrease, because an agent can ignore additional observations."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Translate measurability into a policy restriction",
              "body": "If $u_i$ is $\\mathcal G_i$-measurable, its value is determined by the information agent $i$ possesses. A formula involving an unobserved quantity is not feasible merely because it has a small cost."
            },
            {
              "title": "Derive the information-inclusion inequality",
              "body": "If $\\mathcal G_i\\subseteq\\mathcal H_i$ for every agent, every policy feasible under $\\mathcal G$ is feasible under $\\mathcal H$. Taking an infimum over a larger set can only lower or preserve its value. Thus $J^*(\\mathcal H)\\le J^*(\\mathcal G)$. Equality requires a separate sufficiency argument."
            }
          ]
        },
        {
          "id": "histories",
          "title": "Local history and complete sensor history",
          "body": "\\[\\mathcal F_i(t)=\\sigma\\{Y_i(r):r\\le t\\}.\\]\\[\\mathcal F(t)=\\bigvee_i\\mathcal F_i(t).\\]",
          "explain": [
            "The subscript i means one agent’s own sensor history. Without the subscript, F(t) contains all sensors’ histories through t.",
            "These definitions permit the entire history. A proof must establish when only the latest reading is sufficient."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "l2",
          "title": "Policies with finite second moment",
          "body": "$u_i\\in L^2(\\mathcal G_i)$ means $u_i$ is measurable using $\\mathcal G_i$ and $\\mathbb E[u_i^2]<\\infty$.\n\n“Almost surely” means with probability one.",
          "explain": [
            "The information constraint and the finite-cost condition are both part of admissibility. Policies may be nonlinear and may depend on histories.",
            "Two policies can differ on a probability-zero event and still count as the same optimal policy for expected loss."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Check that the policy space allows perturbations",
              "body": "If $u_i,w_i\\in L^2(\\mathcal G_i)$, their sum uses the same information and satisfies $\\E[(u_i+w_i)^2]\\le2\\E[u_i^2]+2\\E[w_i^2]<\\infty$. Multiplying $w_i$ by any finite real number also preserves feasibility. This is what permits the positive and negative perturbations in Lemma 1."
            },
            {
              "title": "Check the products used in the proof",
              "body": "Cauchy–Schwarz gives $\\E[|AB|]\\le\\sqrt{\\E[A^2]\\E[B^2]}$ for any two $L^2$ variables. Thus the residual–perturbation products in the expansion have finite expectation, even though the individual variables need not be bounded."
            }
          ]
        },
        {
          "id": "loss",
          "title": "Accuracy and agreement share one objective",
          "body": "\\[\\ell(u,X)=\\frac1n\\sum_i(u_i-X)^2+\\frac\\kappa n\\sum_i(u_i-\\bar u)^2.\\]\\[\\kappa\\ge0.\\]",
          "explain": [
            "The first term penalizes each action’s error relative to the true signal. The second penalizes differences between the agents’ actions.",
            "Kappa sets the price of disagreement. At κ = 0, each agent only cares about accuracy. Positive κ makes coordinating the actions valuable."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Show how the two penalties interact",
              "body": "For each realization, write $u_i-X=(u_i-\\bar u)+(\\bar u-X)$ and sum the expanded squares. The cross terms cancel because $\\sum_i(u_i-\\bar u)=0$. Hence\n\\[\\frac1n\\sum_i(u_i-X)^2=(\\bar u-X)^2+\\frac1n\\sum_i(u_i-\\bar u)^2.\\]"
            },
            {
              "title": "Rewrite the complete objective",
              "body": "The instantaneous team loss can also be written\n\\[\\ell(u,X)=(\\bar u-X)^2+\\frac{1+\\kappa}{n}\\sum_i(u_i-\\bar u)^2.\\]\nThe team therefore cares about the accuracy of its average action and the spread around that average. This equivalent expression also makes convexity visible."
            }
          ]
        },
        {
          "id": "costs",
          "title": "Optimal team costs and posterior variances",
          "body": "$J_L,J_P,J_D(\\tau),J_H(\\tau)$ are minimum expected team losses.\n\n$P_1,P_n,P_H(\\tau)$ are conditional estimation-error variances.",
          "explain": [
            "J includes tracking error and disagreement. P measures how well the signal can be estimated from the specified information.",
            "For fresh pooling, everyone uses the same estimate, so J_P = Pₙ. For local operation with a disagreement penalty, the best team action generally differs from the best local estimate."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Define posterior variance through a conditional estimate",
              "body": "For information $\\mathcal G$, let $\\widehat X=\\E[X\\mid\\mathcal G]$. The posterior variance is $\\E[(X-\\widehat X)^2\\mid\\mathcal G]$. In this jointly Gaussian model with fixed observation times, the projection residual is independent of the observations, so that variance is a deterministic number."
            },
            {
              "title": "Explain why J can differ from P",
              "body": "An agent’s posterior mean minimizes its own squared estimation error. The team objective also penalizes differences between actions. A team-optimal action may therefore depart from that posterior mean. With shared information, everyone can use the same posterior mean and have zero disagreement, giving $J_P=P_n$."
            }
          ]
        },
        {
          "id": "v-and-d",
          "title": "The two useful combinations v and d",
          "body": "\\[v=a+\\frac bn.\\]\\[d=a+b\\left[1+\\kappa\\left(1-\\frac1n\\right)\\right].\\]",
          "explain": [
            "The variance of the pooled mean is v. Averaging the independent sensor errors reduces their contribution from b to b/n.",
            "The quantity d is the quadratic coefficient for a common local gain. It combines tracking uncertainty and the cost of disagreement. The model gives d > v > 0."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Derive v from averaging sensor errors",
              "body": "Since $\\bar Y=X+n^{-1}\\sum_iE_i$ and errors are independent,\n\\[\\Var(\\bar Y)=a+\\frac1{n^2}\\sum_i b=a+\\frac bn=v.\\]"
            },
            {
              "title": "Derive d from the team objective",
              "body": "For a common local gain $u_i=kY_i$, tracking loss is $a-2ak+k^2(a+b)$. Disagreement adds $\\kappa k^2b(1-1/n)$. The coefficient of $k^2$ is therefore $a+b+\\kappa b(1-1/n)=d$. Thus $v$ is a variance, while $d$ also includes the decision penalty."
            }
          ]
        },
        {
          "id": "delta",
          "title": "The value available from fresh sharing",
          "body": "\\[\\Delta=J_L-J_P=\\frac{a^2(d-v)}{vd}>0.\\]\\[J_L-J_H(\\tau)\\quad\\text{is the coordination value at age }\\tau.\\]",
          "explain": [
            "Delta measures how much fresh pooling improves the team over fresh local operation. It includes both estimation and agreement benefits.",
            "The hybrid benefit is compared with this same Δ, making it meaningful to ask what fraction of fresh-sharing value survives delay."
          ],
          "source": "Notation and model · Section II"
        },
        {
          "id": "matrix-notation",
          "title": "Vectors, matrices, and residual notation",
          "body": "$Z=(Z_1,\\ldots,Z_n)$ is the sensor-innovation vector. $\\mathbf1$ is the all-ones column vector, $I$ is the identity matrix, and ${}^\\top$ means transpose.\n\n$\\operatorname{diag}(b_i)$ is a diagonal matrix with entries $b_i$.",
          "explain": [
            "A covariance matrix lists every pairwise covariance. The matrix a11ᵀ puts the common-signal covariance a in every entry. Adding a diagonal matrix supplies the independent sensor errors.",
            "The symbol η denotes the signal residual after pooled estimation. The letter w in the optimality proof denotes a policy perturbation, while w_m later denotes a positive component weight."
          ],
          "source": "Notation and model · Section II"
        }
      ]
    },
    {
      "title": "3. Four information architectures",
      "lessons": [
        {
          "id": "fresh-local",
          "title": "Fresh local",
          "body": "Agent $i$ has $\\mathcal F_i(t)$.\n\nIts optimal action uses $Y_i(t)$:\\[u_i^L(t)=\\frac adY_i(t).\\]",
          "explain": [
            "Each agent can use its own measurements through the current time. No shared measurements are needed.",
            "The fact that the optimal action needs only the current reading is a result of the common-rate model. It is proved in Proposition 1."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Separate allowed information from the eventual implementation",
              "body": "The optimization allows $u_i$ to depend on the complete own-sensor history $\\mathcal F_i(t)$. The optimal policy happens to use only $Y_i(t)$. That reduction follows from the common-rate Gaussian projections and Lemma 1, rather than from a restriction imposed on policies."
            },
            {
              "title": "Distinguish the posterior estimate from the team action",
              "body": "The posterior estimate is $aY_i(t)/(a+b)$. The team action is $aY_i(t)/d$. When $\\kappa>0$, $d>a+b$, so the team action puts less weight on an individual noisy reading to reduce disagreement with other agents."
            }
          ]
        },
        {
          "id": "fresh-pooled",
          "title": "Fresh pooled",
          "body": "Every agent has $\\mathcal F(t)$.\n\nThe optimal action is common:\\[u_i^P(t)=\\frac av\\bar Y(t).\\]",
          "explain": [
            "Every sensor’s data are available immediately to everyone. This is the ideal fresh-sharing benchmark.",
            "The optimum uses the average reading rather than the full vector. All agents choose the same action and incur zero disagreement cost."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Explain what pooling includes",
              "body": "The pooled benchmark gives all agents the complete sensor histories through the current time. It therefore includes the exact readings, rather than only prescribing an aggregate as the available information."
            },
            {
              "title": "Explain why the average achieves that benchmark",
              "body": "The residual $X(t)-(a/v)\\bar Y(t)$ has zero covariance with every sensor reading at every time. Joint Gaussianity makes it independent of all that sensor information. Thus the extra raw readings cannot improve the posterior estimate beyond the mean. Choosing that same estimate at every agent also eliminates disagreement."
            }
          ]
        },
        {
          "id": "delayed-only",
          "title": "Delayed pool used alone",
          "body": "Every agent has $\\mathcal F(s)$, where $s=t-\\tau$. No measurement after $s$ is available.\\[u_i^D(t)=\\rho\\frac av\\bar Y(s).\\]",
          "explain": [
            "The shared information is complete: it contains every sensor’s history through the old timestamp s. “Pool” does not impose compression in this comparison.",
            "The optimized action predicts the old pooled estimate forward. This architecture can lose to fresh local operation because it lacks the newer local observations."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Identify the missing new information",
              "body": "All sensor readings through time $s$ are available, but every reading after $s$ is excluded. The agents must therefore predict across the time gap $\\tau=t-s$ using only the old pool."
            },
            {
              "title": "Explain why local information can beat this benchmark",
              "body": "Fresh local information contains one current sensor history. Delayed-only information contains many histories ending earlier. These information sets are not nested. More sensors can reduce old estimation error, while the delay introduces new signal uncertainty. The crossover proof evaluates the exact tradeoff."
            }
          ]
        },
        {
          "id": "hybrid",
          "title": "Hybrid: old shared information and fresh local data",
          "body": "\\[\\mathcal H_i(t;s)=\\mathcal F_i(t)\\vee\\sigma\\{\\bar Y(r):r\\le s\\}.\\] Sufficient data for the optimal action are\\[Y_i(t),\\qquad Y_i(s),\\qquad \\bar Y(s).\\]",
          "explain": [
            "Each agent keeps its fresh local observations while shared data age. It also retains its own measurement from the time the shared pool was sampled.",
            "Theorem 1 proves that a single old shared mean, together with these own-sensor readings, achieves the same optimum as complete delayed sensor sharing."
          ],
          "source": "Notation and model · Section II",
          "details": [
            {
              "title": "Read the complete-sharing comparison literally",
              "body": "The full delayed-sharing benchmark has $\\mathcal F(s)\\vee\\mathcal F_i(t)$. Thus agent $i$ has every sensor’s old history and its own fresh history. The hybrid keeps that fresh local information and uses the scalar old shared mean to implement the optimal policy."
            },
            {
              "title": "Explain why the hybrid improves on delayed-only information",
              "body": "Theorem 1’s formula gives $J_H=\\rho^2P_n+(1-\\rho^2)J_L$. The delayed-only cost is $J_D=\\rho^2P_n+(1-\\rho^2)a$. Subtracting gives\n\\[J_D-J_H=(1-\\rho^2)(a-J_L)=(1-\\rho^2)\\frac{a^2}{d}>0\\]\nat positive age. Fresh local information does help relative to delayed-only operation. It is already present on both sides of the theorem’s scalar-versus-complete-sharing equality."
            }
          ]
        }
      ]
    },
    {
      "title": "4. The optimality test",
      "lessons": [
        {
          "id": "claim-L",
          "title": "Lemma 1: Team optimality",
          "body": "For the information fields $\\mathcal G_i$, optimize over $u_i\\in L^2(\\mathcal G_i)$, with $X\\in L^2$, $n\\ge2$, and $\\kappa\\ge0$. A feasible $u$ is optimal exactly when\n\\[\n(1+\\kappa)u_i-\\kappa\\E[\\bar u\\mid\\mathcal G_i]=\\E[X\\mid\\mathcal G_i]\\quad(i=1,\\ldots,n).\n\\]\nTwo optimal feasible policies agree almost surely.",
          "explain": [
            "This lemma gives an exact test for team optimality. The agent balances tracking the signal against anticipating the other agents’ average action.",
            "A proposed policy that passes this test is optimal among all allowed square-integrable policies. The proof also establishes uniqueness."
          ],
          "source": "Claim · Paper equations (3), (5)",
          "details": [
            {
              "title": "Read the equation as a conditional residual test",
              "body": "Move its right-hand side to the left. The equation says $\\E[(1+\\kappa)u_i-\\kappa\\bar u-X\\mid\\mathcal G_i]=0$, because $u_i$ is already known to agent $i$."
            },
            {
              "title": "Follow the two directions of the proof",
              "body": "The following steps expand $J(u+w)-J(u)$ exactly, show why feasible perturbations introduce conditional expectations, and prove that a zero conditional residual is both necessary and sufficient. Positivity of the quadratic remainder supplies uniqueness."
            }
          ]
        },
        {
          "id": "proof-L-1",
          "title": "Try changing the actions",
          "body": "For a feasible perturbation $w$, the objective difference has linear term $2n^{-1}\\sum_i\\E[w_i((1+\\kappa)u_i-\\kappa\\bar u-X)]$ and a quadratic remainder.",
          "explain": [
            "Imagine nudging each agent's action by a small amount that uses only its own available information. Expanding the squared loss separates the immediate effect of that change from a nonnegative quadratic correction. The vector w represents those allowed changes."
          ],
          "source": "Lemma 1: Team optimality · Proof step L.1",
          "details": [
            {
              "title": "Write the objective and the allowed change",
              "body": "The expected team loss is\n\\[J(u)=\\frac1n\\sum_{i=1}^n\\E[(u_i-X)^2+\\kappa(u_i-\\bar u)^2].\\]\nReplace every action $u_i$ by $u_i+w_i$. Feasibility means $w_i\\in L^2(\\mathcal G_i)$: the change uses only agent $i$’s information and has finite second moment. Define $\\bar w=n^{-1}\\sum_iw_i$. The new average action is $\\bar u+\\bar w$."
            },
            {
              "title": "Expand the tracking square",
              "body": "Use $(A+B)^2-A^2=2AB+B^2$ with $A=u_i-X$ and $B=w_i$:\n\\[(u_i+w_i-X)^2-(u_i-X)^2=2w_i(u_i-X)+w_i^2.\\]\nThe first term is linear in the change. The second is quadratic."
            },
            {
              "title": "Expand the disagreement square",
              "body": "Here the change is $w_i-\\bar w$, because both the individual action and its team average change:\n\\[\\begin{aligned}\n&(u_i+w_i-\\bar u-\\bar w)^2-(u_i-\\bar u)^2\\\\\n&=2(u_i-\\bar u)(w_i-\\bar w)+(w_i-\\bar w)^2.\n\\end{aligned}\\]"
            },
            {
              "title": "Cancel the term involving the average change",
              "body": "By the definition of the average,\n\\[\\sum_i(u_i-\\bar u)=\\sum_i u_i-n\\bar u=0.\\]\nTherefore, for each realization,\n\\[\\begin{aligned}\n\\sum_i(u_i-\\bar u)(w_i-\\bar w)\n&=\\sum_i(u_i-\\bar u)w_i-\\bar w\\sum_i(u_i-\\bar u)\\\\\n&=\\sum_i(u_i-\\bar u)w_i.\n\\end{aligned}\\]\nThis cancellation happens before taking expectation."
            },
            {
              "title": "Collect the coefficients",
              "body": "The coefficient multiplying $w_i$ is\n\\[(u_i-X)+\\kappa(u_i-\\bar u)=(1+\\kappa)u_i-\\kappa\\bar u-X.\\]\nWrite this residual as $R_i$. The exact difference is\n\\[J(u+w)-J(u)=\\frac2n\\sum_i\\E[w_iR_i]+Q(w),\\]\nwhere\n\\[Q(w)=\\frac1n\\sum_i\\E[w_i^2+\\kappa(w_i-\\bar w)^2].\\]\nThere are no higher-order terms because the original objective is quadratic. Since $\\kappa\\ge0$, $Q(w)\\ge0$."
            }
          ]
        },
        {
          "id": "proof-L-2",
          "title": "When no allowed change helps",
          "body": "The linear term vanishes for every feasible $w$ if and only if the conditional normal equations (5) hold.",
          "explain": [
            "An agent cannot choose its change using information it does not have. We therefore average the residual error over everything that agent cannot see. The conditional normal equation says that this locally predictable direction of improvement is zero. This is the condition displayed in equation (5)."
          ],
          "source": "Lemma 1: Team optimality · Proof step L.2",
          "details": [
            {
              "title": "Vary one agent at a time",
              "body": "Let $R_i=(1+\\kappa)u_i-\\kappa\\bar u-X$. Set all perturbations except $w_i$ to zero. The linear term vanishes for every feasible vector precisely when\n\\[\\E[w_iR_i]=0\\quad\\text{for every }w_i\\in L^2(\\mathcal G_i),\\]\nfor each agent separately. If these individual expectations vanish, their sum also vanishes."
            },
            {
              "title": "Condition on the information the perturbation can use",
              "body": "The tower property first gives\n\\[\\E[w_iR_i]=\\E\\big[\\E[w_iR_i\\mid\\mathcal G_i]\\big].\\]\nBecause $w_i$ is determined by $\\mathcal G_i$, it can be pulled outside the inner conditional expectation:\n\\[\\E[w_iR_i]=\\E\\big[w_i\\E[R_i\\mid\\mathcal G_i]\\big].\\]\nThe product is integrable by Cauchy–Schwarz, since both factors have finite second moment. This conditional-expectation rule also applies to these possibly unbounded $L^2$ variables, by approximation with bounded variables."
            },
            {
              "title": "Use the conditional residual itself as a perturbation",
              "body": "Set $q_i=\\E[R_i\\mid\\mathcal G_i]$. It is $\\mathcal G_i$-measurable. Conditional Jensen gives\n\\[\\E[q_i^2]\\le\\E[R_i^2]<\\infty,\\]\nso $w_i=q_i$ is allowed. The vanishing condition then says\n\\[0=\\E[q_iR_i]=\\E[q_i^2].\\]\nA nonnegative random variable with zero expectation is zero almost surely. Hence $q_i=0$ almost surely."
            },
            {
              "title": "Check the reverse implication",
              "body": "If $q_i=0$ almost surely, then every feasible $w_i$ satisfies\n\\[\\E[w_iR_i]=\\E[w_iq_i]=0.\\]\nThus vanishing against every permitted change and a zero conditional residual are equivalent."
            },
            {
              "title": "Expand the conditional residual",
              "body": "Conditional expectation is linear. Also, agent $i$ knows its own action, so $\\E[u_i\\mid\\mathcal G_i]=u_i$. Consequently,\n\\[0=(1+\\kappa)u_i-\\kappa\\E[\\bar u\\mid\\mathcal G_i]-\\E[X\\mid\\mathcal G_i].\\]\nMoving the last term to the other side gives\n\\[(1+\\kappa)u_i-\\kappa\\E[\\bar u\\mid\\mathcal G_i]=\\E[X\\mid\\mathcal G_i].\\]\nThe agent generally does not know $\\bar u$ or $X$, which is why those two conditional expectations remain."
            },
            {
              "title": "See why a nonzero predictable residual would help",
              "body": "If $q_i$ were nonzero, choose $w_i=-\\epsilon q_i$ with $\\epsilon>0$. Its linear contribution would be $-2\\epsilon\\E[q_i^2]/n$, while the quadratic remainder would be proportional to $\\epsilon^2$. For sufficiently small $\\epsilon$, the total change would be negative. The predictable part of the residual therefore has to vanish at an optimum."
            }
          ]
        },
        {
          "id": "proof-L-3",
          "title": "Why the minimum is unique",
          "body": "The remainder is $n^{-1}\\sum_i\\E[w_i^2]+\\kappa n^{-1}\\sum_i\\E[(w_i-\\bar w)^2]$, positive whenever $w$ is nonzero in $L^2$.",
          "explain": [
            "If we move to a genuinely different policy after satisfying the normal equations, the linear change is zero and the remaining quadratic change is positive. The squared tracking term alone makes it positive. A zero disagreement weight is therefore allowed."
          ],
          "source": "Lemma 1: Team optimality · Proof step L.3",
          "details": [
            {
              "title": "Use the sign of each square",
              "body": "The remainder is\n\\[Q(w)=\\frac1n\\sum_i\\E[w_i^2]+\\frac\\kappa n\\sum_i\\E[(w_i-\\bar w)^2].\\]\nEvery squared quantity is nonnegative and $\\kappa\\ge0$. Thus\n\\[Q(w)\\ge\\frac1n\\sum_i\\E[w_i^2].\\]"
            },
            {
              "title": "Identify when it is strictly positive",
              "body": "“Nonzero in $L^2$” means at least one coordinate satisfies $\\E[w_i^2]>0$. The last sum is then positive. Thus $Q(w)>0$ for every genuinely different feasible policy, even if $\\kappa=0$. Changes only on probability-zero events do not count as different in $L^2$."
            }
          ]
        },
        {
          "id": "proof-L-4",
          "title": "The optimality test is complete",
          "body": "Q.E.D. Necessity, sufficiency, and uniqueness follow.",
          "explain": [
            "We now have both directions: every optimum must satisfy the equations, and every feasible policy satisfying them is the unique optimum, up to events of probability zero. This lets us propose simple linear policies later without restricting the competing policies to be linear."
          ],
          "source": "Lemma 1: Team optimality · Proof step L.4",
          "details": [
            {
              "title": "Prove necessity by scaling a direction",
              "body": "Fix any feasible $w$ and let $L(w)=2n^{-1}\\sum_i\\E[w_iR_i]$. The expansion gives\n\\[J(u+\\epsilon w)-J(u)=\\epsilon L(w)+\\epsilon^2Q(w).\\]\nIf $L(w)\\ne0$, choose the sign of $\\epsilon$ opposite to $L(w)$. For small enough nonzero $|\\epsilon|$, the negative linear term dominates. An optimal $u$ must therefore have $L(w)=0$ for every direction."
            },
            {
              "title": "Prove sufficiency for a finite change",
              "body": "If the conditional equations hold, step L.2 makes the linear term vanish for every feasible $w$. The exact expansion becomes $J(u+w)-J(u)=Q(w)\\ge0$. This covers all feasible changes, not just infinitesimal ones."
            },
            {
              "title": "Prove uniqueness",
              "body": "If another feasible policy $v$ were also optimal, set $w=v-u$. Then $0=J(v)-J(u)=Q(w)$. Step L.3 implies every coordinate of $w$ is zero almost surely. Hence the two optimal policies agree almost surely."
            }
          ]
        }
      ]
    },
    {
      "title": "5. Fresh local & fresh pooled",
      "lessons": [
        {
          "id": "claim-P",
          "title": "Proposition 1: Fresh endpoints",
          "body": "Under (1)--(3), let $v=a+b/n$ and $d=a+b[1+\\kappa(1-1/n)]$. For complete local and pooled histories,\n\\[\nP_1=\\frac{ab}{a+b},\\quad P_n=\\frac{ab}{b+na},\\quad\nu_i^L=\\frac adY_i(t),\\quad u_i^P=\\frac av\\bar Y(t).\n\\]\nThe optimal losses are $J_L=a-a^2/d$ and $J_P=P_n=a-a^2/v$, and $\\Delta=J_L-J_P=a^2(d-v)/(vd)>0$.",
          "explain": [
            "These are the fresh local and fresh pooled benchmarks. The formulas state both how to act and what expected loss those optimal actions achieve.",
            "Posterior variances measure estimation uncertainty. Team losses also include the disagreement objective. Delta is the positive improvement from fresh pooling."
          ],
          "source": "Claim · Paper equations (6)--(11)",
          "details": [
            {
              "title": "Identify the two separate optimizations",
              "body": "Local policies may use each agent’s entire own-sensor history. Pooled policies may use all sensor histories. In each class the proof first derives the relevant conditional means, then checks the team-optimal policy using Lemma 1."
            },
            {
              "title": "Read the positive benefit from the formulas",
              "body": "The local cost subtracts $a^2/d$ from $a$, whereas pooling subtracts $a^2/v$. Since $d>v>0$, $a^2/v>a^2/d$, so the pooled cost is smaller. The following proof derives both denominators and evaluates their difference."
            }
          ]
        },
        {
          "id": "proof-P-1",
          "title": "A whole local history reduces to one reading",
          "body": "$X(t)-aY_i(t)/(a+b)$ has zero covariance with every $Y_i(r)$ for $r\\le t$, so it is independent of the local history.",
          "explain": [
            "Subtract the proposed estimate from the true signal. The resulting error has zero covariance with every observation in this agent's history. Joint Gaussianity makes that error independent of the whole history. Older readings therefore cannot improve this estimate under the common-rate model."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.1",
          "details": [
            {
              "title": "Compute the two covariances",
              "body": "Fix an observation time $r\\le t$ and write $q_r=e^{-\\lambda(t-r)}$. Since $Y_i=X+E_i$ and the signal and disturbance are independent,\n\\[\\Cov(X(t),Y_i(r))=a q_r,\\qquad \\Cov(Y_i(t),Y_i(r))=(a+b)q_r.\\]"
            },
            {
              "title": "Subtract the predictable part",
              "body": "For $\\epsilon_i=X(t)-aY_i(t)/(a+b)$, linearity of covariance gives\n\\[\\Cov(\\epsilon_i,Y_i(r))=a q_r-\\frac a{a+b}(a+b)q_r=0.\\]\nThe same coefficient $a/(a+b)$ cancels the covariance for every past time $r$. That is the role of the common temporal rate."
            },
            {
              "title": "Pass from individual observations to the history",
              "body": "The residual and every finite vector of sensor observations are jointly Gaussian. Zero cross-covariances make the residual independent of each such vector. Cylinder events from finite vectors generate the observation sigma-field, so this independence extends to $\\mathcal F_i(t)$. The residual has mean zero, hence $\\E[\\epsilon_i\\mid\\mathcal F_i(t)]=0$."
            }
          ]
        },
        {
          "id": "proof-P-2",
          "title": "The error left after pooling",
          "body": "Define $\\eta(t)=X(t)-(a/v)\\bar Y(t)$. It is uncorrelated with every $Y_j(r)$ and independent of the entire sensor process.",
          "explain": [
            "The same calculation works after averaging all sensors. The residual η is the part of the signal that the sensor observations do not reveal. Its independence holds against every sensor at every time because the signal and sensor errors share the same temporal factor."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.2",
          "details": [
            {
              "title": "Work out the covariance of the average",
              "body": "For any sensor $j$ and any time $r$, put $q_r=e^{-\\lambda|t-r|}$. Among the $n$ terms in $\\bar Y(t)$, one shares sensor $j$’s error and all share the signal. Therefore\n\\[\\Cov(\\bar Y(t),Y_j(r))=\\frac{(a+b)+(n-1)a}{n}q_r=vq_r.\\]"
            },
            {
              "title": "Cancel for every sensor and every time",
              "body": "With $\\eta(t)=X(t)-(a/v)\\bar Y(t)$,\n\\[\\Cov(\\eta(t),Y_j(r))=a q_r-\\frac av vq_r=0.\\]\nThis holds even for $r>t$. Joint Gaussianity therefore makes $\\eta(t)$ independent of the entire sensor process, including later observations. This strong conclusion follows from the common-rate covariance structure."
            }
          ]
        },
        {
          "id": "proof-P-3",
          "title": "Compute the remaining uncertainty",
          "body": "The residual variances are $P_1=ab/(a+b)$ and $P_n=ab/(b+na)$. The corresponding conditional means are $aY_i(t)/(a+b)$ and $(a/v)\\bar Y(t)$.",
          "explain": [
            "Subtract the variance explained by the observation from the signal variance a. A single sensor leaves error variance P₁. Pooling n sensors leaves the smaller variance Pₙ. These are estimation errors; the optimal local team cost also accounts for disagreement."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.3",
          "details": [
            {
              "title": "Recover the conditional means",
              "body": "Write $X(t)=aY_i(t)/(a+b)+\\epsilon_i$. The first term is known from the local history and the residual is independent and mean zero. Taking conditional expectation leaves $aY_i(t)/(a+b)$. The same reasoning with $X(t)=(a/v)\\bar Y(t)+\\eta(t)$ gives the pooled mean."
            },
            {
              "title": "Expand the local residual variance",
              "body": "For centered variables, $\\Var(A-cB)=\\Var(A)-2c\\Cov(A,B)+c^2\\Var(B)$. Thus\n\\[\\begin{aligned}P_1&=a-2\\frac a{a+b}a+\\frac{a^2}{(a+b)^2}(a+b)\\\\&=a-\\frac{a^2}{a+b}=\\frac{ab}{a+b}.\\end{aligned}\\]"
            },
            {
              "title": "Repeat for the pooled residual",
              "body": "Here $\\Cov(X,\\bar Y)=a$ and $\\Var(\\bar Y)=v$. Hence\n\\[P_n=a-2\\frac av a+\\frac{a^2}{v^2}v=a-\\frac{a^2}{v}=\\frac{ab}{b+na}.\\]\nIndependence of each residual from the observations makes this its conditional variance as well as its unconditional variance."
            }
          ]
        },
        {
          "id": "proof-P-4",
          "title": "Predict the other agents' average",
          "body": "For the candidate $u_i=kY_i(t)$, $\\E[\\bar u\\mid\\mathcal F_i(t)]=kvY_i(t)/(a+b)$.",
          "explain": [
            "To check the team equation, an agent needs its conditional prediction of the average action. That prediction is a multiple of its own reading. The factor includes this agent's own contribution to the average, which is why v appears here."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.4",
          "details": [
            {
              "title": "Form the average action",
              "body": "The candidate has $u_j=kY_j(t)$ for every $j$, so $\\bar u=k\\bar Y(t)$. We need to predict this average using only agent $i$’s sensor history."
            },
            {
              "title": "Prove the required projection",
              "body": "At each $r\\le t$, the covariances of $\\bar Y(t)$ and $Y_i(t)$ with $Y_i(r)$ are $vq_r$ and $(a+b)q_r$. The residual\n\\[\\bar Y(t)-\\frac v{a+b}Y_i(t)\\]\nhas zero covariance with every local reading. Gaussianity makes it independent of the local history. Its conditional mean is zero."
            },
            {
              "title": "Multiply by the policy gain",
              "body": "It follows that\n\\[\\E[\\bar u\\mid\\mathcal F_i(t)]=k\\E[\\bar Y(t)\\mid\\mathcal F_i(t)]=\\frac{kv}{a+b}Y_i(t).\\]\nThis calculation conditions on the full local history, so it does not presuppose that the last reading is sufficient."
            }
          ]
        },
        {
          "id": "proof-P-5",
          "title": "Choose the local gain",
          "body": "Equation (5) gives $k[(1+\\kappa)(a+b)-\\kappa v]=a$. The bracket equals $d$, so $k=a/d$.",
          "explain": [
            "Insert the proposed linear action into the optimality equation. A scalar equation determines how much weight the agent should give its sensor. Its solution is a/d. The parameter d includes the disagreement penalty, so the policy generally shrinks the reading more than a pure local estimator would."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.5",
          "details": [
            {
              "title": "Insert the conditional means into Lemma 1",
              "body": "For $u_i=kY_i(t)$, the lemma requires\n\\[(1+\\kappa)kY_i(t)-\\kappa\\frac{kv}{a+b}Y_i(t)=\\frac a{a+b}Y_i(t).\\]\nSince $Y_i(t)$ has positive variance, equality almost surely requires equality of the constant coefficients. Multiplying by $a+b$ gives $k[(1+\\kappa)(a+b)-\\kappa v]=a$."
            },
            {
              "title": "Simplify the bracket without skipping terms",
              "body": "Substitute $v=a+b/n$:\n\\[\\begin{aligned}(1+\\kappa)(a+b)-\\kappa v\n&=a+b+\\kappa a+\\kappa b-\\kappa a-\\kappa b/n\\\\\n&=a+b[1+\\kappa(1-1/n)]=d.\n\\end{aligned}\\]\nThus $kd=a$ and $k=a/d$. Because $d>0$, this gain is well defined."
            }
          ]
        },
        {
          "id": "proof-P-6",
          "title": "Evaluate local team loss",
          "body": "The local loss is $a-2ak+dk^2=a-a^2/d$.",
          "explain": [
            "Substitute the chosen gain into the tracking and disagreement costs. The expression is a simple quadratic in the gain k. At k = a/d, its value is a − a²/d. This is the fully optimized local team cost J_L."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.6",
          "details": [
            {
              "title": "Compute tracking loss",
              "body": "For $u_i=kY_i$,\n\\[\\E[(kY_i-X)^2]=k^2(a+b)-2ka+a.\\]\nThe cross term uses $\\E[Y_iX]=a$. All variables are centered."
            },
            {
              "title": "Compute disagreement loss",
              "body": "The common signal cancels from $Y_i-\\bar Y=E_i-\\bar E$. Its variance is\n\\[b-2(b/n)+b/n=b(1-1/n).\\]\nThus the disagreement contribution per agent is $\\kappa k^2b(1-1/n)$."
            },
            {
              "title": "Combine and substitute the gain",
              "body": "Adding gives $J=a-2ak+dk^2$. At $k=a/d$,\n\\[J_L=a-\\frac{2a^2}{d}+\\frac{a^2}{d}=a-\\frac{a^2}{d}.\\]"
            }
          ]
        },
        {
          "id": "proof-P-7",
          "title": "Pooling makes every agent agree",
          "body": "With pooled information all agents use the common conditional mean, with zero disagreement and loss $P_n$.",
          "explain": [
            "Everyone with the pooled information has the same conditional estimate of the signal. Using that estimate minimizes each tracking-error term and makes the disagreement term zero. The resulting team loss equals the pooled estimation error Pₙ."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.7",
          "details": [
            {
              "title": "Use the squared-error decomposition",
              "body": "Let $m=\\E[X\\mid\\mathcal F(t)]$. For any action $u_i$ based on the pooled information,\n\\[\\E[(u_i-X)^2]=\\E[(m-X)^2]+\\E[(u_i-m)^2].\\]\nThe cross term vanishes because $u_i-m$ is known from $\\mathcal F(t)$ and $\\E[m-X\\mid\\mathcal F(t)]=0$. Thus tracking loss is at least $P_n$ for every agent."
            },
            {
              "title": "Attain both lower bounds together",
              "body": "Set every action to $m=(a/v)\\bar Y(t)$. Each tracking loss is $P_n$, and $u_i-\\bar u=0$ for every agent. The disagreement penalty reaches its lower bound of zero. Hence the total minimum is $J_P=P_n$."
            }
          ]
        },
        {
          "id": "proof-P-8",
          "title": "Certify the proposed policies",
          "body": "The displayed feasible policies are optimal by Lemma 1.",
          "explain": [
            "The local and pooled actions are feasible for their respective information sets. They satisfy the necessary and sufficient test from Lemma 1. That establishes optimality against every admissible policy, including nonlinear policies based on histories."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.8",
          "details": [
            {
              "title": "Verify the full admissible class is covered",
              "body": "The candidate local action is measurable from $\\mathcal F_i(t)$ and has finite second moment. Steps P.4–P.5 checked the conditional equations using that entire field. Lemma 1 therefore certifies optimality among all feasible history-dependent policies, including nonlinear ones."
            },
            {
              "title": "Check the pooled candidate in the same equations",
              "body": "For common $m=\\E[X\\mid\\mathcal F(t)]$, $u_i=\\bar u=m$. The left side of Lemma 1 is $(1+\\kappa)m-\\kappa m=m$, exactly its right side. The uniqueness part of the lemma applies to both architectures."
            }
          ]
        },
        {
          "id": "proof-P-9",
          "title": "Fresh sharing has positive value",
          "body": "$d-v=b(1+\\kappa)(1-1/n)>0$ and subtraction yields the formula for $\\Delta$.",
          "explain": [
            "The difference d − v is strictly positive because there are at least two sensors and their errors have positive variance. Subtracting the two optimized costs gives Δ, the benefit of fresh pooling. This quantity will become the reference value for the aging calculation."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.9",
          "details": [
            {
              "title": "Subtract the denominators",
              "body": "Using their definitions,\n\\[\\begin{aligned}d-v&=b-b/n+\\kappa b(1-1/n)\\\\&=b(1+\\kappa)(1-1/n)>0.\\end{aligned}\\]\nAll factors are positive because $b>0$, $\\kappa\\ge0$, and $n\\ge2$."
            },
            {
              "title": "Subtract the optimized losses",
              "body": "The $a$ terms cancel:\n\\[\\Delta=(a-a^2/d)-(a-a^2/v)=a^2\\left(\\frac1v-\\frac1d\\right)=\\frac{a^2(d-v)}{vd}>0.\\]\nBoth denominators are positive. Fresh pooling therefore strictly improves the optimum in this nondegenerate model."
            }
          ]
        },
        {
          "id": "proof-P-10",
          "title": "The two fresh benchmarks are established",
          "body": "Q.E.D. All endpoint claims follow.",
          "explain": [
            "We now know the exact actions, estimation errors, and optimized team losses for fresh local and fresh pooled information. Later comparisons use these benchmarks without changing their policies or information constraints."
          ],
          "source": "Proposition 1: Fresh endpoints · Proof step P.10",
          "details": [
            {
              "title": "Match the proof to each claim",
              "body": "Steps P.1–P.3 established the conditional means and variances for full histories. P.4–P.8 gave feasible policies, verified optimality, and evaluated their losses. P.9 established the positive difference $\\Delta$. These are all the quantities asserted in Proposition 1."
            },
            {
              "title": "Keep estimation and team optimization distinct",
              "body": "The local conditional mean uses gain $a/(a+b)$, while the local team policy uses $a/d$. They coincide when $\\kappa=0$. The pooled policy is a common conditional mean, so its team cost equals its estimation-error variance."
            }
          ]
        },
        {
          "id": "local-estimation-gap",
          "title": "Why local team loss exceeds local estimation error",
          "body": "\\[J_L-P_1=\\frac{\\kappa a^2b(1-1/n)}{(a+b)d}.\\]",
          "explain": [
            "A local estimator would put gain a/(a+b) on its reading. With a disagreement penalty, the optimal local team gain is a/d instead. This reduces disagreement at the expense of some tracking accuracy.",
            "The gap is zero when κ = 0. It is positive when κ > 0 under the paper’s nondegenerate sensor model."
          ],
          "source": "Derived claim · Equation (12)",
          "details": [
            {
              "title": "Subtract using the two exact losses",
              "body": "Since $P_1=a-a^2/(a+b)$ and $J_L=a-a^2/d$,\n\\[J_L-P_1=\\frac{a^2[d-(a+b)]}{(a+b)d}.\\]"
            },
            {
              "title": "Insert the extra term in d",
              "body": "The difference $d-(a+b)=\\kappa b(1-1/n)$. Thus\n\\[J_L-P_1=\\frac{\\kappa a^2b(1-1/n)}{(a+b)d}.\\]\nAll factors except $\\kappa$ are strictly positive. The gap is zero at $\\kappa=0$ and positive at $\\kappa>0$."
            }
          ]
        }
      ]
    },
    {
      "title": "6. The delay crossover",
      "lessons": [
        {
          "id": "claim-D",
          "title": "Corollary 1: The delay crossover",
          "body": "Let $\\tau\\ge0$ and $s=t-\\tau$. Every agent has $\\mathcal F(s)$ and no post-$s$ measurements. The optimal common action is $u_i^D=e^{-\\lambda\\tau}(a/v)\\bar Y(s)$ and\n\\[\nJ_D(\\tau)=a-\\frac{a^2}{v}e^{-2\\lambda\\tau}.\n\\]\nThen $J_L<J_D(\\tau)$ exactly when $\\tau>(2\\lambda)^{-1}\\log(d/v)$, with equality at that age.",
          "explain": [
            "There is an exact age beyond which fresh local decisions beat optimal decisions based only on complete delayed information. Both decision rules are optimized.",
            "Every delayed-only agent agrees perfectly. Beyond the threshold, the extra tracking error costs more than the agreement saves."
          ],
          "source": "Claim · Paper equations (13), (14)",
          "details": [
            {
              "title": "Identify what has become unavailable",
              "body": "At decision time $t$, the delayed-only agents see all sensors’ observations through $s=t-\\tau$ and none after that time. Predicting the old pooled estimate forward therefore multiplies it by $\\rho=e^{-\\lambda\\tau}$."
            },
            {
              "title": "See the algebra behind the threshold",
              "body": "The difference is $J_D-J_L=a^2(1/d-e^{-2\\lambda\\tau}/v)$. Its sign changes when $e^{-2\\lambda\\tau}=v/d$. The proof below derives the cost and solves this equality, including the direction of the strict inequality."
            }
          ]
        },
        {
          "id": "proof-D-1",
          "title": "Predict from the old pool",
          "body": "The Markov property and Proposition 1 give $\\E[X(t)\\mid\\mathcal F(s)]=e^{-\\lambda\\tau}(a/v)\\bar Y(s)$.",
          "explain": [
            "First estimate the signal at the time the measurements were collected. Then predict forward by multiplying that estimate by ρ. The Markov property says the new signal innovation has mean zero given the old data."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.1",
          "details": [
            {
              "title": "Predict the signal from its old state",
              "body": "Write $X(t)=\\rho X(s)+\\xi$ with $\\rho=e^{-\\lambda(t-s)}$. The OU innovation $\\xi$ is mean zero and independent of all signal and sensor data through $s$. Hence $\\E[\\xi\\mid\\mathcal F(s)]=0$."
            },
            {
              "title": "Condition on the actual shared observations",
              "body": "The old state $X(s)$ is unobserved. Proposition 1 says its conditional mean is $(a/v)\\bar Y(s)$. By linearity,\n\\[\\E[X(t)\\mid\\mathcal F(s)]=\\rho\\E[X(s)\\mid\\mathcal F(s)]=\\rho\\frac av\\bar Y(s).\\]"
            }
          ]
        },
        {
          "id": "proof-D-2",
          "title": "Find the best delayed-only action",
          "body": "Taking this common mean minimizes tracking loss and yields zero disagreement, hence minimizes the team loss.",
          "explain": [
            "All agents have the same old information and no newer measurements. Choosing their common conditional mean gives the smallest tracking loss and zero disagreement. Thus this is the best delayed-only policy, rather than an arbitrary stale-data rule."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.2",
          "details": [
            {
              "title": "Bound each tracking term",
              "body": "With $m_D=\\E[X(t)\\mid\\mathcal F(s)]$, every allowed action satisfies\n\\[\\E[(u_i-X(t))^2]=\\E[(m_D-X(t))^2]+\\E[(u_i-m_D)^2].\\]\nThe cross term is zero by conditioning on $\\mathcal F(s)$. Therefore no agent can beat the first term using delayed information alone."
            },
            {
              "title": "Make disagreement vanish",
              "body": "All agents possess the same information. They can all choose $u_i=m_D$, attaining that tracking lower bound simultaneously. Their actions then agree exactly, so the additional nonnegative disagreement cost is zero. This proves optimality for the team."
            }
          ]
        },
        {
          "id": "proof-D-3",
          "title": "Calculate the cost of waiting",
          "body": "\\[J_D(\\tau)=a-\\frac{a^2}{v}e^{-2\\lambda\\tau}.\\]",
          "explain": [
            "The old pooled estimate explains a²/v of the variance at its own timestamp. Prediction reduces that explained variance by ρ². Subtracting it from a gives J_D(τ) = a − (a²/v)e^(−2λτ)."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.3",
          "details": [
            {
              "title": "Separate old estimation error from new signal uncertainty",
              "body": "Subtract $m_D=\\rho(a/v)\\bar Y(s)$ from $X(t)=\\rho X(s)+\\xi$:\n\\[X(t)-m_D=\\rho\\left[X(s)-\\frac av\\bar Y(s)\\right]+\\xi.\\]\nThe bracket has variance $P_n$, and $\\xi$ is independent of it with variance $a(1-\\rho^2)$."
            },
            {
              "title": "Add the independent variances",
              "body": "Thus\n\\[\\begin{aligned}J_D&=\\rho^2P_n+a(1-\\rho^2)\\\\&=\\rho^2(a-a^2/v)+a-a\\rho^2\\\\&=a-\\frac{a^2}{v}\\rho^2.\n\\end{aligned}\\]\nFinally $\\rho^2=e^{-2\\lambda\\tau}$ gives the displayed formula."
            }
          ]
        },
        {
          "id": "proof-D-4",
          "title": "Compare the optimized costs",
          "body": "Comparison with $J_L$ yields $J_L<J_D$ if and only if $e^{-2\\lambda\\tau}<v/d$.",
          "explain": [
            "Local operation beats delayed-only sharing when its explained-variance benefit is larger. Cancelling the common positive factors reduces the comparison to ρ² < v/d. There is no communication price in this comparison."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.4",
          "details": [
            {
              "title": "Subtract local cost from delayed-only cost",
              "body": "Using the two optimized losses,\n\\[J_D-J_L=a^2\\left(\\frac1d-\\frac{\\rho^2}{v}\\right).\\]\nLocal operation is better exactly when this difference is positive."
            },
            {
              "title": "Multiply only by positive quantities",
              "body": "Since $a^2,d,v>0$,\n\\[J_D-J_L>0\\ \\Longleftrightarrow\\ v-d\\rho^2>0\\ \\Longleftrightarrow\\ \\rho^2<\\frac vd.\\]\nNo inequality reverses in these multiplications. Substituting $\\rho^2=e^{-2\\lambda\\tau}$ yields the claim."
            }
          ]
        },
        {
          "id": "proof-D-5",
          "title": "Solve for the delay threshold",
          "body": "\\[\\tau_{\\rm cross}=\\frac1{2\\lambda}\\log\\frac dv.\\]\\[J_L<J_D(\\tau)\\quad\\Longleftrightarrow\\quad\\tau>\\tau_{\\rm cross}.\\] At equality, the two costs coincide.",
          "explain": [
            "Take logarithms and solve the inequality for age τ. Because λ is positive, dividing by −2λ reverses the inequality. At the threshold the costs are equal; beyond it the fresh-local team has lower loss."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.5",
          "details": [
            {
              "title": "Take the logarithm",
              "body": "Both sides of $e^{-2\\lambda\\tau}<v/d$ are positive. Logarithm is strictly increasing, so\n\\[-2\\lambda\\tau<\\log(v/d)=-\\log(d/v).\\]"
            },
            {
              "title": "Reverse the inequality when dividing by a negative number",
              "body": "Since $-2\\lambda<0$, division reverses the sign:\n\\[\\tau>\\frac{\\log(d/v)}{2\\lambda}.\\]\nRepeating with equality gives $J_L=J_D$ at that age. Because $d>v$, the threshold is strictly positive."
            }
          ]
        },
        {
          "id": "proof-D-6",
          "title": "The crossover claim is complete",
          "body": "The delayed-only policy, its minimum loss, and the exact crossover threshold are established.",
          "explain": [
            "This establishes the optimal delayed-only action, its cost, and the exact crossover. The comparison is between different information sets: fresh own-sensor information and old information from all sensors. The hybrid considered next keeps both kinds of information."
          ],
          "source": "Corollary 1: The delay crossover · Proof step D.6",
          "details": [
            {
              "title": "Check the two endpoints",
              "body": "At age zero, $J_D(0)=J_P<J_L$. At arbitrarily large age, $J_D(\\tau)\\to a>J_L$. The delayed-only loss is strictly increasing because $J_D'(\\tau)=2\\lambda a^2e^{-2\\lambda\\tau}/v>0$. Thus the derived equality is the only crossover."
            },
            {
              "title": "Identify the compared information sets",
              "body": "The delayed-only agents have all sensor data through $s$, with no readings after $s$. Local agents have their own readings through $t$. Neither set contains the other, so a change in which optimum is smaller is compatible with the rule that adding information cannot increase minimum loss."
            }
          ]
        },
        {
          "id": "threshold-dependence",
          "title": "What moves the crossover?",
          "body": "\\[\\tau_{\\rm cross}=\\frac{\\log(d/v)}{2\\lambda}.\\] Increasing $\\kappa$ increases $d$. Increasing $\\lambda$ shortens the time scale.",
          "explain": [
            "If disagreement is more costly, an old common estimate remains competitive for longer. If the signal changes faster, its shared information loses value sooner.",
            "These comparisons hold with the other parameters fixed. They concern delayed information used alone."
          ],
          "source": "Section III-A · Threshold interpretation",
          "details": [
            {
              "title": "Differentiate with respect to the disagreement penalty",
              "body": "Only $d$ depends on $\\kappa$, with $\\partial d/\\partial\\kappa=b(1-1/n)$. The chain rule gives\n\\[\\frac{\\partial\\tau_{\\rm cross}}{\\partial\\kappa}=\\frac{b(1-1/n)}{2\\lambda d}>0.\\]\nMore expensive disagreement extends the age range in which a common delayed decision remains competitive."
            },
            {
              "title": "Differentiate with respect to the temporal rate",
              "body": "Holding $a,b,n,\\kappa$ fixed,\n\\[\\frac{\\partial\\tau_{\\rm cross}}{\\partial\\lambda}=-\\frac{\\log(d/v)}{2\\lambda^2}<0.\\]\nThe numerator is positive because $d>v$. Faster temporal change shortens the allowable delay."
            }
          ]
        }
      ]
    },
    {
      "title": "7. The hybrid theorem",
      "lessons": [
        {
          "id": "claim-H",
          "title": "Theorem 1: Hybrid policy and exponential value",
          "body": "Under (1)--(4), put $\\rho=e^{-\\lambda\\tau}$ and $s=t-\\tau$. The unique optimal hybrid action is\n\\[\nu_i^H=\\rho\\frac av\\bar Y(s)+\\frac ad[Y_i(t)-\\rho Y_i(s)].\n\\]\nIt also attains the optimum with the larger information $\\mathcal F(s)\\vee\\mathcal F_i(t)$. Its posterior variance and team loss satisfy\n\\[\nP_H=\\rho^2P_n+(1-\\rho^2)P_1,\\qquad\nJ_H=\\rho^2J_P+(1-\\rho^2)J_L,\n\\]\nand $J_L-J_H=\\Delta e^{-2\\lambda\\tau}$.",
          "explain": [
            "The action has two parts: everyone uses the same prediction from the old pool, then each agent adds a correction from its own new information.",
            "The theorem proves this policy is optimal even against complete delayed sensor sharing. Its improvement over local operation is exactly the fresh-pooling improvement multiplied by e^(−2λτ)."
          ],
          "source": "Claim · Paper equations (15)--(21)",
          "details": [
            {
              "title": "Read the two information sets being compared",
              "body": "Both the hybrid and complete delayed-sharing benchmark retain fresh local information. The benchmark has all old raw sensor histories through $s$. The hybrid action needs only their old mean and the agent’s own readings at $s$ and $t$."
            },
            {
              "title": "Separate the proof’s two tasks",
              "body": "First verify the proposed policy against the larger full-history class. Then observe that the smaller hybrid class can implement it. This establishes equality of optimized decision values. It does not assert that the mean reproduces every old sensor reading."
            },
            {
              "title": "Read the cost as a weighted combination",
              "body": "The weights $\\rho^2$ and $1-\\rho^2$ are nonnegative and sum to one. At zero age only $J_P$ contributes. As age grows, the weight shifts toward $J_L$. The proof derives those weights from independent residuals and scaled innovation covariance."
            }
          ]
        },
        {
          "id": "proof-H-1",
          "title": "Start with zero delay",
          "body": "CASE $\\tau=0$. The formula is the pooled policy.",
          "explain": [
            "When the shared information is current, the current and stored local readings coincide. Their difference in the hybrid correction is zero, leaving the fresh-pooled policy. The variance and cost formulas also reduce to the pooled benchmark."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.1",
          "details": [
            {
              "title": "Substitute zero age into the action",
              "body": "At $\\tau=0$, $s=t$ and $\\rho=1$. Thus $Y_i(t)-\\rho Y_i(s)=0$, leaving $u_i^H=(a/v)\\bar Y(t)$, the fresh pooled optimum."
            },
            {
              "title": "Check the claimed costs",
              "body": "The weights become $\\rho^2=1$ and $1-\\rho^2=0$. The theorem therefore states $J_H=J_P$ and $P_H=P_n$, both already proved. Treating this case separately avoids division by a zero innovation variance later."
            }
          ]
        },
        {
          "id": "proof-H-2",
          "title": "Now let the shared data age",
          "body": "CASE $\\tau>0$. Prove the remaining claims under this assumption.",
          "explain": [
            "The remaining argument concerns positive age. We will allow the agent its entire local history while the shared data stop at time s. This case and the zero-age case together cover every age in the theorem."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2",
          "details": [
            {
              "title": "Record what positive age guarantees",
              "body": "With $\\tau>0$ and $\\lambda>0$, $0<\\rho<1$. Therefore $1-\\rho^2>0$, so the new sensor innovations have nonzero variance. We may safely use their covariance ratios."
            },
            {
              "title": "State what still needs proving",
              "body": "We must verify the proposed action against full delayed sharing and full local history, show that the smaller hybrid information can implement it, and compute its posterior variance and team cost. Proving only an endpoint regression would not establish the full-history claim."
            }
          ]
        },
        {
          "id": "proof-H-2-1",
          "title": "Give the competitor even more information",
          "body": "Enlarge each information field to $\\mathcal G_i=\\mathcal F(s)\\vee\\mathcal F_i(t)$ and define $Z_i=Y_i(t)-\\rho Y_i(s)$, $h=a/v$, $k=a/d$.",
          "explain": [
            "Temporarily let each agent see every sensor's complete history through s, plus its own history through t. This is at least as informative as the proposed hybrid. Z_i is the change in the local reading after subtracting the prediction from its stored reading. The constants h and k are the fresh pooled and local gains."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.1",
          "details": [
            {
              "title": "Compare the two feasible policy classes",
              "body": "The hybrid agent knows the old shared mean and its own relevant readings. The enlarged field $\\mathcal G_i=\\mathcal F(s)\\vee\\mathcal F_i(t)$ includes every sensor’s history through $s$ and agent $i$’s history through $t$. It contains the hybrid information, so its minimum cost is a lower bound on hybrid minimum cost."
            },
            {
              "title": "Remove what the old local reading predicts",
              "body": "Define $Z_i=Y_i(t)-\\rho Y_i(s)$. The old local reading predicts the fraction $\\rho Y_i(s)$ of the new reading. The remainder $Z_i$ is the new innovation. Write $h=a/v$ for the pooled gain and $k=a/d$ for the local gain. The candidate is $u_i=m+kZ_i$ with common prediction $m=\\rho h\\bar Y(s)$."
            },
            {
              "title": "Explain the strategy for proving equality of values",
              "body": "If this candidate is optimal for the enlarged fields and is also feasible for the smaller hybrid fields, the hybrid can attain the lower bound. The two minimum costs must then coincide. This argument requires checking the enlarged-field normal equations first."
            }
          ]
        },
        {
          "id": "proof-H-2-2",
          "title": "Separate old data from new information",
          "body": "$Z$ is independent of $\\mathcal F(s)$ and has covariance $(1-\\rho^2)(a\\mathbf1\\mathbf1^\\top+bI)$.",
          "explain": [
            "Under the common-rate Gaussian model, the innovation vector Z is independent of the entire old sensor history. Its covariance has the same spatial shape as the original readings, multiplied by 1 − ρ². The new information therefore has the same team structure at a smaller variance scale."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.2",
          "details": [
            {
              "title": "Decompose signal and sensor errors separately",
              "body": "Write $X(t)=\\rho X(s)+\\xi$ and $E_i(t)=\\rho E_i(s)+\\epsilon_i$. Their innovations are independent of the joint past, and $\\xi,\\epsilon_1,\\ldots,\\epsilon_n$ are mutually independent. Then\n\\[Z_i=\\xi+\\epsilon_i,\\quad \\Var(\\xi)=a(1-\\rho^2),\\quad\\Var(\\epsilon_i)=b(1-\\rho^2).\\]"
            },
            {
              "title": "Compute diagonal and off-diagonal entries",
              "body": "For $i=j$, $\\Var(Z_i)=(a+b)(1-\\rho^2)$. For $i\\ne j$, only the shared innovation $\\xi$ contributes to covariance, giving $a(1-\\rho^2)$. The covariance matrix is therefore $(1-\\rho^2)(a\\mathbf1\\mathbf1^\\top+bI)$. The whole vector is independent of $\\mathcal F(s)$ because its underlying innovations are independent of the joint past."
            }
          ]
        },
        {
          "id": "proof-H-2-3",
          "title": "Split the target into three parts",
          "body": "$X(t)=\\rho h\\bar Y(s)+h\\bar Z+\\eta(t)$, where $\\eta(t)$ is independent of all sensor data and has variance $P_n$.",
          "explain": [
            "The true signal consists of a common prediction from the old pooled mean, a sensor-informed innovation, and the irreducible residual η. The old shared prediction can be used identically by every agent. The remaining decision problem is about the new innovations."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.3",
          "details": [
            {
              "title": "Start with the pooled residual identity",
              "body": "Proposition 1 defines $\\eta(t)=X(t)-h\\bar Y(t)$, where $h=a/v$. Rearranging gives $X(t)=h\\bar Y(t)+\\eta(t)$. Its residual is independent of every sensor observation and has variance $P_n$."
            },
            {
              "title": "Average the innovation identities",
              "body": "From $Y_i(t)=\\rho Y_i(s)+Z_i$, averaging gives $\\bar Y(t)=\\rho\\bar Y(s)+\\bar Z$. Substitution yields\n\\[X(t)=\\underbrace{\\rho h\\bar Y(s)}_{m}+h\\bar Z+\\eta(t).\\]\nThe first term is common and known. The second is new information spread across sensors. The last is error that even the full sensor process cannot reveal in this model."
            }
          ]
        },
        {
          "id": "proof-H-2-4",
          "title": "Check every intermediate observation",
          "body": "For $s<r\\le t$, define $Z_i(r)=Y_i(r)-e^{-\\lambda(r-s)}Y_i(s)$. Then $\\Cov(\\bar Z,Z_i(r))=[v/(a+b)]\\Cov(Z_i,Z_i(r))$.",
          "explain": [
            "An agent might benefit from readings between s and t, so checking only its current reading would be insufficient. This identity compares covariances with its innovation at an arbitrary intermediate time r. The same proportionality holds for every r in the interval."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.4",
          "details": [
            {
              "title": "Represent every intermediate local observation",
              "body": "For $s<r\\le t$, set $Z_i(r)=Y_i(r)-e^{-\\lambda(r-s)}Y_i(s)$. Given $\\mathcal F(s)$, knowing these innovations is equivalent to knowing the local observations after $s$. We must predict $\\bar Z$ from this whole path."
            },
            {
              "title": "Use the common temporal factor",
              "body": "Let $f(r)=e^{-\\lambda(t-r)}(1-e^{-2\\lambda(r-s)})$. The next step derives this factor explicitly. Covariances then have the form\n\\[\\Cov(Z_j(t),Z_i(r))=\\begin{cases}(a+b)f(r),&j=i,\\\\af(r),&j\\ne i.\\end{cases}\\]"
            },
            {
              "title": "Average over the terminal sensor index",
              "body": "Thus $\\Cov(\\bar Z,Z_i(r))=[(a+b)+(n-1)a]f(r)/n=vf(r)$, whereas $\\Cov(Z_i,Z_i(r))=(a+b)f(r)$. Multiplication of the latter by $v/(a+b)$ gives the former. Crucially, this multiplier is independent of $r$."
            }
          ]
        },
        {
          "id": "proof-H-2-5",
          "title": "See what the common rate buys",
          "body": "Both covariances have the temporal factor $e^{-\\lambda(t-r)}(1-e^{-2\\lambda(r-s)})$.",
          "explain": [
            "Both covariances contain the same time-dependent factor. Their proportionality is therefore independent of the intermediate time r. This is the crucial consequence of assigning the same temporal rate to the signal and sensor disturbances."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.5",
          "details": [
            {
              "title": "Expand the covariance into four terms",
              "body": "Let $\\Sigma_{ji}=\\Cov(Y_j(s),Y_i(s))$, $\\alpha=e^{-\\lambda(r-s)}$, and $\\beta=e^{-\\lambda(t-r)}$, so $\\rho=\\alpha\\beta$. Bilinearity gives\n\\[\\begin{aligned}\n&\\Cov(Y_j(t)-\\rho Y_j(s),Y_i(r)-\\alpha Y_i(s))\\\\\n&=\\Sigma_{ji}\\big[\\beta-\\alpha\\rho-\\rho\\alpha+\\rho\\alpha\\big].\n\\end{aligned}\\]\nThe four terms come from current–intermediate, current–old, old–intermediate, and old–old covariances, in that order."
            },
            {
              "title": "Factor the remaining expression",
              "body": "The bracket is $\\beta-\\alpha\\rho=\\beta-\\alpha^2\\beta=\\beta(1-\\alpha^2)$. Therefore\n\\[\\Cov(Z_j(t),Z_i(r))=\\Sigma_{ji}e^{-\\lambda(t-r)}(1-e^{-2\\lambda(r-s)}).\\]\nOnly the spatial coefficient $\\Sigma_{ji}$ changes with sensor indices. The time dependence is shared."
            }
          ]
        },
        {
          "id": "proof-H-2-6",
          "title": "Remove everything the local path predicts",
          "body": "$\\bar Z-vZ_i/(a+b)$ is orthogonal to the entire local innovation path and to $\\mathcal F(s)$.",
          "explain": [
            "Subtract the indicated multiple of the current innovation from the pooled innovation. The remaining quantity has zero covariance with every local innovation since s and with all old sensor observations. Thus no part of the available history predicts that residual."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.6",
          "details": [
            {
              "title": "Form the candidate projection residual",
              "body": "Set $W=\\bar Z-vZ_i/(a+b)$. For every $s<r\\le t$, step H.2.4 gives\n\\[\\Cov(W,Z_i(r))=vf(r)-\\frac v{a+b}(a+b)f(r)=0.\\]\nThe same $W$ is uncorrelated with every variable on the local innovation path."
            },
            {
              "title": "Include all old sensor observations",
              "body": "The terminal innovation vector is independent of $\\mathcal F(s)$, so its linear combination $W$ has zero covariance with each old sensor observation as well. Since $Y_i(r)=e^{-\\lambda(r-s)}Y_i(s)+Z_i(r)$, the old data and the innovation path together generate $\\mathcal G_i$. We have checked every generator used in the enlarged information field."
            }
          ]
        },
        {
          "id": "proof-H-2-7",
          "title": "Obtain a conditional mean for the full history",
          "body": "Gaussianity gives $\\E[\\bar Z\\mid\\mathcal G_i]=vZ_i/(a+b)$.",
          "explain": [
            "Joint Gaussianity turns the zero-covariance calculation into independence from the complete information field. The agent's best prediction of the pooled innovation is therefore v/(a+b) times its current innovation Z_i. This statement covers the whole continuous-time history."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.7",
          "details": [
            {
              "title": "Turn the covariance check into independence",
              "body": "The residual $W$ and every finite set of old readings and local-path innovations are jointly Gaussian. Their zero cross-covariances make them independent. This extends to the sigma-field generated by all such observations, namely $\\mathcal G_i$. Therefore $\\E[W\\mid\\mathcal G_i]=0$."
            },
            {
              "title": "Keep the observable part of the decomposition",
              "body": "The endpoint innovation $Z_i$ is known to agent $i$. In the identity $\\bar Z=vZ_i/(a+b)+W$, take conditional expectation to get\n\\[\\E[\\bar Z\\mid\\mathcal G_i]=\\frac v{a+b}Z_i.\\]\nIntermediate readings do not add predictive power for this target because their covariances with the residual all vanish."
            }
          ]
        },
        {
          "id": "proof-H-2-8",
          "title": "Predict the target and average correction",
          "body": "Independence of $\\eta(t)$ gives $\\E[h\\bar Z+\\eta(t)\\mid\\mathcal G_i]=aZ_i/(a+b)$ and $\\E[k\\bar Z\\mid\\mathcal G_i]=kvZ_i/(a+b)$.",
          "explain": [
            "The residual η has conditional mean zero because it is centered and independent of all sensor data. Multiplying the previous projection by h or k gives the two conditional means needed in the team equation. These calculations retain the full history throughout."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.8",
          "details": [
            {
              "title": "Predict the signal correction",
              "body": "The residual $\\eta(t)$ is independent of all sensor data and centered, so its conditional mean under $\\mathcal G_i$ is zero. Then\n\\[\\E[h\\bar Z+\\eta(t)\\mid\\mathcal G_i]=h\\frac v{a+b}Z_i=\\frac a{a+b}Z_i,\\]\nusing $hv=a$."
            },
            {
              "title": "Predict the average action correction",
              "body": "The proposed corrections are $kZ_j$, so their average is $k\\bar Z$. Linearity and step H.2.7 yield\n\\[\\E[k\\bar Z\\mid\\mathcal G_i]=\\frac{kv}{a+b}Z_i.\\]\nConsequently $\\E[X(t)\\mid\\mathcal G_i]=m+aZ_i/(a+b)$ and $\\E[\\bar u\\mid\\mathcal G_i]=m+kvZ_i/(a+b)$, where $m=\\rho h\\bar Y(s)$."
            }
          ]
        },
        {
          "id": "proof-H-2-9",
          "title": "Verify the optimal action directly",
          "body": "Subtract the common prediction. Since $(1+\\kappa)(a+b)-\\kappa v=d$, the correction $kZ_i$ satisfies (5) under the full path information. Lemma 1 certifies optimality.",
          "explain": [
            "Insert the common prediction plus kZ_i into Lemma 1. The displayed identity for d makes the two sides of the normal equation equal. The candidate is therefore optimal even among policies using every old sensor history and the full subsequent local path."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.9",
          "details": [
            {
              "title": "Insert both terms of the proposed action",
              "body": "For $u_i=m+kZ_i$, the left side of Lemma 1 becomes\n\\[\\begin{aligned}(1+\\kappa)u_i-\\kappa\\E[\\bar u\\mid\\mathcal G_i]\n&=(1+\\kappa)(m+kZ_i)-\\kappa\\left(m+\\frac{kv}{a+b}Z_i\\right)\\\\\n&=m+\\frac{k[(1+\\kappa)(a+b)-\\kappa v]}{a+b}Z_i.\n\\end{aligned}\\]"
            },
            {
              "title": "Reduce to the already solved gain equation",
              "body": "The bracket equals $d$, and $k=a/d$. The expression is therefore $m+aZ_i/(a+b)$, exactly $\\E[X(t)\\mid\\mathcal G_i]$ from the previous step. The normal equations hold for every agent."
            },
            {
              "title": "Apply the sufficiency part of the lemma",
              "body": "The action is measurable from $\\mathcal G_i$ and square integrable. Lemma 1 now certifies its unique optimality among all policies using complete delayed sensor sharing and full local histories. No linearity restriction has been imposed on competing policies."
            }
          ]
        },
        {
          "id": "proof-H-2-10",
          "title": "One scalar achieves full delayed sharing",
          "body": "The policy (15) is feasible under the hybrid field (4), so it attains the same value as complete delayed sharing.",
          "explain": [
            "The optimal action just found only needs the old pooled scalar and two own-sensor readings. Those are all available in the smaller hybrid information set. Since a hybrid-feasible policy attains the optimum for the larger information set, their optimal losses are equal."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.10",
          "details": [
            {
              "title": "List what the optimal policy actually uses",
              "body": "The action $\\rho(a/v)\\bar Y(s)+(a/d)[Y_i(t)-\\rho Y_i(s)]$ uses the old shared mean, the stored own-sensor reading from $s$, and the current own-sensor reading. All three are available under the hybrid information structure."
            },
            {
              "title": "Write the two bounding inequalities",
              "body": "Let $J_{\\rm full}$ be the minimum with $\\mathcal F(s)\\vee\\mathcal F_i(t)$. Information inclusion gives $J_{\\rm full}\\le J_H$. The candidate is hybrid-feasible and has cost $J_{\\rm full}$, so $J_H\\le J_{\\rm full}$. Hence $J_H=J_{\\rm full}$."
            },
            {
              "title": "Clarify where the fresh reading enters the comparison",
              "body": "Both sides of this equality give each agent its fresh local reading and its own history. “Complete delayed sharing” adds all old raw sensor data to that same fresh local information. The theorem says that replacing those old raw data by their scalar mean loses no decision value here. It does not compare the hybrid with the delayed-only architecture, which lacks fresh local readings."
            }
          ]
        },
        {
          "id": "proof-H-2-11",
          "title": "Scale the part of the cost that can change",
          "body": "The irreducible variance is $P_n$ and the remaining quadratic cost scales by $1-\\rho^2$. Thus $J_H=P_n+(1-\\rho^2)(J_L-P_n)$.",
          "explain": [
            "The irreducible sensor-estimation error Pₙ stays the same in the decomposition. The remaining loss is quadratic in the sensor innovations, whose covariance is scaled by 1 − ρ². This yields an exact interpolation between the fresh-pooled and fresh-local costs."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.11",
          "details": [
            {
              "title": "Cancel the common prediction in the errors",
              "body": "With $u_i=m+kZ_i$ and $X=m+h\\bar Z+\\eta$,\n\\[u_i-X=kZ_i-h\\bar Z-\\eta,\\qquad u_i-\\bar u=k(Z_i-\\bar Z).\\]\nThe old shared prediction disappears from both expressions."
            },
            {
              "title": "Separate the irreducible residual variance",
              "body": "The residual $\\eta$ is centered and independent of $Z$, so its cross terms with $kZ_i-h\\bar Z$ have zero expectation. Each tracking term contributes $P_n$ plus $\\E[(kZ_i-h\\bar Z)^2]$. Averaging over agents still gives one $P_n$."
            },
            {
              "title": "Scale each remaining quadratic expectation",
              "body": "The covariance of $Z$ is $(1-\\rho^2)$ times the covariance of the fresh sensor vector $Y$. For any fixed coefficient vector $c$, $\\E[(c^\\top Z)^2]=c^\\top\\Cov(Z)c$, so every remaining quadratic term scales by $1-\\rho^2$.\n\nIn the fresh problem, the same decomposition $X=h\\bar Y+\\eta$ gives $J_L=P_n+$ those remaining quadratic terms. Their sum for $Z$ is therefore $(1-\\rho^2)(J_L-P_n)$."
            },
            {
              "title": "Rewrite as the two endpoint costs",
              "body": "Consequently\n\\[J_H=P_n+(1-\\rho^2)(J_L-P_n)=\\rho^2J_P+(1-\\rho^2)J_L,\\]\nbecause $P_n=J_P$. This explains exactly why the old-sharing contribution is weighted by the square of correlation."
            }
          ]
        },
        {
          "id": "proof-H-2-12",
          "title": "Compute the hybrid estimation error",
          "body": "The enlarged-information posterior mean is $\\rho h\\bar Y(s)+aZ_i/(a+b)$. It is hybrid-feasible and has error variance $P_n+(1-\\rho^2)(P_1-P_n)$.",
          "explain": [
            "The best conditional estimate uses a/(a+b) on the local innovation, while the team action uses a/d. This difference reflects the disagreement objective. The estimation-error variance interpolates between Pₙ and P₁, and the estimator is available in the smaller hybrid information set."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.12",
          "details": [
            {
              "title": "Use the full-information conditional mean",
              "body": "Step H.2.8 established $\\widehat X=m+aZ_i/(a+b)$. This estimator uses only the three hybrid quantities, so the enlarged-field optimum for squared estimation error is attainable in the smaller field too."
            },
            {
              "title": "Write its error and remove cross terms",
              "body": "The error is\n\\[X-\\widehat X=h\\bar Z-\\frac a{a+b}Z_i+\\eta.\\]\nThe first two terms are linear in sensor innovations and independent of $\\eta$. Their variance scales by $1-\\rho^2$."
            },
            {
              "title": "Identify the fresh counterpart",
              "body": "For a fresh local estimate,\n\\[X-\\frac a{a+b}Y_i=h\\bar Y-\\frac a{a+b}Y_i+\\eta.\\]\nIts variance is $P_1$, of which $P_n$ comes from $\\eta$. Thus the fresh linear part has variance $P_1-P_n$. The hybrid error variance is\n\\[P_H=P_n+(1-\\rho^2)(P_1-P_n)=\\rho^2P_n+(1-\\rho^2)P_1.\\]\nGaussian projection also makes this residual independent of the enlarged information, so this is the conditional posterior variance."
            }
          ]
        },
        {
          "id": "proof-H-2-13",
          "title": "Read off the exponential benefit",
          "body": "Subtracting the cost from $J_L$ yields $\\Delta e^{-2\\lambda\\tau}$.",
          "explain": [
            "Subtract the hybrid cost from J_L. The result is the fresh-sharing benefit Δ multiplied by ρ² = e^(−2λτ). This is an exact equality, including its coefficient and decay rate."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.13",
          "details": [
            {
              "title": "Subtract the interpolation formula",
              "body": "From $J_H=\\rho^2J_P+(1-\\rho^2)J_L$,\n\\[\\begin{aligned}J_L-J_H&=J_L-\\rho^2J_P-J_L+\\rho^2J_L\\\\&=\\rho^2(J_L-J_P)=\\rho^2\\Delta.\\end{aligned}\\]"
            },
            {
              "title": "Substitute the temporal correlation",
              "body": "Since $\\rho=e^{-\\lambda\\tau}$, the gain is $\\Delta e^{-2\\lambda\\tau}$. At every finite age it is strictly positive because $\\Delta>0$ and the exponential is positive. It tends to zero as age tends to infinity."
            }
          ]
        },
        {
          "id": "proof-H-2-14",
          "title": "Close the positive-age case",
          "body": "Q.E.D. The positive-age branch is established.",
          "explain": [
            "For every positive age we have proved the optimal policy, equality with full delayed sharing, the posterior variance, and the team cost. The local-history argument did not require restricting the policies to current readings in advance."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.2.14",
          "details": [
            {
              "title": "Check each obligation in the positive-age case",
              "body": "H.2.9 certifies the full-history optimum. H.2.10 proves the smaller hybrid field attains it. H.2.11 computes team loss, H.2.12 computes posterior variance, and H.2.13 computes the gain over local operation. Together these establish every assertion for $\\tau>0$."
            },
            {
              "title": "Keep the two types of gains distinct",
              "body": "The posterior mean uses the correction coefficient $a/(a+b)$. The team-optimal action uses $a/d$. The latter also accounts for disagreement. The proof establishes both results without conflating estimation error with team loss."
            }
          ]
        },
        {
          "id": "proof-H-3",
          "title": "Combine the two age cases",
          "body": "Q.E.D. The two cases cover every $\\tau\\ge0$.",
          "explain": [
            "Zero age and positive age cover all finite nonnegative ages. The full theorem follows. As a consequence, an old pool still improves the hybrid's decision loss at every finite age, although the benefit approaches zero as age grows."
          ],
          "source": "Theorem 1: Hybrid policy and exponential value · Proof step H.3",
          "details": [
            {
              "title": "Combine the two cases",
              "body": "Every allowed age satisfies either $\\tau=0$ or $\\tau>0$. H.1 handles zero age directly. The positive-age proof supplies the action, optimality, posterior variance, and loss for all other ages. Therefore no allowed finite age is omitted."
            },
            {
              "title": "Check consistency at the boundary",
              "body": "As $\\tau\\downarrow0$, $\\rho\\to1$ and $\\Var(Z_i)=(a+b)(1-\\rho^2)\\to0$. The innovation correction vanishes in mean square, and the cost formulas converge to $J_P$ and $P_n$, agreeing with the direct zero-age calculation."
            }
          ]
        },
        {
          "id": "hybrid-implementation",
          "title": "How to compute the hybrid action",
          "body": "\\[u_i^H(t)=\\underbrace{\\rho\\frac av\\bar Y(s)}_{\\text{shared prediction}}+\\underbrace{\\frac ad\\bigl[Y_i(t)-\\rho Y_i(s)\\bigr]}_{\\text{local correction}}.\\]",
          "explain": [
            "Predict the old pooled estimate forward. Then subtract the predicted old local reading from the current local reading, and scale that innovation by the local team gain.",
            "Keeping Y_i(s) lets the agent separate its new information from the part predicted by its own old reading. A timestamped local buffer supports this when updates are in transit."
          ],
          "source": "Implementation of Theorem 1 · Equation (15)",
          "details": [
            {
              "title": "Calculate the shared prediction",
              "body": "From the received mean $\\bar Y(s)$, form the old pooled estimate $(a/v)\\bar Y(s)$. Multiply by $\\rho=e^{-\\lambda(t-s)}$ to predict it forward to the current time."
            },
            {
              "title": "Calculate the new private information",
              "body": "Predict the old own-sensor reading as $\\rho Y_i(s)$, then subtract it from the current reading to get $Z_i=Y_i(t)-\\rho Y_i(s)$. Multiply by $a/d$ to account for the tracking and disagreement tradeoff, then add this correction to the shared prediction."
            },
            {
              "title": "Explain why the stored local sample matters",
              "body": "The old shared mean already incorporates information correlated with the old local sample. Subtracting $\\rho Y_i(s)$ isolates the new innovation and prevents treating the entire current reading as new information. The formula’s proof relies on this innovation being independent of the old sensor history."
            }
          ]
        },
        {
          "id": "age-budget",
          "title": "An exact budget for information age",
          "body": "For $0<\\alpha<1$,\\[J_L-J_H(\\tau)\\ge\\alpha\\Delta\\quad\\Longleftrightarrow\\quad\\tau\\le\\frac{\\log(1/\\alpha)}{2\\lambda}.\\]",
          "explain": [
            "Choose the fraction of fresh-sharing benefit you want to preserve. This formula gives the largest permitted age.",
            "The fraction depends only on age and temporal rate. The amount of benefit Δ still depends on sensor count, variances, and the disagreement penalty."
          ],
          "source": "Derived claim · Equation (22)",
          "details": [
            {
              "title": "Cancel the positive fresh benefit",
              "body": "The desired gain inequality is $\\Delta e^{-2\\lambda\\tau}\\ge\\alpha\\Delta$. Since $\\Delta>0$, divide by it to obtain $e^{-2\\lambda\\tau}\\ge\\alpha$."
            },
            {
              "title": "Solve for the maximum age",
              "body": "Logarithm preserves the inequality, giving $-2\\lambda\\tau\\ge\\log\\alpha$. Dividing by the negative number $-2\\lambda$ reverses the direction:\n\\[\\tau\\le-\\frac{\\log\\alpha}{2\\lambda}=\\frac{\\log(1/\\alpha)}{2\\lambda}.\\]\nThe right side is positive because $0<\\alpha<1$."
            }
          ]
        },
        {
          "id": "half-life",
          "title": "The benefit has half the correlation half-life",
          "body": "\\[t_{1/2}^{\\rm value}=\\frac{\\log2}{2\\lambda}.\\]\\[t_{1/2}^{\\rm correlation}=\\frac{\\log2}{\\lambda}.\\]",
          "explain": [
            "The signal correlation decays as e^(−λτ), while coordination value decays as its square. The value therefore falls by half in half the time needed for correlation to fall by half.",
            "Half-life and coherence time are different conventions. The coherence time 1/λ corresponds to correlation e⁻¹, rather than one half."
          ],
          "source": "Section III-B · Half-life interpretation",
          "details": [
            {
              "title": "Solve for a halving of correlation",
              "body": "Set $e^{-\\lambda t}=1/2$. Taking logarithms gives $-\\lambda t=-\\log2$, hence $t=\\log2/\\lambda$."
            },
            {
              "title": "Solve for a halving of coordination value",
              "body": "Set $\\Delta e^{-2\\lambda t}=\\Delta/2$. Cancel $\\Delta>0$ and take logarithms to get $t=\\log2/(2\\lambda)$. Dividing this by the correlation half-life gives exactly $1/2$."
            }
          ]
        }
      ]
    },
    {
      "title": "8. Unequal sensor quality",
      "lessons": [
        {
          "id": "unequal-notation",
          "title": "The new symbols for unequal sensors",
          "body": "\\[\\Var(E_i(t))=b_i>0.\\]\\[C_i=(1+\\kappa)a+b_i[1+\\kappa(1-1/n)].\\]\\[\\theta=\\frac1n\\sum_i C_i^{-1}.\\]",
          "explain": [
            "The common variance b becomes an individual variance b_i. The quantity C_i is a coefficient in the coupled local-gain equations. Theta averages its reciprocal across sensors.",
            "Capital C_i here is a sensor coefficient. Later C(T) will denote the total average cost of periodic refreshing. They are different quantities."
          ],
          "source": "Section IV-A · Equation (23)"
        },
        {
          "id": "claim-U",
          "title": "Proposition 2: Unequal sensor quality",
          "body": "Replace $b$ by $b_i>0$, retaining independence, stationarity, Gaussianity, and a common temporal rate. Define\n\\[\nC_i=(1+\\kappa)a+b_i[1+\\kappa(1-1/n)],\\qquad \\theta=n^{-1}\\sum_i C_i^{-1}.\n\\]\nThen $k_i=a/[C_i(1-\\kappa a\\theta)]$, $J_L=a-a^2\\theta/(1-\\kappa a\\theta)$,\n\\[\nP=(a^{-1}+\\sum_i b_i^{-1})^{-1},\\quad\n\\mu_P(t)=P\\sum_iY_i(t)/b_i,\\quad J_P=P.\n\\]\nThe hybrid action is $u_i^H=\\rho\\mu_P(s)+k_i[Y_i(t)-\\rho Y_i(s)]$ and $J_H=\\rho^2J_P+(1-\\rho^2)J_L$.",
          "explain": [
            "This result allows the sensors to have different error variances. More accurate sensors receive larger weights in the shared estimate.",
            "The same hybrid cost law survives. The signal and all sensor disturbances must still share a common temporal rate."
          ],
          "source": "Claim · Paper equations (23)--(25)",
          "details": [
            {
              "title": "Explain why sensor-dependent gains appear",
              "body": "An agent with different error variance has a different conditional estimate and a different predicted relationship to other actions. The normal equations therefore produce individual gains $k_i$ coupled through their average $\\bar k$."
            },
            {
              "title": "Explain why one shared scalar still suffices",
              "body": "With unequal variances, Gaussian conditioning gives the precision-weighted mean $\\mu_P=P\\sum_iY_i/b_i$. The common temporal rate makes its residual independent of all sensor histories. This is the property used to preserve the hybrid cost law."
            }
          ]
        },
        {
          "id": "proof-U-1",
          "title": "Give each sensor its own gain",
          "body": "Substitution into (5) gives $C_i k_i-\\kappa a\\bar k=a$, where $\\bar k=n^{-1}\\sum_i k_i$.",
          "explain": [
            "With unequal noise variances, a single common gain is no longer appropriate. Substitute a separate k_i for each sensor. The normal equations couple those gains through their average, written as bar k."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.1",
          "details": [
            {
              "title": "Predict the other local actions",
              "body": "Consider $u_j=k_jY_j(t)$ and $\\bar k=n^{-1}\\sum_jk_j$. For $j\\ne i$, the common-rate covariance argument gives $\\E[Y_j(t)\\mid\\mathcal F_i(t)]=aY_i(t)/(a+b_i)$. For $j=i$, the reading itself is known. Thus\n\\[\\E[\\bar u\\mid\\mathcal F_i(t)]=\\frac{a\\bar k+b_i k_i/n}{a+b_i}Y_i(t).\\]"
            },
            {
              "title": "Insert into the conditional normal equation",
              "body": "The conditional target mean is $aY_i(t)/(a+b_i)$. Multiply the normal equation by $a+b_i$ and equate the coefficients of $Y_i(t)$:\n\\[(1+\\kappa)(a+b_i)k_i-\\kappa(a\\bar k+b_i k_i/n)=a.\\]"
            },
            {
              "title": "Collect the terms multiplying the individual gain",
              "body": "The coefficient of $k_i$ becomes $(1+\\kappa)a+b_i(1+\\kappa-\\kappa/n)=C_i$. The remaining coupling term is $-\\kappa a\\bar k$. Hence $C_i k_i-\\kappa a\\bar k=a$."
            }
          ]
        },
        {
          "id": "proof-U-2",
          "title": "Solve the coupled gains",
          "body": "\\[\\bar k=\\frac{a\\theta}{1-\\kappa a\\theta},\\qquad k_i=\\frac{a}{C_i(1-\\kappa a\\theta)}.\\]",
          "explain": [
            "Average the equations over sensors to solve for the mean gain. Substituting that average back gives every individual gain. The quantity θ is the average of 1/C_i, so the solution depends on the collection of sensor qualities."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.2",
          "details": [
            {
              "title": "Solve each equation in terms of the mean gain",
              "body": "From $C_i k_i=a+\\kappa a\\bar k$, divide by $C_i>0$:\n\\[k_i=\\frac{a+\\kappa a\\bar k}{C_i}.\\]\nThe numerator is the same for every sensor."
            },
            {
              "title": "Average and solve the single scalar equation",
              "body": "Averaging over $i$ gives $\\bar k=(a+\\kappa a\\bar k)\\theta$. Rearrange:\n\\[(1-\\kappa a\\theta)\\bar k=a\\theta,\\qquad \\bar k=\\frac{a\\theta}{1-\\kappa a\\theta}.\\]\nThe next step verifies positivity of this denominator."
            },
            {
              "title": "Substitute the mean gain back",
              "body": "Now\n\\[a+\\kappa a\\bar k=a+\\frac{\\kappa a^2\\theta}{1-\\kappa a\\theta}=\\frac a{1-\\kappa a\\theta}.\\]\nDividing by $C_i$ yields $k_i=a/[C_i(1-\\kappa a\\theta)]$."
            }
          ]
        },
        {
          "id": "proof-U-3",
          "title": "Check that the solution is well defined",
          "body": "The denominator is positive because $C_i>(1+\\kappa)a$.",
          "explain": [
            "The denominator 1 − κaθ must be positive before it can be used. Every C_i is greater than (1+κ)a, which gives κaθ < 1 for positive κ. At κ = 0 the denominator is simply one."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.3",
          "details": [
            {
              "title": "Bound the average reciprocal",
              "body": "Because $b_i>0$ and $1+\\kappa(1-1/n)>0$, $C_i>(1+\\kappa)a$. Reciprocals reverse this inequality:\n\\[\\frac1{C_i}<\\frac1{(1+\\kappa)a},\\qquad \\theta<\\frac1{(1+\\kappa)a}.\\]"
            },
            {
              "title": "Handle zero and positive disagreement prices",
              "body": "If $\\kappa=0$, the denominator is exactly 1. If $\\kappa>0$, multiplication of the previous strict inequality gives $\\kappa a\\theta<\\kappa/(1+\\kappa)<1$. In either case $1-\\kappa a\\theta>0$. Thus the gains are finite and well defined."
            }
          ]
        },
        {
          "id": "proof-U-4",
          "title": "Certify optimality with unequal quality",
          "body": "Lemma 1 certifies optimality of the local policy.",
          "explain": [
            "The separate gains satisfy the conditional team equations under each full local history. Lemma 1 therefore proves their optimality over all admissible policies. Introducing linear gains was a way to construct the solution."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.4",
          "details": [
            {
              "title": "Verify admissibility",
              "body": "Each $k_i$ is a finite deterministic constant and $Y_i(t)$ has finite variance $a+b_i$. Hence $k_iY_i(t)$ is in $L^2(\\mathcal F_i(t))$."
            },
            {
              "title": "Apply the optimality test already established",
              "body": "Steps U.1–U.3 solve the conditional normal equations for the entire local information fields. Lemma 1 then certifies the policy’s optimality and uniqueness among all feasible policies. Testing a linear candidate did not restrict the optimization to linear policies."
            }
          ]
        },
        {
          "id": "proof-U-5",
          "title": "Compute the unequal-quality local cost",
          "body": "The quadratic term equals $a\\bar k$, so $J_L=a-a\\bar k$.",
          "explain": [
            "Multiply each gain equation by its gain and average. The quadratic part of the loss becomes a times the average gain, cancelling one of the two linear contributions. This leaves J_L = a − a bar k."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.5",
          "details": [
            {
              "title": "Separate the objective into constant, linear, and quadratic parts",
              "body": "For $u_i=k_iY_i$, let\n\\[Q(u)=\\frac1n\\sum_i\\E[u_i^2+\\kappa(u_i-\\bar u)^2].\\]\nBecause $\\E[u_iX]=ak_i$, expansion of tracking loss gives $J(u)=a-2a\\bar k+Q(u)$."
            },
            {
              "title": "Use the normal equations to evaluate the quadratic part",
              "body": "Multiply each normal equation by $u_i$ and take expectation. The conditioning can be removed because $u_i$ is measurable from the agent’s information. Average over $i$:\n\\[\\frac{1+\\kappa}{n}\\sum_i\\E[u_i^2]-\\kappa\\E[\\bar u^2]=a\\bar k.\\]\nHere $n^{-1}\\sum_i u_i\\bar u=\\bar u^2$. Also $n^{-1}\\sum_i(u_i-\\bar u)^2=n^{-1}\\sum_i u_i^2-\\bar u^2$. The left side is exactly $Q(u)$."
            },
            {
              "title": "Substitute and simplify",
              "body": "Thus $Q(u)=a\\bar k$ and\n\\[J_L=a-2a\\bar k+a\\bar k=a-a\\bar k=a-\\frac{a^2\\theta}{1-\\kappa a\\theta}.\\]"
            }
          ]
        },
        {
          "id": "proof-U-6",
          "title": "Pool with precision weights",
          "body": "\\[P=\\left(a^{-1}+\\sum_i b_i^{-1}\\right)^{-1}.\\]\\[\\mu_P(t)=P\\sum_i\\frac{Y_i(t)}{b_i},\\qquad J_P=P.\\]",
          "explain": [
            "A more accurate sensor has smaller disturbance variance and receives larger weight 1/b_i. Gaussian conditioning gives the weighted pooled estimate μ_P and its residual variance P. The prior signal precision 1/a also enters the total precision."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.6",
          "details": [
            {
              "title": "Write the Gaussian posterior at one time",
              "body": "Given sensor values $y_1,\\ldots,y_n$, the posterior density for the common signal is proportional to\n\\[\\exp\\left[-\\frac12\\left(\\frac{x^2}{a}+\\sum_i\\frac{(y_i-x)^2}{b_i}\\right)\\right].\\]\nThe prior contributes $x^2/a$. Independent sensor errors contribute one squared residual per sensor."
            },
            {
              "title": "Collect and complete the square in x",
              "body": "The terms involving $x$ are\n\\[x^2\\left(a^{-1}+\\sum_i b_i^{-1}\\right)-2x\\sum_i y_i/b_i.\n\\]\nSet $P=(a^{-1}+\\sum_i b_i^{-1})^{-1}$ and $\\mu=P\\sum_i y_i/b_i$. The expression is $(x-\\mu)^2/P$ plus a term independent of $x$. Thus the posterior is Gaussian with mean $\\mu_P$ and variance $P$."
            },
            {
              "title": "Connect to team loss and histories",
              "body": "All agents can choose the common mean and have zero disagreement, so endpoint pooling has loss $P$. The next step proves that the entire sensor history adds no further information beyond this weighted endpoint summary."
            }
          ]
        },
        {
          "id": "proof-U-7",
          "title": "Keep the all-history residual property",
          "body": "$X(t)-\\mu_P(t)$ is independent of the entire sensor process because all temporal covariances share one factor.",
          "explain": [
            "Unequal variances change the weights but preserve the common temporal factor. Once the pooled residual is uncorrelated with each sensor at the same time, it is uncorrelated with each sensor at all times. Gaussianity again gives independence from the sensor process."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.7",
          "details": [
            {
              "title": "Calculate the weighted mean covariance",
              "body": "Let $S=\\sum_i b_i^{-1}$ and $q_r=e^{-\\lambda|t-r|}$. Since $\\Cov(Y_i(t),Y_j(r))=(a+b_j\\mathbf1_{i=j})q_r$,\n\\[\\Cov(\\mu_P(t),Y_j(r))=P(aS+1)q_r=a q_r,\\]\nwhere $P(a^{-1}+S)=1$ implies $P(1+aS)=a$."
            },
            {
              "title": "Subtract from the signal covariance",
              "body": "Since $\\Cov(X(t),Y_j(r))=a q_r$, the residual $X(t)-\\mu_P(t)$ has zero covariance with every sensor at every time. Joint Gaussianity makes it independent of the full sensor process. Its variance remains $P$, proving the full-history pooled result."
            }
          ]
        },
        {
          "id": "proof-U-8",
          "title": "Write the new covariance matrix",
          "body": "Innovations have covariance $(1-\\rho^2)\\Sigma$, where $\\Sigma=a\\mathbf1\\mathbf1^\\top+\\operatorname{diag}(b_i)$.",
          "explain": [
            "The shared signal contributes a to every matrix entry. Each sensor's private disturbance adds b_i to its own diagonal entry. Temporal innovations multiply this matrix by the same factor 1 − ρ²."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.8",
          "details": [
            {
              "title": "Write the innovations with individual noise variances",
              "body": "As before, $Z_i=\\xi+\\epsilon_i$, with mutually independent driving innovations. Now $\\Var(\\epsilon_i)=b_i(1-\\rho^2)$, whereas $\\Var(\\xi)=a(1-\\rho^2)$."
            },
            {
              "title": "Assemble the covariance matrix",
              "body": "Diagonal entries are $(a+b_i)(1-\\rho^2)$ and off-diagonal entries are $a(1-\\rho^2)$. Factoring out the common multiplier gives\n\\[\\Cov(Z)=(1-\\rho^2)\\Sigma,\\quad\\Sigma=a\\mathbf1\\mathbf1^\\top+\\operatorname{diag}(b_i).\\]\nThe vector remains independent of all pre-$s$ sensor data."
            }
          ]
        },
        {
          "id": "proof-U-9",
          "title": "Repeat the full-path projection",
          "body": "For $\\mathcal G_i=\\mathcal F(s)\\vee\\mathcal F_i(t)$, the covariance argument in (21) gives $\\E[Z_j\\mid\\mathcal G_i]=\\Sigma_{ji}Z_i/\\Sigma_{ii}$.",
          "explain": [
            "Use the same intermediate-time argument with the unequal-quality covariance matrix Σ. For j = i, the coefficient is one. For another sensor, the coefficient is a/(a+b_i). The projection remains valid given the entire local path and old shared history."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.9",
          "details": [
            {
              "title": "Use the same path calculation with new spatial coefficients",
              "body": "For every $s<r\\le t$, the four-term covariance expansion gives\n\\[\\Cov(Z_j(t),Z_i(r))=\\Sigma_{ji}f(r),\\qquad\\Cov(Z_i(t),Z_i(r))=\\Sigma_{ii}f(r),\\]\nwhere $f(r)=e^{-\\lambda(t-r)}(1-e^{-2\\lambda(r-s)})$."
            },
            {
              "title": "Remove the part predictable from the own-sensor endpoint",
              "body": "The residual $Z_j-(\\Sigma_{ji}/\\Sigma_{ii})Z_i$ is uncorrelated with every local path innovation. It is also independent of old sensor data. By joint Gaussianity its conditional mean given $\\mathcal G_i$ is zero. Therefore\n\\[\\E[Z_j\\mid\\mathcal G_i]=\\frac{\\Sigma_{ji}}{\\Sigma_{ii}}Z_i.\\]\nFor $j=i$ the ratio is 1, and for $j\\ne i$ it is $a/(a+b_i)$."
            }
          ]
        },
        {
          "id": "proof-U-10",
          "title": "Predict the remaining target",
          "body": "After subtracting $\\rho\\mu_P(s)$, the target has conditional mean $aZ_i/(a+b_i)$.",
          "explain": [
            "After removing the common old prediction, sensor i predicts the remaining target by a/(a+b_i) times its current innovation. The weighted pooled estimate has exactly the covariance needed for this simplification."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.10",
          "details": [
            {
              "title": "Separate the old weighted prediction",
              "body": "Linearity of the pooled estimator gives\n\\[X(t)=\\rho\\mu_P(s)+P\\sum_j Z_j/b_j+\\eta(t),\\]\nwhere $\\eta$ is the pooled residual independent of all sensor data. The old prediction $\\rho\\mu_P(s)$ is known in common."
            },
            {
              "title": "Condition the remaining target",
              "body": "Using U.9 and $\\E[\\eta\\mid\\mathcal G_i]=0$,\n\\[\\E\\left[P\\sum_jZ_j/b_j+\\eta\\mid\\mathcal G_i\\right]\n=\\frac{P\\sum_j\\Sigma_{ji}/b_j}{a+b_i}Z_i.\n\\]\nThe numerator is $P(aS+1)=a$. Thus the target correction has conditional mean $aZ_i/(a+b_i)$, exactly the fresh local regression coefficient."
            }
          ]
        },
        {
          "id": "proof-U-11",
          "title": "Reuse the local gain equations",
          "body": "The residual normal equations are the fresh-local equations, so $k_iZ_i$ is optimal.",
          "explain": [
            "The conditional equations for the innovation problem match the unequal-quality fresh-local equations already solved. The same k_i therefore applies to the local innovation. Lemma 1 certifies the resulting hybrid action."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.11",
          "details": [
            {
              "title": "Compute the average correction conditional on agent i",
              "body": "For corrections $k_jZ_j$, step U.9 gives\n\\[\\E\\left[\\frac1n\\sum_jk_jZ_j\\mid\\mathcal G_i\\right]=\\frac{a\\bar k+b_i k_i/n}{a+b_i}Z_i.\\]"
            },
            {
              "title": "Cancel the common prediction in the normal equations",
              "body": "Write $m=\\rho\\mu_P(s)$. Inserting $u_i=m+k_iZ_i$ into Lemma 1 leaves the coefficient equation\n\\[(1+\\kappa)(a+b_i)k_i-\\kappa(a\\bar k+b_i k_i/n)=a.\\]\nThis is exactly $C_i k_i-\\kappa a\\bar k=a$, solved in U.1–U.3. The lemma certifies the full-information optimum. The action uses only the old weighted summary and the two own-sensor readings, so it is also hybrid-feasible."
            }
          ]
        },
        {
          "id": "proof-U-12",
          "title": "Recover the same aging law",
          "body": "Scaling the remaining quadratic cost by $1-\\rho^2$ gives $J_H=\\rho^2J_P+(1-\\rho^2)J_L$.",
          "explain": [
            "The pooled residual variance remains P, while the rest of the quadratic loss scales by 1 − ρ². The optimal hybrid thus has the same interpolation law as before, using the unequal-quality endpoint costs."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.12",
          "details": [
            {
              "title": "Separate the irreducible variance",
              "body": "Subtracting the common prediction leaves a linear function of $Z$ plus the independent residual $\\eta$, whose variance is $P=J_P$. The residual contributes $P$ to the average tracking loss and has no cross terms with the sensor innovations."
            },
            {
              "title": "Scale the remaining quadratic expression",
              "body": "All remaining tracking and disagreement terms are quadratic in $Z$. Since $\\Cov(Z)=(1-\\rho^2)\\Sigma$, their sum is $(1-\\rho^2)$ times the fresh counterpart, which equals $J_L-P$. Hence\n\\[J_H=P+(1-\\rho^2)(J_L-P)=\\rho^2J_P+(1-\\rho^2)J_L.\\]"
            }
          ]
        },
        {
          "id": "proof-U-13",
          "title": "The unequal-quality extension is complete",
          "body": "The unequal-quality policies, posterior variance, and hybrid cost law are established.",
          "explain": [
            "Sensor qualities may differ. One appropriately weighted shared scalar still suffices, and the hybrid value still decays with the common within-component rate. This result does not allow the signal and its disturbances to have different temporal rates."
          ],
          "source": "Proposition 2: Unequal sensor quality · Proof step U.13",
          "details": [
            {
              "title": "Verify the equal-quality limit",
              "body": "If every $b_i=b$, then $C_i=d+\\kappa a$, so $\\theta=1/(d+\\kappa a)$. Substitution gives $k_i=a/d$. Also $P=(a^{-1}+n/b)^{-1}=P_n$ and $\\mu_P=(a/v)\\bar Y$. Thus the unequal-quality expressions reduce to the original formulas."
            },
            {
              "title": "List the established parts",
              "body": "The coupled local gains and their admissibility were proved in U.1–U.4, their cost in U.5, and the full-history pooled result in U.6–U.7. U.8–U.12 established hybrid optimality and its cost law under the same common-rate assumption."
            }
          ]
        }
      ]
    },
    {
      "title": "9. Independent components",
      "lessons": [
        {
          "id": "components-notation",
          "title": "Several quantities on different time scales",
          "body": "$m\\in\\{1,\\ldots,M\\}$ indexes independent components. Agent $i$ chooses $(u_{i1},\\ldots,u_{iM})$.\n\nComponent $m$ has parameters $(a_m,b_m,\\kappa_m,\\lambda_m)$, weight $w_m>0$, and summary age $\\tau_m$.",
          "explain": [
            "For example, a task could combine a fast-changing quantity and a slowly changing independent quantity. The weight says how much each component matters in the overall loss.",
            "Each component has its own common within-component rate. The theorem allows different rates across components, not between a component’s signal and its sensor disturbances."
          ],
          "source": "Section IV-B · Component model"
        },
        {
          "id": "claim-C",
          "title": "Corollary 2: Additive coordination value",
          "body": "There are finitely many independent components $m=1,\\ldots,M$ and positive weights $w_m$. Within component $m$, the signal and all disturbances share $\\lambda_m>0$. Each component has a pooled summary of age $\\tau_m\\ge0$. Then\n\\[\nJ_L^{\\rm tot}-J_H^{\\rm tot}=\\sum_mw_m\\Delta_m e^{-2\\lambda_m\\tau_m},\\qquad\nJ_L^{\\rm tot}=\\sum_mw_mJ_{L,m},\n\\]\nand each component uses the corresponding hybrid policy (15).",
          "explain": [
            "When the task contains independent components, each can use its own optimal policy. Their positive weighted gains add.",
            "Components may have different temporal rates and different ages. Independence is what permits this separation."
          ],
          "source": "Claim · Paper equations (26)",
          "details": [
            {
              "title": "Explain what prevents cross-component improvement",
              "body": "The objective adds component losses, the action constraints do not couple components, and the underlying component processes are independent. Averaging away other-component observations preserves feasibility and cannot increase a convex quadratic component loss."
            },
            {
              "title": "Add the separately attained improvements",
              "body": "Each component can simultaneously use its own optimal hybrid rule. Therefore its weighted improvement $w_m\\Delta_m e^{-2\\lambda_m\\tau_m}$ contributes directly to the total. The following proof justifies the averaging step even for policies that initially depend on observations from multiple components."
            }
          ]
        },
        {
          "id": "proof-C-1",
          "title": "Separate independent components",
          "body": "Other components are independent of component $m$ and its observations.",
          "explain": [
            "Think of several unrelated quantities being tracked at once. Each component has its own entire signal and disturbance processes. Information from other components is independent of both this component's observations and its true signal."
          ],
          "source": "Corollary 2: Additive coordination value · Proof step C.1",
          "details": [
            {
              "title": "Specify what independence includes",
              "body": "A component contains its signal, all of its sensor disturbances, and the observations they generate over time. The model assumes these entire collections are independent across components. Thus observations of component $j\\ne m$ do not change the conditional distribution of component $m$ given its own observations."
            },
            {
              "title": "Identify the possible extra role of other observations",
              "body": "An agent could still use unrelated component observations to randomize its action for $m$. Different agents could even share some of that randomness. The next step proves such randomization cannot improve this convex component objective."
            }
          ]
        },
        {
          "id": "proof-C-2",
          "title": "Average away irrelevant randomness",
          "body": "Averaging a policy over the other components preserves the information restrictions and cannot increase the component loss.",
          "explain": [
            "A joint policy could let one component's decision depend on another component's observations. Average over those unrelated observations. Convexity of the team loss means this averaging cannot increase expected cost. Each agent's averaged action still uses only its permitted information about the component of interest."
          ],
          "source": "Corollary 2: Additive coordination value · Proof step C.2",
          "details": [
            {
              "title": "Average out the unrelated processes",
              "body": "Fix the entire realization of component $m$ and integrate a proposed action vector for $m$ over all the other component processes. Denote the resulting vector by $\\widetilde u_m$. By independence, the distribution being integrated does not depend on the fixed component-$m$ realization."
            },
            {
              "title": "Check that each averaged action is still feasible",
              "body": "The original action of agent $i$ only uses its allowed component-$m$ observations and its allowed other-component observations. Integrating out the latter leaves a function of the former. It does not reveal any new component-$m$ observation. Jensen also gives $\\E[\\widetilde u_{im}^2]\\le\\E[u_{im}^2]$, so square integrability is preserved."
            },
            {
              "title": "Apply convexity to the whole action vector",
              "body": "For fixed $X_m$, the component loss is a sum of squares of affine functions of the action vector, with nonnegative coefficients. It is therefore convex. Jensen’s inequality gives\n\\[\\ell_m(\\widetilde u_m,X_m)\\le\\E_{-m}[\\ell_m(u_m,X_m)],\\]\nwhere $\\E_{-m}$ averages over the other components. Averaging this inequality over component $m$ proves that removing the extraneous randomness cannot increase expected loss."
            }
          ]
        },
        {
          "id": "proof-C-3",
          "title": "Optimize each component separately",
          "body": "Optimization separates across components. Apply Theorem 1 to each.",
          "explain": [
            "The previous step shows that cross-component information cannot improve the optimum. Choosing the optimal hybrid policy for each component achieves all component minima together. Their different temporal rates can therefore be treated separately."
          ],
          "source": "Corollary 2: Additive coordination value · Proof step C.3",
          "details": [
            {
              "title": "Bound each component separately",
              "body": "By C.2, allowing observations from other independent components cannot beat the optimum using only component $m$’s permitted information. Thus every joint policy has component loss at least $J_{H,m}$."
            },
            {
              "title": "Attain all component bounds at once",
              "body": "The total loss is $\\sum_m w_mJ_m$, and there are no cross-component constraints on the actions. Choose each component’s hybrid optimum simultaneously. This attains $\\sum_m w_mJ_{H,m}$. Theorem 1 gives\n\\[J_{H,m}=J_{L,m}-\\Delta_m e^{-2\\lambda_m\\tau_m}.\\]"
            }
          ]
        },
        {
          "id": "proof-C-4",
          "title": "Add the weighted improvements",
          "body": "Q.E.D. Sum with the positive weights $w_m$.",
          "explain": [
            "Multiply each component's improvement by its positive task weight and add. The sum has finitely many terms. This gives the total benefit for components whose shared summaries may have different ages."
          ],
          "source": "Corollary 2: Additive coordination value · Proof step C.4",
          "details": [
            {
              "title": "Subtract the weighted totals",
              "body": "Since the finite sum separates,\n\\[\\begin{aligned}J_L^{\\rm tot}-J_H^{\\rm tot}\n&=\\sum_m w_m(J_{L,m}-J_{H,m})\\\\\n&=\\sum_m w_m\\Delta_m e^{-2\\lambda_m\\tau_m}.\n\\end{aligned}\\]\nPositive weights preserve each lower-bound inequality used in the proof."
            },
            {
              "title": "State where rates may differ",
              "body": "The formula allows different $\\lambda_m$ across components and different summary ages $\\tau_m$. Within each component, the signal and its sensor disturbances still share a single rate. This is what justified the componentwise use of Theorem 1."
            }
          ]
        },
        {
          "id": "effective-decay",
          "title": "A mixture of rates changes its effective decay",
          "body": "At a common age $\\tau$,\\[V(\\tau)=\\sum_m w_m\\Delta_m e^{-2\\lambda_m\\tau}.\\]\\[-\\frac{V^{\\prime}(\\tau)}{V(\\tau)}=\\frac{\\sum_m2\\lambda_m w_m\\Delta_m e^{-2\\lambda_m\\tau}}{\\sum_m w_m\\Delta_m e^{-2\\lambda_m\\tau}}.\\]",
          "explain": [
            "The effective rate is an average of the component rates, weighted by the benefit each component still has at that age.",
            "As information gets older, the fast-decaying components lose weight more quickly. Slow components therefore account for a growing share of the remaining benefit."
          ],
          "source": "Derived claim · Equation (27)",
          "details": [
            {
              "title": "Differentiate the sum of benefits",
              "body": "Write $\\gamma_m=2\\lambda_m$ and $b_m(\\tau)=w_m\\Delta_m e^{-\\gamma_m\\tau}$. Then $V=\\sum_m b_m$ and $V'=-\\sum_m\\gamma_m b_m$. Since $V>0$,\n\\[-V'/V=\\sum_m p_m\\gamma_m,\\qquad p_m=b_m/V.\\]\nThe weights are positive and sum to one, making the effective rate a weighted average."
            },
            {
              "title": "Show why slower components gain relative weight",
              "body": "For a faster component $f$ and a slower component $s$, with $\\gamma_f>\\gamma_s$,\n\\[\\frac{b_f(\\tau)}{b_s(\\tau)}=\\frac{w_f\\Delta_f}{w_s\\Delta_s}e^{-(\\gamma_f-\\gamma_s)\\tau}.\\]\nThis ratio decreases with age. Thus the slower component’s share relative to the faster one increases."
            }
          ]
        }
      ]
    },
    {
      "title": "10. Refresh notation & cost",
      "lessons": [
        {
          "id": "refresh-service",
          "title": "What one communication update contains",
          "body": "A refresh sends the pooled vector\\[(\\bar Y_1(s),\\ldots,\\bar Y_M(s)).\\] All components are sampled at time $s$ and arrive after a fixed latency $\\delta\\ge0$.",
          "explain": [
            "The update contains one pooled mean per component, sampled at the same time. Its age is already δ when it arrives.",
            "Agents keep using their fresh local observations while waiting. The service can support the selected transmission times without queueing, and agents retain the local samples matching each update’s timestamp."
          ],
          "source": "Section V · Communication model"
        },
        {
          "id": "price-and-period",
          "title": "Price c, latency δ, and refresh interval T",
          "body": "$c>0$ is the price of one complete pooled-vector update. $\\delta$ is its fixed communication latency. $T>0$ is the interval between consecutive periodic updates.",
          "explain": [
            "The price is measured in units of accumulated team loss, so it can be added to the loss integrated over time.",
            "Latency and interval are different. Latency is how long a message takes to arrive. The interval is how often a new update is sent. The model allows messages in transit concurrently."
          ],
          "source": "Section V · Communication model"
        },
        {
          "id": "schedule-class",
          "title": "Which schedules are included?",
          "body": "Schedules may be deterministic or randomized, provided they are independent of all signal and sensor-disturbance processes.\n\nThey must be locally finite: every bounded time interval contains only finitely many transmissions.",
          "explain": [
            "The theorem covers irregular schedules as well as periodic ones. A schedule can be selected independently of the sensor values.",
            "A rule such as “send when the current reading changes a lot” is observation-dependent and is outside this theorem. Conditioning on that kind of schedule would also reveal information about the signal."
          ],
          "source": "Section V · Scope of Theorem 2"
        },
        {
          "id": "amplitudes",
          "title": "Benefit remaining when an update arrives",
          "body": "\\[\\gamma_m=2\\lambda_m.\\]\\[A_m=w_m\\Delta_m e^{-\\gamma_m\\delta}.\\]\\[V_\\delta(r)=\\sum_m A_m e^{-\\gamma_m r}.\\]",
          "explain": [
            "Gamma is the coordination-value decay rate for a component. A_m is that component’s weighted benefit at reception, after the delivery delay.",
            "Here r is time elapsed since reception. The total age of the underlying shared data is δ + r."
          ],
          "source": "Section V · Equation (28) and proof notation",
          "details": [
            {
              "title": "Separate delivery delay from time since arrival",
              "body": "At elapsed time $r$ after reception, the shared data have age $\\delta+r$. The component benefit is $w_m\\Delta_m e^{-\\gamma_m(\\delta+r)}$. The exponential identity $e^{x+y}=e^xe^y$ separates this into $[w_m\\Delta_m e^{-\\gamma_m\\delta}]e^{-\\gamma_mr}$."
            },
            {
              "title": "Identify the reception amplitude",
              "body": "The bracket is $A_m$, the benefit immediately after reception. Summing over components gives $V_\\delta(r)=\\sum_m A_m e^{-\\gamma_mr}$. This separates the benefit already lost in transit from the decay that continues after arrival."
            }
          ]
        },
        {
          "id": "integrated-benefit",
          "title": "Integrate the benefit over one interval",
          "body": "\\[B(T)=\\int_0^T V_\\delta(r)\\,dr=\\sum_m\\frac{A_m}{\\gamma_m}(1-e^{-\\gamma_mT}).\\]",
          "explain": [
            "An update helps throughout the interval until the next one arrives. Integrating its instantaneous improvement gives the total benefit accumulated in that interval.",
            "Because the benefit decays exponentially, even an infinitely long interval yields only a finite total benefit."
          ],
          "source": "Section V · Equation (28)",
          "details": [
            {
              "title": "Integrate one exponential term",
              "body": "An antiderivative of $A_m e^{-\\gamma_m r}$ is $-(A_m/\\gamma_m)e^{-\\gamma_m r}$. Evaluating between 0 and $T$ gives\n\\[\\int_0^T A_m e^{-\\gamma_m r}\\,dr=\\frac{A_m}{\\gamma_m}(1-e^{-\\gamma_mT}).\\]"
            },
            {
              "title": "Sum the accumulated benefits",
              "body": "Linearity of the integral gives $B(T)$ by summing the component formulas. The result measures accumulated loss saved, rather than the instantaneous loss reduction. Its units therefore match the per-update communication price $c$."
            }
          ]
        },
        {
          "id": "periodic-cost",
          "title": "Average cost of periodic refreshing",
          "body": "\\[C(T)=J_L^{\\rm tot}+\\frac{c-B(T)}{T}.\\]\\[J_L^{\\rm tot}=\\sum_m w_mJ_{L,m}.\\]",
          "explain": [
            "Start with the average loss of local operation. Every interval pays c and saves B(T). Divide their difference by the interval length to get the average adjustment.",
            "A negative adjustment means communication improves total average cost. A positive adjustment means the price exceeds the interval’s decision benefit."
          ],
          "source": "Section V · Equation (29)",
          "details": [
            {
              "title": "Account for one complete reception interval",
              "body": "Local operation would accumulate loss $TJ_L^{\\rm tot}$. Using the received summary saves $B(T)$ over that interval. Assign one update price $c$. Total interval cost is therefore $TJ_L^{\\rm tot}-B(T)+c$."
            },
            {
              "title": "Convert accumulated cost to average cost",
              "body": "Divide by interval length $T$ to get\n\\[C(T)=J_L^{\\rm tot}+\\frac{c-B(T)}T.\\]\nEvery complete periodic interval has this same expected cost. Finite initial and final boundary intervals do not change the long-run average."
            }
          ]
        },
        {
          "id": "critical-price",
          "title": "The lifetime benefit sets the critical price",
          "body": "\\[c_{\\rm crit}=\\sum_m\\frac{A_m}{\\gamma_m}=\\int_0^\\infty V_\\delta(r)\\,dr.\\]",
          "explain": [
            "This is the maximum total benefit a received update could provide over its remaining lifetime.",
            "If its price reaches or exceeds that amount, refreshing cannot improve the long-run objective. If the price is smaller, an appropriate refresh interval yields a net improvement."
          ],
          "source": "Theorem 2 · Equation (30)",
          "details": [
            {
              "title": "Compute the benefit of one update over its remaining lifetime",
              "body": "Let $T\\to\\infty$ in the integral formula. Since $e^{-\\gamma_mT}\\to0$,\n\\[B(\\infty)=\\sum_m A_m/\\gamma_m=c_{\\rm crit}.\\]"
            },
            {
              "title": "Check both sides of the price threshold",
              "body": "If $c\\ge c_{\\rm crit}$, no finite interval can recover its price in decision benefit. If $c<c_{\\rm crit}$, continuity and convergence of $B(T)$ imply $B(T)>c$ for some sufficiently long finite $T$. That period has $(c-B(T))/T<0$ and beats the local baseline. Theorem 2 strengthens this comparison to all permitted schedules."
            }
          ]
        },
        {
          "id": "optimization-symbols",
          "title": "The optimization notation in the proof",
          "body": "$T^*$ is an optimal positive period. $H(T)=B(T)-TB^{\\prime}(T)$. A prime denotes a derivative.\n\n$\\inf$ is an infimum, or greatest lower bound. $\\limsup$ is a limiting upper value. $R$ is the observation horizon and $T_j$ is the length of its $j$th complete reception interval.",
          "explain": [
            "H is the auxiliary function that determines whether changing the refresh interval helps. It is unrelated to the information field written as calligraphic H_i.",
            "The general-schedule proof uses longer and longer horizons R. Its auxiliary number g is the best periodic excess cost per unit time, also allowing the zero excess cost of never updating."
          ],
          "source": "Theorem 2 · Proof notation"
        }
      ]
    },
    {
      "title": "11. The optimal refresh theorem",
      "lessons": [
        {
          "id": "claim-R",
          "title": "Theorem 2: Optimal refresh period",
          "body": "Assume fixed finite latency $\\delta\\ge0$, an exact joint pooled-vector refresh with price $c>0$, and locally finite schedules independent of all signal and disturbance processes. Let $\\gamma_m=2\\lambda_m$, $A_m=w_m\\Delta_m e^{-\\gamma_m\\delta}>0$,\n\\[\nB(T)=\\sum_m\\frac{A_m}{\\gamma_m}(1-e^{-\\gamma_mT}),\\qquad\nc_{\\rm crit}=\\sum_mA_m/\\gamma_m.\n\\]\nFor $c\\ge c_{\\rm crit}$, no refreshing minimizes the limiting upper average cost at $J_L^{\\rm tot}$. For $0<c<c_{\\rm crit}$, a periodic schedule is optimal among all admissible schedules. Its unique period solves $B(T^*)-T^*B'(T^*)=c$, and its cost is $J_L^{\\rm tot}-\\sum_m A_m e^{-\\gamma_mT^*}$.",
          "explain": [
            "An update’s lifetime benefit sets the critical communication price. At or above that price, no refreshing is optimal.",
            "Below it, one positive periodic interval minimizes average cost. A periodic schedule with that interval is optimal even among all irregular or randomized schedules independent of the sensor processes."
          ],
          "source": "Claim · Paper equations (28)--(33)",
          "details": [
            {
              "title": "Interpret the two thresholds in the theorem",
              "body": "The price threshold $c_{\\rm crit}$ is the total benefit an update could provide over its remaining lifetime. Below that price, the optimal period balances $c$ against $H(T)=B(T)-TB'(T)$. These compare accumulated loss with a communication price, so their units agree."
            },
            {
              "title": "Identify why the theorem covers irregular schedules",
              "body": "Every complete interval satisfies $c-B(T)\\ge gT$, where $g$ is the best periodic excess rate including no refreshing. Adding this inequality over arbitrary intervals gives a common long-run lower bound. A periodic schedule or no communication attains that bound. The following proof handles the leftover interval and independently randomized schedules explicitly."
            }
          ]
        },
        {
          "id": "proof-R-1",
          "title": "Benefit remaining after reception",
          "body": "Define $V_\\delta(T)=B^{\\prime}(T)=\\sum_m A_m e^{-\\gamma_mT}$.",
          "explain": [
            "V_δ(T) is the instantaneous benefit of the most recent pooled update T time units after it arrived. Communication latency has already reduced each component's amplitude to A_m. Integrating this remaining benefit gives B(T)."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.1",
          "details": [
            {
              "title": "Interpret the elapsed time after reception",
              "body": "An update is already $\\delta$ old on arrival. After another $T$ units of time, its component-$m$ benefit is\n\\[w_m\\Delta_m e^{-\\gamma_m(\\delta+T)}=A_m e^{-\\gamma_mT}.\\]\nSum these terms to get the instantaneous total benefit $V_\\delta(T)$."
            },
            {
              "title": "Differentiate the accumulated benefit",
              "body": "For each component,\n\\[\\frac{d}{dT}\\left[\\frac{A_m}{\\gamma_m}(1-e^{-\\gamma_mT})\\right]=A_m e^{-\\gamma_mT}.\\]\nThere are finitely many terms, so differentiation commutes with summation and $B'(T)=\\sum_m A_m e^{-\\gamma_mT}=V_\\delta(T)$."
            }
          ]
        },
        {
          "id": "proof-R-2",
          "title": "Differentiate the average cost",
          "body": "Differentiate (29): $C^{\\prime}(T)=[H(T)-c]/T^2$, where $H(T)=B(T)-TV_\\delta(T)$.",
          "explain": [
            "A periodic cycle pays one price and accumulates benefit B(T) over T time units. Differentiating that average gives a numerator H(T) − c. Since T² is positive, the sign of that numerator determines whether lengthening the interval helps."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.2",
          "details": [
            {
              "title": "Apply the quotient rule carefully",
              "body": "The constant baseline $J_L^{\\rm tot}$ has derivative zero. For the other term,\n\\[\\frac{d}{dT}\\frac{c-B(T)}{T}=\\frac{-B'(T)T-[c-B(T)]}{T^2}.\\]\nThe minus sign in front of the bracket comes from differentiating the denominator."
            },
            {
              "title": "Collect the numerator into H",
              "body": "The numerator is $B(T)-TB'(T)-c$. Set $H(T)=B(T)-TV_\\delta(T)$ and use $B'=V_\\delta$. Then\n\\[C'(T)=\\frac{H(T)-c}{T^2}.\\]\nSince $T^2>0$, the sign of $C'$ is exactly the sign of $H-c$."
            }
          ]
        },
        {
          "id": "proof-R-3",
          "title": "Show that the crossing is unique",
          "body": "$H^{\\prime}(T)=-TV_\\delta^{\\prime}(T)>0$ for $T>0$, and $H$ increases from zero to $c_{\\rm crit}$.",
          "explain": [
            "All amplitudes and rates are positive, so the remaining value decreases with time. This makes H strictly increasing for T > 0. It starts at zero and approaches the critical price, which is the total lifetime benefit of one update."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.3",
          "details": [
            {
              "title": "Differentiate using the product rule",
              "body": "From $H=B-TV_\\delta$,\n\\[H'=B'-V_\\delta-TV_\\delta'=-TV_\\delta',\\]\nbecause $B'=V_\\delta$. Also\n\\[V_\\delta'(T)=-\\sum_m\\gamma_m A_m e^{-\\gamma_mT}.\\]\nThus $H'(T)=T\\sum_m\\gamma_m A_m e^{-\\gamma_mT}>0$ for every $T>0$. Every factor in every summand is positive."
            },
            {
              "title": "Evaluate the endpoint values explicitly",
              "body": "Substituting $B$ and $V_\\delta$ gives\n\\[H(T)=\\sum_m\\frac{A_m}{\\gamma_m}\\left[1-(1+\\gamma_mT)e^{-\\gamma_mT}\\right].\\]\nAt $T=0$ every bracket is zero. As $T\\to\\infty$, both $e^{-\\gamma_mT}$ and $T e^{-\\gamma_mT}$ tend to zero. Hence $H(T)\\to\\sum_m A_m/\\gamma_m=c_{\\rm crit}$."
            },
            {
              "title": "Explain why strict monotonicity matters",
              "body": "A continuous, strictly increasing function rising from 0 to $c_{\\rm crit}$ crosses each price strictly between them exactly once. This will give a unique candidate period and determine the cost’s slope on either side."
            }
          ]
        },
        {
          "id": "proof-R-4",
          "title": "Consider a price below the threshold",
          "body": "ASSUME $0<c<c_{\\rm crit}$. PROVE a unique minimizing positive period and its displayed value.",
          "explain": [
            "We first handle a positive communication price smaller than the update's lifetime benefit. Under this assumption, we will show that there is exactly one best positive periodic interval and calculate its cost."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.4",
          "details": [
            {
              "title": "Locate the price in the range of H",
              "body": "Assume $0<c<c_{\\rm crit}$. Step R.3 shows the increasing function $H$ starts below $c$ and eventually exceeds it. We can therefore find a finite positive time at which $H=c$."
            },
            {
              "title": "Separate periodic optimality from general scheduling",
              "body": "The next steps establish that this time minimizes $C(T)$ over positive constant periods. A further interval-accounting argument is still needed to show that irregular or independently randomized schedules cannot do better."
            }
          ]
        },
        {
          "id": "proof-R-4-1",
          "title": "Locate the best interval",
          "body": "There is a unique root $H(T^*)=c$, and $C$ decreases before it and increases after it.",
          "explain": [
            "A continuous, strictly increasing H crosses the price c exactly once. Before that crossing, increasing the interval reduces average cost. After it, increasing the interval raises average cost. The crossing therefore identifies the minimizing period."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.4.1",
          "details": [
            {
              "title": "Establish existence and uniqueness of the root",
              "body": "Continuity gives a solution $T^*>0$ to $H(T^*)=c$ by the intermediate value theorem. Strict increase makes that solution unique."
            },
            {
              "title": "Read the direction of improvement from the derivative",
              "body": "For $T<T^*$, $H(T)<c$, so $C'(T)<0$. For $T>T^*$, $H(T)>c$, so $C'(T)>0$. The periodic cost decreases up to $T^*$ and increases afterward. Thus this root is a minimum, rather than a maximum or a flat stationary point."
            }
          ]
        },
        {
          "id": "proof-R-4-2",
          "title": "Check the extreme intervals",
          "body": "$C(T)\\to\\infty$ as $T\\downarrow0$ and $C(T)\\to J_L^{\\rm tot}$ as $T\\to\\infty$, proving the unique global periodic minimum.",
          "explain": [
            "Sending updates arbitrarily often makes the positive cost per update dominate. Sending them arbitrarily rarely makes the average cost approach local operation. Together with the derivative sign change, these limits establish the global periodic minimum."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.4.2",
          "details": [
            {
              "title": "Examine very frequent communication",
              "body": "Since $B(0)=0$ and $B'(0)=\\sum_m A_m$, differentiability gives $B(T)=T\\sum_m A_m+o(T)$. Therefore\n\\[C(T)=J_L^{\\rm tot}+\\frac cT-\\sum_m A_m+o(1)\\to\\infty\\quad(T\\downarrow0),\\]\nbecause $c>0$. Paying a fixed positive price arbitrarily frequently is costly."
            },
            {
              "title": "Examine arbitrarily rare communication",
              "body": "The numerator $c-B(T)$ remains bounded because $0\\le B(T)\\le c_{\\rm crit}$. Dividing by $T\\to\\infty$ makes the adjustment vanish. Hence $C(T)\\to J_L^{\\rm tot}$. Combined with the strict slope signs, these limits confirm the unique global minimum over positive periods."
            }
          ]
        },
        {
          "id": "proof-R-4-3",
          "title": "Simplify the cost at the optimum",
          "body": "At $H(T^*)=c$,\\[c-B(T^*)=-T^*V_\\delta(T^*).\\] Hence\\[C(T^*)=J_L^{\\rm tot}-\\sum_m A_m e^{-\\gamma_m T^*}.\\]",
          "explain": [
            "At T*, the equation H(T*) = c lets us replace price minus accumulated benefit by minus T* times the remaining instantaneous benefit. Dividing by T* gives the theorem's compact optimal-cost formula."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.4.3",
          "details": [
            {
              "title": "Rearrange the root equation",
              "body": "At $T^*$,\n\\[c=H(T^*)=B(T^*)-T^*V_\\delta(T^*).\\]\nSubtracting $B(T^*)$ yields $c-B(T^*)=-T^*V_\\delta(T^*)$."
            },
            {
              "title": "Insert into the periodic cost",
              "body": "Then\n\\[C(T^*)=J_L^{\\rm tot}+\\frac{-T^*V_\\delta(T^*)}{T^*}=J_L^{\\rm tot}-\\sum_m A_m e^{-\\gamma_mT^*}.\\]\nThe subtracted sum is strictly positive. Thus this periodic schedule strictly improves on no refreshing when the price is below threshold."
            }
          ]
        },
        {
          "id": "proof-R-4-4",
          "title": "Close the low-price periodic argument",
          "body": "Q.E.D. The below-threshold periodic claims hold.",
          "explain": [
            "We have proved existence and uniqueness of the optimal periodic interval and evaluated its cost. The remaining question is whether an irregular schedule could do even better."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.4.4",
          "details": [
            {
              "title": "Collect the periodic conclusions",
              "body": "There is one finite positive root, its derivative signs establish the unique minimizing period, and substitution gives its attained cost. The optimum is strictly below the local baseline. All of these conclusions use $0<c<c_{\\rm crit}$."
            },
            {
              "title": "Identify the remaining competitor class",
              "body": "We have optimized over periodic schedules so far. The proof now handles high prices and then bounds every allowed irregular or randomized schedule, completing the larger optimization claim."
            }
          ]
        },
        {
          "id": "proof-R-5",
          "title": "Handle prices at or above the threshold",
          "body": "If $c\\ge c_{\\rm crit}$, then $c-B(T)\\ge0$ for each finite $T$, so no periodic schedule improves on no refreshing.",
          "explain": [
            "Over any finite interval, an update provides less than its full lifetime benefit. If its price is at least that lifetime benefit, no finite periodic interval improves on no communication. Equality of price and threshold belongs to this regime too."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.5",
          "details": [
            {
              "title": "Bound the benefit in a finite interval",
              "body": "Each $1-e^{-\\gamma_mT}<1$ for finite $T>0$, so\n\\[B(T)<\\sum_m A_m/\\gamma_m=c_{\\rm crit}.\\]\nIf $c\\ge c_{\\rm crit}$, then $c-B(T)>0$ for every finite positive interval."
            },
            {
              "title": "Compare with no communication",
              "body": "Therefore $C(T)=J_L^{\\rm tot}+[c-B(T)]/T>J_L^{\\rm tot}$ for every finite period. Never refreshing attains $J_L^{\\rm tot}$ directly. At the threshold as well as above it, a finite period cannot improve the baseline. The general-schedule argument below shows that irregular timing cannot improve it either."
            }
          ]
        },
        {
          "id": "proof-R-6",
          "title": "Compare against every allowed schedule",
          "body": "Every locally finite independent schedule has average cost at least the minimum of the periodic costs and the no-refresh cost. The stated candidates attain this bound.",
          "explain": [
            "Period optimization alone does not rule out an irregular or randomized schedule. The next steps establish a lower bound that applies to every schedule independent of the sensor processes and then show that a periodic or no-refresh schedule attains it."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6",
          "details": [
            {
              "title": "Express an arbitrary schedule as intervals",
              "body": "A received update resets every component’s age to $\\delta$. Between two receptions the benefit therefore follows the same curve $V_\\delta(r)$, regardless of when that interval occurs. An interval of length $T$ saves $B(T)$ and is assigned one communication price $c$."
            },
            {
              "title": "Bound each interval by a common rate",
              "body": "Let $g$ be the smallest periodic excess cost per unit time, also allowing 0 for no updates. By definition $c-B(T)\\ge gT$ for every $T>0$. Apply this inequality to every complete reception interval in a finite horizon. The only unfinished interval has bounded total possible benefit."
            },
            {
              "title": "Let the boundary effect disappear",
              "body": "Summing the interval inequalities gives a lower bound equal to horizon length times $J_L^{\\rm tot}+g$, minus a fixed constant. Dividing by the horizon makes that constant vanish. The following substeps justify conditioning, boundary accounting, and attainment individually."
            }
          ]
        },
        {
          "id": "proof-R-6-1",
          "title": "Fix a schedule and define the best rate",
          "body": "Define $g=\\min\\{0,\\inf_{T>0}(c-B(T))/T\\}$ and condition on a realization of the reception schedule.",
          "explain": [
            "Condition on one realized reception schedule. Because the schedule is independent of the sensors, their statistical law stays unchanged. The number g is the best achievable periodic excess cost per unit time, also allowing zero excess cost from never refreshing. It is nonpositive."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.1",
          "details": [
            {
              "title": "Define the best candidate excess rate",
              "body": "Set\n\\[g=\\min\\left\\{0,\\inf_{T>0}\\frac{c-B(T)}T\\right\\}.\\]\nThe value 0 includes no refreshing. The infimum includes all constant positive periods. In particular $g\\le0$. Also $B(T)\\le V_\\delta(0)T$, so every quotient is at least $-V_\\delta(0)$ and $g$ is finite."
            },
            {
              "title": "Condition on a fixed schedule realization",
              "body": "A randomized schedule can first be viewed as a deterministic sequence of reception times after conditioning on its realization. Because the schedule is independent of all signal and disturbance processes, conditioning does not change their distributions. The previously derived expected benefit $V_\\delta(r)$ therefore still applies in each interval."
            },
            {
              "title": "Explain the independence restriction",
              "body": "If transmission times were chosen from sensor values, learning the schedule could itself reveal information about the signal. Conditional decision losses could then change. The present interval bound uses the stated observation-independent schedule class."
            }
          ]
        },
        {
          "id": "proof-R-6-2",
          "title": "Bound each complete interval",
          "body": "Every complete interval of length $T_j$ contributes at least $gT_j$ relative to local operation when assigned one communication price.",
          "explain": [
            "Take any interval between two receptions. Its price minus benefit is c − B(T_j). By the definition of g, this is at least g times the interval length. This bound holds separately for every interval, however irregular their lengths are."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.2",
          "details": [
            {
              "title": "Apply the definition of the infimum",
              "body": "For any complete interval with positive length $T_j$,\n\\[g\\le\\frac{c-B(T_j)}{T_j}.\\]\nMultiplying by $T_j>0$ gives $gT_j\\le c-B(T_j)$."
            },
            {
              "title": "Interpret the right-hand side as interval cost",
              "body": "Relative to local operation, the update provides integrated decision benefit $B(T_j)$ until the next reception and costs $c$. Its net contribution is therefore $c-B(T_j)$, at least $gT_j$. Summing this bound permits intervals of different lengths. If receptions coincide, a zero-length interval provides no benefit and has cost $c\\ge0=g\\cdot0$."
            }
          ]
        },
        {
          "id": "proof-R-6-3",
          "title": "Control the first and last pieces",
          "body": "The last incomplete interval contributes at least $-c_{\\rm crit}$, and the initial interval before the first reception has zero gain.",
          "explain": [
            "Before the first reception there is no pooling benefit. The final unfinished interval can provide at most one update's lifetime benefit, c_crit. Thus the uncompleted pieces contribute a bounded correction that will vanish after division by a long horizon."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.3",
          "details": [
            {
              "title": "Bound the unfinished final interval",
              "body": "Suppose the last received update has been used for $L$ units of time when the horizon ends. Its accumulated benefit is $B(L)\\le c_{\\rm crit}$. Even if we discard its nonnegative communication charge when forming a lower bound, its net contribution is at least $-c_{\\rm crit}$."
            },
            {
              "title": "Account for the initial interval",
              "body": "Before the first reception, the agents operate locally, so the decision benefit relative to the local baseline is zero. With the no-initial-pool convention used in this accounting, there is no initial benefit to subtract. Local finiteness guarantees that only finitely many intervals need to be summed on any finite horizon."
            }
          ]
        },
        {
          "id": "proof-R-6-4",
          "title": "Add the interval bounds",
          "body": "Because $g\\le0$, the expected total cost through time $R$, conditional on the schedule, is at least $R(J_L^{\\rm tot}+g)-c_{\\rm crit}$.",
          "explain": [
            "The complete intervals occupy at most the observation horizon R. Because g is nonpositive, replacing their combined length by R makes the lower bound smaller and therefore still valid. Add the baseline local cost and the bounded final-interval correction."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.4",
          "details": [
            {
              "title": "Sum complete and unfinished intervals",
              "body": "Let $S$ be the total length of the complete reception intervals within horizon $R$. The conditional expected excess cost is at least\n\\[gS-c_{\\rm crit}.\\]\nThe initial local interval contributes zero and the final interval contributes the stated bounded remainder."
            },
            {
              "title": "Use the sign of g in the correct direction",
              "body": "We have $S\\le R$ and $g\\le0$. Multiplication by a nonpositive number gives $gS\\ge gR$. Thus excess cost is at least $gR-c_{\\rm crit}$. Adding the baseline over the whole horizon gives\n\\[\\E[\\text{total cost through }R\\mid\\text{schedule}]\\ge R(J_L^{\\rm tot}+g)-c_{\\rm crit}.\\]"
            }
          ]
        },
        {
          "id": "proof-R-6-5",
          "title": "Count messages still in transit",
          "body": "Charging transmissions at generation preserves the bound since sent messages are at least as numerous as received messages.",
          "explain": [
            "Charging for an update when it is sent can only increase cost relative to charging when it arrives. Some messages may still be in transit at the horizon. Their nonnegative charges preserve the lower bound."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.5",
          "details": [
            {
              "title": "Compare the two charging conventions",
              "body": "Every message received by time $R$ must have been generated by time $R$, because latency $\\delta\\ge0$. Thus the number sent by $R$ is at least the number received by $R$."
            },
            {
              "title": "Preserve a lower bound when adding charges",
              "body": "The interval proof assigned prices only to received updates, and even dropped a final price. Charging at generation can add charges for messages still in flight. Since $c>0$, those extra charges cannot decrease cost. Therefore the same lower bound remains valid under the paper’s actual transmission-time charging convention."
            }
          ]
        },
        {
          "id": "proof-R-6-6",
          "title": "Average over random schedules",
          "body": "The bound is uniform over schedules. Take expectation over the schedule, divide by $R$, and then take the limiting upper average to obtain the independent-randomized-schedule bound.",
          "explain": [
            "The bound holds for each realized independent schedule with the same bounded correction. We may therefore average it over schedules, divide by the horizon, and take the limiting upper average. No interchange of expectation and a limiting upper average is needed."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.6",
          "details": [
            {
              "title": "Average over the schedule randomness",
              "body": "The bound $R(J_L^{\\rm tot}+g)-c_{\\rm crit}$ does not depend on which schedule realization occurred. Taking expectation over schedules preserves it:\n\\[\\E[\\text{total cost through }R]\\ge R(J_L^{\\rm tot}+g)-c_{\\rm crit}.\\]"
            },
            {
              "title": "Divide before taking the long-run limit",
              "body": "For $R>0$,\n\\[\\frac1R\\E[\\text{total cost through }R]\\ge J_L^{\\rm tot}+g-\\frac{c_{\\rm crit}}R.\\]\nThe final term tends to zero. Hence the limiting upper average cost is at least $J_L^{\\rm tot}+g$. No exchange of expectation and a limiting upper value is needed: the expectation was taken at each finite horizon first."
            }
          ]
        },
        {
          "id": "proof-R-6-7",
          "title": "Attain the lower bound",
          "body": "Periodic operation at $T^*$ below the threshold, or no communication otherwise, attains the bound.",
          "explain": [
            "Below the threshold, repeating the optimal interval reaches the bound. At or above the threshold, never communicating reaches it. The finite initial delivery delay has a vanishing contribution to the long-run average."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.7",
          "details": [
            {
              "title": "Attain the bound below threshold",
              "body": "When $c<c_{\\rm crit}$, the periodic minimizer has negative excess rate $[c-B(T^*)]/T^*$, so this rate equals $g$. Periodic operation repeats the same interval indefinitely. Its finite initial delay and final partial interval vanish in the long-run average, leaving exactly $C(T^*)=J_L^{\\rm tot}+g$."
            },
            {
              "title": "Attain the bound at and above threshold",
              "body": "If $c\\ge c_{\\rm crit}$, every periodic excess rate is nonnegative, so $g=0$. Sending no updates gives the local cost $J_L^{\\rm tot}$ exactly. Thus a feasible policy attains the lower bound in each price regime."
            }
          ]
        },
        {
          "id": "proof-R-6-8",
          "title": "Close the general-schedule argument",
          "body": "Q.E.D. The all-schedules optimum is attained by the stated candidates.",
          "explain": [
            "Every allowed schedule has cost at least the derived bound, and an allowed schedule achieves it. This proves optimality over the full independent-schedule class, including randomized and irregular schedules."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.6.8",
          "details": [
            {
              "title": "Combine a universal lower bound with an attaining policy",
              "body": "Steps R.6.1–R.6.6 show every admissible independent schedule has long-run cost at least $J_L^{\\rm tot}+g$. Step R.6.7 exhibits an admissible schedule achieving that value. Therefore it is the minimum over the whole allowed schedule class."
            },
            {
              "title": "Distinguish the unique period from uniqueness of every schedule",
              "body": "Below threshold the best constant period $T^*$ is unique. The theorem does not assert that every optimal infinite schedule must be identical at every time: changing finitely many updates can leave a long-run average unchanged. The claimed existence of an optimal periodic schedule is the conclusion proved here."
            }
          ]
        },
        {
          "id": "proof-R-7",
          "title": "The refresh theorem is complete",
          "body": "Q.E.D. Both price regimes and every stated policy class are covered.",
          "explain": [
            "Both price regimes are covered. The optimum below the threshold has a unique periodic interval, although changing finitely many updates can leave the long-run cost unchanged. Transmission times chosen from observed sensor values are outside the theorem."
          ],
          "source": "Theorem 2: Optimal refresh period · Proof step R.7",
          "details": [
            {
              "title": "Check both price regimes",
              "body": "For $0<c<c_{\\rm crit}$, the root of $H(T)=c$ gives an optimal periodic schedule and its attained cost. For $c\\ge c_{\\rm crit}$, no communication is optimal. Since the assumptions require $c>0$, these two cases cover all allowed prices."
            },
            {
              "title": "Check the schedule class",
              "body": "The interval argument covers every locally finite deterministic schedule and every independently randomized schedule. Fixed latency makes each reception reset age to the same $\\delta$. These are the assumptions needed to pass from a one-period calculation to the all-schedules result."
            }
          ]
        },
        {
          "id": "scalar-refresh",
          "title": "The single-component period equation",
          "body": "\\[x=2\\lambda T^*,\\qquad\\chi=\\frac{c}{c_{\\rm crit}}.\\]\\[1-(1+x)e^{-x}=\\chi,\\qquad0<\\chi<1.\\]",
          "explain": [
            "The best interval can be found by solving one increasing scalar equation. The variables x and χ express time and price in dimensionless form.",
            "As the price approaches its critical value from below, the best interval grows without bound. Updates become increasingly rare."
          ],
          "source": "Derived claim · Equation (34)",
          "details": [
            {
              "title": "Substitute the one-component expressions",
              "body": "With one component, $c_{\\rm crit}=A/\\gamma$, $B(T)=(A/\\gamma)(1-e^{-\\gamma T})$, and $TB'(T)=TAe^{-\\gamma T}$. The root condition becomes\n\\[\\frac A\\gamma[1-(1+\\gamma T)e^{-\\gamma T}]=c.\\]"
            },
            {
              "title": "Make time and price dimensionless",
              "body": "Divide by $c_{\\rm crit}=A/\\gamma$ and set $x=\\gamma T=2\\lambda T$, $\\chi=c/c_{\\rm crit}$. This yields $1-(1+x)e^{-x}=\\chi$. Its derivative in $x$ is $xe^{-x}>0$ for $x>0$, so every $0<\\chi<1$ has one positive root."
            }
          ]
        },
        {
          "id": "latency-cutoff",
          "title": "A cutoff in communication latency",
          "body": "For one component of unit weight,\\[\\delta_{\\rm stop}=\\max\\left\\{0,\\frac1{2\\lambda}\\log\\frac{\\Delta}{2\\lambda c}\\right\\}.\\] No refreshing is optimal when $\\delta\\ge\\delta_{\\rm stop}$.",
          "explain": [
            "Longer delivery latency consumes more of an update’s useful lifetime before it can be used. This formula turns the price condition into a latency condition.",
            "The maximum with zero handles prices so high that even instantaneous communication is not worthwhile."
          ],
          "source": "Derived claim · Equation (35)",
          "details": [
            {
              "title": "Write the price threshold as an inequality in latency",
              "body": "For one unit-weight component, no refreshing is optimal precisely when\n\\[c\\ge\\frac{\\Delta e^{-2\\lambda\\delta}}{2\\lambda}.\\]\nMultiply by $2\\lambda/\\Delta>0$ to get $e^{-2\\lambda\\delta}\\le2\\lambda c/\\Delta$."
            },
            {
              "title": "Handle whether the right side is at least one",
              "body": "If $2\\lambda c/\\Delta\\ge1$, the inequality holds for every $\\delta\\ge0$. Otherwise take logarithms and divide by $-2\\lambda$, reversing the inequality, to get\n\\[\\delta\\ge\\frac1{2\\lambda}\\log\\frac{\\Delta}{2\\lambda c}.\\]\nCombining these two cases gives the maximum-with-zero formula."
            }
          ]
        },
        {
          "id": "minimum-interval",
          "title": "If the service limits the update rate",
          "body": "When $0<c<c_{\\rm crit}$ and intervals must satisfy $T\\ge T_{\\min}>0$, the optimal feasible period is\\[\\max\\{T_{\\min},T^*\\}.\\]",
          "explain": [
            "If the unconstrained best interval is already allowed, use it. If it is too short for the service, use the shortest permitted interval.",
            "The no-refresh price threshold stays the same. Below it, sufficiently long feasible intervals can still provide a net improvement."
          ],
          "source": "Section V · Minimum-interval consequence",
          "details": [
            {
              "title": "Use the shape of the periodic cost",
              "body": "Below threshold, $C(T)$ decreases up to $T^*$ and increases afterward. If $T_{\\min}\\le T^*$, the unconstrained minimum remains feasible. If $T_{\\min}>T^*$, the whole feasible interval lies on the increasing branch, whose minimum is its left endpoint $T_{\\min}$."
            },
            {
              "title": "Check the no-refresh alternative",
              "body": "For $T\\ge T^*$, $C(T)$ increases toward $J_L^{\\rm tot}$ from below, so any finite constrained minimizer on this branch still improves on no refreshing. This gives $\\max\\{T_{\\min},T^*\\}$ when $c<c_{\\rm crit}$. At or above threshold, the original no-refresh conclusion remains valid."
            }
          ]
        }
      ]
    },
    {
      "title": "12. Discrete time & model limits",
      "lessons": [
        {
          "id": "discrete-model",
          "title": "The discrete-time counterpart",
          "body": "For stationary Gaussian AR(1) processes with a common coefficient $q\\in(0,1)$,\\[X_{t+1}=qX_t+\\xi_t.\\] At integer age $k\\ge0$, replace $\\rho$ by $q^k$.",
          "explain": [
            "An AR(1) process is the discrete-time analogue used here: next time’s value is a fraction of the current value plus a new independent Gaussian innovation.",
            "The sensor disturbances must share the same coefficient within the component. Their innovation variances are chosen to keep the stated stationary variances."
          ],
          "source": "Section III-B · Discrete-time extension",
          "details": [
            {
              "title": "Choose the stationary innovation variance",
              "body": "In $X_{t+1}=qX_t+\\xi_t$, independence of the innovation gives $\\Var(X_{t+1})=q^2a+\\Var(\\xi_t)$. To keep stationary variance $a$, choose $\\Var(\\xi_t)=a(1-q^2)$. Each disturbance uses the corresponding $b_i(1-q^2)$."
            },
            {
              "title": "Iterate the recursion across k slots",
              "body": "Repeated substitution gives $X_{t+k}=q^kX_t+\\sum_{j=0}^{k-1}q^j\\xi_{t+k-1-j}$. The sum is independent of the past and has variance\n\\[a(1-q^2)\\sum_{j=0}^{k-1}q^{2j}=a(1-q^{2k}).\\]\nThus the same prediction and innovation decomposition holds with $\\rho=q^k$."
            }
          ]
        },
        {
          "id": "discrete-proof",
          "title": "Why the endpoint and hybrid laws carry over",
          "body": "For integer $s<r\\le t$,\\[\\Cov(Z_j(t),Z_i(r))=\\Sigma_{ji}q^{t-r}(1-q^{2(r-s)}).\\]\\[J_H(k)=q^{2k}J_P+(1-q^{2k})J_L.\\]",
          "explain": [
            "The same covariance proportionality holds at every intermediate integer time. The projection and team-equation argument therefore goes through with q^k replacing the continuous exponential.",
            "The coordination gain is Δq^(2k). The symbol k here denotes an integer age; in the hybrid proof, k = a/d denoted a policy gain. These uses occur in different contexts."
          ],
          "source": "Section III-B · Discrete-time proof consequence",
          "details": [
            {
              "title": "Repeat the four-term covariance expansion",
              "body": "Let $\\alpha=q^{r-s}$ and $\\beta=q^{t-r}$, so $\\rho=\\alpha\\beta$. Subtracting the predicted old readings gives\n\\[\\Cov(Z_j(t),Z_i(r))=\\Sigma_{ji}[\\beta-\\alpha\\rho-\\rho\\alpha+\\rho\\alpha]=\\Sigma_{ji}\\beta(1-\\alpha^2).\\]\nThis is $\\Sigma_{ji}q^{t-r}(1-q^{2(r-s)})$."
            },
            {
              "title": "Follow the same projection and cost argument",
              "body": "The temporal factor cancels in covariance ratios at every integer observation time. The Gaussian projection and conditional normal-equation checks therefore remain valid. The innovation covariance scales by $1-q^{2k}$, giving $J_H(k)=q^{2k}J_P+(1-q^{2k})J_L$."
            }
          ]
        },
        {
          "id": "discrete-refresh",
          "title": "Refresh sums replace refresh integrals",
          "body": "For a discrete reception interval of $N$ slots, the accumulated benefit is\\[\\sum_m A_m\\frac{1-q_m^{2N}}{1-q_m^2}.\\]",
          "explain": [
            "In discrete time, add the benefits slot by slot. This geometric sum replaces the continuous-time integral B(T).",
            "The paper transfers the endpoint and pooling laws to discrete time. Its continuous positive-period equation is not asserted unchanged for integer refresh periods."
          ],
          "source": "Section III-B · Scope of the discrete-time extension",
          "details": [
            {
              "title": "Sum benefits over the slots in an interval",
              "body": "At elapsed slots $r=0,\\ldots,N-1$, one component contributes $A_m(q_m^2)^r$. Let $x=q_m^2$. The finite sum $S=1+x+\\cdots+x^{N-1}$ satisfies $(1-x)S=1-x^N$."
            },
            {
              "title": "Divide and add components",
              "body": "Since $0<x<1$, $S=(1-x^N)/(1-x)$. Multiplication by $A_m$ and summation over components gives the displayed accumulated benefit. For these reception-slot conventions, the periodic excess cost is price minus this sum, divided by $N$. Optimization is over positive integers, so the continuous derivative equation is not applied verbatim."
            }
          ]
        },
        {
          "id": "white-noise",
          "title": "Why white measurement noise changes the problem",
          "body": "With temporally independent measurement noise and a signal with one-step correlation $q>0$,\\[\\Cov\\left(X_t-\\frac{a}{a+b}Y_{i,t},Y_{i,t-1}\\right)=\\frac{abq}{a+b}>0.\\]",
          "explain": [
            "The error after using only the current reading is still correlated with an older reading. That older reading contains useful information, so the one-reading reduction fails in this model.",
            "A Gaussian recursive estimator generally needs to carry forward information from past readings. This explains why the paper specifies temporally correlated errors with the common rate."
          ],
          "source": "Section II-A · Model qualification",
          "details": [
            {
              "title": "Calculate the covariances with yesterday’s reading",
              "body": "In this alternative discrete model the sensor errors are independent across time. Therefore $\\Cov(X_t,Y_{i,t-1})=aq$ and $\\Cov(Y_{i,t},Y_{i,t-1})=aq$. The second expression has no temporally correlated error term."
            },
            {
              "title": "Evaluate the residual covariance",
              "body": "The endpoint-only estimation residual has covariance\n\\[aq-\\frac a{a+b}aq=\\frac{abq}{a+b}>0\\]\nwith yesterday’s reading. It is therefore not independent of the observed past. Additional history can improve the estimate, so the common-rate endpoint sufficiency proof does not carry over to this alternative model."
            }
          ]
        },
        {
          "id": "scope",
          "title": "What the results assume",
          "body": "A common Gaussian signal, independent sensor disturbances, and a common temporal rate within each component.\n\nQuadratic tracking and disagreement loss. Actions do not affect observations.\n\nExact real-valued summaries. Independent components in the multirate extension. Observation-independent schedules in the refresh theorem.",
          "explain": [
            "These assumptions make the exact formulas possible. Unequal sensor quality is covered. Different signal and disturbance rates within one component require further analysis.",
            "The scalar result is about sufficient information for this model. It does not optimize finite-bit encodings or observation-triggered communication protocols."
          ],
          "source": "Conclusion · Scope of the letter"
        }
      ]
    },
    {
      "title": "13. Numerical examples",
      "lessons": [
        {
          "id": "numerical-endpoints",
          "title": "The eight-sensor example",
          "body": "$n=8$, $a=b=1$, $\\kappa=1$, and $\\lambda=1$.\\[P_1=0.5,\\qquad J_P=\\frac19.\\]\\[J_L=\\frac{15}{23}\\simeq0.6522,\\qquad\\Delta=\\frac{112}{207}\\simeq0.5411.\\]",
          "explain": [
            "These numbers give the fresh endpoints used in the plots. Fresh pooling substantially lowers loss in this example.",
            "The crossover occurs at age about 0.4691. At age one, the delayed-only cost is about 0.8797. Fresh local loss is about 25.9% lower than that delayed-only loss."
          ],
          "source": "Section VI · First example",
          "details": [
            {
              "title": "Substitute the eight-sensor parameters",
              "body": "With $n=8$, $a=b=\\kappa=1$, $v=1+1/8=9/8$ and $d=1+1+(1-1/8)=23/8$. Therefore $P_1=1/2$, $J_P=1-8/9=1/9$, and $J_L=1-8/23=15/23$."
            },
            {
              "title": "Compute the benefit and crossover",
              "body": "Subtract to get $\\Delta=15/23-1/9=(135-23)/207=112/207$. With $\\lambda=1$, the crossover is $\\tfrac12\\log[(23/8)/(9/8)]=\\tfrac12\\log(23/9)\\simeq0.4691$."
            },
            {
              "title": "Check the percentage improvement at age one",
              "body": "The delayed-only loss is $J_D(1)=1-(8/9)e^{-2}\\simeq0.8797$. The percentage reduction from using local operation is $(J_D(1)-J_L)/J_D(1)\\simeq0.2586$, or about 25.9%. The denominator is the delayed-only loss being improved upon."
            }
          ]
        },
        {
          "id": "numerical-decay",
          "title": "Read the crossover and decay figure",
          "body": "\\[\\lambda\\tau_{\\rm cross}\\simeq0.4691.\\]\\[J_H(0.5)\\simeq0.4531.\\] At age $0.5$, the remaining fraction of fresh-sharing value is $e^{-1}\\simeq36.8\\%$.",
          "explain": [
            "The top panel compares optimized team losses. The delayed-only curve crosses above the fresh-local benchmark. The hybrid curve remains below the local benchmark.",
            "The lower panel divides the hybrid improvement by Δ. Different parameter settings follow the same exponential fraction. The markers are Monte Carlo estimates."
          ],
          "source": "Section VI · Figure 1",
          "image": "pooling_decay.svg",
          "alt": "Top panel: delayed-only loss crosses the local benchmark while hybrid loss stays below it. Bottom panel: normalized hybrid benefit follows an exponential curve.",
          "details": [
            {
              "title": "Evaluate the hybrid curve at age one half",
              "body": "At $\\lambda=1$ and $\\tau=0.5$, $e^{-2\\lambda\\tau}=e^{-1}$. Thus\n\\[J_H(0.5)=\\frac{15}{23}-\\frac{112}{207}e^{-1}\\simeq0.4531.\\]"
            },
            {
              "title": "Interpret the normalized lower panel",
              "body": "Dividing $J_L-J_H(\\tau)=\\Delta e^{-2\\lambda\\tau}$ by $\\Delta$ leaves $e^{-2\\lambda\\tau}$. At age one half this is about 0.3679. The curve reports the fraction of fresh-sharing benefit remaining, rather than a percentage reduction in the total loss."
            }
          ]
        },
        {
          "id": "numerical-refresh",
          "title": "Read the periodic-refresh figure",
          "body": "For $\\delta=0.1$,\\[c_{\\rm crit}\\simeq0.2215.\\] At half this price,\\[T^*\\simeq0.8392,\\qquad C(T^*)\\simeq0.5695.\\]",
          "explain": [
            "Each curve is total average cost for the hybrid architecture at a different price. The dashed line is local operation with no updates.",
            "Prices below the threshold give a finite minimizing interval. The curve above the threshold never beats the no-refresh benchmark."
          ],
          "source": "Section VI · Figure 2",
          "image": "refresh_cost.svg",
          "alt": "Average hybrid loss plus communication price versus refresh interval, with finite minima below the critical price and a no-refresh reference line.",
          "details": [
            {
              "title": "Compute the reception amplitude and critical price",
              "body": "For the same example, $\\gamma=2$ and $\\delta=0.1$. Hence $A=(112/207)e^{-0.2}$ and $c_{\\rm crit}=A/2\\simeq0.2215$."
            },
            {
              "title": "Solve the normalized period equation",
              "body": "At half the critical price, solve $1-(1+x)e^{-x}=0.5$. Its positive root is approximately $x=1.67835$. Since $x=2T^*$, $T^*\\simeq0.83917$."
            },
            {
              "title": "Evaluate the attained cost",
              "body": "The optimal-cost identity gives $C(T^*)=15/23-Ae^{-2T^*}\\simeq0.5695$. This value already includes the communication price through the optimizing-period equation."
            }
          ]
        },
        {
          "id": "numerical-multirate",
          "title": "A slower component can dominate the refresh decision",
          "body": "Add an independent component with $(a_2,b_2,\\lambda_2)=(0.4,0.8,0.12)$, $\\kappa_2=1$, and unit weights.\n\nAt latency $0.1$,\\[c_{\\rm crit}\\simeq1.1807.\\] At half that price,\\[T^*\\simeq5.5513,\\qquad C(T^*)\\simeq0.9072.\\]",
          "explain": [
            "The slow component supplies 34.2% of the benefit at reception but 81.2% of its lifetime integral. Its benefit lasts longer.",
            "This is why the refresh decision depends on both the amount of information value and how long it persists."
          ],
          "source": "Section VI · Two-component example",
          "details": [
            {
              "title": "Calculate the second component’s endpoints",
              "body": "With $n=8$, $a_2=0.4$, $b_2=0.8$, and $\\kappa_2=1$, $v_2=0.5$ and $d_2=1.9$. Thus $J_{P,2}=0.4-0.16/0.5=0.08$, $J_{L,2}=0.4-0.16/1.9$, and $\\Delta_2=J_{L,2}-0.08\\simeq0.23579$."
            },
            {
              "title": "Account for latency and lifetime",
              "body": "The rates are $\\gamma_1=2$ and $\\gamma_2=0.24$. At $\\delta=0.1$, $A_1=\\Delta_1e^{-0.2}$ and $A_2=\\Delta_2e^{-0.024}$. The critical price is $A_1/2+A_2/0.24\\simeq1.1807$. The slow component’s reception share is $A_2/(A_1+A_2)\\simeq34.2\\%$, while its lifetime share is $(A_2/0.24)/c_{\\rm crit}\\simeq81.2\\%$."
            },
            {
              "title": "Evaluate the joint period and cost",
              "body": "At $c=c_{\\rm crit}/2$, solve\n\\[\\sum_{m=1}^2\\frac{A_m}{\\gamma_m}[1-(1+\\gamma_mT)e^{-\\gamma_mT}]=c.\\]\nThe root is $T^*\\simeq5.5513$. Substituting into $J_{L,1}+J_{L,2}-A_1e^{-2T^*}-A_2e^{-0.24T^*}$ gives about $0.9072$."
            }
          ]
        },
        {
          "id": "numerical-checks",
          "title": "What the numerical checks establish",
          "body": "The manuscript solves 83 Gaussian-team systems from observation covariances. The maximum cost discrepancy is below 2.7 × 10⁻¹⁵.\n\nEach simulation marker uses 120,000 independent stationary Gaussian sample pairs.",
          "explain": [
            "The linear-system checks independently compare optimized finite-dimensional policies with the formulas. They are a useful check on algebra and implementation.",
            "The proofs establish the claims about full observation histories and all permitted schedules. Numerical examples alone would not establish those universal statements."
          ],
          "source": "Section VI · Reproducibility"
        }
      ]
    },
    {
      "title": "14. Review the main ideas",
      "lessons": [
        {
          "id": "review",
          "title": "Three results to keep in view",
          "body": "\\[\\tau>\\frac{\\log(d/v)}{2\\lambda}\\quad\\Longrightarrow\\quad J_L<J_D(\\tau).\\]\\[J_L-J_H(\\tau)=\\Delta e^{-2\\lambda\\tau}.\\]\\[c_{\\rm crit}=\\sum_m\\frac{w_m\\Delta_m e^{-2\\lambda_m\\delta}}{2\\lambda_m}.\\]",
          "explain": [
            "Fresh local decisions can beat complete delayed information used alone. Keeping fresh local information alongside an old shared summary gives an exactly quantified improvement.",
            "Integrating that improvement determines whether communication is worth its price and, below the threshold, how often to refresh."
          ],
          "source": "Review · Corollary 1, Theorem 1, and Theorem 2"
        },
        {
          "id": "finish",
          "title": "You have reached the end of the guide",
          "body": "The Contents menu lets you return directly to a definition, theorem, or proof step.\n\nThe six-page manuscript and the full Lamport proof report are available from the same menu.",
          "explain": [
            "The main mathematical work is now connected: conditional team optimality gives the policies, Gaussian covariance gives the history reductions, and interval accounting gives the scheduling theorem.",
            "The guide follows the current manuscript and its verified proof structure. The linked report records the exact mathematical assumptions and proof dependencies."
          ],
          "source": "End of guided reading"
        }
      ]
    }
  ],
  "manuscript": {
    "title": "Too Late to Coordinate: When Local Information Beats Global Sharing",
    "repository": "ANRGUSC/TINA",
    "manuscript_commit": "61f68b2b4c9340df44d3ee5bbc56d8fad9e5b6c3",
    "manuscript_path": "papers/lcss/main.tex",
    "submission_pdf_path": "submissions/lcss/lcss-paper.pdf",
    "manuscript_sha256": "732fdedb69495793363cfdb8290fd324b338ca5f14e2ca047e217df7766da395",
    "submission_pdf_sha256": "25ea28c85bde2f2ddcf691d31769e253f4a581300833f96baaf8aed56e38f5dc",
    "report_path": "proof-reports/lcss-letter/TINA_Paper1_Lamport_Report.pdf",
    "report_sha256": "0db52b7c607f445e740511ebfe9375eb438c91558cddb4a4c697ab90731bb2a9",
    "proof_snapshot_tex_sha256": "ca4063836ef506a56fbee54ab850a67499d70fc5a1de8f5c4f8077a1794f8db5",
    "relationship_to_proof_snapshot": "The manuscript adds three 7-point vertical-spacing adjustments. Text, formulas, claims, and proofs are unchanged.",
    "publication_status": "L-CSS submission manuscript; not yet accepted for publication"
  }
};
