# Section 7 numerical evaluation

This directory reproduces the synthetic numerical evaluation integrated into
`main.tex`. The repository-level README and `docs/` directory define the full
clean-room workflow and numerical acceptance thresholds.

## Setup

From the repository root:

```bash
python -m venv .venv
.venv/Scripts/activate
python -m pip install -r requirements-lock.txt
```

The reference run used Python 3.12.10, NumPy 2.4.3, SciPy 1.17.1,
Matplotlib 3.10.8, NetworkX 3.6.1, and PyYAML 6.0.3 on Windows.

## Reproduction

```bash
python numerics/experiments/run_all.py
```

To write a clean comparison run without changing the archived artifacts or
top-level manuscript figures:

```bash
python numerics/experiments/run_all.py --output-root tmp/reproduction --no-paper-copy
```

The final reference run, including supplemental comparative-static checks,
completed in 50.4 seconds on the same machine. Seeds and all configurations are stored in
`numerics/config`. The principal reference seeds are 20260823--20260828.

## Individual experiments

```bash
python numerics/experiments/exp01_temporal_scaling.py
python numerics/experiments/exp02_local_global_crossover.py
python numerics/experiments/exp03_radius_regret.py
python numerics/experiments/exp04_radius_scaling.py
python numerics/experiments/exp05_decision_relevance.py
python numerics/experiments/exp06_general_graphs.py
```

## Output structure

- `results/raw`: trial arrays, graph distances/Laplacians, and covariances.
- `results/processed`: tidy CSV results, estimates, standard errors, and sweeps.
- `results/metadata`: seed, configuration, timestamp, package versions, runtime,
  optional git hash, diagnostics, and headline statistics.
- `figures/pdf` and `figures/png`: publication PDFs and 350-dpi PNGs.
- `figures/supplementary`: Monte Carlo convergence diagnostics.
- `latex`: the integrated section, complete figure environments, and parameter
  table.
- `../figures`: arXiv-ready copies of every PDF figure cited by `main.tex`;
  these are refreshed automatically by the experiment scripts.

## Figure provenance

| Figure | Script | Config | Processed data | PDF / PNG |
|---|---|---|---|---|
| 7.1 | `exp01_temporal_scaling.py` | `experiment_01.yaml` | `exp01_temporal_scaling.csv` | `fig7_1_temporal_scaling.pdf/.png` |
| 7.2 | `exp02_local_global_crossover.py` | `experiment_02.yaml` | `exp02_local_global_crossover.csv` | `fig7_2_local_global_phase.pdf/.png` |
| 7.3 | `exp03_radius_regret.py` | `experiment_03.yaml` | `exp03_radius_regret.csv` | `fig7_3_radius_regret.pdf/.png` |
| 7.4 | `exp04_radius_scaling.py` | `experiment_04.yaml` | `exp04_radius_scaling.csv` | `fig7_4_radius_phase.pdf/.png` |
| 7.5 | `exp05_decision_relevance.py` | `experiment_05.yaml` | `exp05_decision_relevance.csv` | `fig7_5_decision_relevance.pdf/.png` |
| 7.6 | `exp06_general_graphs.py` | `experiment_06.yaml` | `exp06_general_graphs.csv` | `fig7_6_general_graphs.pdf/.png` |

All paths in the table are relative to their corresponding `numerics`
subdirectory. The process is exogenous throughout: no simulated action changes
the future state law.
