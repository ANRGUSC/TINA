"""Build and validate the public reading guide from a pinned manuscript."""
from pathlib import Path
from html.parser import HTMLParser
import hashlib
import json
import re
import shutil
import subprocess
import sys

GUIDE = Path(__file__).resolve().parent
REPO = GUIDE.parents[1]
manifest = json.loads((GUIDE / 'manuscript.json').read_text())

def verified(path, expected):
    data = path.read_bytes()
    actual = hashlib.sha256(data).hexdigest()
    if actual != expected:
        raise SystemExit(f'Manuscript/resource fingerprint mismatch: {path.relative_to(REPO)}. '
                         'Review the guide against this revision and update manuscript.json intentionally.')
    return data

verified(REPO / manifest['manuscript_path'], manifest['manuscript_sha256'])
pdf = verified(REPO / manifest['submission_pdf_path'], manifest['submission_pdf_sha256'])
if (REPO / 'papers/lcss/main.pdf').read_bytes() != pdf:
    raise SystemExit('The editable manuscript PDF and submission PDF differ.')
report = verified(REPO / manifest['report_path'], manifest['report_sha256'])
if (GUIDE / 'dist/paper.pdf').read_bytes() != pdf:
    raise SystemExit('Update dist/paper.pdf to the exact submission PDF before publishing.')
if (GUIDE / 'dist/proof-report.pdf').read_bytes() != report:
    raise SystemExit('Update dist/proof-report.pdf to the recorded report PDF before publishing.')
subprocess.run([sys.executable, str(GUIDE / 'build_content.py')], check=True)
subprocess.run(['node', '--check', str(GUIDE / 'dist/app.js')], check=True)
subprocess.run(['node', str(GUIDE / 'validate_math.js')], check=True)

class Assets(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ('href', 'src') and value and not value.startswith(('http:', 'https:', 'data:', '#')):
                if not (GUIDE / 'dist' / value).is_file():
                    raise SystemExit(f'Missing guide asset: {value}')

Assets().feed((GUIDE / 'dist/index.html').read_text())
for css in (GUIDE / 'dist').rglob('*.css'):
    for url in re.findall(r'url\([\'\"]?([^\)\'\"]+)', css.read_text()):
        if not url.startswith(('http:', 'https:', 'data:')) and not (css.parent / url).is_file():
            raise SystemExit(f'Missing stylesheet asset: {url}')

site = REPO / '_site'
site.mkdir(exist_ok=True)
target = site / 'lcss-letter'
if target.exists():
    shutil.rmtree(target)
shutil.copytree(GUIDE / 'dist', target)
(site / '.nojekyll').write_text('')
(site / 'index.html').write_text('''<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>TINA reading guides</title><style>body{max-width:46rem;margin:4rem auto;padding:0 1.5rem;
font:22px/1.7 Arial,sans-serif;color:#122e46}h1{line-height:1.2}a{color:#1256a0}</style>
<h1>TINA reading guides</h1>
<p><a href="lcss-letter/">Too Late to Coordinate: When Local Information Beats Global Sharing</a></p>
<p>Notation, results, and fully worked proofs of the six-page L-CSS submission manuscript. It has not been accepted for publication.</p>
<p><a href="https://github.com/ANRGUSC/TINA">Manuscripts, simulations, and proof reports on GitHub</a></p>
</html>''')
print('Validated site: _site/lcss-letter/')
