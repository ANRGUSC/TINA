"""Gaussian optimal prediction policies."""
from __future__ import annotations

import numpy as np


def gaussian_linear_predictor(cov_y_obs, cov_obs):
    return np.linalg.solve(cov_obs, cov_y_obs).T

