"""Analytical and Monte Carlo regret estimators."""
from __future__ import annotations

import numpy as np


def affine_rinf(Q, B, sigma):
    return 0.5 * np.trace(B.T @ np.linalg.solve(Q, B) @ sigma)


def mc_quadratic_regret(errors, Q):
    trial = 0.5 * np.einsum("bi,ij,bj->b", errors, Q, errors)
    mean = float(trial.mean())
    se = float(trial.std(ddof=1) / np.sqrt(len(trial)))
    return mean, se, trial

