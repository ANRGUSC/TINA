"""Closed-form predictions used in the manuscript."""
from __future__ import annotations

import numpy as np


def temporal_fraction(rho):
    return 1.0 - np.exp(-2.0 * np.asarray(rho, dtype=float))


def aggregate_eta_local(gamma, n, q=1.0):
    gamma = np.asarray(gamma, dtype=float)
    return q * (q + gamma * n) / ((q + gamma) * (q + gamma * (n - 1)))


def aggregate_threshold(gamma, n, q=1.0):
    return 0.5 * np.log(1.0 / aggregate_eta_local(gamma, n, q))


def canonical_eta(radius, ell_s, ell_c):
    radius = np.asarray(radius, dtype=float)
    return ell_c / (ell_c + 2.0 * ell_s) * np.exp(-2.0 * radius / ell_c)


def composed_regret(radius, ell_s, ell_c, propagation_length):
    radius = np.asarray(radius, dtype=float)
    return 1.0 - np.exp(-2.0 * radius / propagation_length) * (
        1.0 - canonical_eta(radius, ell_s, ell_c)
    )


def canonical_rstar(ell_s, ell_c, propagation_length):
    value = 0.5 * ell_c * np.log(
        (ell_c + propagation_length) / (ell_c + 2.0 * ell_s)
    )
    return np.maximum(value, 0.0)

