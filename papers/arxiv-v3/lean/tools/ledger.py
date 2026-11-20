#!/usr/bin/env python3
"""Proof ledger CLI for the Lean formalization of the arXiv manuscript.

The ledger tracks arXiv v3 (submissions/arxiv-v3) since 2026-11-18 and tracked
arXiv v2 before; the `sources` table names the files and the commit. The Lean
package keeps the name TinaV2.

The ledger is a SQLite database rebuilt in memory on every call from two text
files that are committed to git:

    ledger/schema.sql   tables and views
    ledger/data.sql     one INSERT per row (the source of truth)

Mutating commands rewrite data.sql, so every change is a readable git diff.

    ledger.py status                 one line per claim
    ledger.py show C7                a claim with its proofs, steps, attempts,
                                     edits, findings, decisions and notes (also
                                     C7/p1, C7/p1/s2, C7/a1, C7/f1, E1, F1, F10.2)
    ledger.py headline               the advertised results: Lean theorem, proof
                                     home, what is still assumed, axioms
    ledger.py dispositions [--open] [--md]
                                     what was decided about each point raised
    ledger.py supplement [C5]        the proofs and steps that are not in the paper
    ledger.py docs                   rewrite paper-findings-dispositions.md and
                                     supplement.md from the ledger
    ledger.py frontier               claims ready to prove
    ledger.py sql "SELECT ..."       ad-hoc query
    ledger.py add TABLE k=v ...      insert a row (v may be @path to read a file)
    ledger.py set TABLE ID k=v ...   update a row
    ledger.py note TARGET KIND TEXT  append to the log
    ledger.py freeze PATH|C7/f1 [by=Scott] [note=...] [--refreeze]
                                     record a Lean file as approved against the
                                     paper, with its hash; freezes the statements
                                     declared in it
    ledger.py unfreeze PATH|C7/f1 REASON
                                     withdraw an approval; statements go back to draft
    ledger.py check                  verify ledger <-> paper <-> Lean invariants
    ledger.py assembly               write TinaV2/Assembly.lean from the selected attempts
                                     and record what each assembled theorem assumes
    ledger.py audit [-v]             compare what each Lean step lemma uses with
                                     step_deps, and record the axioms
    ledger.py graph                  claim dependency graph (Mermaid)
    ledger.py edit-diff E1           show an edit as a unified diff
    ledger.py edit-apply E1          apply an approved edit to the TeX
    ledger.py db [PATH]              write a .db file for use with sqlite3
    ledger.py serve [PORT]           open the progress explorer (progress/) locally
    ledger.py site OUTDIR            write the static progress site for GitHub Pages
"""
import datetime
import difflib
import hashlib
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPO = ROOT.parents[2]
SCHEMA = ROOT / "ledger" / "schema.sql"
DATA = ROOT / "ledger" / "data.sql"

# Dump order respects foreign keys.
TABLES = ["meta", "sources", "claims", "claim_deps", "proofs", "steps",
          "step_deps", "formalizations", "attempts", "assembled", "step_map",
          "edits", "edit_deps", "hunks", "hunk_steps", "findings", "dispositions",
          "disposition_scope", "statement_deltas", "frozen_files", "notes"]

STANDARD_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def now():
    return datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")


def connect():
    db = sqlite3.connect(":memory:")
    db.row_factory = sqlite3.Row
    db.executescript(SCHEMA.read_text())
    if DATA.exists():
        db.executescript(DATA.read_text())
    db.execute("PRAGMA foreign_keys = ON")
    return db


def pk_cols(db, table):
    info = db.execute(f"PRAGMA table_info({table})").fetchall()
    pk = [r["name"] for r in sorted(info, key=lambda r: r["pk"]) if r["pk"]]
    return pk or [r["name"] for r in info]


def save(db):
    bad = db.execute("PRAGMA foreign_key_check").fetchall()
    if bad:
        sys.exit(f"refusing to save: foreign key violations {[tuple(b) for b in bad]}")
    out = ["-- Ledger data. Written by tools/ledger.py; edit through the CLI.\n"]
    for t in TABLES:
        cols = [r["name"] for r in db.execute(f"PRAGMA table_info({t})")]
        order = ", ".join(pk_cols(db, t))
        quoted = ", ".join(f"quote({c})" for c in cols)
        rows = db.execute(f"SELECT {quoted} FROM {t} ORDER BY {order}").fetchall()
        if rows:
            out.append(f"\n-- {t}\n")
        for r in rows:
            out.append(f"INSERT INTO {t} ({', '.join(cols)}) VALUES ({', '.join(r)});\n")
    DATA.write_text("".join(out))


def table_out(rows, widths=None):
    rows = [dict(r) for r in rows]
    if not rows:
        print("(no rows)")
        return
    cols = list(rows[0].keys())
    cell = lambda v: "" if v is None else str(v).replace("\n", " ⏎ ")
    w = {c: min(max(len(c), *(len(cell(r[c])) for r in rows)), (widths or {}).get(c, 60))
         for c in cols}
    print("  ".join(c.ljust(w[c]) for c in cols))
    print("  ".join("-" * w[c] for c in cols))
    for r in rows:
        print("  ".join(cell(r[c])[:w[c]].ljust(w[c]) for c in cols))


def parse_kv(args):
    out = {}
    for a in args:
        if "=" not in a:
            sys.exit(f"expected key=value, got {a!r}")
        k, v = a.split("=", 1)
        if v.startswith("@"):
            v = Path(v[1:]).read_text()
        out[k] = None if v == "NULL" else v
    return out


# ------------------------------------------------------------------ commands
def cmd_status(db, args):
    where = "WHERE scope = 'lean'" if "--lean" in args else ""
    table_out(db.execute(
        f"""SELECT id, kind, tier, state,
                   COALESCE(paper_proof, supplement_proof) AS proof,
                   CASE WHEN paper_proof IS NOT NULL THEN 'paper'
                        WHEN supplement_proof IS NOT NULL THEN 'suppl'
                        ELSE '' END AS home,
                   stmt_status AS stmt, attempt_id AS attempt,
                   CASE WHEN n_steps IS NULL THEN ''
                        WHEN n_supplied > 0 THEN n_steps_proved || '/' || n_steps
                             || ' (' || n_supplied || ' suppl)'
                        ELSE n_steps_proved || '/' || n_steps END AS steps,
                   COALESCE(assumes, '') AS assumes,
                   open_findings AS finds,
                   CASE WHEN undecided > 0 THEN undecided || ' undecided'
                        WHEN edits_awaited > 0 THEN edits_awaited || ' edit'
                        ELSE '' END AS waits, title
            FROM v_claim_status {where} ORDER BY
              CAST(substr(id, 2) AS REAL), id"""), {"title": 44})
    print()
    table_out(db.execute(
        "SELECT state, COUNT(*) AS n FROM v_claim_status GROUP BY state ORDER BY n DESC"))


def kind_of(ident):
    if re.fullmatch(r"E\d+", ident): return "edits"
    if re.fullmatch(r"E\d+/h\d+", ident): return "hunks"
    if re.fullmatch(r"F\d+", ident): return "findings"
    if re.fullmatch(r"F\d+\.\d+", ident) or re.search(r"/d\d+$", ident):
        return "statement_deltas" if re.search(r"/f\d+/d\d+$", ident) else "dispositions"
    if re.search(r"/p\d+/s\w+$", ident): return "steps"
    if re.search(r"/p\d+$", ident): return "proofs"
    if re.search(r"/f\d+$", ident): return "formalizations"
    if re.search(r"/a\d+$", ident): return "attempts"
    return "claims"


def show_row(row):
    for k in row.keys():
        v = row[k]
        if v is None or v == "":
            continue
        v = str(v)
        if "\n" in v:
            print(f"{k}:")
            for line in v.rstrip("\n").split("\n"):
                print(f"    {line}")
        else:
            print(f"{k}: {v}")


def show_notes(db, target):
    rows = db.execute("SELECT ts, kind, target, body FROM notes WHERE target = ? "
                      "OR target LIKE ? ORDER BY id", (target, target + "/%")).fetchall()
    if rows:
        print("\n== notes")
        for r in rows:
            print(f"[{r['ts']}] {r['kind']:8} {r['target']}: {r['body']}")


