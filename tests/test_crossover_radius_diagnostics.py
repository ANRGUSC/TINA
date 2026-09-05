import unittest

import numpy as np

from numerics.src.diagnostics import paired_crossover_estimate
from numerics.src.theory import (
    aggregate_eta_captured,
    aggregate_eta_omitted,
    aggregate_threshold,
    canonical_rstar,
    composed_regret,
)


class CrossoverRadiusDiagnosticsTests(unittest.TestCase):
    def test_paired_delta_method_keeps_cross_covariance(self):
        open_trials = np.array([1.0, 1.2, 0.8, 1.1, 0.9, 1.3])
        local_trials = np.array([0.2, 0.25, 0.16, 0.22, 0.18, 0.27])
        estimate = paired_crossover_estimate(open_trials, local_trials)
        expected = 0.5 * np.log(
            open_trials.mean() / (open_trials.mean() - local_trials.mean())
        )
        self.assertAlmostEqual(estimate["estimate"], expected)
        self.assertAlmostEqual(
            estimate["paired_covariance"], np.cov(open_trials, local_trials, ddof=1)[0, 1]
        )
        rinf = open_trials.mean()
        rloc = local_trials.mean()
        captured = rinf - rloc
        gradient = np.array(
            [-0.5 * rloc / (rinf * captured), 0.5 / captured]
        )
        covariance = np.cov(np.column_stack((open_trials, local_trials)), rowvar=False,
                            ddof=1)
        expected_se = np.sqrt(gradient @ covariance @ gradient / len(open_trials))
        self.assertAlmostEqual(estimate["se"], expected_se, places=14)
        unpaired_se = np.sqrt(
            (gradient[0] ** 2 * covariance[0, 0]
             + gradient[1] ** 2 * covariance[1, 1]) / len(open_trials)
        )
        self.assertNotAlmostEqual(estimate["se"], unpaired_se, places=8)
        self.assertLess(estimate["ci_low"], estimate["estimate"])
        self.assertGreater(estimate["ci_high"], estimate["estimate"])

    def test_zero_local_limit_has_zero_crossover_uncertainty(self):
        estimate = paired_crossover_estimate(
            np.array([0.8, 1.0, 1.2, 0.9]), np.zeros(4)
        )
        self.assertAlmostEqual(estimate["estimate"], 0.0)
        self.assertAlmostEqual(estimate["se"], 0.0)

    def test_paired_delta_method_rejects_invalid_captured_mean(self):
        with self.assertRaises(ValueError):
            paired_crossover_estimate(np.ones(4), np.full(4, 1.1))
        with self.assertRaises(ValueError):
            paired_crossover_estimate(np.array([1.0, np.nan]), np.array([0.1, 0.1]))

    def test_aggregate_eta_names_match_the_manuscript(self):
        for n in (5, 25, 100):
            for gamma in (0.0, 0.05, 0.5, 5.0):
                omitted = float(aggregate_eta_omitted(gamma, n))
                captured = float(aggregate_eta_captured(gamma, n))
                self.assertGreaterEqual(omitted, 0.0)
                self.assertLessEqual(omitted, 1.0)
                self.assertAlmostEqual(omitted + captured, 1.0, places=13)
                self.assertAlmostEqual(
                    np.exp(-2.0 * float(aggregate_threshold(gamma, n))),
                    captured,
                    places=13,
                )

    def test_aggregate_omission_matches_direct_matrix_regret(self):
        for n in (1, 5, 25):
            for q in (0.5, 2.0):
                for gamma in (0.0, 0.1, 5.0):
                    Q = q * np.eye(n) + gamma * np.ones((n, n))
                    K = np.linalg.solve(Q, np.eye(n))
                    local = np.eye(n) / (q + gamma)
                    local_error_map = K - local
                    omitted = np.trace(
                        local_error_map.T @ Q @ local_error_map
                    ) / np.trace(K.T @ Q @ K)
                    self.assertAlmostEqual(
                        float(aggregate_eta_omitted(gamma, n, q)),
                        float(omitted),
                        places=13,
                    )

    def test_fixed_radius_grid_diagnoses_positive_and_zero_regions(self):
        radius_grid = np.linspace(0.0, 4.0, 2501)
        radius_step = radius_grid[1] - radius_grid[0]
        checks = []
        for ell_s, length in ((0.05, 0.1), (0.4, 1.0), (1.0, 8.0)):
            theory = float(canonical_rstar(ell_s, 1.0, length))
            numeric = float(
                radius_grid[
                    np.argmin(composed_regret(radius_grid, ell_s, 1.0, length))
                ]
            )
            checks.append((theory, numeric, abs(numeric - theory) / radius_step))
        self.assertEqual(checks[0][0], 0.0)
        self.assertEqual(checks[0][1], 0.0)
        self.assertGreater(checks[-1][0], 0.0)
        self.assertGreater(checks[-1][1], 0.0)
        self.assertLessEqual(max(item[2] for item in checks), 0.5 + 1e-12)


if __name__ == "__main__":
    unittest.main()
