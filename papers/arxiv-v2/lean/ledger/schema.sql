-- Proof ledger for the Lean formalization of the arXiv v2 manuscript (tina-v2).
-- Loaded together with data.sql into SQLite by tools/ledger.py.
-- data.sql is the committed source of truth; this file is the schema only.

PRAGMA foreign_keys = ON;

CREATE TABLE meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Paper source files the ledger is aligned to.
CREATE TABLE sources (
  id         TEXT PRIMARY KEY,          -- MAIN, APP
  path       TEXT NOT NULL,             -- repo-relative
  git_commit TEXT,                      -- commit the excerpts were taken from
  sha256     TEXT NOT NULL              -- file hash at that time
);

-- ---------------------------------------------------------------- claims
-- Everything the paper asserts. IDs C1..C27 match the co-author review
-- ledger (submissions/arxiv-v2/alt-review/claim-ledger.md); C7.b etc. are
-- sub-claims that the paper states inside or next to the parent.
CREATE TABLE claims (
  id         TEXT PRIMARY KEY,
  parent     TEXT REFERENCES claims(id),
  kind       TEXT NOT NULL CHECK (kind IN
               ('definition','assumption','lemma','theorem','corollary',
                'proposition','remark','example','implicit','numeric','prose')),
  title      TEXT NOT NULL,
  statement  TEXT NOT NULL,             -- what is claimed, in plain words
  source     TEXT REFERENCES sources(id),
  label      TEXT,                      -- \label in the TeX, if any
  line_start INTEGER,
  line_end   INTEGER,
  scope      TEXT NOT NULL CHECK (scope IN ('lean','numeric','prose')),
  tier       TEXT CHECK (tier IN ('A','B','C','D')),  -- see README
  notes      TEXT,
  headline   INTEGER NOT NULL DEFAULT 0  -- 1 = a result the paper advertises
                                         -- (theorem, proposition, lemma, corollary);
                                         -- listed in v_headline
);

-- claim_id needs depends_on. kind: uses = logical dependency in the paper's
-- argument; setup = definitions/assumptions it is stated in terms of;
-- instantiates = special case of; evidence = numeric/prose resting on it.
CREATE TABLE claim_deps (
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  depends_on TEXT NOT NULL REFERENCES claims(id),
  kind       TEXT NOT NULL CHECK (kind IN ('uses','setup','instantiates','evidence')),
  note       TEXT,
  PRIMARY KEY (claim_id, depends_on)
);

-- --------------------------------------------------------- English proofs
-- A versioned English proof of a claim. Every Lean proof mirrors one of
-- these, step for step. A proof has one of two homes:
--   in_paper    the paper's own proof (at most one primary per claim)
--   supplement  written for the formalization where the paper gives no proof;
--               kept here, not in the paper, and shown as such everywhere
-- 'proposed' is a proof on its way into the paper through an edit.
CREATE TABLE proofs (
  id         TEXT PRIMARY KEY,          -- C7/p1
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  version    INTEGER NOT NULL,
  parent     TEXT REFERENCES proofs(id),  -- proof this one revises
  status     TEXT NOT NULL CHECK (status IN
               ('in_paper','supplement','proposed','superseded','rejected')),
  is_primary INTEGER NOT NULL DEFAULT 1,  -- 0 = secondary derivation/sketch
  summary    TEXT NOT NULL,
  created    TEXT NOT NULL,
  UNIQUE (claim_id, version)
);

-- One step of an English proof. For origin = 'paper', `tex` is the verbatim
-- paper text; `ledger check` requires it to be findable in the source file, so
-- the paper cannot drift without the ledger noticing. origin = 'supplied'
-- marks a step the paper does not contain: every step of a supplement proof,
-- or a step added to an in-paper proof where the paper skips an argument.
-- A supplied step in an in-paper proof needs a disposition that points at it.
CREATE TABLE steps (
  id         TEXT PRIMARY KEY,          -- C7/p1/s3
  proof_id   TEXT NOT NULL REFERENCES proofs(id),
  ordinal    INTEGER NOT NULL,
  title      TEXT NOT NULL,
  tex        TEXT NOT NULL,
  source     TEXT REFERENCES sources(id),
  line_start INTEGER,
  line_end   INTEGER,
  origin     TEXT NOT NULL DEFAULT 'paper' CHECK (origin IN ('paper','supplied')),
  UNIQUE (proof_id, ordinal)
);

