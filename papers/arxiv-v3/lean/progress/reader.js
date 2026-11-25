/* Detailed views of the current manuscript and the selected formalizations. */
'use strict';

const readerViews = {plain: 'Plain English', paper: 'Math statement/proof (per paper)', lamport: 'Lamport proof', lean: 'Lean statement and proof'};
const claimHref = (id, view) => '#/claim/' + encodeURIComponent(id) + (view === 'plain' ? '' : '?view=' + view);

function readerRole(c) {
  if (c.scope === 'lean') return 'How the model is used';
  return ['C21','C22','C23','C24'].includes(c.id) ? 'What the experiment checks' : 'What the discussion contributes';
}

function plainPanel(c, proofs) {
  const sketch = proofSketches[c.id];
  const links = (title, ids) => ids.length ? `<div><h4>${title}</h4><ul>${ids.map(id => `<li>${claimLink(id, true)}</li>`).join('')}</ul></div>` : '';
  return `<h3>What the claim says</h3><p class="reader-prose">${esc(graphExplanations[c.id])}</p>
    <h3>${sketch ? 'High-level proof sketch' : readerRole(c)}</h3>
    <p class="reader-prose">${linkIds(esc(sketch || readerContext[c.id]))}</p>
    ${sketch && proofs[0]?.status === 'supplement' ? '<p class="lp-meta">This sketch follows the supplemental proof.</p>' : ''}
    <div class="reader-related">${links('Depends on', M.deps.filter(d => d.claim_id === c.id).map(d => d.depends_on))}
    ${links('Used by', M.deps.filter(d => d.depends_on === c.id).map(d => d.claim_id))}
    ${links('Related subclaims', M.claims.filter(d => d.parent === c.id).map(d => d.id))}</div>`;
}

async function readPassage(id) {
  const response = await fetch(new URL('paper-assets/' + encodeURIComponent(id) + '.json', ASSETS));
  if (!response.ok) throw new Error(response.status);
  return response.json();
}

async function paperPanel(panel, c, proofs) {
  panel.innerHTML = '<h3>Math statement/proof (per paper)</h3><p role="status">Loading manuscript passage…</p>';
  try {
    const {regions, source} = await readPassage(c.id);
    const note = proofs[0]?.status === 'supplement' ? `<p>The full proof for this claim is supplied in the <a href="${claimHref(c.id,'lamport')}">supplemental Lamport view</a>.</p>` : '';
    panel.innerHTML = `<h3>Math statement/proof (per paper)</h3>${note}
      ${regions.map(([n,lo,hi]) => `<figure class="reader-page">
        <figcaption><a href="https://anrgusc.github.io/TINA/arxiv-v3/tina-v3.pdf#page=${n}" target="_blank" rel="noopener">Open manuscript · page ${n}</a></figcaption>
        <svg role="img" aria-label="Manuscript excerpt on page ${n}. The corresponding TeX is available below." viewBox="65 ${lo} 482 ${hi-lo}" width="482" height="${hi-lo}"><image href="${new URL('paper-assets/page-' + n + '.svg', ASSETS).href}" width="612" height="792"/></svg></figure>`).join('')}
      <details><summary>Read the manuscript excerpt as TeX</summary>${source.map(s => `<p>${paperLink(s.file,s.first,s.last)}</p><pre class="code reader-tex">${esc(s.tex)}</pre>`).join('')}</details>`;
  } catch (error) {
    panel.innerHTML = `<p>The paper passage could not be loaded. ${paperLink(c.source,c.line_start,c.line_end)}</p>`;
  }
}

