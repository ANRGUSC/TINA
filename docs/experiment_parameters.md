# Experiment parameters and artifact provenance

The YAML files in `numerics/config` are authoritative. The table below records
the principal sweeps and outputs; all random generators use NumPy's
`default_rng` with the listed fixed seed.

| Experiment | Seed | Main sweep | Samples | Main processed artifact | Figure |
|---|---:|---|---:|---|---|
| 1 | 20260823 | `tau/T` 0--3, 25 points; systems A--D | 20,000/point | `exp01_temporal_scaling.csv` | `fig7_1_temporal_scaling` |
| 2 | 20260824 | 4 sizes x 9 `gamma/q` values | 30,000/setting | `exp02_local_global_crossover.csv` | `fig7_2_local_global_phase` |
| 3 | 20260825 | radius 0--2, 1,001 points; 3 regimes | 50,000/point | `exp03_radius_regret.csv` | `fig7_3_radius_regret` |
| 4 | 20260826 | 72 x 68 parameter grid; 2,501 radii | covariance/direct | `exp04_radius_scaling.csv` | `fig7_4_radius_phase` |
| 5 | 20260827 | decision ranges 0.7, 2, 6 on 64-node ring | 12,000 | `exp05_decision_relevance.csv` | `fig7_5_decision_relevance` |
| 6 | 20260828 | 4 graph families and comparative statics | covariance/direct | `exp06_general_graphs.csv` | `fig7_6_general_graphs` |

Raw `.npz` files preserve representative trial regrets, empirical boundaries,
covariances, graph distances, and Laplacians. Metadata JSON files preserve the
full configuration again next to run provenance and validation statistics.
The top-level manuscript figure PDFs are refreshed from the same plotting call
that writes `numerics/figures/pdf`.
