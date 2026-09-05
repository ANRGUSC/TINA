"""Exact common-rate Ornstein--Uhlenbeck sampling."""
from __future__ import annotations

import numpy as np


def exact_ou_pair(rng, covariance, rho, samples):
    """Stationary (theta_{t-tau}, theta_t) pair with tau/T=rho."""
    covariance = np.asarray(covariance, dtype=float)
    if covariance.ndim != 2 or covariance.shape[0] != covariance.shape[1]:
        raise ValueError("covariance must be a square matrix")
    if not np.all(np.isfinite(covariance)):
        raise ValueError("covariance must contain only finite values")
    if not np.isfinite(rho) or rho < 0:
        raise ValueError("rho must be a finite nonnegative number")
    if not isinstance(samples, (int, np.integer)) or samples < 1:
        raise ValueError("samples must be a positive integer")

    # The reference covariances are strictly positive definite.  Do not add a
    # silent diagonal jitter here: it changes both stationary marginals and
    # the innovation covariance, masking an invalid covariance construction.
    symmetric_covariance = (covariance + covariance.T) / 2.0
    chol = np.linalg.cholesky(symmetric_covariance)
    past = rng.standard_normal((samples, covariance.shape[0])) @ chol.T
    innovation = rng.standard_normal(past.shape) @ chol.T
    a = np.exp(-rho)
    # expm1 retains precision for very small positive delays, while the
    # rho=0 case still gives current == past exactly.
    innovation_scale = np.sqrt(-np.expm1(-2.0 * rho))
    current = a * past + innovation_scale * innovation
    return past, current
