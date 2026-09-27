"""Build only this v2 draft, keeping the v1 manuscript and submission untouched."""
from pathlib import Path
import re
import shutil
import subprocess

PAPER = Path(__file__).resolve().parent
BUILD = PAPER / 'build'
BUILD.mkdir(exist_ok=True)
for name in ('main.tex', 'appendices.tex', 'references.bib'):
    shutil.copy2(PAPER / name, BUILD / name)
shutil.copytree(PAPER / 'figures', BUILD / 'figures', dirs_exist_ok=True)
latex = ['pdflatex', '-interaction=nonstopmode', '-halt-on-error',
         '-file-line-error', '-jobname=tina-v2', 'main.tex']
for index, command in enumerate((latex, ['bibtex', 'tina-v2'], latex, latex, latex), 1):
    result = subprocess.run(command, cwd=BUILD, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (BUILD / f'pass-{index}.txt').write_text(result.stdout, encoding='utf-8')
    if result.returncode:
        raise SystemExit(result.stdout)
log = (BUILD / 'tina-v2.log').read_text(encoding='utf-8', errors='replace')
for pattern in (r'undefined references', r'Citation .* undefined',
                r'Reference .* undefined', r'multiply.defined',
                r'Label\(s\) may have changed'):
    if re.search(pattern, log, re.I):
        raise SystemExit(f'Build rejected: {pattern}')
shutil.copy2(BUILD / 'tina-v2.pdf', PAPER / 'tina-v2.pdf')
print('Built:', PAPER / 'tina-v2.pdf')
for line in log.splitlines():
    if 'Overfull' in line or 'Output written' in line:
        print(line)
