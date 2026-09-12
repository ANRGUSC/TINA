#!/usr/bin/env python3
"""Check the expanded report's PDF bounds, source hashes, and claim coverage."""
from pathlib import Path
import hashlib, json, re
import fitz
ROOT=Path(__file__).resolve().parent
NAME="TINA_LCSS_Submission_Lamport_Report"
pdf=fitz.open(ROOT/(NAME+'.pdf'))
log=(ROOT/'output'/(NAME+'.log')).read_text()
for bad in ['Overfull', 'undefined', 'Fatal error']:
    assert bad.lower() not in log.lower(), bad
manifest=json.loads((ROOT/'review_manifest.json').read_text())
for name,digest in manifest['source_sha256'].items():
    assert hashlib.sha256((ROOT/'source'/name).read_bytes()).hexdigest()==digest
text='\n'.join(p.get_text() for p in pdf)
labels=re.findall(r'\\begin\{proofstep\}\{([^}]+)\}',(ROOT/(NAME+'.tex')).read_text())
assert len(labels)==73 and len(set(labels))==73
assert text.count('Supporting reasoning.')==73
assert all(label+'.' in text for label in labels)
assert 'not yet accepted' in text
outside=[]
for i,p in enumerate(pdf):
    for block in p.get_text('blocks'):
        x0,y0,x1,y1=block[:4]
        if x0<0 or y0<0 or x1>p.rect.width or y1>p.rect.height:
            outside.append({'page':i+1,'bbox':block[:4]})
assert not outside
result={'report':NAME+'.pdf','pages':len(pdf),'expanded_claims':73,
        'overfull_boxes':0,'undefined_references':0,'text_outside_page':outside}
(ROOT/'qa_summary.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
