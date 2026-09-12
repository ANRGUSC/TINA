#!/usr/bin/env python3
"""Package the checked report, frozen manuscript, and reproducible audit."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parent
package = root / 'output/TINA_LCSS_Submission_Lamport_Review.zip'
files = [
    'README.md', 'review_manifest.json', 'qa_report.py', 'package_report.py', 'build_report.py',
    'check_audit.py', 'audit_checks.json', 'frozen_conversion.json',
    'forward_ledger.json', 'reverse_graph.json', 'qa_summary.json',
    'source/letter.tex', 'source/letter.pdf', 'source/letter_source.zip',
    'plugin/convert-lamport.md', 'plugin/forward-lamport.md',
    'plugin/reverse-lamport.md', 'plugin/LICENSE',
    'TINA_LCSS_Submission_Lamport_Report.tex',
    'TINA_LCSS_Submission_Lamport_Report.pdf',
]
for name in files:
    assert (root / name).is_file(), name
with ZipFile(package, 'w', compression=ZIP_DEFLATED, compresslevel=9) as archive:
    for name in files:
        destination = name.removeprefix('output/')
        archive.write(root / name, 'TINA_LCSS_Submission_Lamport_Review/' + destination)
with ZipFile(package) as archive:
    assert archive.testzip() is None
    assert len(archive.namelist()) == len(files)
print(f'{package}: {len(files)} files, {package.stat().st_size} bytes; ZIP integrity checked.')
