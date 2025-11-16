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

    <!-- Muenchian key -->
    <xsl:key name="kType" match="notes/note[@start and @end]" use="@type"/>

    <!-- ===== Label-Mapping für Typen ===== -->
    <xsl:template name="label-for-type">
        <xsl:param name="t"/>
        <xsl:choose>
            <xsl:when test="$t='lic#name'">Lizenzname</xsl:when>
            <xsl:when test="$t='lic#spdx'">SPDX-ID</xsl:when>
            <xsl:when test="$t='lic#fsf'">FSF-Freigabe</xsl:when>
            <xsl:when test="$t='lic#osi'">OSI-Freigabe</xsl:when>
            <xsl:when test="$t='lic#c'">Alle Rechte vorbehalten</xsl:when>
            <xsl:when test="$t='lic#c0'">Nutzung uneingeschränkt</xsl:when>

            <xsl:when test="$t='use#doc'">Dokumentation</xsl:when>
            <xsl:when test="$t='use#lib'">Bibliothek/Komponente</xsl:when>
            <xsl:when test="$t='use#app'">Lokale Anwendung</xsl:when>
            <xsl:when test="$t='use#cld'">Cloud-Anwendung</xsl:when>

            <xsl:when test="$t='lim#pc'">Anzahl Rechner</xsl:when>
            <xsl:when test="$t='lim#dev'">Anzahl Geräte</xsl:when>
            <xsl:when test="$t='lim#srv'">Anzahl Server</xsl:when>
            <xsl:when test="$t='lim#cpu'">Anzahl CPUs</xsl:when>
            <xsl:when test="$t='lim#krn'">Anzahl Kerne</xsl:when>
            <xsl:when test="$t='lim#usr'">Anzahl Nutzer</xsl:when>

            <xsl:when test="$t='act#cop'">Vervielfältigung</xsl:when>
            <xsl:when test="$t='act#mod'">Modifikation</xsl:when>
            <xsl:when test="$t='act#mov'">Verbreitung</xsl:when>
            <xsl:when test="$t='act#sel'">Verkauf</xsl:when>
            <xsl:when test="$t='act#der'">Abgeleitete Werke</xsl:when>

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

            <xsl:when test="$t='cpy#weak'">Weak Copyleft</xsl:when>
            <xsl:when test="$t='cpy#strong'">Strong Copyleft</xsl:when>
            <xsl:when test="$t='cpy#network'">Network Copyleft</xsl:when>
            <xsl:when test="$t='cpy#none'">Kein Copyleft</xsl:when>

            <xsl:when test="$t='dst#internal'">Interne Weitergabe</xsl:when>
            <xsl:when test="$t='dst#partners'">Partner/Kunden</xsl:when>
            <xsl:when test="$t='dst#public'">Öffentlich</xsl:when>

            <xsl:when test="$t='lnk#api'">API-Kopplung</xsl:when>
            <xsl:when test="$t='lnk#dyn'">Dynamisches Linken</xsl:when>
            <xsl:when test="$t='lnk#sta'">Statisches Linken</xsl:when>

            <xsl:when test="$t='env#com'">Unternehmen</xsl:when>
            <xsl:when test="$t='env#edu'">Bildung</xsl:when>
            <xsl:when test="$t='env#sci'">Wissenschaft</xsl:when>
            <xsl:when test="$t='env#prv'">Privat</xsl:when>
            <xsl:when test="$t='env#oss'">OSS-Umfeld</xsl:when>
            <xsl:when test="$t='env#gov'">Verwaltung</xsl:when>
            <xsl:when test="$t='env#ngo'">NGO</xsl:when>

            <xsl:otherwise><xsl:value-of select="$t"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ===== Hilfs-Templates für Policy-Tooltips ===== -->

    <!-- Tokenizer: zerlegt einen String in <p>-Knoten nach Leerzeichen -->
    <xsl:template name="tokenize">
        <xsl:param name="text"/>
        <xsl:variable name="t" select="normalize-space($text)"/>
        <xsl:choose>
            <xsl:when test="contains($t, ' ')">
                <p><xsl:value-of select="substring-before($t, ' ')"/></p>
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="text" select="substring-after($t, ' ')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:value-of select="$t"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Token wie "env=com" zu "env#com 🏢 Unternehmen" auflösen -->
    <xsl:template name="token-to-label">
        <xsl:param name="t"/>

        <!-- Typ-Präfix und Wert extrahieren -->
        <xsl:variable name="prefix" select="substring-before($t,'=')"/>
        <xsl:variable name="value"  select="substring-after($t,'=')"/>
        <xsl:variable name="fullType" select="concat($prefix, '#', $value)"/>

        <!-- passende Note suchen (Label enthält Emoji aus Python) -->
        <xsl:variable name="n" select="/annotation/notes/note[@type=$fullType][1]"/>

        <xsl:choose>
            <xsl:when test="$n">
                <xsl:value-of select="$fullType"/>
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <xsl:when test="$n/@label">
                        <xsl:value-of select="$n/@label"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="label-for-type">
                            <xsl:with-param name="t" select="$fullType"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Fallback, falls keine Note gefunden -->
            <xsl:otherwise>
                <xsl:value-of select="$t"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Alle Tokens aus @if einsammeln und kommasepariert auflösen -->
    <xsl:template name="collect-tokens">
        <xsl:param name="expr"/>

        <!-- Sonderzeichen (&, |, (),) zu Leerzeichen machen -->
        <xsl:variable name="flat"
                      select="translate($expr, '&amp;|()', '    ')"/>

        <!-- in Teile zerlegen -->
        <xsl:variable name="parts">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="text" select="$flat"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="nodes" select="exsl:node-set($parts)/p"/>

        <xsl:for-each select="$nodes">
            <xsl:if test="contains(., '=')">
                <xsl:call-template name="token-to-label">
                    <xsl:with-param name="t" select="."/>
                </xsl:call-template>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Einstieg -->
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
                    <xsl:value-of
                            select="substring($docText, number($n/@start)+1, number($n/@end)-number($n/@start)+1)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <html lang="de">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Auswertung –
                    <xsl:value-of select="$licenseName"/>
                </title>

                <style>
                    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 1rem; }
                    table { border-collapse: collapse; width: 100%; margin-bottom: 1.5rem; }
                    th, td { border: 1px solid #ddd; padding: .5rem .6rem; text-align: left; vertical-align: top; }
                    th { background: #f6f8fa; }
                    code { background: #f6f8fa; padding: .1rem .25rem; border-radius: 4px; }
                    pre { white-space: pre-wrap; background: #fafafa; border: 1px dashed #ddd; padding: .75rem; }
                    .muted { color: #777; }
                    .hl-1 { background-color: #fff3cd; }
                    .hl-2 { background-color: #d1ecf1; }
                    .hl-3 { background-color: #e2e3e5; }
                    .hl-4 { background-color: #f8d7da; }
                    .hl-5 { background-color: #d4edda; }
                    .hl-6 { background-color: #fde2e4; }
                    .hl-7 { background-color: #e4d8f6; }
                    .hl-8 { background-color: #f6e6b4; }
                    .pill { display:inline-block; padding:.1rem .4rem; border:1px solid #ddd; border-radius:6px;
                    font-size:.8rem; background:#fbfbfb; }
                    .pill.green { background:#e9f9ee; border-color:#bfe8c8; }
                    .pill.yellow{ background:#fff9e5; border-color:#ffe2a8; }
                    .pill.red{ background:#ffeaea; border-color:#ffc2c2; }

                    .tooltip-label { cursor: help; }
                </style>
            </head>

            <body>

                <h1>Auswertung<br/><xsl:value-of select="$licenseName"/></h1>

                <xsl:variable name="txt" select="string(text)"/>

                <!-- ===== Policies ===== -->
                <h2>Policies</h2>
                <xsl:call-template name="render-policies"/>

                <!-- ===== Allgemeine Infos ===== -->
                <h2>Allgemeine Infos</h2>
                <table>
                    <tr>
                        <th>#</th><th>Typ</th><th>Wert</th><th>ID</th>
                    </tr>
                    <xsl:for-each select="notes/note[not(@start) and not(@end) and not(starts-with(@type,'pol#'))]">
                        <xsl:sort select="@type"/>
                        <tr>
                            <td><xsl:value-of select="position()"/></td>
                            <td>
                                <xsl:call-template name="label-for-type">
                                    <xsl:with-param name="t" select="@type"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <!-- Tooltip: @type und @label, Emoji kommt schon aus Python -->
                                <span class="tooltip-label">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="@type"/>
                                        <xsl:if test="@label">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="@label"/>
                                        </xsl:if>
                                    </xsl:attribute>
                                    <xsl:value-of select="@label"/>
                                </span>
                            </td>
                            <td><xsl:value-of select="@id"/></td>
                        </tr>
                    </xsl:for-each>
                </table>

                <!-- ===== Textbezug-Tabelle ===== -->
                <h2>Informationen mit Textbezug</h2>

                <!-- typeOrder bestimmen -->
                <xsl:variable name="typeOrderRTF">
                    <xsl:for-each select="notes/note[@start][generate-id()=generate-id(key('kType',@type)[1])]">
                        <xsl:sort select="@type"/>
                        <t type="{@type}"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="typeOrder" select="exsl:node-set($typeOrderRTF)/t"/>

                <table>
                    <tr><th>#</th><th>Typ</th><th>Auszug</th><th>ID</th><th>Start</th><th>Ende</th></tr>
                    <xsl:for-each select="notes/note[@start]">
                        <xsl:sort select="@start" data-type="number"/>
                        <xsl:sort select="@end" data-type="number"/>
                        <tr>
                            <td><xsl:value-of select="position()"/></td>
                            <td>
                                <xsl:call-template name="label-for-type">
                                    <xsl:with-param name="t" select="@type"/>
                                </xsl:call-template>
                            </td>
                            <td><xsl:value-of select="substring($txt, number(@start)+1, number(@end)-number(@start)+1)"/></td>
                            <td><xsl:value-of select="@id"/></td>
                            <td><xsl:value-of select="@start"/></td>
                            <td><xsl:value-of select="@end"/></td>
                        </tr>
                    </xsl:for-each>
                </table>

                <!-- ===== Originaltext ===== -->
                <h2>Originaltext</h2>
                <pre>
                    <xsl:call-template name="render-original">
                        <xsl:with-param name="typeOrder" select="$typeOrder"/>
                    </xsl:call-template>
                </pre>

            </body>
        </html>
    </xsl:template>

    <!-- ===== Policies-Renderer ===== -->
    <xsl:template name="render-policies">
        <xsl:variable name="pols"
                      select="/annotation/notes/note[starts-with(@type,'pol#') and not(@present='true')]"/>
        <xsl:choose>
            <xsl:when test="count($pols)&gt;0">
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

    <!-- ===== Policy-Zeile ===== -->
    <xsl:template name="render-condition-row">
        <tr>
            <!-- Rahmenbedingungen mit Tooltip:
                 title = kommaseparierte Liste der env/use/...-Ausprägungen aus @if -->
            <td>
                <span class="tooltip-label">
                    <xsl:attribute name="title">
                        <xsl:call-template name="collect-tokens">
                            <xsl:with-param name="expr" select="@if"/>
                        </xsl:call-template>
                    </xsl:attribute>
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

            <td>
                <span class="pill">
                    <xsl:attribute name="class">
                        <xsl:text>pill </xsl:text><xsl:value-of select="@status"/>
                    </xsl:attribute>
                    <xsl:value-of select="@then"/>
                </span>
            </td>

            <td><xsl:value-of select="@because"/></td>
        </tr>
    </xsl:template>

    <!-- ===== Originaltext-Renderer ===== -->
    <xsl:template name="render-original">
        <xsl:param name="typeOrder"/>
        <xsl:variable name="txt" select="string(/annotation/text)"/>

        <xsl:variable name="sortedSpansRTF">
            <xsl:for-each select="/annotation/notes/note[@start]">
                <xsl:sort select="@start" data-type="number"/>
                <xsl:sort select="@end" data-type="number"/>
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

    <!-- ===== Rekursiver Renderer ===== -->
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

                <!-- Text vor der aktuellen Annotation -->
                <xsl:if test="$s &gt; $cursor">
                    <xsl:value-of select="substring($txt, $cursor+1, $s - $cursor)"/>
                </xsl:if>

                <!-- Highlight-Index für diesen Typ -->
                <xsl:variable name="typeIndex"
                              select="count($typeOrder[@type=$n/@type]/preceding-sibling::t)+1"/>

                <xsl:variable name="cls">
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

                <!-- Markierter Bereich -->
                <span class="{$cls}">
                    <xsl:value-of select="substring($txt, $s+1, $e - $s+1)"/>
                </span>

                <!-- Rekursiv weiter mit nächster Annotation -->
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="typeOrder" select="$typeOrder"/>
                    <xsl:with-param name="idx" select="$idx+1"/>
                    <xsl:with-param name="cursor" select="$e+1"/>
                </xsl:call-template>

            </xsl:when>

            <!-- Resttext hinter der letzten Annotation -->
            <xsl:otherwise>
                <xsl:value-of select="substring($txt, $cursor+1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
