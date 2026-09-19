# Selected Brownian construction sources

This tree contains the 30-module non-Mathlib import closure of `BrownianMotion.Gaussian.BrownianMotion` at the catalog's pinned revisions:

- [BrownianMotion, commit be340b9](https://github.com/RemyDegenne/brownian-motion/tree/be340b915d6d59a63d871ba6fed7a04eef77fb1b).
- [Kolmogorov extension, commit 7d76e18](https://github.com/RemyDegenne/kolmogorov_extension4/tree/7d76e184c3d2138a2741baf923b57e9a01b9cf25).

The selected files are compiled against this project's pinned Lean 4.33.1 and Mathlib `0df444a360eaa60ab8c11dca51a86af692955474`. Upstream repository toolchain/manifests are not imported. `UPSTREAM.json` lists exact source paths, original hashes, ported hashes, repository revisions and license hashes. Both source trees retain their Apache-2.0 license.

`compatibility.patch` is the entire port: remove the duplicate `Set.indicator_apply_apply` declaration from `BrownianMotion/Auxiliary/Algebra.lean`, because the pinned imported libraries already supply it. The other 29 files are unchanged. Whole modules are retained, including some unused downstream declarations in the Brownian root, to keep the source comparison simple.

The axiom audit extracts **all** elaborated constants owned by these namespaces, not just the final Brownian theorems. It checks their transitive axioms, includes their source hashes in verification evidence, and replays the complete `LCSS` import closure with `leanchecker --fresh`. `evidence/vendor-dependencies.json` retains constant types and exact dependencies; `proof-dag.json` groups these constants into module nodes. This is source-vendored reuse of proved results, not a Brownian existence axiom.

Upstream code has ordinary probability/measurability typeclass instances and linter warnings. They are preserved and subject to the same axiom/replay checks. No independent kernel or separate upstream semantic review is claimed.
