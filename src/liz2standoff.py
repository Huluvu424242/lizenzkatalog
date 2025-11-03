#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# liz2standoff.py — Konvertiert .liz (Plaintext mit Markern) in
# 1) reinen Text (Marker entfernt) und
# 2) ein Standoff-XML mit <note type="cat#name" id="…" [start="…"] [end="…"] [value="…"] …/>
#
# Neue Marker-Syntax (kompatibel mit deinem Schema):
#   [[cat#name]] ... [[/cat#name]]         -> Bereiche-Annotation (verschachtelt/überlappend erlaubt)
#   [[cat#name=VALUE]]                     -> Singleton-Annotation (ohne Textbezug)
#   [[lic#fsf]] / [[lic#osi]] / [[lic#c]] / [[lic#c0]] -> Singletons ohne Wert
#
# Offsets sind 0-basiert, end-exklusiv, gemessen im reinen Text nach Entfernen der Marker.

import html
import re
import shutil
from pathlib import Path
from xml.sax.saxutils import quoteattr

import unicodedata

# --- Vokabular-Policy ---------------------------------------------------------
# Welche Tags sind Singletons (benötigen kein schließendes Tag / keine Spanne)?
# Du kannst diese Liste jederzeit erweitern/anpassen.
SINGLETON_TAGS = {
    "lic#spdx",
    "lic#fsf",
    "lic#osi",
    "lic#c",
    "lic#c0",
}

# --- Regex --------------------------------------------------------------------
# [[ lic#name ]], [[ lic#name=VALUE ]], [[ /lic#name ]]
# VALUE kann "…" (mit escapes) oder unquoted (bis zur schließenden ]]) sein.
# --- Regex --------------------------------------------------------------------
# Offene oder Singleton-Tags: [[ lic#name ]] oder [[ lic#name=VALUE ]]
OPEN_OR_SINGLETON_RE = re.compile(
    r"""\[\[\s*
        (?P<cat1>lic|use|lim|act|rul)
        \#
        (?P<name1>[A-Za-z0-9\-]+)
        (?:=(?P<val>
             "(?:\\.|[^"\\])*"         # quoted
             | [^\]\r\n]+              # or unquoted
        ))?
        \s*\]\]""",
    re.VERBOSE,
)

# Schließende Tags: [[ /lic#name ]]
CLOSE_RE = re.compile(
    r"""\[\[\s*/\s*
        (?P<cat2>lic|use|lim|act|rul)
        \#
        (?P<name2>[A-Za-z0-9\-]+)
        \s*\]\]""",
    re.VERBOSE,
)

# Kombinierte Suche (verschiedene Gruppennamen!)
MASTER_RE = re.compile(
    f"{OPEN_OR_SINGLETON_RE.pattern}|{CLOSE_RE.pattern}",
    re.VERBOSE | re.DOTALL,
)

#
# # Optional: ermöglicht literale [[ bzw. ]] im Text via Escape
ESCAPE_OPEN = r"\[\["
ESCAPE_CLOSE = r"\]\]"


def endpos(content: str) -> int:
    return len(content) - 1


def last_char(content: str) -> str:
    return content[-1]


def first_char(content: str) -> str:
    return content[0]


def unquote_value(content: str) -> str:
    if content is None:
        return ""
    content = content.strip()
    if len(content) >= 2 and first_char(content) == '"' and last_char(content) == '"':
        # einfache Un-Escapes für \" \\ \n \t \[ \]
        unquoted_value: list = []
        pos: int = 1
        while pos < endpos(content):
            cur = content[pos]
            if cur == "\\" and pos + 1 < endpos(content):
                nxt = content[pos + 1]
                if nxt == "n":
                    unquoted_value.append("\n")
                elif nxt == "t":
                    unquoted_value.append("\t")
                elif nxt in ['"', "\\", "[", "]"]:
                    unquoted_value.append(nxt)
                else:
                    # unbekannter Escape — roh übernehmen
                    unquoted_value.append(nxt)
                pos += 2
            else:
                unquoted_value.append(cur)
                pos += 1
        return "".join(unquoted_value)
    return content