async function lamportPanel(panel, c, proofs) {
  panel.innerHTML = `<h3>${c.scope === 'lean' ? 'Mathematical statement' : 'Paper claim'}</h3><div class="reader-math"><p class="reader-prose">${linkIds(esc(c.statement))}</p></div>
    <p class="lp-meta"><a href="${claimHref(c.id,'paper')}">Read the typeset statement in context</a></p>
    ${proofs.length ? proofs.map(p => lamportProof(c,p)).join('') :
      `<h3>${c.scope === 'lean' ? 'Model assumption or definition' : 'Scope of the argument'}</h3>
      <p>${linkIds(esc(readerContext[c.id]))} This node has no separate deductive proof.</p>`}`;
  if (c.scope !== 'lean') return;
  const statement = panel.querySelector('.reader-math');
  try {
    const {statement: tex} = await readPassage(c.id);
    const items = tex.split(/\\begin\{enumerate\}|\\end\{enumerate\}/);
    statement.innerHTML = items.map((part,i) => i % 2 ?
      '<ol>' + part.split(/\\item\b/).filter(s => s.trim()).map(s => '<li>' + texHtml(s) + '</li>').join('') + '</ol>' :
      texHtml(part)).join('');
    if (c.id === 'C4.c') {
      statement.innerHTML += texHtml(String.raw`For the centered state, the prediction rule established below is
        \[\mathbb E[\theta_t\mid\theta_{t-\tau}]=e^{-\tau/T}\theta_{t-\tau},\qquad \tau\ge0.\]`);
    }
  } catch { /* The ledger statement and manuscript link remain available. */ }
}

function currentDeclaration(src, name) {
  const lines = src.split(/\r?\n/);
  const short = name.split('.').pop();
  const start = lines.findIndex(line => new RegExp('^(?:noncomputable )?(?:def|abbrev|structure|class|theorem|lemma) ' + short + '\\b').test(line));
  if (start < 0) return src;
  const next = lines.findIndex((line, i) => i > start && /^(?:\/[-]|namespace |section\b|end\b|variable\b|(?:noncomputable )?(?:def|abbrev|structure|class|theorem|lemma) )/.test(line));
  return lines.slice(start, next < 0 ? undefined : next).join('\n').trimEnd();
}

function extractLeanSignature(src, declName) {
  if (!src || !declName) return '';
  const short = declName.split('.').pop();
  const escRe = short.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const re = new RegExp(`^\\s*(?:private\\s+|protected\\s+)?(?:theorem|lemma|def|abbrev|structure)\\s+${escRe}\\b`, 'm');
  const m = re.exec(src);
  if (!m) return '';
  const rest = src.slice(m.index);
  const end = rest.search(/\s*:=\s*(?:by\b|\n|$)|^\s*where\b/m);
  return (end < 0 ? rest.split('\n').slice(0, 12).join('\n') : rest.slice(0, end)).trim();
}

function formatLeanRef(ref) {
  if (!ref) return '';
  const [file, decl] = ref.split('::');
  return decl ? `${leanLink(file)} · <code>${esc(decl)}</code>` : leanLink(file);
}

function routineDispositionsHtml(claimId, openByDefault) {
  const rows = M.disp.filter(d => d.claim_id === claimId && d.decision === 'lean_supplies' && d.lean_ref);
  if (!rows.length) return '';
  return `<details class="routine-disps"${openByDefault ? ' open' : ''}>
    <summary>Routine &amp; internal arguments discharged in Lean (${rows.length})</summary>
    <p class="small muted">Explicit ledger dispositions recording mathematical steps or technical bookkeeping the manuscript leaves implicit and Lean discharges inside <code>Routine/</code> or the step lemma.</p>
    <ul class="routine-list">${rows.map(d =>
      `<li><span class="idlink">${esc(d.id)}</span> ${prose(d.point)}<br><span class="small muted">Discharged by: ${formatLeanRef(d.lean_ref)}</span></li>`
    ).join('')}</ul>
  </details>`;
}

