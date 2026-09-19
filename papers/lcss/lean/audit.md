# C5 paper-to-Lean correspondence review

**Verdict: the review is complete; unconditional C5 closure is not established.** Theorem 1's stated conclusions correspond to the formal result. Theorem 2's constants, candidates, physical objective, endpoint treatment, model existence and optimization conclusions correspond for the formal admissible class. One **High** issue prevents equating that class with every reasonable reading of the paper: the placement of the second-moment quantifiers for randomized policies. Two **Medium** model clarifications should also be recorded.

This is a single-assistant, adversarial review within the same AI workflow that produced the proof. The paper-first requirement extraction and Lean-definition pass are separate reasoning passes, **not separate reviewers**. There is no independent human sign-off, external reviewer, Comparator run or independently implemented kernel. This report is suitable as a review packet for one; it does not satisfy an external-independence requirement by itself.

The core mathematical statements and supplementary correspondence checks are in `proof-project/` and `review/`. Source/type locks detect drift; they do not certify the English statement.

## 1. Scope and frozen inputs

The target is **Too Late to Coordinate: When Local Information Beats Global Sharing**, Theorem 1 (`thm:hybrid`) and Theorem 2 (`thm:refresh`). The reviewed source is `proof-project/reference/lcss-main.tex`, from [ANRGUSC/TINA at the frozen commit](https://github.com/ANRGUSC/TINA/blob/96909b3b63d2ad6921fa499e55cb3a01365e5fdf/papers/lcss/main.tex). The snapshot identifies the paper reviewed; subsequent paper edits require renewed correspondence review.

- Paper SHA-256: `732fdedb69495793363cfdb8290fd324b338ca5f14e2ca047e217df7766da395`.
- Lean: `leanprover/lean4:v4.33.1`; Mathlib: `0df444a360eaa60ab8c11dca51a86af692955474`.

The unequal-sensor-quality proposition, discrete-time remarks, simulations and every other statement of the Letter are not certified by this review. Centered Gaussian covariance-process semantics are reviewed; no SDE equivalence or separate exported stationarity-in-law theorem is claimed.

## 2. Findings and dispositions

| ID | Priority | Finding | Disposition / acceptance criterion |
| --- | --- | --- | --- |
| C5-H1 | High | Randomized admissibility has different possible moment quantifiers. | Open. Either prove a cost-preserving bridge for the broader jointly measurable, unconditional L² class, or obtain an explicit author decision adopting conditional L² admissibility. These are different repairs. |
| C5-M1 | Medium | The paper does not specify the joint measurability needed by its time-integrated objective. | A sufficient Lean adapter is now proved. Record the intended measurable-control convention in the paper. The adapter retains conditional L² and does not resolve H1. |
| C5-M2 | Medium | Empty pooled startup and nonnegative send times are implicit in the proof, not explicit in the model paragraph. | Add an author-approved startup sentence, or prove an extension to another specified initialization. Local prehistory must remain available. |
| C5-P1 | Review gate | Independent statement acceptance. | Pending. This same-workflow AI report is not independent human approval. A short sign-off worksheet is supplied below. |

The distinction in H1 concerns coverage, not a discovered counterexample to the optimal refresh value. The formal theorems remain valid as stated. Raw-history, reception-endpoint and constructed-model results hold at their formal interfaces. “All non-strict competitors” means **all inhabitants of the formal inclusive strategy structure**, until H1 is resolved.

## 3. Paper-first specification and clause map

The paper specifies mutually independent centered stationary Gaussian signal/error processes, exponential covariance with a common rate within each component, current local histories, timestamped pooled means, a quadratic tracking/disagreement loss and information-admissible second-moment-finite actions. The refresh problem uses independent finite-component models, fixed latency, no queue constraint, positive per-vector charges and locally finite sensor-independent schedules. Its objective takes a limiting upper average **after** expectation of the time-integrated physical loss and transmission charges.

The table is the review ledger. Source line numbers refer to the pinned paper snapshot and proof files. `correspondence.json` retains the same entries in structured form. Verification generates exact elaborated theorem types and proof dependencies in `proof-project/evidence/lean-dependencies.json` and `proof-project/proof-dag.json`.

| ID | Paper source lines | Requirement / disposition | Lean clauses and interpretation |
| --- | --- | --- | --- |
| M01 | 54–72 | n≥2, a,b,λ>0, κ≥0. **pass** | `LCSS.Parameters` — `proof-project/LCSS/Parameters.lean`:14. Exact numerical domain; rate is λ, not 2λ. |
| M02 | 54–62 | Independent centered Gaussian primitives with exponential covariance. **pass at covariance process contract** | `LCSS.PaperModel` — `proof-project/LCSS/PaperModel.lean`:17; `LCSS.full_model_witness` — `proof-project/LCSS/ModelWitness.lean`:15. Whole-process independence, Gaussian finite laws, means and covariance; a full real-time continuous witness exists. A separate stationarity-in-law corollary is not exported. |
| M03 | 252–261 | Independent components with possibly different rates. **pass** | `LCSS.PaperComponents` — `proof-project/LCSS/Components.lean`:56. Component source families are independent. Sensors within a component are correlated through their shared signal, as required. |
| I01 | 75–94 | Entire real-time histories, fresh local data and past pooled data. **pass** | `LCSS.historySigma` — `proof-project/LCSS/Gaussian.lean`:21; `LCSS.SensorModel.localInfo` — `proof-project/LCSS/Endpoints.lean`:13; `LCSS.SensorModel.hybridInfo` — `proof-project/LCSS/History.lean`:65; `LCSS.SensorModel.fullInfo` — `proof-project/LCSS/History.lean`:63. Arbitrary real past indices, not a finite grid or only the latest observation. |
| I02 | 75–94 | Pooled data are literal arithmetic means. **pass** | `LCSS.theorem1_arithmetic` — `proof-project/LCSS/ArithmeticHistory.lean`:122; `LCSS.RawRealization.message` — `proof-project/LCSS/RawProcess.lean`:53; `LCSS.RawRealization.receivedInfo_informationSpace` — `proof-project/LCSS/RawProcess.lean`:145. Arithmetic history and raw-to-L² adapters are proved; raw means are pointwise finite sums. |
| I03 | 72–94 | Information measurability modulo null events. **pass with explicit convention** | `LCSS.informationSpace` — `proof-project/LCSS/History.lean`:12; `LCSS.aeHistory` — `proof-project/LCSS/RawHistory.lean`:15; `LCSS.informationSpace_aeHistory` — `proof-project/LCSS/RawHistory.lean`:120; `LCSS.RawRealization.receivedInfo_informationSpace` — `proof-project/LCSS/RawProcess.lean`:145. Ambient-null augmentation has the same admissible L² classes. No simultaneous full-measure event for an uncountable family is assumed. |
| T101 | 176–181 | Hybrid formula. **pass** | `LCSS.Theorem1Claims` — `proof-project/LCSS/Theorem1.lean`:65; `LCSS.theorem1_arithmetic` — `proof-project/LCSS/ArithmeticHistory.lean`:122. policy_formula is the exact affine innovation formula. The literal-message wrapper supplies arithmetic pool semantics. |
| T102 | 72–182 | Optimal among all measurable L² actions, including nonlinear ones. **pass** | `LCSS.optimalExpectedLoss` — `proof-project/LCSS/Theorem1.lean`:17; `LCSS.expectedLoss_eq_optimalExpectedLoss` — `proof-project/LCSS/Theorem1.lean`:21; `LCSS.Theorem1Claims` — `proof-project/LCSS/Theorem1.lean`:65. The domain is all information-measurable L² policies. Nonempty domain and boundedness for the real infimum are proved. |
| T103 | 182–185 | Actual posterior conditional variance. **pass** | `LCSS.Theorem1Claims` — `proof-project/LCSS/Theorem1.lean`:65; `LCSS.SensorModel.posterior_arithmetic_condVar` — `proof-project/LCSS/ArithmeticHistory.lean`:89. Conditional variance is Mathlib condVar and the claimed constant equality holds almost surely, as appropriate. |
| T104 | 182–189 | Cost interpolation, same full-sharing value, exponential gain. **pass** | `LCSS.Theorem1Claims` — `proof-project/LCSS/Theorem1.lean`:65; `LCSS.theorem1` — `proof-project/LCSS/Theorem1.lean`:101. All three are conclusions; not fields assumed by the model. |
| T105 | 193–193 | Age zero is included. **pass** | `LCSS.theorem1` — `proof-project/LCSS/Theorem1.lean`:101. Root assumes 0≤τ; no hidden strict-positive-age restriction. |
| T201 | 272–272 | Fixed latency; no service queue or minimum separation. **pass** | `LCSS.PhysicalSchedule` — `proof-project/LCSS/PhysicalSchedule.lean`:14; `LCSS.PhysicalSchedule.receivedBy` — `proof-project/LCSS/ReceptionEndpoints.lean`:14. Non-strict reception at send+δ. No T≥δ requirement is inserted. |
| T202 | 272–272 | Finite, empty and infinite locally finite schedules. **pass for nonnegative startup** | `LCSS.PhysicalSchedule` — `proof-project/LCSS/PhysicalSchedule.lean`:14; `LCSS.PhysicalSchedule.count_spec` — `proof-project/LCSS/PhysicalSchedule.lean`:38. Active indices form an initial segment; monotone sends can repeat. Each active transmission is charged. No explosion on bounded positive horizons. |
| T203 | 272–311 | Schedule randomness independent of signals and disturbances. **pass with product seed convention** | `LCSS.InclusiveRawStrategy` — `proof-project/LCSS/InclusiveObjective.lean`:14; `LCSS.InclusiveRawStrategy.timeAverage` — `proof-project/LCSS/InclusiveObjective.lean`:51. Schedule depends only on seed ξ; objective uses ν.prod μ. Actions may use the whole independent seed, a harmless enlargement for the lower bound. |
| T204 | 72–272 | Finite second moment for randomized policies. **conditional mismatch high** | `LCSS.InclusiveRawPolicy` — `proof-project/LCSS/InclusivePolicy.lean`:28; `LCSS.InclusiveRawStrategy` — `proof-project/LCSS/InclusiveObjective.lean`:14. Lean requires ∀ξ ∀t MemLp(u ξ t)2 μ. Unconditional fixed-time L² over ν.prod μ does not imply this. See C5-H1. |
| T205 | 72–283 | Measurable time-integrated objective. **clarification medium** | `LCSS.InclusiveRawStrategy` — `proof-project/LCSS/InclusiveObjective.lean`:14; `LCSS.InclusiveRawStrategy.timeAverage` — `proof-project/LCSS/InclusiveObjective.lean`:51. Loss measurability is explicit. C5Review.ofJoint derives the analytic fields from joint action measurability; conditional L² remains an input. |
| T206 | 272–307 | Startup and no initially supplied pooled information. **clarification medium** | `LCSS.PhysicalSchedule` — `proof-project/LCSS/PhysicalSchedule.lean`:14; `LCSS.RawRealization.receivedInfo` — `proof-project/LCSS/RawProcess.lean`:126. Sends start at time 0. Local prehistory still exists. The proof text supports empty pooled startup but the model paragraph should say so. |
| T207 | 252–252 | Same physical agents across all components. **pass by specialization** | `LCSS.AgentCoordinates` — `proof-project/LCSS/ScheduledPolicy.lean`:77. Use common n and the identity agent correspondence. C5Review.commonAgents constructs this specialization. |
| T208 | 272–272 | Competitors may use a message at its reception instant. **pass** | `LCSS.PhysicalSchedule.receivedBy` — `proof-project/LCSS/ReceptionEndpoints.lean`:14; `LCSS.InclusiveRawPolicy` — `proof-project/LCSS/InclusivePolicy.lean`:28; `LCSS.InclusiveRawPolicy.toStrict_integrated_loss` — `proof-project/LCSS/InclusivePolicy.lean`:82. All inclusive competitors in the formal class are covered; endpoint erasure preserves every horizon loss. |
| T209 | 65–72 | Tracking plus disagreement with correct normalization. **pass** | `LCSS.pointwiseLoss` — `proof-project/LCSS/Objective.lean`:14; `LCSS.RawRealization.realizedLoss` — `proof-project/LCSS/RawPolicy.lean`:93. Actual raw loss is used; positive weights and κ≥0 make ofReal conversion faithful. |
| T210 | 283–311 | limsup of expected integrated loss and generation-time charges. **pass** | `LCSS.InclusiveRawStrategy.timeAverage` — `proof-project/LCSS/InclusiveObjective.lean`:51; `LCSS.InclusiveRawStrategy.timeUpperCost` — `proof-project/LCSS/InclusiveObjective.lean`:56. Expectation is before the limsup; raw time integral is inside expectation. Sends still in flight are charged; infinite costs are allowed. |
| T211 | 274–288 | A, γ, B and critical price. **pass** | `LCSS.RefreshMixture.ofParameters` — `proof-project/LCSS/RefreshBridge.lean`:37; `LCSS.RefreshMixture.benefit` — `proof-project/LCSS/RefreshCalculus.lean`:26; `LCSS.RefreshMixture.threshold` — `proof-project/LCSS/RefreshCalculus.lean`:27. γ=2λ, A=wΔexp(-γδ), threshold=ΣA/γ, no missing weight or latency factor. |
| T212 | 290–294 | Unique positive period-equation root. **pass** | `LCSS.RefreshMixture.exists_unique_period` — `proof-project/LCSS/RefreshCalculus.lean`:132; `LCSS.RefreshMixture.marginal_formula` — `proof-project/LCSS/RefreshCalculus.lean`:96. Positive and finite parameters give strict monotonicity and the critical limit. This does not assert uniqueness of every optimal randomized schedule. |
| T213 | 290–298 | No-refresh and periodic costs are physically attained. **pass** | `LCSS.InclusiveRawStrategy.noRefresh_cost` — `proof-project/LCSS/InclusiveAttainment.lean`:24; `LCSS.InclusiveRawStrategy.periodic_cost` — `proof-project/LCSS/InclusiveAttainment.lean`:30; `LCSS.theorem2_inclusive_physical_attainment` — `proof-project/LCSS/InclusiveAttainment.lean`:51. Candidates are single raw action paths for all horizons. Equality concerns the physical time-integrated objective. |
| T214 | 307–311 | Global bound over general schedules and controls. **pass for formal class only** | `LCSS.InclusiveRawStrategy.expected_horizon_lower_bound` — `proof-project/LCSS/InclusiveObjective.lean`:80; `LCSS.theorem2_inclusive_lower_bounds` — `proof-project/LCSS/InclusiveAttainment.lean`:39. C2 removes reception endpoints and compares every formal competitor. C5-H1 prevents unconditional identification with a broader paper class. |
| V01 | 54–62 | Full model existence, not just finitely many Gaussian marginals. **pass** | `LCSS.full_model_witness` — `proof-project/LCSS/ModelWitness.lean`:15; `LCSS.theorem1_ou` — `proof-project/LCSS/ModelWitness.lean`:31; `LCSS.theorem2_ou_physical_attainment` — `proof-project/LCSS/ModelWitness.lean`:35. C3 constructs all real times jointly and independent primitives; instantiated roots require no supplied model or regularity witness. |

## 4. Theorem 1: field-by-field acceptance

Open `proof-project/LCSS/Theorem1.lean`, declaration `Theorem1Claims` (line 65), and `ArithmeticHistory.lean`, `theorem1_arithmetic` (line 122).

1. `policy_formula`: the coefficient of the pool is ρa/v, and the innovation coefficient is a/d. Here the innovation is the current local observation minus ρ times that agent's observation at the sampling time. `theorem1_arithmetic` supplies the literal arithmetic-message interpretation.
2. `feasible_hybrid`: each action belongs to its own information-measurable L² space; this does not assume the optimizer is feasible without proof.
3. `feasible_full`: the same action remains feasible when all delayed sensor histories are shared.
4. `attains_hybrid`: actual expected quadratic loss equals the infimum over the entire admissible L² policy set. That set includes nonlinear policies.
5. `attains_full`: the same action also attains the larger-information problem's infimum. The proof does not restrict the comparison to a proposed linear family.
6. `posterior_variance`: the actual conditional-variance random variable equals ρ²Pₙ+(1−ρ²)P₁ almost surely. This is not a scalar definition named “variance.”
7. `team_cost`: the optimized hybrid cost is ρ²J_P+(1−ρ²)J_L.
8. `full_sharing_same_value`: delayed full histories offer no lower value than the hybrid history.
9. `exponential_value`: the reduction relative to fresh-local operation is Δexp(−2λτ).

The root allows every real t and τ≥0. The genuine real infimum is supported by a nonempty feasible set and a proved lower bound; it is not relying on a default value for an ill-defined infimum. The distinction between strict measurability and ambient-null versions is handled at the admissible-L²-space level. Literal raw optimal formulas provide feasible physical representatives. No cost advantage is obtained by permitting changes on null events.

## 5. C5-H1: the randomized-policy quantifier issue

The paper's model paragraph at line 72 admits measurable policies with finite second moment. Its refresh paragraph at line 272 later permits independent randomized schedules. It does not explicitly say whether the second moment is taken before or after fixing the schedule's independent random seed.

The Lean clauses are unambiguous:

```lean
-- InclusiveObjective.lean, InclusiveRawStrategy
schedule : Ξ → PhysicalSchedule
policy : (ξ : Ξ) → InclusiveRawPolicy B a (schedule ξ) δ

-- InclusivePolicy.lean, InclusiveRawPolicy
memLp : ∀ t m i, MemLp (action t m i) (2 : ℝ≥0∞) μ
```

Together these require **for every seed ξ and every time t**, the action has a finite second moment over the physical process law μ. One natural alternative reading is **for every fixed time t**, a finite second moment under the joint law ν×μ. Fubini yields almost-everywhere sectional assertions with the appropriate quantifiers; it does not justify exchanging “for each t, almost every ξ” with “for every ξ, every t.”

These are not simply nested classes: a conditional second moment can be finite for each seed but grow too rapidly with the seed to have a finite joint expectation. The formal class allows such infinite expected costs. Conversely, unconditional fixed-time L² does not imply the Lean field. The following example isolates this latter failure while respecting the physical information restriction.

### Separating example

Take one component, δ=0 and an independent seed ξ uniform on (0,1). Send exactly one pooled message at time ξ. This is a locally finite sensor-independent schedule. Put q=a+b and let the standard local action be uᵢᴸ(t)=(a/d)Yᵢ(t). Define

\[
u_i(t,\xi,\omega)=u_i^L(t,\omega)
 +\mathbf1_{\{t=\xi\}}\exp\!\left(\frac{Y_i(t,\omega)^2}{2q}\right).
\]

The policy uses only its current own observation and whether the first message has arrived at that instant. Thus the spike is available at reception under the inclusive convention. With the continuous raw realization, this is jointly measurable: the diagonal {t=ξ} is Borel and the raw observation is jointly measurable.

For every fixed t, the seed event {ξ=t} has probability zero. Consequently the action equals uᵢᴸ(t) almost surely under ν×μ, so it has a finite unconditional second moment. But for every fixed seed ξ, at t=ξ the Gaussian variable Yᵢ(ξ) has law N(0,q). Its added term has second moment

\[
\mathbb E\exp(Y_i(\xi)^2/q)
 =\frac1{\sqrt{2\pi q}}\int_{\mathbb R}
       \exp(y^2/(2q))\,dy=\infty.
\]

Adding the L² local action cannot turn a non-L² variable into an L² variable: otherwise subtracting the local action would make the added term L². Thus the displayed policy cannot directly inhabit `InclusiveRawPolicy` at seed ξ.

For each ξ and each physical outcome, the action differs from the local action at only one time. Its time-integrated running loss is exactly the same as the local policy's; the schedule and communication charge are unchanged. **This is not a counterexample to Theorem 2's value or periodic optimality.** It is a counterexample to treating the two pointwise moment conditions as identical.

### What is formally checked

`review/C5Checks.lean` proves, for a generic spike function f:

- `diagonalSpike_section_ae_zero`: at each fixed time, an atomless seed makes the spike zero almost surely under the product law.
- `diagonalSpike_joint_memLp`: each fixed-time joint section is L².
- `diagonalSpike_bad_conditional`: if f is not L², fixing seed ξ and taking t=ξ gives a non-L² action section.
- `diagonalSpike_time_ae_zero`: for every fixed seed and outcome, the spike is zero for Lebesgue-almost-every time.

The concrete Gaussian exponential calculation and its information-feasible realization above are a written mathematical counterexample to class identification; they are **not packaged as a fully formal Gaussian counterexample theorem**. The diagnostic Lean lemmas explicitly take the non-L² fact as a hypothesis where needed. Nothing in the paper proof is made dependent on that hypothesis.

### Closure choices

**Recommended: preserve the broader reading.** Add a measurable, cost-preserving repair theorem, or extend the lower-bound proof directly to jointly measurable policies with unconditional fixed-time L². The required argument must control the measurable set of bad (seed,time) sections, establish the right almost-everywhere quantifiers, preserve information feasibility and show equality of the horizon objectives. C2 already erases reception endpoints for typed competitors, but it cannot automatically accept the displayed untyped competitor before its `memLp` field is supplied. General bad sections need not occur only at reception times.

**Alternative: explicitly adopt conditional admissibility.** The authors may define the paper's admissible class using finite μ-second moments after fixing the seed, for every time. This matches the Lean moment field (up to irrelevant values at nonpositive times, which can be specified separately). Under an unconditional reading, that is a substantive change, not merely an editorial clarification. Do not present it as preserving every previously intended policy unless an additional value-equivalence theorem is proved.

The proposed paragraphs in `model-clarifications.md` keep these alternatives separate. No paper edits have been applied.

## 6. Other semantic points resolved or isolated

### Joint measurability

`InclusiveRawStrategy.before_measurable` and `.after_measurable` permit Tonelli on each fixed-seed phase; `.loss_measurable` permits averaging the integrated loss over the independent seed and physical outcome. Pointwise measurable random variables indexed by time do not alone supply these facts. C3 supplies jointly measurable raw primitives, not joint measurability for every possible competitor action.

`C5Review.ofJoint` proves a useful sufficient interface: jointly measurable actions in (t,ξ,ω), the existing conditional L² requirement, per-time history adaptation and measurable counts produce an `InclusiveRawStrategy`. `ofJoint_action` states that the supplied action is retained exactly. Thus the analytic fields are derivable for the conventional jointly measurable class. This is an actual construction, not a new assumption of a cost identity or optimality result. H1 remains visible in `hL2`.

### Null events and histories

`aeHistory` augments a history by ambient-null changes; it is not an assertion of literal equality of uncompleted raw and selected-representative histories. `informationSpace_aeHistory` and `receivedInfo_informationSpace` prove the equality that optimization needs. The arbitrary-index generator argument avoids intersecting an uncountable family of full-measure events. A paper sentence allowing history-measurable versions almost surely is suitable; it does not grant useful future information or change the L² optimized values.

### Startup, agents and seed information

`PhysicalSchedule.nonnegative` excludes pre-zero transmissions. Received pooled data come only from actual sends; initially there is no free pooled message. Real-time local histories still include the agent's observations before zero, as the stationary paper model permits. The paper proof's initial-interval argument supports this interpretation. An explicit model sentence would remove ambiguity; an arbitrary infinite prehistory of pooled broadcasts is not covered by the same initialization definition.

The paper has a common n and the same physical agent across components. Lean's `AgentCoordinates` is more general. `C5Review.commonAgents` constructs the identity specialization whenever every component has n agents. Hence this generality does not obstruct the paper's case; reviewers should select that specialization rather than read arbitrary cross-component coordinates as physical agent identity.

The product law ν×μ enforces independence of the seed and the entire physical process. Fixing ξ supplies the entire independent schedule to the fixed-seed proof. Allowing actions this additional independent seed information enlarges the comparison class; the lower bound remains valid and the deterministic attaining strategies need no extra information. A general representation theorem between all abstract probability-space formulations and this product presentation is not claimed here. Sensor-dependent schedules remain excluded, as in the paper.

### Objective, charges and endpoints

`timeAverage` is E[∫_(0,R] loss dt+cN(R)]/R; `timeUpperCost` takes its limsup as R tends to infinity. This is neither an expectation of a pathwise limsup nor an average of only a proposed policy's stage costs. `N(R)` counts sends, including messages still in flight, with repetitions charged separately. Positive weights and nonnegative quadratic losses justify use of ENNReal; infinite expected or accumulated costs are not silently discarded. Exact candidate cost equalities include nonnegativity checks where `ofReal` could otherwise clip a negative value.

C2 covers immediate use at reception for every formal competitor. Its strict adapter changes only countably many times for each fixed seed and preserves every horizon integral for every physical outcome. Candidate policies may ignore a message at the exact delivery instant and still be feasible and attain the same time-integrated cost. The unique positive period root is not uniqueness of all optimal random schedules.

## 7. Failure-mode guidance applied

| Failure mode | Review action / result |
| --- | --- |
| Proving a weakened or different theorem | Derived the paper requirements first; inspected the expanded policy fields. H1 is recorded as a real coverage issue, not excused by a successful build. |
| Vacuity or desired conclusion in an assumption | Followed `full_model_witness`, `PaperModel` and `RawRealization`; actual process fields are constructed. Candidate cost and optimality are conclusions. |
| Linear-only optimizer | Inspected the genuine L² infimum and arbitrary-competitor normal-equation bound. |
| Quotient representative / uncountable-null trap | Traced raw arithmetic functions and completed-history L² equalities; no simultaneous representative event is assumed. |
| Wrong objective / exchange of quantifiers | Expanded `timeAverage`, `timeUpperCost`, per-seed `policy` and `memLp`; supplied the diagonal diagnostic. |
| Semantic errors hidden in notation | Checked n-normalization, γ=2λ, positive weights, latency exponent, non-strict reception and send-time charges. |
| Stale sources or unaudited dependencies | Checks the current source lock; supplementary constants receive their own dependency/axiom audit and kernel replay. |
| Misleading certification | Distinguishes core verification, supplementary checks and semantic review. No independent human or independent implementation is claimed. |

## 8. Human acceptance worksheet

A reviewer can work from the clauses below without reading every tactic. For each item record **accept / reject / needs revision**, one sentence of reason, name and date. Blank items are pending, not tacit approval.

| Item | Open these clauses | Point-by-point question | Record |
| --- | --- | --- | --- |
| H1 | `InclusiveRawStrategy.policy`; `InclusiveRawPolicy.memLp`; this report §5 | Is the intended moment condition conditional or unconditional? Does the diagonal example fall within the intended class? Choose a bridge or a documented model change. | Pending |
| H2 | `C5Review.ofJoint`: `hj`, `hL2`, `hf`, `hcount`; `InclusiveRawStrategy` analytic fields | Accept joint measurability for time integration. Notice that `hL2` still quantifies over every seed. Do not approve it as a proof of the broader class bridge. | Pending |
| H3 | `PhysicalSchedule.nonnegative`, `count_spec`; `RawRealization.receivedInfo` | Confirm no pre-zero sends and no initially supplied pool, while all local past observations remain available. | Pending |
| H4 | `aeHistory`; `informationSpace_aeHistory`; `receivedInfo_informationSpace` | Confirm that information is interpreted up to ambient-null versions and that this is value-equivalent to the intended strict measurable policy class. | Pending |
| H5 | `AgentCoordinates`; `C5Review.commonAgents` | Instantiate a common n and matching physical agent index in each component. | Pending |
| H6 | `InclusiveRawStrategy.timeAverage`, `.timeUpperCost` | Check expectation/limsup order, positive-horizon normalization, running loss weights and generation-time charge. | Pending |
| H7 | `receivedBy`; `toStrict_integrated_loss`; `toStrict_timeUpperCost` | Confirm non-strict reception and equality of all horizon objectives after endpoint modification. | Pending |
| H8 | `Theorem1Claims` and `theorem1_arithmetic` | Check the nine fields against equations in Theorem 1 using §4 above. | Pending |
| H9 | `RefreshMixture.ofParameters`, `.marginal_formula`; `theorem2_ou_physical_attainment` | Match A, γ, critical price, equation root, cost equality and quantified competitor class. Do not infer uniqueness of every optimal schedule. | Pending |
| H10 | `full_model_witness`; `PaperModel`; `PaperComponents` | Accept centered Gaussian/covariance semantics of the stationary model and whole-process independence; confirm a constructed model is the intended nonvacuity witness. | Pending |
| H11 | `review/verification.json`; `proof-project/evidence/verification.json` (generated) | Distinguish kernel validity, semantic correspondence and reviewer independence. Record any external checker or human review separately. | Pending |

Reviewer name: __________  Affiliation/role: __________  Date: __________

Independence from proof authorship: __________

Selected H1 resolution: __________  Approved paper revision / formal bridge identifier: __________

Final scope accepted: __________  Remaining objections: __________

## 9. Verification and next action

The validation commands in `README.md` generate fresh reports and logs. Core verification checks the pinned sources and dependencies, 36 regression examples, 13 frozen theorem types, all local/vendor axioms, required proof dependency paths and fresh kernel replay. Eight negative tests check that the verifier rejects source drift and injected axioms. Supplementary verification compiles the correspondence module, audits every elaborated constant and replays that module against the built core.

Generated results live in `proof-project/evidence/`, `proof-project/proof-dag.json` and `review/`; CI uploads them as artifacts. They are not committed. Both replay checks use Lean's own checker, not an independently implemented kernel. Successful verification does not resolve the semantic findings above or constitute independent human acceptance.

**Next substantive work:** prove the unconditional-to-conditional cost-preserving correspondence, or extend the physical lower-bound theorem to the broader joint class. After that, settle the proposed model paragraph and obtain independent human acceptance. A publication claim should currently say that the formulas and physical optimality are machine-checked **for the explicitly formalized class**, with the randomized-admissibility correspondence issue disclosed.
