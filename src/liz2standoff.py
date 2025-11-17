#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# liz2standoff.py — Konvertiert .liz (Plaintext mit Markern) in
# 1) reinen Text (Marker entfernt) und
# 2) ein Standoff-XML mit <note type="cat#name" id="…" [start="…"] [end="…"] …/>
#
# Variante B (robust):
# - Unterstützt [[cat#name=VALUE]] und [[cat#name key="v" key2=...]]
# - Keine re.VERBOSE-Flags in den Hauptmustern (robuster gegen Sonderfälle)
# - pol-Singletons bekommen status (green|yellow|red), title (Tooltip) und label aus if
# - pol#_section wird automatisch erzeugt, wenn es irgendeine pol-Note gibt
# - label baut ein Emoji-„Dashboard“ aus env/use/dst/cpy
# - NEU: Python liefert Zusatz-Metadaten für XSLT:
#   * category (lic/use/env/...)
#   * name (z.B. spdx, com, lib)
#   * emoji für env/use/dst/cpy-Singletons
#   * colorIndex (1–8) für Spans mit start/end

from __future__ import annotations

import html
import re
import shutil
import unicodedata
from pathlib import Path
from xml.sax.saxutils import quoteattr

OPEN_MARKER_CATEGORY = "cat1"
OPEN_MARKER_NAME = "name1"
OPEN_MARKER_WERT = "val"

CLOSE_MARKER_CATEGORY = "cat2"
CLOSE_MARKER_NAME = "name2"

CLOSE_MARKER = "]]"
OPEN_MARKER = "[["

DOPPELTES_HOCHKOMMA = '"'

# Kategorien, die IMMER Singletons sind
SINGLETON_CATEGORIES: set[str] = {
    "env", "cpy", "dst", "lnk", "pol", "met", "use",
}

# Konkrete Singleton-Tags
SINGLETON_TAGS: set[str] = {
    "lic#spdx", "lic#fsf", "lic#osi", "lic#c", "lic#c0",
    "rul#notice", "rul#lictxt", "rul#pat", "rul#patret", "rul#tivo",
}

# Emoji-Mappings für env / use / dst / cpy
ENV_EMOJI: dict[str, str] = {
    "com": "🏢",  # Unternehmen
    "edu": "🎓",  # Bildung
    "sci": "🔬",  # Wissenschaft
    "prv": "🏠",  # Privat
    "oss": "🐧",  # OSS / Pinguin
    "gov": "🏛",  # Verwaltung / Behörde
    "ngo": "🤝",  # NGO / Gemeinnützig
}

USE_EMOJI: dict[str, str] = {
    "doc": "📄",  # Dokumentation
    "lib": "📚",  # Bibliothek / Komponente
    "app": "💻",  # Lokale Anwendung
    "cld": "☁️",  # Cloud-Anwendung
}

DST_EMOJI: dict[str, str] = {
    "none": "🚫",      # keine Weitergabe
    "internal": "🏢",  # intern im Unternehmen
    "partners": "🤝",  # Partner/Kunden
    "public": "🌍",    # öffentlich
    "srv": "🖥️",      # Server-seitig
    "cli": "🧑‍💻",     # Client-Code
}

CPY_EMOJI: dict[str, str] = {
    "none": "⚪",     # kein Copyleft
    "weak": "🟢",     # weak copyleft
    "strong": "🔴",   # strong copyleft
    "network": "🌐",  # network copyleft
}

# -------------------- Regexe (ohne VERBOSE) ----------------------------------
# "=" oder " <KV-Paare>" bis "]]"
OPEN_OR_SINGLETON_REGEX = re.compile(
    r"\[\[\s*"
    r"(?P<" + OPEN_MARKER_CATEGORY + r">lic|use|lim|act|rul|cpy|dst|lnk|env|pol|met)"
                                     r"\#"
                                     r"(?P<" + OPEN_MARKER_NAME + r">[A-Za-z0-9\-]+)"
                                                                  r"(?:="
                                                                  r"(?P<" + OPEN_MARKER_WERT + r">"
                                                                                               r"\"(?:\\.|[^\"\\])*\"|[^\]\r\n]+"
                                                                                               r")"
                                                                                               r"|"
                                                                                               r"\s+(?P<val_ws>[^\]]+?)"
                                                                                               r")?"
                                                                                               r"\s*\]\]"
)

