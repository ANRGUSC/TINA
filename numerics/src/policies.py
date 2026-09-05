"""Gaussian optimal prediction policies."""
from __future__ import annotations

import numpy as np


def gaussian_linear_predictor(cov_y_obs, cov_obs):
    """Return coefficients for ``E[Y | O]`` under zero-mean joint Gaussianity.

    ``cov_y_obs`` is target-by-observation, with shape ``(targets,
    observations)`` (or a one-dimensional observation covariance row for a
    scalar target).  Solving against its transpose is important: the
    observation covariance is square, while the cross-covariance need not be.
    """
    cov_obs = np.asarray(cov_obs, dtype=float)
    cross = np.asarray(cov_y_obs, dtype=float)
    if cov_obs.ndim != 2 or cov_obs.shape[0] != cov_obs.shape[1]:
        raise ValueError("cov_obs must be a square matrix")
    observations = cov_obs.shape[0]
    if cross.ndim == 1:
        if cross.shape[0] != observations:
            raise ValueError("cross-covariance has the wrong observation dimension")
        return np.linalg.solve(cov_obs, cross)
    if cross.ndim != 2 or cross.shape[1] != observations:
        raise ValueError(
            "cov_y_obs must have shape (targets, observations)"
        )
    return np.linalg.solve(cov_obs, cross.T).T
