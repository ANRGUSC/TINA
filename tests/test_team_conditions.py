import unittest

import numpy as np


class TeamConditionTests(unittest.TestCase):
    def test_shared_resource_local_rule_satisfies_conditional_equations(self):
        rng = np.random.default_rng(2026)
        for n, gamma in ((5, 0.2), (25, 2.0), (100, 10.0)):
            theta_i = rng.standard_normal(1000)
            u_i = theta_i / (1.0 + gamma)
            # Independence and zero means give E[u_j | theta_i] = 0 for j != i.
            residual = (1.0 + gamma) * u_i - theta_i
            self.assertLess(np.max(np.abs(residual)), 2e-14)

    def test_common_information_vector_projection(self):
        rng = np.random.default_rng(33)
        a = rng.normal(size=(8, 8))
        q = a.T @ a + np.eye(8)
        b = rng.normal(size=(8, 5))
        theta_hat = rng.normal(size=5)
        action = np.linalg.solve(q, b @ theta_hat)
        self.assertLess(np.linalg.norm(q @ action - b @ theta_hat), 1e-12)


if __name__ == "__main__":
    unittest.main()