function stepSignatureRowsHtml(proofId, attemptId, proofSrc) {
  const steps = q('SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal', [proofId]);
  const maps = new Map(q('SELECT step_id, lean_decl, status FROM step_map WHERE attempt_id = ?', [attemptId]).map(r => [r.step_id, r]));
  const deps = q('SELECT step_id, dep_kind, dep_id FROM step_deps WHERE step_id IN (SELECT id FROM steps WHERE proof_id = ?) ORDER BY dep_kind, dep_id', [proofId]);
  const depsByStep = new Map();
  for (const d of deps) {
    if (!depsByStep.has(d.step_id)) depsByStep.set(d.step_id, []);
    depsByStep.get(d.step_id).push(d.dep_id);
  }
  return `<div class="steps-head"><span>Written step (verbatim TeX)</span><span>Lean step lemma signature</span></div>
    <div class="steps">${steps.map(s => {
      const m = maps.get(s.id);
      const sd = depsByStep.get(s.id) || [];
      const where = s.origin === 'supplied'
        ? '<span class="tag supplied">supplied</span>'
        : `<span class="small muted">${paperLink(s.source, s.line_start, s.line_end)}</span>`;
      const sig = m && proofSrc ? extractLeanSignature(proofSrc, m.lean_decl) : '';
      return `<div class="step${s.origin === 'supplied' ? ' supplied' : ''}">
        <div>
          <h4><span class="idlink">${esc(s.id)}</span> ${esc(s.title)} ${where}</h4>
          ${texHtml(s.tex)}
          ${sd.length ? `<p class="small muted step-deps-line">Uses: ${sd.map(x => `<code>${esc(x)}</code>`).join(', ')}</p>` : ''}
        </div>
        <div class="lean" style="--c:var(${m?.status === 'proved' ? '--st-verified' : '--st-p3'})">
          ${m ? `<h4><code>${esc(m.lean_decl)}</code> <span class="tag">${esc(m.status)}</span></h4>
            ${sig ? leanHtml(sig) : '<p class="small muted">Signature unavailable.</p>'}`
            : '<p class="small muted">No mapped Lean lemma.</p>'}
        </div>
      </div>`;
    }).join('')}</div>`;
}

async function leanPanel(panel, c) {
  const live = q('SELECT * FROM v_formalization WHERE claim_id = ?', [c.id])[0];
  if (!live) {
    panel.innerHTML = `<h3>Lean coverage</h3><p>This ${esc(c.kind)} is outside the Lean formalization.</p>
      <p>${esc(readerContext[c.id])}</p><a href="${claimHref(c.id,'paper')}">Read the manuscript passage</a>`;
    return;
  }
  const sel = M.attempts.find(a => a.claim_id === c.id && a.selected && a.formalization_id === live.id);
  const files = [live, ...(sel ? [sel] : [])];
  const routineHtml = routineDispositionsHtml(c.id, false);
  panel.innerHTML = files.map((f,i) => `<section class="reader-lean"><h3>${i ? 'Selected Lean proof' : sel ? 'Lean statement' : 'Lean model definition'}</h3>
    <p>${leanLink(f.lean_file)}</p>${i === 0 && M.deltas.some(d => d.formalization_id === live.id) ? `<details><summary>How the Lean statement relates to the manuscript</summary>${deltaList(live.id)}</details>` : ''}${i === 0 ? routineHtml : ''}<div class="reader-code" role="region" aria-label="${i ? 'Proof' : 'Statement'} source">Loading Lean source…</div></section>`).join('') +
    (sel ? `<details class="step-sig-details"><summary>Side-by-side step audit: written TeX ↔ Lean lemma signatures</summary><div class="step-sig-host">Loading step signatures…</div></details>`
      : `<p>${linkIds(esc(readerContext[c.id]))}</p>`);
  const sources = await Promise.all(files.map(async (f,i) => {
    const node = panel.querySelectorAll('.reader-code')[i];
    try {
      const src = await loadLean(f.lean_file);
      node.innerHTML = leanHtml(i ? src : currentDeclaration(src, f.lean_decl));
      return src;
    } catch {
      node.textContent = 'Could not load this file. Open the GitHub source above.';
      return '';
    }
  }));
  if (sel) {
    const host = panel.querySelector('.step-sig-host');
    if (host) host.innerHTML = stepSignatureRowsHtml(sel.proof_id, sel.id, sources[1] || '');
  }
}