-- What a step is allowed to use: earlier steps (dep_kind='step') or other
-- claims (dep_kind='claim'). The Lean lemma for the step may use exactly
-- these plus the Routine library and Mathlib.
CREATE TABLE step_deps (
  step_id  TEXT NOT NULL REFERENCES steps(id),
  dep_kind TEXT NOT NULL CHECK (dep_kind IN ('step','claim')),
  dep_id   TEXT NOT NULL,
  PRIMARY KEY (step_id, dep_kind, dep_id)
);

-- ---------------------------------------------------------------- Lean side
-- A Lean statement of a claim (versioned). Proof attempts target one
-- formalization; downstream proofs take it as a hypothesis.
CREATE TABLE formalizations (
  id         TEXT PRIMARY KEY,          -- C7/f1
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  version    INTEGER NOT NULL,
  parent     TEXT REFERENCES formalizations(id),
  lean_decl  TEXT NOT NULL,             -- TinaV2.C07.Statement
  lean_file  TEXT NOT NULL,
  status     TEXT NOT NULL CHECK (status IN
               ('draft','reviewed','frozen','superseded')),
  fidelity   TEXT,                      -- how it maps to the paper statement
  created    TEXT NOT NULL,
  UNIQUE (claim_id, version)
);

-- A Lean proof attempt. It mirrors exactly one English proof (proof_id).
-- parent = attempt it branches from (retry, simplification).
CREATE TABLE attempts (
  id               TEXT PRIMARY KEY,    -- C7/a1
  formalization_id TEXT NOT NULL REFERENCES formalizations(id),
  proof_id         TEXT NOT NULL REFERENCES proofs(id),
  parent           TEXT REFERENCES attempts(id),
  lean_file        TEXT NOT NULL,
  strategy         TEXT NOT NULL,
  status           TEXT NOT NULL CHECK (status IN
                     ('planned','active','proved','failed','abandoned','superseded')),
  selected         INTEGER NOT NULL DEFAULT 0,  -- the one used in Assembly
  build_seconds    REAL,
  lean_lines       INTEGER,
  created          TEXT NOT NULL,
  updated          TEXT NOT NULL
);

-- What the end-to-end assembly says about a claim's selected attempt.
-- `assumes` is written by `ledger.py assembly`: the claims (comma-separated)
-- that remain hypotheses of the assembled theorem because they are used,
-- directly or through other claims, and not yet proved. `axioms` is written
-- by `ledger.py audit`: what Lean reports the assembled theorem depends on;
-- `standard` = 1 when that is within propext, Classical.choice, Quot.sound.
-- A claim is verified only with assumes = '' and standard = 1.
CREATE TABLE assembled (
  claim_id   TEXT PRIMARY KEY REFERENCES claims(id),
  attempt_id TEXT NOT NULL REFERENCES attempts(id),
  assumes    TEXT NOT NULL DEFAULT '',
  axioms     TEXT,
  standard   INTEGER,
  checked    TEXT
);

-- The 1:1 map: each step of the mirrored English proof <-> one Lean lemma.
CREATE TABLE step_map (
  attempt_id TEXT NOT NULL REFERENCES attempts(id),
  step_id    TEXT NOT NULL REFERENCES steps(id),
  lean_decl  TEXT NOT NULL,
  status     TEXT NOT NULL CHECK (status IN ('todo','sorry','proved','failed')),
  PRIMARY KEY (attempt_id, step_id),
  UNIQUE (attempt_id, lean_decl)
);

