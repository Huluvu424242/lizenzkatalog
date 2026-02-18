#!/usr/bin/env python3
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
import difflib

# ---------- repo root ----------
def find_repo_root(start: Path) -> Path:
    cur = start.resolve()
    for _ in range(12):
        if (cur / "lizenzkatalog").is_dir():
            return cur
        if (cur / ".git").exists():
            return cur
        cur = cur.parent
    raise RuntimeError("Could not find repo root (expected 'lizenzkatalog/' or '.git').")

REPO_ROOT = find_repo_root(Path(__file__).parent)

# ---------- tags / spdx ----------
SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
TAG_TOKEN_RE = re.compile(r"\[\[[^\]]+\]\]")  # any [[...]] token
SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

def http_get_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "lizenzkatalog-spdx-updater/1.1"})
    try:
        with urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode("utf-8"))
    except HTTPError as e:
        raise RuntimeError(f"HTTP error fetching {url}: {e.code} {e.reason}") from e
    except URLError as e:
        raise RuntimeError(f"Network error fetching {url}: {e.reason}") from e

def extract_spdx_id(full_text: str) -> str:
    m = SPDX_TAG_RE.search(full_text)
    if not m:
        raise ValueError('Missing required tag [[lic#spdx="..."]].')
    return m.group(1).strip()

def fetch_spdx_license_text(spdx_id: str) -> str:
    data = http_get_json(SPDX_LICENSE_JSON_URL.format(spdx_id=spdx_id))
    txt = data.get("licenseText")
    if not txt:
        raise RuntimeError(f"SPDX JSON for '{spdx_id}' has no 'licenseText'.")
    return txt

def strip_annotations(text: str) -> str:
    return TAG_TOKEN_RE.sub("", text)

