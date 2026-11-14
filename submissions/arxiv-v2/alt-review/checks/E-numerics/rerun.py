"""Rerun repo experiment functions with outputs redirected to scratch; compare with archive."""
import sys, csv, json
from pathlib import Path
import numpy as np
ROOT = Path("/Users/scottmoeller/Documents/github/TINA")
sys.path.insert(0, str(ROOT))
from numerics.experiments import run_all as ex
OUT = Path(__file__).resolve().parent / "rerun_out"
for d in ("results/raw", "results/processed", "results/metadata"):
    (OUT / d).mkdir(parents=True, exist_ok=True)
ex.OUTPUT_ROOT = OUT; ex.PAPER_FIGURES = None; ex.configure()
res = {}
for name, fn in (("exp02", ex.exp02), ("exp03", ex.exp03), ("exp05", ex.exp05), ("exp06", ex.exp06)):
    res[name] = fn()
def cmp(name):
    a = list(csv.DictReader(open(ROOT / "numerics/results/processed" / name)))
    b = list(csv.DictReader(open(OUT / "results/processed" / name)))
    assert len(a) == len(b), (name, len(a), len(b))
    m = 0.0
    for x, y in zip(a, b):
        for k in x:
            try: m = max(m, abs(float(x[k]) - float(y[k])))
            except ValueError: assert x[k] == y[k], (name, k, x[k], y[k])
    return len(a), m
for n in ("exp02_local_global_crossover.csv", "exp03_radius_regret.csv", "exp05_decision_relevance.csv",
          "exp05_mc_checks.csv", "exp06_general_graphs.csv", "exp06_comparative_statics.csv"):
    print(n, "rows,maxdiff vs archive:", cmp(n))
print(json.dumps({k: res[k] for k in ("exp02", "exp03")}, indent=1)[:3000])
print({k: v["rstar"] for k, v in res["exp05"].items() if k[0].isdigit()})
print({k: (v["rstar"], v["diameter"], v["rstar_by_T"], v["rstar_by_ell_c"]) for k, v in res["exp06"].items() if isinstance(v, dict) and "rstar" in v})
