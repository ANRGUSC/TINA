/* Proof-progress explorer for the Lean formalization of the arXiv manuscript (v3 since 2026-11-18).
 *
 * Loads ../ledger/schema.sql and ../ledger/data.sql into SQLite (sql.js) and
 * renders every view from SQL queries. There is no generated data file: the
 * page always shows the ledger as committed. build-info.json (written by
 * `ledger.py site` and served live by `ledger.py serve`) is optional and adds
 * the commit, the build date and the result of `ledger.py check`.
 */
'use strict';

const PUBLIC_PROOFS = document.body.hasAttribute('data-public-proofs');
const ASSETS = new URL('.', document.currentScript.src);
const LEAN_ROOT = new URL('..', ASSETS).href.replace(/\/$/, '');
const DEFAULT_REPO = 'ANRGUSC/TINA';
const DEFAULT_LEAN_DIR = 'papers/arxiv-v3/lean';

let db, info = null, M = null;
const main = document.getElementById('main');
const tip = document.getElementById('tip');

/* ------------------------------------------------------------------ utils */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const plural = (n, one, many) => `${n} ${n === 1 ? one : (many || one + 's')}`;
const idKey = id => {
  const m = /^([A-Z])(\d+)(?:\.([a-z]))?/.exec(id) || [];
  return [m[1] || '', +(m[2] || 0), m[3] || ''];
};
const dispCmp = (a, b) => a.localeCompare(b, undefined, { numeric: true });
const idCmp = (a, b) => {
  const x = idKey(a), y = idKey(b);
  return x[0].localeCompare(y[0]) || x[1] - y[1] || x[2].localeCompare(y[2]) || a.localeCompare(b);
};

function q(sql, params) {
  const st = db.prepare(sql);
  st.bind(params || []);
  const rows = [];
  while (st.step()) rows.push(st.getAsObject());
  st.free();
  return rows;
}

/* --------------------------------------------------------- status scheme */
// Ten keys in five colour groups. Every use pairs the colour with an icon
// and a text label, so status never depends on colour alone.
const KEYS = {
  verified: { group: 'verified', label: 'Verified, follows the paper', glyph: '✓', c: '--st-verified',
    help: 'The Lean proof is complete, the statement is frozen, every step is a step of the proof in the paper, nothing is assumed, and only the standard axioms are used. Routine mathematical facts discharged by Routine/ or internal lemmas are listed under each claim’s Lean tab.' },
  vsup: { group: 'verified', label: 'Verified, Lean supplies steps', glyph: '+', c: '--st-vsup',
    help: 'Lean proves the statement in the paper, statement frozen, nothing assumed. Some or all of the argument is not in the paper: it is written in the ledger and marked as supplied.' },
  cond: { group: 'progress', label: 'Proved, still assumes a claim', glyph: '◐', c: '--st-p4',
    help: 'The Lean proof is complete and the statement frozen, but the assembled theorem takes a claim that is not proved yet as a hypothesis.' },
  p4: { group: 'progress', label: 'Proved, audit pending', glyph: '▸', c: '--st-p4',
    help: 'A Lean proof exists but the statement is not frozen or the axioms are not recorded yet.' },
  p3: { group: 'progress', label: 'Proof under way', glyph: '▸', c: '--st-p3',
    help: 'A Lean proof attempt is planned or active.' },
  p2: { group: 'progress', label: 'Statement approved', glyph: '▸', c: '--st-p2',
    help: 'The Lean statement has been reviewed or frozen. No proof attempt yet.' },
  p1: { group: 'progress', label: 'Statement drafted', glyph: '▸', c: '--st-p1',
    help: 'A draft Lean statement exists and awaits review against the paper.' },
  todo: { group: 'todo', label: 'Not started', glyph: '', c: '--st-todo',
    help: 'Nothing in Lean yet.' },
  blocked: { group: 'blocked', label: 'Waiting on a decision or a paper edit', glyph: '!', c: '--st-blocked',
    help: 'A point on this claim has no decision yet, a paper edit has been agreed and is not in the paper yet, or the last Lean attempt failed.' },
  out: { group: 'out', label: 'Outside Lean scope', glyph: '–', c: '--st-out',
    help: 'Numeric or prose claim. Tracked in the ledger, not proved in Lean.' },
};
const KEY_ORDER = ['verified', 'vsup', 'cond', 'p4', 'p3', 'p2', 'p1', 'todo', 'blocked', 'out'];
const DELTA = {
  extra_hypothesis: 'extra hypothesis', restricted: 'states less', stronger: 'states more',
  reading: 'reading', form: 'form',
};
const TIERS = {
  A: 'Real analysis and algebra',
  B: 'Finite-dimensional probability: L², conditional expectation, independence',
  C: 'L² projection onto a closed subspace',
  D: 'Gaussian processes and the continuum model',
};

function classify(c) {
  // A finding is settled once every point in it has been carried out.
  const settled = f => { const d = M.disp.filter(x => x.finding_id === f.id); return d.length > 0 && d.every(x => x.status === 'done'); };
  const open = M.findings.filter(f => f.claim_id === c.id && f.status === 'open' && !settled(f));
  c.minor = open.filter(f => f.severity === 'minor');
  c.disp = M.disp.filter(d => d.claim_id === c.id);
  c.reasons = [];
  if (c.scope !== 'lean') {
    c.key = 'out';
    c.detail = c.scope === 'numeric' ? 'numeric check' : 'prose';
    return;
  }
  const attempts = M.attempts.filter(a => a.claim_id === c.id);
  const needsProof = !['definition', 'assumption'].includes(c.kind);
  if (c.state === 'needs_paper_edit') {
    c.reasons.push({ short: 'paper edit pending',
      text: 'The Lean proof is complete but mirrors a proposed proof. The paper edit has to be approved and applied.' });
  }
  for (const d of c.disp) {
    if (d.decision === 'undecided') c.reasons.push({ short: `decision pending on ${d.id}`, text: `No decision yet on ${d.id}: ${d.point}` });
    else if (d.decision === 'paper_edit' && d.status === 'open') c.reasons.push({ short: `paper edit agreed (${d.id})`, text: `Paper edit agreed and not yet in the paper (${d.id}): ${d.point}` });
  }
  if (needsProof && !c.paper_proof && !c.disp.some(d => d.whole_proof)) {
    c.reasons.push({ short: 'no proof, no decision', text: 'The paper gives no proof of this claim and no decision says whether the paper or Lean supplies one.' });
  }
  if (attempts.some(a => a.status === 'failed') && !attempts.some(a => ['planned', 'active', 'proved'].includes(a.status))) {
    c.reasons.push({ short: 'Lean attempt failed', text: 'The last Lean attempt failed and no new attempt is open.' });
  }
  if (c.reasons.length) { c.key = 'blocked'; c.detail = c.reasons[0].short; return; }
  const assumes = c.assumes ? `assumes ${c.assumes}` : '';
  if (c.state === 'verified') c.key = 'verified';
  else if (c.state === 'verified_supplied') { c.key = 'vsup'; c.detail = c.proof_status === 'supplement' ? 'proof not in the paper' : `${c.n_supplied} of ${c.n_steps} steps supplied`; }
  else if (c.state === 'conditional') { c.key = 'cond'; c.detail = assumes; }
  else if (c.state === 'proved_unaudited') { c.key = 'p4'; c.detail = [c.stmt_status !== 'frozen' ? `statement ${c.stmt_status}` : '', assumes].filter(Boolean).join(', '); }
  else if (c.state === 'proving') { c.key = 'p3'; if (c.n_steps) c.detail = `${c.n_steps_proved}/${c.n_steps} steps`; }
  else if (c.state === 'stated') { c.key = c.stmt_status === 'draft' ? 'p1' : 'p2'; if (c.key === 'p2') c.detail = c.stmt_status; }
  else c.key = 'todo';
}

