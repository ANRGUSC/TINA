# TINA

This repository contains the manuscript and complete reproduction package for
**A Theory of Information Architecture for Networked Decisions: Freshness,
Locality, and Coordination**, by Scott Moeller and Bhaskar Krishnamachari.

The paper studies decision-relevant information scope and freshness in an
exogenously evolving quadratic static-team model. Its principal design family
uses synchronized neighborhood snapshots: a broader snapshot arrives at a
greater age. The repository includes the exact manuscript inputs, archived raw
and processed numerical results, and deterministic build/test entry points.

## Repository map

- `main.tex`, `references.bib`: canonical manuscript sources.
- `figures/`: the six PDF figures consumed by `main.tex`.
- `tina.pdf`: canonical compiled preprint.
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
by `main.tex`, and `IEEEtran.bst` is required.

```powershell
python scripts/audit_sources.py
python scripts/build_paper.py
```

The build script copies only the declared source closure to a temporary build
directory, runs `pdflatex`/`bibtex`/`pdflatex`/`pdflatex`, rejects undefined
citations or references, and writes `output/pdf/tina.pdf`.

## Scope and license

The numerical work verifies or illustrates results inside the paper's
common-rate Gaussian-affine model. It does not test mixed-age architectures,
heterogeneous temporal rates, endogenous dynamics, nonlinear decision maps, or
action constraints. Code and repository content are released under the
BSD 3-Clause License. See `CITATION.cff` for citation metadata.
