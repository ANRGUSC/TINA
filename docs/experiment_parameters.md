# Experiment parameters and artifact provenance

The YAML files in `numerics/config` are authoritative.  All random generators
use NumPy's `default_rng` with the fixed seed shown below.  Values described as
comparative-statistic sweeps are the configured sample points, not continuous
claims.

| Experiment | Seed | Primary sweep | Fixed design / size | Evaluation | Main processed output | Figure |
|---|---:|---|---|---|---|---|
| 1. Temporal scaling | 20260823 | `rho=tau/T`: 0--3, 25 points | systems A--D; `n=8,20,50,32` | 20,000 exact stationary pairs/point | `exp01_temporal_scaling.csv` | `fig7_1_temporal_scaling` |
| 2. Local/global crossover | 20260824 | 9 `gamma/q` values in 0--10 | `n=5,10,25,100`; `q=1` | 30,000 paired current-state draws/setting | `exp02_local_global_crossover.csv` | `fig7_2_local_global_phase` |
| 3. Radius regret | 20260825 | `r/ell_c`: 0--2, 1,001 points | three configured regimes; cap `D/ell_c=2` | 50,000 scalar innovation draws/point | `exp03_radius_regret.csv` | `fig7_3_radius_regret` |
| 4. Radius scaling | 20260826 | 72 x 68 log-spaced `(vT/ell_c, ell_s/ell_c)` grid | fixed `r/ell_c` grid 0--4; 2,501 points, step 0.0016 | direct scalar minimization | `exp04_radius_scaling.csv` | `fig7_4_radius_phase` |
| 5. Decision relevance | 20260827 | `ell_c=0.7,2,6` | one 64-node ring; `T=6`, latency 0.12/hop | exact conditioning plus 12,000-draw checks | `exp05_decision_relevance.csv` | `fig7_5_decision_relevance` |
| 6. General graphs | 20260828 | path, ring, grid, geometric; configured T, `ell_c`, latency, and `kappa_s` sweeps | one 64-node graph of each type; reference `T=5`, `ell_c=2`, latency 0.12/hop | exact integer-radius conditioning | `exp06_general_graphs.csv` | `fig7_6_general_graphs` |

The graph covariances in Experiments 5--6 are built from the graph Laplacian
and scaled to average marginal variance one.  Path, ring, and grid instances
are deterministic; the random-geometric instance uses the fixed graph seed
derived from the Experiment 6 seed.  Experiment 1 archives its three selected
trial slices and its system matrices.  Experiment 2 archives the paired
boundary estimates.  Experiments 5--6 archive the covariance, distance, and
Laplacian inputs, and Experiment 6 also archives the exact radius curves and
neighboring-regret diagnostics.  These are selected audit artifacts, not a
complete archive of every Monte Carlo draw.

## Artifact map

- `results/processed` contains tidy experiment tables, including
  `exp05_mc_checks.csv` and `exp06_comparative_statics.csv`.
- `results/raw` contains selected trial/boundary arrays, system matrices, and
  graph inputs/curves where applicable.
- `results/metadata` contains the seed, configuration, timestamp, runtime,
  package versions, matrix diagnostics, and headline checks.  The reference
  run also records the robustness Monte Carlo summary.
- `figures/pdf` and `figures/png` contain the generated publication figures;
  `figures/supplementary/mc_convergence.pdf` is the Monte Carlo convergence
  diagnostic.
- `latex` contains the synchronized numerical-section extract, figure environments,
  and parameter table.

Running `python numerics/experiments/run_all.py` refreshes the numerical outputs
and the top-level manuscript PDFs.  Add `--output-root tmp/reproduction
--no-paper-copy` for a clean comparison run that leaves archived outputs and
top-level figures unchanged.  The standalone drivers in
`numerics/experiments/exp0*.py` call the corresponding functions from
`run_all.py`.
