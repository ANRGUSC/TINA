"""Independent covariance checks behind the scalar numerical illustrations."""
import unittest

import numpy as np

from numerics.src.covariance import architecture_eta, psd_power_covariance
from numerics.src.graph_models import exponential_decision_operator, graph_bundle
from numerics.src.theory import canonical_eta


class ArchitectureCompositionTests(unittest.TestCase):
    def test_delayed_neighborhood_policy_matches_composed_regret(self):
        # Compute the covariance of each actual policy error on the joint
        # (past, current) state, rather than inserting eta into the loss.
        _, distances, laplacian = graph_bundle("path", n=9)
        sigma = psd_power_covariance(laplacian, kappa=0.7, nu=1.5)
        decision = exponential_decision_operator(distances, ell_c=2.0)
        total_variance = np.trace(decision @ sigma @ decision.T)
        for radius in (0, 1, 3, 8):
            for rho in (0.0, 0.3, 1.2):
                a = np.exp(-rho)
                joint = np.block([[sigma, a * sigma], [a * sigma, sigma]])
                policy_error = np.zeros((9, 18))
                policy_error[:, 9:] = decision
                for i in range(9):
                    obs = np.flatnonzero(distances[i] <= radius)
                    cross = a * decision[i] @ sigma[:, obs]
                    policy_error[i, obs] = -np.linalg.solve(
                        sigma[np.ix_(obs, obs)], cross
                    )
                direct = np.trace(policy_error @ joint @ policy_error.T)
                eta = architecture_eta(sigma, decision, distances, radius)
                composed = 1.0 - a * a * (1.0 - eta)
                self.assertAlmostEqual(direct / total_variance, composed, places=12)

    def test_canonical_omission_from_discretized_field_covariance(self):
        # Truncate the canonical line to [-12,12] and refine its mesh. Gaussian
        # conditioning on field samples should converge to the continuum law;
        # neither the covariance nor the decision kernel uses canonical_eta.
        previous_error = None
        for spacing in (0.1, 0.05, 0.025):
            position = np.arange(-12.0, 12.0 + spacing / 2.0, spacing)
            weights = np.exp(-np.abs(position)) * spacing  # ell_c = 1
            covariance = np.exp(-np.abs(position[:, None] - position[None, :]) / 0.4)
            cross = weights @ covariance
            variance = cross @ weights
            errors = []
            for radius in (0.0, 0.5, 1.0, 2.0):
                observed = np.flatnonzero(np.abs(position) <= radius + 1e-9)
                explained = cross[observed] @ np.linalg.solve(
                    covariance[np.ix_(observed, observed)], cross[observed]
                )
                direct = (variance - explained) / variance
                errors.append(abs(direct - float(canonical_eta(radius, 0.4, 1.0))))
            error = max(errors)
            if previous_error is not None:
                self.assertLess(error, previous_error / 3.0)
            previous_error = error
        self.assertLess(previous_error, 3.5e-4)


if __name__ == "__main__":
    unittest.main()
