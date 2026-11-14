/* Proof-progress explorer for the arXiv v2 Lean formalization.
 *
 * Loads ../ledger/schema.sql and ../ledger/data.sql into SQLite (sql.js) and
 * renders every view from SQL queries. There is no generated data file: the
 * page always shows the ledger as committed. build-info.json (written by
 * `ledger.py site` and served live by `ledger.py serve`) is optional and adds
 * the commit, the build date and the result of `ledger.py check`.
 */
'use strict';

const LEAN_ROOT = '..';
const DEFAULT_REPO = 'ANRGUSC/TINA';
const DEFAULT_LEAN_DIR = 'papers/arxiv-v2/lean';

let SQL, db, consoleDb, info = null, M = null;
const main = document.getElementById('main');
const tip = document.getElementById('tip');

/* ------------------------------------------------------------------ utils */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const plural = (n, one, many) => `${n} ${n === 1 ? one : (many || one + 's')}`;
const idKey = id => {
  const m = /^([A-Z])(\d+)(?:\.([a-z]))?/.exec(id) || [];
  return [m[1] || '', +(m[2] || 0), m[3] || ''];
};
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
// Eight keys in five colour groups. Every use pairs the colour with an icon
// and a text label, so status never depends on colour alone.
const KEYS = {
  verified: { group: 'verified', label: 'Verified in Lean', glyph: '✓', c: '--st-verified',
    help: 'The Lean proof is complete, the statement is frozen, and the proof mirrors the proof in the paper step for step.' },
  p4: { group: 'progress', label: 'Proved, audit pending', glyph: '▸', c: '--st-p4',
    help: 'A Lean proof exists but the statement is not frozen or the step audit is not done.' },
  p3: { group: 'progress', label: 'Proof under way', glyph: '▸', c: '--st-p3',
    help: 'A Lean proof attempt is planned or active.' },
  p2: { group: 'progress', label: 'Statement approved', glyph: '▸', c: '--st-p2',
    help: 'The Lean statement has been reviewed or frozen. No proof attempt yet.' },
  p1: { group: 'progress', label: 'Statement drafted', glyph: '▸', c: '--st-p1',
    help: 'A draft Lean statement exists and awaits review against the paper.' },
  todo: { group: 'todo', label: 'Not started', glyph: '', c: '--st-todo',
    help: 'Nothing in Lean yet.' },
  blocked: { group: 'blocked', label: 'Needs paper or Lean change', glyph: '!', c: '--st-blocked',
    help: 'Cannot be verified as things stand: the paper has no proof to mirror, a paper edit is pending, a Lean attempt failed, or a finding of medium or higher severity is open.' },
  out: { group: 'out', label: 'Outside Lean scope', glyph: '–', c: '--st-out',
    help: 'Numeric or prose claim. Tracked in the ledger, not proved in Lean.' },
};
const KEY_ORDER = ['verified', 'p4', 'p3', 'p2', 'p1', 'todo', 'blocked', 'out'];
const SEV = { minor: 1, medium: 2, major: 3, critical: 4 };
const SEV_COLOR = { minor: '--sev-minor', medium: '--sev-medium', major: '--sev-major', critical: '--sev-major' };
const TIERS = {
  A: 'Real analysis and algebra',
  B: 'Finite-dimensional probability: L², conditional expectation, independence',
  C: 'L² projection onto a closed subspace',
  D: 'Gaussian processes and the continuum model',
};

function classify(c) {
  const open = M.findings.filter(f => f.claim_id === c.id && f.status === 'open');
  c.open = open;
  c.minor = open.filter(f => SEV[f.severity] < 2);
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
  } else if (needsProof && !c.paper_proof) {
    c.reasons.push(M.proposed.has(c.id)
      ? { short: 'paper edit pending', text: 'A proof is proposed, but the edit that puts it in the paper has not been applied.' }
      : { short: 'no proof in paper', text: 'The paper asserts this without a proof. An English proof has to be added through a tracked paper edit before Lean can mirror it.' });
  }
  for (const f of open) {
    if (SEV[f.severity] >= 2) c.reasons.push({ short: `${f.severity} finding ${f.id}`, text: `Open ${f.severity} finding ${f.id}: ${f.title}` });
  }
  if (attempts.some(a => a.status === 'failed') && !attempts.some(a => ['planned', 'active', 'proved'].includes(a.status))) {
    c.reasons.push({ short: 'Lean attempt failed', text: 'The last Lean attempt failed and no new attempt is open.' });
  }
  if (c.reasons.length) { c.key = 'blocked'; c.detail = c.reasons[0].short; return; }
  if (c.state === 'verified') c.key = 'verified';
  else if (c.state === 'proved_unaudited') c.key = 'p4';
  else if (c.state === 'proving') { c.key = 'p3'; if (c.n_steps) c.detail = `${c.n_steps_proved}/${c.n_steps} steps`; }
  else if (c.state === 'stated') { c.key = c.stmt_status === 'draft' ? 'p1' : 'p2'; if (c.key === 'p2') c.detail = c.stmt_status; }
  else c.key = 'todo';
}

