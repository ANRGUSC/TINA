"""Render the published PDF pages and extract verbatim TeX for the claim reader."""
import hashlib
import json
import re


def build(db, root, repo, out):
    import pymupdf

    spec = json.loads((root / "progress/paper-passages.json").read_text(encoding="utf-8"))
    pdf = repo / "submissions/arxiv-v3/tina-v3.pdf"
    if hashlib.sha256(pdf.read_bytes()).hexdigest() != spec["pdf_sha256"]:
        raise ValueError("Review the passage locations against the new tina-v3.pdf.")
    claims = list(db.execute("SELECT id, source, line_start, line_end, scope FROM claims"))
    if set(spec["regions"]) != {r["id"] for r in claims}:
        raise ValueError("Every current claim needs a paper passage.")
    out.mkdir(parents=True, exist_ok=True)
    sources = {s["id"]: (repo / s["path"]).read_text(encoding="utf-8").splitlines()
               for s in db.execute("SELECT id, path FROM sources")}
    spans = {"C4.c": [("APP", 298, 312)], "C4.b": [("MAIN", 359, 361), ("APP", 313, 320)],
             "C3.c": [("APP", 277, 286), ("APP", 294, 296)],
             "C12": [("MAIN", 577, 627), ("APP", 324, 408)],
             "C18": [("MAIN", 872, 896), ("APP", 410, 487)],
             "C19": [("MAIN", 899, 939), ("APP", 489, 499)],
             "C19.b": [("MAIN", 899, 939), ("APP", 489, 499)],
             "C25": [("MAIN", 46, 48), ("MAIN", 137, 181)]}
    with pymupdf.open(pdf) as doc:
        pages = {p for regions in spec["regions"].values() for p, _, _ in regions}
        for n in pages:
            page = doc[n - 1]
            svg = page.get_svg_image(text_as_path=True)
            (out / f"page-{n}.svg").write_text(svg, encoding="utf-8")
        for claim in claims:
            key = claim["id"]
            extracts = spans.get(key, [(claim["source"], claim["line_start"], claim["line_end"])])
            record = {"regions": spec["regions"][key], "source": [
                {"file": file, "first": lo, "last": hi, "tex": "\n".join(sources[file][lo-1:hi])}
                for file, lo, hi in extracts]}
            if claim["scope"] == "lean":
                # Named environments supply their own statement boundary. For
                # inline claims, keep the surrounding hypotheses with the result.
                bounds = {"C3": (272, 275), "C4": (331, 350), "C5": (25, 68),
                          "C6": (311, 326), "C7.b": (379, 397), "C9": (473, 490),
                          "C11": (67, 86), "C14": (698, 721), "C17": (812, 852),
                          "C17.b": (854, 870), "C19.b": (916, 922)}
                file, lo, hi = extracts[0]
                lo, hi = bounds.get(key, (lo, hi))
                statement = "\n".join(sources[file][lo-1:hi])
                env = re.match(r"\\begin\{(theorem|corollary|proposition|lemma)\}(?:\[[^\]]*\])?", statement)
                if env:
                    statement = statement[env.end():].split(r"\end{" + env[1] + "}")[0]
                statement = re.sub(r"\\(?:subsection|paragraph)\*?\{[^}]*\}", "", statement)
                record["statement"] = statement.strip()
            # Include a complete line at boundaries that contain superscripts or tall glyphs.
            for region in record["regions"]:
                n, lo, hi = region
                lines = [line["bbox"] for b in doc[n-1].get_text("dict")["blocks"]
                         for line in b.get("lines", [])]
                region[1] = min([lo] + [b[1] - 1 for b in lines if b[1] < lo < b[3]])
                region[2] = max([hi] + [b[3] + 1 for b in lines if b[1] < hi < b[3]])
            (out / f"{key}.json").write_text(json.dumps(record, ensure_ascii=False), encoding="utf-8")
