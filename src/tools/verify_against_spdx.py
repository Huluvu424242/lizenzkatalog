#!/usr/bin/env python3
import json
import re
from dataclasses import dataclass
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError

# ---------------------------
# Config
# ---------------------------
SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')
ANY_TAG_RE = re.compile(r"\[\[[^\]]+\]\]")  # any [[...]] token
SPDX_LICENSE_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

PRINT_OK = True          # set False if you only want errors
CONTEXT_CHARS = 60       # context around first mismatch


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
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"


# ---------------------------
# Helpers
# ---------------------------
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
    # remove all [[...]] tokens; keep the rest
    return ANY_TAG_RE.sub("", text)


def normalize_for_compare(text: str) -> str:
    # normalize line endings then compress whitespace
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def fetch_spdx_license_text(spdx_id: str) -> str:
    url = SPDX_LICENSE_JSON_URL.format(spdx_id=spdx_id)
    data = http_get_json(url)
    license_text = data.get("licenseText")
    if not license_text:
        raise RuntimeError(f"SPDX JSON for '{spdx_id}' has no 'licenseText'.")
    return license_text


def first_diff_context(a: str, b: str, ctx: int) -> str:
    """
    Find first differing index and show small context.
    a = SPDX normalized, b = LOCAL normalized
    """
    max_len = min(len(a), len(b))
    i = 0
    while i < max_len and a[i] == b[i]:
        i += 1
    if i == max_len:
        if len(a) == len(b):
            return "No diff."
        # One string is a prefix of the other
        if len(a) < len(b):
            return f"LOCAL has extra content starting at index {i}: …{b[i:i+ctx]}…"
        return f"SPDX has extra content starting at index {i}: …{a[i:i+ctx]}…"

    a_snip = a[max(0, i - ctx): i + ctx]
    b_snip = b[max(0, i - ctx): i + ctx]
    return (
        f"First diff at index {i}\n"
        f"SPDX : …{a_snip}…\n"
        f"LOCAL: …{b_snip}…"
    )


@dataclass
class VerifyResult:
    filename: str
    spdx_id: str | None
    ok: bool
    message: str


def verify_one_file(path: Path) -> VerifyResult:
    raw_local = path.read_text(encoding="utf-8", errors="replace")

    try:
        spdx_id = extract_spdx_id(raw_local)
    except Exception as e:
        return VerifyResult(path.name, None, False, f"ERROR: {e}")

    try:
        raw_spdx = fetch_spdx_license_text(spdx_id)
    except Exception as e:
        return VerifyResult(path.name, spdx_id, False, f"ERROR fetching SPDX text: {e}")

    local_norm = normalize_for_compare(strip_annotations(raw_local))
    spdx_norm = normalize_for_compare(raw_spdx)

    if local_norm == spdx_norm:
        return VerifyResult(path.name, spdx_id, True, "OK")

    info = first_diff_context(spdx_norm, local_norm, CONTEXT_CHARS)
    return VerifyResult(path.name, spdx_id, False, info)


# ---------------------------
# Main
# ---------------------------
def main() -> int:
    if not CATALOG_DIR.exists():
        print(f"ERROR: Missing directory: {CATALOG_DIR}")
        return 2

    files = sorted(CATALOG_DIR.glob("*.liz"))
    if not files:
        print("No .liz files found.")
        return 0

    results: list[VerifyResult] = []
    for f in files:
        results.append(verify_one_file(f))

    oks = [r for r in results if r.ok]
    fails = [r for r in results if not r.ok]

    if PRINT_OK:
        for r in oks:
            print(f"{r.filename}: OK (matches SPDX {r.spdx_id} ignoring formatting + annotations)")

    print(f"\nSummary: {len(oks)} OK, {len(fails)} FAIL")

    if fails:
        print("\nFailures:")
        for r in fails:
            spdx_part = f"SPDX {r.spdx_id}" if r.spdx_id else "SPDX <missing>"
            print(f"\n- {r.filename}: {spdx_part}")
            print(r.message)

        print("\nFailed files (copy/paste list):")
        for r in fails:
            print(r.filename)

    return 0 if not fails else 1


if __name__ == "__main__":
    raise SystemExit(main())