def normalize_ws_plain(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def ws_fuzzy_regex(s: str) -> str:
    """
    Build regex for a normalized chunk where spaces become \s+.
    """
    esc = re.escape(s)
    return esc.replace(r"\ ", r"\s+")

def is_safe_chunk(chunk: str) -> bool:
    """
    Safe if:
    - no whitespace at all, OR
    - after removing spaces it's a single character (dash-like)
    """
    if not chunk:
        return False
    if any(c.isspace() for c in chunk):
        compact = "".join(c for c in chunk if not c.isspace())
        return len(compact) == 1
    return True

def compact_chunk(chunk: str) -> str:
    """Remove whitespace from chunk."""
    return "".join(c for c in chunk if not c.isspace())

@dataclass
class OpPatch:
    kind: str          # 'replace' | 'insert' | 'delete'
    left_ctx: str      # normalized
    right_ctx: str     # normalized
    a_chunk: str       # local normalized chunk (may include spaces)
    b_chunk: str       # spdx normalized chunk (may include spaces)

def compute_patches(local_full: str, spdx_text: str, ctx: int = 30) -> list[OpPatch]:
    local_norm = normalize_ws_plain(strip_annotations(local_full))
    spdx_norm = normalize_ws_plain(spdx_text)

    sm = difflib.SequenceMatcher(a=local_norm, b=spdx_norm, autojunk=False)
    patches: list[OpPatch] = []

    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag not in ("replace", "insert", "delete"):
            continue

        a_chunk = local_norm[i1:i2]
        b_chunk = spdx_norm[j1:j2]

        # For insert/delete, one side can be empty
        if tag == "insert":
            a_chunk = ""  # nothing in local at that point
        if tag == "delete":
            b_chunk = ""  # nothing in spdx at that point

        # Only do "small & safe" changes
        safe = is_safe_chunk(a_chunk) or is_safe_chunk(b_chunk)
        if not safe:
            continue

        left_ctx = local_norm[max(0, i1 - ctx):i1]
        right_ctx = local_norm[i2:i2 + ctx]

        patches.append(OpPatch(tag, left_ctx, right_ctx, a_chunk, b_chunk))

    # Deduplicate
    uniq = {}
    for p in patches:
        uniq[(p.kind, p.left_ctx, p.right_ctx, p.a_chunk, p.b_chunk)] = p
    return list(uniq.values())

def apply_patches(original: str, patches: list[OpPatch]) -> tuple[str, int, list[str]]:
    """
    Apply by finding the context window in ORIGINAL (tags may be in between),
    then doing a minimal edit inside that window.
    """
    updated = original
    applied = 0
    changes: list[str] = []

    # pattern that allows tags in between context/chunk
    tag_gap = r"(?:\s*\[\[[^\]]+\]\]\s*)*"

    for p in patches:
        # Build fuzzy context patterns
        left_pat = ws_fuzzy_regex(p.left_ctx) if p.left_ctx else ""
        right_pat = ws_fuzzy_regex(p.right_ctx) if p.right_ctx else ""

        # For "replace/delete", we want to locate the a_chunk in the window.
        # For "insert", we insert between left/right.
        a_comp = compact_chunk(p.a_chunk)
        b_comp = compact_chunk(p.b_chunk)

        # Build a window matcher: left + (optional token) + right
        # We match on the ORIGINAL text, but allow tags between parts.
        if p.kind == "insert":
            pattern = left_pat + tag_gap + right_pat
        else:
            # match left + a_chunk(compacted or exact) + right
            # allow whitespace variance around single-char patches
            if p.a_chunk and any(c.isspace() for c in p.a_chunk):
                # single char patch with surrounding spaces; match any whitespace around the char
                a_pat = r"\s*" + re.escape(a_comp) + r"\s*"
            else:
                a_pat = re.escape(a_comp if a_comp else p.a_chunk)
            pattern = left_pat + tag_gap + a_pat + tag_gap + right_pat

        m = re.search(pattern, updated)
        if not m:
            continue  # can't safely locate

        window = updated[m.start():m.end()]

        if p.kind == "replace":
            # Replace only the differing token/char inside window
            if a_comp and b_comp:
                # replace compact token first occurrence
                window2 = window.replace(a_comp, b_comp, 1)
                if window2 != window:
                    updated = updated[:m.start()] + window2 + updated[m.end():]
                    applied += 1
                    changes.append(f"replace '{a_comp}' -> '{b_comp}'")
            # else: skip

        elif p.kind == "delete":
            if a_comp:
                window2 = window.replace(a_comp, "", 1)
                if window2 != window:
                    updated = updated[:m.start()] + window2 + updated[m.end():]
                    applied += 1
                    changes.append(f"delete '{a_comp}'")
        elif p.kind == "insert":
            if b_comp:
                # Insert at boundary between left/right inside matched window:
                # simplest: insert before the right_ctx (if present), else append.
                if p.right_ctx:
                    # find right_ctx (fuzzy) inside window; insert before it
                    right_m = re.search(ws_fuzzy_regex(p.right_ctx), window)
                    if right_m:
                        ins_at = right_m.start()
                        window2 = window[:ins_at] + b_comp + window[ins_at:]
                        updated = updated[:m.start()] + window2 + updated[m.end():]
                        applied += 1
                        changes.append(f"insert '{b_comp}'")
                else:
                    # no right context, append
                    window2 = window + b_comp
                    updated = updated[:m.start()] + window2 + updated[m.end():]
                    applied += 1
                    changes.append(f"insert '{b_comp}'")

    return updated, applied, changes

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python src/tools/update_license_from_spdx.py <path-to-.liz>")
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.exists():
        print(f"ERROR: File not found: {path}")
        return 2

    original = path.read_text(encoding="utf-8", errors="replace")
    spdx_id = extract_spdx_id(original)
    spdx_text = fetch_spdx_license_text(spdx_id)

    patches = compute_patches(original, spdx_text)
    if not patches:
        print(f"{path.name}: No safe patches found (already OK or differences are large/whitespace-heavy).")
        return 0

    updated, applied, changes = apply_patches(original, patches)

    if applied == 0 or updated == original:
        print(f"{path.name}: Found candidate patches, but could not apply safely (context not found).")
        return 1

    backup = path.with_suffix(path.suffix + ".bak")
    backup.write_text(original, encoding="utf-8")
    path.write_text(updated, encoding="utf-8")

    print(f"{path.name}: Applied {applied} patch(es confirmed by context) to match SPDX '{spdx_id}'.")
    print(f"Backup written: {backup.name}")

    # show a few changes
    for c in changes[:15]:
        print(f"  - {c}")
    if len(changes) > 15:
        print(f"  ... ({len(changes)-15} more)")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
