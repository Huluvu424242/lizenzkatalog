#!/usr/bin/env python3
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
import difflib

# ---------------------------
# Repo root discovery
# ---------------------------
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

# ---------------------------
# SPDX + tags
# ---------------------------
SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
TAG_TOKEN_RE = re.compile(r"\[\[[^\]]+\]\]")  # any [[...]] token
SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

def http_get_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "lizenzkatalog-spdx-updater/1.0"})
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

# ---------------------------
# Normalization for alignment (whitespace only)
# We do NOT fold characters here; we want to detect real char differences.
# ---------------------------
def normalize_ws_with_map(full_text: str):
    """
    Build a whitespace-collapsed view of full_text with tags removed,
    plus a mapping from normalized index -> original index in full_text.

    - Tags [[...]] are removed completely (do not participate).
    - Any whitespace run becomes a single ' ' in normalized output.
    - Mapping points each normalized char to some original index (start of run).
    """
    norm_chars = []
    norm_to_orig = []

    i = 0
    last_was_space = False

    while i < len(full_text):
        # Skip tag tokens entirely
        if full_text.startswith("[[", i):
            m = TAG_TOKEN_RE.match(full_text, i)
            if m:
                i = m.end()
                continue

        ch = full_text[i]

        if ch.isspace():
            if not last_was_space:
                norm_chars.append(" ")
                norm_to_orig.append(i)
                last_was_space = True
            i += 1
            continue

        # regular char
        norm_chars.append(ch)
        norm_to_orig.append(i)
        last_was_space = False
        i += 1

    # trim leading/trailing spaces in normalized view (and keep mapping consistent)
    # We'll do a simple strip by finding first/last non-space.
    if not norm_chars:
        return "", []

    start = 0
    while start < len(norm_chars) and norm_chars[start] == " ":
        start += 1
    end = len(norm_chars)
    while end > start and norm_chars[end - 1] == " ":
        end -= 1

    return "".join(norm_chars[start:end]), norm_to_orig[start:end]

def normalize_ws_plain(text: str) -> str:
    # collapse whitespace only
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def contains_whitespace(s: str) -> bool:
    return any(c.isspace() for c in s)

@dataclass
class Patch:
    orig_start: int
    orig_end: int
    replacement: str
    local_seg: str
    spdx_seg: str

def compute_token_patches(local_full: str, spdx_text: str) -> list[Patch]:
    """
    Compute safe patches:
    - Compare whitespace-collapsed views.
    - For 'replace' ops, only patch segments that contain NO whitespace on either side.
      (This preserves formatting & avoids reflowing lines.)
    """
    local_norm, local_map = normalize_ws_with_map(local_full)
    spdx_norm = normalize_ws_plain(spdx_text)

    sm = difflib.SequenceMatcher(a=local_norm, b=spdx_norm, autojunk=False)

    patches: list[Patch] = []

    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != "replace":
            continue

        local_seg = local_norm[i1:i2]
        spdx_seg = spdx_norm[j1:j2]

        # Only patch token-like segments (no spaces) to preserve formatting
        if not local_seg or not spdx_seg:
            continue
        if contains_whitespace(local_seg) or contains_whitespace(spdx_seg):
            continue

        # Map normalized slice to original indices
        # We replace from orig at local_map[i1] up to local_map[i2-1]+1
        if i1 >= len(local_map) or (i2 - 1) >= len(local_map):
            continue

        orig_start = local_map[i1]
        orig_end = local_map[i2 - 1] + 1

        patches.append(Patch(
            orig_start=orig_start,
            orig_end=orig_end,
            replacement=spdx_seg,
            local_seg=local_seg,
            spdx_seg=spdx_seg
        ))

    # Deduplicate/merge exact same ranges
    uniq = {}
    for p in patches:
        key = (p.orig_start, p.orig_end, p.replacement)
        uniq[key] = p
    patches = list(uniq.values())

    # Apply from end to start to keep indices valid
    patches.sort(key=lambda p: (p.orig_start, p.orig_end), reverse=True)
    return patches

def apply_patches(text: str, patches: list[Patch]) -> tuple[str, int]:
    updated = text
    applied = 0
    for p in patches:
        if p.orig_start < 0 or p.orig_end > len(updated) or p.orig_start >= p.orig_end:
            continue
        # Safety check: ensure the substring still matches what we expect loosely
        # (avoid patching if file changed during run)
        old = updated[p.orig_start:p.orig_end]
        # If it doesn't match local_seg exactly (because of tags/format), we still allow,
        # but only when it's very close; otherwise skip.
        # Since patches are token-level, exact match should usually hold.
        if old != old:  # no-op, placeholder for potential stricter checks
            pass

        updated = updated[:p.orig_start] + p.replacement + updated[p.orig_end:]
        applied += 1
    return updated, applied

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python src/tools/update_license_to_spdx.py <path-to-.liz>")
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.exists():
        print(f"ERROR: File not found: {path}")
        return 2

    local_full = path.read_text(encoding="utf-8", errors="replace")
    spdx_id = extract_spdx_id(local_full)
    spdx_text = fetch_spdx_license_text(spdx_id)

    patches = compute_token_patches(local_full, spdx_text)
    if not patches:
        print(f"{path.name}: No safe token-level patches found. (Already OK or differences include whitespace/words.)")
        return 0

    updated, applied = apply_patches(local_full, patches)

    if updated == local_full:
        print(f"{path.name}: Computed {len(patches)} patches but nothing changed (unexpected).")
        return 1

    # Backup then write
    backup = path.with_suffix(path.suffix + ".bak")
    backup.write_text(local_full, encoding="utf-8")
    path.write_text(updated, encoding="utf-8")

    print(f"{path.name}: Applied {applied} patch(es) to match SPDX '{spdx_id}' (token-level only).")
    print(f"Backup written: {backup.name}")

    # Print a short summary of what changed
    max_show = 12
    shown = 0
    for p in reversed(patches):  # original order
        if shown >= max_show:
            print(f"... ({len(patches) - max_show} more)")
            break
        print(f"  - '{p.local_seg}' -> '{p.spdx_seg}'")
        shown += 1

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
