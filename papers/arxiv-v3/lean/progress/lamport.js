/* Source-mapped rendering of the written proofs, using WWresearch/lamport-proof's
 * convert-lamport protocol. Endpoints are inclusive ordinals in source order. */
'use strict';

const lamportGroups = {
  'C1/p1': [[2, 'Identify the policy space'], [4, 'Minimize the distance to that space']],
  'C2/p1': [[2, 'Derive the necessary equations'], [4, 'Prove sufficiency and uniqueness']],
  'C4.c/p1': [[2, 'Separate the innovation from the earlier states'], [4, 'Establish the prediction rule and stationarity']],
  'C7/p1': [[4, 'Split the error and evaluate the innovation'], [7, 'Optimize the predictable part']],
  'C9/p1': [[2, 'Decompose the target and its value'], [4, 'Predict each mode'], [6, 'Combine the gains']],
  'C12/p1': [[4, 'Find the optimal local rule'], [7, 'Compare the three information costs']],
  'C12/p2': [[1, 'Invert the cost matrix'], [5, 'Solve the local normal equations'], [8, 'Compute the omitted share']],
  'C13.c/p1': [[2, 'Identify the factor shared by both formulas'], [5, 'Establish monotonicity']],
  'C15.b/p1': [[2, 'Relate derivative signs to gain'], [5, 'Distinguish the two boundaries and the interior']],
  'C15.c/p1': [[3, 'Compare marginal gains at a maximizer'], [5, 'Vary coherence time and latency separately']],
  'C16/p1': [[2, 'Find what controls the derivative'], [4, 'Locate the maximum in each case'], [6, 'Evaluate the radius and apply the cap']],
  'C17.b/p1': [[3, 'Predict the integrated target'], [6, 'Compare delayed and fresh gains']],
  'C18/p1': [[3, 'Express the omitted variance through the two tails'], [6, 'Find its dependence on radius'], [10, 'Evaluate the constant at radius zero']],
};

// Support left implicit in the paper route. The supplemental argument, where
// available, belongs to the Lean development and is not inserted into that route.
const paperObligations = {
  'C1/p1/s4': 'Transfer closedness from the ordinary mean-square norm to the cost-weighted norm before applying the projection theorem.',
  'C2/p1/s2': 'Justify the passage from vanishing pairings with all admissible one-agent perturbations to a zero conditional expectation.',
  'C2/p1/s3': 'Use measurability of each agent’s perturbation when taking its component outside the conditional expectation.',
  'C3/p1/s1': 'Check that the conditional mean is an admissible policy for every agent with the common observation.',
  'C3/p1/s2': 'Identify the linear term of the expansion using the relation between the full-information action and the cost gradient.',
  'C11/p1/s2': 'Justify conditioning on both old readings using independence of the two processes and compute the error variance by prediction orthogonality.',
  'C12/p1/s6': 'Derive the full-information expected cost from the two eigenvalues and the state second moments.',
  'C12/p1/s7': 'Identify the difference of the expected costs with regret using the quadratic excess-cost identity.',
};

const toolkitUrl = 'https://github.com/WWresearch/lamport-proof/blob/c5466f44d6ef0fff983ad67a46bc54e39858826f/skills/convert-lamport/SKILL.md';

