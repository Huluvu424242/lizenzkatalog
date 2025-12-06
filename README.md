[![OSPOLizenzkatalog-Logo](src/img/ospolizenzkatalog_100x100.png "KI generiert by ChatGPT©️2025")](src/img/ospolizenzkatalog.png)

# [OSPO](https://de.wikipedia.org/wiki/Open_Source_Program_Office) **Lizenzkatalog**

> Ein leichtgewichtiges, erweiterbares System zur Analyse und Bewertung von Softwarelizenzen auf Basis von
> Plaintext-Annotationen, Standoff‑XML und XSLT‑Visualisierung.  
> Online-Demo: [Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/)

---

## Inhaltsverzeichnis

- [Projektziel](#projektziel)
- [Idee](#idee)
    - [Beispiel einer Annotation](#beispiel-einer-annotation)
- [Systematik](#systematik)
    - [1. Allgemein (lic)](#1-allgemein-lic)
    - [2. Nutzungsart (use)](#2-nutzungsart-use)
    - [3. Begrenzung (lim)](#3-begrenzung-lim)
    - [4. Aktionen (act)](#4-aktionen-act)
    - [5. Pflichten / Folgen (rul)](#5-pflichten--folgen-rul)
    - [6. Copyleft‑Stärke (cpy)](#6-copyleftstärke-cpy)
    - [7. Verbreitungsmodus (dst)](#7-verbreitungsmodus-dst)
    - [8. Kopplung (lnk)](#8-kopplung-lnk)
    - [9. Umgebung (env)](#9-umgebung-env)
    - [10. Bewertung / Policy (pol)](#10-bewertung--policy-pol)
- [Technische Umsetzung](#technische-umsetzung)
- [Verzeichnisstruktur](#verzeichnisstruktur)
- [Nutzung (lokal)](#nutzung-lokal)
- [Visualisierung](#visualisierung)
- [Hinweise](#hinweise)
- [Mitarbeit / Contributions](#mitarbeit--contributions)

---

## Projektziel

Der **OSPO Lizenzkatalog** ist ein erweiterbares und anpassbares System zur **Analyse und Bewertung von Softwarelizenzen
**. Es bietet:

- ein Register der gängigsten Lizenzen ([Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/)),
- eine einheitliche **Annotation-Systematik** für Lizenztexte,
- Werkzeuge zur **automatischen Extraktion, Transformation und Visualisierung** der Annotationen.

Das System kann sowohl **online** (z. B. via GitHub Pages) als auch **on premise** (lokal beim Nutzer) betrieben werden.
Es richtet sich insbesondere an Organisationen mit einem **Open Source Program Office (OSPO)**, kann aber ebenso von
Einzelpersonen, Unternehmen und Behörden genutzt werden.

---

## Idee

Die Annotation erfolgt in **Plaintext-Dateien (`*.liz`)**. Ein Python-Skript wandelt diese in **Standoff‑XML** (mit
Zeichen‑Offsets) um. Ein **XSLT‑Stylesheet** rendert die Annotationen anschließend im Browser als übersichtliche
Tabellen und farbige Textstellen. **Überlappende Annotationen** werden explizit unterstützt.

### Beispiel einer Annotation

**Datei:** `odc_by_1.0_public_text.liz`

```text
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

Eine gerenderte Auswertung ist im Online‑Katalog einsehbar, z. B.:  
👉 **ODC‑BY‑1.0 – TEI-Auswertung**: https://huluvu424242.github.io/lizenzkatalog/ODC-By-1.0.tei.xml

---

# Systematik

Die **Systematik** strukturiert Annotationen für die spätere Auswertung. Es gibt **Block‑Tags** (mit Start‑ und
Endmarkierung) zum Referenzieren auf wichtige Textpassagen innerhalb der Lizenz, und **Single‑Tags** (ohne
Endmarkierung) um das Vorhandensein spezieller Eigenschaften bei der annotierten
Lizenz hervorzuheben.

> **Block‑Tag**: `[[bereich#schlüssel]] … [[/bereich#schlüssel]]`  
> **Single‑Tag**: `[[bereich#schlüssel[="wert"]]]`

Die Annotationen lassen sich den folgenden Themenbereichen zuordnen.

Die Bereiche:

- **Allgemein, Nutzungsart, Begrenzung, Aktionen, Pflichten/Folgen, Copyleft‑Stärke, Verbreitungsmodus, Kopplung,
  Umgebung, Bewertung (Policy), Metadaten**

---

## 1. Allgemein (`lic`)

Allgemeine Eigenschaften / Metadaten der Lizenz.

| Schlüssel | Bedeutung               | Tag‑Typ    | Beispiel                           |
|-----------|-------------------------|------------|------------------------------------|
| `name`    | Lizenzname              | **Block**  | `[[lic#name]]GPL-3.0[[/lic#name]]` |
| `spdx`    | SPDX‑ID                 | **Single** | `[[lic#spdx="GPL-3.0-only"]]`      |
| `fsf`     | FSF Approved            | **Single** | `[[lic#fsf]]`                      |
| `osi`     | OSI Approved            | **Single** | `[[lic#osi]]`                      |
| `c`       | Alle Rechte vorbehalten | **Single** | `[[lic#c]]`                        |
| `c0`      | Public Domain           | **Single** | `[[lic#c0]]`                       |

---

## 2. Nutzungsart (`use`)

Beschreibt die Eignung der Lizenz zur Lizensierung von bestimmten Produktarten. Wobei eine Lizenz
durchaus für mehrere Produktarten sinnvoll sein kann. Lizenz ist geeigent für:

| Schlüssel | Bedeutung                                                   | Tag‑Typ    | Beispiel      |
|-----------|-------------------------------------------------------------|------------|---------------|
| `doc`     | Dokumentation                                               | **Single** | `[[use#doc]]` |
| `lib`     | Software Bibliotheken / Plugins oder anderen Abhängigkeiten | **Single** | `[[use#lib]]` |
| `app`     | Anwendungen (Desktop, Server, Mobile, ...)                  | **Single** | `[[use#app]]` |
| `cld`     | Cloud‑Anwendungen                                           | **Single** | `[[use#cld]]` |

---

## 3. Begrenzung (`lim`)

Die Lizenz enthält Angaben zu Einschränkungen bezüglich der Anzahlen folgender Dinge:

| Schlüssel | Bedeutung        | Tag‑Typ   | Beispiel                   |
|-----------|------------------|-----------|----------------------------|
| `pc`      | Anzahl Rechner   | **Block** | `[[lim#pc]]…[[/lim#pc]]`   |
| `dev`     | Anzahl Geräte    | **Block** | `[[lim#dev]]…[[/lim#dev]]` |
| `srv`     | Anzahl Server    | **Block** | `[[lim#srv]]…[[/lim#srv]]` |
| `cpu`     | Anzahl CPUs      | **Block** | `[[lim#cpu]]…[[/lim#cpu]]` |
| `krn`     | Anzahl CPU‑Kerne | **Block** | `[[lim#krn]]…[[/lim#krn]]` |
| `usr`     | Anzahl Nutzer    | **Block** | `[[lim#usr]]…[[/lim#usr]]` |

---

## 4. Aktionen (`act`)

Die Lizenz geht speziell auf bestimmte Verwendungen des Lizenzgegenstandes ein.

| Schlüssel | Bedeutung                    | Tag‑Typ   | Beispiel                   |
|-----------|------------------------------|-----------|----------------------------|
| `cop`     | Kopieren / Vervielfältigen   | **Block** | `[[act#cop]]…[[/act#cop]]` |
| `mod`     | Modifikation                 | **Block** | `[[act#mod]]…[[/act#mod]]` |
| `mov`     | Weitergabe / Verbreitung     | **Block** | `[[act#mov]]…[[/act#mov]]` |
| `sel`     | Verkauf / Kommerzialisierung | **Block** | `[[act#sel]]…[[/act#sel]]` |
| `der`     | Ableiten / Integration       | **Block** | `[[act#der]]…[[/act#der]]` |

---

## 5. Pflichten / Folgen (`rul`)

In der Lizenz werden aufgeführte Pflichten und Folgen beschrieben.

| Schlüssel | Bedeutung                                | Tag‑Typ    | Beispiel                         |
|-----------|------------------------------------------|------------|----------------------------------|
| `nolia`   | Haftungsausschluss (Warranty Disclaimer) | **Block**  | `[[rul#nolia]]…[[/rul#nolia]]`   |
| `by`      | Namensnennung                            | **Block**  | `[[rul#by]]…[[/rul#by]]`         |
| `sa`      | Share‑Alike                              | **Block**  | `[[rul#sa]]…[[/rul#sa]]`         |
| `nd`      | Keine Bearbeitung                        | **Block**  | `[[rul#nd]]…[[/rul#nd]]`         |
| `nodrm`   | Keine DRM                                | **Block**  | `[[rul#nodrm]]…[[/rul#nodrm]]`   |
| `nomili`  | Keine militärische Nutzung               | **Block**  | `[[rul#nomili]]…[[/rul#nomili]]` |
| `nc`      | Keine kommerzielle Nutzung               | **Block**  | `[[rul#nc]]…[[/rul#nc]]`         |
| `com`     | Kommerzielle Nutzung erlaubt             | **Block**  | `[[rul#com]]…[[/rul#com]]`       |
| `edu`     | Bildung                                  | **Block**  | `[[rul#edu]]…[[/rul#edu]]`       |
| `gov`     | Behörden                                 | **Block**  | `[[rul#gov]]…[[/rul#gov]]`       |
| `src`     | Quellcodepflicht                         | **Block**  | `[[rul#src]]…[[/rul#src]]`       |
| `notice`  | Copyright‑/Hinweispflicht                | **Single** | `[[rul#notice]]`                 |
| `lictxt`  | Lizenztext beifügen                      | **Single** | `[[rul#lictxt]]`                 |
| `changes` | Änderungen kennzeichnen                  | **Single** | `[[rul#changes]]`                |
| `pat`     | Patentlizenz gewährt                     | **Single** | `[[rul#pat]]`                    |
| `patret`  | Patentretaliation                        | **Single** | `[[rul#patret]]`                 |
| `tivo`    | Anti‑Tivoization                         | **Single** | `[[rul#tivo]]`                   |

---

## 6. Copyleft‑Stärke (`cpy`)

Quantifizierung der Stärke des durch die Lizenz geforderten Copylefts.

| Schlüssel | Bedeutung          | Tag‑Typ    | Beispiel          |
|-----------|--------------------|------------|-------------------|
| `none`    | Kein Copyleft      | **Single** | `[[cpy#none]]`    |
| `weak`    | Schwaches Copyleft | **Single** | `[[cpy#weak]]`    |
| `strong`  | Starkes Copyleft   | **Single** | `[[cpy#strong]]`  |
| `network` | Netzwerk-Copyleft  | **Single** | `[[cpy#network]]` |

---

## 7. Verbreitungsmodus (`dst`)

Veraltet: Dieser Abschnitt wird zukünftig nur in den Bewertungen Anwendung finden.

| Schlüssel  | Bedeutung                  | Tag‑Typ    | Beispiel           |
|------------|----------------------------|------------|--------------------|
| `none`     | Keine Weitergabe           | **Single** | `[[dst#none]]`     |
| `internal` | Interne Nutzung            | **Single** | `[[dst#internal]]` |
| `partners` | Weitergabe an Partner      | **Single** | `[[dst#partners]]` |
| `public`   | Öffentliche Verteilung     | **Single** | `[[dst#public]]`   |
| `srv`      | Nur Serverseite            | **Single** | `[[dst#srv]]`      |
| `cli`      | Clientseitige Auslieferung | **Single** | `[[dst#cli]]`      |

---

## 8. Kopplung (`lnk`)

Veraltet: Dieser Abschnitt wird zukünftig nur in den Bewertungen Anwendung finden.

| Schlüssel | Bedeutung                        | Tag‑Typ    | Beispiel      |
|-----------|----------------------------------|------------|---------------|
| `api`     | Lose Kopplung (API/Netzwerk/IPC) | **Single** | `[[lnk#api]]` |
| `dyn`     | Dynamisches Linken / Plug‑in     | **Single** | `[[lnk#dyn]]` |
| `sta`     | Statisches Linken                | **Single** | `[[lnk#sta]]` |

---

## 9. Umgebung (`env`)

Veraltet: Dieser Abschnitt wird zukünftig nur in den Bewertungen Anwendung finden.

| Schlüssel | Symbol            | Bedeutung    | Tag‑Typ    | Beispiel      |
|-----------|-------------------|--------------|------------|---------------|
| `com`     | &#x1F3E2;         | Kommerziell  | **Single** | `[[env#com]]` |
| `edu`     | &#x1F393;         | Bildung      | **Single** | `[[env#edu]]` |
| `sci`     | &#x1F52C;         | Wissenschaft | **Single** | `[[env#sci]]` |
| `prv`     | &#x1F6CB;&#xFE0F; | Privat       | **Single** | `[[env#prv]]` |
| `oss`     | &#x1F680;         | OSS‑Umfeld   | **Single** | `[[env#oss]]` |
| `gov`     | &#x1F3DB;&#xFE0F; | Behörden     | **Single** | `[[env#gov]]` |
| `ngo`     | &#x1F499;         | Gemeinnützig | **Single** | `[[env#ngo]]` |

---

## 10. Bewertung / Policy (`pol`)

Manuell gepflegte Bewertung/Richtlinie für konkrete Nutzungsszenarien.

**Syntax-Beispiel**

```text
[[pol#if="env=com,use=lib,dst=internal+srv,cpy=network"
      then="gelb"
      because="AGPL intern ok; kein Client-Code an Dritte."
      scope="license"
      span="rul:src+cpy:network"]]
```

**Erläuterungen**

- `if`: Kommagetrennte Bedingungen; Mehrfachwerte mit `+` (UND) kombinieren.
- `then`: Ergebnis/Rating (z. B. *grün*, *gelb*, *rot*).
- `because`: Begründung, die im Bericht angezeigt wird.
- `scope`: Geltungsbereich (z. B. `license`, `textspan`).
- `span`: Verstärkende/kontextgebende Annotationen (Bereich:Schlüssel + …).

---

## Technische Umsetzung

1. **Python** (`src/liz2standoff.py`)
    - erzeugt `output.txt` (Plaintext ohne Marker)
    - erzeugt `output.xml` (Standoff‑Annotationen mit 0‑basierten, end‑exklusiven Offsets)

2. **XSLT 1.0** (`src/styles/liz2table-style.xsl`)
    - Darstellung der Annotationen als HTML‑Tabelle und farbige Textstellen
    - kann direkt im Browser genutzt werden (XML + XSL im selben Verzeichnis)

## Logik der Singleton und Bereichs Tags
siehe Dokumentation der [Taglogik](./src/site/hinweise/lizenzkatalog_taglogik.md)

---

## Verzeichnisstruktur

```text
ospo-lizenzkatalog/
├─ README.md
├─ pyproject.toml
├─ .github/workflows/ci.yml
├─ lizenzkatalog/
│  ├─ apache-2.0.liz
│  └─ gpl-3.0.liz
├─ src/
│  ├─ liz2standoff.py
│  └─ styles/
│     └─ liz2table-style.xsl
└─ build/              # Ausgabeordner für CI und lokale Läufe
```

---

## Nutzung (lokal)

```bash
python3 src/liz2standoff.py
```

Die Ausgaben werden unter `build/` abgelegt (konfigurationsabhängig).

---

## Visualisierung

Die Datei [`src/styles/liz2table-style.xsl`](src/styles/liz2table-style.xsl) ist ein **XSLT‑1.0**‑Stylesheet und lässt
sich im Browser auf das erzeugte `output.xml` anwenden.

---

## Hinweise

- Offsets sind **0‑basiert** und **end‑exklusiv**.
- Eingabetexte werden **Unicode‑NFC** normalisiert (stabile Offsets).
- **IDs sind Pflicht** bei **überlappenden Bereichen**.
- **Single‑Tags** besitzen **kein schließendes Gegenstück**.
- Für die **SPDX‑ID** kann die offizielle Liste referenziert werden (z. B. `[[lic#spdx="Apache-2.0"]]`).

---

## Mitarbeit / Contributions

Mitmachen ist ausdrücklich willkommen (Erweiterungen der Systematik, neue Lizenz‑Annotationen, Verbesserungen von Skript
und Stylesheet). Bitte Pull Requests mit klaren Commits und kurzen Testdaten beilegen.

