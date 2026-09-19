# Proof contract

`review-contract.lock.json` freezes the current local and vendored proof sources,
compiler/dependency pins, verification programs, vendor provenance and licenses,
paper snapshot, and 13 exported theorem types. This is a same-author contract,
not independent approval or a claim that the paper and formal policy classes
are equivalent. See `../../audit.md` for the correspondence findings.

The verifier checks every frozen file, all local/vendor transitive axioms, and
required dependency paths through the OU model, raw realization and physical
attainment constructions. Inclusive attainment must exclude the conditional
quotient-regularity assumption. Standard axioms are limited to `propext`,
`Classical.choice` and `Quot.sound`.

The lock is not regenerated automatically. Intentional source or verifier edits
require explicit review and updated file hashes; theorem statement changes also
require review of the frozen types and paper correspondence. Generated evidence
is not part of the lock. Default verification includes fresh kernel replay;
`--preflight` omits it, and `--extract-only` requires matching previous evidence.
