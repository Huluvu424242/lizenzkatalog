[![Stories in Ready](https://badge.waffle.io/FunThomas424242/licenses.png?label=ready&title=Ready)](http://waffle.io/FunThomas424242/licenses)

licenses project
================

Ein Projekt zur Katalogisierung von Softwarelizenzen. Ziel des Projektes ist es, dem Nutzer/Entwickler ein Mittel
an die Hand zu geben um eine Einbindung der Software von Drittanbietern bewerten zu können.

Das Projekt orientiert sich dabei an einem 3-stufigen Modell:

1. Aufbau einer Adjazenzmatrix mit der einzelne Verwendungsmöglichkeiten je Lizenz entsprechenden Bedingungen zugeordnet werden.
2. Aufbau eines Werkzeuges zur Bestimmung aller expliziten und impliziten Abhängigkeiten der zu bewertenden Software hinsichtlich 
der Lizenzen der Komponenten von denen sie transitiv abhängig ist.
3. Aufbau eines Werkzeuges welches automatisch auf Grundlage der unter (1) erstellte Adjazenzmatrix und der unter (2) gewonnenen
Informationen Lizenzkonflikte aufzeigt.

Literaturhinweise: 

* [Slide01](http://de.slideshare.net/littk/open-source-lizenzmanagement) Open-Source-Lizenzmanagement (Slides)
* [ENG2012](http://www.bibsonomy.org/bibtex/23ad38e2fbc524230344bc7ea48979620/funthomas424242) (Artikel)
* [MV_LIZ](http://www.cheatography.com/funthomas424242/cheat-sheets/lizenverwaltung-mit-maven/) (Software)
* [LIZVER](http://www.bibsonomy.org/bibtex/2d7fa68b5ddaa4bb2318c3da9e38cf4cb/funthomas424242) (Artikel zur Software)
* [TOSSCA](http://www.tossca.org/) TOSSCA e.V. (Verein zur Herauslösung von Kode als Open Source)
* [Recht] (http://www.bibsonomy.org/user/funthomas424242/Recht) Artikel zu Gerichtsurteilen

Aktueller Arbeitsstand
----------------------

Aktuell wird die [Adjazenzmatrix](https://raw.github.com/FunThomas424242/licenses/master/Lizenzmerkmale.fods) aufgebaut.

Aufbau der Adjazenzmatrix
--------------------------

*Anforderungen*: 

* Die Matrix sollte mit einer freien Spreadsheet Anwendung wie LibreOffice bearbeitet werden können. 
* Die Matrix sollte in einem diffbaren Format abgelegt werden um Pull Requests einarbeiten zu können

Als Format wurde *fods* ausgewählt. 

Ablage erfolgt unter: https://raw.github.com/FunThomas424242/licenses/master/Lizenzmerkmale.fods

Voranalysen und Übersetzungen
-----------------------------

Um die Adjazenzmatrix aufbauen zu können werden Voranalysen benötigt. Dazu werden Übersetzungen oder Extrakte im Internet gesucht
und verwertet. Falls kein ausreichendes Material gefunden werden kann wird selbst versucht eine Übersetzung evtl. 
auch nur teilweise zu erstellen. Der zentrale Einstiegspunkt in die Dokumente findet sich unter
[Analysedokumente](./analysis/Quellen.md)
