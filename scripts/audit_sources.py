"""Audit the manuscript's local compile closure and bibliography keys."""
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEX = ROOT / "main.tex"
BIB = ROOT / "references.bib"


def active_tex(text: str) -> str:
    r"""Remove comments and simple top-level \iffalse blocks."""
    kept: list[str] = []
    inactive = 0
    for line in text.splitlines():
        code = re.sub(r"(?<!\\)%.*", "", line)
        if re.match(r"^\s*\\iffalse\b", code):
            inactive += 1
            continue
        if inactive and re.match(r"^\s*\\fi\b", code):
            inactive -= 1
            continue
        if not inactive:
            kept.append(code)
    if inactive:
        raise ValueError("unclosed \\iffalse block in main.tex")
    return "\n".join(kept)


def values(pattern: str, text: str) -> list[str]:
    return [item.strip() for group in re.findall(pattern, text, re.S)
            for item in group.split(",") if item.strip()]


def main() -> int:
    source = active_tex(TEX.read_text(encoding="utf-8"))
    bib_text = BIB.read_text(encoding="utf-8")
    citations = set(values(r"\\cite(?:\[[^]]*\])?\{([^}]*)\}", source))
    bib_keys = re.findall(r"@\w+\s*\{\s*([^,\s]+)\s*,", bib_text)
    duplicate_keys = sorted({key for key in bib_keys if bib_keys.count(key) > 1})
    missing_keys = sorted(citations - set(bib_keys))

    graphics = values(r"\\includegraphics(?:\[[^]]*\])?\{([^}]*)\}", source)
    missing_graphics: list[str] = []
    resolved_graphics: list[Path] = []
    for graphic in graphics:
        path = ROOT / graphic
        candidates = [path] if path.suffix else [path.with_suffix(ext) for ext in (".pdf", ".png", ".jpg")]
        match = next((candidate for candidate in candidates if candidate.is_file()), None)
        if match is None:
            missing_graphics.append(graphic)
        else:
            resolved_graphics.append(match)

    bibliographies = values(r"\\bibliography\{([^}]*)\}", source)
    missing_bibs = [name for name in bibliographies if not (ROOT / f"{name}.bib").is_file()]

    print(f"active citations: {len(citations)}")
    print(f"bibliography entries: {len(bib_keys)}")
    print(f"graphics: {len(resolved_graphics)}")
    print("compile closure:")
    for path in [TEX, BIB, *resolved_graphics]:
        print(f"  {path.relative_to(ROOT)}")

    failures = {
        "missing citation keys": missing_keys,
        "duplicate bibliography keys": duplicate_keys,
        "missing graphics": missing_graphics,
        "missing bibliography files": missing_bibs,
    }
    failed = False
    for label, items in failures.items():
        if items:
            failed = True
            print(f"ERROR {label}: {', '.join(items)}", file=sys.stderr)
    if failed:
        return 1
    print("source audit passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
