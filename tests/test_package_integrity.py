import json
import csv
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class PackageIntegrityTests(unittest.TestCase):
    def test_source_audit(self):
        completed = subprocess.run(
            [sys.executable, str(ROOT / "scripts/audit_sources.py")],
            cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout)

    def test_reference_metadata_meets_acceptance_thresholds(self):
        metadata = ROOT / "numerics/results/metadata"
        exp1 = json.loads((metadata / "exp01.json").read_text())["results"]
        exp2 = json.loads((metadata / "exp02.json").read_text())["results"]
        exp3 = json.loads((metadata / "exp03.json").read_text())["results"]
        exp4 = json.loads((metadata / "exp04.json").read_text())["results"]
        exp5 = json.loads((metadata / "exp05.json").read_text())["results"]
        self.assertLessEqual(exp1["max_abs_error"], 0.02)
        self.assertLessEqual(exp2["max_boundary_error"], 0.007)
        self.assertLessEqual(max(v["mc_max_abs_error"] for v in exp3.values()), 0.025)
        self.assertLessEqual(exp4["max_error"], exp4["max_radius_grid_step"] + 1e-12)
        checks_path = ROOT / "numerics/results/processed/exp05_mc_checks.csv"
        self.assertTrue(checks_path.is_file())
        with checks_path.open(newline="", encoding="utf-8") as handle:
            checks = list(csv.DictReader(handle))
        self.assertGreater(len(checks), 0)
        # The analytical normalizer makes the check an ordinary sample-mean
        # comparison.  Use a four-SE smoke threshold: a fixed absolute bound
        # would incorrectly reject the high-variance ell_c=6, r=0 check.
        self.assertTrue(all(
            float(row["abs_error"]) <= 4.0 * float(row["eta_mc_se"]) + 1e-12
            for row in checks
        ))
        self.assertTrue(all(float(row["normalizer_analytic"]) > 0 for row in checks))

    def test_all_declared_build_inputs_exist(self):
        expected = [ROOT / "main.tex", ROOT / "references.bib"]
        expected.extend((ROOT / "figures").glob("fig7_*.pdf"))
        self.assertEqual(len(expected), 8)
        self.assertTrue(all(path.is_file() and path.stat().st_size > 0 for path in expected))
        self.assertTrue((ROOT / "numerics/results/raw/exp01_system_matrices.npz").is_file())

    def test_manuscript_figures_are_exact_archive_copies(self):
        for figure in (ROOT / "figures").glob("fig7_*.pdf"):
            archived = ROOT / "numerics/figures/pdf" / figure.name
            self.assertEqual(figure.read_bytes(), archived.read_bytes(), figure.name)


if __name__ == "__main__":
    unittest.main()
