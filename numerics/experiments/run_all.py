"""Run all six experiments and regenerate the numerical-section artifacts."""
from __future__ import annotations

import json
import argparse
import sys
import time
from pathlib import Path

SOURCE_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = SOURCE_ROOT
REPO = SOURCE_ROOT.parent
PAPER_FIGURES = REPO / "figures"
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

import matplotlib.pyplot as plt
import numpy as np
import networkx as nx
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from matplotlib.ticker import MaxNLocator
from matplotlib.colors import BoundaryNorm

from numerics.src.covariance import architecture_eta, check_psd, psd_power_covariance
from numerics.src.diagnostics import paired_crossover_estimate
from numerics.src.graph_models import exponential_decision_operator, graph_bundle
from numerics.src.plotting import COLORS, configure, save
from numerics.src.policies import gaussian_linear_predictor
from numerics.src.processes import exact_ou_pair
from numerics.src.regret import affine_rinf, mc_quadratic_regret
from numerics.src.theory import (
    aggregate_eta_captured, aggregate_eta_omitted, aggregate_threshold,
    canonical_eta, canonical_rstar, composed_regret, temporal_fraction,
)
from numerics.src.utils import load_yaml, metadata, sample_mean_ci, write_csv, write_json


def cfg(number):
    return load_yaml(SOURCE_ROOT / "config" / f"experiment_{number:02d}.yaml")


def stable_spd(rng, n, coupled=True):
    if not coupled:
        return np.eye(n)
    A = rng.normal(size=(n, n)) / np.sqrt(n)
    return A.T @ A + 0.7 * np.eye(n)


def _matrix_diagnostics(matrix):
    """Small JSON/NPZ-friendly diagnostics for an archived symmetric matrix."""
    matrix = np.asarray(matrix, dtype=float)
    symmetric = (matrix + matrix.T) / 2.0
    eig = np.linalg.eigvalsh(symmetric)
    return {
        "min_eigenvalue": float(eig.min()),
        "max_eigenvalue": float(eig.max()),
        "condition": float(np.linalg.cond(symmetric)),
        "max_abs_asymmetry": float(np.max(np.abs(matrix - matrix.T))),
        "psd": bool(eig.min() >= -1e-9),
    }


def _neighbor_regret_gaps(radii, regret, optimum):
    """Regret at an integer optimum and gaps to available neighbors."""
    radii = np.asarray(radii)
    regret = np.asarray(regret, dtype=float)
    index = int(np.flatnonzero(radii == optimum)[0])
    current = float(regret[index])
    left = None if index == 0 else float(regret[index - 1] - current)
    right = None if index == len(regret) - 1 else float(regret[index + 1] - current)
    return {
        "rstar_regret": current,
        "left_regret_gap": left,
        "right_regret_gap": right,
    }


def _sweep_record(kind, sweep, value, radii, eta, regret):
    """Archive all quantities needed to audit one finite-graph sweep point."""
    optimum = int(radii[np.argmin(regret)])
    gaps = _neighbor_regret_gaps(radii, regret, optimum)
    return {
        "graph": kind,
        "sweep": sweep,
        "value": float(value),
        "radius_count": int(len(radii)),
        "diameter": int(radii[-1]),
        "rstar": optimum,
        "eta_at_rstar": float(eta[optimum]),
        **gaps,
    }


def system_matrices(name, seed):
    rng = np.random.default_rng(seed)
    dims = {"A": 8, "B": 20, "C": 50, "D": 32}
    n = dims[name]
    if name == "A":
        sigma = np.eye(n); Q = np.eye(n); B = rng.normal(size=(n, n)) / np.sqrt(n)
    elif name == "B":
        idx = np.arange(n); sigma = 0.65 ** np.abs(idx[:, None] - idx[None, :])
        Q = stable_spd(rng, n); B = rng.normal(size=(n, n)) / np.sqrt(n)
    elif name == "C":
        _, dist, lap = graph_bundle("ring", n=n)
        sigma = psd_power_covariance(lap, 0.7, 1.4)
        Q = np.eye(n) + 0.12 * lap
        B = np.exp(-dist / 1.4); B /= np.linalg.norm(B, axis=1, keepdims=True)
    else:
        _, dist, lap = graph_bundle("geometric", n=n, seed=seed)
        sigma = psd_power_covariance(lap, 1.1, 2.0)
        Q = stable_spd(rng, n)
        B = np.exp(-dist / 2.5); B /= np.linalg.norm(B, axis=1, keepdims=True)
    return n, Q, sigma, B


