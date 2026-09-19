# L-CSS theorem proofs

Lean proofs of Theorems 1 and 2 of [the letter](../main.tex), with a constructed
independent Gaussian/OU model, arithmetic-history adapters, physical attaining
policies, and inclusive reception endpoints.

**Scope:** H1 (randomized-policy admissibility correspondence) remains open; this merge leaves the letter text in `papers/lcss/main.tex` unchanged.

Theorem 2 establishes optimality for the explicitly formalized policy class.
The [correspondence audit](audit.md) records an unresolved distinction between
conditional per-seed square integrability and unconditional fixed-time square
integrability for randomized policies. It also identifies joint-measurability
and startup clarifications. See [model-clarifications.md](model-clarifications.md)
for the proposed alternatives. Independent human acceptance remains pending.

## Contents

- `proof-project/LCSS/`: mathematical definitions and proofs. Main instantiated
  results are `LCSS.full_model_witness`, `LCSS.theorem1_ou`, and
  `LCSS.theorem2_ou_physical_attainment` in `LCSS/ModelWitness.lean`.
- `proof-project/Sanity.lean`: 36 regression examples.
- `proof-project/vendor/`: required Brownian/extension sources, provenance,
  compatibility patch, and upstream licenses.
- `proof-project/contracts/`: the current source lock and 13 frozen theorem types.
- `proof-project/reference/`: the reviewed paper snapshot and its license.
- `review/`: supplementary correspondence proofs and their audit/verification tools.
- `audit.md`, `correspondence.json`: the current paper-to-proof analysis and clause map.

## Validate

Install elan and Python 3, then run from this repository:

```sh
cd papers/lcss/lean/proof-project
export LEAN_NUM_THREADS=2
lake exe cache get
python3 scripts/verify.py --clean
python3 scripts/check_guards.py
python3 ../review/verify_review.py "$PWD"
```

`lean-toolchain` pins Lean 4.33.1; `lake-manifest.json` pins Mathlib and its
transitive dependencies. Verification checks source and dependency revisions,
rebuilds the core and vendor modules, runs the regression examples, audits
axioms, checks theorem types and required dependency paths, and performs
`leanchecker --fresh LCSS`. The supplementary checker compiles and audits its
module, then replays it against the built core. These use Lean's own checker.

For a faster development check, `python3 scripts/verify.py --preflight` omits
fresh replay. It is not full verification. `--extract-only` regenerates the
core DAG from hash-matched previous evidence and performs no new proof checking.

[GitHub Actions](../../../.github/workflows/verify-lcss-lean.yml) runs full
validation on pushes to `main` and pull requests that change `papers/lcss/lean/**`
or the verification workflow itself, and on manual dispatches. Logs, dependency
exports, DAGs, and verification reports are generated locally and uploaded as
CI artifacts; they are ignored by Git. A clean checkout requires no archived
results. The temporary `migratefrom/` inputs are also ignored and are not needed
to build or validate the proofs.
