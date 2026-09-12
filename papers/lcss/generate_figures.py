#!/usr/bin/env python3
"""Reproduce the figures and numerical checks for the delayed-pooling letter.

Run: python generate_figures.py
Dependencies: numpy, scipy, matplotlib.  All random seeds are fixed below.
The simulation uses independent stationary OU pairs, not a discretized SDE.
"""

from __future__ import annotations

import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import brentq


ROOT = Path(__file__).resolve().parent
FIGURES = ROOT / "figures"
FIGURES.mkdir(exist_ok=True)
SEED = 260906351
SAMPLES = 120_000

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["DejaVu Serif"],
    "font.size": 8,
    "axes.labelsize": 8,
    "axes.titlesize": 8,
    "legend.fontsize": 6.8,
    "xtick.labelsize": 7,
    "ytick.labelsize": 7,
    "lines.linewidth": 1.45,
    "axes.linewidth": 0.6,
    "pdf.fonttype": 42,
    "ps.fonttype": 42,
    "svg.fonttype": "none",
    "mathtext.fontset": "dejavuserif",
    "savefig.dpi": 240,
})
COLORS = ["#0072B2", "#D55E00", "#009E73", "#CC79A7"]


def parameters(n: int, a: float, b: float, kappa: float) -> dict:
    v = a + b / n
    d = a + b * (1 + kappa * (1 - 1 / n))
    jl, jp = a - a * a / d, a - a * a / v
    return dict(n=n, a=a, b=b, kappa=kappa, v=v, d=d,
                J_local=jl, J_pooled=jp, Delta=jl - jp)


def block_check(n: int, a: float, b: float, kappa: float,
                rho: float, architecture: str) -> dict:
    """Solve the Gaussian team equations from full observation covariances.

    H is the strictly positive quadratic cost matrix.  For observations z_i,
    the optimality equations are
        sum_j H_ij Cov(z_i,z_j) theta_j = Cov(z_i,S).
    Their solution is checked against the claimed policy and objective.  Since
    the gradient and observations are jointly Gaussian, zero cross-covariance
    also establishes the conditional first-order conditions for all measurable
    deviations, not only for linear deviations.
    """
    p = parameters(n, a, b, kappa)
    h = (1 + kappa) * np.eye(n) - kappa * np.ones((n, n)) / n
    dimension = {"local": 1, "hybrid": 3}[architecture]
    q = np.zeros((n * dimension, n * dimension))
    rhs = np.empty(n * dimension)
    for i in range(n):
        ii = slice(dimension * i, dimension * (i + 1))
        rhs[ii] = {1: [a], 3: [a, rho * a, rho * a]}[dimension]
        for j in range(n):
            jj = slice(dimension * j, dimension * (j + 1))
            cij = a + (b if i == j else 0)
            if dimension == 1:
                cov = np.array([[cij]])
            else:
                cov = np.array([
                    [cij, rho * cij, rho * p["v"]],
                    [rho * cij, cij, p["v"]],
                    [rho * p["v"], p["v"], p["v"]],
                ])
            q[ii, jj] = h[i, j] * cov
    theta = np.linalg.solve(q, rhs)
    z = rho * rho
    single_policy = {
        1: [a / p["d"]],
        3: [a / p["d"], -rho * a / p["d"], rho * a / p["v"]],
    }[dimension]
    claimed_theta = np.tile(single_policy, n)
    objective = a - 2 * rhs @ theta / n + theta @ q @ theta / n
    claimed_objective = {
        1: p["J_local"],
        3: p["J_local"] - p["Delta"] * z,
    }[dimension]
    return {
        "architecture": architecture, "n": n, "a": a, "b": b,
        "kappa": kappa, "rho": rho,
        "max_coefficient_error": float(np.max(np.abs(theta - claimed_theta))),
        "conditional_normal_equation_residual": float(
            np.max(np.abs(q @ claimed_theta - rhs))),
        "computed_objective": float(objective),
        "formula_objective": float(claimed_objective),
        "objective_error": float(abs(objective - claimed_objective)),
        "minimum_quadratic_eigenvalue": float(np.linalg.eigvalsh(q)[0]),
    }


