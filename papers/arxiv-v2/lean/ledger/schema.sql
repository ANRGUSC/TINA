-- Proof ledger for the tina-v2-alt Lean formalization.
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
  notes      TEXT
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
-- A versioned English proof of a claim. Exactly one proof per claim may be
-- 'in_paper' and marked primary: that is the text the Lean proof must match.
CREATE TABLE proofs (
  id         TEXT PRIMARY KEY,          -- C7/p1
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  version    INTEGER NOT NULL,
  parent     TEXT REFERENCES proofs(id),  -- proof this one revises
  status     TEXT NOT NULL CHECK (status IN
               ('in_paper','proposed','superseded','rejected')),
  is_primary INTEGER NOT NULL DEFAULT 1,  -- 0 = secondary derivation/sketch
  summary    TEXT NOT NULL,
  created    TEXT NOT NULL,
  UNIQUE (claim_id, version)
);

-- One step of an English proof. `tex` is the verbatim paper text for the
-- step; `ledger check` requires it to be findable in the source file (for
-- in_paper proofs), so the paper cannot drift without the ledger noticing.
CREATE TABLE steps (
  id         TEXT PRIMARY KEY,          -- C7/p1/s3
  proof_id   TEXT NOT NULL REFERENCES proofs(id),
  ordinal    INTEGER NOT NULL,
  title      TEXT NOT NULL,
  tex        TEXT NOT NULL,
  source     TEXT REFERENCES sources(id),
  line_start INTEGER,
  line_end   INTEGER,
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

-- --------------------------------------------------------------------- notes
-- Append-only log against any ledger id. Search here before retrying.
CREATE TABLE notes (
  id     INTEGER PRIMARY KEY,
  ts     TEXT NOT NULL,
  target TEXT NOT NULL,                 -- claim / proof / step / attempt / edit id
  kind   TEXT NOT NULL CHECK (kind IN
           ('success','failure','insight','decision','todo','build')),
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
CREATE VIEW v_selected AS
SELECT f.claim_id, a.id AS attempt_id, a.status AS attempt_status,
       a.proof_id, p.status AS proof_status,
       (SELECT COUNT(*) FROM steps s WHERE s.proof_id = a.proof_id) AS n_steps,
       (SELECT COUNT(*) FROM step_map m JOIN steps s ON s.id = m.step_id
         WHERE m.attempt_id = a.id AND s.proof_id = a.proof_id
           AND m.status = 'proved') AS n_steps_proved
FROM attempts a
JOIN formalizations f ON f.id = a.formalization_id
JOIN proofs p ON p.id = a.proof_id
WHERE a.selected = 1;

-- One row per claim with its overall state.
--   verified          Lean proof done, mirrors the proof now in the paper, 1:1
--   needs_paper_edit  Lean proof done but mirrors a proposed (unapplied) proof
--   proving           an attempt is active/planned
--   stated            Lean statement exists, no attempt yet
--   no_paper_proof    lean-scope claim the paper asserts without proof
--   todo              nothing yet
CREATE VIEW v_claim_status AS
SELECT c.id, c.kind, c.scope, c.tier, c.title,
       (SELECT id FROM proofs p WHERE p.claim_id = c.id
          AND p.status = 'in_paper' AND p.is_primary = 1) AS paper_proof,
       vf.id AS formalization, vf.status AS stmt_status,
       vs.attempt_id, vs.n_steps, vs.n_steps_proved,
       (SELECT COUNT(*) FROM findings fi
         WHERE fi.claim_id = c.id AND fi.status = 'open') AS open_findings,
       CASE
         WHEN c.scope != 'lean' THEN c.scope
         WHEN vs.attempt_status = 'proved' AND vs.proof_status = 'in_paper'
              AND vs.n_steps > 0 AND vs.n_steps = vs.n_steps_proved
              AND vf.status = 'frozen' THEN 'verified'
         WHEN vs.attempt_status = 'proved' AND vs.proof_status = 'proposed'
              THEN 'needs_paper_edit'
         WHEN vs.attempt_status = 'proved' THEN 'proved_unaudited'
         WHEN EXISTS (SELECT 1 FROM attempts a JOIN formalizations f
                        ON f.id = a.formalization_id
                      WHERE f.claim_id = c.id
                        AND a.status IN ('planned','active')) THEN 'proving'
         WHEN vf.id IS NOT NULL THEN 'stated'
         WHEN NOT EXISTS (SELECT 1 FROM proofs p WHERE p.claim_id = c.id
                            AND p.status IN ('in_paper','proposed'))
              AND c.kind NOT IN ('definition','assumption') THEN 'no_paper_proof'
         ELSE 'todo'
       END AS state
FROM claims c
LEFT JOIN v_formalization vf ON vf.claim_id = c.id
LEFT JOIN v_selected vs ON vs.claim_id = c.id;

-- Claims ready to be proved: own statement and every lean-scope dependency's
-- statement are frozen (proofs are conditional on statements, so upstream
-- proofs need not be finished).
CREATE VIEW v_frontier AS
SELECT s.* FROM v_claim_status s
WHERE s.scope = 'lean' AND s.state IN ('stated','proving','todo','no_paper_proof')
  AND s.stmt_status = 'frozen'
  AND NOT EXISTS (
    SELECT 1 FROM claim_deps d
    JOIN claims dc ON dc.id = d.depends_on AND dc.scope = 'lean'
    LEFT JOIN v_formalization df ON df.claim_id = d.depends_on
    WHERE d.claim_id = s.id AND d.kind IN ('uses','setup','instantiates')
      AND (df.status IS NULL OR df.status != 'frozen'));
