"""Build the paper-to-proof guide from the v3 manuscript and its Lean ledger."""
from collections import Counter
from html import escape
from pathlib import Path
from string import Template
import re
import shutil
import sqlite3
import sys


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
LEAN = ROOT / "papers/arxiv-v3/lean"
GITHUB = "https://github.com/ANRGUSC/TINA"
PROOF_ROOT = f"{GITHUB}/blob/main/papers/arxiv-v3/lean"

# Printed page of the statement in tina-v3.pdf, reader summary, and pieces a
# reader may want to follow beyond the primary proof. Numbers and titles come
# from the TeX; the selected Lean attempt comes from the ledger.
RESULTS = {
    "C7": (6, "How much does delay cost when each agent sees only its neighborhood? A snapshot of the same neighborhood retains the square of the temporal prediction factor times its fresh value.",
           [("C7.b", "Normalized form, Eq. (10)")]),
    "C8": (7, "When every agent sees the complete old state, it can act on the predicted part of the current state. Only the innovation since the snapshot contributes to regret.",
           [("C8.c", "Small-delay expansion and large-delay limit"), ("C9", "Extension to modes with different decay rates")]),
    "C10": (8, "How old must a global snapshot be before a fresh local reading wins? The threshold depends on how much decision-relevant information the fresh local view omits. If it omits everything, the global view wins at every finite delay.",
            [("C10.b", "Zero threshold and the single crossing")]),
    "C12": (9, "When a quadratic penalty couples the agents through their total action, each agent’s best local action is its own reading divided by q + γ. The proposition computes the share of the full-information benefit lost under this rule.",
            [("C13", "Crossover threshold for the shared-resource model")]),
    "C15": (10, "At an interior optimum, the proportional gain from observing a wider region equals the proportional loss from waiting longer. The discussion following the proposition gives conditions for finding a unique optimum.",
            [("C15.b", "Unique optimum under a single crossing"), ("C15.c", "How coherence time and latency move the optimum")]),
    "C16": (11, "If spatial omission decays exponentially and delay grows linearly with radius, the optimum has a closed form. The proof covers a zero radius, a positive interior radius, and a cap on the observation range.", []),
    "C18": (12, "On the Gaussian line, observing a fresh interval leaves uncertainty in the two tails outside it. Predictions for each tail depend on the interval only through its nearest endpoint. This gives the exponential omission curve.", []),
    "C19": (12, "For the Gaussian line model, the best radius is positive exactly when vT > 2ℓₛ. The main proof combines the field’s delay law with Lemma 1 and Proposition 3. The theorem’s four parameter comparisons have a separate proof.",
            [("C19.b", "Items 1–4 · How the optimal radius varies"), ("C17.b", "Why the delay law holds for the field")]),
    "C1": (26, "Fix what each agent can observe. The unique best feasible policy is the weighted orthogonal projection of the full-information action onto the space of admissible policies. Regret is half the squared projection error.",
           [("C1.b", "Orthogonality and the Pythagorean identity")]),
    "C2": (26, "Each agent’s component of the cost gradient must have conditional mean zero given its own observations. These coupled equations characterize the team optimum.",
           [("C3", "Common observations and the conditional-mean policy")]),
}

GROUPS = [
    ("scope", "Section 3", "How scope and freshness combine", ["C7", "C8", "C10", "C12"]),
    ("radius", "Section 4", "Choosing the observation radius", ["C15", "C16", "C18", "C19"]),
    ("appendix", "Appendix A", "General formulation and fixed-architecture optimum", ["C1", "C2"]),
]


def build(output):
    db = sqlite3.connect(":memory:")
    db.row_factory = sqlite3.Row
    for name in ("schema", "data"):
        db.executescript((LEAN / f"ledger/{name}.sql").read_text(encoding="utf-8"))
    proofs = {row["id"]: row for row in db.execute("""
        SELECT c.id, c.label, c.headline, a.lean_file FROM claims c
        JOIN formalizations f ON f.claim_id = c.id
        JOIN attempts a ON a.formalization_id = f.id
        WHERE a.selected = 1 AND a.status = 'proved'
    """)}
    counts, headings = Counter(), {}
    by_label = {p["label"]: p["id"] for p in proofs.values() if p["headline"]}
    for s in db.execute("SELECT path FROM sources ORDER BY CASE id WHEN 'MAIN' THEN 0 ELSE 1 END"):
        tex = (ROOT / s["path"]).read_text(encoding="utf-8")
        for kind, title, label in re.findall(
            r"\\begin\{(theorem|proposition|lemma|corollary)\}\[([^\]]+)\]\s*\\label\{([^}]+)\}", tex
        ):
            counts[kind] += 1
            headings[by_label[label]] = (f"{kind.title()} {counts[kind]}", title)
    order = [claim for _, _, _, group in GROUPS for claim in group]
    if list(headings) != order or set(RESULTS) != set(order) or set(by_label.values()) != set(order):
        raise ValueError("The guide and the manuscript's numbered results disagree.")

    def proof_url(claim):
        path = proofs[claim]["lean_file"]
        if not (LEAN / path).is_file():
            raise FileNotFoundError(path)
        return f"{PROOF_ROOT}/{path}"

    sections, contents = [], []
    for anchor, section, heading, group in GROUPS:
        contents.append(f'<a href="#{anchor}"><span>{section}</span>{heading}</a>')
        articles = []
        for claim in group:
            number, title = headings[claim]
            page, summary, related = RESULTS[claim]
            links = "".join(f'<li><a href="{proof_url(c)}">{escape(text)}</a> <small>{c}</small></li>'
                            for c, text in related)
            details = f'<ul class="related">{links}</ul>' if links else ""
            articles.append(f'''<article id="{number.lower().replace(" ", "-")}">
  <div class="citation"><strong>{number}</strong><a href="tina-v3.pdf#page={page}">PDF p. {page}</a></div>
  <h3>{escape(title)}</h3><p>{escape(summary)}</p>
  <div class="actions"><a class="proof" href="{proof_url(claim)}">Read Lean proof <code>{claim}</code></a>
  <a href="https://anrgusc.github.io/TINA/arxiv-v3/lean/progress/#/claim/{claim}">Read the claim and proof sketch</a></div>
  {details}</article>''')
        sections.append(f'<section id="{anchor}"><div class="section-label">{section}</div>'
                        f'<h2>{heading}</h2>{"".join(articles)}</section>')
    output.mkdir(parents=True, exist_ok=True)
    template = Template((HERE / "guide.html").read_text(encoding="utf-8"))
    (output / "index.html").write_text(template.substitute(contents="".join(contents),
                                                          sections="".join(sections)), encoding="utf-8")
    shutil.copyfile(ROOT / "submissions/arxiv-v3/tina-v3.pdf", output / "tina-v3.pdf")
    print(f"Built {len(headings)} numbered results in {output}")


if __name__ == "__main__":
    build(Path(sys.argv[1]))
