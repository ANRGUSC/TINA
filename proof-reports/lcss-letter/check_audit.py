#!/usr/bin/env python3
"""Independent finite-dimensional checks for the Lamport review.

These checks support a mathematical audit; they are not formal proof checking.
Run with Python 3, NumPy and SciPy. All parameters and seeds are recorded.
"""
from pathlib import Path
import hashlib
import json
import math

import numpy as np
import scipy
import sys
from scipy.optimize import brentq

ROOT = Path(__file__).resolve().parent
SEED = 260906351


def endpoints(a, b, kappa):
    n = len(b)
    ci = (1 + kappa) * a + b * (1 + kappa * (1 - 1 / n))
    h = np.mean(1 / ci)
    k = a / (ci * (1 - kappa * a * h))
    p = 1 / (1 / a + np.sum(1 / b))
    return k, a - a * np.mean(k), p, p / b


def team_check(a, b, kappa, rate, age, architecture):
    """Solve first-order equations from raw observations, not claimed gains."""
    n = len(b)
    old_times = [-1.3, -.4, 0.0]
    if architecture == 'local':
        labels = [[(i, age)] for i in range(n)]
    else:
        shared = [(j, r) for r in old_times for j in range(n)]
        labels = [shared + [(i, q * age) for q in (.23, .61, 1.)]
                  for i in range(n)]
    dim = len(labels[0])
    H = (1 + kappa) * np.eye(n) - kappa * np.ones((n, n)) / n

    def cov(x, y):
        i, r = x
        j, s = y
        return (a + (b[i] if i == j else 0.)) * math.exp(-rate * abs(r - s))

    Q = np.zeros((n * dim, n * dim))
    rhs = np.zeros(n * dim)
    for i in range(n):
        ii = slice(i * dim, (i + 1) * dim)
        rhs[ii] = [a * math.exp(-rate * abs(age - r)) for _, r in labels[i]]
        for j in range(n):
            jj = slice(j * dim, (j + 1) * dim)
            Q[ii, jj] = H[i, j] * np.array([[cov(x, y) for y in labels[j]]
                                          for x in labels[i]])
    theta = np.linalg.solve(Q, rhs)
    optimum = a - 2 * rhs @ theta / n + theta @ Q @ theta / n
    k, jl, jp, weights = endpoints(a, b, kappa)
    claimed = np.zeros_like(theta)
    rho = math.exp(-rate * age)
    for i in range(n):
        for q, (j, r) in enumerate(labels[i]):
            if architecture == 'local':
                coefficient = k[i]
            elif r == 0.:
                coefficient = rho * weights[j] - (rho * k[i] if j == i else 0.)
            elif j == i and r == age:
                coefficient = k[i]
            else:
                coefficient = 0.
            claimed[i * dim + q] = coefficient
    formula = jl if architecture == 'local' else rho * rho * jp + (1 - rho * rho) * jl
    return {
        'architecture': architecture, 'n': n, 'a': a, 'b': b.tolist(),
        'kappa': kappa, 'lambda': rate, 'age': age, 'matrix_size': n * dim,
        'computed_loss': float(optimum), 'formula_loss': float(formula),
        'loss_error': float(abs(optimum - formula)),
        'coefficient_error': float(np.max(np.abs(theta - claimed))),
        'conditional_normal_residual': float(np.max(np.abs(Q @ claimed - rhs))),
        'minimum_eigenvalue': float(np.linalg.eigvalsh(Q)[0]),
    }


