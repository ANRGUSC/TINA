"""Exact common-rate Ornstein--Uhlenbeck sampling."""
from __future__ import annotations

import numpy as np


def exact_ou_pair(rng, covariance, rho, samples):
    """Stationary (theta_{t-tau}, theta_t) pair with tau/T=rho."""
    chol = np.linalg.cholesky(covariance + 1e-12 * np.eye(covariance.shape[0]))
    past = rng.standard_normal((samples, covariance.shape[0])) @ chol.T
    innovation = rng.standard_normal(past.shape) @ chol.T
    a = np.exp(-rho)
    current = a * past + np.sqrt(1.0 - a * a) * innovation
    return past, current

