#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# liz2standoff.py — Konvertiert .liz (Plaintext mit Markern) in
# 1) reinen Text (Marker entfernt) und
# 2) ein Standoff-XML mit <span type=... id=... start=... end=... .../>
#
# Marker-Syntax:
#   [[typ#id key="value" ...]]   Start
#   [[/typ#id]]                  Ende
#
# Offsets sind 0-basiert, end-exklusiv, gemessen im reinen Text nach Entfernen der Marker.

import re
import sys
import html
import unicodedata
from pathlib import Path
from xml.sax.saxutils import quoteattr

TAG_RE = re.compile(
    r"\[\[\s*(/?)([A-Za-z][\w:-]*)(?:\#([\w.-]+))?(?:\s+([^\]]*?))?\s*\]\]",
    re.DOTALL,
)

ATTR_RE = re.compile(r'([A-Za-z_][\w:.-]*)\s*=\s*"(.*?)"', re.DOTALL)

def parse_attrs(s):
    # Parse key="value" Paare; ignoriert fehlerhafte Fragmente.
    attrs = {}
    if not s:
        return attrs
    for m in ATTR_RE.finditer(s):
        k, v = m.group(1), m.group(2)
        attrs[k] = v
    return attrs

def main(inp="input.liz", out_txt="output.txt", out_xml="output.xml"):
    src = Path(inp).read_text(encoding="utf-8")
    # Normalisierung für stabile Offsets
    src = unicodedata.normalize("NFC", src)

    pos_src = 0
    out_buf = []
    out_len = 0
    open_spans = {}  # id -> span dict
    spans = []

    for m in TAG_RE.finditer(src):
        # Text bis vor dem Tag
        chunk = src[pos_src:m.start()]
        out_buf.append(chunk)
        out_len += len(chunk)

        slash, typ, sid, attrs_raw = m.groups()
        if not slash:  # Start
            if not sid:
                raise ValueError(f"Start-Tag [[{typ}]] ohne #id bei Pos {m.start()} in {inp}")
            if sid in open_spans:
                raise ValueError(f"ID {sid} schon offen (Start bei Pos {m.start()}) in {inp}")
            open_spans[sid] = {
                "type": typ,
                "id": sid,
                "start": out_len,
                "attrs": parse_attrs(attrs_raw),
            }
        else:          # Ende
            if not sid:
                raise ValueError(f"End-Tag [[/{typ}]] ohne #id bei Pos {m.start()} in {inp}")
            span = open_spans.pop(sid, None)
            if span is None:
                raise ValueError(f"Ende für unbekannte/geschlossene ID {sid} bei Pos {m.start()} in {inp}")
            if span["type"] != typ:
                raise ValueError(f"Typ-Mismatch für ID {sid}: start={span['type']} end={typ} in {inp}")
            span["end"] = out_len
            spans.append(span)

        pos_src = m.end()

    # Resttext
    tail = src[pos_src:]
    out_buf.append(tail)
    out_len += len(tail)

    if open_spans:
        open_ids = ", ".join(sorted(open_spans.keys()))
        raise ValueError(f"Nicht geschlossene IDs: {open_ids} in {inp}")

    # Plaintext schreiben
    plain_text = "".join(out_buf)
    Path(out_txt).write_text(plain_text, encoding="utf-8")

    # XML schreiben
    def attrs_to_xml(a_dict):
        return " ".join(f'{k}={quoteattr(v)}' for k, v in a_dict.items())

    lines = []
    lines.append('<?xml version="1.0" encoding="UTF-8"?>')
    lines.append('<doc>')
    lines.append('  <text>')
    lines.append('    ' + html.escape(plain_text))
    lines.append('  </text>')
    lines.append('  <annotations>')
    for sp in sorted(spans, key=lambda s: (s["start"], s["end"])):
        extra = attrs_to_xml(sp["attrs"])
        if extra:
            extra = " " + extra
        lines.append(f'    <span id="{sp["id"]}" type="{sp["type"]}" start="{sp["start"]}" end="{sp["end"]}"{extra}/>')
    lines.append('  </annotations>')
    lines.append('</doc>')
    Path(out_xml).write_text("\n".join(lines), encoding="utf-8")

if __name__ == "__main__":
    inp = sys.argv[1] if len(sys.argv) > 1 else "input.liz"
    out_txt = sys.argv[2] if len(sys.argv) > 2 else "output.txt"
    out_xml = sys.argv[3] if len(sys.argv) > 3 else "output.xml"
    main(inp, out_txt, out_xml)