function buildModel() {
  M = {};
  M.meta = Object.fromEntries(q('SELECT key, value FROM meta').map(r => [r.key, r.value]));
  M.sources = Object.fromEntries(q('SELECT * FROM sources').map(r => [r.id, r]));
  M.findings = q('SELECT * FROM findings');
  M.disp = q('SELECT * FROM dispositions').sort((a, b) => dispCmp(a.id, b.id));
  M.deltas = q('SELECT * FROM statement_deltas ORDER BY formalization_id, ordinal');
  M.attempts = q('SELECT a.*, f.claim_id FROM attempts a JOIN formalizations f ON f.id = a.formalization_id');
  M.deps = q('SELECT * FROM claim_deps');
  M.claims = q(`SELECT s.*, c.parent, c.statement, c.source, c.label, c.line_start, c.line_end
                FROM v_claim_status s JOIN claims c ON c.id = s.id`).sort((a, b) => idCmp(a.id, b.id));
  M.byId = new Map(M.claims.map(c => [c.id, c]));
  // The ledger appends an editorial cross-reference inside C8's proof note.
  const staleGlobal = M.byId.get('C8');
  if (staleGlobal) staleGlobal.statement = staleGlobal.statement.replace('; until arXiv v3 that was the separate remark C8.b', '');
  M.claims.forEach(classify);
  M.lean = M.claims.filter(c => c.scope === 'lean');
}

/* ------------------------------------------------------- shared fragments */
const icon = key => `<span class="ico ${key}" style="--c:var(${KEYS[key].c})" aria-hidden="true">${KEYS[key].glyph}</span>`;
function statusChip(c, long) {
  if (c.kind === 'assumption' && !M.attempts.some(a => a.claim_id === c.id && a.selected)) {
    return '<span class="chip">Model assumption</span>';
  }
  const k = KEYS[c.key];
  const extra = c.detail && long !== false ? ` · ${esc(c.detail)}` : '';
  if (long === false && c.key === 'blocked') return `<span class="chip" data-tip="${esc(k.help)}">${icon(c.key)}Waiting</span>`;
  return `<span class="chip" data-tip="${esc(k.help)}">${icon(c.key)}${esc(k.label)}${extra}</span>`;
}
function minorBadge(c) {
  return c.minor.length
    ? `<span class="badge" data-tip="${esc(c.minor.map(f => `${f.id}: ${f.title}`).join(' | '))}"><span class="dot" style="--c:var(--sev-minor)"></span>${plural(c.minor.length, 'minor finding')}</span>`
    : '';
}
const claimLink = (id, withTitle) => {
  const c = M.byId.get(id);
  if (!c) return `<span class="idlink">${esc(id)}</span>`;
  return `<a class="idlink" href="#/claim/${encodeURIComponent(id)}" data-tip-title="${esc(id)}: ${esc(c.title)}" data-tip="${esc(KEYS[c.key].label)}${c.detail ? ' · ' + esc(c.detail) : ''}">${esc(id)}</a>${withTitle ? ' ' + esc(c.title) : ''}`;
};
// Turn ledger ids inside already-escaped text into links.
function linkIds(html) {
  return html.replace(/\b(C\d+(?:\.[a-z])?)(?:\/[pfad]\d+(?:\/[sd]\w+)?)?/g,
    (m, id) => M.byId.has(id) ? `<a class="idlink" href="#/claim/${encodeURIComponent(id)}">${m}</a>` : m);
}
const prose = s => linkIds(esc(s)).replace(/\n/g, '<br>');
const repo = () => (info && info.repo) || DEFAULT_REPO;
const leanDir = () => (info && info.lean_dir) || DEFAULT_LEAN_DIR;
function paperLink(source, l1, l2) {
  const s = M.sources[source];
  if (!s) return '';
  const file = s.path.split('/').pop();
  const lines = l1 ? `#L${l1}${l2 && l2 !== l1 ? '-L' + l2 : ''}` : '';
  const label = l1 ? `${file}, lines ${l1}${l2 && l2 !== l1 ? '–' + l2 : ''}` : file;
  return `<a href="https://github.com/${repo()}/blob/${s.git_commit || 'main'}/${s.path}${lines}" target="_blank" rel="noopener">${esc(label)}</a>`;
}
const leanLink = file =>
  `<a href="https://github.com/${repo()}/blob/${(info && info.commit) || 'main'}/${leanDir()}/${file}" target="_blank" rel="noopener">${esc(file)}</a>`;
function stackBar(counts, cls) {
  const total = KEY_ORDER.reduce((s, k) => s + (counts[k] || 0), 0) || 1;
  return `<div class="stack ${cls || ''}" role="img" aria-label="${esc(KEY_ORDER.filter(k => counts[k]).map(k => `${KEYS[k].label}: ${counts[k]}`).join(', '))}">${
    KEY_ORDER.filter(k => counts[k]).map(k =>
      `<span style="--c:var(${KEYS[k].c});flex:${counts[k] / total}" data-tip-title="${esc(KEYS[k].label)}" data-tip="${counts[k]} of ${total} claims"></span>`).join('')}</div>`;
}
const countKeys = list => list.reduce((o, c) => (o[c.key] = (o[c.key] || 0) + 1, o), {});
function deltaList(formId) {
  const rows = M.deltas.filter(d => d.formalization_id === formId);
  if (!rows.length) return '';
  return `<p style="margin:8px 0 2px"><b>Where it differs from the paper's statement.</b></p>
    <ul class="deltas">${rows.map(d => `<li><span class="tag ${d.kind}">${esc(DELTA[d.kind])}</span> ${prose(d.text)}${d.disposition_id ? ` <span class="small muted">(${linkIds(esc(d.disposition_id))})</span>` : ''}</li>`).join('')}</ul>`;
}

