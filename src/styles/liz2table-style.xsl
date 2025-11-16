<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html"
                indent="yes"
                encoding="UTF-8"
                doctype-system="about:legacy-compat"/>

    <xsl:strip-space elements="annotation notes note text"/>

    <!-- ================================
         Hilfsfunktionen
       ================================ -->

    <!-- Label-Mapping für note/@type -->
    <xsl:template name="label-for-type">
        <xsl:param name="t"/>
        <xsl:choose>
            <!-- Lizenz / Regeln -->
            <xsl:when test="$t='lic#name'">Lizenzname</xsl:when>
            <xsl:when test="$t='rul#src'">Quellenangabe</xsl:when>
            <xsl:when test="$t='rul#changes'">Änderungen kennzeichnen</xsl:when>
            <xsl:when test="$t='rul#nolia'">Haftungsausschluss</xsl:when>

            <!-- Beispiel für Policy-Rahmenbedingungen -->
            <xsl:when test="$t='pol#frame'
                           or $t='pol#rahmen'
                           or $t='pol#conditions'">
                Rahmenbedingungen
            </xsl:when>

            <!-- weitere spezielle Typen hier ergänzen -->

            <!-- Fallback -->
            <xsl:otherwise>
                <xsl:value-of select="$t"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Farb-Mapping pro note/@type (für Text-Hervorhebung) -->
    <xsl:template name="color-for-type">
        <xsl:param name="t"/>
        <xsl:choose>
            <xsl:when test="$t='lic#name'">#d0ebff</xsl:when>      <!-- hellblau -->
            <xsl:when test="$t='rul#src'">#e8f5e9</xsl:when>       <!-- hellgrün -->
            <xsl:when test="$t='rul#changes'">#fff3e0</xsl:when>   <!-- hellorange -->
            <xsl:when test="$t='rul#nolia'">#ffebee</xsl:when>     <!-- hellrot -->
            <!-- ggf. weitere Typenfarben -->
            <xsl:otherwise>#eeeeee</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Emoji-Badges mit Tooltip für env=… -->
    <xsl:template name="env-badge">
        <xsl:param name="code"/>

        <!-- Emoji je Kategorie -->
        <xsl:variable name="emoji">
            <xsl:choose>
                <xsl:when test="$code='com'">🏢</xsl:when>
                <xsl:when test="$code='edu'">🎓</xsl:when>
                <xsl:when test="$code='sci'">🔬</xsl:when>
                <xsl:when test="$code='prv'">🏡</xsl:when>
                <xsl:when test="$code='oss'">🐧</xsl:when>
                <xsl:when test="$code='gov'">🏛️</xsl:when>
                <xsl:when test="$code='ngo'">🤝</xsl:when>
                <xsl:otherwise>❓</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Tooltip je Kategorie -->
        <xsl:variable name="tooltip">
            <xsl:choose>
                <xsl:when test="$code='com'">
                    env=com – Kommerzielle Nutzung in Unternehmen oder Organisationen
                </xsl:when>
                <xsl:when test="$code='edu'">
                    env=edu – Nutzung in Bildungseinrichtungen
                </xsl:when>
                <xsl:when test="$code='sci'">
                    env=sci – Wissenschaftliche Nutzung und Forschung
                </xsl:when>
                <xsl:when test="$code='prv'">
                    env=prv – Private, nicht-kommerzielle Nutzung
                </xsl:when>
                <xsl:when test="$code='oss'">
                    env=oss – Nutzung im Open-Source-Umfeld
                </xsl:when>
                <xsl:when test="$code='gov'">
                    env=gov – Öffentliche Verwaltung und Behörden
                </xsl:when>
                <xsl:when test="$code='ngo'">
                    env=ngo – Gemeinnützige Organisationen und NGOs
                </xsl:when>
                <xsl:otherwise>
                    env=? – unbekannte Umgebung
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <span class="env env-{$code}">
            <xsl:attribute name="title">
                <xsl:value-of select="normalize-space($tooltip)"/>
            </xsl:attribute>
            <xsl:value-of select="$emoji"/>
        </span>
    </xsl:template>

    <!-- ================================
         Text-Hervorhebung per Standoff
       ================================ -->

    <!-- Haupt-Template für das Dokument -->
    <xsl:template match="/annotation">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>Lizenzannotation</title>
                <style type="text/css">
                    body {
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                    margin: 1.5rem;
                    }
                    h1, h2 {
                    font-weight: 600;
                    }
                    .layout {
                    display: grid;
                    grid-template-columns: 3fr 2fr;
                    gap: 2rem;
                    align-items: flex-start;
                    }
                    pre.text {
                    background: #fafafa;
                    border: 1px solid #ddd;
                    padding: 1rem;
                    white-space: pre-wrap;
                    line-height: 1.4;
                    }
                    .hl {
                    border-radius: 3px;
                    box-shadow: inset 0 0 0 1px rgba(0,0,0,0.07);
                    }
                    table.notes {
                    border-collapse: collapse;
                    width: 100%;
                    font-size: 0.9rem;
                    }
                    table.notes th,
                    table.notes td {
                    border: 1px solid #ddd;
                    padding: 0.3rem 0.4rem;
                    vertical-align: top;
                    }
                    table.notes th {
                    background: #f0f0f0;
                    }
                    .note-type {
                    font-weight: 600;
                    }
                    .note-label {
                    color: #333;
                    }
                    .env {
                    margin-left: 0.25rem;
                    font-size: 1.1em;
                    cursor: help;
                    }
                </style>
            </head>
            <body>
                <h1>Lizenzannotation</h1>

                <div class="layout">
                    <!-- linker Bereich: Originaltext mit Hervorhebungen -->
                    <div>
                        <h2>Lizenztext</h2>
                        <pre class="text">
                            <xsl:call-template name="render-text-with-notes"/>
                        </pre>
                    </div>

                    <!-- rechter Bereich: Annotationstabelle -->
                    <div>
                        <h2>Annotationen</h2>
                        <table class="notes">
                            <tr>
                                <th>#</th>
                                <th>Typ</th>
                                <th>Label</th>
                                <th>Position</th>
                                <th>Env</th>
                            </tr>
                            <xsl:for-each select="notes/note">
                                <xsl:sort select="number(@start)" data-type="number" order="ascending"/>
                                <tr>
                                    <td>
                                        <xsl:value-of select="position()"/>
                                    </td>
                                    <td class="note-type">
                                        <xsl:variable name="t" select="@type"/>
                                        <xsl:call-template name="label-for-type">
                                            <xsl:with-param name="t" select="$t"/>
                                        </xsl:call-template>
                                    </td>
                                    <td class="note-label">
                                        <xsl:value-of select="@label"/>
                                    </td>
                                    <td>
                                        <xsl:text>[</xsl:text>
                                        <xsl:value-of select="@start"/>
                                        <xsl:text> – </xsl:text>
                                        <xsl:value-of select="@end"/>
                                        <xsl:text>]</xsl:text>
                                    </td>
                                    <td>
                                        <xsl:if test="@env">
                                            <xsl:call-template name="env-badge">
                                                <xsl:with-param name="code" select="@env"/>
                                            </xsl:call-template>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

    <!-- Rendern des Textes mit Hervorhebung anhand notes/@start/@end -->
    <xsl:template name="render-text-with-notes">
        <!-- Gesamter Text als String -->
        <xsl:variable name="txt" select="string(text)"/>

        <!-- Alle Notizen sortiert nach Startposition -->
        <xsl:for-each select="notes/note">
            <xsl:sort select="number(@start)" data-type="number" order="ascending"/>

            <!-- Start/Ende dieser Note (0-basierte Indizes aus der TEI-Annot) -->
            <xsl:variable name="start" select="number(@start)"/>
            <xsl:variable name="end"   select="number(@end)"/>

            <!-- Vorheriger Endpunkt = max(@end) aller vorangehenden Notizen -->
            <xsl:variable name="prev-end">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="../note[number(@start) &lt; $start]">
                            <xsl:sort select="number(@end)" data-type="number" order="ascending"/>
                            <xsl:if test="position() = last()">
                                <xsl:value-of select="@end"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- 1) Zwischenraum zwischen letzter Note und dieser Note -->
            <xsl:if test="number($prev-end) &lt; $start">
                <xsl:value-of select="substring($txt,
                                                number($prev-end) + 1,
                                                $start - number($prev-end))"/>
            </xsl:if>

            <!-- 2) Markiertes Segment für diese Note -->
            <xsl:variable name="seg"
                          select="substring($txt,
                                            $start + 1,
                                            $end - $start)"/>

            <xsl:variable name="t" select="@type"/>
            <xsl:variable name="bg">
                <xsl:call-template name="color-for-type">
                    <xsl:with-param name="t" select="$t"/>
                </xsl:call-template>
            </xsl:variable>

            <span class="hl">
                <xsl:attribute name="style">
                    <xsl:text>background-color:</xsl:text>
                    <xsl:value-of select="$bg"/>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$seg"/>
            </span>

            <!-- Nach der letzten Note: Rest-Text ausgeben -->
            <xsl:if test="position() = last()">
                <xsl:variable name="final-end" select="$end"/>
                <xsl:if test="string-length($txt) &gt; $final-end">
                    <xsl:value-of select="substring($txt,
                                                    $final-end + 1)"/>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!-- Falls es gar keine Notizen gibt, einfach den Text ausgeben -->
        <xsl:if test="not(notes/note)">
            <xsl:value-of select="$txt"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