def path_check(a, b, rate, age):
    n = len(b)
    Sigma = a * np.ones((n, n)) + np.diag(b)
    errors = []
    for fraction in [.07, .29, .53, .91, 1.]:
        r = fraction * age
        rho = math.exp(-rate*age)
        rr = math.exp(-rate*r)
        # Expand Cov(Y(t)-rho Y(0),Y(r)-rr Y(0)) from raw covariances.
        raw_cross = Sigma*(math.exp(-rate*(age-r))-rr*math.exp(-rate*age)
                          -rho*math.exp(-rate*r)+rho*rr)
        for i in range(n):
            projected = (Sigma[:,i]/Sigma[i,i])*raw_cross[i,i]
            errors.append(float(np.max(np.abs(raw_cross[:,i]-projected))))
    _, _, p, weights = endpoints(a, b, 0.)
    # Cov(X - mu_P, Y_j) = a - sum_l weights_l Sigma_lj.
    residual = a * np.ones(n) - weights @ Sigma
    return max(errors), float(np.max(np.abs(residual)))


def discrete_check(q, lag, kappa):
    """Solve a Gaussian AR(1) team from integer-time raw observations."""
    a, b, n = .8, np.array([.4,.7,1.2]), 3
    current = lag
    shared = [(j,r) for r in (-2,-1,0) for j in range(n)]
    labels = [shared+[(i,r) for r in range(1,current+1)] for i in range(n)]
    dim=len(labels[0])
    H=(1+kappa)*np.eye(n)-kappa*np.ones((n,n))/n
    def cov(x,y):
        i,r=x; j,s=y
        return (a+(b[i] if i==j else 0.))*q**abs(r-s)
    Q=np.zeros((n*dim,n*dim)); rhs=np.zeros(n*dim)
    for i in range(n):
        ii=slice(i*dim,(i+1)*dim)
        rhs[ii]=[a*q**abs(current-r) for _,r in labels[i]]
        for j in range(n):
            jj=slice(j*dim,(j+1)*dim)
            Q[ii,jj]=H[i,j]*np.array([[cov(x,y) for y in labels[j]] for x in labels[i]])
    coefficients=np.linalg.solve(Q,rhs)
    cost=a-2*rhs@coefficients/n+coefficients@Q@coefficients/n
    _,jl,jp,_=endpoints(a,b,kappa)
    claimed=q**(2*lag)*jp+(1-q**(2*lag))*jl
    return {'q':q,'lag':lag,'kappa':kappa,'loss':float(cost),
            'formula':float(claimed),'error':float(abs(cost-claimed))}


def refresh_check(rng, scenario):
    M = int(rng.integers(1, 5))
    gamma = np.exp(rng.uniform(-1.7, 1.2, M))
    amp = np.exp(rng.uniform(-2.0, .7, M))
    ccrit = float(np.sum(amp / gamma))
    ratio = [.05, .5, .95, 1., 1.4][scenario % 5]
    c = ratio * ccrit

    def B(T):
        return float(np.sum(amp / gamma * (-np.expm1(-gamma*T))))

    def H(T):
        z = gamma * T
        return float(np.sum(amp / gamma * (-np.expm1(-z) - z * np.exp(-z))))

    Tstar = None
    if c < ccrit:
        right = 1 / min(gamma)
        while H(right) < c:
            right *= 2
        Tstar = float(brentq(lambda t: H(t)-c, 1e-12, right, xtol=1e-13))
        g = (c-B(Tstar))/Tstar
        root_error = abs(H(Tstar)-c)
        value_error = abs(g + np.sum(amp*np.exp(-gamma*Tstar)))
    else:
        g, root_error, value_error = 0., 0., 0.

    R = 30.
    latency = .6
    count = int(rng.integers(0, 40))
    generations = np.sort(rng.uniform(0, R, count))
    receptions = generations + latency
    receptions = receptions[receptions < R]
    gain = 0.
    for j, start in enumerate(receptions):
        stop = receptions[j+1] if j+1 < len(receptions) else R
        gain += B(stop-start)
    relative_cost = c * count - gain
    slack = relative_cost - (R*g-ccrit)
    grid = np.geomspace(1e-5, 1e5, 301)
    periodic_slack = min((c-B(t))/t-g for t in grid)
    # Explicit minimum-interval check below the threshold.
    constrained_slack = 0.
    if Tstar is not None:
        lower = Tstar * float(rng.uniform(.1, 2.5))
        tc = max(lower, Tstar)
        constrained = (c-B(tc))/tc
        constrained_slack = min((c-B(t))/t-constrained
                                for t in np.geomspace(lower, lower*1e4, 201))
    return {'components': M, 'price_ratio': ratio,
            'threshold': ccrit, 'period': Tstar,
            'generation_count': count, 'reception_count': len(receptions),
            'root_error': root_error, 'value_error': float(value_error),
            'finite_horizon_bound_slack': float(slack),
            'periodic_grid_slack': float(periodic_slack),
            'minimum_interval_grid_slack': float(constrained_slack)}