/* ------------------------------------------------------------- TeX + Lean */
function mathHtml(tex, display) {
  tex = tex.replace(/\\label\{[^}]*\}/g, '').replace(/\\(nonumber|notag)\b/g, '')
    .replace(/\\(?:eq)?ref\{([^}]*)\}/g, (m, l) => `\\text{(${l.replace(/_/g, '\\_')})}`);
  if (window.katex) {
    try { return window.katex.renderToString(tex, { displayMode: display, throwOnError: false, strict: 'ignore' }); } catch (e) { /* fall through */ }
  }
  return display ? `<pre class="code">${esc(tex.trim())}</pre>` : `<code>${esc(tex)}</code>`;
}
function texText(s) {
  return esc(s)
    .replace(/\\emph\{([^{}]*)\}/g, '<em>$1</em>').replace(/\\textit\{([^{}]*)\}/g, '<em>$1</em>')
    .replace(/\\textbf\{([^{}]*)\}/g, '<strong>$1</strong>')
    .replace(/\\(?:eq)?ref\{([^}]*)\}/g, '<span class="ref">($1)</span>')
    .replace(/\\cite[a-z]*\{([^}]*)\}/g, '<span class="ref">[$1]</span>')
    .replace(/\\label\{[^}]*\}/g, '')
    .replace(/``/g, '“').replace(/''/g, '”').replace(/---/g, '—').replace(/--/g, '–')
    .replace(/\\%/g, '%').replace(/\\\\/g, '<br>').replace(/~/g, '&nbsp;')
    .replace(/\n\s*\n/g, '<br><br>');
}
function texHtml(src) {
  const re = /\\begin\{(equation|align|gather|multline|eqnarray)(\*?)\}([\s\S]*?)\\end\{\1\2\}|\\\[([\s\S]*?)\\\]|\$\$([\s\S]*?)\$\$|\$((?:\\.|[^$\\])+?)\$/g;
  const out = [];
  let last = 0, m;
  while ((m = re.exec(src))) {
    out.push(texText(src.slice(last, m.index)));
    if (m[1]) {
      const env = /align|eqnarray/.test(m[1]) ? 'aligned' : /gather|multline/.test(m[1]) ? 'gathered' : null;
      out.push(mathHtml(env ? `\\begin{${env}}${m[3]}\\end{${env}}` : m[3], true));
    } else if (m[4] != null) out.push(mathHtml(m[4], true));
    else if (m[5] != null) out.push(mathHtml(m[5], true));
    else out.push(mathHtml(m[6], false));
    last = re.lastIndex;
  }
  out.push(texText(src.slice(last)));
  return `<div class="tex">${out.join('')}</div>`;
}
function leanHtml(src) {
  const re = /(\/-[\s\S]*?-\/)|(--.*$)|("(?:[^"\\]|\\.)*")|\b(theorem|lemma|def|abbrev|structure|class|instance|namespace|section|end|open|import|variable|noncomputable|where|fun|by|let|have|show|from|if|then|else|match|with|at|in|private|protected)\b/gm;
  let out = '', last = 0, m;
  while ((m = re.exec(src))) {
    out += esc(src.slice(last, m.index));
    out += `<span class="${m[1] || m[2] ? 'lc' : m[3] ? 'ls' : 'lk'}">${esc(m[0])}</span>`;
    last = re.lastIndex;
  }
  return `<pre class="code">${out + esc(src.slice(last))}</pre>`;
}
const leanCache = new Map();
function loadLean(file) {
  if (!leanCache.has(file)) {
    leanCache.set(file, fetch(`${LEAN_ROOT}/${file}`).then(r => { if (!r.ok) throw new Error(r.status); return r.text(); }));
  }
  return leanCache.get(file);
}
/* --------------------------------------------------------------- overview */
function viewOverview() {
  const lean = M.lean;
  const n = k => lean.filter(c => c.key === k).length;
  const stmt = q(`SELECT status, COUNT(*) n FROM v_formalization GROUP BY status`);
  const stmtN = s => (stmt.find(r => r.status === s) || { n: 0 }).n;
  const stmtTotal = stmt.reduce((s, r) => s + r.n, 0);
  const live = "p.status IN ('in_paper','supplement') AND p.is_primary = 1";
  const steps = q(`SELECT COUNT(*) n, SUM(s.origin = 'supplied') sup FROM steps s JOIN proofs p ON p.id = s.proof_id WHERE ${live}`)[0];
  const stepsProved = q(`SELECT COUNT(DISTINCT m.step_id) n FROM step_map m JOIN attempts a ON a.id = m.attempt_id
                         JOIN steps s ON s.id = m.step_id JOIN proofs p ON p.id = s.proof_id
                         WHERE m.status = 'proved' AND a.selected = 1 AND ${live}`)[0].n;
  const nProofs = q(`SELECT COUNT(*) n FROM proofs p WHERE ${live}`)[0].n;
  const tile = (k, v, d) => `<div class="card tile"><div class="k">${k}</div><div class="v">${v}</div><div class="d">${d}</div></div>`;
  const counts = countKeys(M.claims);
  const legend = KEY_ORDER.filter(k => counts[k] || k === 'verified' || k === 'vsup').map(k =>
    `<button class="item" data-filter="${k}" data-tip="${esc(KEYS[k].help)}">${icon(k)}<span>${esc(KEYS[k].label)}</span> <b>${counts[k] || 0}</b></button>`).join('');

  const tiers = Object.keys(TIERS).map(t => {
    const list = lean.filter(c => c.tier === t);
    return `<tr><td><b>${t}</b></td><td>${esc(TIERS[t])}</td><td style="min-width:180px">${stackBar(countKeys(list), 'thin')}</td>
      <td class="num">${list.filter(c => c.key === 'verified' || c.key === 'vsup').length} / ${list.length}</td>
      <td>${list.map(c => `<a class="idlink" href="#/claim/${encodeURIComponent(c.id)}" data-tip-title="${esc(c.id)}: ${esc(c.title)}" data-tip="${esc(KEYS[c.key].label)}${c.detail ? ' · ' + esc(c.detail) : ''}">${icon(c.key)}</a>`).join(' ')}</td></tr>`;
  }).join('');
  main.innerHTML = `
    ${checkAlert()}
    <div class="tiles">
      ${tile('Verified in Lean', `${n('verified') + n('vsup')} <small>/ ${lean.length}</small>`, `${n('verified')} follow the paper step for step, ${n('vsup')} with steps Lean supplies`)}
      ${tile('Lean statements written', `${stmtTotal} <small>/ ${lean.length}</small>`, `${stmtN('frozen')} frozen, ${stmtN('reviewed')} reviewed, ${stmtN('draft')} draft`)}
      ${tile('Proof steps proved in Lean', `${stepsProved} <small>/ ${steps.n}</small>`, `${steps.n} steps across ${plural(nProofs, 'written proof')}, ${steps.sup || 0} of them supplied; one Lean lemma per step`)}
    </div>
    <h2>All ${M.claims.length} claims by status</h2>
    <div class="card">${stackBar(counts)}<div class="legend">${legend}</div></div>
    <h2>By tier</h2>
    <div class="tbl-wrap"><table>
      <thead><tr><th>Tier</th><th>Needs</th><th>Status</th><th class="num">Verified</th><th>Claims</th></tr></thead>
      <tbody>${tiers}</tbody></table></div>
    <h2>How to read this page</h2>
    <div class="card">
      <p>Open a claim to read its proof sketch, manuscript passage, Lamport proof, and Lean source, or use the <a href="#/audit">Step audit</a> view to inspect every <code>(Step TeX ↔ Lean step lemma signature + statement_deltas)</code> pair side by side. Steps marked <b>supplied</b> give arguments that the manuscript leaves implicit.</p>
      <p><b>What verified means.</b> The Lean statement has been compared with the paper and frozen, the proof is complete, the
      end-to-end assembly assumes no unproved claim, and Lean reports only the three standard axioms. The two greens say where the
      argument comes from: the paper, or the paper plus supplied steps. Across all claims, <b>${M.disp.filter(d => d.decision === 'lean_supplies' && d.lean_ref).length}</b> routine-level <code>lean_ref</code> dispositions record technical bookkeeping discharged in <code>Routine/</code> or inside existing step lemmas (surfaced on each claim’s Lean tab and in the Step audit view).</p>
      ${info?.verification?.comparator_passed ? `<p><b>Gate-3 multi-kernel replay.</b> <code>lake comparator --paranoid</code> verified all assembled theorems against hash-locked ${leanLink('comparator/Challenge.lean')} (SHA-256 <code>${esc((info.verification.challenge_sha256 || '').slice(0, 16))}…</code>) across <b>${(info.verification.kernels_passed || []).length}</b> independent kernels: ${(info.verification.kernels_passed || []).map(k => `<code>${esc(k)}</code>`).join(', ')}.</p>` : ''}
    </div>`;
}

/* ---------------------------------------------------------------- results */
function viewResults() {
  const rows = q('SELECT * FROM v_headline').sort((a, b) => idCmp(a.id, b.id));
  const std = ['Classical.choice', 'Quot.sound', 'propext'];
  main.innerHTML = `<h2>Advertised results</h2>
    <p class="muted">One row per theorem, proposition, lemma and corollary of the paper: where it is in the paper, the Lean theorem
      that states it, how that statement differs from the paper's, where the proof comes from, what the Lean proof still assumes,
      and the axioms Lean reports. This is the record to check a result against; a successful build alone would not show a step
      that was supplied as a hypothesis.</p>
    <div class="tbl-wrap"><table class="results">
      <thead><tr><th>Result</th><th>Lean theorem</th><th>Lean statement</th><th>Proof</th><th>Still assumes</th><th>Axioms</th><th>Status</th></tr></thead>
      <tbody>${rows.map(r => {
        const c = M.byId.get(r.id);
        const ax = r.axioms ? r.axioms.split(', ') : null;
        const extra = ax ? ax.filter(a => !std.includes(a)) : [];
        const deltas = M.deltas.filter(d => d.formalization_id === c.formalization);
        return `<tr><td>${claimLink(r.id)} ${esc(r.title)}${r.label ? `<br><code class="small">${esc(r.label)}</code>` : ''}</td>
          <td>${r.lean_decl ? `<code>${esc(r.lean_decl)}</code>` : '<span class="muted">not stated yet</span>'}</td>
          <td>${r.stmt_status ? `${esc(r.stmt_status)}${deltas.length ? `<details><summary class="small">${plural(deltas.length, 'difference')} from the paper${r.narrower ? `, ${r.narrower} where Lean states less` : ''}</summary>${deltaList(c.formalization)}</details>` : '<br><span class="small muted">no differences recorded</span>'}` : ''}</td>
          <td class="nowrap">${!r.proof ? '<span class="muted">none yet</span>' : r.proof_home === 'paper'
            ? `the paper's<br><span class="small muted">${plural(r.n_steps - r.n_supplied, 'paper step')}${r.n_supplied ? ` + ${r.n_supplied} supplied` : ''}</span>`
            : `supplied<br><span class="small muted">${plural(r.n_steps, 'step')}, not in the paper</span>`}</td>
          <td>${r.assumes ? r.assumes.split(', ').map(x => claimLink(x)).join(', ') : r.proof ? 'nothing' : ''}</td>
          <td>${!ax ? (r.proof ? '<span class="muted">not recorded</span>' : '') : extra.length ? `<b>${esc(extra.join(', '))}</b> beyond the standard three` : `<span data-tip="${esc(r.axioms)}">standard three</span>`}</td>
          <td>${statusChip(c, !c.reasons.length)}${c.reasons.length ? `<ul class="reasons small">${c.reasons.map(x => `<li>${prose(x.short)}</li>`).join('')}</ul>` : ''}</td></tr>`;
      }).join('')}</tbody></table></div>
    <p class="small muted" style="margin-top:10px">Same table on the command line: <code>python3 tools/ledger.py headline</code>.
      The standard axioms are <code>propext</code>, <code>Classical.choice</code> and <code>Quot.sound</code>.</p>`;
}

