"""Reproduce Experiment 6 in scratch space and audit the archived results.

Run from the repository root: python scripts/verify_graph_restoration.py
The original code, configuration, data, and publication figure are not changed.
"""
from pathlib import Path
import csv
import hashlib
import json
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from numerics.experiments import run_all as experiment
from numerics.src.graph_models import graph_bundle

OUT = ROOT / "tmp/graph-restoration"
for directory in ("results/raw", "results/processed", "results/metadata"):
    (OUT / directory).mkdir(parents=True, exist_ok=True)
experiment.OUTPUT_ROOT = OUT
experiment.PAPER_FIGURES = None
experiment.configure()
result = experiment.exp06()
config = experiment.cfg(6)
archived_metadata = json.loads((ROOT / "numerics/results/metadata/exp06.json").read_text())
assert config == archived_metadata["config"]

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def compare_csv(name):
    with (ROOT / "numerics/results/processed" / name).open() as stream:
        original = list(csv.DictReader(stream))
    with (OUT / "results/processed" / name).open() as stream:
        reproduced = list(csv.DictReader(stream))
    assert len(original) == len(reproduced)
    maximum = 0.0
    for old, new in zip(original, reproduced):
        assert old.keys() == new.keys()
        for key in old:
            try:
                a, b = float(old[key]), float(new[key])
            except ValueError:
                assert old[key] == new[key], (name, key, old, new)
                continue
            if np.isnan(a):
                assert np.isnan(b)
                continue
            error = abs(a - b)
            maximum = max(maximum, error)
            assert error < 2e-11, (name, key, a, b)
    return {"rows": len(original), "max_absolute_difference": maximum}

report = {"configuration": config, "tables": {}, "graphs": {}}
for name in ("exp06_general_graphs.csv", "exp06_comparative_statics.csv"):
    report["tables"][name] = compare_csv(name)

for kind in config["graphs"]:
    name = f"exp06_{kind}_graph.npz"
    old = np.load(ROOT / "numerics/results/raw" / name)
    new = np.load(OUT / "results/raw" / name)
    assert set(old.files) == set(new.files)
    errors = {}
    for key in old.files:
        errors[key] = float(np.max(np.abs(old[key] - new[key])))
        assert errors[key] < 2e-11, (kind, key, errors[key])
    graph, distances, laplacian = graph_bundle(kind, config["n"], config["graph_seed"])
    assert len(graph) == 64
    assert np.array_equal(distances, old["distances"])
    assert np.array_equal(laplacian, old["laplacian"])
    sigma, K, radii = new["sigma"], new["decision_operator"], new["radii"]
    assert np.array_equal(radii, np.arange(int(distances.max()) + 1))
    assert np.linalg.eigvalsh(sigma).min() > 0
    assert np.allclose(np.diag(sigma).mean(), 1.0)
    assert np.allclose(np.linalg.norm(K, axis=1), 1.0)
    # Independent residual calculation: E[(Y-a^T O)^2], rather than
    # subtracting explained variance from total variance as the driver does.
    residual_eta = []
    for radius in radii:
        residual = K.copy()
        for agent in range(64):
            obs = np.flatnonzero(distances[agent] <= radius)
            weights = np.linalg.solve(sigma[np.ix_(obs, obs)], sigma[obs] @ K[agent])
            residual[agent, obs] -= weights
        residual_eta.append(float(np.trace(residual @ sigma @ residual.T)
                                  / np.trace(K @ sigma @ K.T)))
    conditioning_error = float(np.max(np.abs(residual_eta - new["eta"])))
    assert conditioning_error < 2e-12
    assert np.max(np.diff(new["eta"])) < 2e-12
    assert abs(new["eta"][-1]) < 2e-12
    regret = 1 - np.exp(-2 * config["latency_per_hop"] * radii / config["T"]) * (1 - np.array(residual_eta))
    rstar = int(radii[np.argmin(regret)])
    assert rstar == result[kind]["rstar"] == archived_metadata["results"][kind]["rstar"]
    graph_report = {"nodes": len(graph), "edges": graph.number_of_edges(),
                    "diameter": int(radii[-1]), "rstar": rstar,
                    "regret_at_optimum": float(regret[rstar]),
                    "minimum_covariance_eigenvalue": float(np.linalg.eigvalsh(sigma).min()),
                    "independent_conditioning_max_error": conditioning_error,
                    "archive_array_max_errors": errors}
    if kind == "geometric":
        positions = np.array([graph.nodes[i]["pos"] for i in range(64)])
        euclidean = np.linalg.norm(positions[:, None] - positions[None, :], axis=2)
        radius = 0.22
        import networkx as nx
        while not nx.is_connected(nx.from_numpy_array((euclidean <= radius) & (euclidean > 0))):
            radius += 0.02
        graph_report["connection_radius"] = radius
    report["graphs"][kind] = graph_report

figure = ROOT / "numerics/figures/pdf/fig7_6_general_graphs.pdf"
for folder in ("papers/full", "papers/arxiv-v2", "submissions/arxiv-v2"):
    assert digest(figure) == digest(ROOT / folder / "figures" / figure.name)
report["original_figure_sha256"] = digest(figure)
report["figure_policy"] = "Reuse original PDF bytes; regenerated numerical tables agree within floating-point tolerance."
report["reproduced_environment"] = json.loads((OUT / "results/metadata/exp06.json").read_text())["packages"]
target = ROOT / "docs/graph-restoration-verification.json"
target.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, indent=2))
