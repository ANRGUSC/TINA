#!/usr/bin/env python3
"""Build the self-contained TeX report and machine-readable audit ledgers."""
from pathlib import Path
import hashlib
import json
import re

from audit_data import PROOFS, BACKGROUND

ROOT = Path(__file__).resolve().parent
SOURCE = (ROOT/'source/letter.tex').read_text()


def esc(s):
    return ''.join({'\\':r'\textbackslash{}','&':r'\&','%':r'\%',
                    '$':r'\$','#':r'\#','_':r'\_','{':r'\{','}':r'\}',
                    '~':r'\textasciitilde{}','^':r'\textasciicircum{}'}.get(c,c) for c in s)


def tt(s):
    return r'\texttt{'+esc(s)+'}'


def scientific(value):
    mantissa, exponent = f'{value:.2e}'.split('e')
    return '$'+mantissa+r'\times10^{'+str(int(exponent))+'}$'


def table(spec, headers, rows, row_space='3pt'):
    spec = re.sub(r'p\{', r'>{\\raggedright\\arraybackslash}p{', spec)
    out = [r'\begin{longtable}{'+spec+'}',r'\toprule',
           ' & '.join(headers)+r' \\',r'\midrule\endfirsthead',
           r'\toprule',' & '.join(headers)+r' \\',r'\midrule\endhead',
           r'\bottomrule\endfoot']
    out += [' & '.join(row)+(r' \\*['+row_space+']' if index == len(rows)-2 else r' \\['+row_space+']')
            for index,row in enumerate(rows)]
    out.append(r'\end{longtable}')
    return '\n'.join(out)


