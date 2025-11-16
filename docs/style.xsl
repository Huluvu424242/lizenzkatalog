<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl">

    <xsl:output method="html" encoding="UTF-8" indent="yes"
                doctype-system="about:legacy-compat"/>

    <xsl:strip-space elements="annotation notes note text"/>

    <!-- ========================================================= -->
    <!-- Muenchian Key                                             -->
    <!-- ========================================================= -->
    <xsl:key name="kType" match="notes/note[@start and @end]" use="@type"/>

    <!-- ========================================================= -->
    <!-- Label Mapping                                              -->
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
    <!-- TOKENIZER FÜR POLICIES (env=com,use=lib,...)              -->
    <!-- ========================================================= -->

    <!-- Komma-separierte if-Ausdrücke splitten -->
    <xsl:template name="split-assignments">
        <xsl:param name="expr"/>
        <xsl:variable name="t" select="normalize-space($expr)"/>
        <xsl:choose>
            <xsl:when test="contains($t, ',')">
                <p><xsl:value-of select="substring-before($t, ',')"/></p>
                <xsl:call-template name="split-assignments">
                    <xsl:with-param name="expr" select="substring-after($t, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:value-of select="$t"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Ein Token wie "env=com" → "env#com 🏢 Unternehmen" -->
    <xsl:template name="token-to-label">
        <xsl:param name="t"/>

        <xsl:variable name="assignment" select="normalize-space($t)"/>

        <!-- nur Tokens mit "=" -->
        <xsl:if test="contains($assignment, '=')">

            <xsl:variable name="prefix" select="substring-before($assignment,'=')"/>
            <xsl:variable name="value"  select="substring-after($assignment,'=')"/>
            <xsl:variable name="fullType" select="concat($prefix, '#', $value)"/>

            <!-- Emoji-Mapping -->
            <xsl:variable name="emoji">
                <xsl:choose>
                    <!-- env -->
                    <xsl:when test="$fullType='env#com'">🏢</xsl:when>
                    <xsl:when test="$fullType='env#edu'">🎓</xsl:when>
                    <xsl:when test="$fullType='env#sci'">🔬</xsl:when>
                    <xsl:when test="$fullType='env#prv'">🏡</xsl:when>
                    <xsl:when test="$fullType='env#oss'">🐧</xsl:when>
                    <xsl:when test="$fullType='env#gov'">🏛️</xsl:when>
                    <xsl:when test="$fullType='env#ngo'">🤝</xsl:when>

                    <!-- use -->
                    <xsl:when test="$fullType='use#lib'">📚</xsl:when>
                    <xsl:when test="$fullType='use#app'">💻</xsl:when>
                    <xsl:when test="$fullType='use#doc'">📄</xsl:when>
                    <xsl:when test="$fullType='use#cld'">☁️</xsl:when>

                    <!-- dst -->
                    <xsl:when test="$fullType='dst#public'">🌍</xsl:when>
                    <xsl:when test="$fullType='dst#partners'">🤝</xsl:when>
                    <xsl:when test="$fullType='dst#internal'">🏢</xsl:when>

                    <!-- cpy -->
                    <xsl:when test="$fullType='cpy#strong'">🧬</xsl:when>
                    <xsl:when test="$fullType='cpy#weak'">🧬</xsl:when>
                    <xsl:when test="$fullType='cpy#network'">🧬</xsl:when>
                    <xsl:when test="$fullType='cpy#none'">⚪</xsl:when>

                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>

            <!-- Klartext-Label -->
            <xsl:variable name="labelText">
                <xsl:call-template name="label-for-type">
                    <xsl:with-param name="t" select="$fullType"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- Ausgabe: env#com 🏢 Unternehmen -->
            <xsl:value-of select="$fullType"/>
            <xsl:text> </xsl:text>
            <xsl:if test="string($emoji)!=''">
                <xsl:value-of select="$emoji"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$labelText"/>

        </xsl:if>
    </xsl:template>

    <!-- Alle Tokens eines if-Ausdrucks zu schöner Liste -->
    <xsl:template name="collect-tokens">
        <xsl:param name="expr"/>

        <xsl:variable name="parts">
            <xsl:call-template name="split-assignments">
                <xsl:with-param name="expr" select="$expr"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="nodes"
                      select="exsl:node-set($parts)/p"/>

        <xsl:for-each select="$nodes">
            <xsl:if test="contains(., '=')">
                <xsl:call-template name="token-to-label">
                    <xsl:with-param name="t" select="."/>
                </xsl:call-template>
                <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:if>
        </xsl:for-each>
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
                    .badge.lnk { background:#fff8e6; border-color:#ffe7ad; }
                </style>

            </head>

            <body>

                <h1>Auswertung<br/><xsl:value-of select="$licenseName"/></h1>

                <!-- Tagliste / Kontext-Badges -->
                <div class="badges">
                    <xsl:call-template name="render-badges"/>
                </div>

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
                                <xsl:variable name="tooltip" select="concat('[[', @type, ']]')"/>
                                <span title="{$tooltip}">
                                    <xsl:call-template name="label-for-type">
                                        <xsl:with-param name="t" select="@type"/>
                                    </xsl:call-template>
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
                    <tr>
                        <th>#</th><th>Typ</th><th>Auszug</th><th>ID</th><th>Start</th><th>Ende</th>
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
                                    <xsl:call-template name="label-for-type">
                                        <xsl:with-param name="t" select="@type"/>
                                    </xsl:call-template>
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
                    <xsl:call-template name="render-original">
                        <xsl:with-param name="typeOrder" select="$typeOrder"/>
                    </xsl:call-template>
                </pre>

            </body>
        </html>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Badges (Tagliste oben)                                   -->
    <!-- ========================================================= -->
    <xsl:template name="render-badges">
        <!-- Kontext-Badges für env/use/cpy/dst/lnk -->
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
                <xsl:if test="@label">
                    <xsl:text> – </xsl:text>
                    <xsl:value-of select="@label"/>
                </xsl:if>
            </span>
        </xsl:for-each>

        <!-- Wichtige RUL-Flags als Pills (einmalig) -->
        <xsl:for-each select="/annotation/notes/note[
              @type='rul#notice' or @type='rul#lictxt' or @type='rul#src'
           or @type='rul#changes' or @type='rul#pat' or @type='rul#patret'
           or @type='rul#tivo'
        ][generate-id() = generate-id(key('kType', @type)[1]) or not(@start)]">
            <span class="pill">
                <xsl:call-template name="label-for-type">
                    <xsl:with-param name="t" select="@type"/>
                </xsl:call-template>
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

    <!-- Policy-Zeile mit Tooltip aus @if -->
    <xsl:template name="render-condition-row">
        <tr>
            <!-- Rahmenbedingungen mit Tooltip = Liste der env/use/dst/cpy-Ausprägungen -->
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
    <!-- Originaltext Renderer                                     -->
    <!-- ========================================================= -->
    <xsl:template name="render-original">
        <xsl:param name="typeOrder"/>

        <xsl:variable name="txt" select="string(/annotation/text)"/>

        <xsl:variable name="sortedSpansRTF">
            <xsl:for-each select="/annotation/notes/note[@start and @end]">
                <xsl:sort select="@start" data-type="number"/>
                <xsl:sort select="@end" data-type="number"/>
                <span start="{@start}" end="{@end}" id="{@id}" type="{@type}"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="nodes"
                      select="exsl:node-set($sortedSpansRTF)/span"/>

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

    <!-- Rekursiver Renderer mit farbigen Spans + IDs für Anker -->
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

                <!-- markierter Bereich mit ID für die Tabelle (#frag-ID) -->
                <span id="frag-{$n/@id}" class="{$cls}">
                    <xsl:value-of select="substring($txt, $s+1, $e - $s+1)"/>
                </span>

                <!-- Rekursiv weiter -->
                <xsl:call-template name="render-from">
                    <xsl:with-param name="txt" select="$txt"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                    <xsl:with-param name="typeOrder" select="$typeOrder"/>
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
