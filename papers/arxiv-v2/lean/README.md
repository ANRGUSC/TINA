# Lean formalization of tina-v2-alt

Machine-checked proofs of the claims in `submissions/arxiv-v2/main-alt.tex` and
`technical-appendices-alt.tex`, built claim by claim on branch `scott-arxiv2-lean`.

This work starts from the paper text only. It does not read or reuse
`papers/lcss/lean/`.

## Hard constraints

1. **The Lean proofs and the paper's proofs agree 1:1.** Each step of each proof
   in the paper corresponds to exactly one Lean lemma, in the same order, with
   the same dependencies. Lean may not take a different route from the text.
2. **If Lean cannot follow the paper, the paper changes.** The new English proof
   is written first, recorded as a diff against the TeX, and Lean mirrors that.
   A claim is not verified until the proof Lean mirrors is the one in the paper.
3. **Everything is tracked in a queryable ledger**: claims and their
   dependencies, English proof versions and steps, Lean statements, Lean proof
   attempts (with success and failure notes, branches and retries), paper edits
   as diff hunks, and findings.

## Layout

```
ledger/schema.sql     tables and views
ledger/data.sql       one INSERT per row; the committed source of truth
tools/ledger.py       CLI: status, show, frontier, sql, add, set, note, check,
                      graph, edit-diff, edit-apply, db
lakefile.toml, lean-toolchain     Lean 4.33.1 + Mathlib v4.33.1
TinaV2/Prelude.lean   the only Mathlib import (a narrow module list)
TinaV2/Smoke.lean     toolchain smoke test, not part of the ledger
TinaV2/Routine/       regularity lemmas the paper leaves implicit
TinaV2/Defs/          shared definitions (model, architectures, regret)
TinaV2/Statements/    one file per claim: `def Cxx.Statement : Prop`
TinaV2/Proofs/Cxx/    one file per attempt: one lemma per paper step + `main`
TinaV2/Assembly.lean  generated: selected attempts composed end to end
```

`Defs/`, `Statements/`, `Proofs/` and `Assembly.lean` are empty until phase 1.

## The ledger

SQLite, rebuilt in memory from `schema.sql` + `data.sql` on every call, so git
diffs of the ledger are readable and there is no binary file to merge.
`python3 tools/ledger.py db` writes a `.db` copy for the `sqlite3` shell.

| Table | Holds |
|---|---|
| `claims`, `claim_deps` | Every assertion in the paper and what it depends on. IDs C1–C27 match the co-author review ledger; `C7.b` is a sub-claim. Scope is `lean`, `numeric` or `prose`. |
| `proofs`, `steps`, `step_deps` | English proofs, versioned per claim, split into ordered steps. Each step stores the verbatim TeX and what it uses. |
| `formalizations` | Lean statements of a claim, versioned: `draft` → `reviewed` → `frozen`. |
| `attempts`, `step_map` | Lean proof attempts. Each mirrors one English proof; `parent` links retries and simplifications; `step_map` is the step ↔ lemma correspondence. |
| `edits`, `hunks`, `edit_deps`, `hunk_steps` | Changes to the paper. An edit takes a claim from one proof version to the next; its hunks hold old and new TeX; `hunk_steps` records which steps each hunk adds, rewrites or removes; `edit_deps` orders edits that build on each other. |
| `findings` | Problems the formalization exposes in the paper. |
| `notes` | Append-only log against any ID: success, failure, insight, decision, todo, build. |

Common queries:

```
python3 tools/ledger.py status            # every claim and its state
python3 tools/ledger.py show C7           # proofs, statements, attempts, edits, notes
python3 tools/ledger.py show C7/p1        # the English proof, step by step, with Lean lemmas
python3 tools/ledger.py frontier          # claims ready to prove
python3 tools/ledger.py check             # invariants below; non-zero exit on failure
python3 tools/ledger.py sql "SELECT target, body FROM notes WHERE kind = 'failure'"
```

Claim states: `todo` → `stated` → `proving` → `proved_unaudited` → `verified`,
with `needs_paper_edit` when the Lean proof mirrors a proof that is still only
proposed, and `no_paper_proof` when the paper asserts something without proof.

## The 1:1 rule

The unit of correspondence is the proof step.

- An attempt file `Proofs/C07/A1.lean` contains one lemma per step of the
  English proof it mirrors (`s1_…`, `s2_…`, in order) and a `main` that combines
  them into `C07.Statement`. It contains nothing else.
- A step lemma states the intermediate fact the paper's step states. Its proof
  may use only the earlier steps and claims listed for that step in
  `step_deps`, Mathlib, and `TinaV2/Routine/`.
- `Routine/` holds only what a careful paper leaves unsaid: measurability,
  integrability, finiteness, unfolding definitions, ring identities. It may not
  import `Statements/` or `Proofs/`. Anything that would deserve a sentence in
  the paper is not routine; it becomes a finding.

`ledger.py check` enforces what can be checked mechanically:

- every step of an in-paper proof is still found verbatim in the TeX;
- every step has exactly one Lean lemma and every lemma in an attempt file has
  a step;