-- -------------------------------------------------------------- paper edits
-- A change to the paper's English text. An edit that revises a proof takes
-- the paper from proof `from_proof` to `to_proof`; statement or definition
-- edits leave those NULL. Edits form a graph through edit_deps (an edit that
-- only makes sense after another) and through the proof versions they link.
CREATE TABLE edits (
  id             TEXT PRIMARY KEY,      -- E1
  claim_id       TEXT NOT NULL REFERENCES claims(id),
  target         TEXT NOT NULL CHECK (target IN ('statement','proof','definition','prose')),
  from_proof     TEXT REFERENCES proofs(id),
  to_proof       TEXT REFERENCES proofs(id),
  reason         TEXT NOT NULL,         -- why Lean forced or suggested it
  status         TEXT NOT NULL CHECK (status IN
                   ('proposed','approved','applied','rejected','superseded')),
  applied_commit TEXT,
  created        TEXT NOT NULL
);

CREATE TABLE edit_deps (
  edit_id    TEXT NOT NULL REFERENCES edits(id),
  depends_on TEXT NOT NULL REFERENCES edits(id),
  PRIMARY KEY (edit_id, depends_on)
);

-- One diff hunk of an edit: old_tex is replaced by new_tex in `source`.
-- old_tex must be found verbatim before applying; new_tex after.
CREATE TABLE hunks (
  id       TEXT PRIMARY KEY,            -- E1/h1
  edit_id  TEXT NOT NULL REFERENCES edits(id),
  ordinal  INTEGER NOT NULL,
  source   TEXT NOT NULL REFERENCES sources(id),
  old_tex  TEXT NOT NULL,               -- '' for a pure insertion (use anchor)
  new_tex  TEXT NOT NULL,               -- '' for a pure deletion
  anchor   TEXT,                        -- verbatim text the insertion follows
  UNIQUE (edit_id, ordinal)
);

-- Which proof steps a hunk touches, so every step revision traces to a hunk.
CREATE TABLE hunk_steps (
  hunk_id TEXT NOT NULL REFERENCES hunks(id),
  step_id TEXT NOT NULL REFERENCES steps(id),
  effect  TEXT NOT NULL CHECK (effect IN ('adds','rewrites','removes')),
  PRIMARY KEY (hunk_id, step_id)
);

-- ----------------------------------------------------------------- findings
-- Problems the formalization exposes in the paper (gap, missing hypothesis,
-- unproved assertion, mismatch). Resolved by an edit or a recorded decision.
CREATE TABLE findings (
  id         TEXT PRIMARY KEY,          -- F1
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  step_id    TEXT REFERENCES steps(id),
  severity   TEXT NOT NULL CHECK (severity IN ('critical','major','medium','minor')),
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  status     TEXT NOT NULL CHECK (status IN ('open','resolved','wontfix')),
  resolution TEXT,                      -- edit id or decision text
  created    TEXT NOT NULL
);

