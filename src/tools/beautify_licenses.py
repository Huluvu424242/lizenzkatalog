#!/usr/bin/env python3
"""
Beautifier for *.liz files:
- Reflows plain-text paragraphs to a configured width
- Preserves annotation tag lines ([[...]])
- Preserves preformatted blocks (indented/code-ish), ASCII art, lists, headings, URLs
- Can run on all files or on a list of files
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import textwrap
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CATALOG_DIR = REPO_ROOT / "lizenzkatalog"

TAG_LINE_RE = re.compile(r"^\s*\[\[[^\]]+\]\]\s*$")
TAG_BLOCK_RE = re.compile(r"\[\[.*?\]\]", re.DOTALL)
URL_RE = re.compile(r"https?://\S+")
BULLET_RE = re.compile(r"^\s*(?:[-*•]|(\d+)[\.\)])\s+")
HEADING_RE = re.compile(r"^[A-Z0-9][A-Z0-9\s\-\(\):]{8,}$")  # "THE SOFTWARE IS PROVIDED..." etc.
ASCII_ART_RE = re.compile(r"^[=\-*_/\\|]{6,}$")


def looks_preformatted(line: str) -> bool:
    # Indented lines are likely code/preformatted
    if line.startswith("    ") or line.startswith("\t"):
        return True
    # Contains a URL – keep as-is to avoid awkward wraps
    if URL_RE.search(line):
        return True
    # Obvious ASCII separators
    if ASCII_ART_RE.match(line.strip()):
        return True
    return False


def is_special_line(line: str) -> bool:
    s = line.rstrip("\n")
    if not s.strip():
        return True  # blank line
    if TAG_LINE_RE.match(s):
        return True
    if looks_preformatted(s):
        return True
    # Lots of ALLCAPS headings or boilerplate lines – keep as-is
    if HEADING_RE.match(s.strip()):
        return True
    return False


def wrap_paragraph(lines: list[str], width: int) -> list[str]:
    # Join paragraph lines with spaces (respect multiple spaces minimally)
    text = " ".join(l.strip() for l in lines).strip()
    if not text:
        return [""]

    filled = textwrap.fill(
        text,
        width=width,
        expand_tabs=False,
        replace_whitespace=True,
        drop_whitespace=True,
        break_long_words=False,
        break_on_hyphens=False,
    )
    return filled.splitlines()


def beautify_text(content: str, width: int) -> str:
    protected, blocks = protect_tag_blocks(content)

    src_lines = protected.splitlines()
    out: list[str] = []
    para_buf: list[str] = []

    def flush_para():
        nonlocal para_buf
        if para_buf:
            out.extend(wrap_paragraph(para_buf, width))
            para_buf = []

    for line in src_lines:
        s = line.rstrip("\n")

        # placeholders/tags etc wie gehabt...
        m = BULLET_RE.match(s)
        if m:
            flush_para()

            indent = re.match(r"\s*", s).group(0)
            # Bullet prefix (z.B. "a) " oder "1. ")
            prefix = s[len(indent):].split(maxsplit=1)[0] + " "
            rest = s[len(indent) + len(prefix):] if len(s) > len(indent) + len(prefix) else ""

            wrapped = textwrap.fill(
                rest,
                width=width,
                initial_indent=indent + prefix,
                subsequent_indent=indent + " " * len(prefix),
                break_long_words=False,
                break_on_hyphens=False,
            )
            out.extend(wrapped.splitlines())
            continue

        if is_special_line(line):
            flush_para()
            out.append(s)
        else:
            para_buf.append(line)

    flush_para()

    beautified = "\n".join(out).rstrip("\n") + "\n"
    return unprotect_tag_blocks(beautified, blocks)


def iter_target_files(paths: list[str], catalog_dir: Path) -> list[Path]:
    if paths:
        out: list[Path] = []
        for p in paths:
            path = (REPO_ROOT / p).resolve() if not Path(p).is_absolute() else Path(p)
            if path.is_dir():
                out.extend(sorted(path.glob("*.liz")))
            else:
                out.append(path)
        return out
    return sorted(catalog_dir.glob("*.liz"))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--width", type=int, default=int(os.getenv("LIZ_WRAP_WIDTH", "120")),
                    help="Target line width (default: env LIZ_WRAP_WIDTH or 120)")
    ap.add_argument("--catalog", type=str, default=str(DEFAULT_CATALOG_DIR),
                    help="Catalog directory (default: ./lizenzkatalog)")
    ap.add_argument("--check", action="store_true",
                    help="Do not modify files; exit 1 if any file would change")
    ap.add_argument("--files", nargs="*", default=[],
                    help="Optional list of files/dirs to process; default processes catalog dir")
    args = ap.parse_args()

    if args.width < 40:
        print("ERROR: width < 40 is too small for legal texts.", file=sys.stderr)
        return 2

    catalog_dir = Path(args.catalog).resolve()
    files = iter_target_files(args.files, catalog_dir)
    if not files:
        print("No .liz files found.")
        return 0

    changed: list[Path] = []
    for f in files:
        if not f.exists():
            print(f"SKIP missing: {f}")
            continue
        if f.suffix.lower() != ".liz":
            continue

        original = f.read_text(encoding="utf-8", errors="replace")
        beautified = beautify_text(original, args.width)

        if beautified != original:
            changed.append(f)
            if not args.check:
                f.write_text(beautified, encoding="utf-8")

    if args.check:
        if changed:
            print("Beautify check FAILED. Files would change:")
            for f in changed:
                print(f"- {f.relative_to(REPO_ROOT)}")
            return 1
        print("Beautify check OK.")
        return 0

    if changed:
        print(f"Beautified {len(changed)} file(s) to width={args.width}.")
    else:
        print("No changes needed.")
    return 0


def protect_tag_blocks(text: str):
    blocks = []

    def repl(m):
        blocks.append(m.group(0))
        return f"@@TAGBLOCK{len(blocks) - 1}@@"

    return TAG_BLOCK_RE.sub(repl, text), blocks


def unprotect_tag_blocks(text: str, blocks: list[str]) -> str:
    for i, b in enumerate(blocks):
        text = text.replace(f"@@TAGBLOCK{i}@@", b)
    return text


def beautify_preserving_tags(text: str, width: int = 120) -> str:
    protected, blocks = protect_tag_blocks(text)

    # Wichtig: NICHT "whitespace normalisieren" / join lines / split->join!
    # Nur wrap normale Textzeilen, aber lass Placeholder-Zeilen in Ruhe.
    out_lines = []
    for line in protected.splitlines(True):  # True = keep line endings
        stripped = line.strip()

        # Wenn die Zeile ein Platzhalter ist, exakt so lassen
        if stripped.startswith("@@TAGBLOCK") and stripped.endswith("@@"):
            out_lines.append(line)
            continue

        # Optional: Fließtext wrap (nur wenn du wirklich willst)
        if stripped and len(stripped) > width:
            # Preserve indentation
            indent = re.match(r"\s*", line).group(0)
            wrapped = textwrap.fill(
                stripped,
                width=width,
                subsequent_indent=indent,
                break_long_words=False,
                break_on_hyphens=False
            )
            out_lines.append(indent + wrapped + ("\n" if not wrapped.endswith("\n") else ""))
        else:
            out_lines.append(line)

    beautified = "".join(out_lines)
    return unprotect_tag_blocks(beautified, blocks)


if __name__ == "__main__":
    raise SystemExit(main())
