<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/TR/WD-xsl/FO"
>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="doc">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>Standoff-Annotationen</title>
            </head>
            <body>
                <h1>Annotationen</h1>

                test
                <h2>Originaltext</h2>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