def cmd_show(db, args):
    ident = args[0]
    t = kind_of(ident)
    row = db.execute(f"SELECT * FROM {t} WHERE id = ?", (ident,)).fetchone()
    if not row:
        sys.exit(f"no {t} row with id {ident}")
    print(f"== {t[:-1]} {ident}")
    show_row(row)
    q = lambda sql, *p: db.execute(sql, p).fetchall()
    if t == "claims":
        st = q("SELECT state FROM v_claim_status WHERE id = ?", ident)[0]["state"]
        print(f"state: {st}")
        for title, sql in [
            ("depends on", "SELECT depends_on AS id, kind, note FROM claim_deps WHERE claim_id = ?"),
            ("used by", "SELECT claim_id AS id, kind, note FROM claim_deps WHERE depends_on = ?"),
            ("sub-claims", "SELECT id, kind, title FROM claims WHERE parent = ?"),
            ("english proofs", "SELECT id, status, is_primary AS prim, parent, summary FROM proofs WHERE claim_id = ?"),
            ("lean statements", "SELECT id, status, lean_decl, fidelity FROM formalizations WHERE claim_id = ?"),
            ("differences from the paper's statement",
             "SELECT d.id, d.kind, d.disposition_id AS disp, d.text FROM statement_deltas d "
             "JOIN formalizations f ON f.id = d.formalization_id WHERE f.claim_id = ? "
             "ORDER BY d.formalization_id, d.ordinal"),
            ("lean attempts", "SELECT a.id, a.status, a.selected AS sel, a.proof_id, a.parent, a.strategy "
                              "FROM attempts a JOIN formalizations f ON f.id = a.formalization_id WHERE f.claim_id = ?"),
            ("paper edits", "SELECT id, target, status, from_proof, to_proof, reason FROM edits WHERE claim_id = ?"),
            ("findings", "SELECT id, severity, status, title FROM findings WHERE claim_id = ?"),
            ("decisions", "SELECT id, level, decision, status, decided_by AS by, point FROM dispositions "
                          "WHERE claim_id = ? ORDER BY id"),
            ("assembly", "SELECT attempt_id, assumes, axioms, checked FROM assembled WHERE claim_id = ?"),
        ]:
            rows = q(sql, ident)
            if rows:
                print(f"\n== {title}")
                table_out(rows, {"summary": 70, "strategy": 70, "reason": 70, "note": 70,
                                 "fidelity": 2000, "text": 2000, "point": 90, "by": 22})
    elif t == "findings":
        rows = q("SELECT id, level, decision, status, decided_by AS by, point, rationale "
                 "FROM dispositions WHERE finding_id = ? ORDER BY id", ident)
        if rows:
            print("\n== decisions")
            table_out(rows, {"point": 90, "rationale": 2000, "by": 22})
    elif t == "proofs":
        print("\n== steps")
        for s in q("SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal", ident):
            deps = [d["dep_id"] for d in q("SELECT dep_id FROM step_deps WHERE step_id = ?", s["id"])]
            maps = q("SELECT attempt_id, lean_decl, status FROM step_map WHERE step_id = ?", s["id"])
            where = ("supplied, not in the paper" if s["origin"] == "supplied"
                     else f"{s['source']}:{s['line_start']}-{s['line_end']}")
            print(f"{s['id']}  [{where}]  {s['title']}")
            if deps:
                print(f"    uses: {', '.join(deps)}")
            for m in maps:
                print(f"    lean: {m['lean_decl']} ({m['status']}, {m['attempt_id']})")
        rows = q("SELECT id, status, selected AS sel, strategy FROM attempts WHERE proof_id = ?", ident)
        if rows:
            print("\n== lean attempts mirroring this proof")
            table_out(rows, {"strategy": 80})
    elif t == "steps":
        table_out(q("SELECT dep_kind, dep_id FROM step_deps WHERE step_id = ?", ident))
        table_out(q("SELECT attempt_id, lean_decl, status FROM step_map WHERE step_id = ?", ident))
        table_out(q("SELECT hunk_id, effect FROM hunk_steps WHERE step_id = ?", ident))
    elif t == "attempts":
        print("\n== step map")
        table_out(q("SELECT s.ordinal, m.step_id, m.lean_decl, m.status, s.title FROM steps s "
                    "LEFT JOIN step_map m ON m.step_id = s.id AND m.attempt_id = ? "
                    "WHERE s.proof_id = ? ORDER BY s.ordinal", ident, row["proof_id"]))
    elif t == "edits":
        print("\n== hunks")
        cmd_edit_diff(db, [ident])
    show_notes(db, ident)


def cmd_frontier(db, args):
    table_out(db.execute("SELECT id, tier, state, paper_proof, title FROM v_frontier "
                         "ORDER BY tier, id"), {"title": 70})


def cmd_sql(db, args):
    cur = db.execute(args[0])
    if cur.description:
        table_out(cur.fetchall(), {c[0]: 100 for c in cur.description})
    if "--write" in args:
        save(db)


def cmd_add(db, args):
    table, kv = args[0], parse_kv(args[1:])
    cols = {r["name"] for r in db.execute(f"PRAGMA table_info({table})")}
    for c in ("created", "updated", "ts"):
        if c in cols and c not in kv:
            kv[c] = now()
    db.execute(f"INSERT INTO {table} ({', '.join(kv)}) VALUES ({', '.join('?' * len(kv))})",
               list(kv.values()))
    save(db)


def cmd_set(db, args):
    table, ident, kv = args[0], args[1], parse_kv(args[2:])
    cols = {r["name"] for r in db.execute(f"PRAGMA table_info({table})")}
    if "updated" in cols:
        kv.setdefault("updated", now())
    n = db.execute(f"UPDATE {table} SET {', '.join(k + ' = ?' for k in kv)} WHERE id = ?",
                   [*kv.values(), ident]).rowcount
    if n != 1:
        sys.exit(f"{n} rows matched {table}.id = {ident}")
    save(db)


def cmd_note(db, args):
    target, kind, body = args[0], args[1], " ".join(args[2:])
    t = kind_of(target)
    if not db.execute(f"SELECT 1 FROM {t} WHERE id = ?", (target,)).fetchone():
        sys.exit(f"unknown target {target}")
    db.execute("INSERT INTO notes (ts, target, kind, body) VALUES (?, ?, ?, ?)",
               (now(), target, kind, body))
    save(db)


def lean_sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def defs_imports(path):
    """TinaV2/Defs files a Lean file imports directly (`TinaV2.Defs` is all of them)."""
    out = set()
    for m in re.findall(r"^import\s+(TinaV2\.Defs(?:\.\w+)?)\s*$", (ROOT / path).read_text(), re.M):
        if m == "TinaV2.Defs":
            out |= {str(f.relative_to(ROOT)) for f in (ROOT / "TinaV2" / "Defs").glob("*.lean")}
        else:
            out.add(m.replace(".", "/") + ".lean")
    return sorted(out)


def cmd_freeze(db, args):
    flags = {a for a in args if a.startswith("--")}
    args = [a for a in args if not a.startswith("--")]
    if not args:
        sys.exit("usage: ledger.py freeze PATH|FORMALIZATION [by=NAME] [note=TEXT] [--refreeze]")
    target, kv = args[0], parse_kv(args[1:])
    row = db.execute("SELECT lean_file FROM formalizations WHERE id = ?", (target,)).fetchone()
    path = row["lean_file"] if row else target
    if not (ROOT / path).is_file():
        sys.exit(f"{path}: no such file under {ROOT}")
    frozen = {r["path"] for r in db.execute("SELECT path FROM frozen_files")}
    need = [d for d in defs_imports(path) if d not in frozen]
    if need:
        sys.exit(f"{path} imports definitions that are not frozen yet: {', '.join(need)}")
    blocked = db.execute(
        "SELECT f.id, b.disposition_id, b.decision FROM formalizations f "
        "JOIN v_freeze_blockers b ON b.claim_id = f.claim_id "
        "WHERE f.lean_file = ? AND f.status IN ('draft','reviewed','frozen')", (path,)).fetchall()
    if blocked:
        sys.exit(f"{path} waits for: " + ", ".join(
            f"{b['disposition_id']} ({b['decision']}, on {b['id']})" for b in blocked)
            + ". A statement is frozen after the paper edit is upstream or the point is decided.")
    sha = lean_sha(path)
    old = db.execute("SELECT sha256 FROM frozen_files WHERE path = ?", (path,)).fetchone()
    if old and old["sha256"] != sha and "--refreeze" not in flags:
        sys.exit(f"{path} is frozen with another hash ({old['sha256'][:12]}); the file changed. "
                 f"Revert it, or review the change and pass --refreeze.")
    db.execute("INSERT OR REPLACE INTO frozen_files (path, sha256, frozen_by, frozen_on, note) "
               "VALUES (?, ?, ?, ?, ?)",
               (path, sha, kv.get("by", "Scott"), datetime.date.today().isoformat(), kv.get("note")))
    fs = [r["id"] for r in db.execute(
        "SELECT id FROM formalizations WHERE lean_file = ? AND status IN ('draft','reviewed')", (path,))]
    db.execute("UPDATE formalizations SET status = 'frozen' WHERE lean_file = ? "
               "AND status IN ('draft','reviewed')", (path,))
    save(db)
    print(f"frozen {path}  sha256 {sha[:12]}" + (f"  statements: {', '.join(fs)}" if fs else ""))


