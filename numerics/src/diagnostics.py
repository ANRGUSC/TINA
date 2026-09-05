"""Statistical diagnostics shared by the numerical experiments."""
from __future__ import annotations

import numpy as np


def paired_crossover_estimate(open_trials, local_trials):
    """Estimate the crossover and its paired delta-method uncertainty.

    ``open_trials`` and ``local_trials`` contain per-draw quadratic regrets
    computed from the same state draw.  The crossover estimator is the
    temporal-law inversion used by Experiment 2,

        .5 * log(R_inf / (R_inf - R_loc)).

    The delta method is applied to the joint sample mean of the two regret
    columns, retaining their sample covariance.  The returned confidence
    interval is a normal 95 percent interval and is deliberately not clipped
    so that its relationship to the estimator remains auditable.
    """
    open_trials = np.asarray(open_trials, dtype=float)
    local_trials = np.asarray(local_trials, dtype=float)
    if open_trials.ndim != 1 or local_trials.ndim != 1:
        raise ValueError("paired regret samples must be one-dimensional")
    if len(open_trials) != len(local_trials) or len(open_trials) < 2:
        raise ValueError("paired regret samples must have equal length >= 2")
    if not np.all(np.isfinite(open_trials)) or not np.all(np.isfinite(local_trials)):
        raise ValueError("paired regret samples must be finite")

    means = np.array([open_trials.mean(), local_trials.mean()], dtype=float)
    rinf, rloc = means
    if not np.isfinite(rinf) or rinf <= 0.0:
        raise ValueError("open-loop mean regret must be positive and finite")

    captured = rinf - rloc
    if not np.isfinite(captured) or captured <= 0.0:
        raise ValueError("sampled captured mean regret must be positive and finite")
    estimate = 0.5 * (np.log(rinf) - np.log(captured))
    denominator = captured
    covariance = np.cov(np.column_stack((open_trials, local_trials)), rowvar=False,
                        ddof=1)
    gradient = np.array(
        [-0.5 * rloc / (rinf * denominator), 0.5 / denominator], dtype=float
    )
    variance = float(gradient @ covariance @ gradient / len(open_trials))
    se = float(np.sqrt(max(variance, 0.0)))
    return {
        "estimate": float(estimate),
        "se": se,
        "ci_low": float(estimate - 1.96 * se),
        "ci_high": float(estimate + 1.96 * se),
        "rinf": float(rinf),
        "rloc": float(rloc),
        "captured": float(captured),
        "captured_positive": True,
        "paired_covariance": float(covariance[0, 1]),
    }