- a proved attempt has no `sorry` and all its steps proved;
- a proposed proof has an edit carrying its text, and every step that differs
  from the previous proof version is covered by a hunk;
- proposed hunks still apply and applied hunks are present in the TeX;
- at most one primary in-paper proof and one selected attempt per claim.

Two things need more than this and are planned (phase 2 and 5):

- a Lean metaprogram that lists the constants each step lemma uses and compares
  them with `step_deps`, so a step cannot quietly use something the paper's
  step does not;
- a generated side-by-side page (step TeX next to the Lean lemma statement) for
  human review, because whether a Lean statement says what the English says
  cannot be checked by machine.

### When Lean cannot follow the paper

1. Log a `failure` note on the attempt with the obstacle.
2. Open a finding.
3. Write the revised English proof as a new version (`C7/p2`, parent `C7/p1`,
   status `proposed`) with its steps, and an edit whose hunks rewrite the TeX.
4. Start a new attempt that mirrors `C7/p2`.
5. When it is proved the claim is `needs_paper_edit`. On approval,
   `ledger.py edit-apply E1` rewrites the TeX, marks `p2` in-paper and `p1`
   superseded, and the claim becomes `verified`.

A simpler proof found along the way goes through the same path. There are two
kinds of branch, and the ledger keeps them apart:

- **Lean-only retry**: same English proof, different tactics. New attempt,
  `parent` set, no paper change.
- **Proof change**: new proof version plus an edit. The paper changes.

Statements follow the same rule. A hypothesis Lean needs and the paper lacks is
a finding and a statement edit.

## Are separable per-claim proofs safe?

Yes, with the structure below, and the end-to-end check is cheap enough to run
on every commit instead of saving it for the end.

- `Statements/Cxx.lean` defines `Cxx.Statement : Prop` from `Defs/` only.
- A proof file imports `Prelude`, `Defs`, `Statements` and `Routine`. It never
  imports another claim's proof. Where the paper's step uses claim X, the step
  lemma takes `(hX : CX.Statement)` as a hypothesis.
- `Assembly.lean` is generated from the selected attempts. It supplies each
  hypothesis with the proved theorem (`theorem C08 : C08.Statement :=
  C08.A1.main C07`) and prints the axioms each result depends on.

Editing one proof therefore rebuilds one file. A stuck upstream proof does not
block downstream work, and attempts for the same claim coexist as separate
files with the same target.

| How separable proofs could leak | What closes it |
|---|---|
| Downstream assumes a different statement than upstream proved | Both refer to the same `Cxx.Statement` constant; `Assembly.lean` fails to type-check otherwise. |
| Each file defines its own version of regret, architecture, etc. | Definitions live only in `Defs/`; proof files may not define model objects. |
| `sorry` or added axioms | `check` rejects `sorry`; `Assembly.lean` prints axioms, which must be the three standard ones. |
| Circular dependence between claims | Assembly order follows the claim graph; Lean rejects import cycles. |
| A statement is vacuous (hypotheses cannot all hold) | Each model gets a concrete instance satisfying its hypotheses (phase 5). |
| The Lean statement is not the paper's statement | Human review, then `frozen`. A later change is a new formalization version, and the ledger shows which attempts it invalidates. |

## The claim graph

45 claims: 37 in Lean scope, 4 numeric (figures), 4 prose (abstract, related
work, discussion, appendix remarks). 19 English proofs split into 68 steps.
21 Lean-scope claims have a proof or are definitions; 16 are asserted without
proof.

| Tier | Needs | Claims |
|---|---|---|
| A | Real analysis and algebra | C5, C7.b, C8.c, C10, C13, C13.b, C13.c, C14, C15, C15.b, C15.c, C16, C19, C19.b, C20 |
| B | Finite-dimensional probability: L², conditional expectation, independence | C1.c, C3.b, C4, C4.b, C5.b, C6, C6.b, C6.c, C7, C8, C8.b, C11, C12 |
| C | L² projection onto a closed subspace | C1, C1.b, C2, C3 |
| D | Gaussian processes and the continuum model | C4.c, C9, C17, C17.b, C18 |

Critical path: C4, C5, C6 → **C7** → C8 → C10, and C7 → C14 → C16 → C19.
The paper's proof of C7 uses no projection theorem, so tier C is off the
critical path. C19 also needs C18 and the bridge C17.b (tier D).

`python3 tools/ledger.py graph` prints the graph as Mermaid.

## Phases

0. **Infrastructure.** Branch, ledger, claim graph, proof steps, Lean project
   that builds against Mathlib. *Done: `lake build` passes and the smoke-test
   theorem depends only on `propext`, `Classical.choice`, `Quot.sound`.*
1. **Definitions and statements.** `Defs/` and a `Statement` for every tier A
   and B claim, no proofs. Each ambiguity in a paper statement becomes a
   finding. Scott reviews the statements against the paper; approved ones are
   frozen.
2. **Tier A and B proofs**, C7 first, each mirroring the paper's steps. Add the
   step-dependency audit.
3. **Tier C**: projection lemma and normal equations.
4. **Tier D**: starts by resolving F1 (the bridge) through a paper edit, and by
   checking what this Mathlib version provides for Gaussian processes.
