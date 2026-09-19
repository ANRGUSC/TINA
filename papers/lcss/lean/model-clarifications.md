# Proposed C5 model clarification

**Draft for author review; not applied to the paper.** The decision about randomized second moments below must be made explicitly. The current Lean proof supports Option B. Option A preserves a natural broader reading but needs a formal correspondence extension. Both retain the same numerical formulas; equality of their admissible classes is not asserted.

## Shared model text

For the continuous-time refresh problem, use jointly measurable versions of the Gaussian primitives. All components have the same n physical agents. Agent i observes its own local histories in every component. At time t it also knows the timestamped pooled messages whose reception times are at most t. Actions are jointly measurable in time, the independent random seed and the physical outcome, and, after fixing the seed, admit versions measurable with respect to this information at each positive time. Information constraints are understood up to events of probability zero under the physical process law.

Transmissions occur at nonnegative times and are locally finite. There are no pooled messages initially supplied without a transmission; each agent retains its own stationary local prehistory. A message sent at s is available at s+δ, including that instant, and carries the vector of componentwise arithmetic means sampled at s. There is no queueing or minimum separation requirement. Each transmission is charged at its generation time, including transmissions not yet received at the evaluation horizon.

Randomized schedules are functions of a random seed independent of all signal and disturbance processes. Use the product of the seed law ν and the physical law μ. The transmission count through each horizon is measurable in the seed. Giving the full independent seed to the agents is permitted; the attaining no-refresh and periodic policies require no random seed.

For R>0, set

\[
J_R(u,S)=\frac1R\mathbb E_{\nu\otimes\mu}
  \left[\int_{(0,R]}\sum_m w_m\ell_m(t,u(t))\,dt+cN_S(R)\right],
\qquad J(u,S)=\limsup_{R\to\infty}J_R(u,S).
\]

Infinite costs are permitted in comparisons. A strategy includes a single schedule and action path for all horizons.

## Option A: retain unconditional fixed-time square integrability

For every fixed positive time t, agent i and component m, require

\[
\mathbb E_{\nu\otimes\mu}|u_{im}(t,\xi,\omega)|^2<\infty.
\]

**Formal status:** the current theorem does not directly quantify over this class. Joint measurability supplies the integral framework, but `InclusiveRawPolicy.memLp` asks for every seed's section to be square-integrable at every time. The diagonal example in `audit.md` separates the conditions.

**Recommended follow-up:** prove a cost-preserving measurable repair/embedding or a direct lower bound for this class. Establish measurability of the bad-section set, its product-null status, seed/time section claims in the correct order, adaptedness of the repaired action and equality of the physical horizon cost. Do not cite endpoint erasure alone as covering arbitrary bad sections. Preserve all existing roots and add a new paper-facing root for this class. The deterministic attaining policies already have the required moments.

## Option B: state conditional square integrability explicitly

After fixing every seed ξ, require, for every positive time t, agent i and component m,

\[
\mathbb E_\mu|u_{im}(t,\xi,\omega)|^2<\infty.
\]

Joint expected cost is still allowed to be infinite. Values at nonpositive times may be set to zero when encoding a policy in Lean; this does not change any positive-horizon time-integrated objective. The local observation histories themselves are not set to zero.

**Formal status:** with measurable counts and the shared joint/adaptation clauses, `LCSS.C5Review.ofJoint` constructs precisely the required analytic strategy fields and retains the supplied actions. The current physical optimality theorem then applies directly for this conditional class.

**Editorial consequence:** adopting Option B is not automatically a harmless clarification. Under an intended unconditional reading, it excludes policies such as the diagonal example while also allowing some policies with infinite joint second moment. No equality of the two classes, or general equality of their attainable values, has yet been formalized.

## Changes not needed

No change to the critical-price formula, optimal-period equation, optimal value, Gaussian covariance parameters, fixed-latency service or immediate-reception convention is indicated by this review. Deterministic-only scheduling is not needed as a repair. C3's constructed continuous model supplies a jointly measurable instance; no SDE equivalence is needed for the paper's Gaussian/covariance specification.

## Approval record

- Intended moment convention: __________
- If Option A, accepted formal bridge/root and version: __________
- If Option B, author acknowledgment of the class distinction: __________
- Startup convention accepted: __________
- Joint measurability and information convention accepted: __________
- Common physical-agent indexing accepted: __________
- Independent reviewer, date and scope: __________

These blanks are intentionally pending. The original paper remains unchanged.