function verificationRecord(c) {
  const record = info?.verification;
  const proof = record?.claims?.[c.id];
  if (!proof) return '';
  const match = info.verification_match;
  const reused = record.commit !== info.commit;
  if (reused && (match?.site_commit !== info.commit || match?.verified_commit !== record.commit)) return '';
  const attempt = M.attempts.find(a => a.claim_id === c.id && a.selected && a.status === 'proved');
  if (attempt?.id !== proof.attempt) return '';
  const kernels = Array.isArray(record.kernels_passed) ? record.kernels_passed : [];
  const multiKernel = record.comparator_passed && kernels.length > 1;
  const summaryLabel = multiKernel
    ? `✓ Machine-checked by Lean (${kernels.length} independent kernels)`
    : '✓ Machine-checked by Lean';
  const compRow = record.challenge_sha256
    ? `<dt>Comparator</dt><dd>${record.comparator_passed ? 'Passed' : 'Not passed'} · ${leanLink('comparator/Challenge.lean')} SHA-256 <code>${esc(record.challenge_sha256)}</code></dd>`
    : '';
  const kernelRow = kernels.length
    ? `<dt>Kernels passed</dt><dd>${kernels.map(k => `<code>${esc(k)}</code>`).join(', ')}</dd>`
    : '';
  const nvWits = Object.entries(record.non_vacuity || {})
    .filter(([, row]) => Array.isArray(row.claims) && row.claims.includes(c.id))
    .map(([name]) => name);
  const nvRow = nvWits.length
    ? `<dt>Non-vacuity</dt><dd>${nvWits.map(w => `<code>${esc(w)}</code>`).join(', ')}</dd>`
    : '';
  const note = multiKernel
    ? `The axiom audit found no <code>sorry</code> dependencies, and <code>lake comparator --paranoid</code> replayed the exported proof terms against the hash-locked challenge specification across ${kernels.length} independent kernels.`
    : 'The axiom audit found no <code>sorry</code> dependencies.';
  return `<div class="verification"><details><summary>${summaryLabel}</summary>
    <dl class="kv"><dt>Theorem</dt><dd><code>${esc(proof.theorem)}</code></dd>
    <dt>Checked</dt><dd>${esc(record.checked)}</dd>
    <dt>Verified commit</dt><dd><a href="https://github.com/${repo()}/commit/${esc(record.commit)}"><code>${esc(record.commit)}</code></a>
    ${reused ? ' · This site revision uses identical proof inputs.' : ''}</dd>
    <dt>Lean version</dt><dd>${esc(record.lean)}</dd>
    <dt>Transitive axioms</dt><dd>${esc(proof.axioms.join(', ') || 'None')}</dd>
    ${nvRow}${compRow}${kernelRow}</dl>
    <p>${note}</p></details>
    <a href="${esc(record.run)}">View verification run</a></div>`;
}