def exp01():
    c = cfg(1); start = time.perf_counter(); rng = np.random.default_rng(c["seed"])
    rhos = np.linspace(c["rho_min"], c["rho_max"], c["rho_points"])
    # Trials are collected in delay order below; archive labels in that same
    # order, including when the configured selection is unsorted or repeated.
    trial_indices = np.unique(np.asarray(
        c.get("trial_rho_indices", [0, len(rhos)//2, len(rhos)-1]), dtype=int
    ))
    if np.any(trial_indices < 0) or np.any(trial_indices >= len(rhos)):
        raise ValueError("trial_rho_indices must index the configured rho grid")
    rows, raw, matrix_archive, matrix_diagnostics = [], {}, {}, {}
    fig, ax = plt.subplots(figsize=(3.45, 2.6))
    ax.plot(rhos, temporal_fraction(rhos), color="black", label=r"$1-e^{-2\tau/T}$")
    for sidx, name in enumerate(c["systems"]):
        n, Q, sigma, B = system_matrices(name, c["seed"] + sidx)
        K = np.linalg.solve(Q, B); rinf = affine_rinf(Q, B, sigma)
        matrix_archive.update({
            f"{name}_Q": Q,
            f"{name}_sigma": sigma,
            f"{name}_B": B,
            f"{name}_K": K,
        })
        matrix_diagnostics[name] = {
            "seed": int(c["seed"] + sidx),
            "n": int(n),
            "rinf": float(rinf),
            "Q": _matrix_diagnostics(Q),
            "sigma": _matrix_diagnostics(sigma),
            "B_max_abs": float(np.max(np.abs(B))),
            "K_max_abs": float(np.max(np.abs(K))),
        }
        system_trials = []
        for j, rho in enumerate(rhos):
            past, current = exact_ou_pair(rng, sigma, float(rho), c["samples"])
            pred = np.exp(-rho) * past
            errors = (current - pred) @ K.T
            mean, se, trial = mc_quadratic_regret(errors, Q)
            cov_value = temporal_fraction(rho) * rinf
            rows.append({"system": name, "n": n, "rho": rho, "rinf": rinf,
                         "mc_regret": mean, "mc_se": se, "cov_regret": cov_value,
                         "mc_normalized": mean/rinf, "cov_normalized": cov_value/rinf,
                         "theory_normalized": temporal_fraction(rho)})
            if j in trial_indices:
                system_trials.append(trial)
        raw[name] = np.vstack(system_trials)
        sr = [x for x in rows if x["system"] == name]
        ax.errorbar(rhos, [x["mc_normalized"] for x in sr],
                    yerr=[1.96*x["mc_se"]/rinf for x in sr], fmt="o", ms=2.4,
                    markevery=2, capsize=0, color=COLORS[sidx], label=f"System {name}")
    ax.set(xlabel=r"staleness $\tau/T$", ylabel=r"$R_{\rm glob}/R_\infty$", xlim=(0,3), ylim=(-.02,1.04))
    ax.legend(frameon=False, ncol=2); ax.grid(alpha=.18)
    save(fig, OUTPUT_ROOT, "fig7_1_temporal_scaling", PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp01_temporal_scaling.csv", rows)
    # The trial archive retains the labels that make its three stored slices
    # reproducible.  Matrix arrays are kept in a separate NPZ because the four
    # systems have different dimensions and therefore cannot form one tensor.
    np.savez_compressed(
        OUTPUT_ROOT/"results/raw/exp01_trial_regret.npz",
        rhos=rhos,
        trial_indices=trial_indices,
        trial_rhos=rhos[trial_indices],
        **raw,
    )
    np.savez_compressed(OUTPUT_ROOT/"results/raw/exp01_system_matrices.npz", **matrix_archive)
    diffs = np.array([x["mc_normalized"]-x["theory_normalized"] for x in rows])
    covdiff = np.array([x["mc_normalized"]-x["cov_normalized"] for x in rows])
    result = {"max_abs_error": float(abs(diffs).max()), "rmse": float(np.sqrt(np.mean(diffs**2))),
              "max_mc_cov_discrepancy": float(abs(covdiff).max()), "systems": 4,
              "points": len(rows), "samples_per_point": c["samples"],
              "trial_rhos": [float(x) for x in rhos[trial_indices]],
              "matrix_archive": "results/raw/exp01_system_matrices.npz",
              "trial_archive": "results/raw/exp01_trial_regret.npz",
              "matrix_diagnostics": matrix_diagnostics}
    write_json(OUTPUT_ROOT/"results/metadata/exp01.json", {**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":result})
    return result


def exp02():
    c = cfg(2)
    start = time.perf_counter()
    rng = np.random.default_rng(c["seed"])
    rows = []
    empirical_boundaries = []
    empirical_ses = []
    theoretical_boundaries = []

    for n in c["n"]:
        for gamma in c["gamma_over_q"]:
            theta = rng.standard_normal((c["samples"], n))
            Q = np.eye(n) + gamma * np.ones((n, n))
            K = np.linalg.solve(Q, np.eye(n))
            xstar = theta @ K.T
            uloc = theta / (1.0 + gamma)
            local_error = xstar - uloc
            _, _, local_trials = mc_quadratic_regret(local_error, Q)
            _, _, open_trials = mc_quadratic_regret(xstar, Q)

            estimate = paired_crossover_estimate(open_trials, local_trials)
            exact = float(aggregate_threshold(gamma, n))
            empirical_boundaries.append(estimate["estimate"])
            empirical_ses.append(estimate["se"])
            theoretical_boundaries.append(exact)
            rows.append({
                "n": n,
                "gamma_over_q": gamma,
                "eta_omitted": float(aggregate_eta_omitted(gamma, n)),
                "eta_captured": float(aggregate_eta_captured(gamma, n)),
                "threshold_theory": exact,
                "threshold_empirical": estimate["estimate"],
                "threshold_empirical_se": estimate["se"],
                "threshold_ci_low": estimate["ci_low"],
                "threshold_ci_high": estimate["ci_high"],
                "boundary_abs_error": abs(estimate["estimate"] - exact),
                "boundary_residual": estimate["estimate"] - exact,
                "rinf_empirical": estimate["rinf"],
                "rloc_empirical": estimate["rloc"],
                "paired_regret_covariance": estimate["paired_covariance"],
                "threshold_denominator_valid": estimate["captured_positive"],
            })

    write_csv(OUTPUT_ROOT / "results/processed/exp02_local_global_crossover.csv", rows)
    np.savez_compressed(
        OUTPUT_ROOT / "results/raw/exp02_boundaries.npz",
        n=np.array([r["n"] for r in rows], dtype=int),
        gamma_over_q=np.array([r["gamma_over_q"] for r in rows]),
        empirical=np.array(empirical_boundaries),
        empirical_se=np.array(empirical_ses),
        theory=np.array(theoretical_boundaries),
    )

    positive_gamma = np.asarray(c["gamma_over_q"], dtype=float)
    positive_gamma = positive_gamma[positive_gamma > 0.0]
    gamma_grid = np.logspace(
        np.log10(positive_gamma.min()), np.log10(positive_gamma.max()), 400
    )
    rho_grid = np.linspace(0.0, c["rho_max"], 300)
    X, Y = np.meshgrid(gamma_grid, rho_grid)
    boundary = aggregate_threshold(X, 100)
    winner = (Y > boundary).astype(float)

    fig = plt.figure(figsize=(7.15, 3.45), constrained_layout=True)
    grid = fig.add_gridspec(
        2,
        2,
        width_ratios=[1.12, 1.0],
        height_ratios=[1.6, 0.9],
    )
    ax = fig.add_subplot(grid[:, 0])
    ax2 = fig.add_subplot(grid[0, 1])
    ax3 = fig.add_subplot(grid[1, 1], sharex=ax2)
    ax.contourf(
        X,
        Y,
        winner,
        levels=[-0.5, 0.5, 1.5],
        colors=["#D9EAF4", "#F5D5C8"],
    )
    ax.plot(gamma_grid, aggregate_threshold(gamma_grid, 100), "k-", lw=1.4)
    ax.plot(gamma_grid, 0.5 * np.log1p(gamma_grid), "k--", lw=1.2)
    ax.set_xscale("log")
    ax.set(
        xlabel=r"coupling $\gamma/q$",
        ylabel=r"staleness $\tau/T$",
        ylim=(0, c["rho_max"]),
    )
    ax.text(0.04, 0.86, "fresh-local", transform=ax.transAxes, fontsize=7)
    ax.text(0.96, 0.08, "stale-global", transform=ax.transAxes, fontsize=7, ha="right")
    ax.legend(
        handles=[
            Line2D([], [], color="k", lw=1.4, label=r"finite $n=100$"),
            Line2D([], [], color="k", lw=1.2, ls="--", label=r"$n\to\infty$"),
        ],
        frameon=False,
        fontsize=6.5,
        loc="upper left",
    )
    ax.grid(alpha=0.15)

    for j, n in enumerate(c["n"]):
        rr = [
            r for r in rows if r["n"] == n and r["gamma_over_q"] > 0.0
        ]
        color = COLORS[j]
        ax2.plot(
            gamma_grid,
            aggregate_threshold(gamma_grid, n),
            color=color,
            lw=1.25,
            label=rf"exact $n={n}$",
        )
        ax2.errorbar(
            [r["gamma_over_q"] for r in rr],
            [r["threshold_empirical"] for r in rr],
            yerr=[1.96 * r["threshold_empirical_se"] for r in rr],
            linestyle="none",
            marker="x",
            ms=4.0,
            mew=0.9,
            capsize=1.5,
            elinewidth=0.7,
            color=color,
        )
    ax2.set_xscale("log")
    ax2.set(
        ylabel=r"crossover $\rho^\star$",
        xlim=(positive_gamma.min() * 0.85, positive_gamma.max() * 1.08),
        ylim=(0, c["rho_max"]),
    )
    exact_legend = ax2.legend(
        frameon=False, fontsize=6.2, ncol=2, loc="upper left", title="closed form"
    )
    ax2.add_artist(exact_legend)
    ax2.legend(
        handles=[
            Line2D(
                [],
                [],
                color="0.2",
                marker="x",
                linestyle="none",
                ms=4,
                label="paired MC ±95% CI",
            )
        ],
        frameon=False,
        fontsize=6.2,
        loc="lower right",
    )
    ax2.grid(alpha=0.18)

    for j, n in enumerate(c["n"]):
        rr = [
            r for r in rows if r["n"] == n and r["gamma_over_q"] > 0.0
        ]
        ax3.errorbar(
            [r["gamma_over_q"] for r in rr],
            [r["boundary_residual"] for r in rr],
            yerr=[1.96 * r["threshold_empirical_se"] for r in rr],
            linestyle="none",
            marker="x",
            ms=3.3,
            mew=0.8,
            capsize=1.2,
            elinewidth=0.6,
            color=COLORS[j],
        )
    ax3.axhline(0.0, color="0.25", lw=0.8)
    ax3.set_xscale("log")
    ax3.set(
        xlabel=r"$\gamma/q$",
        ylabel=r"$\hat\rho^\star-\rho^\star$",
        xlim=(positive_gamma.min() * 0.85, positive_gamma.max() * 1.08),
    )
    ax2.tick_params(labelbottom=False)
    ax3.text(
        0.05,
        0.05,
        r"zero coupling: residual $=0$",
        transform=ax3.transAxes,
        fontsize=5.8,
    )
    ax3.grid(alpha=0.18)
    save(fig, OUTPUT_ROOT, "fig7_2_local_global_phase", PAPER_FIGURES)

    errors = np.array([r["boundary_abs_error"] for r in rows])
    result = {
        "max_boundary_error": float(errors.max()),
        "mean_boundary_error": float(errors.mean()),
        "finite_n_gap_at_gamma10_n5": float(
            aggregate_threshold(10, 5) - 0.5 * np.log(11)
        ),
        "samples_per_setting": c["samples"],
        "paired_delta_method": True,
        "zero_coupling_settings": int(
            sum(r["gamma_over_q"] == 0.0 for r in rows)
        ),
        "max_threshold_se": float(max(r["threshold_empirical_se"] for r in rows)),
        "mean_threshold_se": float(
            np.mean([r["threshold_empirical_se"] for r in rows])
        ),
        "ci_contains_theory": int(
            sum(
                r["threshold_ci_low"] <= r["threshold_theory"] <= r["threshold_ci_high"]
                for r in rows
            )
        ),
        "invalid_threshold_settings": int(
            sum(not r["threshold_denominator_valid"] for r in rows)
        ),
    }
    write_json(
        OUTPUT_ROOT / "results/metadata/exp02.json",
        {
            **metadata(c["seed"], c["samples"], c, time.perf_counter() - start),
            "results": result,
        },
    )
    return result


def exp03():
    c=cfg(3); start=time.perf_counter(); rng=np.random.default_rng(c["seed"]); rows=[]; results={}
    radius_grid_points=int(c.get("radius_grid_points", 1001))
    max_radius_over_lc=float(c.get("D_over_ell_c", c.get("D", 2.0)))
    radius_over_lc=np.linspace(0.0, max_radius_over_lc, radius_grid_points)
    fig,axes=plt.subplots(1,3,figsize=(7.45,2.65),sharey=True,constrained_layout=True)
    for j,(name,p) in enumerate(c["regimes"].items()):
        ell_c=float(p["ell_c"]); radius=radius_over_lc*ell_c
        eta=p["eta0"]*np.exp(-2*radius_over_lc); temporal=1-np.exp(-2*radius/p["vT"])
        spatial=np.exp(-2*radius/p["vT"])*eta; total=temporal+spatial
        rtheory=max(0,.5*p["ell_c"]*np.log(p["eta0"]*(1+p["vT"]/p["ell_c"])))
        rcap=min(max_radius_over_lc*ell_c,rtheory); rnum=float(radius[np.argmin(total)])
        mT=2/p["vT"]*np.ones_like(radius)
        mS=2*eta/(p["ell_c"]*(1-eta))
        # Independent Monte Carlo: temporal and residual spatial innovations.
        mc_sum=np.zeros_like(radius)
        mc_sum_sq=np.zeros_like(radius)
        remaining=c["samples"]
        while remaining:
            batch=min(1000,remaining)
            zt=rng.standard_normal((batch,len(radius)))
            zs=rng.standard_normal((batch,len(radius)))
            squared=(np.sqrt(temporal)*zt+np.sqrt(spatial)*zs)**2
            mc_sum+=np.sum(squared,axis=0)
            mc_sum_sq+=np.sum(squared*squared,axis=0)
            remaining-=batch
        mc=mc_sum/c["samples"]
        sample_variance=np.maximum(
            (mc_sum_sq - mc_sum*mc_sum/c["samples"])/(c["samples"]-1), 0.0
        )
        mc_se=np.sqrt(sample_variance/c["samples"])
        mc_ci_low=mc-1.96*mc_se; mc_ci_high=mc+1.96*mc_se
        for k,r in enumerate(radius):
            rows.append({"regime":name,"radius":r,"radius_over_lc":radius_over_lc[k],
                         "total":total[k],"temporal":temporal[k],"spatial":spatial[k],
                         "mc_total":mc[k],"mc_se":mc_se[k],"mc_ci_low":mc_ci_low[k],
                         "mc_ci_high":mc_ci_high[k],"variance_total":total[k],
                         "mT":mT[k],"mS":mS[k]})
        ax=axes[j]; ax.plot(radius_over_lc,total,color="black",label=r"total $R/R_\infty$")
        ax.plot(radius_over_lc,temporal,"--",color=COLORS[0],label="temporal")
        ax.plot(radius_over_lc,spatial,":",color=COLORS[1],label="spatial")
        sampled=slice(None,None,80)
        ax.errorbar(radius_over_lc[sampled],mc[sampled],yerr=1.96*mc_se[sampled],
                    fmt="o",mfc="none",ms=2.8,color=COLORS[2],capsize=0,
                    label="scalar variance check")
        rcap_over_lc=rcap/ell_c
        rnum_over_lc=rnum/ell_c
        ax.axvline(rcap_over_lc,color=COLORS[3],ls="-.",label=r"theory $r^\star$ (capped)")
        ax.plot(rnum_over_lc,total.min(),"x",color="black",ms=5,label="grid minimum")
        regime_title={"local":"local","interior":"interior",
                       "broad":"maximum allowed radius"}[name]
        ax.set(xlabel=r"dimensionless radius $r/\ell_c$",
               title=regime_title + "\n" +
               fr"$\eta_0={p['eta0']:g},\;vT/\ell_c={p['vT']/ell_c:g}$")
        results[name]={"rstar_theory_capped":rcap_over_lc,"rstar_numeric":rnum_over_lc,
                       "rstar_theory_capped_over_lc":rcap_over_lc,
                       "rstar_numeric_over_lc":rnum_over_lc,
                       "rstar_theory_capped_physical":rcap,
                       "rstar_numeric_physical":rnum,
                       "rstar_abs_error":abs(rcap_over_lc-rnum_over_lc),
                       "rstar_abs_error_over_lc":abs(rcap_over_lc-rnum_over_lc),
                       "mc_max_abs_error":float(abs(mc-total).max()),
                       "mc_max_se":float(mc_se.max()),
                       "mc_max_ci_width":float((2*1.96*mc_se).max()),
                       "variance_check": "scalar Gaussian error decomposition",
                       "ell_c":ell_c,"vT":float(p["vT"]),
                       "eta0":float(p["eta0"]),
                       "radius_grid_points":radius_grid_points,
                       "radius_grid_step_over_lc":float(radius_over_lc[1]-radius_over_lc[0])}
        if name=="interior":
            results[name]["marginal_gap_at_numeric_optimum"]=float(abs(mS[np.argmin(total)]-mT[np.argmin(total)]))
    axes[0].set_ylabel(r"normalized regret component")
    axes[0].legend(frameon=False,fontsize=6.2); [a.grid(alpha=.16) for a in axes]
    save(fig,OUTPUT_ROOT,"fig7_3_radius_regret",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp03_radius_regret.csv",rows)
    write_json(OUTPUT_ROOT/"results/metadata/exp03.json",{**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":results})
    return results


def exp04():
    c = cfg(4)
    start = time.perf_counter()
    lo, hi, num = c["vT_over_lc"]
    vlo, vhi, vnum = c["ell_s_over_lc"]
    vT = np.logspace(np.log10(lo), np.log10(hi), int(num))
    ls = np.logspace(np.log10(vlo), np.log10(vhi), int(vnum))
    grid_min = float(c.get("radius_grid_min", 0.0))
    grid_max = float(c["radius_grid_max"])
    grid_points = int(c["radius_grid_points"])
    transition_tolerance = float(c.get("transition_classification_tolerance", 1e-12))
    radius_grid = np.linspace(grid_min, grid_max, grid_points)
    radius_step = float(radius_grid[1] - radius_grid[0])

    rows = []
    numeric = []
    theory = []
    for s in ls:
        for L in vT:
            rt = float(canonical_rstar(s, 1.0, L))
            vals = composed_regret(radius_grid, s, 1.0, L)
            rn = float(radius_grid[np.argmin(vals)])
            transition_gap = float(L - 2.0 * s)
            theory_positive = bool(transition_gap > transition_tolerance)
            numeric_positive = bool(rn > grid_min + 1e-12)
            classification_match = theory_positive == numeric_positive
            error = float(rn - rt)
            rows.append({
                "ell_s_over_lc": float(s),
                "vT_over_lc": float(L),
                "rstar_numeric": rn,
                "rstar_theory": rt,
                "abs_error": abs(error),
                "signed_error": error,
                "error_in_grid_steps": abs(error) / radius_step,
                "signed_error_in_grid_steps": error / radius_step,
                "radius_step": radius_step,
                "theory_positive_radius": theory_positive,
                "numeric_positive_radius": numeric_positive,
                "classification_match": classification_match,
                "transition_gap_vT_over_lc": abs(transition_gap),
            })
            numeric.append(rn)
            theory.append(rt)
    write_csv(OUTPUT_ROOT / "results/processed/exp04_radius_scaling.csv", rows)

    numeric = np.asarray(numeric, dtype=float)
    theory = np.asarray(theory, dtype=float)
    numeric_grid = numeric.reshape(len(ls), len(vT)).T
    theory_grid = theory.reshape(len(ls), len(vT)).T
    numeric_positive_grid = numeric_grid > grid_min + 1e-12
    positive_values = numeric_grid[numeric_positive_grid]
    positive_max = float(np.max(positive_values))
    positive_masked = np.ma.masked_where(~numeric_positive_grid, numeric_grid)

    fig = plt.figure(figsize=(7.15, 3.85), constrained_layout=True)
    grid = fig.add_gridspec(
        2,
        2,
        width_ratios=[1.12, 1.0],
        height_ratios=[1.4, 0.9],
    )
    ax = fig.add_subplot(grid[:, 0])
    ax2 = fig.add_subplot(grid[0, 1])
    ax3 = fig.add_subplot(grid[1, 1])

    color_levels = np.arange(0.0, 1.5001, 0.25)
    cmap = plt.get_cmap("viridis", len(color_levels) - 1).copy()
    cmap.set_bad("#eeeeee")
    norm = BoundaryNorm(color_levels, cmap.N, clip=True)
    mesh = ax.pcolormesh(
        ls,
        vT,
        positive_masked,
        shading="auto",
        cmap=cmap,
        norm=norm,
        rasterized=True,
    )
    contours = ax.contour(
        ls,
        vT,
        positive_masked,
        levels=[0.25, 0.5, 0.75, 1.0, 1.25],
        colors="white",
        linewidths=0.35,
        alpha=0.8,
    )
    for label in ax.clabel(contours, fmt="%g", fontsize=6.5, inline=True):
        label.set_color("#222222")
        label.set_bbox({"facecolor": "white", "edgecolor": "none",
                        "alpha": 0.8, "pad": 0.5})
    ax.contour(
        ls,
        vT,
        numeric_positive_grid.astype(float),
        levels=[0.5],
        colors="#333333",
        linewidths=0.65,
    )
    ax.plot(ls, 2.0 * ls, "k--", lw=1.15)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set(
        xlabel=r"$\ell_s/\ell_c$",
        ylabel=r"$vT/\ell_c$",
        xlim=(ls.min(), ls.max()),
        ylim=(vT.min(), vT.max()),
    )
    ax.legend(
        handles=[
            Patch(facecolor="#eeeeee", edgecolor="0.45", label=r"grid minimum $r=0$"),
            Line2D([], [], color="k", ls="--", lw=1.15, label=r"exact threshold $vT=2\ell_s$"),
        ],
        frameon=False,
        fontsize=7.0,
        loc="lower right",
    )
    fig.colorbar(
        mesh,
        ax=ax,
        pad=0.02,
        fraction=0.05,
        ticks=color_levels,
        boundaries=color_levels,
        label=r"positive grid $\hat r^\star/\ell_c$",
    )
    ax.grid(alpha=0.12, which="major")

    cross_targets = c.get("cross_section_ell_s_over_lc", [0.1, 0.4, 1.0])
    cross_handles = []
    marker_indices = np.linspace(0, len(vT) - 1, min(14, len(vT)), dtype=int)
    for j, target in enumerate(cross_targets):
        sidx = int(np.argmin(abs(ls - float(target))))
        s = float(ls[sidx])
        color = COLORS[j % len(COLORS)]
        ax2.plot(
            vT,
            theory_grid[:, sidx],
            color=color,
            lw=1.15,
        )
        ax2.plot(
            vT[marker_indices],
            numeric_grid[marker_indices, sidx],
            linestyle="none",
            marker="o",
            mfc="none",
            ms=2.3,
            mew=0.65,
            color=color,
        )
        cross_handles.append(
            Line2D([], [], color=color, lw=1.15, label=rf"$\ell_s/\ell_c={s:.2g}$")
        )
    ax2.set_xscale("log")
    ax2.set(
        xlabel=r"$vT/\ell_c$",
        ylabel=r"optimal radius $r^\star/\ell_c$",
        xlim=(vT.min(), vT.max()),
        ylim=(-0.035, max(1.05 * positive_max, radius_step)),
    )
    exact_legend = ax2.legend(
        handles=cross_handles,
        frameon=False,
        fontsize=7.0,
        title="closed form",
        loc="upper left",
    )
    ax2.add_artist(exact_legend)
    ax2.legend(
        handles=[
            Line2D([], [], color="0.25", marker="o", mfc="none", ls="none", ms=2.8,
                   label="fixed-grid minimum")
        ],
        frameon=False,
        fontsize=7.0,
        loc="lower right",
    )
    ax2.grid(alpha=0.18, which="both")

    signed_step_errors = np.array([r["signed_error_in_grid_steps"] for r in rows])
    histogram_bins = np.linspace(-0.75, 0.75, 16)
    ax3.hist(
        signed_step_errors,
        bins=histogram_bins,
        weights=np.full(len(signed_step_errors), 100.0 / len(signed_step_errors)),
        color=COLORS[0],
        alpha=0.82,
        edgecolor="white",
        linewidth=0.35,
    )
    ax3.axvspan(-0.5, 0.5, color="#dddddd", alpha=0.45, zorder=0)
    ax3.axvline(0.0, color="0.2", lw=0.75)
    ax3.set(
        xlabel=r"signed grid error $/(\Delta r)$",
        ylabel="share (%)",
        xlim=(-0.75, 0.75),
    )
    ax3.text(
        0.05,
        0.94,
        f"MAE {np.mean(abs(signed_step_errors)):.2f}\nmax {np.max(abs(signed_step_errors)):.2f}",
        transform=ax3.transAxes,
        va="top",
        fontsize=6.5,
    )
    ax3.grid(alpha=0.18)
    save(fig, OUTPUT_ROOT, "fig7_4_radius_phase", PAPER_FIGURES)

    errors = abs(numeric - theory)
    error_steps = errors / radius_step
    theory_positive = np.array([r["theory_positive_radius"] for r in rows], dtype=bool)
    numeric_positive = np.array([r["numeric_positive_radius"] for r in rows], dtype=bool)
    classification_mismatch = theory_positive != numeric_positive
    mismatch_rows = [
        {
            "ell_s_over_lc": float(r["ell_s_over_lc"]),
            "vT_over_lc": float(r["vT_over_lc"]),
            "theory_positive_radius": bool(r["theory_positive_radius"]),
            "numeric_positive_radius": bool(r["numeric_positive_radius"]),
            "transition_gap_vT_over_lc": float(r["transition_gap_vT_over_lc"]),
            "theory_radius_in_grid_steps": float(r["rstar_theory"] / radius_step),
        }
        for r in rows
        if not r["classification_match"]
    ]
    result = {
        "mae": float(errors.mean()),
        "max_error": float(errors.max()),
        "max_radius_grid_step": radius_step,
        "points": len(rows),
        "radius_grid_min": grid_min,
        "radius_grid_max": grid_max,
        "radius_grid_points": grid_points,
        "radius_grid_independent_of_closed_form": True,
        "transition_classification_tolerance": transition_tolerance,
        "mean_error_in_grid_steps": float(error_steps.mean()),
        "max_error_in_grid_steps": float(error_steps.max()),
        "p95_error_in_grid_steps": float(np.quantile(error_steps, 0.95)),
        "positive_region_points": int(theory_positive.sum()),
        "zero_region_points": int((~theory_positive).sum()),
        "positive_region_mae_in_grid_steps": float(error_steps[theory_positive].mean()),
        "positive_region_max_error_in_grid_steps": float(error_steps[theory_positive].max()),
        "zero_region_max_error_in_grid_steps": float(error_steps[~theory_positive].max()),
        "transition_misclassifications": int(classification_mismatch.sum()),
        "transition_misclassification_points": mismatch_rows,
        "transition_misclassification_max_gap_vT_over_lc": float(
            max((p["transition_gap_vT_over_lc"] for p in mismatch_rows), default=0.0)
        ),
        "transition_misclassification_max_theory_radius_in_grid_steps": float(
            max((p["theory_radius_in_grid_steps"] for p in mismatch_rows), default=0.0)
        ),
        "exact_transition_condition": "vT/ell_c > 2*(ell_s/ell_c)",
    }

    # One-dimensional numerical comparative statics in the interior regime.
    sweep_rows = []
    base = {"T": 5.0, "v": 2.0, "ell_s": 0.4, "ell_c": 1.0}
    sweep_values = {
        "T": [2.0, 3.0, 5.0, 8.0, 12.0],
        "v": [0.8, 1.2, 2.0, 3.0, 5.0],
        "ell_s": [0.1, 0.2, 0.4, 0.8, 1.5],
        "ell_c": [0.4, 0.7, 1.0, 1.7, 3.0],
    }
    directions = {}
    for parameter, values in sweep_values.items():
        opt = []
        for value in values:
            p = {**base, parameter: value}
            rg = np.linspace(0, 5, 5001)
            vals = composed_regret(rg, p["ell_s"], p["ell_c"], p["v"] * p["T"])
            rn = float(rg[np.argmin(vals)])
            opt.append(rn)
            sweep_rows.append({"parameter": parameter, "value": value, "rstar_numeric": rn})
        delta = np.diff(opt)
        expected = "decreasing" if parameter == "ell_s" else "increasing"
        directions[parameter] = {
            "expected": expected,
            "observed_monotone": bool(
                np.all(delta <= 1e-12)
                if expected == "decreasing"
                else np.all(delta >= -1e-12)
            ),
            "rstar": opt,
        }
    write_csv(OUTPUT_ROOT / "results/processed/exp04_comparative_statics.csv", sweep_rows)
    result["comparative_statics"] = directions
    write_json(
        OUTPUT_ROOT / "results/metadata/exp04.json",
        {
            **metadata(c["seed"], 0, c, time.perf_counter() - start),
            "results": result,
        },
    )
    return result


def exp05():
    c=cfg(5); start=time.perf_counter(); rng=np.random.default_rng(c["seed"])
    _,dist,lap=graph_bundle("ring",n=c["n"]); sigma=psd_power_covariance(lap,c["kappa"],c["nu"])
    radii=np.arange(0,int(np.max(dist))+1); rows=[]; result={}
    mc_rows=[]
    fig,(ax,ax2,ax3)=plt.subplots(1,3,figsize=(7.35,2.65),
                                    gridspec_kw={"width_ratios":[1.15,1.15,.8]},
                                    constrained_layout=True)
    # This is a state statistic, not the decision omission.  It is displayed
    # in a dedicated panel and copied into the processed rows for provenance.
    state_corr=np.empty(len(radii),dtype=float)
    for k,r in enumerate(radii):
        pairs=np.argwhere(dist==r)
        state_corr[k]=float(np.mean([
            sigma[i,j]/np.sqrt(sigma[i,i]*sigma[j,j]) for i,j in pairs
        ]))
    for j,ell in enumerate(c["ell_c"]):
        K=exponential_decision_operator(dist,ell); eta=np.array([architecture_eta(sigma,K,dist,r) for r in radii])
        regret=1-np.exp(-2*c["latency_per_hop"]*radii/c["T"])*(1-eta)
        rstar=int(radii[np.argmin(regret)])
        # Independent MC checks at representative radii using exact
        # conditional policies.  Normalize by the analytical total decision
        # variance, not by a realization-specific denominator.
        check_offset=int(c.get("mc_check_radius_offset",3))
        check_r=sorted(set([0,rstar,min(rstar+check_offset,int(radii[-1])),int(radii[-1])]))
        mc_errors=[]
        theta=rng.multivariate_normal(np.zeros(c["n"]),sigma,size=c["samples"])
        x=theta@K.T
        total_variance=float(np.trace(K@sigma@K.T))
        for r in check_r:
            omitted_trials=np.zeros(c["samples"],dtype=float)
            for i in range(c["n"]):
                obs=np.flatnonzero(dist[i]<=r)
                cov_obs=sigma[np.ix_(obs,obs)]
                cov_y_obs=K[i]@sigma[:,obs]
                beta=gaussian_linear_predictor(cov_y_obs,cov_obs)
                pred=theta[:,obs]@beta
                omitted_trials+=(x[:,i]-pred)**2
            omitted_mean,omitted_se,omitted_low,omitted_high=sample_mean_ci(omitted_trials)
            mc_eta=omitted_mean/total_variance
            mc_se=omitted_se/total_variance
            mc_low=omitted_low/total_variance
            mc_high=omitted_high/total_variance
            abs_error=abs(mc_eta-eta[r]); mc_errors.append(abs_error)
            mc_rows.append({"ell_c":float(ell),"radius":int(r),
                            "eta_theory":float(eta[r]),"eta_mc":float(mc_eta),
                            "eta_mc_se":float(mc_se),"eta_mc_ci_low":float(mc_low),
                            "eta_mc_ci_high":float(mc_high),"abs_error":float(abs_error),
                            "omitted_variance_mc":float(omitted_mean),
                            "omitted_variance_mc_se":float(omitted_se),
                            "normalizer_analytic":total_variance,
                            "rinf_analytic":0.5*total_variance,
                            "samples":int(c["samples"])})
        for r,e,rr in zip(radii,eta,regret):
            rows.append({"ell_c":ell,"radius":int(r),"eta_S":e,"regret":rr,
                         "state_correlation":state_corr[r]})
        ax.plot(radii,eta,color=COLORS[j],marker="o",ms=1.8,markevery=2,label=fr"$\ell_c={ell}$")
        ax2.plot(radii,regret,color=COLORS[j],marker="o",ms=1.8,markevery=2,label=fr"$\ell_c={ell}$")
        ax2.scatter([rstar],[regret[rstar]],color=COLORS[j],marker="D",s=24,zorder=5,
                    edgecolors="black",linewidths=.35,label="_nolegend_")
        result[str(ell)]={"rstar":rstar,"eta0":float(eta[0]),
                          "normalizer_analytic":total_variance,
                          "rinf_analytic":0.5*total_variance,
                          "check_radii":[int(x) for x in check_r],
                          "max_mc_eta_error":float(max(mc_errors)),
                          "mean_mc_eta_error":float(np.mean(mc_errors)),
                          "max_mc_eta_se":float(max(row["eta_mc_se"] for row in mc_rows if row["ell_c"]==ell)),
                          "mc_check_count":len(check_r)}
    ax.set(xlabel="graph radius $r$",ylabel=r"decision omission $\eta_S(r)$",xlim=(0,15))
    ax2.set(xlabel="graph radius $r$",ylabel=r"$R(r)/R_\infty$",xlim=(0,15))
    ax3.plot(radii,state_corr,"k--",lw=1.2)
    ax3.set(xlabel="graph radius $r$",ylabel="raw state correlation",xlim=(0,15),ylim=(-.02,1.04))
    for axis in (ax, ax2, ax3):
        axis.xaxis.set_major_locator(MaxNLocator(nbins=5, integer=True))
    ax2.legend(frameon=False,fontsize=6.2,ncol=1)
    ax.grid(alpha=.16); ax2.grid(alpha=.16); ax3.grid(alpha=.16)
    save(fig,OUTPUT_ROOT,"fig7_5_decision_relevance",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp05_decision_relevance.csv",rows)
    write_csv(OUTPUT_ROOT/"results/processed/exp05_mc_checks.csv",mc_rows)
    np.savez_compressed(OUTPUT_ROOT/"results/raw/exp05_fixed_environment.npz",sigma=sigma,distances=dist,laplacian=lap,
                        state_correlation=state_corr)
    mineig,psd=check_psd(sigma); result["environment"]={"sigma_condition":float(np.linalg.cond(sigma)),"min_eigenvalue":mineig,"psd":psd}
    result["mc_checks_archive"]="results/processed/exp05_mc_checks.csv"
    write_json(OUTPUT_ROOT/"results/metadata/exp05.json",{**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":result})
    return result


def graph_curve(kind,c,T=None,ell_c=None,kappa=None):
    graph_seed=int(c.get("graph_seed",c["seed"]+11))
    _,dist,lap=graph_bundle(kind,n=c["n"],seed=graph_seed)
    use_kappa=c["kappa"] if kappa is None else kappa
    use_ell_c=c["ell_c"] if ell_c is None else ell_c
    use_T=c["T"] if T is None else T
    sigma=psd_power_covariance(lap,use_kappa,c["nu"]); K=exponential_decision_operator(dist,use_ell_c)
    radii=np.arange(int(np.max(dist))+1); eta=np.array([architecture_eta(sigma,K,dist,r) for r in radii])
    regret=1-np.exp(-2*c["latency_per_hop"]*radii/use_T)*(1-eta)
    return radii,eta,regret,int(radii[np.argmin(regret)]),sigma,dist,lap


def exp06():
    c=cfg(6); start=time.perf_counter(); rows=[]; result={}
    fig,axes=plt.subplots(2,2,figsize=(7.25,5.05),constrained_layout=True)
    ax,ax2,ax3,ax4=axes.ravel()
    supplemental=[]
    markers=("o","s","^","D")
    linestyles=("-","--","-.",":")
    for j,kind in enumerate(c["graphs"]):
        radii,eta,regret,rstar,sigma,dist,lap=graph_curve(kind,c)
        gaps=_neighbor_regret_gaps(radii,regret,rstar)
        for r,e,rr in zip(radii,eta,regret):
            rows.append({"graph":kind,"radius":int(r),"eta_S":e,"regret":rr,
                         "is_optimum":bool(int(r)==rstar),"rstar":rstar,
                         "rstar_regret":gaps["rstar_regret"],
                         "left_regret_gap":gaps["left_regret_gap"],
                         "right_regret_gap":gaps["right_regret_gap"]})
        upto=min(len(radii),17)
        style={"marker":markers[j],"linestyle":linestyles[j],"ms":3.0,
               "mfc":"none","mec":COLORS[j],"color":COLORS[j],"lw":1.0}
        ax.plot(radii[:upto],eta[:upto],label=kind,**style)
        ax2.plot(radii[:upto],regret[:upto],label=fr"{kind} ($r^\star={rstar}$)",**style)
        ax.scatter([rstar],[eta[rstar]],marker=markers[j],s=30,facecolors="none",
                   edgecolors=COLORS[j],linewidths=.8,zorder=6)
        ax2.scatter([rstar],[regret[rstar]],marker=markers[j],s=30,facecolors="none",
                    edgecolors=COLORS[j],linewidths=.8,zorder=6)
        mineig,psd=check_psd(sigma); result[kind]={"rstar":rstar,"eta0":float(eta[0]),"diameter":int(radii[-1]),
            "sigma_condition":float(np.linalg.cond(sigma)),"min_eigenvalue":mineig,"psd":psd}
        result[kind].update({"full_neighborhood_eta":float(eta[-1]),
                             "eta_monotone_nonincreasing":bool(np.all(np.diff(eta)<=1e-10)),
                             "rstar_regret":gaps["rstar_regret"],
                             "left_regret_gap":gaps["left_regret_gap"],
                             "right_regret_gap":gaps["right_regret_gap"],
                             "covariance_diagnostics":_matrix_diagnostics(sigma),
                             "graph_seed":int(c.get("graph_seed",c["seed"]+11))})
        latency_values=[float(x) for x in c.get("latency_sweep",[.05,.08,.12,.18,.28])]
        latency_rstars=[]
        for latency in latency_values:
            rr=1-np.exp(-2*latency*radii/c["T"])*(1-eta)
            latency_rstars.append(int(radii[np.argmin(rr)]))
            supplemental.append(_sweep_record(kind,"latency_per_hop",latency,radii,eta,rr))
        result[kind]["rstar_by_latency"]=latency_rstars
        K=exponential_decision_operator(dist,c["ell_c"])
        np.savez_compressed(OUTPUT_ROOT/f"results/raw/exp06_{kind}_graph.npz",
                            sigma=sigma,distances=dist,laplacian=lap,
                            decision_operator=K,radii=radii,eta=eta,regret=regret,
                            graph_seed=np.array(c.get("graph_seed",c["seed"]+11),dtype=int))
    Tvals=np.asarray(c.get("T_sweep",[1.5,2.5,4,6,9,14]),dtype=float)
    ellvals=np.asarray(c.get("ell_c_sweep",[.7,1.2,2,3.5,6]),dtype=float)
    for j,kind in enumerate(c["graphs"]):
        tcurves=[graph_curve(kind,c,T=float(T)) for T in Tvals]
        ecurves=[graph_curve(kind,c,ell_c=float(e)) for e in ellvals]
        rt=[curve[3] for curve in tcurves]; re=[curve[3] for curve in ecurves]
        style={"linestyle":"none","marker":markers[j],"ms":4.2,
               "mfc":"none","mec":COLORS[j],"color":COLORS[j]}
        ax3.plot(Tvals,rt,label=kind,**style)
        ax4.plot(ellvals,re,label=kind,**style)
        result[kind]["rstar_by_T"]=rt; result[kind]["rstar_by_ell_c"]=re
        kappa_values=[float(x) for x in c.get("kappa_sweep",[1.5,1.0,.7,.45,.3])]
        kcurves=[graph_curve(kind,c,kappa=float(k)) for k in kappa_values]
        rk=[curve[3] for curve in kcurves]
        result[kind]["rstar_by_kappa"]=rk
        for value,curve in zip(Tvals,tcurves): supplemental.append(
            _sweep_record(kind,"T",value,curve[0],curve[1],curve[2]))
        for value,curve in zip(ellvals,ecurves): supplemental.append(
            _sweep_record(kind,"ell_c",value,curve[0],curve[1],curve[2]))
        for value,curve in zip(kappa_values,kcurves): supplemental.append(
            _sweep_record(kind,"kappa",value,curve[0],curve[1],curve[2]))
    ax.set(xlabel="graph radius $r$",ylabel=r"$\eta_S(r)$"); ax2.set(xlabel="graph radius $r$",ylabel=r"$R(r)/R_\infty$")
    ax3.set(xlabel="sampled coherence time $T$",ylabel=r"optimal integer radius $r^\star$")
    ax4.set(xlabel=r"sampled decision range $\ell_c$",ylabel=r"optimal integer radius $r^\star$")
    for axis,title in zip((ax,ax2,ax3,ax4),
                          ("(a) Spatial omission", "(b) Regret",
                           "(c) Coherence-time sweep", "(d) Decision-range sweep")):
        axis.set_title(title,loc="left",pad=3,fontsize=8)
    ax3.set_xticks(Tvals); ax4.set_xticks(ellvals)
    ax3.yaxis.set_major_locator(MaxNLocator(integer=True))
    ax4.yaxis.set_major_locator(MaxNLocator(integer=True))
    for a in axes.ravel(): a.grid(alpha=.16)
    ax.legend(frameon=False,ncol=2,fontsize=6.5); ax2.legend(frameon=False,fontsize=6.2,ncol=2)
    ax3.legend(frameon=False,ncol=2,fontsize=6.5); ax4.legend(frameon=False,ncol=2,fontsize=6.5)
    save(fig,OUTPUT_ROOT,"fig7_6_general_graphs",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp06_general_graphs.csv",rows)
    write_csv(OUTPUT_ROOT/"results/processed/exp06_comparative_statics.csv",supplemental)
    result["sampled_sweep_values"]={"latency_per_hop":[float(x) for x in c.get("latency_sweep",[.05,.08,.12,.18,.28])],
                                     "T":[float(x) for x in Tvals],
                                     "ell_c":[float(x) for x in ellvals],
                                     "kappa":[float(x) for x in c.get("kappa_sweep",[1.5,1.0,.7,.45,.3])]}
    result["sweep_archive"]="results/processed/exp06_comparative_statics.csv"
    result["curve_archive"]="results/processed/exp06_general_graphs.csv"
    write_json(OUTPUT_ROOT/"results/metadata/exp06.json",{**metadata(c["seed"],0,c,time.perf_counter()-start),"results":result})
    return result


def robustness(all_results):
    base_seed=9941; replicates=8; sample_sizes=[1000,3000,10000,30000]; rows=[]
    rho=.8; theory=float(temporal_fraction(rho))
    for replicate in range(replicates):
        # Each reported seed is the seed actually used for this replicate;
        # previously one stream was labelled with replicate indices 0--7.
        seed=base_seed+replicate; rng=np.random.default_rng(seed)
        for count in sample_sizes:
            z=rng.standard_normal(count); squared=theory*z*z
            estimate,se,ci_low,ci_high=sample_mean_ci(squared)
            rows.append({"replicate":replicate,"seed":seed,"samples":count,
                         "theory":theory,"estimate":estimate,"se":se,
                         "ci95_low":ci_low,"ci95_high":ci_high,
                         "abs_error":abs(estimate-theory)})
    write_csv(OUTPUT_ROOT/"results/processed/robustness_mc.csv",rows)
    fig,ax=plt.subplots(figsize=(3.4,2.35))
    for replicate in range(replicates):
        rr=[x for x in rows if x["replicate"]==replicate]
        ax.plot(sample_sizes,[x["abs_error"] for x in rr],"-o",ms=2,alpha=.55,
                label=f"replicate {replicate} (seed {base_seed+replicate})")
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set(xlabel="Monte Carlo samples",ylabel="absolute error")
    supplemental = OUTPUT_ROOT/"figures/supplementary"
    supplemental.mkdir(parents=True,exist_ok=True)
    ax.grid(alpha=.18); ax.legend(frameon=False,fontsize=4.8,ncol=2)
    fig.savefig(supplemental/"mc_convergence.pdf",bbox_inches="tight"); plt.close(fig)
    summary={"base_seed":base_seed,"replicates":replicates,"sample_sizes":sample_sizes,
             "rho":rho,"theory":theory,
             "seed_values":[base_seed+i for i in range(replicates)],
             "archive":"results/processed/robustness_mc.csv"}
    write_json(OUTPUT_ROOT/"results/metadata/robustness_mc.json",summary)
    return summary


def main():
    global OUTPUT_ROOT, PAPER_FIGURES
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root",type=Path,default=SOURCE_ROOT,
                        help="write generated numerics beneath this directory")
    parser.add_argument("--no-paper-copy",action="store_true",
                        help="do not refresh the manuscript's top-level figures")
    args=parser.parse_args()
    OUTPUT_ROOT=args.output_root.resolve()
    PAPER_FIGURES=None if args.no_paper_copy else REPO/"figures"
    for relative in ("results/raw", "results/processed", "results/metadata",
                     "figures/pdf", "figures/png", "figures/supplementary"):
        (OUTPUT_ROOT/relative).mkdir(parents=True,exist_ok=True)
    configure(); overall=time.perf_counter(); results={}
    for number,fn in enumerate((exp01,exp02,exp03,exp04,exp05,exp06),1):
        print(f"Running Experiment {number}...",flush=True); results[f"exp{number:02d}"]=fn()
    results["robustness"]=robustness(results)
    results["total_runtime_seconds"]=time.perf_counter()-overall
    write_json(OUTPUT_ROOT/"results/metadata/reference_run.json",results)
    print(json.dumps(results,indent=2)); print(f"Completed in {results['total_runtime_seconds']:.1f} s")


if __name__ == "__main__":
    main()
