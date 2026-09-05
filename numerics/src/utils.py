"""I/O and provenance helpers."""
from __future__ import annotations

import csv
import json
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import matplotlib
import networkx
import numpy
import scipy
import yaml


def load_yaml(path):
    with open(path, encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def sample_mean_ci(values, confidence_z=1.96):
    """Return a sample mean, normal standard error, and confidence interval.

    The input is the per-draw quantity whose expectation is being estimated,
    rather than a pre-normalized aggregate.  Keeping the sample moments at
    this level avoids silently treating a sampled denominator as exact.
    """
    values = numpy.asarray(values, dtype=float).reshape(-1)
    if values.size < 2:
        raise ValueError("at least two draws are required for a sample SE")
    if not numpy.all(numpy.isfinite(values)):
        raise ValueError("sample values must be finite")
    mean = float(values.mean())
    se = float(values.std(ddof=1) / numpy.sqrt(values.size))
    margin = float(confidence_z * se)
    return mean, se, mean - margin, mean + margin


def write_csv(path, rows):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = list(rows)
    if not rows:
        return
    with open(path, "w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def write_json(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2)


def metadata(seed, samples, config, runtime_seconds):
    try:
        commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True, stderr=subprocess.DEVNULL
        ).strip()
    except Exception:
        commit = None
    return {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "seed": seed,
        "monte_carlo_samples": samples,
        "runtime_seconds": runtime_seconds,
        "git_commit": commit,
        "platform": platform.platform(),
        "python": sys.version,
        "packages": {
            "numpy": numpy.__version__, "scipy": scipy.__version__,
            "matplotlib": matplotlib.__version__, "networkx": networkx.__version__,
        },
        "config": config,
    }