function viewClaim(id, requested) {
  const c = M.byId.get(id);
  if (!c) { main.innerHTML = `<p>Unknown claim ${esc(id)}. <a href="#/claims">Browse claims</a></p>`; return; }
  const view = Object.hasOwn(readerViews, requested) ? requested : 'plain';
  const proofs = q("SELECT * FROM proofs WHERE claim_id = ? AND status IN ('in_paper','supplement') ORDER BY is_primary DESC, version DESC", [id]);
  const at = M.claims.indexOf(c);
  const neighbor = (offset) => {
    const other = M.claims[at + offset];
    return other ? `<a href="${claimHref(other.id,view)}">${offset < 0 ? '← ' : ''}${esc(other.id)}${offset > 0 ? ' →' : ''}</a>` : '';
  };
  const tabNames = Object.keys(readerViews);
  const hadFocus = main.contains(document.activeElement) && document.activeElement.getAttribute('role') === 'tab';
  main.innerHTML = `<article class="claim-reader"><p class="crumbs"><a href="#/claims">Claims</a> / ${esc(id)}
      <span class="reader-neighbors">${neighbor(-1)} ${neighbor(1)}</span></p>
    <div class="claim-head"><h2><span class="idlink">${esc(id)}</span> ${esc(c.title)}</h2><span class="tag">${esc(c.kind)}</span></div>
    <p>${statusChip(c)} <a class="reader-graph" href="#/graph/${encodeURIComponent(id)}">Show in dependency graph</a></p>
    ${verificationRecord(c)}
    <div class="reader-tabs" role="tablist" aria-label="Claim views">${tabNames.map(v => `<a id="reader-tab-${v}" role="tab" href="${claimHref(id,v)}" aria-controls="reader-panel" aria-selected="${v===view}" tabindex="${v===view ? 0 : -1}">${readerViews[v]}</a>`).join('')}</div>
    <section id="reader-panel" class="reader-panel" tabindex="0" role="tabpanel" aria-labelledby="reader-tab-${view}"></section></article>`;
  const panel = main.querySelector('#reader-panel');
  if (view === 'paper') paperPanel(panel,c,proofs);
  else if (view === 'lean') leanPanel(panel,c);
  else if (view === 'lamport') lamportPanel(panel,c,proofs);
  else panel.innerHTML = plainPanel(c,proofs);
  panel.addEventListener('click', e => {
    const link = e.target.closest('[data-reader-jump]');
    if (link) { e.preventDefault(); document.getElementById(link.dataset.readerJump)?.scrollIntoView({block:'center'}); }
  });
  const selected = main.querySelector('[role=tab][aria-selected=true]');
  if (hadFocus) selected.focus({preventScroll:true});
  main.querySelector('[role=tablist]').addEventListener('keydown', e => {
    const i = tabNames.indexOf(view);
    const next = {ArrowRight:(i+1)%4, ArrowLeft:(i+3)%4, Home:0, End:3}[e.key];
    if (next !== undefined) { e.preventDefault(); location.hash = claimHref(id,tabNames[next]); }
  });
}


