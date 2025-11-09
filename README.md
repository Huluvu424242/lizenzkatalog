[![OSPOLizenzkatalog-Logo](src/img/ospolizenzkatalog_100x100.png "KI generiert by ChatGPT©️2025")](src/img/ospolizenzkatalog.png)
# [OSPO](https://de.wikipedia.org/wiki/Open_Source_Program_Office) **Lizenzkatalog**

> Ein leichtgewichtiges, erweiterbares System zur Analyse und Bewertung von Softwarelizenzen auf Basis von Plaintext-Annotationen, Standoff‑XML und XSLT‑Visualisierung.  
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
  - [6. Kopyleft‑Stärke (cpy)](#6-kopyleftstärke-cpy)
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

Der **OSPO Lizenzkatalog** ist ein erweiterbares und anpassbares System zur **Analyse und Bewertung von Softwarelizenzen**. Es bietet:

- ein Register der gängigsten Lizenzen ([Lizenzkatalog](http://huluvu424242.github.io/lizenzkatalog/)),
- eine einheitliche **Annotation-Systematik** für Lizenztexte,
- Werkzeuge zur **automatischen Extraktion, Transformation und Visualisierung** der Annotationen.

Das System kann sowohl **online** (z. B. via GitHub Pages) als auch **on premise** (lokal beim Nutzer) betrieben werden. Es richtet sich insbesondere an Organisationen mit einem **Open Source Program Office (OSPO)**, kann aber ebenso von Einzelpersonen, Unternehmen und Behörden genutzt werden.

---

## Idee

Die Annotation erfolgt in **Plaintext-Dateien (`*.liz`)**. Ein Python-Skript wandelt diese in **Standoff‑XML** (mit Zeichen‑Offsets) um. Ein **XSLT‑Stylesheet** rendert die Annotationen anschließend im Browser als übersichtliche Tabellen und farbige Textstellen. **Überlappende Annotationen** werden explizit unterstützt.

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

Eine gerenderte Auswertung ist im Online‑Katalog einsehbar, z. B.:  
👉 **ODC‑BY‑1.0 – TEI-Auswertung**: https://huluvu424242.github.io/lizenzkatalog/ODC-By-1.0.tei.xml

---

# Systematik

Die **Systematik** strukturiert Annotationen für die spätere Auswertung. Es gibt **Block‑Tags** (mit Start‑ und Endmarkierung) und **Single‑Tags** (ohne Endmarkierung).

> **Block‑Tag**: `[[bereich#schlüssel]] … [[/bereich#schlüssel]]`  
> **Single‑Tag**: `[[bereich#schlüssel[="wert"]]]`

Die Bereiche:

- **Allgemein, Nutzungsart, Begrenzung, Aktionen, Pflichten/Folgen, Kopyleft‑Stärke, Verbreitungsmodus, Kopplung, Umgebung, Bewertung (Policy), Metadaten**

---

## 1. Allgemein (`lic`)

Allgemeine Eigenschaften / Metadaten der Lizenz.

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `name` | Lizenzname | **Block** | `[[lic#name]]GPL-3.0[[/lic#name]]` |
| `spdx` | SPDX‑ID | **Single** | `[[lic#spdx="GPL-3.0-only"]]` |
| `fsf` | FSF Approved | **Single** | `[[lic#fsf]]` |
| `osi` | OSI Approved | **Single** | `[[lic#osi]]` |
| `c` | Alle Rechte vorbehalten | **Single** | `[[lic#c]]` |
| `c0` | Public Domain | **Single** | `[[lic#c0]]` |

---

## 2. Nutzungsart (`use`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `doc` | Dokumentation | **Block** | `[[use#doc]]…[[/use#doc]]` |
| `lib` | Bibliothek / Abhängigkeit | **Block** | `[[use#lib]]…[[/use#lib]]` |
| `app` | Lokale Anwendung | **Block** | `[[use#app]]…[[/use#app]]` |
| `cld` | Cloud‑Anwendung | **Block** | `[[use#cld]]…[[/use#cld]]` |

---

## 3. Begrenzung (`lim`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `pc` | Anzahl Rechner | **Block** | `[[lim#pc]]…[[/lim#pc]]` |
| `dev` | Anzahl Geräte | **Block** | `[[lim#dev]]…[[/lim#dev]]` |
| `srv` | Anzahl Server | **Block** | `[[lim#srv]]…[[/lim#srv]]` |
| `cpu` | Anzahl CPUs | **Block** | `[[lim#cpu]]…[[/lim#cpu]]` |
| `krn` | Anzahl CPU‑Kerne | **Block** | `[[lim#krn]]…[[/lim#krn]]` |
| `usr` | Anzahl Nutzer | **Block** | `[[lim#usr]]…[[/lim#usr]]` |

---

## 4. Aktionen (`act`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `cop` | Kopieren / Vervielfältigen | **Block** | `[[act#cop]]…[[/act#cop]]` |
| `mod` | Modifikation | **Block** | `[[act#mod]]…[[/act#mod]]` |
| `mov` | Weitergabe / Verbreitung | **Block** | `[[act#mov]]…[[/act#mov]]` |
| `sel` | Verkauf / Kommerzialisierung | **Block** | `[[act#sel]]…[[/act#sel]]` |
| `der` | Ableiten / Integration | **Block** | `[[act#der]]…[[/act#der]]` |

---

## 5. Pflichten / Folgen (`rul`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `nolia` | Haftungsausschluss (Warranty Disclaimer) | **Block** | `[[rul#nolia]]…[[/rul#nolia]]` |
| `by` | Namensnennung | **Block** | `[[rul#by]]…[[/rul#by]]` |
| `sa` | Share‑Alike | **Block** | `[[rul#sa]]…[[/rul#sa]]` |
| `nd` | Keine Bearbeitung | **Block** | `[[rul#nd]]…[[/rul#nd]]` |
| `nodrm` | Keine DRM | **Block** | `[[rul#nodrm]]…[[/rul#nodrm]]` |
| `nomili` | Keine militärische Nutzung | **Block** | `[[rul#nomili]]…[[/rul#nomili]]` |
| `nc` | Nicht‑kommerziell | **Block** | `[[rul#nc]]…[[/rul#nc]]` |
| `com` | Kommerzielle Nutzung erlaubt | **Block** | `[[rul#com]]…[[/rul#com]]` |
| `edu` | Bildung | **Block** | `[[rul#edu]]…[[/rul#edu]]` |
| `gov` | Behörden | **Block** | `[[rul#gov]]…[[/rul#gov]]` |
| `src` | Quellcodepflicht | **Block** | `[[rul#src]]…[[/rul#src]]` |
| `notice` | Copyright‑/Hinweispflicht | **Single** | `[[rul#notice]]` |
| `lictxt` | Lizenztext beifügen | **Single** | `[[rul#lictxt]]` |
| `changes` | Änderungen kennzeichnen | **Single** | `[[rul#changes]]` |
| `pat` | Patentlizenz gewährt | **Single** | `[[rul#pat]]` |
| `patret` | Patentretaliation | **Single** | `[[rul#patret]]` |
| `tivo` | Anti‑Tivoization | **Single** | `[[rul#tivo]]` |

---

## 6. Kopyleft‑Stärke (`cpy`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `none` | Kein Copyleft | **Single** | `[[cpy#none]]` |
| `weak` | Schwaches Copyleft | **Single** | `[[cpy#weak]]` |
| `strong` | Starkes Copyleft | **Single** | `[[cpy#strong]]` |
| `network` | Netzwerkkopyleft | **Single** | `[[cpy#network]]` |

---

## 7. Verbreitungsmodus (`dst`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `none` | Keine Weitergabe | **Single** | `[[dst#none]]` |
| `internal` | Interne Nutzung | **Single** | `[[dst#internal]]` |
| `partners` | Weitergabe an Partner | **Single** | `[[dst#partners]]` |
| `public` | Öffentliche Verteilung | **Single** | `[[dst#public]]` |
| `srv` | Nur Serverseite | **Single** | `[[dst#srv]]` |
| `cli` | Clientseitige Auslieferung | **Single** | `[[dst#cli]]` |

---

## 8. Kopplung (`lnk`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `api` | Lose Kopplung (API/Netzwerk/IPC) | **Single** | `[[lnk#api]]` |
| `dyn` | Dynamisches Linken / Plug‑in | **Single** | `[[lnk#dyn]]` |
| `sta` | Statisches Linken | **Single** | `[[lnk#sta]]` |

---

## 9. Umgebung (`env`)

| Schlüssel | Bedeutung | Tag‑Typ | Beispiel |
|---|---|---|---|
| `com` | Kommerziell | **Single** | `[[env#com]]` |
| `edu` | Bildung | **Single** | `[[env#edu]]` |
| `sci` | Wissenschaft | **Single** | `[[env#sci]]` |
| `prv` | Privat | **Single** | `[[env#prv]]` |
| `oss` | OSS‑Umfeld | **Single** | `[[env#oss]]` |
| `gov` | Behörden | **Single** | `[[env#gov]]` |
| `ngo` | Gemeinnützig | **Single** | `[[env#ngo]]` |

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
- `then`: Ergebnis/Rating (z. B. *grün*, *gelb*, *rot*).
- `because`: Begründung, die im Bericht angezeigt wird.
- `scope`: Geltungsbereich (z. B. `license`, `textspan`).
- `span`: Verstärkende/kontextgebende Annotationen (Bereich:Schlüssel + …).

---

## Technische Umsetzung

1. **Python** (`src/liz2standoff.py`)
   - erzeugt `output.txt` (Plaintext ohne Marker)
   - erzeugt `output.xml` (Standoff‑Annotationen mit 0‑basierten, end‑exklusiven Offsets)

2. **XSLT 1.0** (`src/styles/liz2table-style.xsl`)
   - Darstellung der Annotationen als HTML‑Tabelle und farbige Textstellen
   - kann direkt im Browser genutzt werden (XML + XSL im selben Verzeichnis)

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

Die Datei [`src/styles/liz2table-style.xsl`](src/styles/liz2table-style.xsl) ist ein **XSLT‑1.0**‑Stylesheet und lässt sich im Browser auf das erzeugte `output.xml` anwenden.

---

## Hinweise

- Offsets sind **0‑basiert** und **end‑exklusiv**.
- Eingabetexte werden **Unicode‑NFC** normalisiert (stabile Offsets).
- **IDs sind Pflicht** bei **überlappenden Bereichen**.
- **Single‑Tags** besitzen **kein schließendes Gegenstück**.
- Für die **SPDX‑ID** kann die offizielle Liste referenziert werden (z. B. `[[lic#spdx="Apache-2.0"]]`).

---

## Mitarbeit / Contributions

Mitmachen ist ausdrücklich willkommen (Erweiterungen der Systematik, neue Lizenz‑Annotationen, Verbesserungen von Skript und Stylesheet). Bitte Pull Requests mit klaren Commits und kurzen Testdaten beilegen.