def cmd_unfreeze(db, args):
    """Withdraw an approval: the file's hash is dropped and its statements go back to draft."""
    if len(args) < 2:
        sys.exit("usage: ledger.py unfreeze PATH|FORMALIZATION REASON")
    target, reason = args[0], " ".join(args[1:])
    row = db.execute("SELECT lean_file FROM formalizations WHERE id = ?", (target,)).fetchone()
    path = row["lean_file"] if row else target
    if not db.execute("SELECT 1 FROM frozen_files WHERE path = ?", (path,)).fetchone():
        sys.exit(f"{path} is not frozen")
    users = [r["path"] for r in db.execute("SELECT path FROM frozen_files WHERE path != ?", (path,))
             if path in defs_imports(r["path"])]
    if users:
        sys.exit(f"{path} is imported by frozen files: {', '.join(users)}; unfreeze those first")
    fs = [r["id"] for r in db.execute(
        "SELECT id FROM formalizations WHERE lean_file = ? AND status = 'frozen'", (path,))]
    db.execute("DELETE FROM frozen_files WHERE path = ?", (path,))
    db.execute("UPDATE formalizations SET status = 'draft' WHERE lean_file = ? AND status = 'frozen'", (path,))
    for f in fs:
        db.execute("INSERT INTO notes (ts, target, kind, body) VALUES (?, ?, 'decision', ?)",
                   (now(), f, f"Approval withdrawn, statement back to draft: {reason}"))
    save(db)
    print(f"unfrozen {path}" + (f"  statements back to draft: {', '.join(fs)}" if fs else ""))


def norm(text):
    return re.sub(r"\s+", " ", text).strip()


def source_text(db, sid, cache={}):
    if sid not in cache:
        path = db.execute("SELECT path FROM sources WHERE id = ?", (sid,)).fetchone()["path"]
        cache[sid] = (REPO / path).read_text() if (REPO / path).exists() else ""
    return cache[sid]


