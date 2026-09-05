# Numerical consistency checks and finite-graph illustrations

This directory reproduces the synthetic consistency checks and finite-graph
illustrations integrated into `main.tex`.  The common environment is exogenous:
actions do not change later states.  Experiment-specific parameters and artifact
provenance are listed in [`docs/experiment_parameters.md`](../docs/experiment_parameters.md);
the estimators, safeguards, and acceptance checks are specified in
[`docs/numerical_method.md`](../docs/numerical_method.md).

## Setup

From the repository root:

```bash
python -m venv .venv
source .venv/bin/activate  # Windows PowerShell: .venv\Scripts\Activate.ps1
python -m pip install -r requirements-lock.txt
```

The final reference run used Python 3.12.12 on macOS with NumPy 2.4.3,
SciPy 1.17.1, Matplotlib 3.10.8, NetworkX 3.6.1, and PyYAML 6.0.3.  An
earlier Windows run used Python 3.12.10; its metadata remains in Git history.
Package and platform details
are recorded in each metadata JSON file.

## Reproduction

To regenerate the archived numerical tables and figures in place:

```bash
python numerics/experiments/run_all.py
```

For a clean comparison run that leaves archived outputs and top-level
manuscript figures unchanged:

```bash
python numerics/experiments/run_all.py --output-root tmp/reproduction --no-paper-copy
```

The six standalone drivers are entry points into `run_all.py`:

```bash
python numerics/experiments/exp01_temporal_scaling.py
python numerics/experiments/exp02_local_global_crossover.py
python numerics/experiments/exp03_radius_regret.py
python numerics/experiments/exp04_radius_scaling.py
python numerics/experiments/exp05_decision_relevance.py
python numerics/experiments/exp06_general_graphs.py
```

## Output structure

- `results/processed`: tidy experiment curves, estimates, standard errors,
  intervals, radius errors, and comparative-statistic tables.  Experiment 2
  separates omission/captured shares; Experiment 5 writes `exp05_mc_checks.csv`;
  Experiment 6 writes neighboring-regret diagnostics.
- `results/raw`: selected trial and inferred-boundary arrays, Experiment 1
  system matrices, and graph covariance/distance/Laplacian inputs and curves
  where applicable.  This is an audit subset, not a complete archive of every
  random draw.
- `results/metadata`: seed, configuration, timestamp, package versions,
  runtime, matrix diagnostics, and headline checks.  The reference run also
  records the Monte Carlo robustness summary.
- `figures/pdf` and `figures/png`: publication PDFs and 350-dpi PNGs;
  `figures/supplementary/mc_convergence.pdf` is the convergence diagnostic.
- `latex`: the synchronized numerical-section extract, figure environments, and
  parameter table.
- `../figures`: top-level copies of the PDFs cited by `main.tex`; these are
  refreshed unless `--no-paper-copy` is supplied.

## Figure provenance

| Figure | Driver | Config | Processed data | PDF / PNG |
|---|---|---|---|---|
| 7.1 | `exp01_temporal_scaling.py` | `experiment_01.yaml` | `exp01_temporal_scaling.csv` | `fig7_1_temporal_scaling.pdf/.png` |
| 7.2 | `exp02_local_global_crossover.py` | `experiment_02.yaml` | `exp02_local_global_crossover.csv` | `fig7_2_local_global_phase.pdf/.png` |
| 7.3 | `exp03_radius_regret.py` | `experiment_03.yaml` | `exp03_radius_regret.csv` | `fig7_3_radius_regret.pdf/.png` |
| 7.4 | `exp04_radius_scaling.py` | `experiment_04.yaml` | `exp04_radius_scaling.csv` | `fig7_4_radius_phase.pdf/.png` |
| 7.5 | `exp05_decision_relevance.py` | `experiment_05.yaml` | `exp05_decision_relevance.csv`, `exp05_mc_checks.csv` | `fig7_5_decision_relevance.pdf/.png` |
| 7.6 | `exp06_general_graphs.py` | `experiment_06.yaml` | `exp06_general_graphs.csv`, `exp06_comparative_statics.csv` | `fig7_6_general_graphs.pdf/.png` |

The generated Figure 2 includes exact curves, visible paired Monte Carlo
crosses with delta-method intervals, and a boundary-residual panel.  Figure 4
uses a fixed 0--4 scalar radius grid, separates the numerical zero region, and
shows selected slices plus a grid-step residual diagnostic.  Figure 5 keeps
raw state correlation separate from decision-weighted omission, and Figure 6
marks sampled integer optima without implying fractional transition locations.

After editing the numerical section in `main.tex`, run
`python scripts/sync_numerical_latex.py` to refresh its standalone TeX extracts;
`--check` verifies synchronization without writing. Historical `fig7_*` and
`section7.tex` filenames are retained, although the section number is assigned
automatically by the manuscript.
