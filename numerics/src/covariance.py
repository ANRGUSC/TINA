"""Gaussian conditioning and covariance utilities."""
from __future__ import annotations

import numpy as np
from scipy.linalg import eigh


def psd_power_covariance(laplacian, kappa=0.8, nu=1.5, sigma2=1.0):
    vals, vecs = eigh(kappa * kappa * np.eye(laplacian.shape[0]) + laplacian)
    cov = (vecs * vals ** (-nu)) @ vecs.T
    cov *= sigma2 / np.mean(np.diag(cov))
    return (cov + cov.T) / 2.0


def conditional_variance_scalar(cov_y, cov_obs, cov_y_obs):
    if len(cov_obs) == 0:
        return float(cov_y)
    sol = np.linalg.solve(cov_obs, cov_y_obs)
    return max(float(cov_y - cov_y_obs @ sol), 0.0)


def architecture_eta(sigma, K, distances, radius):
    """Normalized Q=I regret for row-wise neighborhood observations."""
    total = float(np.trace(K @ sigma @ K.T))
    omitted = 0.0
    for i in range(K.shape[0]):
        obs = np.flatnonzero(distances[i] <= radius + 1e-12)
        ky = K[i]
        cov_y = float(ky @ sigma @ ky)
        cov_y_obs = ky @ sigma[:, obs]
        omitted += conditional_variance_scalar(
            cov_y, sigma[np.ix_(obs, obs)], cov_y_obs
        )
    return omitted / total


def check_psd(matrix, tol=1e-9):
    eig = np.linalg.eigvalsh((matrix + matrix.T) / 2.0)
    return float(eig.min()), bool(eig.min() >= -tol)