def run_check(db):
    """Return (errors, warnings) for the ledger <-> paper <-> Lean invariants."""
    errs, warns = [], []
    q = lambda sql, *p: db.execute(sql, p).fetchall()

    missing = set()   # sources that are gone: report once, skip their excerpt checks
    for s in q("SELECT * FROM sources"):
        if not (REPO / s["path"]).exists():
            missing.add(s["id"])
            errs.append(f"{s['id']}: {s['path']} does not exist (renamed or removed since "
                        f"the ledger was aligned at {(s['git_commit'] or '?')[:7]})")
        elif hashlib.sha256((REPO / s["path"]).read_bytes()).hexdigest() != s["sha256"]:
            warns.append(f"{s['id']}: {s['path']} changed since the ledger was aligned "
                         f"(excerpt checks below decide whether that matters)")

    # 1. Every paper step of a proof that is in the paper is verbatim in the
    # paper. Supplied steps are not paper text and are checked in 6 below.
    for s in q("SELECT s.* FROM steps s JOIN proofs p ON p.id = s.proof_id "
               "WHERE p.status = 'in_paper' AND s.origin = 'paper'"):
        if s["source"] in missing:
            continue
        if norm(s["tex"]) not in norm(source_text(db, s["source"])):
            errs.append(f"{s['id']}: step text no longer found in {s['source']}")

    # 2. One primary in-paper proof per claim.
    for r in q("SELECT claim_id, COUNT(*) n FROM proofs WHERE status = 'in_paper' "
               "AND is_primary = 1 GROUP BY claim_id HAVING n > 1"):
        errs.append(f"{r['claim_id']}: {r['n']} primary in-paper proofs")

    # 3. Step dependencies resolve, and point backwards within a proof. One
    # exception (README, "The 1:1 rule"): where the paper's step cites an
    # equation inside another claim's proof, the dependency may name that step,
    # if it is a step of the primary in-paper proof of a claim this one uses.
    for d in q("SELECT d.*, s.proof_id, s.ordinal, p.claim_id FROM step_deps d "
               "JOIN steps s ON s.id = d.step_id JOIN proofs p ON p.id = s.proof_id"):
        if d["dep_kind"] == "claim":
            if not q("SELECT 1 FROM claims WHERE id = ?", d["dep_id"]):
                errs.append(f"{d['step_id']}: unknown claim dependency {d['dep_id']}")
            continue
        o = q("SELECT s.proof_id, s.ordinal, p.claim_id, p.status, p.is_primary FROM steps s "
              "JOIN proofs p ON p.id = s.proof_id WHERE s.id = ?", d["dep_id"])
        if not o:
            errs.append(f"{d['step_id']}: unknown step dependency {d['dep_id']}")
        elif o[0]["proof_id"] == d["proof_id"]:
            if o[0]["ordinal"] >= d["ordinal"]:
                errs.append(f"{d['step_id']}: step dependency {d['dep_id']} is not an earlier step of the same proof")
        elif not (o[0]["status"] == "in_paper" and o[0]["is_primary"] and q(
                "SELECT 1 FROM claim_deps WHERE claim_id = ? AND depends_on = ? AND kind = 'uses'",
                d["claim_id"], o[0]["claim_id"])):
            errs.append(f"{d['step_id']}: step dependency {d['dep_id']} is in another proof; that is allowed "
                        f"only for a step of the primary in-paper proof of a claim {d['claim_id']} uses")

    # 4. Attempts: the Lean file and the mirrored English proof agree 1:1.
    for r in q("SELECT claim_id, COUNT(*) n FROM v_selected GROUP BY claim_id HAVING n > 1"):
        errs.append(f"{r['claim_id']}: {r['n']} selected attempts")
    decl_re = re.compile(r"^\s*(?:private\s+|protected\s+)?(?:theorem|lemma)\s+([\w.']+)", re.M)
    for a in q("SELECT * FROM attempts WHERE status IN ('active','proved')"):
        f = ROOT / a["lean_file"]
        if not f.exists():
            errs.append(f"{a['id']}: missing Lean file {a['lean_file']}")
            continue
        src = f.read_text()
        decls = set(decl_re.findall(src))
        steps = {s["id"] for s in q("SELECT id FROM steps WHERE proof_id = ?", a["proof_id"])}
        maps = {m["step_id"]: m for m in q("SELECT * FROM step_map WHERE attempt_id = ?", a["id"])}
        for sid in sorted(steps - maps.keys()):
            errs.append(f"{a['id']}: step {sid} has no Lean lemma")
        for sid in sorted(maps.keys() - steps):
            errs.append(f"{a['id']}: Lean lemma {maps[sid]['lean_decl']} maps to {sid}, "
                        f"which is not a step of {a['proof_id']}")
        mapped = {m["lean_decl"].split(".")[-1] for m in maps.values()}
        for name in sorted(mapped - decls):
            errs.append(f"{a['id']}: {name} is in the step map but not in {a['lean_file']}")
        extra = sorted(decls - mapped - {"main"})
        if extra:
            errs.append(f"{a['id']}: Lean lemmas with no step: {', '.join(extra)} "
                        f"(move to Routine/, or record a supplied step with a disposition)")
        if a["status"] == "proved":
            if re.search(r"\b(sorry|admit)\b", src):
                errs.append(f"{a['id']}: marked proved but {a['lean_file']} contains sorry")
            for m in maps.values():
                if m["status"] != "proved":
                    errs.append(f"{a['id']}: marked proved but step {m['step_id']} is {m['status']}")

    # 4c. Separation of proof files: an attempt imports statements and routine
    # lemmas only, and routine files never import statements or proofs. The
    # one other import an attempt may have is the selected attempt file of a
    # proof that owns a step listed as a cross-proof dependency of the proof
    # it mirrors (rule 3); `audit` then checks which lemmas of it are used.
    imp_re = re.compile(r"^import\s+(\S+)", re.M)
    for a in q("SELECT * FROM attempts WHERE status IN ('active','proved')"):
        f = ROOT / a["lean_file"]
        if f.exists():
            cross = {r["lean_file"][:-len(".lean")].replace("/", ".") for r in q(
                "SELECT DISTINCT b.lean_file FROM step_deps d JOIN steps s ON s.id = d.step_id "
                "JOIN steps o ON o.id = d.dep_id JOIN attempts b ON b.proof_id = o.proof_id "
                "WHERE d.dep_kind = 'step' AND s.proof_id = ? AND o.proof_id != s.proof_id "
                "AND b.selected = 1 AND b.status = 'proved'", a["proof_id"])}
            bad = [i for i in imp_re.findall(f.read_text())
                   if i != "TinaV2.Statements" and not i.startswith("TinaV2.Routine.")
                   and i not in cross]
            if bad:
                errs.append(f"{a['id']}: {a['lean_file']} imports {', '.join(bad)}; an attempt may "
                            f"import only TinaV2.Statements, TinaV2.Routine.* and the selected attempt "
                            f"of a proof whose steps its own steps list in step_deps")
    for f in sorted((ROOT / "TinaV2" / "Routine").glob("*.lean")):
        bad = [i for i in imp_re.findall(f.read_text())
               if i.startswith(("TinaV2.Statements", "TinaV2.Proofs", "TinaV2.Assembly"))]
        if bad:
            errs.append(f"TinaV2/Routine/{f.name} imports {', '.join(bad)}; routine files may "
                        f"not import statements or proofs")

    # 4a. The assembly file is the one the selected attempts generate, and the
    # `assembled` rows say what it says.
    if q("SELECT 1 FROM attempts WHERE selected = 1 AND status = 'proved'"):
        text, plan = assembly_plan(db)
        if not ASSEMBLY.exists():
            errs.append("TinaV2/Assembly.lean is missing: run `ledger.py assembly`")
        elif ASSEMBLY.read_text() != text:
            errs.append("TinaV2/Assembly.lean is out of date: run `ledger.py assembly`")
        rows = {r["claim_id"]: r for r in q("SELECT * FROM assembled")}
        for claim, (attempt, assumes) in sorted(plan.items()):
            r = rows.pop(claim, None)
            if not r or r["attempt_id"] != attempt or r["assumes"] != assumes:
                errs.append(f"{claim}: the assembled record is missing or stale: run `ledger.py assembly`")
            elif r["axioms"] is None:
                warns.append(f"{claim}: axioms not recorded for {attempt}: run `lake build` then `ledger.py audit`")
            elif not r["standard"]:
                errs.append(f"{claim}: {attempt} depends on axioms outside the standard three: {r['axioms']}")
        for claim in sorted(rows):
            errs.append(f"{claim}: assembled record without a selected proved attempt: run `ledger.py assembly`")

    # 4b. Every live Lean statement exists where the ledger says it does.
    for f in q("SELECT * FROM formalizations WHERE status != 'superseded'"):
        path = ROOT / f["lean_file"]
        name = f["lean_decl"].split(".")[-1]
        if not path.exists():
            errs.append(f"{f['id']}: missing Lean file {f['lean_file']}")
        elif not re.search(rf"^\s*(?:def|structure|abbrev)\s+{re.escape(name)}\b",
                           path.read_text(), re.M):
            errs.append(f"{f['id']}: {name} is not declared in {f['lean_file']}")

    # 5. Edits: hunk text is where the status says it should be.
    for h in q("SELECT h.*, e.status FROM hunks h JOIN edits e ON e.id = h.edit_id"):
        if h["source"] in missing:
            continue
        text = norm(source_text(db, h["source"]))
        if h["status"] in ("proposed", "approved"):
            want = h["old_tex"] or h["anchor"] or ""
            if not want or norm(want) not in text:
                errs.append(f"{h['id']}: text to replace not found in {h['source']} (edit is stale)")
        elif h["status"] == "applied" and h["new_tex"] and norm(h["new_tex"]) not in text:
            errs.append(f"{h['id']}: edit marked applied but new text not found in {h['source']}")
    for e in q("SELECT * FROM edits WHERE status = 'applied' AND to_proof IS NOT NULL"):
        st = q("SELECT status FROM proofs WHERE id = ?", e["to_proof"])[0]["status"]
        if st != "in_paper":
            errs.append(f"{e['id']}: applied, but {e['to_proof']} is '{st}', not in_paper")
    for p in q("SELECT * FROM proofs WHERE status = 'proposed'"):
        if not q("SELECT 1 FROM edits WHERE to_proof = ? AND status IN ('proposed','approved')", p["id"]):
            errs.append(f"{p['id']}: proposed proof has no edit carrying its text into the paper")
    for s in q("SELECT s.id, s.tex, p.parent FROM steps s JOIN proofs p ON p.id = s.proof_id "
               "WHERE p.parent IS NOT NULL AND p.status IN ('proposed','in_paper') "
               "AND NOT EXISTS (SELECT 1 FROM hunk_steps hs WHERE hs.step_id = s.id)"):
        old = {norm(o["tex"]) for o in q("SELECT tex FROM steps WHERE proof_id = ?", s["parent"])}
        if norm(s["tex"]) not in old:
            errs.append(f"{s['id']}: step differs from the previous proof version but no hunk records the change")

    # 6. Proof homes and dispositions.
    for s in q("SELECT s.id, s.origin, s.source FROM steps s JOIN proofs p ON p.id = s.proof_id "
               "WHERE p.status = 'supplement'"):
        if s["origin"] != "supplied":
            errs.append(f"{s['id']}: a step of a supplement proof must have origin 'supplied'")
    for s in q("SELECT s.id FROM steps s JOIN proofs p ON p.id = s.proof_id "
               "WHERE p.status IN ('in_paper','proposed') AND s.origin = 'supplied' "
               "AND NOT EXISTS (SELECT 1 FROM dispositions d WHERE d.step_id = s.id "
               "                AND d.decision = 'lean_supplies')"):
        errs.append(f"{s['id']}: supplied step in a paper proof has no 'lean_supplies' disposition pointing at it")
    for p in q("SELECT id, claim_id FROM proofs WHERE status = 'supplement'"):
        if not q("SELECT 1 FROM dispositions WHERE claim_id = ? AND decision = 'lean_supplies' "
                 "AND (whole_proof = 1 OR proof_id = ?)", p["claim_id"], p["id"]):
            errs.append(f"{p['id']}: supplement proof without a 'lean_supplies' disposition on {p['claim_id']}")
    for r in q("SELECT claim_id, COUNT(*) n FROM proofs WHERE status = 'supplement' "
               "AND is_primary = 1 GROUP BY claim_id HAVING n > 1"):
        errs.append(f"{r['claim_id']}: {r['n']} primary supplement proofs")
    # Every point gets a disposition: each open finding, and each claim the
    # paper asserts without proof.
    for f in q("SELECT id FROM findings f WHERE status = 'open' AND NOT EXISTS "
               "(SELECT 1 FROM dispositions d WHERE d.finding_id = f.id)"):
        errs.append(f"{f['id']}: open finding with no disposition")
    for c in q("SELECT id FROM v_claim_status WHERE scope = 'lean' AND paper_proof IS NULL "
               "AND kind NOT IN ('definition','assumption')"):
        if not q("SELECT 1 FROM dispositions WHERE claim_id = ? AND whole_proof = 1", c["id"]):
            errs.append(f"{c['id']}: the paper gives no proof and no disposition (whole_proof = 1) says what to do")
    proved = lambda proof_id: q(
        "SELECT 1 FROM attempts a WHERE a.proof_id = ? AND a.selected = 1 AND a.status = 'proved'", proof_id)
    for d in q("SELECT * FROM dispositions"):
        if d["decision"] == "lean_supplies" and d["status"] == "done":
            if d["step_id"]:
                if not q("SELECT 1 FROM step_map m JOIN attempts a ON a.id = m.attempt_id "
                         "WHERE m.step_id = ? AND m.status = 'proved' AND a.selected = 1 "
                         "AND a.status = 'proved'", d["step_id"]):
                    errs.append(f"{d['id']}: done, but step {d['step_id']} is not proved in a selected attempt")
            elif d["proof_id"]:
                if not proved(d["proof_id"]):
                    errs.append(f"{d['id']}: done, but no selected proved attempt mirrors {d['proof_id']}")
            elif d["lean_ref"]:
                ref = d["lean_ref"].split("::")[0]
                if not (ROOT / ref).exists():
                    errs.append(f"{d['id']}: lean_ref {ref} does not exist")
                elif "::" in d["lean_ref"] and not re.search(
                        rf"\b{re.escape(d['lean_ref'].split('::')[1])}\b", (ROOT / ref).read_text()):
                    errs.append(f"{d['id']}: {d['lean_ref'].split('::')[1]} not found in {ref}")
            else:
                errs.append(f"{d['id']}: 'lean_supplies' marked done with no step_id, proof_id or lean_ref")
        if d["decision"] == "lean_supplies" and d["status"] == "open" and d["whole_proof"]:
            sp = q("SELECT id FROM proofs WHERE claim_id = ? AND status = 'supplement' "
                   "AND is_primary = 1", d["claim_id"])
            if sp and proved(sp[0]["id"]):
                warns.append(f"{d['id']}: {sp[0]['id']} is proved; mark the disposition done "
                             f"(set status=done proof_id={sp[0]['id']})")
        if d["decision"] == "paper_edit" and d["status"] == "done":
            applied = d["edit_id"] and q("SELECT 1 FROM edits WHERE id = ? AND status = 'applied'", d["edit_id"])
            if not d["resolved_commit"] and not applied:
                errs.append(f"{d['id']}: paper edit marked done with no resolved_commit or applied edit")
    settled = []
    for f in q("SELECT f.id, f.status, "
               "(SELECT COUNT(*) FROM dispositions d WHERE d.finding_id = f.id) n, "
               "(SELECT COUNT(*) FROM dispositions d WHERE d.finding_id = f.id AND d.status = 'open') n_open "
               "FROM findings f"):
        if f["status"] != "open" and f["n_open"]:
            errs.append(f"{f['id']}: finding is {f['status']} but {f['n_open']} of its dispositions are open")
        elif f["status"] == "open" and f["n"] and not f["n_open"]:
            settled.append(f["id"])
    if settled:
        warns.append(f"{len(settled)} open findings have every point carried out and can be closed "
                     f"(`ledger.py set findings F7 status=resolved resolution=...`): {', '.join(settled)}")
    for name in DOCS:
        f = ROOT / name
        if not f.exists() or f.read_text() != doc_text(db, name):
            errs.append(f"{name} is missing or out of date: run `ledger.py docs`")
    # Frozen files are unchanged, rest on frozen definitions, and every frozen
    # statement is in one.
    frozen = {r["path"]: r for r in q("SELECT * FROM frozen_files")}
    for path, r in frozen.items():
        if not (ROOT / path).is_file():
            errs.append(f"{path}: frozen file does not exist")
            continue
        if lean_sha(path) != r["sha256"]:
            errs.append(f"{path}: changed since it was frozen on {r['frozen_on']} by {r['frozen_by']} "
                        f"(revert, or review the change and `ledger.py freeze {path} --refreeze`; "
                        f"a changed statement is a new formalization version)")
        for d in defs_imports(path):
            if d not in frozen:
                errs.append(f"{path}: frozen, but it imports {d}, which is not")
    for b in q("SELECT f.id, b.disposition_id, b.decision FROM formalizations f "
               "JOIN v_freeze_blockers b ON b.claim_id = f.claim_id WHERE f.status = 'frozen'"):
        errs.append(f"{b['id']}: frozen, but {b['disposition_id']} ({b['decision']}) is still open "
                    f"(`ledger.py unfreeze {b['id']} REASON`; freeze again when it is settled)")
    for f in q("SELECT id, lean_file FROM formalizations WHERE status = 'frozen'"):
        if f["lean_file"] not in frozen:
            errs.append(f"{f['id']}: frozen, but {f['lean_file']} has no recorded hash "
                        f"(`ledger.py freeze {f['id']}`)")
    # A frozen statement of an advertised result has its differences listed.
    for h in q("SELECT h.id FROM v_headline h WHERE h.stmt_status = 'frozen' AND h.deltas = 0"):
        warns.append(f"{h['id']}: frozen headline statement with no statement_deltas row "
                     f"(record the differences from the paper, or a 'form' row saying there are none)")
    # A claim is reported verified from its own proof and its own statement. If
    # a step of that proof cites a claim whose statement is not approved yet,
    # the review of that statement can still change what the step rests on.
    # Direct dependencies only: a claim is used through its statement, so a
    # change further down does not reach past a frozen statement.
    for r in q("SELECT cs.id, cs.state, dep.id AS dep, dep.formalization AS dep_f, "
               "       dep.stmt_status AS dep_status, GROUP_CONCAT(DISTINCT s.id) AS steps "
               "FROM v_claim_status cs "
               "JOIN steps s ON s.proof_id = cs.mirrored_proof "
               "JOIN step_deps sd ON sd.step_id = s.id "
               "JOIN v_claim_status dep ON dep.id = CASE sd.dep_kind WHEN 'claim' THEN sd.dep_id "
               "     ELSE (SELECT p.claim_id FROM steps s2 JOIN proofs p ON p.id = s2.proof_id "
               "           WHERE s2.id = sd.dep_id) END "
               "WHERE cs.state IN ('verified', 'verified_supplied') AND dep.id != cs.id "
               "  AND dep.formalization IS NOT NULL AND dep.stmt_status != 'frozen' "
               "GROUP BY cs.id, dep.id ORDER BY cs.id, dep.id"):
        warns.append(f"{r['id']}: reported {r['state']}, but its proof cites {r['dep']} (in {r['steps']}), "
                     f"whose statement {r['dep_f']} is {r['dep_status']}, not approved. If the review changes "
                     f"that statement, those steps are re-pointed.")

    return errs, warns


