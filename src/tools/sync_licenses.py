#!/usr/bin/env python3
import json
import os
import re
import sys
import datetime
from pathlib import Path
from urllib.request import urlopen, Request

REPO_ROOT = Path(__file__).resolve().parents[2]
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"
TARGET_FILE = REPO_ROOT / "automation" / "target_licenses.json"

SPDX_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')

SPDX_LICENSES_INDEX = "https://spdx.org/licenses/licenses.json"


def load_valid_spdx_ids() -> set[str]:
    idx = http_get_json(SPDX_LICENSES_INDEX)
    # SPDX index has a "licenses" array with "licenseId" fields
    return {x["licenseId"] for x in idx.get("licenses", []) if "licenseId" in x}

def read_target_spdx_ids() -> list[str]:
    data = json.loads(TARGET_FILE.read_text(encoding="utf-8"))
    ids = data.get("spdx_ids", [])
    if not ids:
        raise RuntimeError("target_licenses.json has no spdx_ids")
    return ids

def list_existing_liz_files() -> list[Path]:
    if not CATALOG_DIR.exists():
        raise RuntimeError(f"Missing directory: {CATALOG_DIR}")
    return sorted(CATALOG_DIR.glob("*.liz"))

def extract_spdx_id_from_liz(text: str) -> str | None:
    m = SPDX_TAG_RE.search(text)
    return m.group(1) if m else None

def inventory_present_spdx_ids() -> set[str]:
    present = set()
    for p in list_existing_liz_files():
        txt = p.read_text(encoding="utf-8", errors="replace")
        spdx = extract_spdx_id_from_liz(txt)
        if spdx:
            present.add(spdx.strip())
    return present

def http_get_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "lizenzkatalog-sync-bot/1.0"})
    with urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))

def filename_for_spdx_id(spdx_id: str) -> str:
    # EXACT SPDX licenseId -> filename
    # e.g. "Apache-2.0" -> "Apache-2.0.liz"
    return f"{spdx_id}.liz"


def sanitize_filename(spdx_id: str) -> str:
    # keep repo naming simple & stable: <spdx>.liz
    # SPDX IDs already safe-ish, but keep conservative
    return re.sub(r"[^A-Za-z0-9\.\-\+]+", "_", spdx_id) + ".liz"

def build_liz_content(spdx_id: str, meta: dict) -> str:
    today = datetime.date.today().isoformat()
    src = meta.get("detailsUrl") or f"https://spdx.org/licenses/{spdx_id}.html"
    license_text = (meta.get("licenseText") or "").rstrip()

    if not license_text:
        raise RuntimeError(f"No licenseText in SPDX JSON for {spdx_id}")

    lines = []
    # Pflicht
    lines.append(f"[[lic#spdx=\"{spdx_id}\"]]")
    # Optional, aber praktisch
    lines.append(f"[[lic#src=\"{src}\"]]")
    lines.append(f"[[lic#date=\"{today}\"]]")
    lines.append("")

    # Dann der reine Lizenztext
    lines.append(license_text)
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    targets = read_target_spdx_ids()
    valid = load_valid_spdx_ids()

    invalid = [x for x in targets if x not in valid]
    if invalid:
        raise RuntimeError(f"Invalid SPDX IDs in target_licenses.json: {invalid}")

    present = inventory_present_spdx_ids()
    missing = [x for x in targets if x not in present]

    print(f"Present SPDX IDs: {len(present)}")
    print(f"Missing SPDX IDs: {len(missing)}")

    if not missing:
        print("Nothing to do.")
        return 0

    CATALOG_DIR.mkdir(parents=True, exist_ok=True)

    created = 0
    for spdx_id in missing:
        url = SPDX_JSON_URL.format(spdx_id=spdx_id)
        meta = http_get_json(url)
        out_name = filename_for_spdx_id(spdx_id)
        out_path = CATALOG_DIR / out_name

        if out_path.exists():
            # Avoid overwriting if a differently-named file already exists;
            # still skip to be conservative
            print(f"SKIP exists: {out_path}")
            continue

        content = build_liz_content(spdx_id, meta)
        out_path.write_text(content, encoding="utf-8")
        created += 1
        print(f"Created: {out_path}")

    print(f"Created files: {created}")
    return 0 if created >= 0 else 1

if __name__ == "__main__":
    raise SystemExit(main())
