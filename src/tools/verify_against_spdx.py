#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError

# --- Repo root discovery (works even when script is in src/tools) ---
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
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
ANY_TAG_RE = re.compile(r"\[\[[^\]]+\]\]")  # remove any [[...]] tokens

SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"


def http_get_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "lizenzkatalog-verify/1.0"})
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


def strip_annotations(text: str) -> str:
    # Removes all annotation tokens like [[...]] anywhere in the document.
    return ANY_TAG_RE.sub("", text)


def normalize_for_compare(text: str) -> str:
    """
    Make formatting irrelevant:
    - Remove annotations already, then:
    - Convert any whitespace (incl. newlines/tabs) to single spaces
    - Trim
    """
    # Normalize line endings first (optional, but keeps behavior predictable)
    text = text.replace("\r\n", "\n").replace("\r", "\n")

    # Collapse all whitespace runs (spaces, tabs, newlines) into single spaces
    text = re.sub(r"\s+", " ", text)

    return text.strip()


def fetch_spdx_license_text(spdx_id: str) -> str:
    url = SPDX_LICENSE_JSON_URL.format(spdx_id=spdx_id)
    data = http_get_json(url)
    license_text = data.get("licenseText")
    if not license_text:
        raise RuntimeError(f"SPDX JSON for '{spdx_id}' has no 'licenseText'.")
    return license_text


def first_diff_context(a: str, b: str, ctx: int = 40) -> str:
    """
    Returns a small snippet showing where strings differ.
    """
    max_len = min(len(a), len(b))
    i = 0
    while i < max_len and a[i] == b[i]:
        i += 1
    if i == max_len and len(a) == len(b):
        return "No diff."
    a_snip = a[max(0, i - ctx): i + ctx]
    b_snip = b[max(0, i - ctx): i + ctx]
    return (
        f"First diff at index {i}\n"
        f"SPDX : …{a_snip}…\n"
        f"LOCAL: …{b_snip}…"
    )


def verify_one_file(path: Path) -> tuple[bool, str]:
    raw_local = path.read_text(encoding="utf-8", errors="replace")
    spdx_id = extract_spdx_id(raw_local)

    raw_spdx = fetch_spdx_license_text(spdx_id)

    local_norm = normalize_for_compare(strip_annotations(raw_local))
    spdx_norm = normalize_for_compare(raw_spdx)

    if local_norm == spdx_norm:
        return True, f"{path.name}: OK (matches SPDX {spdx_id} ignoring formatting + annotations)"

    info = first_diff_context(spdx_norm, local_norm)
    msg = (
        f"{path.name}: MISMATCH vs SPDX {spdx_id}\n"
        f"{info}"
    )
    return False, msg


def main() -> int:
    if not CATALOG_DIR.exists():
        print(f"ERROR: Missing directory: {CATALOG_DIR}")
        return 2

    files = sorted(CATALOG_DIR.glob("*.liz"))
    if not files:
        print("No .liz files found.")
        return 0

    ok_all = True
    for f in files:
        try:
            ok, msg = verify_one_file(f)
            print(msg)
            if not ok:
                ok_all = False
        except Exception as e:
            ok_all = False
            print(f"{f.name}: ERROR: {e}")

    return 0 if ok_all else 1


if __name__ == "__main__":
    raise SystemExit(main())
