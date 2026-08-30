import unittest

import numpy as np

from numerics.src.covariance import architecture_eta, check_psd, psd_power_covariance
from numerics.src.graph_models import exponential_decision_operator, graph_bundle
from numerics.src.processes import exact_ou_pair


class CovarianceTests(unittest.TestCase):
    def test_graph_covariance_psd_and_conditioned(self):
        _, distances, laplacian = graph_bundle("ring", n=32)
        sigma = psd_power_covariance(laplacian, kappa=0.8, nu=1.5)
        minimum, passed = check_psd(sigma)
        self.assertTrue(passed)
        self.assertGreater(minimum, 0.0)
        self.assertLess(np.linalg.cond(sigma), 200.0)
        self.assertLess(np.max(np.abs(sigma - sigma.T)), 1e-12)
        operator = exponential_decision_operator(distances, ell_c=2.0)
        eta = np.array([architecture_eta(sigma, operator, distances, r) for r in range(17)])
        self.assertTrue(np.all(np.diff(eta) <= 1e-12))
        self.assertAlmostEqual(eta[-1], 0.0, places=12)

    def test_exact_ou_pair_has_target_moments(self):
        rng = np.random.default_rng(104)
        sigma = np.array([[1.0, 0.35], [0.35, 1.4]])
        past, current = exact_ou_pair(rng, sigma, rho=0.7, samples=150000)
        empirical_cross = past.T @ current / len(past)
        self.assertLess(np.max(np.abs(empirical_cross - np.exp(-0.7) * sigma)), 0.02)


if __name__ == "__main__":
    unittest.main()
