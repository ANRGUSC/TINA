import unittest

import numpy as np

from numerics.src.policies import gaussian_linear_predictor
from numerics.src.processes import exact_ou_pair
from numerics.src.utils import sample_mean_ci
from numerics.experiments.run_all import _neighbor_regret_gaps


class SimulationDiagnosticsTests(unittest.TestCase):
    def test_predictor_accepts_target_by_observation_cross_covariance(self):
        cov_obs = np.array([
            [2.0, 0.2, 0.1],
            [0.2, 1.5, -0.1],
            [0.1, -0.1, 1.2],
        ])
        cov_y_obs = np.array([
            [0.4, -0.2, 0.7],
            [0.1, 0.8, -0.3],
        ])
        expected = np.linalg.solve(cov_obs, cov_y_obs.T).T
        actual = gaussian_linear_predictor(cov_y_obs, cov_obs)
        self.assertEqual(actual.shape, (2, 3))
        np.testing.assert_allclose(actual, expected)
        np.testing.assert_allclose(actual @ cov_obs, cov_y_obs)

    def test_scalar_predictor_keeps_one_dimensional_convention(self):
        cov_obs = np.array([[2.0, 0.5], [0.5, 1.5]])
        cross = np.array([0.3, -0.4])
        actual = gaussian_linear_predictor(cross, cov_obs)
        np.testing.assert_allclose(actual, np.linalg.solve(cov_obs, cross))
        np.testing.assert_allclose(actual @ cov_obs, cross)

    def test_exact_ou_zero_delay_has_no_covariance_jitter(self):
        covariance = np.array([[1.0, 0.25], [0.25, 1.4]])
        past, current = exact_ou_pair(
            np.random.default_rng(7), covariance, rho=0.0, samples=128
        )
        np.testing.assert_array_equal(current, past)

        with self.assertRaises(np.linalg.LinAlgError):
            exact_ou_pair(np.random.default_rng(7), np.zeros((2, 2)), rho=0.5, samples=4)

    def test_sample_mean_ci_uses_observed_second_moment(self):
        mean, se, low, high = sample_mean_ci(np.array([1.0, 2.0, 3.0, 4.0]))
        self.assertAlmostEqual(mean, 2.5)
        self.assertAlmostEqual(se, np.std([1.0, 2.0, 3.0, 4.0], ddof=1) / 2.0)
        self.assertAlmostEqual(low, mean - 1.96 * se)
        self.assertAlmostEqual(high, mean + 1.96 * se)

    def test_integer_optimum_archives_available_neighbor_gaps(self):
        gaps = _neighbor_regret_gaps(
            np.array([0, 1, 2]), np.array([0.4, 0.1, 0.2]), optimum=1
        )
        self.assertAlmostEqual(gaps["rstar_regret"], 0.1)
        self.assertAlmostEqual(gaps["left_regret_gap"], 0.3)
        self.assertAlmostEqual(gaps["right_regret_gap"], 0.1)


if __name__ == "__main__":
    unittest.main()