function checkAlert() {
  if (!info || !info.check) return '';
  const { errors = [], warnings = [] } = info.check;
  if (!errors.length && !warnings.length) return '';
  return `<details class="alert" style="--c:var(${errors.length ? '--st-blocked' : '--st-todo'})">
    <summary>Ledger check at build time: ${plural(errors.length, 'error')}, ${plural(warnings.length, 'warning')}.
      ${errors.length ? 'The ledger and the paper source in this commit disagree, so the statuses below describe the paper as it was when the ledger was aligned.' : ''}</summary>
    <ul>${errors.map(e => `<li><b>error</b> ${prose(e)}</li>`).join('')}${warnings.map(w => `<li><b>warning</b> ${prose(w)}</li>`).join('')}</ul>
  </details>`;
}

/* ------------------------------------------------------------------ graph */
// Reader-facing explanations. The precise statement and review status come from the ledger.
const graphExplanations = {
  'C1': 'Imagine knowing the ideal action for every state, then restricting each agent to what it can observe. The best team policy is the feasible one closest to those ideal actions on average, with errors weighted by their cost.',
  'C1.b': 'Once the team has chosen its best feasible policy, no adjustment based on the same observations can predict the remaining error in a direction that reduces cost. This lets us split the value of full information into the part the policy captures and the part it misses.',
  'C1.c': 'Giving agents more information can only improve their best achievable performance or leave it unchanged. They can always ignore the extra readings and use their old policy.',
  'C2': 'At the best team decision, each agent expects no first-order cost saving from nudging its action, given what it can see. For this quadratic cost, satisfying that condition for every agent is enough to identify the optimum.',
  'C3': 'When every agent sees the same report, the team should use the average full-information action among states consistent with that report. This works even when one agent’s error affects the cost of another’s.',
  'C3.b': 'If having no observations already costs nothing, the ideal action in centered coordinates is zero with probability one. Every information arrangement can then achieve zero regret, and there is no positive loss by which to divide.',
  'C3.c': 'In the stationary Markov model, an older complete snapshot cannot improve the best prediction. Stationarity makes the expected loss the same at each time, while interpreting a long run on one sample path as that expectation also calls for ergodicity.',
  'C4': 'Given the whole old network state, your best prediction scales every old reading by the same factor, which shrinks as the snapshot ages. Even knowing all the old readings, the remaining error averages to zero.',
  'C4.b': 'In this discrete-time model, each step retains a fixed fraction of the previous state and adds a disturbance whose average given the past is zero. Looking ahead several steps multiplies that fraction once per step.',
  'C4.c': 'In the continuous-time Gaussian model studied here, an old reading predicts a deviation from the mean that fades exponentially with time. The random change since that reading has mean zero given the old state, as C4 requires.',
  'C5': 'For a given state, the quadratic cost has one ideal action. Choosing any other action adds exactly half the squared distance from that ideal, with the cost matrix determining which errors matter most.',
  'C5.b': 'Known averages can be subtracted from both the observations and the actions. Working with deviations from those averages preserves every feasible decision rule and the error it makes.',
  'C6': 'An information architecture specifies which readings each agent receives and how old they are. Regret measures the extra cost of the best decisions those readings allow, compared with decisions made with full current information.',
  'C6.b': 'If an agent has no readings, the team’s best fixed choice is the average ideal action, which is zero after centering. The remaining loss measures how much those ideal actions vary in directions that matter for cost.',
  'C6.c': 'With fresh readings, the fraction of the no-information loss that remains is between zero and one. It can only fall or stay the same as the neighborhood expands, and it reaches zero once every agent sees the whole connected graph.',
  'C7': 'Delay mixes two losses: the loss with no information and the loss with a fresh view of the same neighborhood. The weight on the fresh-view loss is the square of the prediction factor, so older readings move performance toward the no-information baseline.',
  'C7.b': 'Measure a snapshot’s value by the fraction of the no-information loss it saves. A delayed snapshot saves the fraction a fresh neighborhood would save, multiplied by the square of the prediction factor.',
  'C8': 'With a complete old snapshot, the team can act on everything the old state predicts. Its remaining regret comes entirely from changes since the snapshot, and the formula gives that loss at any finite delay.',
  'C8.c': 'A complete snapshot starts with zero regret. For short delays its loss grows approximately in proportion to its age, and for very long delays it approaches the loss of acting without observations.',
  'C9': 'A complete snapshot can reveal independent patterns that fade at different speeds. Its remaining value is a weighted average of what each pattern retains, with greater weight on patterns that matter more to the decision.',
  'C10': 'The more useful information a fresh local reading misses, the older a complete report can be before the local reading beats it. If the local reading misses everything, the complete report wins at every finite age.',
  'C10.b': 'If a local reading already determines the ideal action, it beats a complete report at any positive delay. If the reading captures only part of what matters, the two choices tie at exactly one delay.',
  'C11': 'To estimate the average of two independent sensor signals, would you take one fresh reading or both old readings? In this example, the fresh reading gives smaller mean squared error once the pair is more than about 0.35 coherence times old.',
  'C12': 'When the team pays a penalty for its combined action, each agent’s best response to its own fresh reading is to scale it down by a fixed amount. The result also quantifies the loss from being unable to see the other agents’ readings.',
  'C13': 'For the shared-resource example, team size and the penalty on the combined action determine a specific delay threshold. Above it, using fresh local readings costs less than using a complete old report.',
  'C13.b': 'As the team grows, the delay threshold approaches a finite limit. Local readings continue to capture a definite share of the available benefit, determined by the relative strengths of the individual and shared costs.',
  'C13.c': 'With no shared penalty, any positive delay favors fresh local readings. As the penalty couples agents more strongly, knowing what others are doing becomes more valuable and a complete report can be older before local readings win.',
  'C14': 'One more hop gives an agent a wider view but can make the whole snapshot older. Take that hop if the wider snapshot still saves more expected loss after its extra delay is counted.',
  'C15': 'If the best observation radius lies between the two allowed extremes, a small expansion buys exactly as much in additional predictive value as its delay costs. The balance compares proportional changes in value.',
  'C15.b': 'Suppose the advantage of expanding a little farther steadily decreases with radius. The best radius is where that advantage crosses zero, or at the appropriate endpoint if expanding is already unhelpful at the start or still worthwhile at the end.',
  'C15.c': 'With the same spatial information curve and a single crossing, slower changes in the state can move the best radius outward, while slower delivery can move it inward. The best radius can stay put, for example at a boundary.',
  'C16': 'Suppose the information missed falls exponentially with radius and waiting time grows in proportion to distance. The best choice is to stay local if the first expansion gains too little, and otherwise expand to the balance point or the allowed range limit.',
  'C17': 'Picture sensors all along a line, with nearby readings and nearby times more closely related. Each location wants a distance-weighted average of the field and can see an interval around it, but a wider interval takes longer to arrive.',
  'C17.b': 'Even with a whole interval of sensors on the line, delay reduces the value of its readings by the same factor as in the network model. If the best predicted action shrinks by a given factor, the gain under squared error shrinks by its square.',
  'C18': 'On the Gaussian line, knowing a fresh interval lets each boundary reading predict part of the unobserved region beyond it. The fraction of decision-relevant information still missing falls exponentially as the interval widens.',
  'C19': 'In the line model, it pays to look beyond the local reading exactly when a report can travel more than twice the spatial correlation length in one coherence time. The theorem gives the unique best radius on either side of that threshold.',
  'C19.b': 'When the best radius is positive, it grows if reports travel faster, the state changes more slowly, or the decision gives distant readings more weight. It shrinks if nearby readings resemble each other over greater distances, comparing settings that stay in the positive-radius regime.',
  'C20': 'Even if the decision gives weight to readings farther and farther away, the best observation radius approaches a finite limit. In the positive-radius regime, that limit is half the distance a report travels in one coherence time, minus one spatial correlation length.',
  'C21': 'In the shared-resource simulation, the estimated delay at which fresh local readings overtake a complete old report agrees with the theoretical boundary. The comparison checks the prediction in the simulated cases.',
  'C22': 'With the allowed radius capped at two, the best choice differs across the three plotted examples. One stays local, another stops partway out at about 0.63, and the third uses the full allowed range.',
  'C23': 'On the same 64-node ring, changing only how far the decision weights reach shifts the best observation radius from one hop to two and then five. The network and its delay per hop stay fixed.',
  'C24': 'In the plotted path, ring, grid, and random geometric networks, the best radii are two, two, three, and two hops, respectively. Each optimum is well short of the distance needed to see the whole network.',
  'C25': 'The paper asks when fresh local information beats an old global view, how far an agent should look, and how that choice changes with the decision it must make. Its main examples put numbers on each of those tradeoffs.',
  'C26': 'The paper connects its results to earlier work on team decisions and the value of fresh information. In particular, it identifies where Marschak and Radner already derived the marginal balance and the local information share used here.',
  'C27': 'On a general finite graph, compare the available hop counts directly. In the continuous model, a single crossing of the gain and delay rates can identify the optimum.',
};
const G = { showOut: false, kinds: { uses: true, setup: true, instantiates: true, evidence: true }, sel: null, vb: null };
const NW = 128, NH = 54, GX = 12, GY = 54;