const proofSketches = {
  'C1': 'First collect all the decisions the agents can make with their observations. They form a closed linear space. Completing the square turns the cost of a mistake into a squared distance, so finding the best policy amounts to finding the closest point in that space.',
  'C1.b': 'Draw the ideal action as the sum of the best feasible action and its leftover error. Projection makes those two parts perpendicular in the cost-weighted geometry. Pythagoras then gives the error by subtracting the squared length of the feasible part from that of the ideal action.',
  'C1.c': 'Any rule that worked with fewer observations still works with more. The team is minimizing the same loss over a larger set of choices, so its best loss can only fall or stay the same.',
  'C2': 'Vary one agent’s action by a small amount that depends only on what it observes. At an optimum, the change in expected cost has zero first-order term for every such variation. Conversely, if these terms all vanish, any other policy adds a positive quadratic cost unless it agrees with the optimum.',
  'C3': 'Predict the ideal action from the shared report. Given that report, the prediction error averages to zero, so changing the prediction by any report-based amount cannot cancel any of the error on average. Expanding the squared cost leaves only the extra cost of that change.',
  'C3.b': 'The cost matrix assigns positive cost to every nonzero error. If the average squared size of the centered target is zero, the target itself must be zero almost surely. Choosing zero works with any set of observations.',
  'C4.b': 'Run the one-step recursion forward from the old reading. Each step scales the part already predictable, while each new disturbance averages to zero given the old reading. After k steps the scale factor has been applied k times. Squaring that factor gives the retained share of the decision benefit.',
  'C4.c': 'Subtract the predicted part from today’s state. The exponential covariance makes the remainder uncorrelated with every reading at or before the snapshot. Joint Gaussianity makes that remainder independent of those readings, so its conditional mean is zero. The one-time distributions also agree because each is Gaussian with the same mean and covariance.',
  'C5': 'Find the action where the slope of the cost is zero, then expand the cost around that action. The linear term disappears. The remaining quadratic term is positive for every nonzero change, which gives both the minimizer and the exact cost of missing it.',
  'C5.b': 'Subtract the known means before applying a decision rule and add them back afterward. This translation works in both directions and preserves the difference between the chosen and ideal actions, so it preserves regret.',
  'C6.b': 'With no readings, the choice is a constant. Expanding its average cost separates the squared size of that constant from the variation in the centered ideal action. Zero minimizes the first part, and summing the remaining weighted variances gives the trace formula.',
  'C6.c': 'Squared loss is nonnegative, and every agent can choose the no-information rule. These two observations bound the fraction between zero and one. An agent can ignore extra fresh readings, and once everyone sees the whole state the ideal action is feasible.',
  'C7': 'Split the desired action into a part predictable from the old state and a new disturbance. No policy based on that snapshot predicts the disturbance, so the two error costs add. Stationarity fixes the disturbance cost. Rescaling the policy turns the remaining optimization into the fresh-neighborhood problem.',
  'C7.b': 'Divide the composition formula by the positive no-information loss. Subtract the result from one to express the benefit retained as the product of a spatial share and a temporal share.',
  'C8': 'Everyone sees the whole old state, so the team can choose the predicted action exactly. That makes the predictable part of the error zero. The cost of the disturbance since the snapshot is then the entire regret.',
  'C8.c': 'Start with the exact regret as a function of age. At zero age the exponential factor is one. Its initial slope gives the short-delay approximation, and its decay to zero gives the long-delay limit.',
  'C9': 'Separate the desired action into contributions from the independent patterns. Centering and independence cancel the cross terms in the average quadratic cost. Predict each contribution at its own rate, square the factor to get its remaining benefit, and add the contributions using their decision-cost weights.',
  'C10': 'Compare the fixed loss from missing remote information with the increasing loss from waiting for a complete report. Equating the two gives the cutoff. When the local reading saves nothing, a complete report still saves a positive amount at every finite delay.',
  'C10.b': 'Insert zero local omission into the crossover formula: its threshold becomes zero. For an omission strictly between zero and one, the threshold is positive and the stale-global loss passes through the fixed local loss exactly once.',
  'C11': 'A fresh reading tells you one half of the sum exactly and leaves the other sensor unknown. Both old readings let you predict the whole average, but that prediction loses accuracy with age. Comparing the two mean squared errors gives the crossover.',
  'C12': 'Split each agent’s rule into its average and its response to local fluctuations. Independence removes cross terms between fluctuations at different agents. Minimize the remaining costs separately, then compare the local and full-information costs to obtain the lost share.',
  'C13': 'The shared-resource calculation gives the fraction of decision value a local reading misses. Insert that fraction into the general crossover formula and simplify. Positivity of the retained share places the result on the finite-threshold branch.',
  'C13.b': 'In the exact threshold, the two terms that grow with team size have the same leading growth. Their ratio tends to one. Taking the logarithm gives the limiting threshold, and taking the reciprocal of its argument gives the limiting local share.',
  'C13.c': 'Rewrite the threshold so its dependence on the shared penalty appears in a single increasing factor. At zero penalty the local policy is already ideal. Increasing the penalty raises both the loss from missing remote readings and the delay at which a fresh local reading wins.',
  'C14': 'Apply the composition formula to the delay associated with each radius. The no-information baseline is fixed, so comparing two radii amounts to comparing how much loss each saves. Comparing adjacent radii gives the one-more-hop test.',
  'C15': 'Take the logarithm of the benefit saved. This turns the product of the spatial benefit and the delay factor into a sum. At an interior maximum the slope of that sum is zero, so the two proportional rates balance.',
  'C15.b': 'The sign of the marginal advantage tells you whether widening the view helps. If it falls steadily, it either favors one endpoint throughout or changes sign once. In the latter case the benefit rises before the crossing and falls after it.',
  'C15.c': 'At every radius, increasing the coherence time makes waiting less costly. Increasing the latency scale has the opposite effect. Compare the signs of the marginal advantage at the old and new optima: with a single crossing, movement in the wrong direction would contradict those signs.',
  'C16': 'Differentiate the benefit saved and isolate the factor that controls its sign. That factor decreases steadily and eventually becomes negative. Its initial sign determines whether to stay at radius zero or expand to its unique zero; an imposed cap truncates that choice.',
  'C17.b': 'Subtract the predicted old field from the current field. The separable covariance and Gaussian law make the residual independent of the earlier field. Averaging over space and conditioning on the interval therefore scales the best prediction by the decay factor. Its variance, and hence the decision benefit, scales by the square.',
  'C18': 'Split the desired average into an observed middle and two unobserved tails. Given the boundary readings, the tails contribute separate errors. Moving a boundary outward reduces the tail’s weight exponentially, while its uncertainty relative to the boundary stays the same. The covariance integrals determine the starting value at radius zero.',
  'C19': 'Use the field calculation to find how delay reduces the benefit of an observed interval. Lemma 1 supplies the interval’s fresh omission curve. Substituting that curve into Proposition 3 gives the maximizing radius and the condition for it to be positive.',
  'C19.b': 'In the positive-radius regime, differentiate the closed form with respect to propagation distance and spatial correlation length. Their derivatives have opposite signs. For decision range, write the same radius as an integral whose integrand grows with the range.',
  'C20': 'In the positive-radius regime, rewrite the logarithm as the logarithm of one plus a quantity tending to zero. Near zero that logarithm has slope one. The growing factor outside it cancels the shrinking factor inside, leaving a finite limit.',
};