function lamportProof(c, proof) {
  const rows = q('SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal', [proof.id]);
  if (!rows.length) return '<p>No written proof steps are available for conversion.</p>';
  const groups = lamportGroups[proof.id] || [];
  const steps = rows.map((s, i) => {
    const g = groups.findIndex(([end]) => i + 1 <= end);
    const label = g < 0 ? `⟨1⟩${i + 1}` : `⟨1⟩${g + 1}.⟨2⟩${i + 1 - (groups[g - 1]?.[0] || 0)}`;
    return { ...s, label, src: 'SRC-' + String(i + 1).padStart(3, '0'),
      deps: q('SELECT dep_id FROM step_deps WHERE step_id = ? ORDER BY dep_id', [s.id]).map(d => d.dep_id) };
  });
  const supplement = proof.status === 'supplement';
  const issueList = [];
  for (const s of steps) {
    const inserted = !supplement && s.origin === 'supplied';
    const points = !supplement && q("SELECT point FROM dispositions WHERE step_id = ? AND level = 'proof'", [s.id]);
    const issues = points || [];
    if (paperObligations[s.id]) issues.push({point: paperObligations[s.id]});
    if (inserted && !issues.length) issues.push({point: s.title});
    s.inserted = inserted;
    s.issues = issues.map(({point}) => {
      const id = 'GAP-' + String(issueList.length + 1).padStart(3, '0');
      issueList.push({id, point, s});
      return id;
    });
  }
  const target = s => proof.id + '-' + s.src;
  const stepLink = s => `<a href="#${esc(target(s))}" data-reader-jump="${esc(target(s))}">${s.label}</a>`;
  const dep = id => {
    const local = steps.find(s => s.id === id);
    if (local) return stepLink(local);
    const parent = id.split('/')[0];
    return id === parent ? claimLink(id, true) : `<a href="#/claim/${encodeURIComponent(parent)}?view=lamport">${esc(id)}</a>`;
  };
  const terminals = steps.filter(s => !steps.some(t => t.deps.includes(s.id)));
  const source = supplement ? 'Supplemental proof supplied for the formalization' : 'Proof in the arXiv v3 paper';
  const row = (s) => `<div class="lp-step" id="${esc(target(s))}">
    <h4><code>${s.label}</code> ${esc(s.title)}</h4>
    ${s.inserted ? '<p class="lp-gap">The manuscript leaves this justification implicit.</p>' : texHtml(s.tex)}
    ${s.deps.length ? `<p class="lp-meta">Uses ${s.deps.map(dep).join(', ')}</p>` : ''}
    ${s.issues.map(id => `<p class="lp-gap"><b>${id}</b> · ${esc(issueList.find(x => x.id === id).point)}</p>`).join('')}
    ${s.inserted ? `<details><summary>Supplemental justification</summary>${texHtml(s.tex)}</details>` : ''}
    </div>`;
  const hierarchy = groups.length ? groups.map(([end, title], i) =>
    `<section class="lp-group"><h4>⟨1⟩${i + 1}. ${esc(title)}</h4>${steps.slice(groups[i - 1]?.[0] || 0, end).map(row).join('')}</section>`).join('') : steps.map(row).join('');
  const qed = `⟨1⟩${(groups.length || steps.length) + 1}`;
  const boundary = s => s.origin === 'paper' ? paperLink(s.source, s.line_start, s.line_end) :
    `<a href="https://github.com/${repo()}/blob/${info?.commit || 'main'}/${leanDir()}/supplement.md">Supplement</a>`;
  return `<section class="reader-proof"><h3>${source}${proof.is_primary ? '' : ' · alternative derivation'}</h3>
    <p class="lp-meta">SOURCE-MAPPED · This status concerns source mapping only; it is not a validity verdict.</p>
    <details><summary>Source contract</summary><p>${esc(c.statement)}</p>
    <p>${paperLink(c.source,c.line_start,c.line_end)} · ${esc(proof.id)}. The source argument and its cited definitions supply the hypotheses and background rules. Supplemental justifications for omitted paper steps are labeled separately.</p></details>
    <details><summary>Source inventory</summary><ol>${steps.map(s => `<li><code>${s.src}</code> · ${esc(s.title)} · ${boundary(s)} · ${stepLink(s)}${s.inserted ? ' (supplemental bridge)' : ''}</li>`).join('')}</ol></details>
    <div class="lp-tree">${hierarchy}<div class="lp-step"><h4><code>${qed}</code> Q.E.D.</h4><p>By ${terminals.map(stepLink).join(', ')}.</p></div></div>
    <details><summary>Source-to-step mapping</summary><ul><li>Theorem contract · claim ${esc(c.id)} and its linked manuscript passage.</li>
      ${steps.map(s => `<li>${s.src} · ${stepLink(s)} · ${s.inserted ? 'OBLIGATION · OPEN' : 'DIRECT · ' + (s.issues.length ? 'OPEN' : 'EXPLICIT')}${s.issues.length ? ' · ' + s.issues.join(', ') : ''}</li>`).join('')}
      ${issueList.filter(x => !x.s.inserted).map(x => `<li>${x.s.src} · ${x.id} · OBLIGATION · OPEN</li>`).join('')}
      ${groups.map(([end], i) => `<li>⟨1⟩${i + 1} · ${steps[groups[i-1]?.[0] || 0].src} through ${steps[end-1].src} · STRUCTURAL · IMPLICIT</li>`).join('')}
      <li>${qed} · ${terminals.map(s => s.src).join(', ')} · STRUCTURAL · IMPLICIT</li></ul></details>
    <details><summary>Source obligations (${issueList.length})</summary>${issueList.length ? issueList.map(x => {
      const downstream = steps.filter(s => s.deps.includes(x.s.id));
      return `<p><b>${x.id}</b> · ${stepLink(x.s)} · ${esc(x.point)} Directly used by ${downstream.length ? downstream.map(stepLink).join(', ') : qed}.</p>`;
    }).join('') : '<p>No additional source obligation is recorded for this rendering.</p>'}</details>
    <details><summary>Conversion record</summary><p>Source text, labels and dependencies are tied to ${esc(proof.id)} at ${esc(info?.commit?.slice(0, 9) || 'this checkout')}. The mapping identifies the origin of each step. The Lean tab contains the machine-checked argument.</p>
    <a href="${toolkitUrl}">WWresearch convert-lamport method</a></details>
  </section>`;
}
