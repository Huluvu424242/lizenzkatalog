<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <!-- Ausgabe als HTML -->
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Einstieg -->
    <xsl:template match="/">
        <xsl:apply-templates select="/annotation"/>
    </xsl:template>

    <!-- Haupttemplate für <annotation> -->
    <xsl:template match="annotation">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Standoff-Annotationen</title>
                <style>
                    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 1rem; }
                    table { border-collapse: collapse; width: 100%; }
                    th, td { border: 1px solid #ddd; padding: .5rem .6rem; text-align: left; vertical-align: top; }
                    th { background: #f6f8fa; }
                    code { background: #f6f8fa; padding: .1rem .25rem; border-radius: 4px; }
                    pre { white-space: pre-wrap; background: #fafafa; border: 1px dashed #ddd; padding: .75rem; }
                    .muted { color: #777; }
                </style>
            </head>
            <body>
                <h1>Annotationen</h1>

                <!-- Gesamttext als String (XSLT 1.0: string() auf Knoten) -->
                <xsl:variable name="txt" select="string(text)"/>

                <!-- Tabelle der Annotationen -->
                <table>
                    <tr>
                        <th>#</th>
                        <th>Type</th>
                        <th>ID</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Auszug</th>
                        <th>Attribute</th>
                    </tr>

                    <!-- Zuerst: Spannen mit start/end -->
                    <xsl:for-each select="notes/note[@start and @end]">
                        <xsl:sort select="number(@start)" data-type="number" order="ascending"/>
                        <xsl:sort select="number(@end)" data-type="number" order="ascending"/>
                        <xsl:variable name="s" select="number(@start)"/>
                        <xsl:variable name="e" select="number(@end)"/>
                        <!-- XSLT substring ist 1-basiert: +1 bei Start, Länge = end - start -->
                        <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s)"/>

                        <tr>
                            <td><xsl:value-of select="position()"/></td>
                            <td><code><xsl:value-of select="@type"/></code></td>
                            <td><xsl:value-of select="@id"/></td>
                            <td><xsl:value-of select="@start"/></td>
                            <td><xsl:value-of select="@end"/></td>
                            <td><xsl:value-of select="normalize-space($frag)"/></td>
                            <td>
                                <!-- Alle sonstigen Attribute außer id/type/start/end -->
                                <xsl:for-each select="@*[not(name()='id' or name()='type' or name()='start' or name()='end')]">
                                    <div><b><xsl:value-of select="name()"/>:</b> <xsl:value-of select="."/></div>
                                </xsl:for-each>
                            </td>
                        </tr>
                    </xsl:for-each>

                    <!-- Danach: Singletons ohne start/end -->
                    <xsl:for-each select="notes/note[not(@start) or not(@end)]">
                        <xsl:sort select="@type"/>
                        <tr>
                            <td><span class="muted"><xsl:value-of select="position()"/></span></td>
                            <td><code><xsl:value-of select="@type"/></code></td>
                            <td><xsl:value-of select="@id"/></td>
                            <td class="muted">–</td>
                            <td class="muted">–</td>
                            <td class="muted">kein Textbezug</td>
                            <td>
                                <!-- zeige z. B. value="MIT" u.a. Zusatzattribute -->
                                <xsl:for-each select="@*[not(name()='id' or name()='type' or name()='start' or name()='end')]">
                                    <div><b><xsl:value-of select="name()"/>:</b> <xsl:value-of select="."/></div>
                                </xsl:for-each>
                            </td>
                        </tr>
                    </xsl:for-each>

                </table>

                <!-- Hinweis, falls es gar keine Notes gibt -->
                <xsl:if test="not(notes/note)">
                    <p class="muted">Keine Annotationen vorhanden.</p>
                </xsl:if>

                <h2>Originaltext</h2>
                <pre><xsl:value-of select="$txt"/></pre>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
