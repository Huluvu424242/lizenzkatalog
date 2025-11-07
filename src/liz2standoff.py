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

OPEN_MARKER_CATEGORY = "cat1"
OPEN_MARKER_NAME = "name1"
OPEN_MARKER_WERT = "val"

CLOSE_MARKER_CATEGORY = "cat2"
CLOSE_MARKER_NAME = "name2"

CLOSE_MARKER = "]]"

OPEN_MARKER = "[["

DOPPELTES_HOCHKOMMA = '"'

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

# noinspection RegExpRedundantEscape
# noinspection RegExpDuplicateAlternationBranch
# noinspection RegExpSimplifiable
OPEN_OR_SINGLETON_REGEX = re.compile(
    rf"""\[\[\s*
        (?P<{OPEN_MARKER_CATEGORY}>lic|use|lim|act|rul)
        \#
        (?P<{OPEN_MARKER_NAME}>[A-Za-z0-9\-]+)
        (?:=(?P<{OPEN_MARKER_WERT}>
             "(?:\\.|[^"\\])*"         # quoted
             | [^\]\r\n]+              # or unquoted
        ))?
        \s*\]\]""",
    re.VERBOSE,
)

# noinspection RegExpRedundantEscape
# noinspection RegExpDuplicateAlternationBranch
# noinspection RegExpSimplifiable
CLOSE_REGEX = re.compile(
    rf"""\[\[\s*/\s*
        (?P<{CLOSE_MARKER_CATEGORY}>lic|use|lim|act|rul)
        \#
        (?P<{CLOSE_MARKER_NAME}>[A-Za-z0-9\-]+)
        \s*\]\]""",
    re.VERBOSE,
)

# Kombinierte Suche (verschiedene Gruppennamen!)
MASTER_REGEX = re.compile(
    f"{OPEN_OR_SINGLETON_REGEX.pattern}|{CLOSE_REGEX.pattern}",
    re.VERBOSE | re.DOTALL,
)

#
# # Optional: ermöglicht literale [[ bzw. ]] im Text via Escape
ESCAPED_OPEN_MARKER = r"\[\["
ESCAPED_CLOSE_MARKER = r"\]\]"


def lastpos(content: str) -> int:
    return len(content) - 1


def nextpos(pos: int) -> int:
    return pos + 1


def last_char(content: str) -> str:
    return content[-1]


def first_char(content: str) -> str:
    return content[0]


def is_string_part(content: str) -> bool:
    return (len(content) >= 2
            and first_char(content) == DOPPELTES_HOCHKOMMA
            and last_char(content) == DOPPELTES_HOCHKOMMA)


def unquote_value(content: str) -> str:
    if content is None:
        return ""
    content = content.strip()
    if is_string_part(content):
        # einfache Un-Escapes für \" \\ \n \t \[ \]
        unquoted_value: list = []
        pos: int = 1
        while pos < lastpos(content):
            cur_char = content[pos]
            if cur_char == "\\" and nextpos(pos) < lastpos(content):
                next_char = content[nextpos(pos)]
                if next_char == "n":
                    unquoted_value.append("\n")  # quoted newline
                elif next_char == "t":
                    unquoted_value.append("\t")  # quoted tab
                elif next_char in [DOPPELTES_HOCHKOMMA, "\\", "[", "]"]:
                    unquoted_value.append(next_char)  # quoted qoute or bracket
                else:
                    # unbekannter Escape — roh übernehmen
                    unquoted_value.append(next_char)
                pos += 2
            else:
                unquoted_value.append(cur_char)
                pos = nextpos(pos)
        return "".join(unquoted_value)
    return content


def copy_text_file(src_dir: str, dst_dir: str) -> None:
    """Kopiert eine Textdatei von src_dir nach dst_dir."""
    src_path = Path(src_dir)
    dst_path = Path(dst_dir)
    print(f"Von: {src_path} Nach: {dst_path}")
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_path, dst_path)


def unquote_marker(text: str) -> str:
    return text.replace(ESCAPED_OPEN_MARKER, OPEN_MARKER).replace(ESCAPED_CLOSE_MARKER, CLOSE_MARKER)


def konvertiere(inp="input.liz", out_txt="output.txt", out_xml="output.xml"):
    print(f"Verarbeite: {inp}")
    text_raw = Path(inp).read_text(encoding="utf-8")
    # Normalisierung für stabile Offsets
    text = unicodedata.normalize("NFC", text_raw)

    cur_pos = 0  # Position im Rohtext
    out_buf: list[str] = []  # bereinigter Text (ohne Marker)
    out_len = 0  # Länge des bereinigten Texts

    # Stacks für offene Bereiche je Tag (cat#name) — ermöglicht Überlappung
    open_stacks: dict[str, list[dict]] = {}

    # Ergebnisliste: sowohl Bereiche als auch Singletons
    notes: list[dict] = []

    auto_seq = 0  # laufende ID-Vergabe

    for treffer in MASTER_REGEX.finditer(text):
        # Text bis vor dem Tag in den bereinigten Puffer kopieren
        chunk = text[cur_pos:treffer.start()]
        # Escape-Sequenzen für literale [[ / ]] im Text ersetzen
        chunk = unquote_marker(chunk)
        out_buf.append(chunk)
        out_len += len(chunk)

        # Match zerlegen: ist es ein Open/Singleton oder Close?
        mo_open = OPEN_OR_SINGLETON_REGEX.match(treffer.group(0))
        if mo_open:
            cat = mo_open.group(OPEN_MARKER_CATEGORY)
            name = mo_open.group(OPEN_MARKER_NAME)
            raw_val = mo_open.group(OPEN_MARKER_WERT)
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
            mo_close = CLOSE_REGEX.match(treffer.group(0))
            if not mo_close:
                raise ValueError("Interner Parserfehler: Weder open/singleton noch close erkannt.")

            cat = mo_close.group(CLOSE_MARKER_CATEGORY)
            name = mo_close.group(CLOSE_MARKER_NAME)
            tag_key = f"{cat}#{name}"

            stack = open_stacks.get(tag_key, [])
            if not stack:
                raise ValueError(
                    f"Ende für unbekannte/geschlossene Spanne {tag_key} bei Pos {treffer.start()} in {inp}"
                )
            frame = stack.pop()  # LIFO – korrekt bei Verschachtelung gleicher Tags
            frame["end"] = out_len
            notes.append(frame)

        cur_pos = treffer.end()

    # Resttext übernehmen
    tail = text[cur_pos:]
    tail = tail.replace(ESCAPED_OPEN_MARKER, OPEN_MARKER).replace(ESCAPED_CLOSE_MARKER, CLOSE_MARKER)
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

    lines: list[str] = ['<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
                        '<!DOCTYPE annotation SYSTEM "annotation.dtd">',
                        '<?xml-stylesheet type="text/xsl" href="style.xsl"?>',
                        '<?thomas-schubert document-status="draft" version="2.0"?>', '<annotation>',
                        '  <text xml:space="preserve">', html.escape(plain_text), '  </text>', '  <notes>']

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