-- ------------------------------------------------------------- dispositions
-- What was decided about each point the formalization raised. A point is one
-- numbered item of a finding (id F10.2) or, with no finding, a point on a
-- claim (id C8.c/d1), usually that the paper gives no proof (whole_proof = 1).
--   level     statement: what is claimed, its hypotheses or definitions
--             proof:     a step of an argument
--             wording:   presentation only
--   decision  undecided      waiting for a decision; blocks the claim
--             paper_edit     the paper will change (agreed with the co-author)
--             lean_supplies  the paper stays; Lean proves the step or the claim
--                            from a supplied step, a supplement proof or a
--                            routine lemma (step_id / proof_id / lean_ref)
--             reading        the paper stays; the Lean statement fixes one
--                            reading of the paper's words (see statement_deltas)
--             leave          the paper stays and nothing changes in Lean
--   status    done once carried out: the edit is upstream (resolved_commit),
--             the supplied proof is checked, or the reading is recorded.
CREATE TABLE dispositions (
  id              TEXT PRIMARY KEY,
  claim_id        TEXT NOT NULL REFERENCES claims(id),
  finding_id      TEXT REFERENCES findings(id),
  whole_proof     INTEGER NOT NULL DEFAULT 0,
  point           TEXT NOT NULL,
  level           TEXT NOT NULL CHECK (level IN ('statement','proof','wording')),
  decision        TEXT NOT NULL CHECK (decision IN
                    ('undecided','paper_edit','lean_supplies','reading','leave')),
  decided_by      TEXT,
  decided_on      TEXT,
  rationale       TEXT,
  status          TEXT NOT NULL CHECK (status IN ('open','done')),
  step_id         TEXT REFERENCES steps(id),
  proof_id        TEXT REFERENCES proofs(id),
  lean_ref        TEXT,                 -- Lean file or declaration that supplies it
  edit_id         TEXT REFERENCES edits(id),
  resolved_commit TEXT,
  CHECK (decision != 'undecided' OR status = 'open'),
  CHECK (decision = 'undecided' OR decided_by IS NOT NULL)
);

-- Where a Lean statement differs from the paper's statement, one row per
-- difference. This is what a co-author checks before a statement is frozen.
--   extra_hypothesis  Lean assumes something the paper's statement does not say
--   restricted        Lean states only part of what the paper claims
--   stronger          Lean proves more (a hypothesis dropped, a wider claim)
--   reading           the paper's words allow more than one meaning; Lean fixes one
--   form              same content in another form
CREATE TABLE statement_deltas (
  id               TEXT PRIMARY KEY,    -- C8/f1/d1
  formalization_id TEXT NOT NULL REFERENCES formalizations(id),
  ordinal          INTEGER NOT NULL,
  kind             TEXT NOT NULL CHECK (kind IN
                     ('extra_hypothesis','restricted','stronger','reading','form')),
  text             TEXT NOT NULL,
  disposition_id   TEXT REFERENCES dispositions(id),
  UNIQUE (formalization_id, ordinal)
);

-- Further claims whose statement the same decision touches. A disposition
-- names one claim; an agreed paper edit can reword several (F8.1 rewrites the
-- sentence that introduces C15, C15.b, C15.c and C16). A statement is not
-- frozen while a paper edit or an undecided point in its scope is open.
CREATE TABLE disposition_scope (
  disposition_id TEXT NOT NULL REFERENCES dispositions(id),
  claim_id       TEXT NOT NULL REFERENCES claims(id),
  note           TEXT,
  PRIMARY KEY (disposition_id, claim_id)
);

-- Open points that keep a claim's statement from being frozen: an agreed
-- paper edit that is not upstream, a point with no decision, or a reading
-- that the Lean statement does not carry yet.
CREATE VIEW v_freeze_blockers AS
SELECT d.claim_id, d.id AS disposition_id, d.decision FROM dispositions d
WHERE d.status = 'open' AND d.level = 'statement'
  AND d.decision IN ('paper_edit','undecided','reading')
UNION
SELECT d.claim_id, d.id, d.decision FROM dispositions d
WHERE d.status = 'open' AND d.decision = 'paper_edit'
UNION
SELECT s.claim_id, d.id, d.decision FROM disposition_scope s
JOIN dispositions d ON d.id = s.disposition_id
WHERE d.status = 'open' AND d.decision IN ('paper_edit','undecided','reading');

-- -------------------------------------------------------------- frozen files
-- A Lean file whose text was approved against the paper (`ledger.py freeze`).
-- `check` fails when the file no longer has this hash, when a file it imports
-- from TinaV2/Defs is not frozen, or when a frozen formalization's file is
-- not listed here. So a frozen statement pins the definitions it is written in.
CREATE TABLE frozen_files (
  path       TEXT PRIMARY KEY,          -- TinaV2/Defs/Cost.lean
  sha256     TEXT NOT NULL,
  frozen_by  TEXT NOT NULL,
  frozen_on  TEXT NOT NULL,
  note       TEXT
);

