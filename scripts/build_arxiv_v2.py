"""Build the clean v2 submission and companion; create a source-only upload ZIP."""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PAPER = ROOT / 'submissions/arxiv-v2'
COMPANION = ROOT / 'submissions/arxiv-v2-companion'

def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    if result.returncode:
        raise SystemExit(result.stdout)

def check(build, job):
    log = (build / (job + '.log')).read_text(errors='replace')
    for pattern in (r'undefined references', r'Citation .* undefined',
                    r'Reference .* undefined', r'multiply.defined',
                    r'Label\(s\) may have changed', r'Overfull'):
        if re.search(pattern, log, re.I):
            raise SystemExit(f'{job}: {pattern}')

scratch = ROOT / 'tmp'
scratch.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='arxiv-v2-', dir=scratch) as directory:
    build = Path(directory)
    for path in PAPER.rglob('*'):
        if path.is_file() and path.suffix != '.zip' and path.name != 'tina-v2.pdf':
            dest = build / path.relative_to(PAPER)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
    latex = ['pdflatex', '-interaction=nonstopmode', '-halt-on-error', '-file-line-error']
    # Default job name matches the bibliography bundled for arXiv.
    run(latex + ['main-v2.tex'], build)
    run(['bibtex', 'main-v2'], build)
    for _ in range(2):
        run(latex + ['main-v2.tex'], build)
    check(build, 'main-v2')
    pdf_output = ROOT / 'output/pdf'
    pdf_output.mkdir(parents=True, exist_ok=True)
    shutil.copy2(build / 'main-v2.pdf', pdf_output / 'tina-v2.pdf')
    shutil.copy2(build / 'main-v2.pdf', PAPER / 'tina-v2.pdf')
    shutil.copy2(build / 'main-v2.bbl', PAPER / 'main-v2.bbl')
    # Companion imports the main paper's equation numbers, but is not uploaded.
    shutil.copy2(build / 'main-v2.aux', build / 'tina-v2.aux')
    for path in COMPANION.rglob('*'):
        if path.is_file() and (path.suffix != '.pdf' or path.parent.name == 'figures'):
            dest = build / path.relative_to(COMPANION)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
    for _ in range(3):
        run(latex + ['-jobname=tina-v2-alt-companion', 'companion-alt.tex'], build)
    check(build, 'tina-v2-alt-companion')
    shutil.copy2(build / 'tina-v2-alt-companion.pdf', COMPANION / 'tina-v2-alt-companion.pdf')

output = ROOT / 'output/arxiv'
output.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(output / 'tina-v2-source.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(PAPER.rglob('*')):
        if path.is_file() and path.suffix != '.zip' and path.name != 'tina-v2.pdf':
            archive.write(path, path.relative_to(PAPER).as_posix())
shutil.copy2(output / 'tina-v2-source.zip', PAPER / 'tina-v2-source.zip')
print('Built:', ROOT / 'output/pdf/tina-v2.pdf')
print('Built companion; upload package:', output / 'tina-v2-source.zip')
