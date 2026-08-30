"""Run all six experiments and regenerate Section 7 artifacts."""
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

from numerics.src.covariance import architecture_eta, check_psd, psd_power_covariance
from numerics.src.graph_models import exponential_decision_operator, graph_bundle
from numerics.src.plotting import COLORS, configure, save
from numerics.src.processes import exact_ou_pair
from numerics.src.regret import affine_rinf, mc_quadratic_regret
from numerics.src.theory import (
    aggregate_eta_local, aggregate_threshold, canonical_eta, canonical_rstar,
    composed_regret, temporal_fraction,
)
from numerics.src.utils import load_yaml, metadata, write_csv, write_json


def cfg(number):
    return load_yaml(SOURCE_ROOT / "config" / f"experiment_{number:02d}.yaml")


def stable_spd(rng, n, coupled=True):
    if not coupled:
        return np.eye(n)
    A = rng.normal(size=(n, n)) / np.sqrt(n)
    return A.T @ A + 0.7 * np.eye(n)


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
    rows, raw = [], {}
    fig, ax = plt.subplots(figsize=(3.45, 2.6))
    ax.plot(rhos, temporal_fraction(rhos), color="black", label=r"$1-e^{-2\tau/T}$")
    for sidx, name in enumerate(c["systems"]):
        n, Q, sigma, B = system_matrices(name, c["seed"] + sidx)
        K = np.linalg.solve(Q, B); rinf = affine_rinf(Q, B, sigma)
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
            if j in (0, len(rhos)//2, len(rhos)-1):
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
    np.savez_compressed(OUTPUT_ROOT/"results/raw/exp01_trial_regret.npz", **raw)
    diffs = np.array([x["mc_normalized"]-x["theory_normalized"] for x in rows])
    covdiff = np.array([x["mc_normalized"]-x["cov_normalized"] for x in rows])
    result = {"max_abs_error": float(abs(diffs).max()), "rmse": float(np.sqrt(np.mean(diffs**2))),
              "max_mc_cov_discrepancy": float(abs(covdiff).max()), "systems": 4,
              "points": len(rows), "samples_per_point": c["samples"]}
    write_json(OUTPUT_ROOT/"results/metadata/exp01.json", {**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":result})
    return result


def exp02():
    c=cfg(2); start=time.perf_counter(); rng=np.random.default_rng(c["seed"]); rows=[]
    empirical_boundaries=[]
    for n in c["n"]:
        for gamma in c["gamma_over_q"]:
            theta=rng.standard_normal((c["samples"],n))
            Q=np.eye(n)+gamma*np.ones((n,n)); K=np.linalg.solve(Q,np.eye(n))
            xstar=theta@K.T; uloc=theta/(1+gamma)
            loc_err=xstar-uloc
            rloc,_se,loc_trials=mc_quadratic_regret(loc_err,Q)
            open_mean,_open_se,open_trials=mc_quadratic_regret(xstar,Q)
            emp=0.5*np.log(open_mean/max(open_mean-rloc,1e-15))
            exact=float(aggregate_threshold(gamma,n))
            empirical_boundaries.append(emp)
            rows.append({"n":n,"gamma_over_q":gamma,"eta_local":float(aggregate_eta_local(gamma,n)),
                         "threshold_theory":exact,"threshold_empirical":emp,
                         "boundary_abs_error":abs(emp-exact),"rinf_empirical":open_mean,
                         "rloc_empirical":rloc})
    write_csv(OUTPUT_ROOT/"results/processed/exp02_local_global_crossover.csv",rows)
    np.savez_compressed(OUTPUT_ROOT/"results/raw/exp02_boundaries.npz", empirical=np.array(empirical_boundaries))
    gx=np.logspace(np.log10(.01),1,240); ry=np.linspace(0,c["rho_max"],240)
    X,Y=np.meshgrid(gx,ry); boundary=aggregate_threshold(X,100)
    winner=(Y>boundary).astype(float)
    fig,(ax,ax2)=plt.subplots(1,2,figsize=(6.9,2.6),gridspec_kw={"width_ratios":[1.25,1]})
    ax.contourf(X,Y,winner,levels=[-.5,.5,1.5],colors=["#D9EAF4","#F5D5C8"])
    ax.plot(gx,aggregate_threshold(gx,100),"k-",label=r"finite $n=100$")
    ax.plot(gx,.5*np.log1p(gx),"k--",label=r"$n\to\infty$")
    ax.set_xscale("log"); ax.set(xlabel=r"coupling $\gamma/q$",ylabel=r"staleness $\tau/T$",ylim=(0,c["rho_max"]))
    ax.text(.018,1.32,"fresh-local",fontsize=7)
    ax.text(8.2,.08,"stale-global",fontsize=7,ha="right")
    ax.legend(frameon=False,loc="center left",bbox_to_anchor=(.02,.72))
    for j,n in enumerate(c["n"]):
        rr=[r for r in rows if r["n"]==n]
        ax2.plot([r["gamma_over_q"] for r in rr],[r["threshold_theory"] for r in rr],
                 marker="o",ms=2.8,color=COLORS[j],label=f"n={n}")
        ax2.plot([r["gamma_over_q"] for r in rr],[r["threshold_empirical"] for r in rr],
                 linestyle="none",marker="x",ms=3,color=COLORS[j])
    ax2.set_xscale("log"); ax2.set(xlabel=r"$\gamma/q$",ylabel=r"crossover $\rho^\star$",xlim=(.01,10),ylim=(0,c["rho_max"]))
    ax2.legend(frameon=False,ncol=2); ax2.grid(alpha=.18)
    save(fig,OUTPUT_ROOT,"fig7_2_local_global_phase",PAPER_FIGURES)
    errors=np.array([r["boundary_abs_error"] for r in rows])
    result={"max_boundary_error":float(errors.max()),"mean_boundary_error":float(errors.mean()),
            "finite_n_gap_at_gamma10_n5":float(aggregate_threshold(10,5)-.5*np.log(11)),
            "samples_per_setting":c["samples"]}
    write_json(OUTPUT_ROOT/"results/metadata/exp02.json",{**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":result})
    return result


def exp03():
    c=cfg(3); start=time.perf_counter(); rng=np.random.default_rng(c["seed"]); rows=[]; results={}
    radius=np.linspace(0,c["D"],1001); fig,axes=plt.subplots(1,3,figsize=(7.15,2.45),sharey=True)
    for j,(name,p) in enumerate(c["regimes"].items()):
        eta=p["eta0"]*np.exp(-2*radius/p["ell_c"]); temporal=1-np.exp(-2*radius/p["vT"])
        spatial=np.exp(-2*radius/p["vT"])*eta; total=temporal+spatial
        rtheory=max(0,.5*p["ell_c"]*np.log(p["eta0"]*(1+p["vT"]/p["ell_c"])))
        rcap=min(c["D"],rtheory); rnum=float(radius[np.argmin(total)])
        mT=2/p["vT"]*np.ones_like(radius)
        mS=2*eta/(p["ell_c"]*(1-eta))
        # Independent Monte Carlo: temporal and residual spatial innovations.
        mc_sum=np.zeros_like(radius)
        remaining=c["samples"]
        while remaining:
            batch=min(1000,remaining)
            zt=rng.standard_normal((batch,len(radius)))
            zs=rng.standard_normal((batch,len(radius)))
            mc_sum+=np.sum((np.sqrt(temporal)*zt+np.sqrt(spatial)*zs)**2,axis=0)
            remaining-=batch
        mc=mc_sum/c["samples"]
        for k,r in enumerate(radius):
            rows.append({"regime":name,"radius":r,"total":total[k],"temporal":temporal[k],
                         "spatial":spatial[k],"mc_total":mc[k],"mT":mT[k],"mS":mS[k]})
        ax=axes[j]; ax.plot(radius,total,color="black",label=r"total $R/R_\infty$")
        ax.plot(radius,temporal,"--",color=COLORS[0],label="temporal")
        ax.plot(radius,spatial,":",color=COLORS[1],label="spatial")
        ax.plot(radius[::80],mc[::80],"o",mfc="none",ms=2.8,color=COLORS[2],label="Monte Carlo")
        ax.axvline(rcap,color=COLORS[3],ls="-.",label=r"theory $r^\star$")
        ax.plot(rnum,total.min(),"x",color="black",ms=5,label="grid minimum")
        ax.set(xlabel=r"radius $r/\ell_c$",title={"local":"local","interior":"interior","broad":"boundary/global"}[name])
        results[name]={"rstar_theory_capped":rcap,"rstar_numeric":rnum,
                       "rstar_abs_error":abs(rcap-rnum),"mc_max_abs_error":float(abs(mc-total).max())}
        if name=="interior":
            results[name]["marginal_gap_at_numeric_optimum"]=float(abs(mS[np.argmin(total)]-mT[np.argmin(total)]))
    axes[0].set_ylabel(r"normalized regret component")
    axes[0].legend(frameon=False,fontsize=6.4); [a.grid(alpha=.16) for a in axes]
    save(fig,OUTPUT_ROOT,"fig7_3_radius_regret",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp03_radius_regret.csv",rows)
    write_json(OUTPUT_ROOT/"results/metadata/exp03.json",{**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":results})
    return results


def exp04():
    c=cfg(4); start=time.perf_counter(); lo,hi,num=c["vT_over_lc"]; vlo,vhi,vnum=c["ell_s_over_lc"]
    vT=np.logspace(np.log10(lo),np.log10(hi),int(num)); ls=np.logspace(np.log10(vlo),np.log10(vhi),int(vnum))
    rows=[]; numeric=[]; theory=[]; step_errors=[]
    for s in ls:
        for L in vT:
            rt=float(canonical_rstar(s,1,L)); rmax=max(4.0,rt+1.0)
            rg=np.linspace(0,rmax,c["radius_grid_points"]); vals=composed_regret(rg,s,1,L)
            rn=float(rg[np.argmin(vals)]); step=float(rg[1]-rg[0])
            rows.append({"ell_s_over_lc":s,"vT_over_lc":L,"rstar_numeric":rn,"rstar_theory":rt,
                         "abs_error":abs(rn-rt),"radius_step":step})
            numeric.append(rn); theory.append(rt); step_errors.append(step)
    write_csv(OUTPUT_ROOT/"results/processed/exp04_radius_scaling.csv",rows)
    Z=np.array(numeric).reshape(len(ls),len(vT)).T
    fig,(ax,ax2)=plt.subplots(1,2,figsize=(6.9,2.65),gridspec_kw={"width_ratios":[1.2,1]},constrained_layout=True)
    mesh=ax.pcolormesh(ls,vT,Z,shading="auto",cmap="viridis")
    ax.plot(ls,2*ls,"w--",lw=1.5,label=r"$vT=2\ell_s$")
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set(xlabel=r"$\ell_s/\ell_c$",ylabel=r"$vT/\ell_c$")
    ax.legend(frameon=False,loc="lower right"); fig.colorbar(mesh,ax=ax,label=r"$\hat r^\star/\ell_c$",pad=.025)
    numeric=np.array(numeric); theory=np.array(theory)
    ax2.scatter(theory,numeric,s=5,alpha=.35,color=COLORS[0]); lim=max(theory.max(),numeric.max())
    ax2.plot([0,lim],[0,lim],"k--"); ax2.set(xlabel=r"closed-form $r^\star/\ell_c$",ylabel=r"grid $\hat r^\star/\ell_c$")
    ax2.grid(alpha=.18)
    save(fig,OUTPUT_ROOT,"fig7_4_radius_phase",PAPER_FIGURES)
    errors=abs(numeric-theory)
    result={"mae":float(errors.mean()),"max_error":float(errors.max()),
            "max_radius_grid_step":float(max(step_errors)),"points":len(rows),
            "transition_misclassifications":int(np.sum((numeric>1e-8)!=(theory>1e-8)))}
    # One-dimensional numerical comparative statics in the interior regime.
    sweep_rows=[]
    base={"T":5.0,"v":2.0,"ell_s":0.4,"ell_c":1.0}
    sweep_values={"T":[2.0,3.0,5.0,8.0,12.0],"v":[0.8,1.2,2.0,3.0,5.0],
                  "ell_s":[0.1,0.2,0.4,0.8,1.5],"ell_c":[0.4,0.7,1.0,1.7,3.0]}
    directions={}
    for parameter,values in sweep_values.items():
        opt=[]
        for value in values:
            p={**base,parameter:value}; rg=np.linspace(0,5,5001)
            vals=composed_regret(rg,p["ell_s"],p["ell_c"],p["v"]*p["T"])
            rn=float(rg[np.argmin(vals)]); opt.append(rn)
            sweep_rows.append({"parameter":parameter,"value":value,"rstar_numeric":rn})
        delta=np.diff(opt)
        expected="decreasing" if parameter=="ell_s" else "increasing"
        directions[parameter]={"expected":expected,"observed_monotone":bool(np.all(delta<=1e-12) if expected=="decreasing" else np.all(delta>=-1e-12)),"rstar":opt}
    write_csv(OUTPUT_ROOT/"results/processed/exp04_comparative_statics.csv",sweep_rows)
    result["comparative_statics"]=directions
    write_json(OUTPUT_ROOT/"results/metadata/exp04.json",{**metadata(c["seed"],0,c,time.perf_counter()-start),"results":result})
    return result


def exp05():
    c=cfg(5); start=time.perf_counter(); rng=np.random.default_rng(c["seed"])
    _,dist,lap=graph_bundle("ring",n=c["n"]); sigma=psd_power_covariance(lap,c["kappa"],c["nu"])
    radii=np.arange(0,int(np.max(dist))+1); rows=[]; result={}
    fig,(ax,ax2)=plt.subplots(1,2,figsize=(6.9,2.55))
    for j,ell in enumerate(c["ell_c"]):
        K=exponential_decision_operator(dist,ell); eta=np.array([architecture_eta(sigma,K,dist,r) for r in radii])
        regret=1-np.exp(-2*c["latency_per_hop"]*radii/c["T"])*(1-eta)
        rstar=int(radii[np.argmin(regret)])
        # Independent MC checks at representative radii using exact conditional policies.
        check_r=sorted(set([0,rstar,min(rstar+3,int(radii[-1])),int(radii[-1])]))
        mc_errors=[]
        theta=rng.multivariate_normal(np.zeros(c["n"]),sigma,size=c["samples"]); x=theta@K.T
        total=np.mean(x*x)
        for r in check_r:
            omitted=0.0
            for i in range(c["n"]):
                obs=np.flatnonzero(dist[i]<=r)
                beta=np.linalg.solve(sigma[np.ix_(obs,obs)],sigma[np.ix_(obs,np.arange(c["n"]))]@K[i])
                pred=theta[:,obs]@beta
                omitted+=np.mean((x[:,i]-pred)**2)
            mc_eta=omitted/(c["n"]*total); mc_errors.append(abs(mc_eta-eta[r]))
        for r,e,rr in zip(radii,eta,regret): rows.append({"ell_c":ell,"radius":int(r),"eta_S":e,"regret":rr})
        ax.plot(radii,eta,color=COLORS[j],label=fr"$\ell_c={ell}$")
        ax2.plot(radii,regret,color=COLORS[j],label=fr"$\ell_c={ell}$")
        ax2.plot(rstar,regret[rstar],"o",color=COLORS[j],ms=4)
        result[str(ell)]={"rstar":rstar,"eta0":float(eta[0]),"max_mc_eta_error":float(max(mc_errors))}
    # raw state correlation is unchanged across K
    corr=np.array([np.mean([sigma[i,j]/np.sqrt(sigma[i,i]*sigma[j,j]) for i in range(c["n"]) for j in range(c["n"]) if dist[i,j]==r]) for r in radii])
    ax.plot(radii,corr,"k--",lw=1,label="state correlation")
    ax.set(xlabel="graph radius $r$",ylabel=r"$\eta_S(r)$",xlim=(0,15)); ax2.set(xlabel="graph radius $r$",ylabel=r"$R(r)/R_\infty$",xlim=(0,15))
    ax.legend(frameon=False); ax2.legend(frameon=False); ax.grid(alpha=.16); ax2.grid(alpha=.16)
    save(fig,OUTPUT_ROOT,"fig7_5_decision_relevance",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp05_decision_relevance.csv",rows)
    np.savez_compressed(OUTPUT_ROOT/"results/raw/exp05_fixed_environment.npz",sigma=sigma,distances=dist,laplacian=lap)
    mineig,psd=check_psd(sigma); result["environment"]={"sigma_condition":float(np.linalg.cond(sigma)),"min_eigenvalue":mineig,"psd":psd}
    write_json(OUTPUT_ROOT/"results/metadata/exp05.json",{**metadata(c["seed"],c["samples"],c,time.perf_counter()-start),"results":result})
    return result


def graph_curve(kind,c,T=None,ell_c=None,kappa=None):
    _,dist,lap=graph_bundle(kind,n=c["n"],seed=c["seed"]+11)
    sigma=psd_power_covariance(lap,kappa or c["kappa"],c["nu"]); K=exponential_decision_operator(dist,ell_c or c["ell_c"])
    radii=np.arange(int(np.max(dist))+1); eta=np.array([architecture_eta(sigma,K,dist,r) for r in radii])
    useT=T or c["T"]; regret=1-np.exp(-2*c["latency_per_hop"]*radii/useT)*(1-eta)
    return radii,eta,regret,int(radii[np.argmin(regret)]),sigma,dist,lap


def exp06():
    c=cfg(6); start=time.perf_counter(); rows=[]; result={}
    fig,axes=plt.subplots(2,2,figsize=(7.05,5.0)); ax,ax2,ax3,ax4=axes.ravel()
    supplemental=[]
    for j,kind in enumerate(c["graphs"]):
        radii,eta,regret,rstar,sigma,dist,lap=graph_curve(kind,c)
        for r,e,rr in zip(radii,eta,regret): rows.append({"graph":kind,"radius":int(r),"eta_S":e,"regret":rr})
        upto=min(len(radii),17); ax.plot(radii[:upto],eta[:upto],marker="o",ms=2.2,color=COLORS[j],label=kind)
        ax2.plot(radii[:upto],regret[:upto],marker="o",ms=2.2,color=COLORS[j],label=f"{kind} ($r^*={rstar}$)")
        mineig,psd=check_psd(sigma); result[kind]={"rstar":rstar,"eta0":float(eta[0]),"diameter":int(radii[-1]),
            "sigma_condition":float(np.linalg.cond(sigma)),"min_eigenvalue":mineig,"psd":psd}
        latency_values=[.05,.08,.12,.18,.28]
        latency_rstars=[]
        for latency in latency_values:
            rr=1-np.exp(-2*latency*radii/c["T"])*(1-eta)
            radius_opt=int(radii[np.argmin(rr)]); latency_rstars.append(radius_opt)
            supplemental.append({"graph":kind,"sweep":"latency_per_hop","value":latency,"rstar":radius_opt})
        result[kind]["rstar_by_latency"]=latency_rstars
        np.savez_compressed(OUTPUT_ROOT/f"results/raw/exp06_{kind}_graph.npz",sigma=sigma,distances=dist,laplacian=lap)
    Tvals=np.array([1.5,2.5,4,6,9,14]); ellvals=np.array([.7,1.2,2,3.5,6])
    for j,kind in enumerate(c["graphs"]):
        rt=[graph_curve(kind,c,T=float(T))[3] for T in Tvals]
        re=[graph_curve(kind,c,ell_c=float(e))[3] for e in ellvals]
        ax3.plot(Tvals,rt,marker="o",ms=3,color=COLORS[j],label=kind)
        ax4.plot(ellvals,re,marker="o",ms=3,color=COLORS[j],label=kind)
        result[kind]["rstar_by_T"]=rt; result[kind]["rstar_by_ell_c"]=re
        kappa_values=[1.5,1.0,.7,.45,.3]
        rk=[graph_curve(kind,c,kappa=float(k))[3] for k in kappa_values]
        result[kind]["rstar_by_kappa"]=rk
        for value,radius_opt in zip(Tvals,rt): supplemental.append({"graph":kind,"sweep":"T","value":value,"rstar":radius_opt})
        for value,radius_opt in zip(ellvals,re): supplemental.append({"graph":kind,"sweep":"ell_c","value":value,"rstar":radius_opt})
        for value,radius_opt in zip(kappa_values,rk): supplemental.append({"graph":kind,"sweep":"kappa","value":value,"rstar":radius_opt})
    ax.set(xlabel="graph radius $r$",ylabel=r"$\eta_S(r)$"); ax2.set(xlabel="graph radius $r$",ylabel=r"$R(r)/R_\infty$")
    ax3.set(xlabel="coherence time $T$",ylabel=r"optimal discrete radius $r^\star$")
    ax4.set(xlabel=r"decision range $\ell_c$",ylabel=r"optimal discrete radius $r^\star$")
    for a in axes.ravel(): a.grid(alpha=.16)
    ax.legend(frameon=False,ncol=2); ax2.legend(frameon=False,fontsize=6.5,ncol=2)
    save(fig,OUTPUT_ROOT,"fig7_6_general_graphs",PAPER_FIGURES)
    write_csv(OUTPUT_ROOT/"results/processed/exp06_general_graphs.csv",rows)
    write_csv(OUTPUT_ROOT/"results/processed/exp06_comparative_statics.csv",supplemental)
    write_json(OUTPUT_ROOT/"results/metadata/exp06.json",{**metadata(c["seed"],0,c,time.perf_counter()-start),"results":result})
    return result


def robustness(all_results):
    rng=np.random.default_rng(9941); sample_sizes=[1000,3000,10000,30000]; rows=[]
    rho=.8; theory=float(temporal_fraction(rho))
    for seed in range(8):
        for count in sample_sizes:
            z=rng.standard_normal(count); estimate=float(np.mean((np.sqrt(theory)*z)**2))
            rows.append({"seed":seed,"samples":count,"estimate":estimate,"abs_error":abs(estimate-theory)})
    write_csv(OUTPUT_ROOT/"results/processed/robustness_mc.csv",rows)
    fig,ax=plt.subplots(figsize=(3.4,2.35))
    for seed in range(8):
        rr=[x for x in rows if x["seed"]==seed]; ax.plot(sample_sizes,[x["abs_error"] for x in rr],"-o",ms=2,alpha=.55)
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set(xlabel="Monte Carlo samples",ylabel="absolute error")
    supplemental = OUTPUT_ROOT/"figures/supplementary"
    supplemental.mkdir(parents=True,exist_ok=True)
    ax.grid(alpha=.18); fig.savefig(supplemental/"mc_convergence.pdf",bbox_inches="tight"); plt.close(fig)


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
    robustness(results)
    results["total_runtime_seconds"]=time.perf_counter()-overall
    write_json(OUTPUT_ROOT/"results/metadata/reference_run.json",results)
    print(json.dumps(results,indent=2)); print(f"Completed in {results['total_runtime_seconds']:.1f} s")


if __name__ == "__main__":
    main()
