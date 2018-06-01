<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 27, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p>apply to lyra_items2.xml</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" />
    
    
    <xsl:template match="man">
        <relatedItem type='constituent' otherType='manifestation'>
            <xsl:attribute name="displayLabel">
                <xsl:value-of select="item[1]/meta/title"/>
            </xsl:attribute>
            
            <xsl:for-each select="item">
                <xsl:copy-of select="current()/relatedItem" />
            </xsl:for-each>
            
        </relatedItem>
    </xsl:template>
</xsl:stylesheet>