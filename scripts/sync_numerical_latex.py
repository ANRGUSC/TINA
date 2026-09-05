"""Refresh or check standalone numerical TeX extracts against main.tex."""
from __future__ import annotations

import argparse
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def extracts(source: str) -> dict[str, str]:
    label = source.index(r"\label{sec:numerical-evaluation}")
    start = source.rfind(r"\section{", 0, label)
    end = source.index(r"\section{", label)
    section = source[start:end].strip()
    tables = re.findall(r"\\begin\{table\}.*?\\end\{table\}", section, re.S)
    figures = re.findall(r"\\begin\{figure\}.*?\\end\{figure\}", section, re.S)
    if len(tables) != 1 or len(figures) != 6:
        raise ValueError("expected one parameter table and six numerical figures")
    standalone = section.replace(tables[0], r"\input{numerics/latex/table_parameters}")

    def figure_paths(text: str) -> str:
        return text.replace("{figures/", "{numerics/figures/pdf/")

    return {
        "section7.tex": figure_paths(standalone) + "\n",
        "table_parameters.tex": tables[0] + "\n",
        "figures.tex": "% Generated numerical figure environments from main.tex.\n"
        + figure_paths("\n\n".join(figures)) + "\n",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check without writing")
    args = parser.parse_args()
    expected = extracts((ROOT / "main.tex").read_text(encoding="utf-8"))
    stale = []
    for name, text in expected.items():
        path = ROOT / "numerics/latex" / name
        if args.check:
            if not path.exists() or path.read_text(encoding="utf-8") != text:
                stale.append(name)
        else:
            path.write_text(text, encoding="utf-8")
    if stale:
        print("Stale TeX extracts: " + ", ".join(stale))
        print("Run python scripts/sync_numerical_latex.py to refresh them.")
        return 1
    print("Numerical TeX extracts " + ("match main.tex" if args.check else "refreshed"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
