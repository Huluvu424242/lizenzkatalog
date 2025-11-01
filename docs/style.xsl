<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- ===== Label-Mapping (wie zuvor) ===== -->
    <xsl:template name="label-for-type">
        <xsl:param name="t"/>
        <xsl:choose>
            <!-- lic -->
            <xsl:when test="$t='lic#name'">Lizenzname</xsl:when>
            <xsl:when test="$t='lic#spdx'">SPDX-ID</xsl:when>
            <xsl:when test="$t='lic#fsf'">FSF-Freigabe</xsl:when>
            <xsl:when test="$t='lic#osi'">OSI-Freigabe</xsl:when>
            <xsl:when test="$t='lic#c'">Alle Rechte vorbehalten</xsl:when>
            <xsl:when test="$t='lic#c0'">Nutzung uneingeschränkt</xsl:when>
            <!-- use -->
            <xsl:when test="$t='use#doc'">Dokumentation</xsl:when>
            <xsl:when test="$t='use#lib'">Bibliothek/Komponente</xsl:when>
            <xsl:when test="$t='use#app'">Lokale Anwendung</xsl:when>
            <xsl:when test="$t='use#cld'">Cloud-Anwendung</xsl:when>
            <!-- lim -->
            <xsl:when test="$t='lim#pc'">Anzahl Rechner</xsl:when>
            <xsl:when test="$t='lim#dev'">Anzahl Geräte</xsl:when>
            <xsl:when test="$t='lim#srv'">Anzahl Server</xsl:when>
            <xsl:when test="$t='lim#cpu'">Anzahl CPUs</xsl:when>
            <xsl:when test="$t='lim#krn'">Anzahl Kerne</xsl:when>
            <xsl:when test="$t='lim#usr'">Anzahl Nutzer</xsl:when>
            <!-- act -->
            <xsl:when test="$t='act#cop'">Vervielfältigung</xsl:when>
            <xsl:when test="$t='act#mod'">Modifikation</xsl:when>
            <xsl:when test="$t='act#mov'">Verbreitung</xsl:when>
            <xsl:when test="$t='act#sel'">Verkauf</xsl:when>
            <xsl:when test="$t='act#der'">Abgeleitete Werke</xsl:when>
            <!-- rul -->
            <xsl:when test="$t='rul#nolia'">Haftungsausschluss</xsl:when>
            <xsl:when test="$t='rul#by'">Namensnennung</xsl:when>
            <xsl:when test="$t='rul#sa'">Share-Alike</xsl:when>
            <xsl:when test="$t='rul#nd'">Keine Bearbeitung</xsl:when>
            <xsl:when test="$t='rul#nodrm'">Kein Kopierschutz</xsl:when>
            <xsl:when test="$t='rul#nomili'">Keine militärische Nutzung</xsl:when>
            <xsl:when test="$t='rul#nc'">Nicht-kommerziell</xsl:when>
            <xsl:when test="$t='rul#com'">Kommerziell</xsl:when>
            <xsl:when test="$t='rul#edu'">Bildung/Forschung</xsl:when>
            <xsl:when test="$t='rul#psi'">Behörden/Verwaltung</xsl:when>
            <!-- fallback -->
            <xsl:otherwise><xsl:value-of select="$t"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Einstieg -->
    <xsl:template match="/">
        <xsl:apply-templates select="/annotation"/>
    </xsl:template>

    <xsl:template match="annotation">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Standoff-Annotationen</title>
                <style>
                    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 1rem; }
                    table { border-collapse: collapse; width: 100%; margin-bottom: 1.5rem; }
                    th, td { border: 1px solid #ddd; padding: .5rem .6rem; text-align: left; vertical-align: top; }
                    th { background: #f6f8fa; }
                    code { background: #f6f8fa; padding: .1rem .25rem; border-radius: 4px; }
                    pre { white-space: pre-wrap; background: #fafafa; border: 1px dashed #ddd; padding: .75rem; }
                    .muted { color: #777; }
                    .warn { color: #b00; font-weight: bold; }
                    .hl-1 { background-color: #fff3cd; }  /* gelb */
                    .hl-2 { background-color: #d1ecf1; }  /* cyan */
                    .hl-3 { background-color: #e2e3e5; }  /* grau */
                    .hl-4 { background-color: #f8d7da; }  /* rosa */
                    .hl-5 { background-color: #d4edda; }  /* grün */
                    h1, h2 { margin: .2rem 0 .6rem 0; }
                </style>
            </head>
            <body>
                <h1>Annotationen</h1>

                <xsl:variable name="txt" select="string(text)"/>

                <!-- ============================== -->
                <!-- Tabelle 1: ohne Textbezug      -->
                <!-- ============================== -->
                <h2>Annotationen ohne Textbezug</h2>
                <table>
                    <tr>
                        <th>#</th>
                        <th>Typ</th>
                        <th>Wert</th>
                        <th>ID</th>
                    </tr>
                    <xsl:for-each select="notes/note[not(@start) or not(@end)]">
                        <xsl:sort select="@type"/>
                        <xsl:variable name="tooltip">
                            <xsl:choose>
                                <xsl:when test="@value"><xsl:value-of select="concat('[[', @type, '=', @value, ']]')"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="concat('[[', @type, ']]')"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <tr>
                            <td><xsl:value-of select="position()"/></td>
                            <td>
                                <span title="{$tooltip}">
                                    <xsl:call-template name="label-for-type">
                                        <xsl:with-param name="t" select="@type"/>
                                    </xsl:call-template>
                                </span>
                            </td>
                            <td><xsl:choose><xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when><xsl:otherwise><span class="muted">–</span></xsl:otherwise></xsl:choose></td>
                            <td><xsl:value-of select="@id"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <xsl:if test="not(notes/note[not(@start) or not(@end)])">
                    <p class="muted">Keine Annotationen ohne Textbezug vorhanden.</p>
                </xsl:if>

                <!-- ============================== -->
                <!-- Tabelle 2: mit Textbezug       -->
                <!-- ============================== -->
                <h2>Annotationen mit Textbezug</h2>
                <table>
                    <tr>
                        <th>#</th>
                        <th>Typ</th>
                        <th>Auszug</th>
                        <th>ID</th>
                        <th>Start Pos</th>
                        <th>End Pos</th>
                    </tr>
                    <xsl:for-each select="notes/note[@start and @end]">
                        <xsl:sort select="number(@start)"/>
                        <xsl:sort select="number(@end)"/>
                        <xsl:variable name="s" select="number(@start)"/>
                        <xsl:variable name="e" select="number(@end)"/>
                        <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s + 1)"/>
                        <xsl:variable name="tooltipSpan" select="concat('[[', @type, ']]...[[/', @type, ']]')"/>
                        <!-- Farbe zyklisch 1..5 -->
                        <xsl:variable name="colorClass">
                            <xsl:choose>
                                <xsl:when test="position() mod 5 = 1">hl-1</xsl:when>
                                <xsl:when test="position() mod 5 = 2">hl-2</xsl:when>
                                <xsl:when test="position() mod 5 = 3">hl-3</xsl:when>
                                <xsl:when test="position() mod 5 = 4">hl-4</xsl:when>
                                <xsl:otherwise>hl-5</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <tr>
                            <!-- Link auf Anker im hervorgehobenen Originaltext -->
                            <td><a href="#frag-{@id}"><xsl:value-of select="position()"/></a></td>
                            <td>
                                <span title="{$tooltipSpan}">
                                    <xsl:call-template name="label-for-type">
                                        <xsl:with-param name="t" select="@type"/>
                                    </xsl:call-template>
                                </span>
                            </td>
                            <td><xsl:value-of select="normalize-space($frag)"/></td>
                            <td><xsl:value-of select="@id"/></td>
                            <td><xsl:value-of select="@start"/></td>
                            <td><xsl:value-of select="@end"/></td>
                        </tr>
                    </xsl:for-each>
                </table>

                <!-- ============================== -->
                <!-- Hervorhebungen im Originaltext  -->
                <!-- ============================== -->
                <xsl:variable name="notesSorted" select="notes/note[@start and @end]">
                    <!-- (nur Referenz, Sortierung unten per for-each) -->
                </xsl:variable>

                <!-- Warnung bei kreuzenden Überlappungen (einfacher Check) -->
                <xsl:variable name="hasOverlap">
                    <xsl:for-each select="notes/note[@start and @end]">
                        <xsl:sort select="number(@start)"/>
                        <xsl:sort select="number(@end)"/>
                        <xsl:if test="position() &gt; 1">
                            <xsl:variable name="prevEnd" select="number(preceding-sibling::note[@start and @end][1]/@end)"/>
                            <xsl:if test="number(@start) &lt; $prevEnd">1</xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="contains(string($hasOverlap),'1')">
                    <p class="warn">Hinweis: Es existieren überlappende/kreuzende Bereiche. Die Darstellung unten hebt nur die
                        nicht-überlappenden Segmente in Reihenfolge hervor.</p>
                </xsl:if>

                <h2>Originaltext (mit Hervorhebungen)</h2>
                <pre>
                    <!-- sortierte Liste der Spannen als temporärer Result-Tree -->
                    <xsl:variable name="sortedSpansRTF">
                        <xsl:for-each select="notes/note[@start and @end]">
                            <xsl:sort select="number(@start)"/>
                            <xsl:sort select="number(@end)"/>
                            <span start="{@start}" end="{@end}" id="{@id}"/>
                        </xsl:for-each>
                    </xsl:variable>

                    <!-- EXSLT node-set, falls verfügbar -->
                    <xsl:variable name="sortedSpans" select="exsl:node-set($sortedSpansRTF)/span"
                                  xmlns:exsl="http://exslt.org/common"/>

                    <!-- Fallback ohne exsl:node-set: viele Prozessoren (libxslt, Saxon 6.5) unterstützen exsl.
                         Falls nicht verfügbar, kannst du die Render-Logik im Python-Skript vor-sortieren und
                         die <note>-Elemente bereits in der gewünschten Reihenfolge ausgeben. -->

                    <xsl:choose>
                        <xsl:when test="$sortedSpans">
                            <!-- rekursives Rendering über die sortierte Liste -->
                            <xsl:call-template name="render-from">
                                <xsl:with-param name="txt" select="string(text)"/>
                                <xsl:with-param name="nodes" select="$sortedSpans"/>
                                <xsl:with-param name="idx" select="1"/>
                                <xsl:with-param name="cursor" select="0"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Fallback: keine Spannen oder kein exsl:node-set -->
                            <xsl:value-of select="string(text)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </pre>

                <!-- ========== Rekursive Templates ========== -->

                <!-- Gibt den Text bis zum Ende aus, indem es nacheinander Spannen einfärbt.
                     - txt: kompletter Text
                     - nodes: sortierte <span>-Liste (Attribute: start, end, id)
                     - idx: 1-basierter Index im nodes-NodeSet
                     - cursor: zuletzt ausgegebene Endposition (0-basiert, end-exklusiv) -->
                <xsl:template name="render-from" xmlns:exsl="http://exslt.org/common">
                    <xsl:param name="txt"/>
                    <xsl:param name="nodes"/>
                    <xsl:param name="idx"/>
                    <xsl:param name="cursor"/>

                    <xsl:choose>
                        <xsl:when test="$idx &lt;= count($nodes)">
                            <xsl:variable name="n" select="$nodes[$idx]"/>
                            <xsl:variable name="s" select="number($n/@start)"/>
                            <xsl:variable name="e" select="number($n/@end)"/>
                            <!-- 1) Unmarkierter Text von cursor .. s -->
                            <xsl:if test="$s &gt; $cursor">
                                <xsl:value-of select="substring($txt, $cursor + 1, $s - $cursor)"/>
                            </xsl:if>
                            <!-- 2) Markierter Bereich: inclusive-Ende (+1) -->
                            <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s + 1)"/>
                            <xsl:variable name="colorClass">
                                <xsl:choose>
                                    <xsl:when test="$idx mod 5 = 1">hl-1</xsl:when>
                                    <xsl:when test="$idx mod 5 = 2">hl-2</xsl:when>
                                    <xsl:when test="$idx mod 5 = 3">hl-3</xsl:when>
                                    <xsl:when test="$idx mod 5 = 4">hl-4</xsl:when>
                                    <xsl:otherwise>hl-5</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <span id="frag-{$n/@id}" class="{$colorClass}">
                                <xsl:value-of select="$frag"/>
                            </span>
                            <!-- 3) Weiter mit nächster Spanne, Cursor := max(cursor, e+1) -->
                            <xsl:call-template name="render-from">
                                <xsl:with-param name="txt" select="$txt"/>
                                <xsl:with-param name="nodes" select="$nodes"/>
                                <xsl:with-param name="idx" select="$idx + 1"/>
                                <xsl:with-param name="cursor">
                                    <xsl:choose>
                                        <xsl:when test="$e + 1 &gt; $cursor"><xsl:value-of select="$e + 1"/></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="$cursor"/></xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Rest ab cursor -->
                            <xsl:value-of select="substring($txt, $cursor + 1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>

                <!-- Falls es gar keine Spannen gibt, kompletten Text ausgeben -->
                    <xsl:if test="not(notes/note[@start and @end])">
                        <xsl:value-of select="$txt"/>
                    </xsl:if>
                </pre>

            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