CLOSE_REGEX = re.compile(
    r"\[\[\s*/\s*"
    r"(?P<" + CLOSE_MARKER_CATEGORY + r">lic|use|lim|act|rul|cpy|dst|lnk|env|pol|met)"
                                      r"\#"
                                      r"(?P<" + CLOSE_MARKER_NAME + r">[A-Za-z0-9\-]+)"
                                                                    r"\s*\]\]"
)

# Kombiniertes Suchmuster
MASTER_REGEX = re.compile(
    OPEN_OR_SINGLETON_REGEX.pattern + r"|" + CLOSE_REGEX.pattern,
    re.DOTALL,
    )

# Literal [[ bzw. ]] im Text (escaped)
ESCAPED_OPEN_MARKER = r"\[\["
ESCAPED_CLOSE_MARKER = r"\]\]"


# -------------------- String-Helfer ------------------------------------------
def lastpos(content: str) -> int:
    return len(content) - 1


def nextpos(pos: int) -> int:
    return pos + 1


def last_char(content: str) -> str:
    return content[-1]


def first_char(content: str) -> str:
    return content[0]


def is_string_part(content: str) -> bool:
    return (
            len(content) >= 2
            and first_char(content) == DOPPELTES_HOCHKOMMA
            and last_char(content) == DOPPELTES_HOCHKOMMA
    )


def unquote_value(content: str | None) -> str:
    if content is None:
        return ""
    content = content.strip()
    if is_string_part(content):
        unquoted_value: list[str] = []
        pos: int = 1
        while pos < lastpos(content):
            cur_char = content[pos]
            if cur_char == "\\" and nextpos(pos) < lastpos(content):
                next_char = content[nextpos(pos)]
                if next_char == "n":
                    unquoted_value.append("\n")
                elif next_char == "t":
                    unquoted_value.append("\t")
                elif next_char in [DOPPELTES_HOCHKOMMA, "\\", "[", "]"]:
                    unquoted_value.append(next_char)
                else:
                    unquoted_value.append(next_char)
                pos += 2
            else:
                unquoted_value.append(cur_char)
                pos = nextpos(pos)
        return "".join(unquoted_value)
    return content


def unquote_marker(text: str) -> str:
    return text.replace(ESCAPED_OPEN_MARKER, OPEN_MARKER).replace(ESCAPED_CLOSE_MARKER, CLOSE_MARKER)


# -------------------- pol: KV-Parsing + Status + IF→Emoji-Label -------------
_KV_PAIR_RE = re.compile(
    r"\s*([A-Za-z_][A-Za-z0-9_\-]*)\s*=\s*(?:\"((?:\\.|[^\"\\])*)\"|([^\s;]+))\s*;?"
)


def parse_kv_attributes(s: str) -> dict[str, str]:
    if not s:
        return {}
    out: dict[str, str] = {}
    s = unquote_value(s)
    pos = 0
    while pos < len(s):
        m = _KV_PAIR_RE.match(s, pos)
        if not m:
            break
        key = m.group(1)
        val = m.group(2) if m.group(2) is not None else m.group(3)
        if val is None:
            val = ""
        out[key] = val
        pos = m.end()
    return out


def normalize_then_to_status(then_val: str | None) -> str | None:
    if not then_val:
        return None
    t = then_val.strip().lower()
    if t in {"allow", "allowed,allow", "allowed", "permit", "permitted", "yes", "ok", "green", "gruen", "grün"}:
        return "green"
    if t in {"deny", "denied", "forbid", "forbidden", "block", "no", "red", "rot"}:
        return "red"
    if t in {"conditional", "maybe", "depends", "it-depends", "yellow", "gelb"}:
        return "yellow"
    return "yellow"


