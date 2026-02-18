#!/usr/bin/env python3
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CATALOG_DIR = REPO_ROOT / "lizenzkatalog"

SPDX_TAG_RE = re.compile(r'\[\[lic#spdx="([^"]+)"\]\]')

def extract_spdx_id(text: str) -> str | None:
    m = SPDX_TAG_RE.search(text)
    return m.group(1).strip() if m else None

def main() -> int:
    if not CATALOG_DIR.exists():
        print(f"ERROR: Missing directory: {CATALOG_DIR}")
        return 2

    files = sorted(CATALOG_DIR.glob("*.liz"))
    if not files:
        print("No .liz files found. Nothing to normalize.")
        return 0

    # Map SPDX -> current paths (detect duplicates early)
    spdx_to_paths: dict[str, list[Path]] = {}
    for p in files:
        txt = p.read_text(encoding="utf-8", errors="replace")
        spdx = extract_spdx_id(txt)
        if not spdx:
            print(f"ERROR: Missing [[lic#spdx=\"...\"]] in {p.name}")
            return 3
        spdx_to_paths.setdefault(spdx, []).append(p)

    duplicates = {k: v for k, v in spdx_to_paths.items() if len(v) > 1}
    if duplicates:
        print("ERROR: Duplicate SPDX IDs found (multiple files claim same lic#spdx):")
        for spdx, paths in duplicates.items():
            print(f"  {spdx}: " + ", ".join(x.name for x in paths))
        return 4

    planned_moves: list[tuple[Path, Path]] = []
    for spdx, paths in spdx_to_paths.items():
        src = paths[0]
        dst = CATALOG_DIR / f"{spdx}.liz"
        if src.name == dst.name:
            continue
        if dst.exists():
            print(f"ERROR: Target already exists: {dst.name} (would collide with {src.name})")
            return 5
        planned_moves.append((src, dst))

    if not planned_moves:
        print("All filenames already normalized.")
        return 0

    print("Planned renames:")
    for src, dst in planned_moves:
        print(f"  {src.name} -> {dst.name}")

    for src, dst in planned_moves:
        src.rename(dst)

    print(f"Renamed {len(planned_moves)} file(s).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
