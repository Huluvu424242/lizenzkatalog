![OSPOLizenkatalog-Logo](lizenzkatalog/img/ospolizenzkatalog.png){width=100px height=100px}]
# OSPO Lizenzkatalog
## Projektziel

Das Projekt stellt ein erweiterbares und anpassbares System zur Analyse und Bewertung von Lizenzen 
nebst eines Registers mit Bewertungen der gängigsten Lizenzen (Lizenzkatalog) 
für den Einsatz im Umfeld einer OSPO (oder eines Nutzers) bereit. 

Hiermit soll die OSPO (oder der Nutzer)
Unterstützung bei der Analyse und Bewertung von Lizenzen im eigenen Umfeld erhalten.

Das System ist frei einsetzbar und kann auch 1:1 on premise auf einem beim Nutzer 
gehosteten github genutzt werden. 

Auch sind eigene Anpassungen der Systematik an die besoneren Bedürfnisse des Nutzers möglich. 



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

# Systematik
Details der Systematik zur Annotierung von Lizenztexten um diese analysieren und bewerten zu können. 
Die Systematik untergliedert sich in folgende Bereiche( Allgemein, Nutzungsart, Begrenzung, Aktionen, Pflichten/Folgen, Bewertung und Umgebung):

## Allgemein (lic): 
* name: Name der Lizenz
 ```[[lic#name]]...[[/lic#name]]```
* spdx: SPDX ID der Lizenz
 ```[[lic#spdx=IDBezeichner]]```
* fsf: FSF Approved
 ```[[lic#fsf]]```
* OSI: OSI Approved
 ```[[lic#osi]]```
* c: Alle Rechte vorbehalten
 ```[[lic#c]]```
* c0: Nutzung uneingeschränkt
 ```[[lic#c0]]```

## Nutzungsart (use): 
* doc:: Dokumentation
 ```[[use#doc]]...[[/use#doc]]```
* lib: Softwarekomponente, Bibliothek als Abhängigkeit
 ```[[use#lib]]...[[/use#lib]]```
* app: Eigenständige lokale Anwendung
 ```[[use#app]]...[[/use#app]]```
* cld: Eigenständige Cloud Anwendung
 ```[[use#cld]]...[[/use#cld]]```

## Begrenzung (lim)
* pc: Anzahl Rechner
 ```[[lim#pc]]...[[/lim#pc]]```
* dev: Anzahl Geräte (Drucker etc.)
 ```[[lim#dev]]...[[/lim#dev]]```
* srv: Anzahl Server
 ```[[lim#srv]]...[[/lim#srv]]```
* cpu: Anzahl CPU
 ```[[lim#cpu]]...[[/lim#cpu]]```
* krn: Anzahl Kerne
 ```[[lim#krn]]...[[/lim#krn]]```
* usr: Anzahl Nutzer
 ```[[lim#usr]]...[[/lim#usr]]```

## Aktionen (act):
* cop: Vervielfältigung, Kopieren
 ```[[act#cop]]...[[/act#cop]]```
* mod: Verändern, Modifikation
 ```[[act#mod]]...[[/act#mod]]```
* mov: Verteilen, Verbreiten
 ```[[act#mov]]...[[/act#mov]]```
* sel: Verkaufen
 ```[[act#sel]]...[[/act#sel]]```
* der: Derive, Ableiten, Einbau in eigene Software
 ```[[act#der]]...[[/act#der]]```

## Pflichten/Folgen (rul):
* nolia: Haftungsausschluss, Warranty Disclaimer
 ```[[rul#nolia]]...[[/rul#nolia]]```
* by: Namensnennung
 ```[[rul#by]]...[[/rul#by]]```
* sa: Weitergabe unter gleicher Lizenz
 ```[[rul#sa]]...[[/rul#sa]]```
* nd: Keine Modifikation
 ```[[rul#nd]]...[[/rul#nd]]```
* nodrm: Keine technischen Schutzmaßnahmen wie Kpierschutz erlaubt
 ```[[rul#nodrm]]...[[/rul#nodrm]]```
* nomili: Keine Militärische Nutzung
 ```[[rul#nomili]]...[[/rul#nomili]]```
* nc: Keine Kommerzielle Nutzung
 ```[[rul#nc]]...[[/rul#nc]]```
* com: Kommerzielle Nutzung
 ```[[rul#com]]...[[/rul#com]]```
* edu: Nutzung in Bildung oder Forschung
 ```[[rul#edu]]...[[/rul#edu]]```
* psi: Nutzung in Behörden, Verwaltungen
 ```[[rul#psi]]...[[/rul#psi]]```


## Bewertung (eval):
* grün: uneingeschränkt einsetzbar
  ```[[eval#grün ]]```
* gelb: eingeschränkt einsetzbar
  ```[[eval#gelb ]]```
* rot: nicht einsetzbar
  ```[[eval#rot ]]```
## Umgebung (env):
* Kommerzielle Unternehmen oder als kommerziell eingestufte juristische Personen (Orgs, Vereine etc.)
  ```[[env#com ]]```
* Schulen, Bildung, Kinderbetreuung
  ```[[env#edu ]]```
* Forschung, Universitäten, Bibliotheken
  ```[[env#sci ]]```
* Private Nutzung
  ```[[env#prv ]]```  
* OSS Umfeld (freie OSS Entwickler, unentgeltlich arbeitende Vereine)
  ```[[env#oss ]]```

# Annotationsbeispiele
## Analyse

  Beispiel Haftungsausschluss
  ```
  8.2 [[rul#nolia]]If liability may not be excluded by law, it is limited to actual and direct financial loss to the extent it is caused by proved negligence on the part of the Licensor.[[/rul#nolia]]
  ```


  Beispiel Verbreitung eingeschränkt:
  ```
  Goethe [[person#p1 ref="gnd:118540238"]]Johann W. v. Goethe[[/person#p1]]
  war ein [[relation#r1]]Freund von [[person#p2]]Schiller[[/person#p2]][[/relation#r1]].
  ```
## Bewertung

*
* ```[[eval#grün ]]```

# Projekt und Mitarbeit

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
python3 src/liz2standoff.py examples/gpl-3.0.liz     build/gpl-3.0.txt     build/gpl-3.0.tei.xml
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
java -jar saxon-he.jar -s:build/apache-2.0.xml -xsl:src/xslt/liz2table-style.xsl -o:build/apache-2.0.html

# GPL
java -jar saxon-he.jar -s:build/gpl-3.0.tei.xml -xsl:src/xslt/liz2table-style.xsl -o:build/gpl-3.0.html
```

## Hinweise
- Offsets sind 0-basiert und end-exklusiv.
- Eingabetexte werden NFC-normalisiert, damit Offsets stabil bleiben.
- IDs sind Pflicht bei überlappenden Spannen.
