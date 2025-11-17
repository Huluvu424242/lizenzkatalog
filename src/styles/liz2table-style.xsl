<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl">

    <xsl:output method="html"
                doctype-system="about:legacy-compat"
                encoding="UTF-8"
                indent="yes"/>
    <xsl:strip-space elements="annotation notes note text"/>

    <!-- ========================================================= -->
    <!-- Label Mapping (Fallback, falls kein @label/@tooltip da ist) -->
    <!-- ========================================================= -->
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
            <xsl:when test="$t='rul#edu'">Bildung</xsl:when>
            <xsl:when test="$t='rul#gov'">Verwaltung</xsl:when>
            <xsl:when test="$t='rul#notice'">Hinweispflicht</xsl:when>
            <xsl:when test="$t='rul#lictxt'">Lizenztext beifügen</xsl:when>
            <xsl:when test="$t='rul#changes'">Änderungen kennzeichnen</xsl:when>
            <xsl:when test="$t='rul#src'">Quellcode bereitstellen</xsl:when>
            <xsl:when test="$t='rul#pat'">Patentlizenz</xsl:when>
            <xsl:when test="$t='rul#patret'">Patent-Retaliation</xsl:when>
            <xsl:when test="$t='rul#tivo'">Anti-Tivoization</xsl:when>

            <!-- cpy -->
            <xsl:when test="$t='cpy#none'">Kein Copyleft</xsl:when>
            <xsl:when test="$t='cpy#weak'">Weak Copyleft</xsl:when>
            <xsl:when test="$t='cpy#strong'">Strong Copyleft</xsl:when>
            <xsl:when test="$t='cpy#network'">Network Copyleft</xsl:when>

            <!-- dst -->
            <xsl:when test="$t='dst#internal'">Interne Weitergabe</xsl:when>
            <xsl:when test="$t='dst#partners'">Partner/Kunden</xsl:when>
            <xsl:when test="$t='dst#public'">Öffentlich</xsl:when>

            <!-- lnk -->
            <xsl:when test="$t='lnk#api'">API-Kopplung</xsl:when>
            <xsl:when test="$t='lnk#dyn'">Dynamisches Linken</xsl:when>
            <xsl:when test="$t='lnk#sta'">Statisches Linken</xsl:when>

            <!-- env -->
            <xsl:when test="$t='env#com'">Unternehmen</xsl:when>
            <xsl:when test="$t='env#edu'">Bildung</xsl:when>
            <xsl:when test="$t='env#sci'">Wissenschaft</xsl:when>
            <xsl:when test="$t='env#prv'">Privat</xsl:when>
            <xsl:when test="$t='env#oss'">OSS-Umfeld</xsl:when>
            <xsl:when test="$t='env#gov'">Verwaltung</xsl:when>
            <xsl:when test="$t='env#ngo'">NGO</xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="$t"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Einstieg                                                   -->
    <!-- ========================================================= -->

    <xsl:template match="/">
        <xsl:apply-templates select="/annotation"/>
    </xsl:template>

    <xsl:template match="annotation">

        <xsl:variable name="docText" select="string(text)"/>

        <!-- Lizenzname -->
        <xsl:variable name="licenseName">
            <xsl:choose>
                <xsl:when test="notes/note[@type='lic#name' and @label]">
                    <xsl:value-of select="normalize-space(notes/note[@type='lic#name'][1]/@label)"/>
                </xsl:when>
                <xsl:when test="notes/note[@type='lic#name' and @start and @end]">
                    <xsl:variable name="n" select="notes/note[@type='lic#name'][1]"/>
                    <xsl:value-of select="
                        substring($docText,
                            number($n/@start)+1,
                            number($n/@end)-number($n/@start)+1)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <html lang="de">
            <head>
                <meta charset="UTF-8"/>
                <title>Auswertung – <xsl:value-of select="$licenseName"/></title>

                <style>
                    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding:1rem; }
                    table { border-collapse: collapse; width:100%; margin-bottom:1.5rem;}
                    th,td { border:1px solid #ddd; padding:0.5rem; vertical-align:top; text-align:left; }
                    th { background:#f6f8fa; }
                    code { background:#f6f8fa; padding:0.1rem 0.25rem; border-radius:4px;}
                    pre { white-space:pre-wrap; background:#fafafa; border:1px dashed #ddd; padding:0.75rem;}
                    h1,h2 { margin:.2rem 0 .6rem 0; }

                    .muted { color:#777; }
                    .tooltip-label { cursor:help; }

                    .pill { display:inline-block; padding:0.1rem 0.4rem; border-radius:6px; border:1px solid #ddd;
                    font-size:0.8rem; background:#fbfbfb; }
                    .pill.green { background:#e9f9ee; border-color:#bfe8c8;}
                    .pill.red { background:#ffeaea; border-color:#ffc2c2;}
                    .pill.yellow { background:#fff9e5; border-color:#ffe2a8;}

                    .hl-1 { background:#fff3cd;}
                    .hl-2 { background:#d1ecf1;}
                    .hl-3 { background:#e2e3e5;}
                    .hl-4 { background:#f8d7da;}
                    .hl-5 { background:#d4edda;}
                    .hl-6 { background:#fde2e4;}
                    .hl-7 { background:#e4d8f6;}
                    .hl-8 { background:#f6e6b4;}

                    .badges { display:flex; flex-wrap:wrap; gap:.35rem; margin:.35rem 0 1rem; }
                    .badge { display:inline-block; padding:.2rem .5rem; border-radius:999px; border:1px solid #ddd;
                    background:#f7f7f7; font-size:.85rem; }
                    .badge.env { background:#f6f2ff; border-color:#e0d7ff; }
                    .badge.use { background:#e6f7ff; border-color:#bfe7ff; }
                    .badge.cpy { background:#eef7ff; border-color:#cfe6ff; }
                    .badge.dst { background:#f1fff0; border-color:#d6f5d3; }
                    .badge.lic { background:#fff8e6; border-color:#ffe7ad; }
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

                <!-- Tagliste / Kontext-Badges -->
                <div class="badges">
                    <xsl:call-template name="render-badges"/>
                </div>

                <xsl:variable name="txt" select="string(text)"/>

                <!-- ===== Policies (direkt über Attribute) ===== -->
                <h2>Policies (manuelle Bewertungen)</h2>
                <xsl:call-template name="render-policies"/>

                <!-- ===== Tabelle 1: ohne Textbezug (Singletons) ===== -->
                <h2>
                    <img src="ospolizenzkatalog.svg"
                         alt="Bücherregal mit einem aufgeschlagenem Buch aus dem ein Paragraphenzeichen aufsteigt."
                         title="KI generiert by ChatGPT©️2025"
                         width="100" height="100"
                         style="max-width:100%; height:auto;"/>
                    Allgemeine Infos
                </h2>
                <table>
                    <tr>
                        <th>#</th>
                        <th>Typ</th>
                        <th>Wert</th>
                        <th>ID</th>
                    </tr>
                    <xsl:for-each select="notes/note[not(@start) and not(@end) and not(starts-with(@type,'pol#'))]">
                        <xsl:sort select="@type"/>
                        <tr>
                            <td><xsl:value-of select="position()"/></td>

                            <td>
                                <xsl:variable name="tooltip" select="concat('[[', @type, ']]')"/>
                                <span title="{$tooltip}">
                                    <xsl:choose>
                                        <xsl:when test="@tooltip">
                                            <xsl:value-of select="@tooltip"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="label-for-type">
                                                <xsl:with-param name="t" select="@type"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                            </td>

                            <td>
                                <span class="tooltip-label">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="@type"/>
                                        <xsl:if test="@label">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="@label"/>
                                        </xsl:if>
                                    </xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="@label">
                                            <xsl:value-of select="@label"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="muted">–</span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                            </td>

                            <td><xsl:value-of select="@id"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <xsl:if test="not(notes/note[not(@start) and not(@end) and not(starts-with(@type,'pol#'))])">
                    <p class="muted">Keine Annotationen ohne Textbezug vorhanden.</p>
                </xsl:if>

                <!-- ===== Textbezug-Tabelle ===== -->
                <h2>
                    <img src="ospolizenzkatalog.svg"
                         alt="Bücherregal mit einem aufgeschlagenem Buch aus dem ein Paragraphenzeichen aufsteigt."
                         title="KI generiert by ChatGPT©️2025"
                         width="100" height="100"
                         style="max-width:100%; height:auto;"/>
                    Informationen mit Textbezug
                </h2>

                <table>
                    <tr>
                        <th>#</th>
                        <th>Typ</th>
                        <th>Auszug</th>
                        <th>ID</th>
                        <th>Start</th>
                        <th>Ende</th>
                    </tr>
                    <xsl:for-each select="notes/note[@start]">
                        <xsl:sort select="@start" data-type="number"/>
                        <xsl:sort select="@end" data-type="number"/>

                        <xsl:variable name="s" select="number(@start)"/>
                        <xsl:variable name="e" select="number(@end)"/>
                        <xsl:variable name="frag"
                                      select="substring($txt, $s+1, $e - $s + 1)"/>
                        <xsl:variable name="tooltipSpan"
                                      select="concat('[[', @type, ']]...[[/', @type, ']]')"/>

                        <tr>
                            <!-- Verlinkung auf farbigen Originaltext -->
                            <td>
                                <a href="#frag-{@id}">
                                    <xsl:value-of select="position()"/>
                                </a>
                            </td>

                            <td>
                                <span title="{$tooltipSpan}">
                                    <xsl:choose>
                                        <xsl:when test="@tooltip">
                                            <xsl:value-of select="@tooltip"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="label-for-type">
                                                <xsl:with-param name="t" select="@type"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                            </td>

                            <td>
                                <xsl:value-of select="normalize-space($frag)"/>
                            </td>

                            <td><xsl:value-of select="@id"/></td>
                            <td><xsl:value-of select="@start"/></td>
                            <td><xsl:value-of select="@end"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <xsl:if test="not(notes/note[@start])">
                    <p class="muted">Keine Annotationen mit Textbezug vorhanden.</p>
                </xsl:if>

                <!-- ===== Originaltext ===== -->
                <h2>Originaltext (mit Hervorhebungen)</h2>
                <pre>
                    <xsl:call-template name="render-original"/>
                </pre>

            </body>
        </html>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Badges (Tagliste oben) – Variante A                       -->
    <!-- ========================================================= -->
    <xsl:template name="render-badges">
        <!--
          Kontext-Badges für:
            - env / use / dst / cpy (aus category)
            - wichtige Lizenz-Singletons: lic#spdx, lic#c, lic#c0
          Es werden nur Singletons (ohne start/end) berücksichtigt.
        -->
        <xsl:variable name="badgeNodesRTF">
            <xsl:for-each select="/annotation/notes/note[
                  not(@start) and not(@end) and
                  (
                      @category='env' or
                      @category='use' or
                      @category='dst' or
                      @category='cpy' or
                      @type='lic#spdx' or
                      @type='lic#c' or
                      @type='lic#c0'
                  )
              ]">
                <xsl:sort select="@category"/>
                <xsl:sort select="@name"/>
                <!-- Duplikate vermeiden: gleiche type+label nur einmal -->
                <xsl:if test="not(preceding::note[
                                     @type = current()/@type and
                                     @label = current()/@label
                                   ])">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="exsl:node-set($badgeNodesRTF)/note">
            <xsl:variable name="cat" select="@category"/>
            <xsl:variable name="cls">
                <xsl:text>badge </xsl:text>
                <xsl:choose>
                    <xsl:when test="$cat != ''">
                        <xsl:value-of select="$cat"/>
                    </xsl:when>
                    <xsl:otherwise>lic</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <span class="{$cls}">
                <xsl:if test="@tooltip">
                    <xsl:attribute name="title">
                        <xsl:value-of select="@tooltip"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@emoji">
                    <xsl:value-of select="@emoji"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@label">
                        <xsl:value-of select="@label"/>
                    </xsl:when>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:for-each>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Policies-Renderer                                         -->
    <!-- ========================================================= -->
    <xsl:template name="render-policies">
        <xsl:variable name="pols"
                      select="/annotation/notes/note[
                            starts-with(@type,'pol#')
                            and (@if or @then or @because)
                            and not(@present='true')
                      ]"/>

        <xsl:choose>
            <xsl:when test="count($pols)>0">
                <table>
                    <tr>
                        <th>Rahmenbedingungen</th>
                        <th>Verwendbarkeit</th>
                        <th>Grund</th>
                    </tr>
                    <xsl:for-each select="$pols">
                        <xsl:call-template name="render-condition-row"/>
                    </xsl:for-each>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <p class="muted">Keine Policies vorhanden.</p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Policy-Zeile, nutzt if_tooltip + label aus Python -->
    <xsl:template name="render-condition-row">
        <tr>
            <!-- Rahmenbedingungen mit Tooltip -->
            <td>
                <span class="tooltip-label">
                    <xsl:if test="@if_tooltip">
                        <xsl:attribute name="title">
                            <xsl:value-of select="@if_tooltip"/>
                        </xsl:attribute>
                    </xsl:if>
                    <code>
                        <xsl:choose>
                            <xsl:when test="@label">
                                <xsl:value-of select="@label"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@if"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </code>
                </span>
            </td>

            <!-- Verwendbarkeit -->
            <td>
                <span class="pill">
                    <xsl:attribute name="class">
                        <xsl:text>pill </xsl:text>
                        <xsl:value-of select="@status"/>
                    </xsl:attribute>
                    <xsl:value-of select="@then"/>
                </span>
            </td>

            <!-- Grund -->
            <td><xsl:value-of select="@because"/></td>
        </tr>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Originaltext Renderer (nutzt colorIndex aus Python)       -->
    <!-- ========================================================= -->
    <xsl:template name="render-original">
        <xsl:variable name="txt" select="string(/annotation/text)"/>

        <xsl:variable name="sortedSpansRTF">
            <xsl:for-each select="/annotation/notes/note[@start and @end]">
                <xsl:sort select="@start" data-type="number"/>
                <xsl:sort select="@end" data-type="number"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="nodes"
                      select="exsl:node-set($sortedSpansRTF)/note"/>

        <xsl:choose>
            <xsl:when test="$nodes">
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="idx" select="1"/>
                    <xsl:with-param name="cursor" select="0"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$txt"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Rekursiver Renderer mit colorIndex + IDs für Anker -->
    <xsl:template name="render-from">
        <xsl:param name="txt"/>
        <xsl:param name="nodes"/>
        <xsl:param name="idx"/>
        <xsl:param name="cursor"/>

        <xsl:choose>
            <xsl:when test="$idx &lt;= count($nodes)">
                <xsl:variable name="n" select="$nodes[$idx]"/>
                <xsl:variable name="s" select="number($n/@start)"/>
                <xsl:variable name="e" select="number($n/@end)"/>

                <!-- Text vor der aktuellen Annotation -->
                <xsl:if test="$s &gt; $cursor">
                    <xsl:value-of select="substring($txt, $cursor+1, $s - $cursor)"/>
                </xsl:if>

                <!-- Klasse direkt aus colorIndex -->
                <xsl:variable name="cls">
                    <xsl:text>hl-</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$n/@colorIndex">
                            <xsl:value-of select="$n/@colorIndex"/>
                        </xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <span id="frag-{$n/@id}" class="{$cls}">
                    <xsl:value-of select="substring($txt, $s+1, $e - $s+1)"/>
                </span>

                <!-- Rekursiv weiter -->
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="idx" select="$idx+1"/>
                    <xsl:with-param name="cursor" select="$e+1"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($txt, $cursor+1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
