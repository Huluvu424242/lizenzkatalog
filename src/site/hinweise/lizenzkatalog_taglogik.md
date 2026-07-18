# Lizenzkatalog – Verhalten von Tags: Bereiche, Singletons & Default-Labels

Diese Dokumentation beschreibt das Verhalten der Tags innerhalb des Python‑Parsers
(`generate_site.py`). Sie erklärt die Regeln für **Bereiche**, **Singletons** und
**Default-Labels**, sowie deren Zusammenspiel.

---

# 1. Grundprinzip: Zwei Arten von Tags

Tags im `.liz`‑Format können auf zwei Arten auftreten:

## **1. Bereiche (Ranges)**  
Beispiel:
```
[[rul#notice]] … Textstelle … [[/rul#notice]]
```

→ Wird zu einem XML‑Note mit **start** und **end**:
```xml
<note type="rul#notice" start="..." end="..." …/>
```

---

## **2. Singletons (Einzelmarkierungen)**  
Beispiel:
```
[[lic#spdx=GPL-3.0-only]]
```

→ Wird zu:
```xml
<note type="lic#spdx" label="GPL-3.0-only" …/>
```

Single‑Notes besitzen **kein start/end**.

---

# 2. Entscheidungslogik: Wann ist ein Tag Spanne, wann Singleton?

## ✔ Ein Tag wird **als Singleton** behandelt, wenn mindestens *eine* Regel zutrifft:

### **Regel A — expliziter Wert (`=VALUE`)**
Wenn ein Marker beim Öffnen einen Wert hat:
```
[[cat#name=VALUE]]
[[cat#name VALUE]]
```

→ `val != None` → **Singleton**.

Beispiel:
```
[[rul#notice="Quelltext beilegen"]]
```

Wird **immer Singleton**.

---

### **Regel B — Kategorie ist generell Singleton**
Folgende Kategorien erzeugen IMMER Singletons:

```
env, use, dst, cpy, lnk, pol, met
```

Beispiel:
```
[[env#com]]
[[cpy#strong]]
```

→ Immer Singleton.

---

### **Regel C — Tag steht in SINGLETON_TAGS**
Beispiel:
```
lic#spdx
lic#fsf
lic#osi
```

→ Immer Singleton, unabhängig von Syntax.

---

## ✔ Ein Tag wird **als Bereich** behandelt, wenn:

### ❗ Es *keinen* Value besitzt  
UND  
### ❗ Es *nicht* in einer Singleton-Kategorie ist  
UND  
### ❗ Es *nicht* in SINGLETON_TAGS enthalten ist  

Beispiel (gültige Bereiche):
```
[[rul#notice]]
Der Lizenztext … 
[[/rul#notice]]
```

---

# 3. Default-Labels – was sie tun (und was nicht)

Du kannst für jedes Tag ein Default‑Label definieren:

```python
DEFAULT_LABELS = {
    "cpy#strong": "Wirkt sich immer auf das Gesamtwerk aus",
    "cpy#weak": "Wirkt sich nur bedingt auf das Gesamtwerk aus",
    "lic#fsf": "Von der FSF empfohlen",
    "lic#osi": "Von der OSI anerkannt",
    ...
}
```

## ✔ Wann wird das Default-Label gesetzt?

Nur wenn:

- das Tag **kein** explizites Label hat  
- und **kein** Value angegeben wurde  
- und das Tag bereits vollständig eingelesen wurde (also NACH der Entscheidung „Span oder Singleton“)

---

## ❗ Entscheidend:

### **Default-Labels beeinflussen NICHT, ob ein Tag Bereich oder Singleton ist.**

Denn:

- Die Entscheidung erfolgt **beim Einlesen des Öffnungstags**  
- Default-Labels werden **erst später** eingesetzt  

Daraus folgt:

### ➜ Ein Tag bleibt Bereich, auch wenn in `DEFAULT_LABELS` ein Text eingetragen ist.

Beispiel:

```
[[rul#notice]]…[[/rul#notice]]
```

→ wird ein Bereich, selbst wenn `DEFAULT_LABELS["rul#notice"]` existiert.

---

# 4. Verhältnis: Default-Label vs. Explizites Value

| Syntax | Verhalten                                 |
|--------|-------------------------------------------|
| `[[rul#notice]] … [[/rul#notice]]` | Bereich, Default-Label wird gesetzt       |
| `[[rul#notice=Pflicht]]` | **Singleton**, Value überschreibt Default |
| `[[rul#notice Pflicht]]` | **Singleton**, Value überschreibt Default |

---

# 5. Hybride Tags – sowohl Spanne als auch Singleton möglich

Ein Tag, das NICHT in `SINGLETON_CATEGORIES`  
und NICHT in `SINGLETON_TAGS` steht, kann:

### ✔ als Bereich genutzt werden:  
```
[[rul#pat]]…[[/rul#pat]]
```

### ✔ oder als Singleton genutzt werden:  
```
[[rul#pat=Patentfreigabe erforderlich]]
```

Ideal für Dinge wie Regeln, Hinweise, Einschränkungen.

---

# 6. Summary-Tabelle

| Fall | Syntax | Ergebnis                                          |
|------|--------|---------------------------------------------------|
| Spanne | `[[rul#x]] ... [[/rul#x]]` | start/end                                         |
| Singleton durch Value | `[[rul#x=...]]` | ohne start/end                                    |
| Singleton-Kategorie | `[[env#x]]` | ohne start/end                                    |
| Singleton-Tag | `[[lic#spdx]]` | ohne start/end                                    |
| Default-Label | Automatisch | wird gesetzt, ohne Einfluss auf Bereich/Singleton |

---

# 7. Best Practices

### ✔ Bereiche verwenden, wenn Textstellen zitiert werden müssen.  
### ✔ Singleton verwenden, wenn die Eigenschaft generell gilt, aber nicht zitierbar ist.  
### ✔ Default-Labels definieren, um konsistente Semantik zu erzeugen.  
### ✔ Keine Values setzen, wenn ein Bereich gewünscht ist.  
### ✔ Neue Tags NICHT in `SINGLETON_TAGS` eintragen, wenn sie hybrid bleiben sollen.

---

# 8. Beispiel: Copyleft-Defaults

`.liz`:
```
[[cpy#strong]]
```

`DEFAULT_LABELS`:
```
"cpy#strong": "Wirkt sich immer auf das Gesamtwerk aus"
```

XML:
```xml
<note type="cpy#strong"
      label="Wirkt sich immer auf das Gesamtwerk aus"
      emoji="🔴"
      category="cpy"
      name="strong"/>
```

---

# 9. Beispiel: Hybrid-Tag „rul#notice“

### Bereich:
```
[[rul#notice]]…[[/rul#notice]]
```

### Singleton:
```
[[rul#notice=Quelltext beilegen]]
```

---

# 10. Fazit

- Default-Labels sind sicher.  
- Sie beeinflussen **niemals** die Bereichslogik.  
- Nur explizite Values machen aus einem potenziellen Bereichs-Tag ein Singleton.  
- Die Architektur unterstützt somit elegant beide Nutzungsarten.

---


