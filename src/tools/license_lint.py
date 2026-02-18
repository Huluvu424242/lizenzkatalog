#!/usr/bin/env python3
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
TAG_TOKEN_RE = re.compile(r"\[\[[^\]]+\]\]")  # any [[...]]
OPEN_BLOCK_RE = re.compile(r"\[\[([a-z]{3})#([a-z]{1,10})\]\]")       # [[abc#key]]
CLOSE_BLOCK_RE = re.compile(r"\[\[\/([a-z]{3})#([a-z]{1,10})\]\]")   # [[/abc#key]]

def extract_spdx_id(text: str) -> str | None:
    m = SPDX_TAG_RE.search(text)
    return m.group(1).strip() if m else None

def lint_file(path: Path) -> list[str]:
    errors: list[str] = []
    txt = path.read_text(encoding="utf-8", errors="replace")

    # 1) SPDX required
    spdx = extract_spdx_id(txt)
    if not spdx:
        errors.append("Missing required tag [[lic#spdx=\"...\"]].")
        return errors

    # 2) Filename must match SPDX
    expected = f"{spdx}.liz"
    if path.name != expected:
        errors.append(f"Filename mismatch: expected '{expected}' (from lic#spdx), got '{path.name}'.")

    # 3) Basic bracket sanity: count [[ and ]]
    # (not perfect, but catches common corruption)
    if txt.count("[[") != txt.count("]]"):
        errors.append("Unbalanced tag brackets: count('[[') != count(']]').")

    # 4) Block tag balancing
    # We scan tags in order and maintain a stack for [[area#key]] ... [[/area#key]]
    stack: list[tuple[str, str]] = []
    for token in TAG_TOKEN_RE.findall(txt):
        m_open = OPEN_BLOCK_RE.fullmatch(token)
        if m_open:
            stack.append((m_open.group(1), m_open.group(2)))
            continue
        m_close = CLOSE_BLOCK_RE.fullmatch(token)
        if m_close:
            closing = (m_close.group(1), m_close.group(2))
            if not stack:
                errors.append(f"Closing block without opener: {token}")
                continue
            opening = stack.pop()
            if opening != closing:
                errors.append(f"Mismatched block close: opened [[{opening[0]}#{opening[1]}]] but closed {token}")
            continue

    if stack:
        # report remaining open blocks (limit to first few)
        preview = ", ".join([f"[[{a}#{k}]]" for a, k in stack[:5]])
        errors.append(f"Unclosed block tags: {preview}" + (" ..." if len(stack) > 5 else ""))

    return errors

def main() -> int:
    if not CATALOG_DIR.exists():
        print(f"ERROR: Missing directory: {CATALOG_DIR}")
        return 2

    files = sorted(CATALOG_DIR.glob("*.liz"))
    if not files:
        print("No .liz files found.")
        return 0

    all_errors: list[str] = []

    spdx_seen: dict[str, Path] = {}
    for p in files:
        txt = p.read_text(encoding="utf-8", errors="replace")
        spdx = extract_spdx_id(txt)
        if spdx:
            if spdx in spdx_seen:
                all_errors.append(
                    f"{p.name}: Duplicate lic#spdx '{spdx}' already used by {spdx_seen[spdx].name}"
                )
            else:
                spdx_seen[spdx] = p

        errs = lint_file(p)
        for e in errs:
            all_errors.append(f"{p.name}: {e}")

    if all_errors:
        print("License lint FAILED:\n")
        for e in all_errors:
            print(f"- {e}")
        print(f"\nTotal errors: {len(all_errors)}")
        return 1

    print(f"License lint OK ({len(files)} file(s)).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
