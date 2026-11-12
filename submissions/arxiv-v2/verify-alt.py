"""Deterministic mathematical and preservation checks for the alternative.

Run after build-alt.py. No publication experiment or baseline file is changed.
"""
from pathlib import Path
from itertools import product
from collections import Counter
import hashlib
import json
import re
import sys

import numpy as np
from scipy.optimize import minimize_scalar

PAPER = Path(__file__).resolve().parent
ROOT = PAPER.parents[1]
sys.path.insert(0, str(ROOT))
from numerics.experiments.run_all import cfg, graph_curve

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

manifest = json.loads((PAPER / 'alt-baseline.json').read_text())
for path, expected in manifest['tracked_baseline_sha256'].items():
    assert digest(ROOT / path) == expected, ('baseline modified', path)
assert digest(PAPER / 'major-revision.md') == manifest['untracked_revision_spec_sha256']

main = (PAPER / 'main-alt.tex').read_text(encoding='utf-8')
appendix = (PAPER / 'technical-appendices-alt.tex').read_text(encoding='utf-8')
companion = (PAPER / 'appendices-alt.tex').read_text(encoding='utf-8')
old = (PAPER / 'main.tex').read_text(encoding='utf-8')
for source in (main + appendix, main + appendix + companion):
    labels = re.findall(r'\\label\{([^}]+)\}', source)
    refs = re.findall(r'\\(?:ref|eqref)\{([^}]+)\}', source)
    assert not (set(refs) - set(labels))
    assert not [k for k, v in Counter(labels).items() if v > 1]
    assert '---' not in source and '\u2014' not in source
assert len(re.findall(r'\\section\{', main)) == 7
assert len(re.findall(r'\\section\{', appendix)) == 4
assert r'\label{eq:OU_process}' not in main
assert r'\label{eq:OU_process}' in appendix
assert r'\label{lem:radner_projection}' not in main
assert r'\label{lem:radner_projection}' in appendix
assert r'\label{lem:innovation_split}' not in main + appendix
for env in ('figure',):
    pattern = r'\\begin\{' + env + r'\}.*?\\end\{' + env + r'\}'
    figures = re.findall(pattern, main, re.S)
    assert len(figures) == 6
    assert r'\label{fig:snapshot-architectures}' in figures[0]
    assert r'\label{fig:field-and-cost}' in figures[1]
    assert re.findall(pattern, old, re.S) == figures[2:]
def section(text, title):
    return text.split(r'\section{' + title + '}')[1].split(r'\section{')[0]
assert section(old, 'Numerical Illustrations') == section(main, 'Numerical Illustrations')
assert section(old, 'Related Work') == section(main, 'Related Work')

def all_policy_optimum(states, pi, q, k, observations, transition):
    """Complete indicator basis, one independent table per agent."""
    columns = []
    for agent, observed in enumerate(observations):
        values = np.unique(states[:, observed], axis=0) if observed else np.zeros((1, 0))
        for value in values:
            col = np.zeros((len(states), len(observations)))
            col[:, agent] = np.all(states[:, observed] == value, axis=1)
            columns.append(col)
    basis = np.stack(columns, axis=2)
    targets = states @ k.T
    joint = pi[:, None] * transition
    hessian = np.einsum('s,sip,ij,sjq->pq', pi, basis, q, basis)
    rhs = np.einsum('st,sip,ij,tj->p', joint, basis, q, targets)
    coefficients = np.linalg.solve(hessian, rhs)
    action = np.einsum('sip,p->si', basis, coefficients)
    error = targets[None, :, :] - action[:, None, :]
    regret = .5 * np.einsum('st,sti,ij,stj->', joint, error, q, error)
    return float(regret), action

raw = np.array(list(product((-1., 0., 1.), repeat=2)))
pi = np.array([5, 1, 2, 2, 3, 4, 1, 2, 5], dtype=float)
pi /= pi.sum()
states = raw - pi @ raw
q = np.array([[2., .4], [.4, 1.5]])
k = np.array([[1., .7], [-.3, 1.2]])
targets = states @ k.T
open_regret = .5 * np.einsum('s,si,ij,sj->', pi, targets, q, targets)
composition_checks = []
for name, observations in [('local', [(0,), (1,)]),
                           ('full', [(0, 1), (0, 1)]),
                           ('none', [(), ()])]:
    fresh, fresh_policy = all_policy_optimum(states, pi, q, k, observations, np.eye(9))
    if name == 'full':
        assert fresh < 1e-20
    elif name == 'none':
        assert abs(fresh - open_regret) < 1e-12
    else:
        assert 0 < fresh < open_regret
        # A nonzero residual verifies that the optimal table need not be affine.
        affine_residual = max(float(np.max(np.abs(
            fresh_policy[:, i] - np.column_stack([np.ones(9), states[:, i]]) @
            np.linalg.lstsq(np.column_stack([np.ones(9), states[:, i]]), fresh_policy[:, i], rcond=None)[0])))
            for i in range(2))
        assert affine_residual > 1e-4
    for a in (0., .05, .25, .6, .95, 1.):
        transition = a * np.eye(9) + (1 - a) * np.broadcast_to(pi, (9, 9))
        assert np.allclose(pi @ transition, pi)
        assert np.allclose(transition @ states, a * states)
        actual, policy = all_policy_optimum(states, pi, q, k, observations, transition)
        expected = (1-a*a)*open_regret + a*a*fresh
        error = abs(actual-expected)
        policy_error = float(np.max(np.abs(policy-a*fresh_policy)))
        assert error < 2e-12 and policy_error < 2e-12
        composition_checks.append({'observations': name, 'a': a,
                                   'regret_error': error, 'policy_error': policy_error})