-- --------------------------------------------------------------------- notes
-- Append-only log against any ledger id. Search here before retrying.
CREATE TABLE notes (
  id     INTEGER PRIMARY KEY,
  ts     TEXT NOT NULL,
  target TEXT NOT NULL,                 -- claim / proof / step / attempt / edit id
  kind   TEXT NOT NULL CHECK (kind IN
           ('success','failure','insight','decision','todo','done','build')),  -- done = a todo that was carried out
  body   TEXT NOT NULL
);

-- --------------------------------------------------------------------- views
-- Latest live formalization per claim.
CREATE VIEW v_formalization AS
SELECT f.* FROM formalizations f
WHERE f.status != 'superseded'
  AND f.version = (SELECT MAX(version) FROM formalizations g
                   WHERE g.claim_id = f.claim_id AND g.status != 'superseded');

-- Selected attempt per claim, with step coverage of the mirrored proof.
-- n_supplied counts the steps of that proof that are not in the paper.
CREATE VIEW v_selected AS
SELECT f.claim_id, a.id AS attempt_id, a.status AS attempt_status,
       a.proof_id, p.status AS proof_status,
       (SELECT COUNT(*) FROM steps s WHERE s.proof_id = a.proof_id) AS n_steps,
       (SELECT COUNT(*) FROM steps s WHERE s.proof_id = a.proof_id
           AND s.origin = 'supplied') AS n_supplied,
       (SELECT COUNT(*) FROM step_map m JOIN steps s ON s.id = m.step_id
         WHERE m.attempt_id = a.id AND s.proof_id = a.proof_id
           AND m.status = 'proved') AS n_steps_proved
FROM attempts a
JOIN formalizations f ON f.id = a.formalization_id
JOIN proofs p ON p.id = a.proof_id
WHERE a.selected = 1;

-- One row per claim with its overall state.
--   verified           Lean proof done, statement frozen, every step is a step
--                      of the paper's proof, nothing assumed, standard axioms
--   verified_supplied  the same, except that the proof is a supplement or has
--                      supplied steps: Lean proves the paper's statement by an
--                      argument that is not (all) in the paper
--   conditional        the same, except that the assembled theorem still
--                      assumes a claim that is not proved (column `assumes`)
--   needs_paper_edit   Lean proof done but mirrors a proposed (unapplied) proof
--   proved_unaudited   Lean proof done; statement not frozen, or the axioms
--                      are not recorded yet (`ledger.py audit`)
--   proving            an attempt is active/planned
--   stated             Lean statement exists, no attempt yet
--   no_written_proof   no proof in the paper and no supplement yet
--   todo               nothing yet
-- `written_proof` is the proof a new attempt would mirror: the paper's primary
-- proof if there is one, otherwise the supplement.
CREATE VIEW v_claim_status AS
SELECT c.id, c.kind, c.scope, c.tier, c.title, c.headline,
       (SELECT id FROM proofs p WHERE p.claim_id = c.id
          AND p.status = 'in_paper' AND p.is_primary = 1) AS paper_proof,
       (SELECT id FROM proofs p WHERE p.claim_id = c.id
          AND p.status = 'supplement' AND p.is_primary = 1) AS supplement_proof,
       vf.id AS formalization, vf.status AS stmt_status,
       vs.attempt_id, vs.proof_id AS mirrored_proof, vs.proof_status,
       vs.n_steps, vs.n_steps_proved, vs.n_supplied,
       asm.assumes, asm.axioms, asm.standard AS axioms_standard,
       (SELECT COUNT(*) FROM findings fi
         WHERE fi.claim_id = c.id AND fi.status = 'open') AS open_findings,
       (SELECT COUNT(*) FROM dispositions d
         WHERE d.claim_id = c.id AND d.decision = 'undecided') AS undecided,
       (SELECT COUNT(*) FROM dispositions d
         WHERE d.claim_id = c.id AND d.decision = 'paper_edit'
           AND d.status = 'open') AS edits_awaited,
       CASE
         WHEN c.scope != 'lean' THEN c.scope
         WHEN vs.attempt_status = 'proved' AND vs.proof_status = 'proposed'
              THEN 'needs_paper_edit'
         WHEN vs.attempt_status = 'proved'
              AND vs.proof_status IN ('in_paper','supplement')
              AND vs.n_steps > 0 AND vs.n_steps = vs.n_steps_proved
              AND vf.status = 'frozen' AND asm.standard = 1
              THEN CASE
                     WHEN asm.assumes != '' THEN 'conditional'
                     WHEN vs.proof_status = 'in_paper' AND vs.n_supplied = 0
                          THEN 'verified'
                     ELSE 'verified_supplied'
                   END
         WHEN vs.attempt_status = 'proved' THEN 'proved_unaudited'
         WHEN EXISTS (SELECT 1 FROM attempts a JOIN formalizations f
                        ON f.id = a.formalization_id
                      WHERE f.claim_id = c.id
                        AND a.status IN ('planned','active')) THEN 'proving'
         WHEN vf.id IS NOT NULL THEN 'stated'
         WHEN NOT EXISTS (SELECT 1 FROM proofs p WHERE p.claim_id = c.id
                            AND p.status IN ('in_paper','supplement','proposed'))
              AND c.kind NOT IN ('definition','assumption') THEN 'no_written_proof'
         ELSE 'todo'
       END AS state
