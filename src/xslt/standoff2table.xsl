<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title>Standoff-Annotationen</title>
        <style>
          body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 1rem; }
          table { border-collapse: collapse; width: 100%; }
          th, td { border: 1px solid #ddd; padding: .5rem .6rem; text-align: left; }
          th { background: #f6f8fa; }
          code { background: #f6f8fa; padding: .1rem .25rem; border-radius: 4px; }
          pre { white-space: pre-wrap; background: #fafafa; border: 1px dashed #ddd; padding: .75rem; }
        </style>
      </head>
      <body>
        <h1>Annotationen</h1>
        <xsl:variable name="txt" select="string(/doc/text)"/>

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

          <xsl:for-each select="/doc/annotations/span">
            <xsl:sort select="@start" data-type="number"/>
            <xsl:variable name="s" select="number(@start)"/>
            <xsl:variable name="e" select="number(@end)"/>
            <xsl:variable name="frag" select="substring($txt, $s + 1, $e - $s)"/>

            <tr>
              <td><xsl:value-of select="position()"/></td>
              <td><code><xsl:value-of select="@type"/></code></td>
              <td><xsl:value-of select="@id"/></td>
              <td><xsl:value-of select="@start"/></td>
              <td><xsl:value-of select="@end"/></td>
              <td><xsl:value-of select="normalize-space($frag)"/></td>
              <td>
                <xsl:for-each select="@*[name() ne 'id' and name() ne 'type' and name() ne 'start' and name() ne 'end']">
                  <div><b><xsl:value-of select="name()"/>:</b> <xsl:value-of select="."/></div>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:for-each>
        </table>

        <h2>Originaltext</h2>
        <pre><xsl:value-of select="$txt"/></pre>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
