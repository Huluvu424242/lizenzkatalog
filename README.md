# license-annotator

Ein leichtgewichtiges Tooling, um **überlappende Annotationen** in Plaintext-Dateien (`*.liz`) zu erfassen,
danach **standoff-XML** zu generieren und die Ergebnisse mit **XSLT** zu visualisieren.

## Idee

1. Plaintext mit eigenen Markern:
   - Start: `[[typ#id key="value" ...]]`
   - Ende:  `[[/typ#id]]`

   Beispiel:
   ```
   Goethe [[person#p1 ref="gnd:118540238"]]Johann W. v. Goethe[[/person#p1]]
   war ein [[relation#r1]]Freund von [[person#p2]]Schiller[[/person#p2]][[/relation#r1]].
   ```

2. Python-Skript erzeugt
   - `output.txt` (reiner Text ohne Marker)
   - `output.xml` (standoff-Annotationen mit start/end Offsets)

3. XSLT 2.0 zeigt die Annotationen als HTML-Tabelle an.

## Verzeichnisstruktur

```
license-annotator/
├─ README.md
├─ requirements.txt
├─ .gitignore
├─ .github/workflows/ci.yml
├─ examples/
│  ├─ apache-2.0.liz
│  └─ gpl-3.0.liz
├─ src/
│  ├─ liz2standoff.py
│  └─ xslt/
│     └─ standoff2table.xsl
└─ build/              # Ausgabeordner für CI und lokale Läufe
```

## Nutzung (lokal)

```bash
python3 src/liz2standoff.py examples/apache-2.0.liz build/apache-2.0.txt build/apache-2.0.xml
python3 src/liz2standoff.py examples/gpl-3.0.liz     build/gpl-3.0.txt     build/gpl-3.0.xml
```

Optional: Alle `*.liz` in `examples/` verarbeiten:
```bash
for f in examples/*.liz; do
  base=$(basename "$f" .liz)
  python3 src/liz2standoff.py "$f" "build/$base.txt" "build/$base.xml"
done
```

## Visualisierung

Die Datei `src/xslt/standoff2table.xsl` ist ein **XSLT 2.0** Stylesheet.  
Du kannst sie mit Saxon (CLI) anwenden oder mit Saxon-JS im Browser nutzen.

Beispiel (Saxon HE CLI):
```bash
# Apache 2.0
java -jar saxon-he.jar -s:build/apache-2.0.xml -xsl:src/xslt/standoff2table.xsl -o:build/apache-2.0.html

# GPL
java -jar saxon-he.jar -s:build/gpl-3.0.xml -xsl:src/xslt/standoff2table.xsl -o:build/gpl-3.0.html
```

## Hinweise
- Offsets sind 0-basiert und end-exklusiv.
- Eingabetexte werden NFC-normalisiert, damit Offsets stabil bleiben.
- IDs sind Pflicht bei überlappenden Spannen.