def monte_carlo(p: dict, age: float, rng: np.random.Generator) -> dict:
    n, a, b, kappa = (p[k] for k in ("n", "a", "b", "kappa"))
    rho = np.exp(-age)
    s0 = np.sqrt(a) * rng.standard_normal((SAMPLES, 1))
    e0 = np.sqrt(b) * rng.standard_normal((SAMPLES, n))
    st = rho * s0 + np.sqrt(a * (1 - rho * rho)) * rng.standard_normal((SAMPLES, 1))
    et = rho * e0 + np.sqrt(b * (1 - rho * rho)) * rng.standard_normal((SAMPLES, n))
    y0, yt = s0 + e0, st + et
    ul = (a / p["d"]) * yt
    uh = rho * (a / p["v"]) * y0.mean(axis=1, keepdims=True) + (
        a / p["d"]) * (yt - rho * y0)
    up = (a / p["v"]) * yt.mean(axis=1, keepdims=True)
    ud = rho * (a / p["v"]) * y0.mean(axis=1, keepdims=True)

    def sample_cost(u):
        return ((u - st)**2).mean(axis=1) + kappa * (
            (u - u.mean(axis=1, keepdims=True))**2).mean(axis=1)

    ll, lh, lp, ld = (sample_cost(u) for u in (ul, uh, up, ud))
    gain = ll - lh
    exact_h = p["J_local"] - p["Delta"] * rho * rho
    exact_d = a - a * a / p["v"] * rho * rho
    def mean_se(x):
        return {"mean": float(x.mean()), "standard_error": float(x.std(ddof=1) / np.sqrt(SAMPLES))}
    out = {"lambda_age": age, "rho": float(rho), "samples": SAMPLES,
           "hybrid": mean_se(lh), "local": mean_se(ll), "pooled": mean_se(lp),
           "delayed_pool_only": mean_se(ld),
           "gain": mean_se(gain), "hybrid_exact": float(exact_h),
           "delayed_pool_only_exact": float(exact_d),
           "normalized_gain_exact": float(rho * rho)}
    out["normalized_gain"] = out["gain"]["mean"] / p["Delta"]
    out["normalized_gain_standard_error"] = out["gain"]["standard_error"] / p["Delta"]
    out["hybrid_standardized_error"] = (out["hybrid"]["mean"] - exact_h) / out["hybrid"]["standard_error"]
    out["delayed_pool_only_standardized_error"] = (
        out["delayed_pool_only"]["mean"] - exact_d) / out["delayed_pool_only"]["standard_error"]
    return out


def style_axes(ax):
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(axis="y", color="0.88", linewidth=0.5)
    ax.set_axisbelow(True)


def save_figure(fig, name):
    for extension in ("pdf", "svg", "png"):
        fig.savefig(FIGURES / f"{name}.{extension}")
    plt.close(fig)


def refresh_cost(t, jl, amplitudes, rates, c):
    t = np.asarray(t)
    rewards = (amplitudes[:, None] * (-np.expm1(-2 * rates[:, None] * t)) /
               (2 * rates[:, None])).sum(axis=0)
    return jl + (c - rewards) / t


def optimum_refresh(amplitudes, rates, c):
    ccrit = float(np.sum(amplitudes / (2 * rates)))
    if c >= ccrit:
        return None
    def residual(t):
        z = 2 * rates * t
        # expm1 preserves the small-z difference before subtracting z exp(-z).
        return float(np.sum(amplitudes * (-np.expm1(-z) - z * np.exp(-z)) /
                            (2 * rates)) - c)
    right = 1 / float(np.min(rates))
    while residual(right) < 0:
        right *= 2
    return float(brentq(residual, 1e-12, right, xtol=1e-13))