function layoutGraph(ids, edges) {
  const parents = new Map(ids.map(i => [i, []])), children = new Map(ids.map(i => [i, []]));
  edges.forEach(e => { parents.get(e.to).push(e.from); children.get(e.from).push(e.to); });
  const depth = new Map(), visiting = new Set();
  const dfs = id => {
    if (depth.has(id)) return depth.get(id);
    if (visiting.has(id)) return 0;
    visiting.add(id);
    const d = Math.max(-1, ...parents.get(id).map(dfs)) + 1;
    visiting.delete(id);
    depth.set(id, d);
    return d;
  };
  ids.forEach(dfs);
  const layers = [];
  ids.forEach(id => (layers[depth.get(id)] = layers[depth.get(id)] || []).push(id));
  const pos = new Map();
  const place = L => L.forEach((id, i) => pos.set(id, i - (L.length - 1) / 2));
  layers.forEach(place);
  const bary = (id, nb) => { const a = nb.get(id); return a.length ? a.reduce((s, x) => s + pos.get(x), 0) / a.length : pos.get(id); };
  const sortBy = (L, nb) => { const b = new Map(L.map(id => [id, bary(id, nb)])); L.sort((x, y) => b.get(x) - b.get(y)); place(L); };
  for (let it = 0; it < 8; it++) {
    for (let i = 1; i < layers.length; i++) sortBy(layers[i], parents);
    for (let i = layers.length - 2; i >= 0; i--) sortBy(layers[i], children);
  }
  // Coordinates: pull each node toward the mean of its neighbours, keep order and spacing.
  const S = NW + GX, x = new Map();
  layers.forEach(L => L.forEach((id, i) => x.set(id, (i - (L.length - 1) / 2) * S)));
  const relax = (L, nbs) => {
    const want = L.map(id => { const a = nbs(id); return a.length ? a.reduce((s, n) => s + x.get(n), 0) / a.length : x.get(id); });
    const got = [];
    L.forEach((id, i) => got.push(i ? Math.max(want[i], got[i - 1] + S) : want[i]));
    for (let i = L.length - 2; i >= 0; i--) got[i] = Math.min(got[i], got[i + 1] - S);
    const shift = want.reduce((s, w, i) => s + w - got[i], 0) / L.length;
    L.forEach((id, i) => x.set(id, got[i] + shift));
  };
  for (let it = 0; it < 6; it++) {
    for (let i = 1; i < layers.length; i++) relax(layers[i], id => parents.get(id));
    for (let i = layers.length - 2; i >= 0; i--) relax(layers[i], id => children.get(id));
  }
  const minX = Math.min(...ids.map(id => x.get(id)));
  const nodes = new Map(ids.map(id => [id, { id, x: x.get(id) - minX + 20, y: depth.get(id) * (NH + GY) + 20 }]));
  const w = Math.max(...[...nodes.values()].map(n => n.x)) + NW + 20;
  const h = layers.length * (NH + GY) - GY + 40;
  return { nodes, w, h, parents, children };
}
function wrapTitle(t, max) {
  const words = t.split(/\s+/), lines = [''];
  for (const w of words) {
    const cur = lines[lines.length - 1];
    if ((cur + ' ' + w).trim().length <= max) lines[lines.length - 1] = (cur + ' ' + w).trim();
    else if (lines.length < 2) lines.push(w);
    else { lines[1] = `${lines[1]} ${w}`.slice(0, max - 1).trimEnd() + '…'; break; }
  }
  return lines.map(l => l.length > max + 1 ? l.slice(0, max) + '…' : l);
}
function closure(start, nb) {
  const seen = new Set(), stack = [start];
  while (stack.length) for (const n of nb.get(stack.pop()) || []) if (!seen.has(n)) { seen.add(n); stack.push(n); }
  return seen;
}

function viewGraph(focus) {
  if (focus && M.byId.has(focus)) { G.sel = focus; if (M.byId.get(focus).scope !== 'lean') G.showOut = true; }
  main.innerHTML = `
    <div class="filters">
      <button class="toggle text" id="g-out" aria-pressed="${G.showOut}">Numeric and prose claims</button>
      <span class="muted small">Edges:</span>
      ${Object.keys(G.kinds).map(k => `<button class="toggle text" data-kind="${k}" aria-pressed="${G.kinds[k]}"><span class="edge-key ${k}"></span> ${k}</button>`).join('')}
    </div>
    <div class="graph-box">
      <svg id="gsvg" role="img" aria-label="Claim dependency graph"></svg>
      <div class="zoom"><button id="z-in" aria-label="Zoom in">+</button><button id="z-out" aria-label="Zoom out">−</button><button id="z-fit" aria-label="Fit to view" data-tip="Fit to view">⤢</button></div>
      <aside class="card side" id="gside" hidden></aside>
    </div>
    <div class="legend">${(counts => KEY_ORDER.map(k => `<span class="item" data-tip="${esc(KEYS[k].help)}">${icon(k)}${esc(KEYS[k].label)} <b>${counts[k] || 0}</b></span>`).join(''))(countKeys(M.claims.filter(x => G.showOut || x.scope === 'lean')))}
      <span class="item"><span class="ico todo" style="--c:var(--sev-minor)">1</span>open minor findings on the claim</span></div>
    <p class="muted small" style="margin-top:10px">Foundations are at the top; an arrow runs from a claim to the claims that rest on it.
      <b>uses</b> is a logical dependency in the paper's argument, <b>setup</b> a definition or assumption the claim is stated in,
      <b>instantiates</b> a special case, <b>evidence</b> a numeric or prose claim resting on a result.
      Click a claim to trace everything upstream and downstream of it; double-click opens it. Drag to pan; pinch or use the buttons to zoom.</p>`;
  drawGraph(true);
  document.getElementById('g-out').onclick = () => { G.showOut = !G.showOut; G.sel = null; viewGraph(); };
  main.querySelectorAll('[data-kind]').forEach(b => b.onclick = () => { G.kinds[b.dataset.kind] = !G.kinds[b.dataset.kind]; viewGraph(); });
}

