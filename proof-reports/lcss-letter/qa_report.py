#!/usr/bin/env python3
"""Mechanical document checks and contact sheets for visual review."""
from pathlib import Path
import hashlib
import json
import re

import fitz
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parent
pdf=fitz.open(ROOT/'output/TINA_Paper1_Lamport_Report.pdf')
log=(ROOT/'output/TINA_Paper1_Lamport_Report.log').read_text()
assert 'Overfull' not in log
assert 'undefined' not in log.lower()
assert 'Fatal error' not in log
manifest=json.loads((ROOT/'review_manifest.json').read_text())
for name,digest in manifest['source_sha256'].items():
    assert hashlib.sha256((ROOT/'source'/name).read_bytes()).hexdigest()==digest
pages=[]
outside=[]
for i,p in enumerate(pdf):
    spans=[s for b in p.get_text('dict')['blocks'] if 'lines' in b
           for line in b['lines'] for s in line['spans'] if s['text'].strip()]
    for s in spans:
        # get_text coordinates are unrotated; compare to the unrotated media box.
        x0,y0,x1,y1=s['bbox']
        if x0<0 or y0<0 or x1>p.mediabox.width+1 or y1>p.mediabox.height+1:
            outside.append({'page':i+1,'text':s['text'],'bbox':s['bbox']})
    pages.append({'page':i+1,'rotation':p.rotation,'text_chars':len(p.get_text()),
                  'minimum_font_pt':min(s['size'] for s in spans),
                  'maximum_font_pt':max(s['size'] for s in spans)})
assert not outside,outside
text='\n'.join(p.get_text() for p in pdf)
for word in ['SOURCE-MAPPED','PASS','FOLLOWS','Too Late to Coordinate',
             'full-history covariance identity']:
    assert word in text,word
for stale in ['PASS WITH MINOR ISSUES','LMP-001','LMP-004',
              'How Fast Does Coordination Value Decay?']:
    assert stale not in text,stale
render=ROOT/'render'
images=sorted(render.glob('page-*.png'))
assert len(images)==len(pdf)
for start in range(0,len(images),9):
    canvas=Image.new('RGB',(1440,1830),'#dce3e7')
    draw=ImageDraw.Draw(canvas)
    for local,path in enumerate(images[start:start+9]):
        im=Image.open(path).convert('RGB')
        im.thumbnail((460,575))
        row,col=divmod(local,3)
        x=col*480+(480-im.width)//2
        y=row*610+25
        canvas.paste(im,(x,y))
        draw.text((col*480+12,row*610+6),f'Page {start+local+1}',fill='black')
    canvas.save(render/f'contact-{start//9+1}.png')
summary={'pages':len(pdf),'overfull_boxes':0,'undefined_references':0,
         'text_outside_page':outside,'page_details':pages}
(ROOT/'qa_summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({'pages':len(pdf),'contact_sheets':(len(pdf)+8)//9,
                  'out_of_page_spans':len(outside),'layout_warnings':0},indent=2))
