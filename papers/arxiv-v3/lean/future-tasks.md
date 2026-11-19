# Future tasks

Tasks that are noted but not started and not decided. The order of the work
that is decided is in `README.md`, "Next step"; this file holds what is parked
beside it. Started on 2026-11-19, during the statement review.

## 1. Simplifications to suggest (parked by Scott, 2026-11-19)

Scott's question at the review of the two-sensor example: here and elsewhere,
should we suggest edits that simplify? Not now. The examples below are kept so
the question can be taken up later. Nothing here is a finding, and none of it
is wrong in the paper or in Lean: each item is a hypothesis or a dependency
that the result turned out not to need.

Three kinds, because each has a different owner and a different cost.

### 1a. The paper states a hypothesis its result does not use

These would be suggestions to Bhaskar. A hypothesis may be there for the
reader, or for the sentences that follow, so each needs a look at the
surrounding text before anything is proposed.

| Claim | Hypothesis in the paper | What the Lean proof needs | Record |
|---|---|---|---|
| C10, crossover theorem | "If `0 ≤ η_S(0) < 1`" | Only `η_S(0) < 1`. The lower bound always holds and the proof never uses it. | `C10/f2/d1` |
| C14, radius objective | `τ` nondecreasing, `τ(0) = 0`, maximum radius `D` | None of the three, for the three identities. `τ(r) ≥ 0` is used. They do matter for the reading of the section. | `C14/f1/d2` |
| C15, marginal balance | `τ′ ≥ 0`, `η_S′ ≤ 0`, `η_S ≥ 0` | Only continuous differentiability on `[0, D]` and `η_S < 1`. But `τ′ ≥ 0` is what makes the comparative statics of the next paragraph (C15.c) true, so it is not idle in the section. | `C15/f1/d2`, note on `C15/a1` |
| C7, composition theorem | A stationary process | Equal one-time laws at the two epochs, at one epoch and one delay. | `C7/f1/d2`, `C4/f1/d1` |
| C6 and after | The state is centered | Zero mean is not needed as a model assumption; where the temporal assumption holds with `τ > 0` it follows. | `C6/f1/d2` |
| C1.b, projection remark | Target `x⋆ = Q⁻¹b(θ_t)` | Holds for any square-integrable target. | `C1.b/f1/d2` |
| C17.b, composition in the field model | `σ² > 0` (model paragraph, since v3) | Holds without it. Scott decided on 2026-11-19 to keep it a hypothesis of C18 and C19 only. | `C17/f1/d3` |

### 1b. A Lean statement carries a hypothesis Lean does not use

These would be changes to Lean statements. Every one of these statements is
frozen, so a change is a new statement version and a new approval. The gain is
a shorter statement that is closer to what is actually proved; the cost is
that some of these hypotheses are the paper's own words, and dropping them
makes the Lean statement look less like the paper.

| Statement | Unused hypothesis | Note |
|---|---|---|
| `C11/f1`, two-sensor example | The two stationarity hypotheses (`IdentDistrib`) | Mean zero and variance `σ²` are assumed at every time, which already gives what stationarity is used for. The alternative that is closer to the paper: assume the moments at one time and keep "stationary". Square integrability is also implied by the variance hypothesis. |
| `C15/f1`, marginal balance | `0 < T`, `0 < D`, `τ′ ≥ 0`, `η′ ≤ 0`, `0 ≤ η` | They come with `SmoothCurves`, which C15.b and C15.c share. Note on `C15/a1`. |
| `C5.b/f1`, affine reduction | `Measurable snap`, `MemLp snap 2`, `Measurable now` | Note on `C5.b/a1`. |
| `C17.b/f1`, composition in the field model | `0 ≤ r` | Not used by any step. Note on `C17.b/a1`. |
| `C1/f1`, projection lemma | `IsProbabilityMeasure μ` | Not used by any step. Note on `C1/a1`. |
| `C16/f1`, exponential omission | (none found) | Listed so the table is not read as complete: no one has tested the other statements for unused hypotheses. |

How to find the rest: delete one hypothesis from a statement in a scratch copy
and rebuild its proof. Lean's unused-variable linter does not report an unused
hypothesis of a `def … : Prop`, so this has to be done by trial.

### 1c. The ledger lists a dependency a step does not use

`ledger.py audit -v` prints these as "listed but not used": 59 lines at the
moment. Most are a definition claim (C6 26 times, C17 16, C4 9) listed on a
step that uses the definition and no statement, which is how definitions are
meant to be listed, so they are not errors. The ones worth a second look are
the claims with a proved statement:

- C14 is listed on all nine steps of C15 and C16 and used by none: both proofs
  are about the gain function alone.
- C19 is listed on the three steps of C19.b and used by none: the comparative
  statics are proved from the closed form of the radius.
- C5 (completing the square) is listed on the two steps of C5.b and not used.
- C6.b is listed on three steps of C7 and C8 and not used.
- `C12/p1`: step 4 does not use step 2 in Lean, and step 5 proves a clause
  ("every constant has nonnegative expected cost") that nothing uses (note on
  `C12/a1`).

A listed dependency records what the paper's sentence cites, so pruning is not
automatic: where the paper cites something Lean did not need, that is itself a
small fact about the proof and may be worth telling Bhaskar (kind 1a).

Also parked here, from a todo note on `C16/a1`: `Routine/ExpRadius.lean` and
`Routine/RadiusCalculus.lean` each have a wrapper for "strictly monotone from
the sign of the derivative"; merge them.

## 2. Other parked items

- **An example for "the optimum can stay unchanged at a boundary"** (C15.c).
  The sentence is not stated in Lean (`C15.c/f1/d3`). Stating it means proving
  one example in which a larger `T` leaves the optimum at `0` or at `D`.
- **Uniqueness of the best estimate in the two-sensor example.** `C11/f1` says
  the named estimates attain the smallest error, not that nothing else does
  (`C11/f1/d2`).
- **Non-vacuity instances** (README, phase 5): a concrete model satisfying the
  temporal assumption with `R_∞ > 0` and `0 < η_S(0) < 1`, and a Gaussian field
  satisfying `CanonicalField`. Until then each theorem is about "every model
  that satisfies the hypotheses" with no proof in Lean that one exists.
- **A side-by-side page** of step TeX and Lean lemma statement (README, "The
  1:1 rule", planned).
