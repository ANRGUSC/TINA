"""Build v2-d and its two separate supporting PDFs without changing v1, v2-a, v2-b, or v2-c."""
from pathlib import Path
import re
import shutil
import subprocess

PAPER = Path(__file__).resolve().parent
BUILD = PAPER / 'build'
BUILD.mkdir(exist_ok=True)
for name in ('main.tex', 'appendices.tex', 'supplement.tex',
             'supplement-body.tex', 'companion.tex', 'references.bib'):
    shutil.copy2(PAPER / name, BUILD / name)
shutil.copytree(PAPER / 'figures', BUILD / 'figures', dirs_exist_ok=True)
documents = {'tina-v2-d': 'main.tex',
             'tina-v2-d-supplement': 'supplement.tex',
             'tina-v2-d-companion': 'companion.tex'}

def run(command, name):
    result = subprocess.run(command, cwd=BUILD, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (BUILD / f'{name}.txt').write_text(result.stdout, encoding='utf-8')
    if result.returncode:
        raise SystemExit(result.stdout)

# Repeated passes resolve references between the paper and separate supplements.
for pass_number in range(4):
    for job, source in documents.items():
        run(['pdflatex', '-interaction=nonstopmode', '-halt-on-error',
             '-file-line-error', f'-jobname={job}', source],
            f'{job}-pass-{pass_number}')
        if pass_number == 0 and job == 'tina-v2-d':
            run(['bibtex', job], f'{job}-bibtex')

for job in documents:
    log = (BUILD / f'{job}.log').read_text(encoding='utf-8', errors='replace')
    for pattern in (r'undefined references', r'Citation .* undefined',
                    r'Reference .* undefined', r'multiply.defined',
                    r'Label\(s\) may have changed'):
        if re.search(pattern, log, re.I):
            raise SystemExit(f'{job}: build rejected: {pattern}')
    shutil.copy2(BUILD / f'{job}.pdf', PAPER / f'{job}.pdf')
    print('Built:', PAPER / f'{job}.pdf')
    for line in log.splitlines():
        if 'Overfull' in line or 'Output written' in line:
            print(line)