function drawGraph(fit) {
  const svg = document.getElementById('gsvg');
  const claims = M.claims.filter(c => G.showOut || c.scope === 'lean');
  const ids = claims.map(c => c.id), has = new Set(ids);
  if (G.sel && !has.has(G.sel)) G.sel = null;
  const allEdges = M.deps.filter(d => has.has(d.claim_id) && has.has(d.depends_on))
    .map(d => ({ from: d.depends_on, to: d.claim_id, kind: d.kind, note: d.note }));
  // Layout uses every edge so positions stay put when an edge kind is hidden.
  const lay = layoutGraph(ids, allEdges);
  const edges = allEdges.filter(e => G.kinds[e.kind]);
  let up = new Set(), down = new Set();
  if (G.sel) {
    const par = new Map(ids.map(i => [i, []])), chi = new Map(ids.map(i => [i, []]));
    edges.forEach(e => { par.get(e.to).push(e.from); chi.get(e.from).push(e.to); });
    up = closure(G.sel, par); down = closure(G.sel, chi);
  }
  const inUp = id => id === G.sel || up.has(id), inDown = id => id === G.sel || down.has(id);
  const edgeSvg = edges.map(e => {
    const a = lay.nodes.get(e.from), b = lay.nodes.get(e.to);
    const x1 = a.x + NW / 2, y1 = a.y + NH, x2 = b.x + NW / 2, y2 = b.y - 5, my = (y1 + y2) / 2;
    const hot = G.sel && ((inUp(e.from) && inUp(e.to)) || (inDown(e.from) && inDown(e.to)));
    return `<path class="gedge ${e.kind} ${hot ? 'hot' : G.sel ? 'dim' : ''}" marker-end="url(#${hot ? 'ah' : 'a'})"
      d="M${x1},${y1} C${x1},${my} ${x2},${my} ${x2},${y2}"><title>${esc(e.to)} ${esc(e.kind)} ${esc(e.from)}${e.note ? ': ' + esc(e.note) : ''}</title></path>`;
  }).join('');
  const nodeSvg = claims.map(c => {
    const n = lay.nodes.get(c.id), k = KEYS[c.key];
    const dim = G.sel && c.id !== G.sel && !up.has(c.id) && !down.has(c.id);
    const lines = wrapTitle(c.title, 21);
    return `<g class="gnode ${c.key} ${c.id === G.sel ? 'sel' : ''} ${dim ? 'dim' : ''}" style="--c:var(${k.c})" data-id="${esc(c.id)}"
        transform="translate(${n.x},${n.y})" tabindex="0" role="button" aria-label="${esc(c.id)}: ${esc(c.title)}. ${esc(k.label)}"
        data-tip-title="${esc(c.id)}: ${esc(c.title)}" data-tip="${esc(k.label)}${c.detail ? ' · ' + esc(c.detail) : ''}${c.minor.length ? ' · ' + plural(c.minor.length, 'minor finding') : ''}">
      <rect class="body" width="${NW}" height="${NH}" rx="7"/>
      <circle class="gico" cx="15" cy="15" r="8.5"/><text class="gicot" x="15" y="19" text-anchor="middle">${k.glyph}</text>
      <text class="gid" x="29" y="20">${esc(c.id)}</text>
      ${c.tier ? `<text class="gtier" x="${NW - 8}" y="19" text-anchor="end">tier ${c.tier}</text>` : ''}
      ${lines.map((l, i) => `<text class="gtitle" x="8" y="${35 + i * 12.5}">${esc(l)}</text>`).join('')}
      ${c.minor.length ? `<circle class="warn" cx="${NW - 2}" cy="${NH - 2}" r="8"/><text class="warnt" x="${NW - 2}" y="${NH + 1}" text-anchor="middle">${c.minor.length}</text>` : ''}
    </g>`;
  }).join('');
  svg.innerHTML = `<defs>
      <marker id="a" viewBox="0 0 8 8" refX="1" refY="4" markerWidth="6" markerHeight="6" orient="auto"><path class="arrow" d="M0,0 L8,4 L0,8 z"/></marker>
      <marker id="ah" viewBox="0 0 8 8" refX="1" refY="4" markerWidth="6" markerHeight="6" orient="auto"><path class="arrow-hot" d="M0,0 L8,4 L0,8 z"/></marker>
    </defs>${edgeSvg}${nodeSvg}`;
  G.full = { x: 0, y: 0, w: lay.w, h: lay.h };
  if (fit || !G.vb) G.vb = { ...G.full };
  // Size the canvas to the graph: full width, no taller than the window.
  const scale = Math.min(1.15, svg.parentNode.clientWidth / lay.w);
  svg.style.height = `${Math.round(Math.max(360, Math.min(lay.h * scale, window.innerHeight * 0.86)))}px`;
  applyViewBox(svg);
  bindGraph(svg);
  drawSide(lay);
}
function applyViewBox(svg) { svg.setAttribute('viewBox', `${G.vb.x} ${G.vb.y} ${G.vb.w} ${G.vb.h}`); }
function zoomGraph(svg, f) {
  const { x, y, w, h } = G.vb;
  G.vb = { x: x + w * (1 - f) / 2, y: y + h * (1 - f) / 2, w: w * f, h: h * f };
  applyViewBox(svg);
}
function bindGraph(svg) {
  let drag = null, moved = false;
  svg.onpointerdown = e => { drag = { x: e.clientX, y: e.clientY, vb: { ...G.vb } }; moved = false; };
  svg.onpointermove = e => {
    if (!drag) return;
    const dx = e.clientX - drag.x, dy = e.clientY - drag.y;
    if (!moved && Math.hypot(dx, dy) < 4) return;
    if (!moved) { moved = true; svg.setPointerCapture(e.pointerId); svg.classList.add('drag'); }
    const r = svg.getBoundingClientRect(), s = Math.max(G.vb.w / r.width, G.vb.h / r.height);
    G.vb.x = drag.vb.x - dx * s; G.vb.y = drag.vb.y - dy * s;
    applyViewBox(svg);
  };
  svg.onpointerup = svg.onpointercancel = () => { drag = null; svg.classList.remove('drag'); };
  svg.onclick = e => {
    if (moved) { moved = false; return; }
    const g = e.target.closest('.gnode');
    G.sel = g ? (G.sel === g.dataset.id ? null : g.dataset.id) : null;
    drawGraph(false);
  };
  svg.ondblclick = e => { const g = e.target.closest('.gnode'); if (g) location.hash = `#/claim/${encodeURIComponent(g.dataset.id)}`; };
  svg.onkeydown = e => {
    const g = e.target.closest && e.target.closest('.gnode');
    if (g && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); G.sel = g.dataset.id; drawGraph(false); }
  };
  svg.onwheel = e => { if (e.ctrlKey || e.metaKey) { e.preventDefault(); zoomGraph(svg, e.deltaY > 0 ? 1.1 : 0.9); } };
  document.getElementById('z-in').onclick = () => zoomGraph(svg, 0.8);
  document.getElementById('z-out').onclick = () => zoomGraph(svg, 1.25);
  document.getElementById('z-fit').onclick = () => { G.vb = { ...G.full }; applyViewBox(svg); };
}
function drawSide(lay) {
  const side = document.getElementById('gside');
  const c = G.sel && M.byId.get(G.sel);
  side.hidden = !c;
  if (!c) return;
  const list = a => a.length ? a.sort(idCmp).map(id => claimLink(id)).join(', ') : '<span class="muted">none</span>';
  side.innerHTML = `<button class="close" id="g-close" aria-label="Clear selection">×</button>
    <h3><span class="idlink">${esc(c.id)}</span> ${esc(c.title)}</h3>
    <a class="btn" href="${claimHref(c.id, 'plain')}">All Proofs</a>
    ${graphExplanations[c.id] ? `<p class="claim-explanation">${esc(graphExplanations[c.id])}</p>
      <details class="graph-statement"><summary>Formal statement</summary><p>${esc(c.statement)}</p></details>`
      : `<p>${esc(c.statement)}</p>`}
    <p>${statusChip(c)} ${minorBadge(c)}</p>
    ${c.reasons.length ? `<ul class="reasons small">${c.reasons.map(r => `<li>${prose(r.text)}</li>`).join('')}</ul>` : ''}
    <dl><dt>Kind</dt><dd>${esc(c.kind)}${c.tier ? `, tier ${c.tier}` : ''}</dd>
      <dt>Rests on</dt><dd>${list([...lay.parents.get(c.id)])}</dd>
      <dt>Used by</dt><dd>${list([...lay.children.get(c.id)])}</dd></dl>`;
  document.getElementById('g-close').onclick = () => { G.sel = null; drawGraph(false); };
}

/* ----------------------------------------------------------------- claims */
const F = { keys: new Set(), tier: '', text: '', sort: 'id', dir: 1 };
function viewPublicClaims() {
  main.innerHTML = `<h2>Claims</h2><div class="filters"><input type="search" id="f-text"
    placeholder="Search by claim, title, or statement" aria-label="Search claims" value="${esc(F.text)}"></div>
    <div class="tbl-wrap"><table id="ctable"><thead><tr><th>Claim</th><th>Title</th><th>Kind</th></tr></thead>
    <tbody></tbody></table></div>`;
  const draw = () => {
    const query = F.text.trim().toLowerCase();
    const rows = M.claims.filter(c => `${c.id} ${c.title} ${c.statement} ${c.kind}`.toLowerCase().includes(query));
    main.querySelector('tbody').innerHTML = rows.map(c => `<tr><td>${claimLink(c.id)}</td>
      <td><a href="${claimHref(c.id, 'plain')}">${esc(c.title)}</a></td><td>${esc(c.kind)}</td></tr>`).join('')
      || '<tr><td colspan="3">No claims match.</td></tr>';
  };
  main.querySelector('#f-text').oninput = e => { F.text = e.target.value; draw(); };
  draw();
}

