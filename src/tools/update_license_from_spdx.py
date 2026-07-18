#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError

# --- Repo root discovery ---
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

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
TAG_TOKEN_RE = re.compile(r"\[\[[^\]]+\]\]")
SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

DASHLIKE = {"-", "–", "—", "−"}
# You can extend similarly for quotes/ellipsis later if needed.

def http_get_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "lizenzkatalog-fix/1.0"})
    try:
        with urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode("utf-8"))
    except HTTPError as e:
        raise RuntimeError(f"HTTP error fetching {url}: {e.code} {e.reason}") from e
    except URLError as e:
        raise RuntimeError(f"Network error fetching {url}: {e.reason}") from e

def extract_spdx_id(text: str) -> str:
    m = SPDX_TAG_RE.search(text)
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

def normalize_ws(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def mismatch_score(local_full: str, spdx_text: str) -> int:
    """
    Simple score: number of positions where normalized strings differ + length delta.
    Lower is better. Fast and deterministic.
    """
    a = normalize_ws(strip_annotations(local_full))
    b = normalize_ws(spdx_text)
    n = min(len(a), len(b))
    diffs = sum(1 for i in range(n) if a[i] != b[i])
    diffs += abs(len(a) - len(b))
    return diffs

def iter_outside_tag_positions(text: str):
    """
    Yield positions i that are outside [[...]] tags.
    """
    i = 0
    L = len(text)
    while i < L:
        if text.startswith("[[", i):
            m = TAG_TOKEN_RE.match(text, i)
            if m:
                i = m.end()
                continue
        yield i
        i += 1

def replace_at(text: str, idx: int, new_ch: str) -> str:
    return text[:idx] + new_ch + text[idx + 1:]

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python src/tools/fix_single_char_mismatches.py <path-to-.liz>")
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.exists():
        print(f"ERROR: File not found: {path}")
        return 2

    original = path.read_text(encoding="utf-8", errors="replace")
    spdx_id = extract_spdx_id(original)
    spdx_text = fetch_spdx_license_text(spdx_id)

    base_score = mismatch_score(original, spdx_text)
    if base_score == 0:
        print(f"{path.name}: Already matches SPDX after whitespace normalization.")
        return 0

    best = original
    best_score = base_score
    changes = []

    # We try single-character flips among dash-like characters
    for i in iter_outside_tag_positions(original):
        ch = original[i]
        if ch not in DASHLIKE:
            continue

        # Try replacing with other dashlike chars
        for cand in DASHLIKE:
            if cand == ch:
                continue
            trial = replace_at(best, i, cand)
            s = mismatch_score(trial, spdx_text)
            if s < best_score:
                changes.append((i, ch, cand, best_score, s))
                best = trial
                best_score = s
                # Greedy improvement: keep going from improved text

        # Early exit if we hit perfect match
        if best_score == 0:
            break

    if best_score >= base_score:
        print(f"{path.name}: No improving single-char dash fixes found. (score {base_score} -> {best_score})")
        return 1

    backup = path.with_suffix(path.suffix + ".bak")
    backup.write_text(original, encoding="utf-8")
    path.write_text(best, encoding="utf-8")

    print(f"{path.name}: Improved SPDX match score {base_score} -> {best_score}")
    print(f"Backup written: {backup.name}")
    for (idx, old, new, s0, s1) in changes[:20]:
        print(f"  - pos {idx}: '{old}' -> '{new}'  ({s0}->{s1})")
    if len(changes) > 20:
        print(f"  ... ({len(changes)-20} more)")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