function buildModel() {
  M = {};
  M.meta = Object.fromEntries(q('SELECT key, value FROM meta').map(r => [r.key, r.value]));
  M.sources = Object.fromEntries(q('SELECT * FROM sources').map(r => [r.id, r]));
  M.findings = q('SELECT * FROM findings');
  M.edits = q('SELECT * FROM edits');
  M.attempts = q('SELECT a.*, f.claim_id FROM attempts a JOIN formalizations f ON f.id = a.formalization_id');
  M.proposed = new Set(q("SELECT DISTINCT claim_id FROM proofs WHERE status = 'proposed'").map(r => r.claim_id));
  M.deps = q('SELECT * FROM claim_deps');
  M.claims = q(`SELECT s.*, c.parent, c.statement, c.source, c.label, c.line_start, c.line_end, c.notes
                FROM v_claim_status s JOIN claims c ON c.id = s.id`).sort((a, b) => idCmp(a.id, b.id));
  M.byId = new Map(M.claims.map(c => [c.id, c]));
  M.claims.forEach(classify);
  M.findingIds = new Set(M.findings.map(f => f.id));
  M.editIds = new Set(M.edits.map(e => e.id));
  M.lean = M.claims.filter(c => c.scope === 'lean');
}

/* ------------------------------------------------------- shared fragments */
const icon = key => `<span class="ico ${key}" style="--c:var(${KEYS[key].c})" aria-hidden="true">${KEYS[key].glyph}</span>`;
function statusChip(c, long) {
  const k = KEYS[c.key];
  const extra = c.detail && long !== false ? ` · ${esc(c.detail)}` : '';
  return `<span class="chip" data-tip="${esc(k.help)}">${icon(c.key)}${esc(k.label)}${extra}</span>`;
}
function minorBadge(c) {
  return c.minor.length
    ? `<span class="badge" data-tip="${esc(c.minor.map(f => `${f.id}: ${f.title}`).join(' | '))}"><span class="dot" style="--c:var(--sev-minor)"></span>${plural(c.minor.length, 'minor finding')}</span>`
    : '';
}
const sevBadge = f => `<span class="badge"><span class="dot" style="--c:var(${SEV_COLOR[f.severity]})"></span>${esc(f.severity)}</span>`;
const claimLink = (id, withTitle) => {
  const c = M.byId.get(id);
  if (!c) return `<span class="idlink">${esc(id)}</span>`;
  return `<a class="idlink" href="#/claim/${encodeURIComponent(id)}" data-tip-title="${esc(id)}: ${esc(c.title)}" data-tip="${esc(KEYS[c.key].label)}${c.detail ? ' · ' + esc(c.detail) : ''}">${esc(id)}</a>${withTitle ? ' ' + esc(c.title) : ''}`;
};
// Turn ledger ids inside already-escaped text into links.
function linkIds(html) {
  return html.replace(/\b(C\d+(?:\.[a-z])?)((?:\/[pfa]\d+(?:\/s\w+)?)?)|\b([FE]\d+)\b/g, (m, cid, rest, other) => {
    if (cid) return M.byId.has(cid) ? `<a class="idlink" href="#/claim/${encodeURIComponent(cid)}">${m}</a>` : m;
    if (M.findingIds.has(other)) return `<a class="idlink" href="#/findings/${other}">${other}</a>`;
    if (M.editIds.has(other)) return `<a class="idlink" href="#/edits/${other}">${other}</a>`;
    return m;
  });
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
function notesList(rows) {
  return `<ul class="notes">${rows.map(n =>
    `<li><time>${esc(n.ts.replace('T', ' ').slice(0, 16))}</time><span class="tag">${esc(n.kind)}</span> ${linkIds(esc(n.target))}<br>${prose(n.body)}</li>`).join('')}</ul>`;
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
function lineDiff(a, b) {
  const A = a.split('\n'), B = b.split('\n');
  const n = A.length, m = B.length;
  const L = Array.from({ length: n + 1 }, () => new Uint16Array(m + 1));
  for (let i = n - 1; i >= 0; i--) for (let j = m - 1; j >= 0; j--) {
    L[i][j] = A[i] === B[j] ? L[i + 1][j + 1] + 1 : Math.max(L[i + 1][j], L[i][j + 1]);
  }
  const out = [];
  let i = 0, j = 0;
  while (i < n || j < m) {
    if (i < n && j < m && A[i] === B[j]) { out.push(['', A[i]]); i++; j++; }
    else if (j < m && (i === n || L[i][j + 1] >= L[i + 1][j])) out.push(['add', B[j++]]);
    else out.push(['del', A[i++]]);
  }
  return out.map(([k, t]) => `<div class="${k}">${k === 'add' ? '+ ' : k === 'del' ? '− ' : '  '}${esc(t)}</div>`).join('');
}

/* --------------------------------------------------------------- overview */
function viewOverview() {
  const lean = M.lean;
  const n = k => lean.filter(c => c.key === k).length;
  const stmt = q(`SELECT status, COUNT(*) n FROM v_formalization GROUP BY status`);
  const stmtN = s => (stmt.find(r => r.status === s) || { n: 0 }).n;
  const stmtTotal = stmt.reduce((s, r) => s + r.n, 0);
  const steps = q(`SELECT COUNT(*) n FROM steps s JOIN proofs p ON p.id = s.proof_id
                   WHERE p.status IN ('in_paper','proposed') AND p.is_primary = 1`)[0].n;
  const stepsProved = q(`SELECT COUNT(DISTINCT m.step_id) n FROM step_map m JOIN attempts a ON a.id = m.attempt_id
                         WHERE m.status = 'proved' AND a.status NOT IN ('superseded','abandoned','failed')`)[0].n;
  const nProofs = q(`SELECT COUNT(*) n FROM proofs WHERE status IN ('in_paper','proposed') AND is_primary = 1`)[0].n;
  const open = M.findings.filter(f => f.status === 'open');
  const sevCount = Object.entries(open.reduce((o, f) => (o[f.severity] = (o[f.severity] || 0) + 1, o), {}))
    .sort((a, b) => SEV[b[0]] - SEV[a[0]]).map(([s, c]) => `${c} ${s}`).join(', ');
  const blocked = lean.filter(c => c.key === 'blocked');
  const noProof = blocked.filter(c => c.reasons.some(r => r.short === 'no proof in paper')).length;
  const pendingEdits = M.edits.filter(e => ['proposed', 'approved'].includes(e.status)).length;
  const frontier = q('SELECT id, title FROM v_frontier ORDER BY tier, id').sort((a, b) => idCmp(a.id, b.id));
  const todos = q("SELECT * FROM notes WHERE kind = 'todo' ORDER BY id DESC");
  const notes = q('SELECT * FROM notes ORDER BY id DESC LIMIT 8');

  const tile = (k, v, d) => `<div class="card tile"><div class="k">${k}</div><div class="v">${v}</div><div class="d">${d}</div></div>`;
  const counts = countKeys(M.claims);
  const legend = KEY_ORDER.filter(k => counts[k] || k === 'verified').map(k =>
    `<button class="item" data-filter="${k}" data-tip="${esc(KEYS[k].help)}">${icon(k)}<span>${esc(KEYS[k].label)}</span> <b>${counts[k] || 0}</b></button>`).join('');

  const next = [];
  if (stmtN('draft')) next.push(`Review ${plural(stmtN('draft'), 'draft Lean statement')} against the paper and freeze the ones that are right. Proofs start from frozen statements. <a href="#/claims?key=p1">Show them</a>`);
  if (noProof) next.push(`Write English proofs for ${plural(noProof, 'claim')} the paper asserts without proof, as tracked paper edits. <a href="#/claims?key=blocked">Show them</a>`);
  if (frontier.length) next.push(`Ready to prove now (own statement and all dependencies frozen): ${frontier.map(f => claimLink(f.id)).join(', ')}.`);
  else next.push('No claim is ready to prove yet: a claim enters the frontier when its own Lean statement and the statements of everything it depends on are frozen.');
  if (pendingEdits) next.push(`${plural(pendingEdits, 'paper edit')} awaiting approval or application. <a href="#/edits">Show them</a>`);
  if (open.length) next.push(`Resolve ${plural(open.length, 'open finding')} (${sevCount}). <a href="#/findings">Show them</a>`);
  todos.forEach(t => next.push(`${linkIds(esc(t.target))}: ${prose(t.body)}`));

  const tiers = Object.keys(TIERS).map(t => {
    const list = lean.filter(c => c.tier === t);
    return `<tr><td><b>${t}</b></td><td>${esc(TIERS[t])}</td><td style="min-width:180px">${stackBar(countKeys(list), 'thin')}</td>
      <td class="num">${list.filter(c => c.key === 'verified').length} / ${list.length}</td>
      <td>${list.map(c => `<a class="idlink" href="#/claim/${encodeURIComponent(c.id)}" data-tip-title="${esc(c.id)}: ${esc(c.title)}" data-tip="${esc(KEYS[c.key].label)}${c.detail ? ' · ' + esc(c.detail) : ''}">${icon(c.key)}</a>`).join(' ')}</td></tr>`;
  }).join('');

  main.innerHTML = `
    ${checkAlert()}
    <div class="tiles">
      ${tile('Verified in Lean', `${n('verified')} <small>/ ${lean.length}</small>`, 'Lean-scope claims whose Lean proof mirrors the proof in the paper step for step')}
      ${tile('Lean statements written', `${stmtTotal} <small>/ ${lean.length}</small>`, `${stmtN('frozen')} frozen, ${stmtN('reviewed')} reviewed, ${stmtN('draft')} draft`)}
      ${tile('Proof steps proved in Lean', `${stepsProved} <small>/ ${steps}</small>`, `${steps} steps across ${plural(nProofs, 'English proof')}; one Lean lemma per step`)}
      ${tile('Need a paper or Lean change', `${blocked.length}`, `${noProof} lack a proof in the paper${pendingEdits ? `, ${plural(pendingEdits, 'edit')} pending` : ''}`)}
      ${tile('Open findings', `${open.length}`, sevCount || 'none')}
    </div>
    <h2>All ${M.claims.length} claims by status</h2>
    <div class="card">${stackBar(counts)}<div class="legend">${legend}</div></div>
    <h2>By tier</h2>
    <div class="tbl-wrap"><table>
      <thead><tr><th>Tier</th><th>Needs</th><th>Status</th><th class="num">Verified</th><th>Claims</th></tr></thead>
      <tbody>${tiers}</tbody></table></div>
    <div class="grid cols-2">
      <section><h2>What is next</h2><div class="card"><ul class="todo-list">${next.map(x => `<li>${x}</li>`).join('')}</ul></div></section>
      <section><h2>Recent ledger notes</h2><div class="card">${notes.length ? notesList(notes) : '<p class="muted">No notes yet.</p>'}</div></section>
    </div>
    <h2>How to read this page</h2>
    <div class="card">
      <p><b>The rule being tracked.</b> Each step of each proof in the paper corresponds to exactly one Lean lemma, in the same
      order, with the same dependencies. If Lean cannot follow the paper, the paper's proof is revised through a tracked edit and
      Lean mirrors the revision. A claim counts as verified only when the proof Lean mirrors is the one in the paper.</p>
      <p><b>Colours.</b> ${KEY_ORDER.map(k => `${icon(k)} ${esc(KEYS[k].label)}`).join(' &nbsp; ')}.
      Blue darkens as a claim moves from a drafted statement to a finished proof. A small yellow square marks a minor open
      finding, which does not turn a claim red.</p>
      <p class="muted small">Paper: <code>${esc(M.meta.paper || '')}</code>. Toolchain: ${esc(M.meta.toolchain || '')}</p>
    </div>`;
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
    <p>${statusChip(c)} ${minorBadge(c)}</p>
    ${c.reasons.length ? `<ul class="reasons small">${c.reasons.map(r => `<li>${prose(r.text)}</li>`).join('')}</ul>` : ''}
    <p class="small">${esc(c.statement)}</p>
    <dl><dt>Kind</dt><dd>${esc(c.kind)}${c.tier ? `, tier ${c.tier}` : ''}</dd>
      <dt>Rests on</dt><dd>${list([...lay.parents.get(c.id)])}</dd>
      <dt>Used by</dt><dd>${list([...lay.children.get(c.id)])}</dd></dl>
    <a class="btn" href="#/claim/${encodeURIComponent(c.id)}">Open claim</a>`;
  document.getElementById('g-close').onclick = () => { G.sel = null; drawGraph(false); };
}

/* ----------------------------------------------------------------- claims */
const F = { keys: new Set(), tier: '', text: '', sort: 'id', dir: 1 };
function viewClaims(params) {
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
      steps: (a, b) => (b.n_steps || 0) - (a.n_steps || 0), findings: (a, b) => b.open.length - a.open.length,
    };
    rows.sort((a, b) => F.dir * sorters[F.sort](a, b) || idCmp(a.id, b.id));
    const th = (k, label, cls) => `<th class="sortable ${cls || ''}" data-sort="${k}" aria-sort="${F.sort === k ? (F.dir > 0 ? 'ascending' : 'descending') : 'none'}">${label}${F.sort === k ? (F.dir > 0 ? ' ▲' : ' ▼') : ''}</th>`;
    document.getElementById('ctable').innerHTML = `<thead><tr>${th('id', 'Claim')}${th('title', 'Title')}${th('kind', 'Kind')}${th('tier', 'Tier')}${th('status', 'Status')}<th>Paper proof</th><th>Lean statement</th>${th('steps', 'Lean steps')}${th('findings', 'Findings')}</tr></thead>
      <tbody>${rows.map(c => `<tr class="click" data-id="${esc(c.id)}">
        <td><a class="idlink" href="#/claim/${encodeURIComponent(c.id)}">${esc(c.id)}</a></td>
        <td>${esc(c.title)}</td><td>${esc(c.kind)}</td><td>${c.tier || ''}</td>
        <td>${statusChip(c)}</td>
        <td class="nowrap">${c.scope !== 'lean' ? '' : c.paper_proof ? `<span class="idlink">${esc(c.paper_proof)}</span>` : ['definition', 'assumption'].includes(c.kind) ? '<span class="muted">not needed</span>' : 'none'}</td>
        <td>${c.stmt_status ? esc(c.stmt_status) : ''}</td>
        <td class="nowrap">${c.n_steps ? `<span class="meter"><i style="width:${100 * c.n_steps_proved / c.n_steps}%"></i></span>${c.n_steps_proved}/${c.n_steps}` : ''}</td>
        <td class="nowrap">${c.open.map(f => `<span class="badge" data-tip="${esc(f.title)}"><span class="dot" style="--c:var(${SEV_COLOR[f.severity]})"></span>${esc(f.id)}</span>`).join(' ')}</td>
      </tr>`).join('') || `<tr><td colspan="9" class="muted">No claims match.</td></tr>`}</tbody>`;
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

/* ----------------------------------------------------------- claim detail */
const STEP_COLOR = { proved: '--st-verified', sorry: '--st-p2', todo: '--st-todo', failed: '--st-blocked' };
function findingCard(f) {
  return `<div class="card finding" id="${esc(f.id)}" style="--c:var(${f.status === 'open' ? SEV_COLOR[f.severity] : '--st-out'})">
    <div class="row"><span class="idlink"><b>${esc(f.id)}</b></span>${sevBadge(f)}<span class="tag">${esc(f.status)}</span>
      <span class="small muted">on ${claimLink(f.claim_id, true)}${f.step_id ? `, step <span class="idlink">${esc(f.step_id)}</span>` : ''} · ${esc((f.created || '').slice(0, 10))}</span></div>
    <h3>${esc(f.title)}</h3><p>${prose(f.body)}</p>
    ${f.resolution ? `<p><b>Resolution:</b> ${prose(f.resolution)}</p>` : ''}</div>`;
}
function editCard(e) {
  const hunks = q('SELECT h.*, s.path FROM hunks h JOIN sources s ON s.id = h.source WHERE edit_id = ? ORDER BY ordinal', [e.id]);
  return `<div class="card" id="${esc(e.id)}">
    <div class="claim-head"><b class="idlink">${esc(e.id)}</b><span class="tag">${esc(e.status)}</span><span class="tag">${esc(e.target)}</span>
      <span class="small muted">on ${claimLink(e.claim_id, true)}${e.from_proof || e.to_proof ? ` · ${esc(e.from_proof || 'no proof')} → ${esc(e.to_proof || '')}` : ''}${e.applied_commit ? ` · applied in ${esc(e.applied_commit.slice(0, 7))}` : ''}</span></div>
    <p style="margin-top:6px">${prose(e.reason)}</p>
    ${hunks.map(h => {
      const touched = q('SELECT step_id, effect FROM hunk_steps WHERE hunk_id = ?', [h.id]).map(t => `${t.effect} ${t.step_id}`).join('; ');
      return `<div class="diff"><div class="hd">${esc(h.id)} · ${esc(h.path)}${touched ? ' · ' + esc(touched) : ''}${!h.old_tex && h.anchor ? ' · inserted after: ' + esc(h.anchor.replace(/\s+/g, ' ').slice(0, 90)) : ''}</div>${lineDiff(h.old_tex || '', h.new_tex || '')}</div>`;
    }).join('') || '<p class="muted small">No hunks recorded.</p>'}</div>`;
}

function viewClaim(id) {
  const c = M.byId.get(id);
  if (!c) { main.innerHTML = `<p class="empty">No claim with id ${esc(id)}. <a href="#/claims">All claims</a></p>`; return; }
  const k = KEYS[c.key];
  const lean = c.scope === 'lean';
  const needsProof = !['definition', 'assumption'].includes(c.kind);
  const proofs = q(`SELECT * FROM proofs WHERE claim_id = ? ORDER BY (status = 'in_paper') DESC, is_primary DESC, version DESC`, [id]);
  const forms = q('SELECT * FROM formalizations WHERE claim_id = ? ORDER BY version DESC', [id]);
  const attempts = M.attempts.filter(a => a.claim_id === id);
  const edits = M.edits.filter(e => e.claim_id === id);
  const findings = M.findings.filter(f => f.claim_id === id);
  const notes = q('SELECT * FROM notes WHERE target = ? OR target LIKE ? ORDER BY id DESC', [id, id + '/%']);
  const dependsOn = M.deps.filter(d => d.claim_id === id), usedBy = M.deps.filter(d => d.depends_on === id);
  const subs = M.claims.filter(x => x.parent === id);
  const ordered = M.claims.map(x => x.id), at = ordered.indexOf(id);

  // Pipeline: paper proof -> Lean statement -> Lean proof -> verified.
  const stage = (label, v, d, color, glyph) => `<div class="stage" style="--c:var(${color})"><div class="k">${label}</div>
    <div class="v"><span class="ico" style="--c:var(${color})">${glyph}</span>${v}</div><div class="d">${d}</div></div>`;
  const live = forms.find(f => f.status !== 'superseded');
  const sel = attempts.find(a => a.selected) || attempts.find(a => ['active', 'planned'].includes(a.status)) || attempts[attempts.length - 1];
  const pipeline = !lean ? '' : `<div class="pipeline">
    ${!needsProof ? stage('1 · Paper proof', 'Not needed', `A ${esc(c.kind)} has nothing to prove`, '--st-out', '–')
      : c.paper_proof ? stage('1 · Paper proof', 'In the paper', `${esc(c.paper_proof)}, ${plural(q('SELECT COUNT(*) n FROM steps WHERE proof_id = ?', [c.paper_proof])[0].n, 'step')}`, '--st-verified', '✓')
      : M.proposed.has(id) ? stage('1 · Paper proof', 'Proposed', 'Edit not applied to the paper yet', '--st-blocked', '!')
      : stage('1 · Paper proof', 'Missing', 'Asserted without proof; needs a paper edit', '--st-blocked', '!')}
    ${!live ? stage('2 · Lean statement', 'Not written', '', '--st-todo', '')
      : live.status === 'frozen' ? stage('2 · Lean statement', 'Frozen', esc(live.id), '--st-verified', '✓')
      : stage('2 · Lean statement', live.status === 'draft' ? 'Draft' : 'Reviewed', `${esc(live.id)}, ${live.status === 'draft' ? 'awaiting review against the paper' : 'not frozen yet'}`, live.status === 'draft' ? '--st-p1' : '--st-p2', '▸')}
    ${!sel ? stage('3 · Lean proof', 'No attempt', live && live.status !== 'frozen' ? 'Starts once the statement is frozen' : '', '--st-todo', '')
      : sel.status === 'proved' ? stage('3 · Lean proof', 'Proved', `${esc(sel.id)}${c.n_steps ? `, ${c.n_steps_proved}/${c.n_steps} steps` : ''}`, '--st-verified', '✓')
      : sel.status === 'failed' ? stage('3 · Lean proof', 'Attempt failed', esc(sel.id), '--st-blocked', '!')
      : stage('3 · Lean proof', sel.status === 'active' ? 'Under way' : esc(sel.status), esc(sel.id), '--st-p3', '▸')}
    ${c.state === 'verified' ? stage('4 · Verified 1:1', 'Verified', 'Lean mirrors the proof in the paper', '--st-verified', '✓')
      : c.state === 'needs_paper_edit' ? stage('4 · Verified 1:1', 'Paper edit pending', 'Lean mirrors a proposed proof', '--st-blocked', '!')
      : stage('4 · Verified 1:1', 'Not yet', '', '--st-todo', '')}
  </div>`;

  const depChips = (rows, key) => rows.length ? `<div class="deps">${rows.sort((a, b) => idCmp(a[key], b[key])).map(d => {
    const x = M.byId.get(d[key]);
    return `<a class="chip" href="#/claim/${encodeURIComponent(d[key])}" data-tip-title="${esc(d[key])}: ${esc(x.title)}" data-tip="${esc(KEYS[x.key].label)}${d.note ? ' · ' + esc(d.note) : ''}">${icon(x.key)}<span class="idlink">${esc(d[key])}</span> <small>${esc(d.kind)}</small></a>`;
  }).join('')}</div>` : '<span class="muted">none</span>';

  const proofHtml = proofs.map(p => {
    const steps = q('SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal', [p.id]);
    const mirrored = attempts.filter(a => a.proof_id === p.id);
    return `<h3><span class="idlink">${esc(p.id)}</span> <span class="tag">${esc(p.status.replace('_', ' '))}</span>
        ${p.is_primary ? '' : '<span class="tag">secondary derivation</span>'}${p.parent ? ` <span class="small muted">revises ${esc(p.parent)}</span>` : ''}</h3>
      <p>${prose(p.summary)}</p>
      <div class="steps-head"><span>Paper, step by step</span><span>Lean lemma for the step</span></div>
      <div class="steps">${steps.map(s => {
        const deps = q('SELECT dep_kind, dep_id FROM step_deps WHERE step_id = ?', [s.id]);
        const maps = q(`SELECT m.* FROM step_map m JOIN attempts a ON a.id = m.attempt_id WHERE m.step_id = ? ORDER BY a.selected DESC, a.created DESC`, [s.id]);
        const top = maps[0];
        return `<div class="step"><div>
            <h4><span class="idlink">s${s.ordinal}</span>${esc(s.title)}</h4>
            ${texHtml(s.tex)}
            <p class="small muted" style="margin:6px 0 0">${paperLink(s.source, s.line_start, s.line_end)}${deps.length ? ` · uses ${deps.map(d => d.dep_kind === 'claim' ? claimLink(d.dep_id) : `<span class="idlink">${esc(d.dep_id.split('/').pop())}</span>`).join(', ')}` : ''}</p>
          </div><div class="lean" style="--c:var(${top ? STEP_COLOR[top.status] : '--line-strong'})">
            ${maps.length ? maps.map(m => `<p><code>${esc(m.lean_decl)}</code><br><span class="tag">${esc(m.status)}</span> <span class="small muted">in ${esc(m.attempt_id)}</span></p>`).join('')
              : `<p class="muted small">No Lean lemma yet.${mirrored.length ? '' : ' No attempt mirrors this proof.'}</p>`}
          </div></div>`;
      }).join('') || '<div class="step"><div class="muted">No steps recorded.</div><div class="lean"></div></div>'}</div>`;
  }).join('');

  main.innerHTML = `
    <p class="crumbs"><a href="#/claims">Claims</a> / ${esc(id)}
      <span style="float:right">${at > 0 ? `<a href="#/claim/${encodeURIComponent(ordered[at - 1])}">← ${esc(ordered[at - 1])}</a>` : ''}
      ${at < ordered.length - 1 ? ` &nbsp; <a href="#/claim/${encodeURIComponent(ordered[at + 1])}">${esc(ordered[at + 1])} →</a>` : ''}</span></p>
    <div class="claim-head">
      <h2><span class="idlink">${esc(id)}</span> ${esc(c.title)}</h2>
      <span class="tag">${esc(c.kind)}</span>${c.tier ? `<span class="tag" data-tip="${esc(TIERS[c.tier])}">tier ${c.tier}</span>` : ''}
    </div>
    <p style="margin-top:8px">${statusChip(c)} ${minorBadge(c)} <span class="small muted">ledger state <code>${esc(c.state)}</code> · <a href="#/graph/${encodeURIComponent(id)}">show in dependency graph</a></span></p>
    ${c.reasons.length ? `<ul class="reasons">${c.reasons.map(r => `<li>${prose(r.text)}</li>`).join('')}</ul>` : ''}
    ${pipeline}
    <h3>What the paper claims</h3>
    <div class="card"><p class="statement">${esc(c.statement)}</p>
      <dl class="kv"><dt>In the paper</dt><dd>${paperLink(c.source, c.line_start, c.line_end) || '<span class="muted">not located</span>'}${c.label ? ` · <code>\\label{${esc(c.label)}}</code>` : ''}</dd>
        ${c.parent ? `<dt>Stated with</dt><dd>${claimLink(c.parent, true)}</dd>` : ''}
        ${subs.length ? `<dt>Sub-claims</dt><dd>${subs.map(s => claimLink(s.id)).join(', ')}</dd>` : ''}
        <dt>Rests on</dt><dd>${depChips(dependsOn, 'depends_on')}</dd>
        <dt>Used by</dt><dd>${depChips(usedBy, 'claim_id')}</dd>
        ${c.notes ? `<dt>Note</dt><dd>${prose(c.notes)}</dd>` : ''}</dl></div>
    ${findings.length ? `<h2>Findings</h2><div class="grid">${findings.map(findingCard).join('')}</div>` : ''}
    ${lean ? `<h2>Lean statement</h2>${forms.length ? forms.map(f => `<div class="card" style="margin-bottom:12px">
        <div class="claim-head"><b class="idlink">${esc(f.id)}</b><span class="tag">${esc(f.status)}</span><code>${esc(f.lean_decl)}</code><span class="small">${leanLink(f.lean_file)}</span></div>
        ${f.fidelity ? `<p style="margin-top:8px"><b>How it maps to the paper's wording.</b> ${prose(f.fidelity)}</p>` : ''}
        <details ${f === live ? 'open' : ''} data-lean="${esc(f.lean_file)}"><summary class="small">Lean source</summary><div class="src muted small">Loading…</div></details>
      </div>`).join('') : '<p class="muted">No Lean statement yet.</p>'}` : ''}
    <h2>English proof${proofs.length > 1 ? 's' : ''}</h2>
    ${proofs.length ? proofHtml : `<p class="muted">${lean && needsProof ? 'The paper gives no proof of this claim. One has to be added through a tracked paper edit.' : 'None recorded.'}</p>`}
    ${attempts.length ? `<h2>Lean proof attempts</h2><div class="tbl-wrap"><table><thead><tr><th>Attempt</th><th>Status</th><th>Mirrors</th><th>Branches from</th><th>Strategy</th><th class="num">Lines</th><th class="num">Build s</th><th>File</th></tr></thead>
      <tbody>${attempts.map(a => `<tr><td class="idlink">${esc(a.id)}${a.selected ? ' ★' : ''}</td><td>${esc(a.status)}</td><td class="idlink">${esc(a.proof_id)}</td><td class="idlink">${esc(a.parent || '')}</td><td>${prose(a.strategy)}</td><td class="num">${a.lean_lines ?? ''}</td><td class="num">${a.build_seconds ?? ''}</td><td>${leanLink(a.lean_file)}</td></tr>`).join('')}</tbody></table></div>
      <p class="small muted">★ is the attempt used in the end-to-end assembly.</p>` : ''}
    ${edits.length ? `<h2>Paper edits</h2><div class="grid">${edits.map(editCard).join('')}</div>` : ''}
    ${notes.length ? `<h2>Ledger notes</h2><div class="card">${notesList(notes)}</div>` : ''}
    <p class="small muted" style="margin-top:18px">Same record on the command line: <code>python3 tools/ledger.py show ${esc(id)}</code></p>`;

  main.querySelectorAll('details[data-lean]').forEach(d => {
    const load = () => {
      if (d.dataset.done) return;
      d.dataset.done = '1';
      loadLean(d.dataset.lean).then(src => { d.querySelector('.src').outerHTML = leanHtml(src); })
        .catch(() => { d.querySelector('.src').textContent = 'Could not load the file from this site. Use the GitHub link above.'; });
    };
    if (d.open) load();
    d.addEventListener('toggle', () => d.open && load());
  });
}

/* ------------------------------------------------------ findings and edits */
function viewFindings(focus) {
  const rows = M.findings.slice().sort((a, b) => (a.status !== 'open') - (b.status !== 'open') || SEV[b.severity] - SEV[a.severity] || idCmp(a.id, b.id));
  const open = rows.filter(f => f.status === 'open').length;
  main.innerHTML = `<h2>Findings</h2>
    <p class="muted">Problems the formalization exposes in the paper: a gap, a missing hypothesis, an unproved assertion, a mismatch
      between statement and proof. ${open} open, ${rows.length - open} closed. Medium and above turn the claim red; minor ones show as a badge.</p>
    <div class="grid">${rows.map(findingCard).join('') || '<p class="empty">No findings recorded.</p>'}</div>`;
  scrollToId(focus);
}
function viewEdits(focus) {
  main.innerHTML = `<h2>Paper edits</h2>
    <p class="muted">Changes to the paper's text that the formalization forced or suggested. Each edit takes a claim from one proof
      version to the next and is stored as diff hunks against the TeX source.</p>
    <div class="grid">${M.edits.map(editCard).join('') || '<p class="empty">No paper edits have been proposed yet.</p>'}</div>`;
  scrollToId(focus);
}
function scrollToId(id) {
  const el = id && document.getElementById(id);
  if (el) { el.scrollIntoView({ block: 'start' }); el.style.outline = '2px solid var(--focus)'; }
}

/* -------------------------------------------------------------------- SQL */
const EXAMPLES = [
  ['Status of every claim', `SELECT id, kind, tier, state, paper_proof, stmt_status, open_findings, title\nFROM v_claim_status\nORDER BY CAST(substr(id, 2) AS REAL), id;`],
  ['Claims with no proof in the paper', `SELECT id, kind, tier, title\nFROM v_claim_status\nWHERE scope = 'lean' AND paper_proof IS NULL\n  AND kind NOT IN ('definition', 'assumption');`],
  ['Ready to prove (frontier)', `SELECT id, tier, state, title FROM v_frontier ORDER BY tier, id;`],
  ['Steps of the C7 proof', `SELECT s.id, s.title, group_concat(d.dep_id, ', ') AS uses\nFROM steps s LEFT JOIN step_deps d ON d.step_id = s.id\nWHERE s.proof_id = 'C7/p1'\nGROUP BY s.id ORDER BY s.ordinal;`],
  ['Open findings', `SELECT id, claim_id, severity, title FROM findings WHERE status = 'open';`],
  ['What rests on C7', `WITH RECURSIVE down(id) AS (\n  SELECT 'C7'\n  UNION SELECT d.claim_id FROM claim_deps d JOIN down ON d.depends_on = down.id\n)\nSELECT s.id, s.state, s.title FROM down JOIN v_claim_status s ON s.id = down.id WHERE s.id != 'C7';`],
  ['Failure notes', `SELECT ts, target, body FROM notes WHERE kind = 'failure' ORDER BY id DESC;`],
];
let lastSql = EXAMPLES[0][1];
function viewSql() {
  const objs = q("SELECT name, type FROM sqlite_master WHERE type IN ('table','view') ORDER BY type, name");
  main.innerHTML = `<h2>Query the ledger</h2>
    <p class="muted">SQLite running in your browser on a private copy of the ledger. Anything you change here is discarded on reload
      and never reaches the repository.</p>
    <div class="sql-layout"><div>
      <div class="examples">${EXAMPLES.map((e, i) => `<button class="toggle text" data-ex="${i}">${esc(e[0])}</button>`).join('')}</div>
      <textarea class="sql" id="sql" spellcheck="false" aria-label="SQL">${esc(lastSql)}</textarea>
      <p style="margin-top:8px"><button class="btn" id="run">Run</button> <button class="btn ghost" id="reset">Reset copy</button>
        <span class="small muted">Ctrl or Cmd + Enter runs the query.</span></p>
      <div id="out"></div>
    </div>
    <aside class="card schema"><h3 style="margin-top:0">Schema</h3>${objs.map(o => `<details><summary>${esc(o.name)}${o.type === 'view' ? ' <span class="tag">view</span>' : ''}</summary>
      <ul>${q(`PRAGMA table_info(${o.name})`).map(col => `<li>${esc(col.name)} <span class="muted">${esc((col.type || '').toLowerCase())}</span></li>`).join('')}</ul></details>`).join('')}
      <p class="small muted" style="margin-top:8px">Definitions and comments: <a href="${LEAN_ROOT}/ledger/schema.sql">schema.sql</a></p></aside></div>`;
  const ta = document.getElementById('sql'), out = document.getElementById('out');
  const run = () => {
    lastSql = ta.value;
    if (!consoleDb) consoleDb = new SQL.Database(db.export());
    try {
      const t0 = performance.now();
      const res = consoleDb.exec(lastSql);
      const ms = (performance.now() - t0).toFixed(1);
      out.innerHTML = res.length ? res.map(r => `<p class="small muted" style="margin:12px 0 4px">${plural(r.values.length, 'row')} · ${ms} ms</p>
        <div class="tbl-wrap result"><table><thead><tr>${r.columns.map(col => `<th>${esc(col)}</th>`).join('')}</tr></thead>
        <tbody>${r.values.map(v => `<tr>${v.map(x => `<td>${x === null ? '<span class="muted">NULL</span>' : linkIds(esc(x))}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`).join('')
        : `<p class="small muted" style="margin-top:12px">Statement ran, no rows returned · ${ms} ms</p>`;
    } catch (e) {
      out.innerHTML = `<p class="error" style="margin-top:12px">${esc(e.message)}</p>`;
    }
  };
  document.getElementById('run').onclick = run;
  document.getElementById('reset').onclick = () => { if (consoleDb) consoleDb.close(); consoleDb = null; out.innerHTML = '<p class="small muted" style="margin-top:12px">Copy reset to the committed ledger.</p>'; };
  ta.onkeydown = e => { if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') { e.preventDefault(); run(); } };
  main.querySelectorAll('[data-ex]').forEach(b => b.onclick = () => { ta.value = EXAMPLES[+b.dataset.ex][1]; run(); });
  run();
}

/* ---------------------------------------------------------------- routing */
function route() {
  const [path, query] = (location.hash.replace(/^#\/?/, '') || 'overview').split('?');
  const [view, ...rest] = path.split('/');
  const arg = decodeURIComponent(rest.join('/'));
  const params = new URLSearchParams(query || '');
  const nav = view === 'claim' ? 'claims' : view;
  document.querySelectorAll('#nav a').forEach(a => a.classList.toggle('on', a.dataset.view === nav));
  tip.hidden = true;
  ({ overview: viewOverview, graph: () => viewGraph(arg), claims: () => viewClaims(params), claim: () => viewClaim(arg),
     findings: () => viewFindings(arg), edits: () => viewEdits(arg), sql: viewSql }[view] || viewOverview)();
  if (!arg || view === 'claim' || view === 'graph') window.scrollTo(0, 0);
}

function header() {
  const src = Object.values(M.sources)[0];
  const parts = [`Ledger: ${M.claims.length} claims, ${M.lean.length} in Lean scope`];
  if (src && src.git_commit) parts.push(`aligned to the paper at commit <a href="https://github.com/${repo()}/commit/${src.git_commit}">${src.git_commit.slice(0, 7)}</a>`);
  if (info && info.commit) parts.push(`site built from <a href="https://github.com/${repo()}/commit/${info.commit}">${info.commit.slice(0, 7)}</a>${info.generated ? ' on ' + esc(info.generated.slice(0, 10)) : ''}`);
  document.getElementById('buildmeta').innerHTML = parts.join(' · ');
  const openF = M.findings.filter(f => f.status === 'open').length;
  const pend = M.edits.filter(e => ['proposed', 'approved'].includes(e.status)).length;
  const badge = (view, n) => { if (n) document.querySelector(`#nav a[data-view=${view}]`).insertAdjacentHTML('beforeend', `<span class="n">${n}</span>`); };
  badge('findings', openF); badge('edits', pend);
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
      window.initSqlJs({ locateFile: f => `vendor/${f}` }),
      text('ledger/schema.sql'), text('ledger/data.sql'),
      fetch('build-info.json', { cache: 'no-cache' }).then(r => (r.ok ? r.json() : null)).catch(() => null),
    ]);
    SQL = sql; info = build;
    db = new SQL.Database();
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
