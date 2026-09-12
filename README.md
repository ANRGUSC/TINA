# TINA

This repository contains the manuscript and complete reproduction package for
**A Theory of Information Architecture for Networked Decisions: Freshness,
Locality, and Coordination**, by Scott Moeller and Bhaskar Krishnamachari.

The paper studies decision-relevant information scope and freshness in an
exogenously evolving quadratic static-team model. Its principal design family
uses synchronized neighborhood snapshots: a broader snapshot arrives at a
greater age. The repository includes the exact manuscript inputs, archived raw
and processed numerical results, and deterministic build/test entry points.

## Interactive reading guide

**Publication status:** This is an L-CSS submission manuscript. It has not been accepted for publication.

[**Read the interactive guide: notation, results, and fully worked proofs**](https://anrgusc.github.io/TINA/lcss-letter/).

The guide covers the six-page letter **Too Late to Coordinate: When Local
Information Beats Global Sharing**. It has adjustable 14–40 px text, chapter
navigation, plain-English explanations, and 260 worked substeps covering all
73 proof steps. This explainer is specific to the L-CSS letter and does not cover
the full TINA arXiv manuscript. Its [source and manuscript provenance](explainers/lcss-letter/)
are included in this repository.

## Repository map

- `papers/full/`: canonical full manuscript, bibliography, figures, and compiled
  preprint.
- `explainers/lcss-letter/`: interactive reading guide, editable explanations, and Pages build.
- `papers/lcss/`: six-page joint L-CSS/ACC Paper 1 manuscript, compiled PDF, IEEE class file,
  figures, and numerical verification materials.
- `papers/acc/`: pointer to the shared L-CSS/ACC Paper 1 source.
- `submissions/arxiv/`: the verified arXiv source closure, metadata, and upload
  ZIP for the full manuscript.
- `submissions/lcss/`: current joint L-CSS/ACC submission PDF and source ZIP.
- `proof-reports/lcss-letter/`: [Lamport review PDF](proof-reports/lcss-letter/TINA_Paper1_Lamport_Report.pdf),
  standalone LaTeX source, audit records, and the reviewed manuscript snapshot.
- `numerics/config/`: fixed experiment parameters and seeds.
- `numerics/experiments/`: six experiment drivers and the all-experiment runner.
- `numerics/src/`: covariance, process, regret, theory, graph, and plotting code.
- `numerics/results/`: archived raw arrays, processed CSVs, and run metadata.
- `docs/`: numerical specification, parameter inventory, audit notes, and a
  clean-room reproduction checklist.
- `tests/`: closed-form, covariance, team-optimality, and package-integrity tests.
- `scripts/`: clean manuscript build and source/reference audits.

## Reproduce the numerical artifacts

Python 3.12 is recommended. From the repository root:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install -r requirements-lock.txt
python numerics/experiments/run_all.py
python -m unittest discover -s tests -v
```

To preserve the archived reference results while testing a clean run:

```powershell
python numerics/experiments/run_all.py --output-root tmp/reproduction --no-paper-copy
```

The reference run takes about one minute on a contemporary laptop. The runner
records configurations, software versions, seeds, diagnostics, and headline
errors in `numerics/results/metadata`.

## Build the paper

A TeX installation containing `pdflatex`, `bibtex`, the standard packages used
by `papers/full/main.tex`, and `IEEEtran.bst` is required.

```powershell
python scripts/audit_sources.py
python scripts/build_paper.py
```

The build script copies only the declared source closure to a temporary build
directory, runs `pdflatex`/`bibtex`/`pdflatex`/`pdflatex`, rejects undefined
citations or references, updates `papers/full/tina.pdf`, and writes the build
artifact to `output/pdf/tina.pdf`.

## Scope and license

The numerical work verifies or illustrates results inside the paper's
common-rate Gaussian-affine model. It does not test mixed-age architectures,
heterogeneous temporal rates, endogenous dynamics, nonlinear decision maps, or
action constraints. Code and repository content are released under the
BSD 3-Clause License. See `CITATION.cff` for citation metadata.