const readerContext = {
  'C4': 'The composition theorem takes this prediction rule as a hypothesis. C4.b derives its discrete-time counterpart from an autoregression, and C4.c establishes it for the Gaussian process with exponential covariance.',
  'C6': 'These definitions specify what a policy can observe and how its loss is measured. C6.b computes the no-information baseline, and C6.c bounds the fraction of that loss remaining with fresh local observations.',
  'C17': 'This model specifies the field, the desired spatial average, and the time needed to collect a reading. C17.b derives the delay law, and C18 derives the spatial omission curve.',
  'C3.c': 'The appendix discusses what stationarity supplies for expectations and what additional conditions connect them to long-run averages. This discussion is tracked as prose.',
  'C21': 'The experiment samples local and no-information losses and uses them to estimate the crossover. Compare the estimated boundaries with the exact curves in Figure 3.',
  'C22': 'Figure 4 plots temporal and spatial contributions to loss as radius changes. Compare the minimum of each curve with the allowed endpoints and the marked analytical optimum.',
  'C23': 'The experiment holds the ring, state covariance, and per-hop delay fixed and changes the distance over which readings affect the desired action. Figure 5 shows the minimizing radius for each choice.',
  'C24': 'The experiment evaluates every feasible integer radius for each of four graphs. Figure 6 reports the minimizing radii and shows how they change over the sampled parameters.',
  'C25': 'The abstract and introduction frame the questions. The detailed mathematical claims and the numerical illustrations provide the corresponding arguments and evidence.',
  'C26': 'This section identifies earlier results and explains how their models relate to the paper’s setting. The cited works are the sources for those comparisons.',
  'C27': 'The discussion collects the assumptions needed by the different results and interprets what they imply for choosing an observation radius.',
};