transition = .6*np.eye(9) + .4*np.broadcast_to(pi, (9, 9))
innovation = states[None, :, :] - .6*states[:, None, :]
conditional_energy = np.einsum('st,sti,sti->s', transition, innovation, innovation)
assert np.ptp(conditional_energy) > .1  # Innovation is not independent of old state.

aggregate_errors = []
for n, stiffness, coupling in product((2, 3, 5), (.4, 1., 2.3), (0., .2, 3.)):
    variance = 1.7
    theta = np.array(list(product((-np.sqrt(variance), np.sqrt(variance)), repeat=n)))
    weights = np.full(len(theta), 1/len(theta))
    qmat = stiffness*np.eye(n) + coupling*np.ones((n, n))
    kmat = np.linalg.inv(qmat)
    regret, action = all_policy_optimum(theta, weights, qmat, kmat, [(i,) for i in range(n)], np.eye(len(theta)))
    closed_open = n*variance*(stiffness+coupling*(n-1))/(2*stiffness*(stiffness+coupling*n))
    closed_local = n*variance*coupling**2*(n-1)/(2*stiffness*(stiffness+coupling)*(stiffness+coupling*n))
    direct_open = variance/2*np.trace(kmat)
    assert abs(direct_open-closed_open) < 1e-11
    assert np.max(np.abs(action-theta/(stiffness+coupling))) < 1e-11
    assert abs(regret-closed_local) < 1e-11
    eta = coupling**2*(n-1)/((stiffness+coupling)*(stiffness+coupling*(n-1)))
    threshold = .5*np.log((stiffness+coupling)*(stiffness+coupling*(n-1))/(stiffness*(stiffness+coupling*n)))
    assert abs(eta-closed_local/closed_open) < 1e-12
    assert abs(threshold + .5*np.log1p(-eta)) < 1e-12
    aggregate_errors.append(abs(regret-closed_local))

def generic(eta, lc, length):
    return .5*lc*max(0., np.log(eta*(1+length/lc)))
radius_checks = []
for name, eta, lc, length, cap in [('local', .25, 1., .2, 2.),
                                 ('interior', .7, 1., 4., 2.),
                                 ('capped', .9, 1., 100., 2.),
                                 ('zero_derivative', .5, 1., 1., 2.)]:
    optimum = min(cap, generic(eta, lc, length))
    gain = lambda r: np.exp(-2*r/length)*(1-eta*np.exp(-2*r/lc))
    numerical = minimize_scalar(lambda r: -gain(r), bounds=(0, cap), method='bounded', options={'xatol': 1e-12})
    candidates = [0., cap, float(numerical.x)]
    best = max(candidates, key=gain)
    assert abs(best-optimum) < 2e-7
    assert abs(gain(best)-gain(optimum)) < 1e-12
    radius_checks.append({'case': name, 'closed_radius': optimum, 'numerical_radius': best})

def canonical(lc, ls, length):
    return .5*lc*max(0., np.log((lc+length)/(lc+2*ls)))
for lc, ls, length in product((.3, 1., 5.), (.2, 1., 3.), (.4, 2., 10.)):
    eta = lc/(lc+2*ls)
    assert abs(canonical(lc, ls, length)-generic(eta, lc, length)) < 1e-14
    assert (canonical(lc, ls, length)>0) == (length>2*ls)
    assert canonical(lc, ls, 2*ls) == 0
    if length > 2*ls:
        r = canonical(lc, ls, length)
        assert canonical(lc*1.01, ls, length) > r
        assert canonical(lc, ls*1.001, length) < r
        assert canonical(lc, ls, length*1.01) > r
assert abs(canonical(1e6, 1., 5.)-1.5) < 1e-5

graphs = {}
config = cfg(6)
for kind in config['graphs']:
    radii, eta, regret, rstar, sigma, dist, lap = graph_curve(kind, config)
    assert np.array_equal(radii, np.arange(int(dist.max())+1))
    assert rstar == int(np.argmin(regret))
    archived = np.load(ROOT/f'numerics/results/raw/exp06_{kind}_graph.npz')
    assert np.max(np.abs(regret-archived['regret'])) < 1e-12
    graphs[kind] = {'radius_count': len(radii), 'diameter': int(radii[-1]), 'rstar': rstar}

report = {'baseline_commit': manifest['commit'],
          'baseline_files_unchanged': len(manifest['tracked_baseline_sha256']),
          'all_references_resolve_in_submission_and_companion': True,
          'numerical_section_and_related_work_verbatim': True,
          'four_original_numerical_figure_environments_verbatim': True,
          'two_explanatory_figures_added': True,
          'non_gaussian_all_policy_checks': composition_checks,
          'nonlinear_local_policy_affine_fit_residual': affine_residual,
          'innovation_conditional_energy_range': float(np.ptp(conditional_energy)),
          'aggregate_cases': len(aggregate_errors), 'aggregate_max_regret_error': max(aggregate_errors),
          'generic_radius_cases': radius_checks,
          'canonical_substitution_threshold_comparative_statics_and_limit': 'pass',
          'finite_graph_exhaustive_search': graphs,
          'source_sha256': {n: digest(PAPER/n) for n in ('main-alt.tex','technical-appendices-alt.tex','appendices-alt.tex','companion-alt.tex')}}
(PAPER/'alt-verification.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(json.dumps(report, indent=2))
