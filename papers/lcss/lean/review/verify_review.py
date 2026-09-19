#!/usr/bin/env python3
"""Audit supplementary correspondence proofs against the current built core.
Usage: python3 review/verify_review.py /absolute/path/to/proof-project
Core fresh replay is performed separately by scripts/verify.py.
"""
import datetime, hashlib, json, os, re, shutil, subprocess, sys, time
from pathlib import Path
review = Path(__file__).resolve().parent
bundle = review.parent
built = Path(sys.argv[1]).resolve()
project = bundle / 'proof-project'
lake = os.environ.get('C5_LAKE') or shutil.which('lake')
if not lake:
    raise RuntimeError('lake not found; install elan and put lake on PATH')
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
contract = json.loads((project/'contracts/review-contract.lock.json').read_text())
files = contract['files_sha256']
for rel, expected in files.items():
    if sha(project/rel) != expected or sha(built/rel) != expected:
        raise RuntimeError(f'Core source/contract drift: {rel}')
source = (review/'C5Checks.lean').read_text()
assert not re.search(r'\b(sorry|admit|sorryAx|native_decide)\b|^\s*(axiom|unsafe|opaque|run_cmd)\s', source, re.M)
env = os.environ.copy()
for key in ['PATH','LEAN_PATH']:
    val = subprocess.check_output([lake,'env','printenv',key],cwd=built,text=True).strip()
    env[key] = str(review)+os.pathsep+val if key == 'LEAN_PATH' else val
commands = [
    ('version',['lean','--version']),
    ('compile',['lean','-R',str(review),'-o',str(review/'C5Checks.olean'),str(review/'C5Checks.lean')]),
    ('audit',['lean',str(review/'C5Audit.lean')]),
    ('kernel_replay',['leanchecker','C5Checks']),
]
checks=[]
for name, cmd in commands:
    start=time.monotonic()
    result=subprocess.run(cmd,cwd=review,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (review/(name+'.log')).write_text(result.stdout)
    checks.append({'name':name,'command':cmd,'exit_code':result.returncode,'seconds':round(time.monotonic()-start,3)})
    print(name, result.returncode, flush=True)
    if result.returncode:
        print(result.stdout,flush=True)
        sys.exit(result.returncode)
rows=json.loads((review/'C5-dependencies.json').read_text())
allowed={'propext','Classical.choice','Quot.sound'}
assert rows
for row in rows:
    assert set(row['axioms']) <= allowed, row['name']
    assert row['kind'] != 'axiom', row['name']
result={
    'completed_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'status':'passed', 'scope':'supplementary correspondence checks; core verification reported separately',
    'review_source_sha256':sha(review/'C5Checks.lean'),
    'exporter_sha256':sha(review/'C5Audit.lean'),
    'verifier_sha256':sha(Path(__file__)),
    'core_contract_files_verified':len(files),
    'core_fresh_replay_this_review':False,
    'new_module_kernel_replay':True,
    'new_module_replay_fresh':False,
    'independent_kernel':False, 'independent_human_review':False,
    'elaborated_review_constants':len(rows),
    'axioms':sorted({a for r in rows for a in r['axioms']}),
    'checks':checks,
}
(review/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
