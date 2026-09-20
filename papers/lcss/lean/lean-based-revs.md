# Minimal Lean-based revisions for the L-CSS paper

Proposed additions for a future revision of `papers/lcss/main.tex`. These changes have not been applied to the paper.

1. **H1: conditional second moments.** Add at the beginning of Theorem 2 (Optimal refresh period):

   > For randomized strategies, assume that, for every fixed realization of the independent random seed and every time, each action has finite second moment with respect to the signal and disturbance processes.

2. **M1: joint measurability.** Add to the opening model paragraph of the refresh section:

   > Actions are jointly measurable in time, the independent random seed, and the signal and disturbance outcomes. The number of transmissions by each time is measurable in the seed.

3. **M2: startup convention.** Add to the opening model paragraph of the refresh section:

   > Transmission times are nonnegative, and no pooled messages are supplied initially without a transmission. Agents retain their local observation histories from before time zero.

4. **Information constraints up to null events.** Add to the general model paragraph defining admissible policies:

   > Information constraints are understood up to events of probability zero.