def main():
    rng = np.random.default_rng(SEED)
    checks = []
    for _ in range(40):
        n = int(rng.integers(2, 13))
        a, b = 10 ** rng.uniform(-1, 1, 2)
        kappa = float(10 ** rng.uniform(-2, 1.5))
        rho = float(rng.uniform(0.01, 0.98))
        for architecture in ("local", "hybrid"):
            checks.append(block_check(n, float(a), float(b), kappa, rho, architecture))
    # Include coordination-free teams and a nearly fresh snapshot explicitly.
    for rho in (0, 0.5, 0.999):
        checks.append(block_check(8, 1, 1, 0, rho, "hybrid"))
    summary = {
        "number_of_linear_systems": len(checks),
        "maximum_coefficient_error": max(c["max_coefficient_error"] for c in checks),
        "maximum_conditional_normal_equation_residual": max(c["conditional_normal_equation_residual"] for c in checks),
        "maximum_objective_error": max(c["objective_error"] for c in checks),
        "all_quadratic_matrices_positive_definite": all(c["minimum_quadratic_eigenvalue"] > 0 for c in checks),
    }
    assert summary["maximum_coefficient_error"] < 1e-9
    assert summary["maximum_conditional_normal_equation_residual"] < 1e-10
    assert summary["maximum_objective_error"] < 1e-10
    assert summary["all_quadratic_matrices_positive_definite"]

    base = parameters(8, 1, 1, 1)
    configs = [base, parameters(2, 1, 1, 0), parameters(32, 1, 1, 4)]
    age_grids = [[0, .25, .5, .75, 1, 1.5, 2, 2.5],
                 [.1, .35, .6, .9, 1.25, 1.75, 2.25],
                 [.18, .43, .68, 1.08, 1.4, 1.9, 2.4]]
    simulations = [{"parameters": p, "points": [monte_carlo(p, x, rng) for x in ages]}
                   for p, ages in zip(configs, age_grids)]
    fig, axs = plt.subplots(2, 1, figsize=(3.42, 3.35), sharex=True)
    fig.subplots_adjust(left=.17, right=.975, top=.97, bottom=.12, hspace=.16)
    x = np.linspace(0, 2.5, 400)
    ax = axs[0]
    ax.axhline(base["J_local"], color="0.3", linestyle="--", linewidth=1.1, label="Fresh local")
    ax.plot(x, base["J_local"] - base["Delta"] * np.exp(-2 * x), color=COLORS[0], label="Hybrid")
    ax.axhline(base["J_pooled"], color=COLORS[2], linestyle=":", linewidth=1.5, label="Fresh pooled")
    z = np.exp(-2 * x)
    delayed_pool_only = base["a"] - base["a"]**2 / base["v"] * z
    ax.plot(x, delayed_pool_only, color=COLORS[1], linestyle="--", linewidth=1.2,
            label="Delayed pool only")
    points = simulations[0]["points"]
    ax.errorbar([r["lambda_age"] for r in points], [r["hybrid"]["mean"] for r in points],
                yerr=[1.96 * r["hybrid"]["standard_error"] for r in points],
                fmt="o", color=COLORS[0], markerfacecolor="white", markersize=3.3,
                markeredgewidth=.8, elinewidth=.7, capsize=1.6, label="Monte Carlo")
    ax.errorbar([r["lambda_age"] for r in points],
                [r["delayed_pool_only"]["mean"] for r in points],
                yerr=[1.96 * r["delayed_pool_only"]["standard_error"] for r in points],
                fmt="s", color=COLORS[1], markerfacecolor="white", markersize=3.0,
                markeredgewidth=.8, elinewidth=.7, capsize=1.6)
    crossover_age = .5 * float(np.log(base["d"] / base["v"]))
    ax.plot(crossover_age, base["J_local"], "o", color="0.2", markersize=3.3)
    ax.annotate(r"$\lambda\tau_{\mathrm{cross}}$", xy=(crossover_age, base["J_local"]),
                xytext=(.29, .78), fontsize=7, ha="center",
                arrowprops={"arrowstyle": "-", "color": "0.35", "lw": .6})
    ax.set_ylim(.065, 1.04)
    ax.set_yticks([.1, .4, .7, 1])
    ax.set_ylabel("Expected loss")
    ax.text(.96, .79, r"$n=8,\ \kappa=1$", transform=ax.transAxes, ha="right", fontsize=7)
    ax.legend(loc="lower right", bbox_to_anchor=(1.01, .07), frameon=False, ncol=1,
              handlelength=1.8, borderaxespad=.15, labelspacing=.22, fontsize=6.4)
    ax.text(.03, .87, "(a)", transform=ax.transAxes)
    ax = axs[1]
    ax.plot(x, np.exp(-2 * x), color="0.2", linewidth=1.2, label=r"$e^{-2\lambda\tau}$")
    for sim, marker, color in zip(simulations, ["o", "s", "^"], COLORS):
        p, points = sim["parameters"], sim["points"]
        ax.errorbar([r["lambda_age"] for r in points], [r["normalized_gain"] for r in points],
                    yerr=[1.96 * r["normalized_gain_standard_error"] for r in points],
                    fmt=marker, color=color, markerfacecolor="white", markersize=3.2,
                    markeredgewidth=.8, elinewidth=.6, capsize=1.3,
                    label=fr'$n={p["n"]},\ \kappa={p["kappa"]}$')
    ax.set_ylabel("Fraction of fresh gain")
    ax.set_xlabel(r"Snapshot age $\lambda\tau$")
    ax.set_yticks([0, .5, 1])
    ax.set_ylim(-.04, 1.06)
    ax.set_xlim(0, 2.5)
    ax.text(.03, .10, "(b)", transform=ax.transAxes)
    ax.legend(loc="upper right", frameon=False, handlelength=1.8, borderaxespad=.15,
              labelspacing=.28)
    for ax in axs:
        style_axes(ax)
    save_figure(fig, "pooling_decay")

    rates = np.array([1.0])
    latency = .1
    amplitudes = np.array([base["Delta"] * np.exp(-2 * rates[0] * latency)])
    ccrit = float(np.sum(amplitudes / (2 * rates)))
    refresh_results = []
    fig, ax = plt.subplots(figsize=(3.42, 2.62))
    fig.subplots_adjust(left=.17, right=.975, top=.965, bottom=.17)
    t = np.linspace(.035, 5, 1600)
    ax.axhline(base["J_local"], color="0.35", linewidth=1, linestyle="--", label="No refresh")
    for ratio, color in zip([.1, .5, .9, 1.1], COLORS):
        c = ratio * ccrit
        costs = refresh_cost(t, base["J_local"], amplitudes, rates, c)
        ax.plot(t, costs, color=color, label=fr"$c/c_{{\rm crit}}={ratio:g}$")
        optimum = optimum_refresh(amplitudes, rates, c)
        result = {"cost_ratio": ratio, "cost_per_refresh": c, "optimal_period": optimum}
        if optimum is not None:
            minimum = float(refresh_cost([optimum], base["J_local"], amplitudes, rates, c)[0])
            ax.plot(optimum, minimum, "o", markersize=4.2, color=color,
                    markeredgecolor="black", markeredgewidth=.45)
            result["minimum_average_cost"] = minimum
            result["optimality_equation_residual"] = float(abs(c - np.sum(
                amplitudes * (1 - (1 + 2 * rates * optimum) * np.exp(-2 * rates * optimum)) / (2 * rates))))
            step = 1e-4
            neighbor_costs = refresh_cost([optimum * (1 - step), optimum * (1 + step)],
                                          base["J_local"], amplitudes, rates, c)
            assert np.all(neighbor_costs >= minimum - 1e-12)
        else:
            result["minimum_average_cost"] = base["J_local"]
            assert np.all(costs > base["J_local"])
        refresh_results.append(result)
    ax.set_xlim(0, 5)
    ax.set_ylim(.35, .85)
    ax.set_yticks([.4, .5, .6, .7, .8])
    ax.set_xlabel(r"Refresh period $\lambda T$")
    ax.set_ylabel("Loss plus communication cost")
    ax.legend(loc="upper right", frameon=False, ncol=2, columnspacing=.6,
              handlelength=1.5, labelspacing=.32, borderaxespad=.15)
    ax.text(.98, .09, r"$\lambda\delta=0.1$", transform=ax.transAxes, ha="right", fontsize=7)
    style_axes(ax)
    save_figure(fig, "refresh_cost")

    # Check the multirate implementation with two independent modes.
    second = parameters(8, .4, .8, 1)
    multi_rates = np.array([1., .12])
    multi_amplitudes = np.array([base["Delta"], second["Delta"]]) * np.exp(-2 * multi_rates * latency)
    multi_threshold = float(np.sum(multi_amplitudes / (2 * multi_rates)))
    multi_c = .5 * multi_threshold
    multi_optimum = optimum_refresh(multi_amplitudes, multi_rates, multi_c)
    multi_jl = base["J_local"] + second["J_local"]
    multi_min = float(refresh_cost([multi_optimum], multi_jl, multi_amplitudes, multi_rates, multi_c)[0])
    multi_closed_min = float(multi_jl - np.sum(multi_amplitudes * np.exp(-2 * multi_rates * multi_optimum)))
    assert abs(multi_min - multi_closed_min) < 1e-12

    verification = {
        "seed": SEED,
        "model": "Independent stationary Gaussian common and local OU components; all single-mode rates equal lambda.",
        "baseline": base,
        "gaussian_team_checks_summary": summary,
        "gaussian_team_checks": checks,
        "monte_carlo_samples_per_point": SAMPLES,
        "monte_carlo": simulations,
        "maximum_absolute_hybrid_monte_carlo_z_score": max(
            abs(r["hybrid_standardized_error"]) for sim in simulations for r in sim["points"]),
        "maximum_absolute_delayed_pool_only_monte_carlo_z_score": max(
            abs(r["delayed_pool_only_standardized_error"])
            for sim in simulations for r in sim["points"]),
        "delayed_pool_crossover": {
            "lambda_age": crossover_age,
            "formula": "lambda*tau_cross = log(d/v)/2",
            "cost_at_crossover": base["J_local"],
            "objective_equality_error": abs(base["a"] - base["a"]**2 /
                base["v"] * np.exp(-2 * crossover_age) - base["J_local"]),
            "fresh_local_better_for": "lambda*age > lambda*tau_cross",
        },
        "costs_at_lambda_age_1": {
            "fresh_local": base["J_local"],
            "fresh_pooled": base["J_pooled"],
            "hybrid": float(base["J_local"] - base["Delta"] * np.exp(-2)),
            "delayed_pool_only": float(base["a"] - base["a"]**2 / base["v"] * np.exp(-2)),
        },
        "refresh": {"lambda": 1, "latency": latency, "A": float(amplitudes[0]),
                    "critical_refresh_cost": ccrit, "scenarios": refresh_results},
        "multirate_check": {"rates": multi_rates.tolist(), "latency": latency,
                            "amplitudes": multi_amplitudes.tolist(),
                            "critical_refresh_cost": multi_threshold, "refresh_cost": multi_c,
                            "optimal_period": multi_optimum, "minimum_average_cost": multi_min,
                            "closed_form_minimum_error": abs(multi_min - multi_closed_min)},
    }
    (ROOT / "verification.json").write_text(json.dumps(verification, indent=2) + "\n")
    print(json.dumps({"baseline": base, "gaussian_team_checks": summary,
                      "maximum_absolute_hybrid_monte_carlo_z_score": verification["maximum_absolute_hybrid_monte_carlo_z_score"],
                      "maximum_absolute_delayed_pool_only_monte_carlo_z_score": verification["maximum_absolute_delayed_pool_only_monte_carlo_z_score"],
                      "delayed_pool_crossover": verification["delayed_pool_crossover"],
                      "costs_at_lambda_age_1": verification["costs_at_lambda_age_1"],
                      "refresh": verification["refresh"], "multirate_check": verification["multirate_check"]}, indent=2))


if __name__ == "__main__":
    main()