def cmd_check(db, args):
    errs, warns = run_check(db)
    for w in warns:
        print(f"warn  {w}")
    for e in errs:
        print(f"ERROR {e}")
    print(f"{len(errs)} errors, {len(warns)} warnings")
    sys.exit(1 if errs else 0)


def cmd_graph(db, args):
    print("graph BT")
    style = {"verified": ":::ok", "verified_supplied": ":::ok", "conditional": ":::edit",
             "needs_paper_edit": ":::edit", "proving": ":::wip"}
    for c in db.execute("SELECT id, title, state FROM v_claim_status WHERE scope = 'lean' "
                        "ORDER BY id"):
        nid = c["id"].replace(".", "_")
        print(f'  {nid}["{c["id"]}: {c["title"][:40]}"]{style.get(c["state"], "")}')
    for d in db.execute("SELECT d.* FROM claim_deps d JOIN claims a ON a.id = d.claim_id "
                        "JOIN claims b ON b.id = d.depends_on "
                        "WHERE a.scope = 'lean' AND b.scope = 'lean' ORDER BY 1, 2"):
        arrow = "-.->" if d["kind"] == "setup" else "-->"
        print(f"  {d['depends_on'].replace('.', '_')} {arrow} {d['claim_id'].replace('.', '_')}")
    print("  classDef ok fill:#cfc;\n  classDef edit fill:#fdc;\n  classDef wip fill:#ffc;")


def cmd_edit_diff(db, args):
    for h in db.execute("SELECT h.*, s.path FROM hunks h JOIN sources s ON s.id = h.source "
                        "WHERE edit_id = ? ORDER BY ordinal", (args[0],)):
        touched = [f"{r['effect']} {r['step_id']}" for r in db.execute(
            "SELECT * FROM hunk_steps WHERE hunk_id = ?", (h["id"],))]
        print(f"--- {h['id']}  {h['path']}  ({'; '.join(touched) or 'no step'})")
        if not h["old_tex"] and h["anchor"]:
            print(f"    insert after: {norm(h['anchor'])[:90]}")
        for line in difflib.unified_diff(h["old_tex"].splitlines(), h["new_tex"].splitlines(),
                                         lineterm="", n=2):
            if not line.startswith(("---", "+++")):
                print(line)


def cmd_edit_apply(db, args):
    eid = args[0]
    e = db.execute("SELECT * FROM edits WHERE id = ?", (eid,)).fetchone()
    if not e or e["status"] != "approved":
        sys.exit(f"{eid} must exist with status 'approved' (it is {e['status'] if e else 'missing'})")
    for d in db.execute("SELECT depends_on FROM edit_deps WHERE edit_id = ?", (eid,)):
        st = db.execute("SELECT status FROM edits WHERE id = ?", (d[0],)).fetchone()["status"]
        if st != "applied":
            sys.exit(f"{eid} depends on {d[0]}, which is '{st}'")
    texts = {}
    for h in db.execute("SELECT h.*, s.path FROM hunks h JOIN sources s ON s.id = h.source "
                        "WHERE edit_id = ? ORDER BY ordinal", (eid,)):
        path = REPO / h["path"]
        text = texts.setdefault(path, path.read_text())
        old = h["old_tex"] or h["anchor"]
        if text.count(old) != 1:
            sys.exit(f"{h['id']}: text to replace occurs {text.count(old)} times in {h['path']}")
        new = h["new_tex"] if h["old_tex"] else h["anchor"] + h["new_tex"]
        texts[path] = text.replace(old, new)
    for path, text in texts.items():
        path.write_text(text)
    db.execute("UPDATE edits SET status = 'applied' WHERE id = ?", (eid,))
    if e["to_proof"]:
        db.execute("UPDATE proofs SET status = 'in_paper' WHERE id = ?", (e["to_proof"],))
    if e["from_proof"]:
        db.execute("UPDATE proofs SET status = 'superseded' WHERE id = ?", (e["from_proof"],))
    for s in db.execute("SELECT id, path FROM sources").fetchall():
        db.execute("UPDATE sources SET sha256 = ? WHERE id = ?",
                   (hashlib.sha256((REPO / s["path"]).read_bytes()).hexdigest(), s["id"]))
    save(db)
    print(f"applied {eid} to {', '.join(str(p.relative_to(REPO)) for p in texts)}; "
          f"commit, then: ledger.py set edits {eid} applied_commit=<sha>")


