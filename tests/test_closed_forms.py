import unittest

import numpy as np

from numerics.src.theory import (
    aggregate_eta_local,
    aggregate_threshold,
    canonical_rstar,
    composed_regret,
    temporal_fraction,
)


class ClosedFormTests(unittest.TestCase):
    def test_temporal_endpoints_and_monotonicity(self):
        rho = np.linspace(0.0, 4.0, 101)
        values = temporal_fraction(rho)
        self.assertAlmostEqual(values[0], 0.0)
        self.assertTrue(np.all(np.diff(values) > 0.0))
        self.assertTrue(np.all(values < 1.0))

    def test_crossover_identity(self):
        for n in (5, 25, 100):
            for gamma in (0.05, 0.5, 5.0):
                eta = float(aggregate_eta_local(gamma, n))
                threshold = float(aggregate_threshold(gamma, n))
                self.assertAlmostEqual(np.exp(-2.0 * threshold), eta, places=13)

    def test_canonical_radius_matches_direct_minimum(self):
        for ell_s, ell_c, length in ((0.4, 1.0, 4.0), (0.1, 2.0, 8.0), (2.0, 1.0, 0.5)):
            theory = float(canonical_rstar(ell_s, ell_c, length))
            radius = np.linspace(0.0, max(5.0, theory + 1.0), 20001)
            numeric = float(radius[np.argmin(composed_regret(radius, ell_s, ell_c, length))])
            self.assertLessEqual(abs(numeric - theory), radius[1] - radius[0] + 1e-12)


if __name__ == "__main__":
    unittest.main()
