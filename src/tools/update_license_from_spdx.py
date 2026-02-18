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
TAG_TOKEN_RE = re.compile(r"\[\[[^\]]+\]\]")
SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

def strip_annotations(text: str) -> str:
    """
    Remove all annotation tokens of the form [[...]].
    Keeps all other content unchanged.
    """
    return TAG_TOKEN_RE.sub("", text)


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
    local_token: str
    spdx_token: str
    context_left: str
    context_right: str


def compute_token_patches(local_full: str, spdx_text: str) -> list[Patch]:
    local_norm = normalize_ws_plain(strip_annotations(local_full))
    spdx_norm = normalize_ws_plain(spdx_text)

    sm = difflib.SequenceMatcher(a=local_norm, b=spdx_norm, autojunk=False)
    patches: list[Patch] = []

    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != "replace":
            continue

        local_seg = local_norm[i1:i2]
        spdx_seg = spdx_norm[j1:j2]

        # Only token-like patches (no spaces) to preserve formatting
        if not local_seg or not spdx_seg:
            continue
        if contains_whitespace(local_seg) or contains_whitespace(spdx_seg):
            continue

        # Capture small context around the token in normalized space
        left = local_norm[max(0, i1 - 25):i1]
        right = local_norm[i2:i2 + 25]

        patches.append(Patch(
            local_token=local_seg,
            spdx_token=spdx_seg,
            context_left=left,
            context_right=right
        ))

    # dedupe
    uniq = {}
    for p in patches:
        uniq[(p.local_token, p.spdx_token, p.context_left, p.context_right)] = p
    return list(uniq.values())


def apply_patches(text: str, patches: list[Patch]) -> tuple[str, int]:
    updated = text
    applied = 0

    # Apply in any order; each patch is anchored by context
    for p in patches:
        # Build a regex that matches:
        #   <context_left> ... <local_token> ... <context_right>
        # but allow any whitespace variability inside the context
        def ws_fuzzy(s: str) -> str:
            # escape and replace spaces with \s+
            s = re.escape(s)
            s = s.replace(r"\ ", r"\s+")
            return s

        left_pat = ws_fuzzy(p.context_left[-25:])  # keep small
        right_pat = ws_fuzzy(p.context_right[:25])

        # We also ignore tags between context and token by allowing optional tag tokens
        tag_pat = r"(?:\[\[[^\]]+\]\]\s*)*"

        pattern = (
                left_pat +
                tag_pat +
                re.escape(p.local_token) +
                tag_pat +
                right_pat
        )

        m = re.search(pattern, updated)
        if not m:
            # Fallback: replace first exact token occurrence outside tags (safer than breaking text)
            # We'll do a conservative non-tag replacement:
            updated2, n = replace_token_outside_tags(updated, p.local_token, p.spdx_token, max_repl=1)
            if n:
                updated = updated2
                applied += 1
            continue

        # Replace only the token inside the matched window, preserve everything else
        window = updated[m.start():m.end()]
        window2 = window.replace(p.local_token, p.spdx_token, 1)
        updated = updated[:m.start()] + window2 + updated[m.end():]
        applied += 1

    return updated, applied


def replace_token_outside_tags(text: str, old: str, new: str, max_repl: int = 1) -> tuple[str, int]:
    """
    Replace token occurrences that are not inside [[...]] tags.
    Simple scanner that skips tag ranges.
    """
    out = []
    i = 0
    n = 0
    L = len(text)

    while i < L:
        if text.startswith("[[", i):
            m = TAG_TOKEN_RE.match(text, i)
            if m:
                out.append(text[i:m.end()])
                i = m.end()
                continue

        if n < max_repl and text.startswith(old, i):
            out.append(new)
            i += len(old)
            n += 1
        else:
            out.append(text[i])
            i += 1

    return "".join(out), n

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
