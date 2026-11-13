# Preserved arXiv v2 development material

These files were moved out of the submission folder during its cleanup on
2026-11-12. Nothing here belongs in the arXiv upload. Revision h, revision
instructions, validation scripts and reports, and original PNG figure assets
are retained for reference. `relocation-manifest.json` records the original
and destination paths and SHA-256 hashes of all moved files (including the
companion files now in their own folder).

The manifest captures bytes at relocation time. The active companion's
external-document filename was subsequently updated from `tina-v2-alt` to
`tina-v2` and its PDF rebuilt to follow the requested submission rename.

The build and verification scripts here are historical snapshots tied to
the former layout. For the complete working layout at that point, use commit
`7bace26` in a separate checkout. Use `scripts/build_arxiv_v2.py` in the current
repository for the active paper and companion. The numerical experiment code
and data remain in `numerics/`; the graph verification script remains active
in `scripts/verify_graph_restoration.py`.

Generated pre-cleanup build intermediates were preserved locally under
`tmp/arxiv-v2-pre-cleanup-build/`, not added to version control.