FROM claims c
LEFT JOIN v_formalization vf ON vf.claim_id = c.id
LEFT JOIN v_selected vs ON vs.claim_id = c.id
LEFT JOIN assembled asm ON asm.claim_id = c.id AND asm.attempt_id = vs.attempt_id;

-- Claims ready to be proved: own statement and every lean-scope dependency's
-- statement are frozen (proofs are conditional on statements, so upstream
-- proofs need not be finished).
CREATE VIEW v_frontier AS
SELECT s.* FROM v_claim_status s
WHERE s.scope = 'lean' AND s.state IN ('stated','proving','todo','no_written_proof')
  AND s.kind NOT IN ('definition','assumption')   -- nothing to prove
  AND s.stmt_status = 'frozen'
  AND NOT EXISTS (
    SELECT 1 FROM claim_deps d
    JOIN claims dc ON dc.id = d.depends_on AND dc.scope = 'lean'
    LEFT JOIN v_formalization df ON df.claim_id = d.depends_on
    WHERE d.claim_id = s.id AND d.kind IN ('uses','setup','instantiates')
      AND (df.status IS NULL OR df.status != 'frozen'));

-- The completion record for each advertised result: where it is in the paper,
-- the Lean theorem, how the Lean statement differs from the paper's, where the
-- proof comes from, what is still assumed, and the axioms.
--   deltas   differences recorded between the Lean and the paper statement
--   narrower those of kind extra_hypothesis or restricted (Lean proves less)
CREATE VIEW v_headline AS
SELECT s.id, s.kind, c.label, s.title, vf.lean_decl, s.stmt_status, s.state,
       s.mirrored_proof AS proof,
       CASE s.proof_status WHEN 'in_paper' THEN 'paper'
                           WHEN 'supplement' THEN 'supplement'
                           ELSE s.proof_status END AS proof_home,
       s.n_steps, s.n_supplied, s.assumes, s.axioms,
       (SELECT COUNT(*) FROM statement_deltas d
         WHERE d.formalization_id = s.formalization) AS deltas,
       (SELECT COUNT(*) FROM statement_deltas d
         WHERE d.formalization_id = s.formalization
           AND d.kind IN ('extra_hypothesis','restricted')) AS narrower,
       s.undecided, s.edits_awaited
FROM v_claim_status s
JOIN claims c ON c.id = s.id
LEFT JOIN v_formalization vf ON vf.claim_id = s.id
WHERE c.headline = 1;
