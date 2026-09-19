#!/usr/bin/env python3
"""Negative tests of the proof verifier, in isolated temporary copies."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

root=Path(__file__).resolve().parents[1]
lock=json.loads((root/'contracts/review-contract.lock.json').read_text())
records=[]
cases=[('parameter_source_change','LCSS/Parameters.lean','\n','Review-contract drift'),
       ('time_integral_source_change','LCSS/TimeIntegral.lean','\n','Review-contract drift'),
       ('physical_attainment_source_change','LCSS/PhysicalAttainment.lean','\n','Review-contract drift'),
       ('raw_history_source_change','LCSS/RawHistory.lean','\n','Review-contract drift'),
       ('reception_endpoint_source_change','LCSS/ReceptionEndpoints.lean','\n','Review-contract drift'),
       ('ou_process_source_change','LCSS/OUProcess.lean','\n','Review-contract drift'),
       ('vendor_source_change','vendor/BrownianMotion/Gaussian/BrownianMotion.lean','\n','Vendor source drift'),
       ('unlocked_injected_proof','LCSS/Injected.lean','axiom invented : False\n','Forbidden proof machinery')]
for label,path,addition,expected in cases:
    with tempfile.TemporaryDirectory(prefix='lcss-verifier-regression-') as td:
        dest=Path(td)
        for rel in [*lock['files_sha256'],'contracts/review-contract.lock.json']:
            target=dest/rel
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(root/rel,target)
        p=dest/path
        p.write_text((p.read_text() if p.exists() else '')+addition)
        cmd=[sys.executable,str(dest/'scripts/verify.py'),'--extract-only']
        result=subprocess.run(cmd,cwd=dest,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        assert result.returncode != 0 and expected in result.stdout, (label,result.stdout)
        records.append({'test':label,'expected_rejection':expected,'exit_code':result.returncode,
                        'result':'pass_rejected_before_build','scope':'isolated_temporary_copy'})
(root/'evidence').mkdir(exist_ok=True)
(root/'evidence/gate-regressions.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps(records,indent=2))
