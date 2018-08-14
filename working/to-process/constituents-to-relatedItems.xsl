<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd mods"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 4, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" />
    
    <xsl:template match="constituents">
        <modsCollection xmlns="http://www.loc.gov/mods/v3">
            <xsl:apply-templates />
        </modsCollection>
    </xsl:template>
    
    <xsl:template match="section">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='work'>
            <xsl:attribute name="displayLabel">
                <xsl:value-of select="normalize-space(constituent[1]//mods:title)"/>
            </xsl:attribute>
            <identifer type='ctsurn'>
                <xsl:value-of select="replace(constituent[1]/@ctsurn, '^(.*)\..*$', '$1')"/>
            </identifer>
            <xsl:apply-templates />            
        </relatedItem>
    </xsl:template>
    
    <xsl:template match="constituent">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='manifestation'>
            <identifier type='ctsurn'><xsl:value-of select="@ctsurn"/></identifier>
        </relatedItem>
    </xsl:template>
    
</xsl:stylesheet>