5. **Assembly and audits**: axioms, step dependencies, non-vacuity instances,
   the side-by-side review page for co-authors, and applying approved edits.
   Numeric claims are linked to the existing verification scripts, not proved
   in Lean.

## Working rules

- Before an attempt, run `ledger.py show <claim>` and read the failure notes.
- Test the exact statement numerically before trying to prove it.
- Search Mathlib (`.lake/packages/mathlib`) before writing a `Routine` lemma.
- Never `import Mathlib` whole: it costs about 48 s per file check here, against
  about 4 s with the narrow list in `Prelude.lean`. Add modules there as needed.
- If a step is not closed after about eight build cycles, stop, log a `failure`
  note naming the obstacle, and choose between a Lean-only retry and a finding.
- Record build time and line count on every proved attempt, so variants can be
  compared.
- Run `ledger.py check` before every commit.

## Decisions

Made on 2026-11-13:

- **Claims the paper asserts without proof** (state `no_paper_proof`: C1.b,
  C1.c, C4.b, C4.c, C6.b, C7.b, C8.b, C8.c, C9, C13, C13.b, C13.c, C15.b,
  C15.c, C20, and the implicit C17.b) get short proofs in an appendix through
  tracked edits, and those proofs are formalized.
- **F2: C12 has two derivations** of the optimal local rule. The main-text one
  (`C12/p1`) is the proof Lean mirrors. When C12 is formalized, a tracked edit
  cuts the appendix down to the arithmetic, so C12 needs no tier C material.
- **Toolchain**: Lean 4.33.1 and Mathlib v4.33.1, the versions already on this
  machine. Tier D may need a newer Mathlib for Gaussian processes; decide then.

Still open:

1. **F1: the continuum bridge.** C19 cannot be proved in Lean until the paper
   states why the composition law applies to the canonical field model.
2. **C4.c: the Ornstein–Uhlenbeck example** is written as a stochastic
   differential equation, which Mathlib cannot express. A covariance-based
   Gaussian statement would be provable but is a statement edit.
3. **Rules as functions or as measurable maps.** The main text writes
   `u_i = g_i(Z_i)`; the appendix uses sigma-algebras. Lean will follow the main
   text, and the link between the two becomes an explicit step where C1 is used.
4. **Review finding K1** (the composition law is in Marschak–Radner). If the
   paper restates C7 as a known result, that arrives as edits in this ledger
   and the Lean proof follows.

## Libraries

Surveyed on 2026-11-13: Mathlib v4.33.1 (our pin), TauCeti at `62bbc05`
(Mathlib master, Lean 4.36.0-rc2) and atlas-lean at `8e813e6` (Mathlib v4.35.0).
Both alternatives are add-ons that `require mathlib`; neither replaces it.

- **Tiers A, B, C need nothing beyond Mathlib v4.33.1.** Neither add-on has team
  theory, the Q-weighted projection (C1) or the composition law (C7).
- **Tier D: atlas-lean has the closest material.**
  `MathlibExt/Probability/OrnsteinUhlenbeck.lean` defines the stationary scalar
  OU process as a Gaussian process with covariance `(σ²/2θ) e^{-θ|t-s|}` and
  proves existence, stationarity, `E[X t | F s] = e^{-θ(t-s)} X s` and the
  transition law. That covers C4.c and C9 in scalar form. Its import closure
  is 3 files, 1603 lines, with no `sorry` or axioms.
- **Neither add-on covers C17 or C18**: no Gaussian field on line × time, no
  spatial Markov property on a two-sided index, no integral of a field
  against a weight. That is our own work under any choice.
- **Trial compile against our pin**: atlas `BestPredictor.lean` and
  `AR1Variance.lean` compile unchanged. `KolmogorovExtension.lean` and
  `GaussianConditioning.lean` fail (renamed lemmas, API drift), so the OU file
  does not build on v4.33.1 as it stands.

Recommendation, not yet confirmed by Scott: Mathlib stays the only Lake
dependency. For tier D, copy the three atlas OU files at a recorded commit
into a separate vendored directory with their licence headers, and treat them
as library code under the 1:1 rule. Any vendored definition that appears in a
`Statement` is reviewed like our own `Defs/`.

**TODO (when the connection allows): move to Lean and Mathlib v4.35.0** before
tier D starts, so the atlas OU files build unchanged. Measured cost: Lean
toolchain 543 MB, Mathlib cache 440 MB in full or about 160 MB for our import
closure (`lake exe cache get` with the `Prelude.lean` module list), Mathlib git
fetch about 30 MB. Roughly 1 GB, 35–50 minutes at 4 Mbps; about 0.75 GB with
the partial cache. Not needed for phases 1–3. After the bump, rebuild and
record any tier A–C proof that breaks as a Lean-only retry.

## Next step

Phase 1: `Defs/` and Lean statements for the tier A and B claims, no proofs,
for review against the paper before anything is frozen. Not started.

## Findings so far

Four, all from reading the proofs for step extraction (none yet from Lean):
`python3 tools/ledger.py sql "SELECT id, claim_id, severity, title FROM findings"`.
