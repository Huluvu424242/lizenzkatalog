[![OSPOLizenkatalog-Logo](src/img/ospolizenzkatalog_100x100.png)](src/img/ospolizenzkatalog.png)
# [OSPO Lizenzkatalog](https://de.wikipedia.org/wiki/Open_Source_Program_Office)
## Projektziel

Das Projekt stellt ein erweiterbares und anpassbares System zur Analyse und Bewertung von Lizenzen 
nebst eines Registers mit Bewertungen der gängigsten Lizenzen (Lizenzkatalog) 
für den Einsatz im Umfeld einer OSPO (oder eines Nutzers) bereit. 

Hiermit soll die OSPO (oder der Nutzer)
Unterstützung bei der Analyse und Bewertung von Lizenzen im eigenen Umfeld erhalten.

Das System ist frei einsetzbar und kann auch 1:1 on premise auf einem beim Nutzer 
gehosteten github Portal genutzt werden. 

Auch sind eigene Anpassungen der Systematik an die besonderen Bedürfnisse des Nutzers möglich. 





## Idee
Die Idee besteht in einem leichtgewichtiges Tooling, bei dem  **(auch überlappende) Annotationen** in 
Plaintext-Dateien (`*.liz`) erfasst werden können. Danach werden **standoff-XML** Dateien generiert und 
die Ergebnisse über **XSLT** im Browser visualisiert.

Beispiel Linzenz in Plaintext mit eigenen Markern:

**Datei:** `odc_by_1.0_public_text.liz`
```text title="odc_by_1.0_public_text.liz"
# [[lic#name]]ODC Attribution License (ODC-By)[[/lic#name]]
[[lic#spdx="ODC-By-1.0"]]
### Preamble
:
:
[[rul#nolia]]
8.2 If liability may not be excluded by law, it is limited to actual and
direct financial loss to the extent it is caused by proved negligence on
the part of the Licensor.
[[/rul#nolia]]

```
Das Ergebnis einer solchen Annotation sieht man im Online [Lizenzkatalog](lizenzkatalog/index.html) oder speziell zum Beispiel hier 
in der Auswertung zur [Lizeng ODC-BY Version 1](https://huluvu424242.github.io/lizenzkatalog/odc_by_1.0_public_text.tei.xml)


# Systematik
Details der Systematik zur Annotierung von Lizenztexten um diese analysieren und bewerten zu können. 
Die Systematik untergliedert sich in folgende Bereiche( Allgemein, Nutzungsart, Begrenzung, Aktionen, Pflichten/Folgen, Bewertung und Umgebung):

## Allgemein (lic): 
* name: Name der Lizenz
 ```[[lic#name]]...[[/lic#name]]```
* spdx: SPDX ID der Lizenz
 ```[[lic#spdx=IDBezeichner]]```  Quelle: https://spdx.org/licenses/licenses.json
* fsf: FSF Approved
 ```[[lic#fsf]]```  Quelle: https://spdx.org/licenses/licenses.json
* OSI: OSI Approved
 ```[[lic#osi]]```  Quelle: https://spdx.org/licenses/licenses.json
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

# Technische Umsetzung

2. Python-Skript erzeugt
   - `output.txt` (reiner Text ohne Marker)
   - `output.xml` (standoff-Annotationen mit start/end Offsets)

3. XSLT 2.0 zeigt die Annotationen als HTML-Tabelle an.

## Verzeichnisstruktur

```
ospo-lizenzkatalog/
├─ README.md
├─ pyprojekt.toml
├─ .gitignore
├─ .github/workflows/ci.yml
├─ lizenzkatalog/
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
python3 src/liz2standoff.py 
```
## Visualisierung

Die Datei [`src/xslt/liz2table-style.xsl`](src/xslt/liz2table-style.xsl) ist
ein **XSLT 1.0** Stylesheet. Diese kann direkt im Browser genutzt werden. 


## Hinweise
- Offsets sind 0-basiert und end-exklusiv.
- Eingabetexte werden NFC-normalisiert, damit Offsets stabil bleiben.
- IDs sind Pflicht bei überlappenden Spannen.

# Mitarbeit / Contributions
TODO noch festzulegen