ASSEMBLY = ROOT / "TinaV2" / "Assembly.lean"


def assembly_text(db):
    return assembly_plan(db)[0]


def assembly_plan(db):
    """Lean source that composes the selected proved attempts end to end, and
    {claim id: (attempt id, claims still assumed)} for the `assembled` table.

    Each attempt's `main` takes the claims it uses as hypotheses
    `(hC7 : C07.Statement)`. Here each is given the assembled theorem for that
    claim. A used claim with no proved attempt stays an explicit hypothesis of
    the assembled theorem, and of everything downstream of it.
    """
    info = {}
    for r in db.execute(
            "SELECT f.claim_id, f.lean_decl, a.id, a.lean_file FROM attempts a "
            "JOIN formalizations f ON f.id = a.formalization_id "
            "WHERE a.selected = 1 AND a.status = 'proved' ORDER BY f.claim_id"):
        src = (ROOT / r["lean_file"]).read_text()
        short = r["lean_decl"].split(".")[-2]                 # C07
        sig = re.search(r"^theorem main\b(.*?):=", src, re.M | re.S)
        ns = re.search(r"^namespace\s+(\S+)", src, re.M)
        if not sig or not ns:
            sys.exit(f"{r['id']}: no `theorem main` or namespace in {r['lean_file']}")
        info[short] = {
            "claim": r["claim_id"], "attempt": r["id"], "ns": ns.group(1),
            "module": r["lean_file"][:-len(".lean")].replace("/", "."),
            "hyps": re.findall(r"\(\s*\w+\s*:\s*(C\w+)\.Statement\s*\)", sig.group(1))}
    order, done = [], set()

    def visit(c, stack=()):
        if c in done or c not in info:
            return
        if c in stack:
            sys.exit(f"circular use of claims: {' -> '.join(stack + (c,))}")
        for h in info[c]["hyps"]:
            visit(h, stack + (c,))
        done.add(c)
        order.append(c)
    for c in sorted(info):
        visit(c)
    unproved = {}                    # claim -> hypotheses still open, transitively
    for c in order:
        unproved[c] = []
        for h in info[c]["hyps"]:
            for x in (unproved[h] if h in info else [h]):
                if x not in unproved[c]:
                    unproved[c].append(x)
    out = ["/-! # Assembly: the selected proof attempts composed end to end",
           "",
           "Generated by `python3 tools/ledger.py assembly`. Do not edit by hand.",
           "",
           "Each theorem below is the `main` of the selected attempt for a claim, with the",
           "claims it uses supplied by the theorems above it. A hypothesis that remains",
           "is a claim that is used but not yet proved. The `#print axioms` lines must",
           "list only `propext`, `Classical.choice` and `Quot.sound`. -/",
           ""]
    out[0:0] = [f"import {info[c]['module']}" for c in order] + [""]
    out += ["namespace TinaV2.Assembly", ""]
    for c in order:
        i = info[c]
        binders = "".join(f" (h{x} : TinaV2.{x}.Statement)" for x in unproved[c])
        args = ""
        for h in i["hyps"]:
            if h not in info:
                args += f" h{h}"
            elif unproved[h]:
                args += " (" + h + "".join(f" h{x}" for x in unproved[h]) + ")"
            else:
                args += f" {h}"
        out += [f"/-- {i['claim']}, attempt {i['attempt']}. -/",
                f"theorem {c}{binders} : TinaV2.{c}.Statement := {i['ns']}.main{args}", ""]
    out += [f"#print axioms {c}" for c in order]
    out += ["", "end TinaV2.Assembly", ""]
    claim_of = lambda short: info[short]["claim"] if short in info else (
        db.execute("SELECT claim_id FROM formalizations WHERE lean_decl = ?",
                   (f"TinaV2.{short}.Statement",)).fetchone() or [short])[0]
    plan = {info[c]["claim"]: (info[c]["attempt"], ", ".join(claim_of(x) for x in unproved[c]))
            for c in order}
    return "\n".join(out), plan


def cmd_assembly(db, args):
    text, plan = assembly_plan(db)
    ASSEMBLY.write_text(text)
    old = {r["claim_id"]: r for r in db.execute("SELECT * FROM assembled")}
    db.execute("DELETE FROM assembled")
    for claim, (attempt, assumes) in plan.items():
        o = old.get(claim)
        keep = o is not None and o["attempt_id"] == attempt     # axioms belong to the attempt
        db.execute("INSERT INTO assembled (claim_id, attempt_id, assumes, axioms, standard, checked) "
                   "VALUES (?, ?, ?, ?, ?, ?)",
                   (claim, attempt, assumes, o["axioms"] if keep else None,
                    o["standard"] if keep else None, o["checked"] if keep else None))
    save(db)
    cond = {c: a for c, (_, a) in plan.items() if a}
    print(f"wrote {ASSEMBLY.relative_to(ROOT)}; {len(plan)} assembled theorems"
          + (f", conditional: {', '.join(f'{c} (on {a})' for c, a in sorted(cond.items()))}" if cond else ""))


AUDIT_LEAN = """import TinaV2.Assembly
open Lean Elab Command

/-- Constants of the attempt namespace `ns` that `n` uses, looking through
compiler-generated auxiliaries (`foo._proof_1`, `foo.match_1`, ...) but not
through other step lemmas. -/
partial def auditUses (env : Environment) (top : NameSet) (ns : Name) (n : Name)
    (seen : NameSet := {}) : NameSet := Id.run do
  let some ci := env.find? n | return seen
  let mut acc := seen
  let used := ci.type.getUsedConstants ++ ((ci.value? (allowOpaque := true)).map
    Expr.getUsedConstants).getD #[]
  for c in used do
    if acc.contains c then continue
    if top.contains c || (c.getPrefix != ns && !ns.isPrefixOf c
        && c.components.getLast? == some `Statement) then
      acc := acc.insert c
    else if ns.isPrefixOf c then
      acc := auditUses env top ns c (acc.insert c)
  return acc

run_cmd do
  let env ← getEnv
  let lemmas : List (Name × Name) := [%LEMMAS%]
  let top : NameSet := lemmas.foldl (fun s p => s.insert p.2) {}
  for (ns, n) in lemmas do
    if (env.find? n).isNone then
      logInfo m!"AUDIT-MISSING {n}"
    else
      let uses := (auditUses env top ns n).toList.filter fun c =>
        c != n && (top.contains c || c.components.getLast? == some `Statement)
      logInfo m!"AUDIT {n} := {uses}"

run_cmd do
  let thms : List Name := [%THEOREMS%]
  for n in thms do
    let ax ← Lean.collectAxioms n
    logInfo m!"AXIOMS {n} := {ax.toList}"
"""


