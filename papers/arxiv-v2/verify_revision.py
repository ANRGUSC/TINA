"""Independent finite-state and archived-grid checks for the v2 refinement."""
from pathlib import Path
from itertools import product
from collections import Counter
import csv
import difflib
import hashlib
import json
import re
import numpy as np

PAPER = Path(__file__).resolve().parent
ROOT = PAPER.parents[1]
BASE = ROOT / 'papers/full'
source = (PAPER / 'main.tex').read_text(encoding='utf-8')
baseline = (BASE / 'main.tex').read_text(encoding='utf-8')
labels = re.findall(r'\\label\{([^}]+)\}', source)
refs = re.findall(r'\\(?:ref|eqref)\{([^}]+)\}', source)
assert not (set(refs) - set(labels))
assert not [key for key, count in Counter(labels).items() if count > 1]
assert '---' not in source and '\u2014' not in source

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

unchanged = {}
for path in sorted((BASE / 'figures').glob('*.pdf')):
    assert digest(path) == digest(PAPER / 'figures' / path.name)
    unchanged[path.name] = digest(path)
assert digest(BASE / 'references.bib') == digest(PAPER / 'references.bib')
assert digest(BASE / 'main.tex') == digest(ROOT / 'submissions/arxiv/source/main.tex')

def section(text, title):
    start = text.index('\\section{' + title + '}')
    end = text.find('\\section{', start + 10)
    return text[start:end if end >= 0 else len(text)]

assert section(source, 'Related Work') == section(baseline, 'Related Work')
assert source[:source.index('\\begin{abstract}')].replace(
    r'\date{September 2026}', r'\date{August 2026}'
) == baseline[:baseline.index('\\begin{abstract}')]

# A stationary non-Gaussian Markov chain on {-1,+1}^3 with common scalar
# conditional decay. Optimize over ALL measurable agentwise policies by using
# a complete indicator basis, with non-diagonal positive-definite Q.
states = np.array(list(product((-1.0, 1.0), repeat=3)))
rng = np.random.default_rng(260906351)
matrix = rng.normal(size=(3, 3))
q = matrix.T @ matrix + np.eye(3)
k = rng.normal(size=(3, 3))
mean = np.array([1.3, -0.4, 2.0])
targets = states @ k.T + mean
obs_sets = ((0,), (1, 2), (0, 2))
columns = []
for agent, observed in enumerate(obs_sets):
    for pattern in product((-1.0, 1.0), repeat=len(observed)):
        column = np.zeros((len(states), 3))
        column[:, agent] = np.all(states[:, observed] == pattern, axis=1)
        columns.append(column)
basis = np.stack(columns, axis=2)

def optimize(joint):
    # joint[old,current] weights; full indicator basis includes constants.
    marginal = joint.sum(axis=1)
    hessian = np.einsum('s,sip,ij,sjq->pq', marginal, basis, q, basis)
    rhs = np.einsum('st,sip,ij,tj->p', joint, basis, q, targets)
    coeff = np.linalg.solve(hessian, rhs)
    action = np.einsum('sip,p->si', basis, coeff)
    errors = targets[None, :, :] - action[:, None, :]
    regret = 0.5 * np.einsum('st,sti,ij,stj->', joint, errors, q, errors)
    return regret, action

zero_regret, zero_action = optimize(np.eye(8) / 8)
centered = targets - mean
open_regret = 0.5 * np.einsum('si,ij,sj->', centered, q, centered) / 8
finite_checks = []
for a in (0.0, 0.15, 0.6, 0.95, 1.0):
    transition = np.prod((1 + a * states[:, None, :] * states[None, :, :]) / 2, axis=2)
    joint = transition / 8
    direct, action = optimize(joint)
    expected = (1 - a*a) * open_regret + a*a * zero_regret
    error = abs(direct - expected)
    policy_error = float(np.max(np.abs(action - (mean + a*(zero_action-mean)))))
    assert error < 2e-12 and policy_error < 2e-12
    finite_checks.append({'decay': a, 'regret_error': float(error),
                          'optimal_policy_error': policy_error})

# Compare the two independently parameterized omission expressions in v1 and v2.
max_omission_error = 0.0
for ls, lc, radius in product((0.03, 0.4, 1., 8.), (0.07, 1., 5.), (0., .2, 2.)):
    kappa, lam = 1/lc, 1/ls
    conditional = kappa*lam/(2*(kappa+lam)**2)*np.exp(-2*kappa*radius)
    variance = kappa*(2*kappa+lam)/(2*(kappa+lam)**2)
    revised = lc/(lc+2*ls)*np.exp(-2*radius/lc)
    max_omission_error = max(max_omission_error, abs(conditional/variance-revised))
assert max_omission_error < 1e-14

rows = list(csv.DictReader((ROOT / 'numerics/results/processed/exp04_radius_scaling.csv').open()))
grid = np.arange(2501) * 0.0016
grid_errors = []
archived_errors = []
for row in rows:
    ls = float(row['ell_s_over_lc'])
    length = float(row['vT_over_lc'])
    eta0 = 1 / (1 + 2*ls)
    closed = max(0., .5*np.log(eta0*(1+length)))
    costs = 1 - np.exp(-2*grid/length)*(1-eta0*np.exp(-2*grid))
    numerical = float(grid[np.argmin(costs)])
    assert abs(numerical-float(row['rstar_numeric'])) < 1e-12
    archived_errors.append(abs(closed-float(row['rstar_theory'])))
    grid_errors.append(abs(closed-numerical))
assert max(archived_errors) < 1e-12
# A minimum of an asymmetric curve need not round to the nearest grid point;
# the half-step error is approximate. The rigorous bracket bound is one step.
assert max(grid_errors) < 0.0016

report = {
    'baseline_source_sha256': digest(BASE / 'main.tex'),
    'reviewed_source_sha256': digest(PAPER / 'main.tex'),
    'references_and_labels': 'pass',
    'baseline_matches_arxiv_source': True,
    'title_authors_preamble_unchanged_except_date': True,
    'title_page_date': 'September 2026',
    'related_work_verbatim_unchanged': True,
    'bibliography_verbatim_unchanged': True,
    'figures_unchanged_sha256': unchanged,
    'non_gaussian_coupled_team_exact_enumeration': finite_checks,
    'v1_v2_omission_max_abs_error': max_omission_error,
    'archived_experiment4_points': len(rows),
    'v2_vs_archived_theory_max_abs_error': max(archived_errors),
    'direct_grid_max_abs_error': max(grid_errors),
    'direct_grid_mean_abs_error': float(np.mean(grid_errors)),
}
(PAPER / 'verification.json').write_text(json.dumps(report, indent=2)+'\n')
(PAPER / 'changes-from-v1.diff').write_text(''.join(difflib.unified_diff(
    baseline.splitlines(keepends=True), source.splitlines(keepends=True),
    fromfile='papers/full/main.tex (v1)', tofile='papers/arxiv-v2/main.tex (v2 draft)')),
    encoding='utf-8')
print(json.dumps({key: val for key, val in report.items() if key != 'figures_unchanged_sha256'}, indent=2))
