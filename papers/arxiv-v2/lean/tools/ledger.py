#!/usr/bin/env python3
"""Proof ledger CLI for the tina-v2-alt Lean formalization.

The ledger is a SQLite database rebuilt in memory on every call from two text
files that are committed to git:

    ledger/schema.sql   tables and views
    ledger/data.sql     one INSERT per row (the source of truth)

Mutating commands rewrite data.sql, so every change is a readable git diff.

    ledger.py status                 one line per claim
    ledger.py show C7                a claim with its proofs, steps, attempts,
                                     edits, findings and notes (also C7/p1,
                                     C7/p1/s2, C7/a1, E1, F1)
    ledger.py frontier               claims ready to prove
    ledger.py sql "SELECT ..."       ad-hoc query
    ledger.py add TABLE k=v ...      insert a row (v may be @path to read a file)
    ledger.py set TABLE ID k=v ...   update a row
    ledger.py note TARGET KIND TEXT  append to the log
    ledger.py check                  verify ledger <-> paper <-> Lean invariants
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
          "step_deps", "formalizations", "attempts", "step_map", "edits",
          "edit_deps", "hunks", "hunk_steps", "findings", "notes"]


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
        f"""SELECT id, kind, tier, state, paper_proof AS proof,
                   stmt_status AS stmt, attempt_id AS attempt,
                   CASE WHEN n_steps IS NULL THEN ''
                        ELSE n_steps_proved || '/' || n_steps END AS steps,
                   open_findings AS finds, title
            FROM v_claim_status {where} ORDER BY
              CAST(substr(id, 2) AS REAL), id"""), {"title": 58})
    print()
    table_out(db.execute(
        "SELECT state, COUNT(*) AS n FROM v_claim_status GROUP BY state ORDER BY n DESC"))


def kind_of(ident):
    if re.fullmatch(r"E\d+", ident): return "edits"
    if re.fullmatch(r"E\d+/h\d+", ident): return "hunks"
    if re.fullmatch(r"F\d+", ident): return "findings"
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
            ("lean attempts", "SELECT a.id, a.status, a.selected AS sel, a.proof_id, a.parent, a.strategy "
                              "FROM attempts a JOIN formalizations f ON f.id = a.formalization_id WHERE f.claim_id = ?"),
            ("paper edits", "SELECT id, target, status, from_proof, to_proof, reason FROM edits WHERE claim_id = ?"),
            ("findings", "SELECT id, severity, status, title FROM findings WHERE claim_id = ?"),
        ]:
            rows = q(sql, ident)
            if rows:
                print(f"\n== {title}")
                table_out(rows, {"summary": 70, "strategy": 70, "reason": 70, "note": 70,
                                 "fidelity": 2000})
    elif t == "proofs":
        print("\n== steps")
        for s in q("SELECT * FROM steps WHERE proof_id = ? ORDER BY ordinal", ident):
            deps = [d["dep_id"] for d in q("SELECT dep_id FROM step_deps WHERE step_id = ?", s["id"])]
            maps = q("SELECT attempt_id, lean_decl, status FROM step_map WHERE step_id = ?", s["id"])
            print(f"{s['id']}  [{s['source']}:{s['line_start']}-{s['line_end']}]  {s['title']}")
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

    for s in q("SELECT * FROM sources"):
        if not (REPO / s["path"]).exists():
            errs.append(f"{s['id']}: {s['path']} does not exist (renamed or removed since "
                        f"the ledger was aligned at {(s['git_commit'] or '?')[:7]})")
        elif hashlib.sha256((REPO / s["path"]).read_bytes()).hexdigest() != s["sha256"]:
            warns.append(f"{s['id']}: {s['path']} changed since the ledger was aligned "
                         f"(excerpt checks below decide whether that matters)")

    # 1. Every step of a proof that is in the paper is verbatim in the paper.
    for s in q("SELECT s.* FROM steps s JOIN proofs p ON p.id = s.proof_id "
               "WHERE p.status = 'in_paper'"):
        if norm(s["tex"]) not in norm(source_text(db, s["source"])):
            errs.append(f"{s['id']}: step text no longer found in {s['source']}")

    # 2. One primary in-paper proof per claim.
    for r in q("SELECT claim_id, COUNT(*) n FROM proofs WHERE status = 'in_paper' "
               "AND is_primary = 1 GROUP BY claim_id HAVING n > 1"):
        errs.append(f"{r['claim_id']}: {r['n']} primary in-paper proofs")

    # 3. Step dependencies resolve, and point backwards within a proof.
    for d in q("SELECT d.*, s.proof_id, s.ordinal FROM step_deps d JOIN steps s ON s.id = d.step_id"):
        if d["dep_kind"] == "claim":
            if not q("SELECT 1 FROM claims WHERE id = ?", d["dep_id"]):
                errs.append(f"{d['step_id']}: unknown claim dependency {d['dep_id']}")
        else:
            o = q("SELECT proof_id, ordinal FROM steps WHERE id = ?", d["dep_id"])
            if not o or o[0]["proof_id"] != d["proof_id"] or o[0]["ordinal"] >= d["ordinal"]:
                errs.append(f"{d['step_id']}: step dependency {d['dep_id']} is not an earlier step of the same proof")

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
            errs.append(f"{a['id']}: paper step {sid} has no Lean lemma")
        for sid in sorted(maps.keys() - steps):
            errs.append(f"{a['id']}: Lean lemma {maps[sid]['lean_decl']} maps to {sid}, "
                        f"which is not a step of {a['proof_id']}")
        mapped = {m["lean_decl"].split(".")[-1] for m in maps.values()}
        for name in sorted(mapped - decls):
            errs.append(f"{a['id']}: {name} is in the step map but not in {a['lean_file']}")
        extra = sorted(decls - mapped - {"main"})
        if extra:
            errs.append(f"{a['id']}: Lean lemmas with no paper step: {', '.join(extra)} "
                        f"(move to Routine/ or add a paper step through an edit)")
        if a["status"] == "proved":
            if re.search(r"\b(sorry|admit)\b", src):
                errs.append(f"{a['id']}: marked proved but {a['lean_file']} contains sorry")
            for m in maps.values():
                if m["status"] != "proved":
                    errs.append(f"{a['id']}: marked proved but step {m['step_id']} is {m['status']}")

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
    style = {"verified": ":::ok", "needs_paper_edit": ":::edit", "proving": ":::wip"}
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
# this directory's layout. build-info.json is the only generated file.
def build_info(db):
    def git(*a):
        try:
            return subprocess.run(["git", "-C", str(REPO), *a], capture_output=True,
                                  text=True, check=True).stdout.strip()
        except (OSError, subprocess.CalledProcessError):
            return None
    errs, warns = run_check(db)
    return {"repo": os.environ.get("GITHUB_REPOSITORY", "ANRGUSC/TINA"),
            "lean_dir": str(ROOT.relative_to(REPO)),
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
    (out / "progress" / "build-info.json").write_text(json.dumps(info, indent=1))
    (out / "index.html").write_text(
        '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=progress/">'
        '<title>arXiv v2 Lean proof progress</title><a href="progress/">Lean proof progress</a>\n')
    c = info["check"]
    print(f"wrote {out}/progress/ ({n} Lean files; ledger check: "
          f"{len(c['errors'])} errors, {len(c['warnings'])} warnings)")


def cmd_serve(db, args):
    import functools
    import http.server
    port = int(args[0]) if args else 8642

    class Handler(http.server.SimpleHTTPRequestHandler):
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
    srv = http.server.ThreadingHTTPServer(
        ("127.0.0.1", port), functools.partial(Handler, directory=str(ROOT)))
    print(f"progress explorer: http://127.0.0.1:{port}/progress/   (Ctrl-C to stop; "
          f"reload the page after a ledger change)")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


COMMANDS = {"serve": cmd_serve, "site": cmd_site, "status": cmd_status, "show": cmd_show, "frontier": cmd_frontier,
            "sql": cmd_sql, "add": cmd_add, "set": cmd_set, "note": cmd_note,
            "check": cmd_check, "graph": cmd_graph, "edit-diff": cmd_edit_diff,
            "edit-apply": cmd_edit_apply, "db": cmd_db}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        sys.exit(__doc__)
    COMMANDS[sys.argv[1]](connect(), sys.argv[2:])