def audit_selected(db, args):
    """Compare what each step lemma uses in Lean with what its paper step may use.

    For every selected proved attempt, Lean lists the step lemmas and the claim
    statements that each step lemma (and `main`) refers to. A step lemma may
    refer only to the steps and claims in `step_deps` for its step. The steps
    may belong to another claim's proof where `step_deps` says so (the paper's
    step cites an equation inside that proof); the map from Lean lemma to step
    covers every selected attempt, so such a use is compared like any other.
    """
    import tempfile
    q = lambda sql, *p: db.execute(sql, p).fetchall()
    attempts = q("SELECT a.id, a.proof_id, a.lean_file, f.claim_id, f.lean_decl FROM attempts a "
                 "JOIN formalizations f ON f.id = a.formalization_id "
                 "WHERE a.selected = 1 AND a.status = 'proved' ORDER BY a.id")
    lemmas, owner = [], {}          # owner: lean name -> (attempt row, step id or None)
    for a in attempts:
        src = (ROOT / a["lean_file"]).read_text()
        ns = re.search(r"^namespace\s+(\S+)", src, re.M).group(1)
        for m in q("SELECT step_id, lean_decl FROM step_map WHERE attempt_id = ?", a["id"]):
            lemmas.append((ns, m["lean_decl"]))
            owner[m["lean_decl"]] = (a, m["step_id"])
        lemmas.append((ns, ns + ".main"))
        owner[ns + ".main"] = (a, None)
    if not lemmas:
        print("no selected proved attempts")
        return []
    shorts = {a["claim_id"]: a["lean_decl"].split(".")[-2] for a in attempts}
    lean = (AUDIT_LEAN.replace("%LEMMAS%", ", ".join(f"(`{ns}, `{n})" for ns, n in lemmas))
            .replace("%THEOREMS%", ", ".join(f"`TinaV2.Assembly.{s}" for s in shorts.values())))
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "Audit.lean"
        f.write_text(lean)
        r = subprocess.run(["lake", "env", "lean", str(f)], cwd=ROOT, capture_output=True, text=True)
    out = r.stdout + r.stderr
    if r.returncode != 0:
        sys.exit("audit could not run (build first with `lake build TinaV2.Assembly`):\n" + out)
    stmt_claim = {r["lean_decl"]: r["claim_id"] for r in q("SELECT claim_id, lean_decl FROM formalizations")}
    errs, seen = [], 0
    for m in re.finditer(r"AUDIT-MISSING (\S+)", out):
        errs.append(f"{m.group(1)}: not found in the built project")
    for m in re.finditer(r"AUDIT (\S+) := \[(.*?)\]", out, re.S):
        seen += 1
        name, used = m.group(1), [u.strip() for u in m.group(2).replace("\n", " ").split(",") if u.strip()]
        a, step = owner[name]
        used_steps = {owner[u][1] for u in used if u in owner and owner[u][1]}
        used_claims = {stmt_claim.get(u, u) for u in used if u.endswith(".Statement")}
        # A proof file may be imported for a cross-proof step dependency. Its
        # `main` is never a step: a claim is used through its statement.
        for u in used:
            if u in owner and owner[u][1] is None and u != name:
                errs.append(f"{step or a['id'] + ' main'}: Lean lemma uses {u}, the finished proof of "
                            f"another claim; take the claim's statement as a hypothesis")
        if step is None:            # main: its own statement plus the claims its steps may use
            foreign = sorted(x for x in used_steps if not x.startswith(a["proof_id"] + "/"))
            if foreign:
                errs.append(f"{a['id']} main: uses steps {foreign} of another proof; only a step "
                            f"lemma may, through step_deps")
            allowed_claims = {a["claim_id"]} | {d["dep_id"] for d in q(
                "SELECT d.dep_id FROM step_deps d JOIN steps s ON s.id = d.step_id "
                "WHERE s.proof_id = ? AND d.dep_kind = 'claim'", a["proof_id"])}
            extra = used_claims - allowed_claims
            if extra:
                errs.append(f"{a['id']} main: uses claims {sorted(extra)} that no step of {a['proof_id']} may use")
            continue
        allowed_steps = {d["dep_id"] for d in q(
            "SELECT dep_id FROM step_deps WHERE step_id = ? AND dep_kind = 'step'", step)}
        # A claim that an earlier step rests on reaches this step through that
        # step (in Lean, as a hypothesis passed along), so claims are inherited.
        reach, todo = {step}, [step]
        while todo:
            for d in q("SELECT dep_id FROM step_deps WHERE step_id = ? AND dep_kind = 'step'", todo.pop()):
                if d["dep_id"] not in reach:
                    reach.add(d["dep_id"])
                    todo.append(d["dep_id"])
        allowed_claims = {d["dep_id"] for x in reach for d in q(
            "SELECT dep_id FROM step_deps WHERE step_id = ? AND dep_kind = 'claim'", x)}
        for x in sorted(used_steps - allowed_steps):
            errs.append(f"{step}: Lean lemma uses step {x}, which the paper step does not list")
        for x in sorted(used_claims - allowed_claims):
            errs.append(f"{step}: Lean lemma uses claim {x}, which the paper step does not list")
        if "-v" in args:
            unused = sorted((allowed_steps - used_steps) | (allowed_claims - used_claims))
            print(f"{step}: uses {sorted(used_steps | used_claims) or '-'}"
                  + (f"; listed but not used: {unused}" if unused else ""))
    # Axioms of each assembled theorem, recorded in `assembled`.
    axioms = {m.group(1): sorted(x.strip() for x in m.group(2).replace("\n", " ").split(",") if x.strip())
              for m in re.finditer(r"AXIOMS TinaV2\.Assembly\.(\S+) := \[(.*?)\]", out, re.S)}
    recorded = 0
    for claim, short in shorts.items():
        if short not in axioms:
            errs.append(f"{claim}: Lean did not report the axioms of Assembly.{short}")
            continue
        ax = axioms[short]
        ok = set(ax) <= STANDARD_AXIOMS
        if not ok:
            errs.append(f"{claim}: Assembly.{short} depends on {sorted(set(ax) - STANDARD_AXIOMS)}")
        n = db.execute("UPDATE assembled SET axioms = ?, standard = ?, checked = ? WHERE claim_id = ? "
                       "AND attempt_id = (SELECT a.id FROM attempts a JOIN formalizations f "
                       "ON f.id = a.formalization_id WHERE f.claim_id = ? AND a.selected = 1)",
                       (", ".join(ax), int(ok), now(), claim, claim)).rowcount
        if n != 1:
            errs.append(f"{claim}: no assembled record to store the axioms in: run `ledger.py assembly`")
        recorded += n
    for e in errs:
        print("ERROR  ", e)
    print(f"{seen} lemmas audited in {len(attempts)} attempts, axioms recorded for {recorded} "
          f"assembled theorems, {len(errs)} errors")
    return errs


def cmd_audit(db, args):
    errs = audit_selected(db, args)
    save(db)
    sys.exit(1 if errs else 0)


def cmd_headline(db, args):
    """The completion record for each advertised result."""
    table_out(db.execute(
        """SELECT id, label, state, stmt_status AS stmt, COALESCE(proof_home, '') AS home,
                  CASE WHEN n_steps IS NULL THEN ''
                       ELSE (n_steps - n_supplied) || ' paper + ' || n_supplied || ' supplied' END AS steps,
                  COALESCE(assumes, '') AS assumes,
                  CASE WHEN axioms IS NULL THEN '' ELSE axioms END AS axioms,
                  deltas || CASE WHEN narrower > 0 THEN ' (' || narrower || ' narrower)' ELSE '' END AS deltas,
                  CASE WHEN undecided > 0 THEN undecided || ' undecided ' ELSE '' END ||
                  CASE WHEN edits_awaited > 0 THEN edits_awaited || ' paper edit' ELSE '' END AS waits,
                  lean_decl
           FROM v_headline ORDER BY CAST(substr(id, 2) AS REAL), id"""), {"axioms": 44})
    print("\nstate: verified = follows the paper; verified_supplied = Lean supplies steps the paper "
          "omits;\nconditional = still assumes the claims under `assumes`. `deltas` counts recorded "
          "differences\nbetween the Lean statement and the paper's (`ledger.py show C7`).")


DECISIONS = [("undecided", "Waiting for a decision"),
             ("paper_edit", "The paper changes"),
             ("lean_supplies", "The paper stays; Lean supplies the argument"),
             ("reading", "The paper stays; the Lean statement fixes a reading"),
             ("leave", "The paper stays; nothing changes in Lean")]


def cmd_dispositions(db, args):
    """What was decided about each point: a table, or Markdown with --md."""
    where = "WHERE d.status = 'open'" if "--open" in args else ""
    rows = db.execute(
        f"""SELECT d.*, c.title AS claim_title FROM dispositions d JOIN claims c ON c.id = d.claim_id
            {where}""").fetchall()
    key = lambda r: [int(x) if x.isdigit() else x for x in re.split(r"(\d+)", r["id"])]
    rows.sort(key=key)
    if "--md" not in args:
        table_out([{k: r[k] for k in ("id", "claim_id", "level", "decision", "status", "decided_by", "point")}
                   for r in rows], {"point": 80, "decided_by": 24})
        print()
        table_out(db.execute("SELECT decision, status, COUNT(*) n FROM dispositions "
                             "GROUP BY decision, status ORDER BY decision, status"))
        return
    src = db.execute("SELECT git_commit FROM sources LIMIT 1").fetchone()
    print("# Dispositions: what was decided about each point the formalization raised\n")
    print("Generated by `python3 tools/ledger.py dispositions --md`; do not edit by hand. "
          f"Manuscript commit `{(src['git_commit'] or '?')[:7]}`. "
          "`F10.2` is item 2 of finding F10 in `paper-findings-2026-11-14.md`; "
          "`C8.c/d1` is a point on claim C8.c that has no finding, usually that the paper gives no proof.\n")
    cell = lambda v: (v or "").replace("|", "\\|").replace("\n", " ")
    for dec, title in DECISIONS:
        part = [r for r in rows if r["decision"] == dec]
        if not part:
            continue
        print(f"## {title} ({len(part)})\n")
        print("| Id | Claim | Point | Level | Status | Decided by | Reason |")
        print("|---|---|---|---|---|---|---|")
        for r in part:
            done = r["status"] + (f" ({r['resolved_commit'][:7]})" if r["resolved_commit"] else "")
            print(f"| {r['id']} | {r['claim_id']} {cell(r['claim_title'])} | {cell(r['point'])} | {r['level']} "
                  f"| {done} | {cell(r['decided_by'])} | {cell(r['rationale'])} |")
        print()


