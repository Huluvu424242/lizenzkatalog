<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

    <xsl:output method="html"
                doctype-system="about:legacy-compat"
                encoding="UTF-8"
                indent="yes"/>
    <xsl:strip-space elements=""/>

    <!-- Muenchian key: alle Bereiche (mit Textbezug) nach @type gruppieren -->
    <xsl:key name="kType" match="notes/note[@start and @end]" use="@type"/>

    <!-- ===== Label-Mapping (Typcode -> Anzeige) ===== -->
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

            <!-- use (Kontextmarker) -->
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
            <xsl:when test="$t='rul#gov'">Behörden/Verwaltung</xsl:when>
            <xsl:when test="$t='rul#notice'">Hinweis beilegen</xsl:when>
            <xsl:when test="$t='rul#lictxt'">Lizenztext beifügen</xsl:when>
            <xsl:when test="$t='rul#changes'">Änderungen kennzeichnen</xsl:when>
            <xsl:when test="$t='rul#src'">Quellcode bereitstellen</xsl:when>
            <xsl:when test="$t='rul#pat'">Patentlizenz</xsl:when>
            <xsl:when test="$t='rul#patret'">Patentretaliation</xsl:when>
            <xsl:when test="$t='rul#tivo'">Anti-Tivoization</xsl:when>

            <!-- cpy/dst/lnk/env/pol/met -->
            <xsl:when test="$t='cpy#none'">Copyleft: none</xsl:when>
            <xsl:when test="$t='cpy#weak'">Copyleft: weak</xsl:when>
            <xsl:when test="$t='cpy#strong'">Copyleft: strong</xsl:when>
            <xsl:when test="$t='cpy#network'">Copyleft: network</xsl:when>

            <xsl:when test="$t='dst#none'">Weitergabe: keine</xsl:when>
            <xsl:when test="$t='dst#internal'">Weitergabe: intern</xsl:when>
            <xsl:when test="$t='dst#partners'">Weitergabe: Partner/Kunden</xsl:when>
            <xsl:when test="$t='dst#public'">Weitergabe: öffentlich</xsl:when>
            <xsl:when test="$t='dst#srv'">Server-seitig</xsl:when>
            <xsl:when test="$t='dst#cli'">Client-Code</xsl:when>

            <xsl:when test="$t='lnk#api'">Kopplung: API</xsl:when>
            <xsl:when test="$t='lnk#dyn'">Kopplung: dyn. Link</xsl:when>
            <xsl:when test="$t='lnk#sta'">Kopplung: stat. Link</xsl:when>

            <xsl:when test="$t='env#com'">Umfeld: Unternehmen</xsl:when>
            <xsl:when test="$t='env#edu'">Umfeld: Bildung</xsl:when>
            <xsl:when test="$t='env#sci'">Umfeld: Forschung</xsl:when>
            <xsl:when test="$t='env#prv'">Umfeld: privat</xsl:when>
            <xsl:when test="$t='env#oss'">Umfeld: OSS</xsl:when>
            <xsl:when test="$t='env#gov'">Umfeld: Verwaltung</xsl:when>
            <xsl:when test="$t='env#ngo'">Umfeld: NGO</xsl:when>

            <xsl:otherwise><xsl:value-of select="$t"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ===== kleine Helfer für Policies ===== -->
    <xsl:template name="pol-get">
        <!-- extrahiert key="value" aus @value -->
        <xsl:param name="raw"/>
        <xsl:param name="key"/>
        <xsl:variable name="needle" select="concat($key,'=&quot;')"/>
        <xsl:choose>
            <xsl:when test="contains($raw,$needle)">
                <xsl:variable name="after" select="substring-after($raw,$needle)"/>
                <xsl:value-of select="substring-before($after,'&quot;')"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- Einstieg -->
    <xsl:template match="/">
        <xsl:apply-templates select="/annotation"/>
    </xsl:template>

    <xsl:template match="annotation">
        <!-- Gesamter Text als String (für Bereiche) -->
        <xsl:variable name="docText" select="string(text)"/>

        <!-- Lizenzname ermitteln: zuerst @value, sonst Bereich -->
        <xsl:variable name="licenseName">
            <xsl:choose>
                <xsl:when test="notes/note[@type='lic#name' and @value]">
                    <xsl:value-of select="normalize-space(notes/note[@type='lic#name' and @value][1]/@value)"/>
                </xsl:when>
                <xsl:when test="notes/note[@type='lic#name' and @start and @end]">
                    <xsl:variable name="n" select="notes/note[@type='lic#name' and @start and @end][1]"/>
                    <xsl:value-of select="normalize-space(
                        substring($docText, number($n/@start) + 1,
                                           number($n/@end) - number($n/@start) + 1)
                    )"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>

        <html lang="de">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>
                    <xsl:text>Standoff-Annotationen</xsl:text>
                    <xsl:if test="string($licenseName) != ''">
                        <xsl:text> – </xsl:text>
                        <xsl:value-of select="$licenseName"/>
                    </xsl:if>
                </title>
                <style>
                    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 1rem; }
                    table { border-collapse: collapse; width: 100%; margin-bottom: 1.5rem; }
                    th, td { border: 1px solid #ddd; padding: .5rem .6rem; text-align: left; vertical-align: top; }
                    th { background: #f6f8fa; }
                    code { background: #f6f8fa; padding: .1rem .25rem; border-radius: 4px; }
                    pre { white-space: pre-wrap; background: #fafafa; border: 1px dashed #ddd; padding: .75rem; }
                    .muted { color: #777; }
                    /* Farbpalette (8 Farben, rotiert per Modulo) */
                    .hl-1 { background-color: #fff3cd; }  /* gelb */
                    .hl-2 { background-color: #d1ecf1; }  /* cyan */
                    .hl-3 { background-color: #e2e3e5; }  /* grau */
                    .hl-4 { background-color: #f8d7da; }  /* rosa */
                    .hl-5 { background-color: #d4edda; }  /* grün */
                    .hl-6 { background-color: #fde2e4; }  /* hellrot */
                    .hl-7 { background-color: #e4d8f6; }  /* lila */
                    .hl-8 { background-color: #f6e6b4; }  /* sand */
                    h1, h2 { margin: .2rem 0 .6rem 0; }

                    /* Badges & Pills */
                    .badges { display:flex; flex-wrap:wrap; gap:.35rem; margin:.35rem 0 1rem; }
                    .badge { display:inline-block; padding:.2rem .5rem; border-radius:999px; border:1px solid #ddd; background:#f7f7f7; font-size:.85rem; }
                    .badge.env { background:#f6f2ff; border-color:#e0d7ff; }
                    .badge.use { background:#e6f7ff; border-color:#bfe7ff; }
                    .badge.cpy { background:#eef7ff; border-color:#cfe6ff; }
                    .badge.dst { background:#f1fff0; border-color:#d6f5d3; }
                    .badge.lnk { background:#fff8e6; border-color:#ffe7ad; }

                    .pill { display:inline-block; padding:.1rem .4rem; border-radius:6px; border:1px solid #ddd; font-size:.8rem; background:#fbfbfb; }
                    .pill.green { background:#e9f9ee; border-color:#bfe8c8; }
                    .pill.yellow{ background:#fff9e5; border-color:#ffe2a8; }
                    .pill.red{ background:#ffeaea; border-color:#ffc2c2; }
                </style>
            </head>
            <body>
                <h1>
                    <xsl:text>Auswertung</xsl:text>
                    <xsl:if test="string($licenseName) != ''">
                        <br/>
                        <xsl:value-of select="$licenseName"/>
                    </xsl:if>
                </h1>

                <!-- Kontext-Badges aus env/use/cpy/dst/lnk und ausgewählte rul-Flags -->
                <div class="badges">
                    <xsl:call-template name="render-badges"/>
                </div>

                <xsl:variable name="txt" select="string(text)"/>

                <!-- ===== Tabelle 1: ohne Textbezug (Singletons) ===== -->
                <h2>
                    <img src="ospolizenzkatalog.svg"
                         alt="Bücherregal mit einem aufgeschlagenem Buch aus dem ein Paragraphenzeichen aufsteigt."
                         title="KI generiert by ChatGPT©️2025"
                         width="100" height="100"
                         style="max-width:100%; height:auto;" />
                    Allgemeine Infos</h2>
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
                                <xsl:when test="@value">
                                    <xsl:value-of select="concat('[[', @type, '=', @value, ']]')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('[[', @type, ']]')"/>
                                </xsl:otherwise>
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
                            <td>
                                <xsl:choose>
                                    <xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
                                    <xsl:otherwise><span class="muted">–</span></xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td><xsl:value-of select="@id"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <xsl:if test="not(notes/note[not(@start) or not(@end)])">
                    <p class="muted">Keine Annotationen ohne Textbezug vorhanden.</p>
                </xsl:if>

                <!-- ===== Tabelle 2: mit Textbezug (Bereiche) ===== -->
                <xsl:variable name="typeOrderRTF">
                    <!-- EINMALIGE, SORTIERTE TYPENLISTE -->
                    <xsl:for-each select="notes/note[@start and @end][generate-id() = generate-id(key('kType', @type)[1])]">
                        <xsl:sort select="@type"/>
                        <t type="{@type}"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="typeOrder" select="exsl:node-set($typeOrderRTF)/t"/>

                <h2>
                    <img src="ospolizenzkatalog.svg"
                         alt="Bücherregal mit einem aufgeschlagenem Buch aus dem ein Paragraphenzeichen aufsteigt."
                         title="KI generiert by ChatGPT©️2025"
                         width="100" height="100"
                         style="max-width:100%; height:auto;" />
                    Informationen mit Textbezug</h2>
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
                        <!-- Sortierung nach Position im Text -->
                        <xsl:sort select="@start" data-type="number" order="ascending"/>
                        <xsl:sort select="@end"   data-type="number" order="ascending"/>
                        <xsl:variable name="s" select="number(@start)"/>
                        <xsl:variable name="e" select="number(@end)"/>
                        <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s + 1)"/>
                        <xsl:variable name="tooltipSpan" select="concat('[[', @type, ']]...[[/', @type, ']]')"/>

                        <!-- Typ-Index: Position des Typs in der eindeutigen Typenliste -->
                        <xsl:variable name="typeIndex"
                                      select="count($typeOrder[@type = current()/@type]/preceding-sibling::t) + 1"/>

                        <tr>
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
                <xsl:if test="not(notes/note[@start and @end])">
                    <p class="muted">Keine Annotationen mit Textbezug vorhanden.</p>
                </xsl:if>

                <!-- ===== Policies: aus pol@value if/then/because ===== -->
                <h2>Policies (manuelle Bewertungen)</h2>
                <xsl:call-template name="render-policies"/>

                <!-- ===== Originaltext mit typkonstanten Hervorhebungen ===== -->
                <h2>Originaltext (mit Hervorhebungen)</h2>
                <pre><xsl:call-template name="render-original">
                    <xsl:with-param name="typeOrder" select="$typeOrder"/>
                </xsl:call-template></pre>

            </body>
        </html>
    </xsl:template>

    <!-- ===== Badges aus env/use/cpy/dst/lnk + ausgewählten rul-Flags ===== -->
    <xsl:template name="render-badges">
        <!-- Kontext-Badges -->
        <xsl:for-each select="/annotation/notes/note[
              starts-with(@type,'env#') or starts-with(@type,'use#')
           or starts-with(@type,'cpy#') or starts-with(@type,'dst#')
           or starts-with(@type,'lnk#')
        ]">
            <xsl:variable name="cls">
                <xsl:choose>
                    <xsl:when test="starts-with(@type,'env#')">badge env</xsl:when>
                    <xsl:when test="starts-with(@type,'use#')">badge use</xsl:when>
                    <xsl:when test="starts-with(@type,'cpy#')">badge cpy</xsl:when>
                    <xsl:when test="starts-with(@type,'dst#')">badge dst</xsl:when>
                    <xsl:otherwise>badge lnk</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <span class="{$cls}">
                <xsl:value-of select="substring-after(@type,'#')"/>
                <xsl:if test="@value">
                    <xsl:text> = </xsl:text>
                    <xsl:value-of select="@value"/>
                </xsl:if>
            </span>
        </xsl:for-each>

        <!-- Wichtige RUL-Flags als Pills (egal ob Bereich oder Singleton) -->
        <xsl:for-each select="/annotation/notes/note[
            @type='rul#notice' or @type='rul#lictxt' or @type='rul#src'
            or @type='rul#changes' or @type='rul#pat' or @type='rul#patret' or @type='rul#tivo'
        ][generate-id() = generate-id(key('kType', @type)[1]) or not(@start)]">
            <span class="pill">
                <xsl:call-template name="label-for-type">
                    <xsl:with-param name="t" select="@type"/>
                </xsl:call-template>
            </span>
        </xsl:for-each>
    </xsl:template>

    <!-- ===== Policies tabellarisch ===== -->
    <xsl:template name="render-policies">
        <xsl:variable name="pols" select="/annotation/notes/note[starts-with(@type,'pol#')]"/>
        <xsl:choose>
            <xsl:when test="count($pols) &gt; 0">
                <table>
                    <tr>
                        <th>IF (Kontext)</th>
                        <th>THEN</th>
                        <th>BECAUSE</th>
                    </tr>
                    <xsl:for-each select="$pols">
                        <tr>
                            <td>
                                <code>
                                    <xsl:call-template name="pol-get">
                                        <xsl:with-param name="raw" select="@value"/>
                                        <xsl:with-param name="key" select="'if'"/>
                                    </xsl:call-template>
                                </code>
                            </td>
                            <td>
                                <xsl:variable name="then">
                                    <xsl:call-template name="pol-get">
                                        <xsl:with-param name="raw" select="@value"/>
                                        <xsl:with-param name="key" select="'then'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="translate($then,'GRÜNGELBROT','grüngelbrot')='grün'">
                                        <span class="pill green">grün</span>
                                    </xsl:when>
                                    <xsl:when test="translate($then,'GRÜNGELBROT','grüngelbrot')='gelb'">
                                        <span class="pill yellow">gelb</span>
                                    </xsl:when>
                                    <xsl:when test="translate($then,'ROT','rot')='rot'">
                                        <span class="pill red">rot</span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="pill"><xsl:value-of select="$then"/></span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:call-template name="pol-get">
                                    <xsl:with-param name="raw" select="@value"/>
                                    <xsl:with-param name="key" select="'because'"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <p class="muted">Keine Policies vorhanden.</p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ===== Originaltext-Rendering: typbasierte Farben ===== -->
    <xsl:template name="render-original">
        <xsl:param name="typeOrder"/>
        <xsl:variable name="txt" select="string(/annotation/text)"/>

        <!-- sortierte Bereiche als RTF (inkl. type-Attribut!) -->
        <xsl:variable name="sortedSpansRTF">
            <xsl:for-each select="/annotation/notes/note[@start and @end]">
                <xsl:sort select="@start" data-type="number" order="ascending"/>
                <xsl:sort select="@end"   data-type="number" order="ascending"/>
                <span start="{@start}" end="{@end}" id="{@id}" type="{@type}"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="nodes" select="exsl:node-set($sortedSpansRTF)/span"/>
        <xsl:choose>
            <xsl:when test="$nodes">
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="typeOrder" select="$typeOrder"/>
                    <xsl:with-param name="idx" select="1"/>
                    <xsl:with-param name="cursor" select="0"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$txt"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ===== Rekursives Rendering (typbasierte Farbe) ===== -->
    <xsl:template name="render-from">
        <xsl:param name="txt"/>
        <xsl:param name="nodes"/>
        <xsl:param name="typeOrder"/>
        <xsl:param name="idx"/>
        <xsl:param name="cursor"/>

        <xsl:choose>
            <xsl:when test="$idx &lt;= count($nodes)">
                <xsl:variable name="n" select="$nodes[$idx]"/>
                <xsl:variable name="s" select="number($n/@start)"/>
                <xsl:variable name="e" select="number($n/@end)"/>

                <!-- Unmarkierter Text von cursor .. s -->
                <xsl:if test="$s &gt; $cursor">
                    <xsl:value-of select="substring($txt, $cursor + 1, $s - $cursor)"/>
                </xsl:if>

                <!-- Typindex aus $typeOrder -->
                <xsl:variable name="typeIndex"
                              select="count($typeOrder[@type = $n/@type]/preceding-sibling::t) + 1"/>

                <!-- Farbklasse: 8er-Palette rotiert -->
                <xsl:variable name="colorClass">
                    <xsl:choose>
                        <xsl:when test="$typeIndex mod 8 = 1">hl-1</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 2">hl-2</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 3">hl-3</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 4">hl-4</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 5">hl-5</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 6">hl-6</xsl:when>
                        <xsl:when test="$typeIndex mod 8 = 7">hl-7</xsl:when>
                        <xsl:otherwise>hl-8</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- Markierter Bereich (inclusive Ende) -->
                <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s + 1)"/>
                <span id="frag-{$n/@id}" class="{$colorClass}">
                    <xsl:value-of select="$frag"/>
                </span>

                <!-- Weiter -->
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="typeOrder" select="$typeOrder"/>
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

</xsl:stylesheet>