def main():
    rng = np.random.default_rng(SEED)
    teams, paths = [], []
    for q in range(24):
        n = int(rng.integers(2, 7))
        a = float(np.exp(rng.uniform(-1, 1)))
        b = np.exp(rng.uniform(-1.5, 1.5, n))
        kappa = 0. if q % 6 == 0 else float(np.exp(rng.uniform(-2, 2)))
        rate = float(np.exp(rng.uniform(-1, 1)))
        age = float(rng.uniform(.12, 2.))
        for architecture in ['local', 'full_delayed_history_and_private_path']:
            teams.append(team_check(a, b, kappa, rate, age, architecture))
        paths.append(path_check(a, b, rate, age))
    schedules = [refresh_check(rng, q) for q in range(200)]
    discrete=[discrete_check(q,lag,kappa) for q in (.15,.6,.95)
              for lag in (1,2,4) for kappa in (0.,1.7)]
    summary = {
        'linear_systems': len(teams),
        'maximum_system_size': max(x['matrix_size'] for x in teams),
        'maximum_loss_error': max(x['loss_error'] for x in teams),
        'maximum_coefficient_error': max(x['coefficient_error'] for x in teams),
        'maximum_conditional_normal_residual': max(x['conditional_normal_residual'] for x in teams),
        'minimum_system_eigenvalue': min(x['minimum_eigenvalue'] for x in teams),
        'maximum_path_projection_cross_covariance': max(x[0] for x in paths),
        'maximum_pooled_residual_cross_covariance': max(x[1] for x in paths),
        'discrete_systems':len(discrete),
        'maximum_discrete_loss_error':max(x['error'] for x in discrete),
        'schedule_checks': len(schedules),
        'maximum_period_equation_error': max(x['root_error'] for x in schedules),
        'maximum_optimal_value_error': max(x['value_error'] for x in schedules),
        'minimum_finite_horizon_bound_slack': min(x['finite_horizon_bound_slack'] for x in schedules),
        'minimum_periodic_grid_slack': min(x['periodic_grid_slack'] for x in schedules),
        'minimum_constrained_grid_slack': min(x['minimum_interval_grid_slack'] for x in schedules),
    }
    assert summary['maximum_loss_error'] < 1e-10
    assert summary['maximum_coefficient_error'] < 1e-9
    assert summary['maximum_conditional_normal_residual'] < 1e-10
    assert summary['maximum_path_projection_cross_covariance'] < 1e-10
    assert summary['maximum_discrete_loss_error'] < 1e-10
    assert summary['minimum_system_eigenvalue'] > 0
    assert summary['minimum_finite_horizon_bound_slack'] >= -1e-10
    assert summary['minimum_periodic_grid_slack'] >= -1e-10
    assert summary['minimum_constrained_grid_slack'] >= -1e-10
    hashes = {name: hashlib.sha256((ROOT/'source'/name).read_bytes()).hexdigest()
              for name in ['letter.tex','letter.pdf']}
    result = {'environment': {'python':sys.version.split()[0], 'numpy':np.__version__, 'scipy':scipy.__version__}, 'seed': SEED, 'scope': 'Finite-dimensional numerical audit, not formal proof.',
              'source_sha256': hashes, 'summary': summary,
              'team_checks': teams, 'refresh_checks': schedules,
              'discrete_checks':discrete, 'path_projection_checks':paths}
    (ROOT/'audit_checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(summary,indent=2))


if __name__ == '__main__':
    main()