def cmd_supplement(db, args):
    """The written arguments that are not in the paper, as Markdown."""
    q = lambda sql, *p: db.execute(sql, p).fetchall()
    only = args[0] if args else None
    key = lambda r: [int(x) if x.isdigit() else x for x in re.split(r"(\d+)", r["claim_id"])]
    proofs = sorted(q("SELECT p.*, c.title FROM proofs p JOIN claims c ON c.id = p.claim_id "
                      "WHERE p.status = 'supplement' OR (p.status IN ('in_paper','proposed') AND EXISTS "
                      "(SELECT 1 FROM steps s WHERE s.proof_id = p.id AND s.origin = 'supplied'))"), key=key)
    proofs = [p for p in proofs if not only or p["claim_id"] == only]
    print("# Supplement: arguments the formalization supplies\n")
    print("Generated by `python3 tools/ledger.py supplement`. These proofs and steps are not in the "
          "paper. Each Lean lemma named below mirrors one step.\n")
    if not proofs:
        print("(none recorded)")
    for p in proofs:
        whole = p["status"] == "supplement"
        print(f"## {p['claim_id']} {p['title']} ({p['id']})\n")
        print(("The paper gives no proof. " if whole else "The paper's proof, with the supplied steps marked. ")
              + p["summary"] + "\n")
        for s in q("SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal", p["id"]):
            m = q("SELECT m.lean_decl, m.status FROM step_map m JOIN attempts a ON a.id = m.attempt_id "
                  "WHERE m.step_id = ? ORDER BY a.selected DESC", s["id"])
            lean = f"`{m[0]['lean_decl']}` ({m[0]['status']})" if m else "no Lean lemma yet"
            tag = "supplied" if s["origin"] == "supplied" else f"paper, {s['source']}:{s['line_start']}"
            deps = [d["dep_id"] for d in q("SELECT dep_id FROM step_deps WHERE step_id = ?", s["id"])]
            print(f"**Step {s['ordinal']} ({tag}). {s['title']}.** {s['tex'].strip()}\n")
            print(f"- Lean: {lean}" + (f"; uses {', '.join(deps)}" if deps else "") + "\n")
    routine = q("SELECT id, claim_id, point, lean_ref FROM dispositions "
                "WHERE decision = 'lean_supplies' AND lean_ref IS NOT NULL")
    routine = [r for r in routine if not only or r["claim_id"] == only]
    if routine:
        print("## Supplied through a routine lemma or inside an existing step lemma\n")
        for r in sorted(routine, key=key):
            print(f"- {r['id']} ({r['claim_id']}): {r['point']} Lean: `{r['lean_ref']}`")


DOCS = {"paper-findings-dispositions.md": lambda db: cmd_dispositions(db, ["--md"]),
        "supplement.md": lambda db: cmd_supplement(db, [])}


def doc_text(db, name):
    import contextlib
    import io
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        DOCS[name](db)
    return buf.getvalue()


def cmd_docs(db, args):
    """Write the two documents that are generated from the ledger."""
    for name in DOCS:
        (ROOT / name).write_text(doc_text(db, name))
        print(f"wrote {name}")


def cmd_db(db, args):
    path = Path(args[0]) if args else ROOT / "ledger" / "ledger.db"
    path.unlink(missing_ok=True)
    out = sqlite3.connect(path)
    db.backup(out)
    out.close()
    print(f"wrote {path} (a copy; changes made there are not saved to data.sql)")


# ------------------------------------------------------- progress explorer
# progress/ is a static page that loads ledger/*.sql into SQLite in the
# browser. It needs ../ledger and ../TinaV2 next to it, so the site mirrors
# this directory's layout. The build also renders the manuscript excerpts.
def build_info(db):
    def git(*a):
        try:
            return subprocess.run(["git", "-C", str(REPO), *a], capture_output=True,
                                  text=True, check=True).stdout.strip()
        except (OSError, subprocess.CalledProcessError):
            return None
    errs, warns = run_check(db)
    return {"repo": os.environ.get("GITHUB_REPOSITORY", "ANRGUSC/TINA"),
            "lean_dir": ROOT.relative_to(REPO).as_posix(),
            "commit": os.environ.get("GITHUB_SHA") or git("rev-parse", "HEAD"),
            "generated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "check": {"errors": errs, "warnings": warns}}


def cmd_site(db, args):
    if not args:
        sys.exit("usage: ledger.py site OUTDIR")
    out = Path(args[0]).resolve()
    if out == ROOT or ROOT in out.parents:
        sys.exit("OUTDIR must be outside the lean/ directory")
    for sub in ("progress", "ledger", "TinaV2"):
        if (out / sub).exists():
            shutil.rmtree(out / sub)
    shutil.copytree(ROOT / "progress", out / "progress")
    from reader_passages import build as build_passages
    build_passages(db, ROOT, REPO, out / "progress" / "paper-assets")
    (out / "ledger").mkdir(parents=True)
    for f in (SCHEMA, DATA):
        shutil.copy(f, out / "ledger" / f.name)
    n = 0
    for f in sorted((ROOT / "TinaV2").rglob("*.lean")):
        dest = out / f.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(f, dest)
        n += 1
    for r in db.execute("SELECT id, lean_file FROM formalizations WHERE status != 'superseded'"):
        if not (out / r["lean_file"]).is_file():
            sys.exit(f"{r['id']}: {r['lean_file']} is in the ledger but not in the site")
    info = build_info(db)
    if len(args) > 1:
        verification = json.loads(Path(args[1]).read_text(encoding="utf-8"))
        if not info["commit"] or verification["commit"] != info["commit"]:
            sys.exit("The Lean verification record and site must have the same commit.")
        info["verification"] = verification
    (out / "progress" / "build-info.json").write_text(json.dumps(info, indent=1))
    (out / "index.html").write_text(
        '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=progress/">'
        '<title>arXiv v3 Lean proof progress</title><a href="progress/">Lean proof progress</a>\n')
    c = info["check"]
    print(f"wrote {out}/progress/ ({n} Lean files; ledger check: "
          f"{len(c['errors'])} errors, {len(c['warnings'])} warnings)")


def cmd_serve(db, args):
    import functools
    import http.server
    import tempfile
    from reader_passages import build as build_passages
    port = int(args[0]) if args else 8642

    class Handler(http.server.SimpleHTTPRequestHandler):
        def translate_path(self, path):
            local = Path(super().translate_path(path))
            base = ROOT / "progress" / "paper-assets"
            if local.is_relative_to(base):
                return str(Path(cache.name) / local.relative_to(base))
            return str(local)

        def do_GET(self):
            if self.path.split("?")[0] == "/progress/build-info.json":
                body = json.dumps(build_info(connect())).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            else:
                super().do_GET()

        def end_headers(self):
            self.send_header("Cache-Control", "no-store")
            super().end_headers()

        def log_message(self, *a):
            pass

    Handler.extensions_map = {**Handler.extensions_map, ".wasm": "application/wasm",
                              ".sql": "text/plain; charset=utf-8", ".lean": "text/plain; charset=utf-8"}
    cache = tempfile.TemporaryDirectory()
    build_passages(db, ROOT, REPO, Path(cache.name))
    srv = http.server.ThreadingHTTPServer(
        ("127.0.0.1", port), functools.partial(Handler, directory=str(ROOT)))
    print(f"progress explorer: http://127.0.0.1:{port}/progress/   (Ctrl-C to stop; "
          f"reload the page after a ledger change)")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        srv.server_close()
        cache.cleanup()


COMMANDS = {"assembly": cmd_assembly, "audit": cmd_audit, "serve": cmd_serve, "site": cmd_site, "status": cmd_status, "show": cmd_show, "frontier": cmd_frontier,
            "sql": cmd_sql, "add": cmd_add, "set": cmd_set, "note": cmd_note,
            "check": cmd_check, "graph": cmd_graph, "edit-diff": cmd_edit_diff,
            "headline": cmd_headline, "dispositions": cmd_dispositions,
            "supplement": cmd_supplement, "docs": cmd_docs,
            "edit-apply": cmd_edit_apply, "db": cmd_db, "freeze": cmd_freeze, "unfreeze": cmd_unfreeze}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        sys.exit(__doc__)
    COMMANDS[sys.argv[1]](connect(), sys.argv[2:])