function viewClaims(params) {
  if (PUBLIC_PROOFS) return viewPublicClaims();
  if (params.has('key')) { F.keys = new Set(params.get('key').split(',').filter(k => KEYS[k])); }
  const counts = countKeys(M.claims);
  main.innerHTML = `
    <div class="filters">
      <input type="search" id="f-text" placeholder="Search id, title, statement" value="${esc(F.text)}" aria-label="Search claims">
      <select id="f-tier" aria-label="Tier"><option value="">All tiers</option>${Object.keys(TIERS).map(t => `<option ${F.tier === t ? 'selected' : ''}>${t}</option>`).join('')}</select>
      ${KEY_ORDER.filter(k => counts[k]).map(k => `<button class="toggle" data-key="${k}" aria-pressed="${!F.keys.size || F.keys.has(k)}">${icon(k)}${esc(KEYS[k].label)} <b>${counts[k]}</b></button>`).join('')}
      ${F.keys.size ? '<button class="btn ghost" id="f-clear">Show all</button>' : ''}
    </div>
    <div class="tbl-wrap"><table id="ctable"></table></div>`;
  const draw = () => {
    const text = F.text.toLowerCase();
    const rows = M.claims.filter(c => (!F.keys.size || F.keys.has(c.key)) && (!F.tier || c.tier === F.tier) &&
      (!text || `${c.id} ${c.title} ${c.statement} ${c.kind}`.toLowerCase().includes(text)));
    const sorters = {
      id: (a, b) => idCmp(a.id, b.id), title: (a, b) => a.title.localeCompare(b.title),
      tier: (a, b) => (a.tier || 'Z').localeCompare(b.tier || 'Z'), kind: (a, b) => a.kind.localeCompare(b.kind),
      status: (a, b) => KEY_ORDER.indexOf(a.key) - KEY_ORDER.indexOf(b.key),
      steps: (a, b) => (b.n_steps || 0) - (a.n_steps || 0),
    };
    rows.sort((a, b) => F.dir * sorters[F.sort](a, b) || idCmp(a.id, b.id));
    const th = (k, label, cls) => `<th class="sortable ${cls || ''}" data-sort="${k}" aria-sort="${F.sort === k ? (F.dir > 0 ? 'ascending' : 'descending') : 'none'}">${label}${F.sort === k ? (F.dir > 0 ? ' ▲' : ' ▼') : ''}</th>`;
    document.getElementById('ctable').innerHTML = `<thead><tr>${th('id', 'Claim')}${th('title', 'Title')}${th('kind', 'Kind')}${th('tier', 'Tier')}${th('status', 'Status')}<th>Written proof</th><th>Lean statement</th>${th('steps', 'Lean steps')}</tr></thead>
      <tbody>${rows.map(c => `<tr class="click" data-id="${esc(c.id)}">
        <td><a class="idlink" href="#/claim/${encodeURIComponent(c.id)}">${esc(c.id)}</a></td>
        <td>${esc(c.title)}</td><td>${esc(c.kind)}</td><td>${c.tier || ''}</td>
        <td>${statusChip(c)}</td>
        <td class="nowrap">${c.scope !== 'lean' ? '' : c.paper_proof ? `<span class="idlink">${esc(c.paper_proof)}</span> paper` : c.supplement_proof ? `<span class="idlink">${esc(c.supplement_proof)}</span> supplied` : ['definition', 'assumption'].includes(c.kind) && !c.disp.some(d => d.whole_proof) ? '<span class="muted">not needed</span>' : 'none yet'}</td>
        <td>${c.stmt_status ? esc(c.stmt_status) : ''}</td>
        <td class="nowrap">${c.n_steps ? `<span class="meter"><i style="width:${100 * c.n_steps_proved / c.n_steps}%"></i></span>${c.n_steps_proved}/${c.n_steps}${c.n_supplied ? ` <span class="small muted">(${c.n_supplied} supplied)</span>` : ''}` : ''}</td>
      </tr>`).join('') || `<tr><td colspan="8" class="muted">No claims match.</td></tr>`}</tbody>`;
  };
  draw();
  document.getElementById('f-text').oninput = e => { F.text = e.target.value; draw(); };
  document.getElementById('f-tier').onchange = e => { F.tier = e.target.value; draw(); };
  main.querySelectorAll('[data-key]').forEach(b => b.onclick = () => {
    const k = b.dataset.key;
    if (!F.keys.size) F.keys = new Set([k]); else if (F.keys.has(k)) F.keys.delete(k); else F.keys.add(k);
    history.replaceState(null, '', '#/claims'); viewClaims(new URLSearchParams());
  });
  const clear = document.getElementById('f-clear');
  if (clear) clear.onclick = () => { F.keys.clear(); history.replaceState(null, '', '#/claims'); viewClaims(new URLSearchParams()); };
  document.getElementById('ctable').onclick = e => {
    const th = e.target.closest('th[data-sort]');
    if (th) { if (F.sort === th.dataset.sort) F.dir = -F.dir; else { F.sort = th.dataset.sort; F.dir = 1; } draw(); return; }
    const tr = e.target.closest('tr[data-id]');
    if (tr && !e.target.closest('a')) location.hash = `#/claim/${encodeURIComponent(tr.dataset.id)}`;
  };
}

/* ------------------------------------------------------------- step audit */
const AU = { text: '', headline: false, deltasOnly: false, routineOnly: false };