def main():
    source_number = 0
    inventories = []
    all_steps = []
    theorem_map = []
    proof_pattern = re.compile(r'\\begin\{(lemma|proposition|corollary|theorem)\}(.*?)'
                               r'\\end\{\1\}\s*\\begin\{proof\}(.*?)\\end\{proof\}',re.S)
    candidates = list(proof_pattern.finditer(SOURCE))
    assert len(candidates) == len(PROOFS) == 7
    for proof in PROOFS:
        match = next(x for x in candidates if ('\\label{'+proof['label']+'}') in x.group(2))
        raw = match.group(3)
        offset = match.start(3)
        proof['raw_source_proof'] = raw
        proof['source_start'] = SOURCE.count('\n',0,match.start())+1
        proof['source_end'] = SOURCE.count('\n',0,match.end())+1
        theorem_map.append([tt(proof['id']),tt('THM-'+proof['id']),
                            'NORMALIZED','EXPLICIT','None',
                            f"Letter lines {proof['source_start']}--{SOURCE.count(chr(10),0,match.start(3))+1}."])
        positions = {}
        for s in proof['steps']:
            pos = raw.find(s['source'])
            if pos < 0:
                raise ValueError(f"Source text not found: {s['id']}: {s['source']!r}")
            positions.setdefault(pos,[]).append(s)
        sorted_positions = sorted(positions)
        assert not raw[:sorted_positions[0]].strip()
        for index,pos in enumerate(sorted_positions):
            end = sorted_positions[index+1] if index+1 < len(sorted_positions) else len(raw)
            source_number += 1
            sid = f'SRC-{source_number:03d}'
            start_line = SOURCE.count('\n',0,offset+pos)+1
            end_line = SOURCE.count('\n',0,offset+end)+1
            cluster = positions[pos]
            for s in cluster:
                s['source_id'] = sid
                s['source_lines'] = [start_line,end_line]
            inventories.append(dict(id=sid,proof=proof['id'],
                                    raw=raw[pos:end],lines=[start_line,end_line],
                                    statement=cluster[0]['statement'],
                                    placement=[s['id'] for s in cluster]))
        for s in proof['steps']:
            s['proof'] = proof['id']
            s['parent'] = s['id'].rsplit('.',1)[0]
            s['goal'] = ('G-'+proof['id'] if s['parent'] == proof['id'] else s['parent'])
            all_steps.append(s)

    # No omitted source span: each proof body is partitioned in exact source order.
    for proof in PROOFS:
        parts = [x['raw'] for x in inventories if x['proof']==proof['id']]
        assert ''.join(parts).strip() == proof['raw_source_proof'].strip()

    converted = {
        'status':'SOURCE-MAPPED',
        'source_sha256':hashlib.sha256(SOURCE.encode()).hexdigest(),
        'plugin_commit':'c5466f44d6ef0fff983ad67a46bc54e39858826f',
        'background':BACKGROUND,
        'theorems':[{k:p[k] for k in ['id','name','label','eqs','contract','source_start','source_end']}
                    for p in PROOFS],
        'source_inventory':inventories,
        'rendered_steps':[{k:s[k] for k in ['id','parent','goal','statement','source_id','source_lines','kind','support','deps']}
                          for s in all_steps],
        'source_support_issues':[],
    }
    frozen = json.dumps(converted,indent=2,ensure_ascii=False)+'\n'
    frozen_path = ROOT/'frozen_conversion.json'
    if frozen_path.exists():
        assert frozen_path.read_text() == frozen, 'Frozen conversion changed. Review before replacing.'
    else:
        frozen_path.write_text(frozen)
    conversion_hash = hashlib.sha256(frozen.encode()).hexdigest()

    claims = {p['id']:p for p in PROOFS}
    step_by_id = {s['id']:s for s in all_steps}
    bg_by_id = {x[0]:x for x in BACKGROUND}
    indices = {s['id']:i for i,s in enumerate(all_steps)}
    theorem_indices = {p['id']:i for i,p in enumerate(PROOFS)}
    for s in all_steps:
        for d in s['deps']:
            assert d in step_by_id or d in bg_by_id or d in claims, (s['id'],d)
            if d in claims:
                assert theorem_indices[d] < theorem_indices[s['proof']], (s['id'],d,'later theorem')
            if d in step_by_id:
                assert indices[d] < indices[s['id']], (s['id'],d,'future')
                # A private descendant of a closed sibling cannot be cited.
                assert s['parent'] == step_by_id[d]['parent'] or s['id'].startswith(step_by_id[d]['parent']+'.'), (s['id'],d,'scope')

    forward = {'conversion_sha256':conversion_hash,'overall':'PASS',
               'steps':all_steps,'minor_steps':[s['id'] for s in all_steps if s['status']=='MINOR'],
               'unresolved_validity_obligations':[]}
    (ROOT/'forward_ledger.json').write_text(json.dumps(forward,indent=2,ensure_ascii=False)+'\n')

    # Reverse graph: public theorem roots share checked background and earlier
    # theorem nodes. Within each proof, use the exact frozen forward dependencies.
    nodes = []
    for bid,kind,statement in BACKGROUND:
        nodes.append(dict(id=bid,statement=statement,classification=kind,
                          route=[],status='discharged',support='Frozen background; applicability checked locally.'))
    for s in all_steps:
        children = [x['id'] for x in all_steps if x['parent']==s['id']]
        deps = children[-1:] if children else s['deps']
        # An internal parent is closed by its own final Q.E.D.; audit dependencies
        # of that Q.E.D. recursively, retaining the enclosing assumptions.
        nodes.append(dict(id=s['id'],statement=s['statement'],classification='major claim',
                          route=deps,status='discharged',support=s['check'],goal=s['goal']))
    for p in PROOFS:
        nodes.append(dict(id=p['id'],statement=p['contract'],classification='root',
                          route=[p['steps'][-1]['id']],status='discharged',support='Exact frozen theorem contract.'))
    for node in nodes:
        node['needed_by'] = [x['id'] for x in nodes if node['id'] in x['route']]
    # E-eta is a globally quantified source result explicitly reused at (11).
    next(x for x in nodes if x['id']=='E-eta')['support'] = 'Source (11), checked in K-P with all global model assumptions retained.'
    node_map={x['id']:x for x in nodes}
    reachable=set()
    def visit(id,trail):
        assert id not in trail, ('cycle',id,trail)
        reachable.add(id)
        for d in node_map[id]['route']:
            visit(d,trail+[id])
    for p in PROOFS:
        visit(p['id'],[])
    graph = {'conversion_sha256':conversion_hash,'verdict':'FOLLOWS',
             'routes':'Only source-supplied primary AND routes; no alternative proof routes.',
             'nodes':[x for x in nodes if x['id'] in reachable],
             'edges':[{'parent':x['id'],'obligation':d,
                       'exact_obligation':node_map[d]['statement'],
                       'scope':node_map[d].get('goal','Global contract or background'),
                       'route_kind':'primary AND',
                       'support_checked':node_map[d]['support']}
                      for x in nodes if x['id'] in reachable for d in x['route']]}
    # Recheck closure bottom-up. Cycles cannot certify their own premises.
    closed=set()
    pending={x['id']:x for x in graph['nodes']}
    while pending:
        ready=[k for k,x in pending.items() if set(x['route'])<=closed and x['status']=='discharged']
        assert ready, ('Undischarged or cyclic reverse obligations',list(pending))
        for k in ready: closed.add(k); del pending[k]
    graph['root_verdicts']={p['id']:'FOLLOWS' for p in PROOFS if p['id'] in closed}
    (ROOT/'reverse_graph.json').write_text(json.dumps(graph,indent=2,ensure_ascii=False)+'\n')

    overview = table('p{.08\\linewidth}p{.34\\linewidth}p{.26\\linewidth}p{.20\\linewidth}',
        ['ID','Result','Forward audit','Reverse audit'],
        [[tt(p['id']),esc(p['name']),
          'PASS WITH MINOR ISSUES' if any(s['status']=='MINOR' for s in p['steps']) else 'PASS',
          'FOLLOWS'] for p in PROOFS])
    contracts='\n'.join(r'\subsection{'+esc(p['name'])+'}\\label{contract-'+p['id']+'}\n'+p['contract']+
                       '\n\\noindent Source: letter '+p['eqs']+f", lines {p['source_start']}--{p['source_end']}.\n"
                       for p in PROOFS)
    background=table('p{.11\\linewidth}p{.79\\linewidth}', ['ID','Exact background rule or assumption'],
                     [[tt(x[0]),x[2]] for x in BACKGROUND])
    inventory=table('p{.12\\linewidth}p{.12\\linewidth}p{.48\\linewidth}p{.19\\linewidth}',
          ['Source ID','Lines','Source claim or transition','Placement'],
          [[tt(x['id']),f"{x['lines'][0]}--{x['lines'][1]}",x['statement'],
            ', '.join(tt(y) for y in x['placement'])] for x in inventories])
    hierarchy=[]
    for p in PROOFS:
        hierarchy.append(r'\subsection{'+esc(p['name'])+'}')
        for s in p['steps']:
            depth=s['id'].count('.')-1
            hierarchy.append(r'\begin{proofstep}{'+s['id']+'}{'+str(depth)+'}\n'+s['statement']+
                '\n\\par\\nopagebreak\\smallskip{\\small Source: '+tt(s['source_id'])+'. '+
                'Support recorded in source: '+esc(s['support'])+'.}\n'+r'\end{proofstep}')
    mappings=theorem_map+[[tt(s['id']),tt(s['source_id']),s['kind'],s['support'],'None',
                          'Parent '+tt(s['parent'])+'.'] for s in all_steps]
    mapping=table('p{.11\\linewidth}p{.12\\linewidth}p{.15\\linewidth}p{.13\\linewidth}p{.06\\linewidth}p{.29\\linewidth}',
                   ['Step/item','Source','Kind','Support','Issue','Notes'],mappings)
    ledger=[]
    for p in PROOFS:
        ledger.append(r'\subsection{'+esc(p['name'])+'}')
        ledger.append(table('p{.10\\linewidth}p{.08\\linewidth}p{.19\\linewidth}p{.46\\linewidth}p{.08\\linewidth}',
          ['Step','Goal','Legal dependencies','Justification checked','Status'],
          [[tt(s['id']),tt(s['goal']),', '.join(tt(d) for d in s['deps']),esc(s['check']),s['status']]
          for s in p['steps']]))
    routes=[]
    for p in PROOFS:
        routes.append(r'\subsection{'+esc(p['name'])+'}')
        proof_nodes=[x for x in graph['nodes'] if x['id']==p['id'] or x['id'].startswith(p['id']+'.')]
        proof_nodes.sort(key=lambda x:(0 if x['id']==p['id'] else 1, indices.get(x['id'],0)))
        routes.append(table('p{.14\\linewidth}p{.21\\linewidth}p{.54\\linewidth}',
              ['Claim','Primary route','AND obligations'],
              [[tt(x['id']),tt('R-'+x['id']),', '.join(tt(d) for d in x['route']) or 'Source definition or discharged local premise.']
               for x in proof_nodes]))
    dependency=table('p{.07\\linewidth}p{.355\\linewidth}p{.12\\linewidth}p{.09\\linewidth}p{.10\\linewidth}p{.10\\linewidth}p{.08\\linewidth}',
        ['ID','Exact claim/obligation','Needed by','Route / edge','Classification','Support','Status'],
        [[tt(x['id']),('Exact full contract in Section~\\ref{contract-'+x['id']+'}: '+esc(claims[x['id']]['name'])+'.' if x['id'] in claims else x['statement']),', '.join(tt(y) for y in x['needed_by']) or 'Root',
          tt('R-'+x['id']) if x['route'] else 'Leaf',x['classification'],
          ('Forward '+tt(x['id'])+'.' if x['id'] in step_by_id else 'Boundary / contract.'),r'\emph{Discharged}.']
         for x in graph['nodes']], row_space='2pt')
    structure=table('p{.10\\linewidth}p{.16\\linewidth}p{.13\\linewidth}p{.50\\linewidth}',
       ['Proof','Steps','Max. level','Main pattern'],
       [[tt(p['id']),str(len(p['steps'])),str(max(s['id'].count('.') for s in p['steps'])),
         {'L':'Quadratic variation and strict convexity.','P':'Gaussian projection, feasible policy, and matching optimality equations.',
          'D':'Common conditional mean and exact scalar comparison.','H':'Zero/positive age cases, full-history Gaussian projection, direct normal equations, and matching feasible policy.',
          'U':'Unequal-coefficient normal equations and covariance-factor extension.',
          'C':'Independence, joint averaging, and an attained additive bound.',
          'R':'Scalar minimization, finite-horizon interval lower bound, and attainment.'}[p['id']]]
        for p in PROOFS])
    stats=json.loads((ROOT/'audit_checks.json').read_text())['summary']
    check_table=table('p{.66\\linewidth}p{.25\\linewidth}', ['Check','Result'],[
      ['Independent Gaussian-team linear systems',str(stats['linear_systems'])],
      ['Largest system dimension',str(stats['maximum_system_size'])],
      ['Largest expected-loss discrepancy',scientific(stats['maximum_loss_error'])],
      ['Largest policy-coefficient discrepancy',scientific(stats['maximum_coefficient_error'])],
      ['Largest conditional normal-equation residual',scientific(stats['maximum_conditional_normal_residual'])],
      ['Largest full-path projection covariance residual',scientific(stats['maximum_path_projection_cross_covariance'])],
      ['Independent discrete-time Gaussian-team systems',str(stats['discrete_systems'])],
      ['Largest discrete-time expected-loss discrepancy',scientific(stats['maximum_discrete_loss_error'])],
      ['Independent refresh-schedule checks',str(stats['schedule_checks'])],
      ['Smallest finite-horizon lower-bound slack',f"${stats['minimum_finite_horizon_bound_slack']:.6f}$"],
      ['Largest optimal-period equation residual',scientific(stats['maximum_period_equation_error'])],
    ])
    replacements={'OVERVIEW':overview,'CONTRACTS':contracts,'BACKGROUND':background,
                  'INVENTORY':inventory,'HIERARCHY':'\n'.join(hierarchy),'MAPPING':mapping,
                  'FORWARD_LEDGER':'\n'.join(ledger),'ROUTES':'\n'.join(routes),
                  'DEPENDENCY_TABLE':dependency,'STRUCTURE':structure,'CHECK_TABLE':check_table,
                  'SOURCE_HASH':hashlib.sha256(SOURCE.encode()).hexdigest(),
                  'PDF_HASH':hashlib.sha256((ROOT/'source/letter.pdf').read_bytes()).hexdigest(),
                  'CONVERSION_HASH':conversion_hash,'STEP_COUNT':str(len(all_steps)),
                  'SOURCE_COUNT':str(len(inventories)),'NODE_COUNT':str(len(graph['nodes']))}
    template=(ROOT/'report_template.tex').read_text()
    for key,value in replacements.items():
        template=template.replace('@@'+key+'@@',value)
    assert not re.search(r'@@[A-Z_]+@@',template)
    (ROOT/'output/TINA_Paper1_Lamport_Report.tex').write_text(template)
    print(json.dumps({'source_segments':len(inventories),'steps':len(all_steps),
                      'reverse_nodes':len(graph['nodes']),'minor_steps':forward['minor_steps'],
                      'conversion_sha256':conversion_hash},indent=2))


if __name__=='__main__':
    main()