def make_policy_if_label(if_raw: str | None) -> str | None:
    """
    Baut aus einem if-String wie
        "env=com,use=lib,dst=public,cpy=strong"
    eine Anzeigeform wie
        "🏢 📚 🌍 🔴"
    Optional gefolgt von Textteilen, falls es weitere Bedingungen gibt.
    """
    if not if_raw:
        return None

    parts = [p.strip() for p in if_raw.split(",") if p.strip()]
    env_emojis: list[str] = []
    use_emojis: list[str] = []
    dst_emojis: list[str] = []
    cpy_emojis: list[str] = []
    other_parts: list[str] = []

    for p in parts:
        if "=" not in p:
            other_parts.append(p)
            continue

        key, val = p.split("=", 1)
        key = key.strip()
        val = val.strip()

        if key == "env":
            em = ENV_EMOJI.get(val)
            if em:
                env_emojis.append(em)
            else:
                other_parts.append(p)
        elif key == "use":
            em = USE_EMOJI.get(val)
            if em:
                use_emojis.append(em)
            else:
                other_parts.append(p)
        elif key == "dst":
            em = DST_EMOJI.get(val)
            if em:
                dst_emojis.append(em)
            else:
                other_parts.append(p)
        elif key == "cpy":
            em = CPY_EMOJI.get(val)
            if em:
                cpy_emojis.append(em)
            else:
                other_parts.append(p)
        else:
            other_parts.append(p)

    emoji_chunks: list[str] = []
    emoji_chunks.extend(env_emojis)
    emoji_chunks.extend(use_emojis)
    emoji_chunks.extend(dst_emojis)
    emoji_chunks.extend(cpy_emojis)

    label_parts: list[str] = []

    if emoji_chunks:
        label_parts.append(" ".join(emoji_chunks))

    if other_parts:
        # Falls zusätzliche textuelle Bedingungen existieren, hinten anhängen
        suffix = ",".join(other_parts)
        if label_parts:
            label_parts.append(" " + suffix)
        else:
            label_parts.append(suffix)

    if label_parts:
        return "".join(label_parts)

    # Falls nichts erkannt wurde, gib den Rohwert zurück
    return if_raw


# -------------------- Hilfsfunktionen für Notes/Metadaten --------------------
def enrich_note_metadata(note: dict, cat: str, name: str) -> None:
    """
    Fügt generische Metadaten in note['attrs'] ein:
      - category: lic/use/env/...
      - name: z.B. spdx, com, lib
      - emoji: für env/use/dst/cpy (falls vorhanden)
    """
    attrs = note.setdefault("attrs", {})
    attrs["category"] = cat
    attrs["name"] = name

    emoji: str | None = None
    if cat == "env":
        emoji = ENV_EMOJI.get(name)
    elif cat == "use":
        emoji = USE_EMOJI.get(name)
    elif cat == "dst":
        emoji = DST_EMOJI.get(name)
    elif cat == "cpy":
        emoji = CPY_EMOJI.get(name)

    if emoji:
        attrs["emoji"] = emoji


# -------------------- Dateien kopieren ---------------------------------------
def copy_text_file(src_dir: str, dst_dir: str) -> None:
    src_path = Path(src_dir)
    dst_path = Path(dst_dir)
    print(f"Von: {src_path} Nach: {dst_path}")
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_path, dst_path)


