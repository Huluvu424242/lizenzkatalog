[![OSPOLizenkatalog-Logo](src/img/ospolizenzkatalog_100x100.png  "KI generiert by ChatGPT©️2025")](src/img/ospolizenzkatalog.png)
# [OSPO](https://de.wikipedia.org/wiki/Open_Source_Program_Office) [Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/) 
## Projektziel

Das Projekt stellt ein erweiterbares und anpassbares System zur Analyse und Bewertung von Lizenzen 
nebst eines Registers mit Bewertungen der gängigsten Lizenzen ([Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/)) 
für den Einsatz im Umfeld einer [OSPO](https://de.wikipedia.org/wiki/Open_Source_Program_Office)
(oder eines Nutzers) bereit. 

Hiermit soll die [OSPO](https://de.wikipedia.org/wiki/Open_Source_Program_Office) (oder der Nutzer)
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
Das Ergebnis einer solchen Annotation sieht man im Online [Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/) oder speziell zum Beispiel hier 
in der Auswertung zur [Lizenz ODC-BY Version 1](https://huluvu424242.github.io/lizenzkatalog/odc_by_1.0_public_text.tei.xml)

# Systematik

Details der Systematik zur Annotierung von Lizenztexten, um diese analysieren und bewerten zu können.  
Die Systematik untergliedert sich in folgende Bereiche:  
**Allgemein, Nutzungsart, Begrenzung, Aktionen, Pflichten/Folgen, Kopyleft-Stärke, Verbreitungsmodus, Kopplung, Umgebung, Bewertung (Policy) und Metadaten.**

---

## Allgemein (`lic`)

Allgemeine Angaben zur Lizenz selbst.

* **name**: Name der Lizenz  
  ```[[lic#name]]...[[/lic#name]]```

* **spdx**: SPDX-ID der Lizenz  
  ```[[lic#spdx=IDBezeichner]]```  
  Quelle: [https://spdx.org/licenses/licenses.json](https://spdx.org/licenses/licenses.json)

* **fsf**: FSF Approved  
  ```[[lic#fsf]]```

* **osi**: OSI Approved  
  ```[[lic#osi]]```

* **c**: Alle Rechte vorbehalten  
  ```[[lic#c]]```

* **c0**: Nutzung uneingeschränkt / Public Domain  
  ```[[lic#c0]]```

---

## Nutzungsart (`use`)

Beschreibt, in welcher Form die Software verwendet wird.

* **doc**: Dokumentation  
  ```[[use#doc]]...[[/use#doc]]```

* **lib**: Softwarekomponente oder Bibliothek als Abhängigkeit  
  ```[[use#lib]]...[[/use#lib]]```

* **app**: Eigenständige lokale Anwendung  
  ```[[use#app]]...[[/use#app]]```

* **cld**: Eigenständige Cloud-Anwendung  
  ```[[use#cld]]...[[/use#cld]]```

---

## Begrenzung (`lim`)

Definiert quantitative Nutzungseinschränkungen.

* **pc**: Anzahl Rechner  
  ```[[lim#pc]]...[[/lim#pc]]```

* **dev**: Anzahl Geräte (z. B. Drucker)  
  ```[[lim#dev]]...[[/lim#dev]]```

* **srv**: Anzahl Server  
  ```[[lim#srv]]...[[/lim#srv]]```

* **cpu**: Anzahl CPUs  
  ```[[lim#cpu]]...[[/lim#cpu]]```

* **krn**: Anzahl CPU-Kerne  
  ```[[lim#krn]]...[[/lim#krn]]```

* **usr**: Anzahl Nutzer  
  ```[[lim#usr]]...[[/lim#usr]]```

---

## Aktionen (`act`)

Beschreibt, welche Handlungen mit der Software erlaubt oder untersagt sind.

* **cop**: Kopieren / Vervielfältigung  
  ```[[act#cop]]...[[/act#cop]]```

* **mod**: Modifikation / Veränderung  
  ```[[act#mod]]...[[/act#mod]]```

* **mov**: Verteilen / Verbreiten  
  ```[[act#mov]]...[[/act#mov]]```

* **sel**: Verkauf / kommerzielle Weitergabe  
  ```[[act#sel]]...[[/act#sel]]```

* **der**: Ableiten / Integration in eigene Software  
  ```[[act#der]]...[[/act#der]]```

---

## Pflichten / Folgen (`rul`)

Kennzeichnet rechtliche oder praktische Pflichten, Einschränkungen und Folgen.

* **nolia**: Haftungsausschluss / Warranty Disclaimer  
  ```[[rul#nolia]]...[[/rul#nolia]]```

* **by**: Namensnennung erforderlich  
  ```[[rul#by]]...[[/rul#by]]```

* **sa**: Weitergabe unter gleicher Lizenz (Share-Alike)  
  ```[[rul#sa]]...[[/rul#sa]]```

* **nd**: Keine Modifikation erlaubt (No Derivatives)  
  ```[[rul#nd]]...[[/rul#nd]]```

* **nodrm**: Keine technischen Schutzmaßnahmen (DRM)  
  ```[[rul#nodrm]]...[[/rul#nodrm]]```

* **nomili**: Keine militärische Nutzung  
  ```[[rul#nomili]]...[[/rul#nomili]]```

* **nc**: Keine kommerzielle Nutzung  
  ```[[rul#nc]]...[[/rul#nc]]```

* **com**: Kommerzielle Nutzung erlaubt  
  ```[[rul#com]]...[[/rul#com]]```

* **edu**: Nutzung in Bildung und Forschung erlaubt oder vorgesehen  
  ```[[rul#edu]]...[[/rul#edu]]```

* **gov**: Nutzung in Behörden und Verwaltungen erlaubt oder vorgesehen  
  ```[[rul#gov]]...[[/rul#gov]]```

* **src**: Bereitstellung des Quellcodes erforderlich  
  ```[[rul#src]]...[[/rul#src]]```

* **notice**: Beifügung von Copyright- und Lizenzhinweisen erforderlich  
  ```[[rul#notice]]```

* **lictxt**: Beifügung des Lizenztextes erforderlich  
  ```[[rul#lictxt]]```

* **changes**: Änderungen müssen kenntlich gemacht werden  
  ```[[rul#changes]]```

* **pat**: Patentlizenz wird gewährt  
  ```[[rul#pat]]```

* **patret**: Patentretaliation-Klausel (Widerruf bei Klage)  
  ```[[rul#patret]]```

* **tivo**: Anti-Tivoization (kein Lock-down der Hardware zulässig)  
  ```[[rul#tivo]]```

---

## Kopyleft-Stärke (`cpy`)

Definiert, ab wann und in welcher Form Copyleft-Pflichten greifen.

* **none** – kein Copyleft (z. B. MIT, BSD)  
  ```[[cpy#none]]```

* **weak** – schwaches Copyleft (z. B. LGPL)  
  ```[[cpy#weak]]```

* **strong** – starkes Copyleft (z. B. GPL)  
  ```[[cpy#strong]]```

* **network** – Netzwerkkopyleft (z. B. AGPL)  
  ```[[cpy#network]]```

---

## Verbreitungsmodus (`dst`)

Beschreibt, ob und wie Software oder Teile davon weitergegeben werden.

* **none** – keine Weitergabe  
  ```[[dst#none]]```

* **internal** – interne Nutzung / Verteilung innerhalb des Unternehmens  
  ```[[dst#internal]]```

* **partners** – Weitergabe an Partner oder Kunden unter Auflagen  
  ```[[dst#partners]]```

* **public** – öffentliche Verteilung (z. B. Download, App-Store, Website)  
  ```[[dst#public]]```

* **srv** – ausschließlich serverseitige Nutzung, kein Client-Code  
  ```[[dst#srv]]```

* **cli** – Client-Code wird an Dritte übertragen (z. B. JavaScript, Mobile-App)  
  ```[[dst#cli]]```

---

## Kopplungsart (`lnk`)

Beschreibt die technische Kopplung zwischen lizenzierter und eigener Software.

* **api** – lose Kopplung über API / Netzwerk / IPC  
  ```[[lnk#api]]```

* **dyn** – dynamisches Linken / Plug-in  
  ```[[lnk#dyn]]```

* **sta** – statisches Linken / Zusammenführen im Binary  
  ```[[lnk#sta]]```

---

## Umgebung (`env`)

Gibt an, in welchem Nutzungskontext die Bewertung erfolgt.

* **com** – kommerzielle Unternehmen oder Organisationen  
  ```[[env#com]]```

* **edu** – Schulen, Bildung, Kinderbetreuung  
  ```[[env#edu]]```

* **sci** – Forschung, Universitäten, Bibliotheken  
  ```[[env#sci]]```

* **prv** – private Nutzung  
  ```[[env#prv]]```

* **oss** – OSS-Umfeld (freie Entwickler, gemeinnützige Vereine)  
  ```[[env#oss]]```

* **gov** – Behörden, Verwaltungen, staatliche Einrichtungen  
  ```[[env#gov]]```

* *(optional)* **ngo** – gemeinnützige Organisationen  
  ```[[env#ngo]]```

---

## Bewertung / Policy (`pol`)

Stellt eine manuell gepflegte Bewertung oder Richtlinie dar,  
die den Einsatz einer Lizenz unter bestimmten Bedingungen beschreibt.

**Syntax:**
```text
[[pol#if="env=com,use=lib,dst=internal+srv,cpy=network"
      then="gelb"
      because="AGPL intern ok; kein Client-Code an Dritte."
      scope="license"
      span="rul:src+cpy:network"]]

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

* TODO
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
│  └─ styles/
│     └─ standoff2table.xsl
└─ build/              # Ausgabeordner für CI und lokale Läufe
```

## Nutzung (lokal)

```bash
python3 src/liz2standoff.py 
```
## Visualisierung

Die Datei [`src/styles/liz2table-style.xsl`](src/styles/liz2table-style.xsl) ist
ein **XSLT 1.0** Stylesheet. Diese kann direkt im Browser genutzt werden. 


## Hinweise
- Offsets sind 0-basiert und end-exklusiv.
- Eingabetexte werden NFC-normalisiert, damit Offsets stabil bleiben.
- IDs sind Pflicht bei überlappenden Bereiche.

# Mitarbeit / Contributions
TODO noch festzulegen