def copy_text_file(src_dir: str, dst_dir: str) -> None:
    """Kopiert eine Textdatei von src_dir nach dst_dir."""
    src_path = Path(src_dir)
    dst_path = Path(dst_dir)
    print(f"Von: {src_path} Nach: {dst_path}")
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_path, dst_path)


def konvertiere(inp="input.liz", out_txt="output.txt", out_xml="output.xml"):
    print(f"Verarbeite: {inp}")
    src_raw = Path(inp).read_text(encoding="utf-8")
    # Normalisierung für stabile Offsets
    src = unicodedata.normalize("NFC", src_raw)

    pos_src = 0  # Position im Rohtext
    out_buf: list[str] = []  # bereinigter Text (ohne Marker)
    out_len = 0  # Länge des bereinigten Texts

    # Stacks für offene Bereiche je Tag (cat#name) — ermöglicht Überlappung
    open_stacks: dict[str, list[dict]] = {}

    # Ergebnisliste: sowohl Bereiche als auch Singletons
    notes: list[dict] = []

    auto_seq = 0  # laufende ID-Vergabe

    for m in MASTER_RE.finditer(src):
        # Text bis vor dem Tag in den bereinigten Puffer kopieren
        chunk = src[pos_src:m.start()]
        # Escape-Sequenzen für literale [[ / ]] im Text ersetzen
        chunk = chunk.replace(ESCAPE_OPEN, "[[").replace(ESCAPE_CLOSE, "]]")
        out_buf.append(chunk)
        out_len += len(chunk)

        # Match zerlegen: ist es ein Open/Singleton oder Close?
        mo_open = OPEN_OR_SINGLETON_RE.match(m.group(0))
        if mo_open:
            cat = mo_open.group("cat1")
            name = mo_open.group("name1")
            raw_val = mo_open.group("val")
            val = unquote_value(raw_val) if raw_val is not None else None

            tag_key = f"{cat}#{name}"
            is_singleton_by_vocab = tag_key in SINGLETON_TAGS
            is_singleton_by_value = (val is not None)

            if is_singleton_by_vocab or is_singleton_by_value:
                # -> Singleton: sofort Note emittieren, kein Start/Ende
                auto_seq += 1
                note = {
                    "id": f"a{auto_seq}",
                    "type": tag_key,
                    "value": val,
                    # Singletons haben bewusst kein start/end
                }
                notes.append(note)
            else:
                # -> Open-Span: auf den Stack
                auto_seq += 1
                frame = {
                    "id": f"a{auto_seq}",
                    "type": tag_key,
                    "start": out_len,
                }
                open_stacks.setdefault(tag_key, []).append(frame)

        else:
            mo_close = CLOSE_RE.match(m.group(0))
            if not mo_close:
                raise ValueError("Interner Parserfehler: Weder open/singleton noch close erkannt.")

            cat = mo_close.group("cat2")
            name = mo_close.group("name2")
            tag_key = f"{cat}#{name}"

            stack = open_stacks.get(tag_key, [])
            if not stack:
                raise ValueError(
                    f"Ende für unbekannte/geschlossene Spanne {tag_key} bei Pos {m.start()} in {inp}"
                )
            frame = stack.pop()  # LIFO – korrekt bei Verschachtelung gleicher Tags
            frame["end"] = out_len
            notes.append(frame)

        pos_src = m.end()

    # Resttext übernehmen
    tail = src[pos_src:]
    tail = tail.replace(ESCAPE_OPEN, "[[").replace(ESCAPE_CLOSE, "]]")
    out_buf.append(tail)
    out_len += len(tail)

    # Nicht geschlossene Bereiche melden
    dangling = []
    for tag_key, stack in open_stacks.items():
        for fr in stack:
            dangling.append(f'{tag_key} (id={fr["id"]}, start={fr["start"]})')
    if dangling:
        raise ValueError("Nicht geschlossene Bereiche: " + ", ".join(dangling) + f" in {inp}")

    # Plaintext schreiben
    plain_text = "".join(out_buf)
    Path(out_txt).write_text(plain_text, encoding="utf-8")
    print(f" --> {out_txt}")

    # XML schreiben
    def xml_attr_pair(k: str, v: str | None) -> str | None:
        if v is None:
            return None
        return f'{k}={quoteattr(str(v))}'

    lines: list[str] = []
    lines.append('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
    lines.append('<!DOCTYPE annotation SYSTEM "annotation.dtd">')
    lines.append('<?xml-stylesheet type="text/xsl" href="style.xsl"?>')
    lines.append('<?thomas-schubert document-status="draft" version="2.0"?>')
    lines.append('<annotation>')
    lines.append('  <text xml:space="preserve">')
    lines.append(html.escape(plain_text))
    lines.append('  </text>')
    lines.append('  <notes>')

    # Sortierung: Bereiche zuerst nach (start, end), Singletons danach stabil
    spans_sorted: list[tuple[int, int, dict]] = []
    singletons: list[dict] = []
    for n in notes:
        if "start" in n and "end" in n:
            spans_sorted.append((n["start"], n["end"], n))
        else:
            singletons.append(n)
    spans_sorted.sort(key=lambda t: (t[0], t[1]))

    # Bereiche ausgeben
    for _, _, sp in spans_sorted:
        attrs = [
            xml_attr_pair("id", sp.get("id")),
            xml_attr_pair("type", sp.get("type")),
            xml_attr_pair("start", sp.get("start")),
            xml_attr_pair("end", sp.get("end")),
        ]
        # Falls später Werte in Bereiche benutzt werden sollen:
        if "value" in sp and sp["value"] is not None:
            attrs.append(xml_attr_pair("value", sp["value"]))
        attrs = [a for a in attrs if a is not None]
        lines.append("    <note " + " ".join(attrs) + "/>")

    # Singletons ausgeben (ohne start/end)
    for sg in singletons:
        attrs = [
            xml_attr_pair("id", sg.get("id")),
            xml_attr_pair("type", sg.get("type")),
        ]
        if sg.get("value") is not None:
            attrs.append(xml_attr_pair("value", sg["value"]))
        attrs = [a for a in attrs if a is not None]
        lines.append("    <note " + " ".join(attrs) + "/>")

    lines.append('  </notes>')
    lines.append('</annotation>')
    Path(out_xml).write_text("\n".join(lines), encoding="utf-8")
    print(f" --> {out_xml}")


if __name__ == "__main__":
    src_folder: str = "lizenzkatalog"
    styles_folder: str = "src/styles"
    site_folder: str = "src/site"
    img_folder: str = "src/img"
    dst_folder: str = "docs"

    srcpath: Path = Path(src_folder)
    liz_dateien = [f.stem for f in srcpath.glob("*.liz")]
    liz_dateien.sort(key=lambda s: s.lower())

    print(liz_dateien)
    copy_text_file(f"{styles_folder}/liz2table-style.xsl", f"{dst_folder}/style.xsl")
    copy_text_file(f"{styles_folder}/annotation.dtd", f"{dst_folder}/annotation.dtd")
    copy_text_file(f"{site_folder}/index.html", f"{dst_folder}/index.html")
    copy_text_file(f"{site_folder}/content.js", f"{dst_folder}/content.js")
    copy_text_file(f"{img_folder}/ospolizenzkatalog.svg", f"{dst_folder}/ospolizenzkatalog.svg")
    xmlfilenames: list[str] = []
    for license_name in liz_dateien:
        inp = f"{src_folder}/{license_name}.liz"
        out_txt = f"{dst_folder}/{license_name}.txt"
        out_xml = f"{dst_folder}/{license_name}.tei.xml"
        konvertiere(inp, out_txt, out_xml)
        xmlfilenames.append(f"{license_name}")
    Path(f"{dst_folder}/content.txt").write_text("\n".join(xmlfilenames), encoding="utf-8")