# -------------------- Hauptkonvertierung -------------------------------------
def konvertiere(inp: str = "input.liz", out_txt: str = "output.txt", out_xml: str = "output.xml") -> None:
    print(f"Verarbeite: {inp}")
    text_raw = Path(inp).read_text(encoding="utf-8")
    text = unicodedata.normalize("NFC", text_raw)

    cur_pos = 0
    out_buf: list[str] = []
    out_len = 0

    open_stacks: dict[str, list[dict]] = {}
    notes: list[dict] = []
    auto_seq = 0

    for treffer in MASTER_REGEX.finditer(text):
        chunk = text[cur_pos:treffer.start()]
        chunk = unquote_marker(chunk)
        out_buf.append(chunk)
        out_len += len(chunk)

        mo_open = OPEN_OR_SINGLETON_REGEX.match(treffer.group(0))
        if mo_open:
            cat = mo_open.group(OPEN_MARKER_CATEGORY)
            name = mo_open.group(OPEN_MARKER_NAME)
            raw_val = mo_open.group(OPEN_MARKER_WERT) or mo_open.group("val_ws")
            val = unquote_value(raw_val) if raw_val is not None else None

            tag_key = f"{cat}#{name}"
            is_singleton_by_vocab = (tag_key in SINGLETON_TAGS) or (cat in SINGLETON_CATEGORIES)
            is_singleton_with_label = (val is not None)

            if is_singleton_by_vocab or is_singleton_with_label:
                auto_seq += 1
                note: dict = {"id": f"a{auto_seq}", "type": tag_key, "label": val}
                enrich_note_metadata(note, cat, name)

                if cat == "pol":
                    # pol-Notes: VALUE wird als KV-Paare interpretiert
                    attrs = parse_kv_attributes(raw_val or "")
                    status = attrs.get("status") or normalize_then_to_status(attrs.get("then"))
                    if status:
                        attrs["status"] = status
                    tooltip = attrs.get("because") or attrs.get("grund") or attrs.get("why")
                    if tooltip:
                        attrs["title"] = tooltip

                    # Emoji-Label aus if=... bauen
                    if "if" in attrs:
                        nice_label = make_policy_if_label(attrs["if"])
                        if nice_label:
                            attrs.setdefault("label", nice_label)

                    if attrs:
                        # in bestehende attrs-Struktur einblenden
                        note_attrs = note.setdefault("attrs", {})
                        note_attrs.update(attrs)

                notes.append(note)
            else:
                auto_seq += 1
                frame: dict = {
                    "id": f"a{auto_seq}",
                    "type": tag_key,
                    "start": out_len,
                }
                enrich_note_metadata(frame, cat, name)
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
            frame = stack.pop()
            frame["end"] = out_len
            notes.append(frame)

        cur_pos = treffer.end()

    tail = text[cur_pos:]
    tail = tail.replace(ESCAPED_OPEN_MARKER, OPEN_MARKER).replace(ESCAPED_CLOSE_MARKER, CLOSE_MARKER)
    out_buf.append(tail)
    out_len += len(tail)

    dangling: list[str] = []
    for tag_key, stack in open_stacks.items():
        for fr in stack:
            dangling.append(f'{tag_key} (id={fr["id"]}, start={fr["start"]})')
    if dangling:
        raise ValueError("Nicht geschlossene Bereiche: " + ", ".join(dangling) + f" in {inp}")

    has_pol = any(n.get("type", "").startswith("pol#") for n in notes)
    if has_pol:
        auto_seq += 1
        notes.append({"id": f"a{auto_seq}", "type": "pol#_section", "attrs": {"present": "true"}})

    plain_text = "".join(out_buf)
    Path(out_txt).write_text(plain_text, encoding="utf-8")
    print(f" --> {out_txt}")

    # -------------------- Zusatz: colorIndex für Spans berechnen -------------
    # Wir bestimmen für alle Spans (mit start/end) den Typ-Index (sortiert nach @type)
    # und rechnen ihn in colorIndex 1..8 um (wie bisher im XSLT).
    span_notes = [n for n in notes if "start" in n and "end" in n]
    unique_types: list[str] = []
    for n in span_notes:
        t = n.get("type")
        if t is not None and t not in unique_types:
            unique_types.append(t)
    unique_types.sort()
    type_index_map = {t: i + 1 for i, t in enumerate(unique_types)}

    for n in span_notes:
        t = n.get("type")
        if not t:
            continue
        idx = type_index_map.get(t, 1)
        color_index = idx % 8
        if color_index == 0:
            color_index = 8
        attrs = n.setdefault("attrs", {})
        attrs.setdefault("colorIndex", str(color_index))

    # -------------------- XML schreiben --------------------------------------
    def xml_attr_pair(k: str, v: str | None) -> str | None:
        if v is None:
            return None
        return f'{k}={quoteattr(str(v))}'

    lines: list[str] = [
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
        '<!DOCTYPE annotation SYSTEM "annotation.dtd">',
        '<?xml-stylesheet type="text/xsl" href="style.xsl"?>',
        '<?thomas-schubert document-status="draft" version="2.1"?>',
        '<annotation>',
        '  <text xml:space="preserve">',
        html.escape(plain_text),
        '  </text>',
        '  <notes>',
    ]

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
        # value wäre hier nur Altlast (wird derzeit nicht gesetzt)
        if ("attrs" not in sp or not sp["attrs"]) and sp.get("value") is not None:
            attrs.append(xml_attr_pair("value", sp["value"]))
        for k, v in (sp.get("attrs") or {}).items():
            attrs.append(xml_attr_pair(k, v))
        attrs = [a for a in attrs if a is not None]
        lines.append("    <note " + " ".join(attrs) + "/>")

    # Singletons ausgeben
    for sg in singletons:
        attrs = [
            xml_attr_pair("id", sg.get("id")),
            xml_attr_pair("type", sg.get("type")),
        ]
        # label als Standardattribut, falls keine attrs existieren
        if ("attrs" not in sg or not sg["attrs"]) and sg.get("label") is not None:
            attrs.append(xml_attr_pair("label", sg["label"]))

        for k, v in (sg.get("attrs") or {}).items():
            attrs.append(xml_attr_pair(k, v))

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