function viewAudit(focusClaim) {
  const proved = M.lean.filter(c => M.attempts.some(a => a.claim_id === c.id && a.selected && a.status === 'proved'));
  const totalRoutine = M.disp.filter(d => d.decision === 'lean_supplies' && d.lean_ref).length;
  main.innerHTML = `<h2>Side-by-side step-signature audit</h2>
    <p class="muted">Human sign-off view pairing each claim’s frozen Lean statement and <code>statement_deltas</code> with every <code>(Step TeX ↔ Lean step lemma signature)</code> pair and all <b>${totalRoutine}</b> routine-level <code>lean_ref</code> dispositions.</p>
    <div class="filters">
      <input type="search" id="au-text" placeholder="Filter claim, title, statement" value="${esc(AU.text)}" aria-label="Filter audited claims">
      <button class="toggle text" id="au-head" aria-pressed="${AU.headline}">Headline results only (10)</button>
      <button class="toggle text" id="au-delta" aria-pressed="${AU.deltasOnly}">With statement deltas</button>
      <button class="toggle text" id="au-rout" aria-pressed="${AU.routineOnly}">With routine lean_ref (${totalRoutine})</button>
      <button class="btn ghost" id="au-expand">Expand visible</button>
      <button class="btn ghost" id="au-collapse">Collapse all</button>
    </div>
    <div id="au-list"></div>`;

  const host = document.getElementById('au-list');

  async function hydrateClaim(det, c) {
    if (det.dataset.loaded) return;
    det.dataset.loaded = '1';
    const body = det.querySelector('.audit-body');
    const live = q('SELECT * FROM v_formalization WHERE claim_id = ?', [c.id])[0];
    const sel = M.attempts.find(a => a.claim_id === c.id && a.selected && a.status === 'proved');
    const [stmtSrc, proofSrc] = await Promise.all([
      live ? loadLean(live.lean_file).catch(() => '') : Promise.resolve(''),
      sel ? loadLean(sel.lean_file).catch(() => '') : Promise.resolve(''),
    ]);
    const stmtDecl = live && stmtSrc ? currentDeclaration(stmtSrc, live.lean_decl) : '';
    const deltas = live ? deltaList(live.id) : '';
    const routine = routineDispositionsHtml(c.id, true);
    body.innerHTML = `
      <div class="audit-stmt">
        <div>
          <p class="small muted" style="margin-bottom:4px"><b>Paper statement</b> · ${paperLink(c.source, c.line_start, c.line_end)} · <a href="${claimHref(c.id, 'lean')}">Open claim view</a></p>
          <p>${prose(c.statement)}</p>
          ${deltas || '<p class="small muted">No statement differences recorded.</p>'}
        </div>
        <div>
          <p class="small muted" style="margin-bottom:4px"><b>Frozen Lean statement</b> · ${live ? leanLink(live.lean_file) : ''}</p>
          ${stmtDecl ? leanHtml(stmtDecl) : '<p class="small muted">Could not load statement source.</p>'}
        </div>
      </div>
      ${routine}
      ${sel ? `<p class="small muted" style="margin:12px 0 4px"><b>Mirrored proof</b> <code>${esc(sel.proof_id)}</code> ↔ ${leanLink(sel.lean_file)}</p>${stepSignatureRowsHtml(sel.proof_id, sel.id, proofSrc)}` : ''}`;
  }

  function render() {
    const query = AU.text.trim().toLowerCase();
    const rows = proved.filter(c => {
      if (AU.headline && !c.headline) return false;
      const deltas = M.deltas.filter(d => d.formalization_id === c.formalization);
      if (AU.deltasOnly && !deltas.length) return false;
      const rout = M.disp.filter(d => d.claim_id === c.id && d.decision === 'lean_supplies' && d.lean_ref);
      if (AU.routineOnly && !rout.length) return false;
      if (query && !`${c.id} ${c.title} ${c.statement}`.toLowerCase().includes(query)) return false;
      return true;
    });
    if (!rows.length) {
      host.innerHTML = '<p class="empty">No proved claims match the current filters.</p>';
      return;
    }
    host.innerHTML = rows.map(c => {
      const deltas = M.deltas.filter(d => d.formalization_id === c.formalization);
      const narrow = deltas.filter(d => d.kind === 'extra_hypothesis' || d.kind === 'restricted').length;
      const rout = M.disp.filter(d => d.claim_id === c.id && d.decision === 'lean_supplies' && d.lean_ref).length;
      const open = focusClaim === c.id;
      return `<details class="card audit-claim" data-id="${esc(c.id)}"${open ? ' open' : ''}>
        <summary>
          <span class="idlink">${esc(c.id)}</span> <b>${esc(c.title)}</b>
          ${statusChip(c, false)}
          <span class="tag">${esc(c.n_steps || 0)} steps${c.n_supplied ? ` (${c.n_supplied} supplied)` : ''}</span>
          ${deltas.length ? `<span class="tag${narrow ? ' restricted' : ''}">${plural(deltas.length, 'delta')}${narrow ? ` · ${narrow} narrower` : ''}</span>` : ''}
          ${rout ? `<span class="tag">${plural(rout, 'routine ref')}</span>` : ''}
        </summary>
        <div class="audit-body"><p class="small muted">Loading statement and step signatures…</p></div>
      </details>`;
    }).join('');
    host.querySelectorAll('details.audit-claim').forEach(det => {
      const c = M.byId.get(det.dataset.id);
      det.addEventListener('toggle', () => { if (det.open) hydrateClaim(det, c); });
      if (det.open) hydrateClaim(det, c);
    });
  }

  render();
  document.getElementById('au-text').oninput = e => { AU.text = e.target.value; render(); };
  document.getElementById('au-head').onclick = () => { AU.headline = !AU.headline; viewAudit(); };
  document.getElementById('au-delta').onclick = () => { AU.deltasOnly = !AU.deltasOnly; viewAudit(); };
  document.getElementById('au-rout').onclick = () => { AU.routineOnly = !AU.routineOnly; viewAudit(); };
  document.getElementById('au-expand').onclick = () => {
    host.querySelectorAll('details.audit-claim').forEach(det => { det.open = true; });
  };
  document.getElementById('au-collapse').onclick = () => {
    host.querySelectorAll('details.audit-claim').forEach(det => { det.open = false; });
  };
}

/* ----------------------------------------------------------- claim detail */
/* ---------------------------------------------------------------- routing */
function route() {
  const landing = PUBLIC_PROOFS ? 'claims' : 'overview';
  const [path, query] = (location.hash.replace(/^#\/?/, '') || landing).split('?');
  const [view, ...rest] = path.split('/');
  if (PUBLIC_PROOFS && !['claim', 'claims', 'graph'].includes(view)) {
    history.replaceState(null, '', '#/claims');
    return route();
  }
  if (['edits', 'findings', 'sql'].includes(view)) {
    history.replaceState(null, '', '#/results');
    return route();
  }
  const arg = decodeURIComponent(rest.join('/'));
  const params = new URLSearchParams(query || '');
  const nav = view === 'claim' ? 'claims' : view;
  document.querySelectorAll('#nav a').forEach(a => a.classList.toggle('on', a.dataset.view === nav));
  tip.hidden = true;
  ({ overview: viewOverview, results: viewResults, audit: () => viewAudit(arg), graph: () => viewGraph(arg),
     claims: () => viewClaims(params), claim: () => viewClaim(arg, params.get('view')) }[view] || viewOverview)();
  if (!arg || view === 'claim' || view === 'graph') window.scrollTo(0, 0);
}

function header() {
  if (PUBLIC_PROOFS) {
    document.getElementById('buildmeta').textContent = `${M.claims.length} claims in the manuscript and appendix`;
    return;
  }
  const src = Object.values(M.sources)[0];
  const parts = [`Ledger: ${M.claims.length} claims, ${M.lean.length} in Lean scope`];
  if (src && src.git_commit) parts.push(`aligned to the paper at commit <a href="https://github.com/${repo()}/commit/${src.git_commit}">${src.git_commit.slice(0, 7)}</a>`);
  if (info && info.commit) parts.push(`site built from <a href="https://github.com/${repo()}/commit/${info.commit}">${info.commit.slice(0, 7)}</a>${info.generated ? ' on ' + esc(info.generated.slice(0, 10)) : ''}`);
  document.getElementById('buildmeta').innerHTML = parts.join(' · ');
}

/* --------------------------------------------------------------- tooltips */
function bindTips() {
  const show = e => {
    const el = e.target.closest && e.target.closest('[data-tip]');
    if (!el) { tip.hidden = true; return; }
    tip.innerHTML = (el.dataset.tipTitle ? `<b>${esc(el.dataset.tipTitle)}</b>` : '') + esc(el.dataset.tip);
    tip.hidden = false;
    const r = tip.getBoundingClientRect();
    const x = Math.min(e.clientX + 14, window.innerWidth - r.width - 8);
    const y = e.clientY + 18 + r.height > window.innerHeight ? e.clientY - r.height - 10 : e.clientY + 18;
    tip.style.left = `${Math.max(8, x)}px`; tip.style.top = `${Math.max(8, y)}px`;
  };
  document.addEventListener('mousemove', show);
  document.addEventListener('focusin', e => {
    const el = e.target.closest && e.target.closest('[data-tip]');
    if (!el) return;
    const r = el.getBoundingClientRect();
    show({ target: el, clientX: r.left, clientY: r.bottom });
  });
  document.addEventListener('focusout', () => { tip.hidden = true; });
  document.addEventListener('click', e => {
    const b = e.target.closest('[data-filter]');
    if (b) location.hash = `#/claims?key=${b.dataset.filter}`;
  });
}

/* ------------------------------------------------------------------- boot */
async function boot() {
  try {
    const text = p => fetch(`${LEAN_ROOT}/${p}`, { cache: 'no-cache' }).then(r => {
      if (!r.ok) throw new Error(`could not load ${p} (HTTP ${r.status})`);
      return r.text();
    });
    const [sql, schema, data, build] = await Promise.all([
      window.initSqlJs({ locateFile: f => new URL('vendor/' + f, ASSETS).href }),
      text('ledger/schema.sql'), text('ledger/data.sql'),
      fetch(new URL('build-info.json', ASSETS), { cache: 'no-cache' }).then(r => (r.ok ? r.json() : null)).catch(() => null),
    ]);
    info = build;
    db = new sql.Database();
    db.exec(schema); db.exec(data);
    buildModel(); header(); bindTips();
    window.addEventListener('hashchange', route);
    route();
  } catch (e) {
    main.innerHTML = `<div class="error"><b>The ledger could not be loaded.</b> ${esc(e.message)}
      <p class="small muted" style="margin:8px 0 0">The page fetches <code>../ledger/schema.sql</code> and <code>../ledger/data.sql</code>, so it has to be
      served over HTTP. Locally: <code>python3 tools/ledger.py serve</code> from the <code>lean/</code> directory.</p></div>`;
    console.error(e);
  }
}
boot();
