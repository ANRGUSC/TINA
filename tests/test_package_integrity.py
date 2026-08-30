import json
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
        self.assertLessEqual(max(v["max_mc_eta_error"] for k, v in exp5.items() if k != "environment"), 5e-4)

    def test_all_declared_build_inputs_exist(self):
        expected = [ROOT / "main.tex", ROOT / "references.bib"]
        expected.extend((ROOT / "figures").glob("fig7_*.pdf"))
        self.assertEqual(len(expected), 8)
        self.assertTrue(all(path.is_file() and path.stat().st_size > 0 for path in expected))


if __name__ == "__main__":
    unittest.main()
