"""Finite graph constructions used in Experiments 5--6."""
from __future__ import annotations

import numpy as np
import networkx as nx


def graph_bundle(kind, n=64, seed=0):
    if kind == "path":
        graph = nx.path_graph(n)
    elif kind == "ring":
        graph = nx.cycle_graph(n)
    elif kind == "grid":
        side = int(round(np.sqrt(n)))
        graph = nx.convert_node_labels_to_integers(nx.grid_2d_graph(side, side))
    elif kind == "geometric":
        rng = np.random.default_rng(seed)
        positions = {i: rng.random(2) for i in range(n)}
        radius = 0.22
        graph = nx.random_geometric_graph(n, radius, pos=positions)
        while not nx.is_connected(graph):
            radius += 0.02
            graph = nx.random_geometric_graph(n, radius, pos=positions)
    else:
        raise ValueError(kind)
    dist = np.asarray(nx.floyd_warshall_numpy(graph), dtype=float)
    lap = nx.laplacian_matrix(graph).toarray().astype(float)
    return graph, dist, lap


def exponential_decision_operator(distances, ell_c):
    K = np.exp(-distances / ell_c)
    row_norm = np.sqrt(np.sum(K * K, axis=1, keepdims=True))
    return K / row_norm

