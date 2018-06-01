<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd mods"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 3, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" />
    
    <xsl:template match="volumes">
        <modsCollection xmlns="http://www.loc.gov/mods/v3">
            <xsl:apply-templates />
        </modsCollection>
    </xsl:template>
    
    <xsl:template match="volume">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='volume'>
            <xsl:attribute name="displayLabel">
                <xsl:value-of select="concat('Volume ', @n)"/>
            </xsl:attribute>
            <xsl:apply-templates />
        </relatedItem>
    </xsl:template>
    
    <xsl:template match="group">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='section'>
            <xsl:attribute name="displayLabel">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <identifier type='ctsurn'><xsl:value-of select="@urn"/></identifier>
            <xsl:apply-templates />
        </relatedItem>
    </xsl:template>
    
    <xsl:template match="work">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='section'>
            <xsl:attribute name="displayLabel">
                <xsl:apply-templates select="title" />
            </xsl:attribute>
            <identifier type='ctsurn'><xsl:value-of select="@ctsurn"/></identifier>
            <xsl:apply-templates select="expression" />
        </relatedItem>
    </xsl:template>
    
    <xsl:template match="expression">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='manifestation'>
            <identifier type='ctsurn'>
                <xsl:value-of select="concat(@ctsurn, '-F3')"/>
            </identifier>
        </relatedItem>    
    </xsl:template>
    
</xsl:stylesheet>