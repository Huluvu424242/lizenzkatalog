#!/usr/bin/env python3
import json
import os
import re
import sys
import datetime
from pathlib import Path
from urllib.request import urlopen, Request

REPO_ROOT = Path(__file__).resolve().parents[1]
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"
TARGET_FILE = REPO_ROOT / "target_licenses.json"

SPDX_JSON_URL = "https://spdx.org/licenses/{spdx_id}.json"

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')

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

def sanitize_filename(spdx_id: str) -> str:
    # keep repo naming simple & stable: <spdx>.liz
    # SPDX IDs already safe-ish, but keep conservative
    return re.sub(r"[^A-Za-z0-9\.\-\+]+", "_", spdx_id) + ".liz"

def build_liz_content(spdx_id: str, meta: dict) -> str:
    today = datetime.date.today().isoformat()
    name = meta.get("name", spdx_id)
    # Canonical "details page" is stable; json includes "detailsUrl" or can use SPDX page
    src = meta.get("detailsUrl") or f"https://spdx.org/licenses/{spdx_id}.html"
    license_text = meta.get("licenseText", "").rstrip()

    if not license_text:
        raise RuntimeError(f"No licenseText in SPDX JSON for {spdx_id}")

    # Minimal header per your repo conventions (lic#name is a block; lic#spdx/src/date are single tags)
    header = []
    header.append(f"[[lic#spdx=\"{spdx_id}\"]]")
    header.append(f"[[lic#src=\"{src}\"]]")
    header.append(f"[[lic#date=\"{today}\"]]")
    header.append("")
    header.append("[[lic#name]]")
    header.append(name)
    header.append("[[/lic#name]]")
    header.append("")
    header.append(license_text)
    header.append("")
    return "\n".join(header)

def main() -> int:
    targets = read_target_spdx_ids()
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
        out_name = sanitize_filename(spdx_id)
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
