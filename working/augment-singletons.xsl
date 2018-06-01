<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mods="http://www.loc.gov/mods/v3" 
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd mods atom" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p>
                Adds manifestation relatedItem to singleton MODS records
                (those that don't have hosts).
            </xd:p>
            
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="yes"/>
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mods:title">
        <mods:title>
            <xsl:value-of select="normalize-space()"/>
        </mods:title>
    </xsl:template>
    
    <xsl:template match="mods:modsCollection">
        <mods:modsCollection  xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 https://www.loc.gov/standards/mods/mods.xsd">
            <xsl:apply-templates />
        </mods:modsCollection>
    </xsl:template>
    
    
    <xsl:template match="mods:mods">
        <xsl:variable name="displayLabel">
            <xsl:value-of select="normalize-space(mods:titleInfo[1])"/>
        </xsl:variable>
        <xsl:variable name="ctsurn">
            <xsl:value-of select="mods:identifier[@type='ctsurn']"/>
        </xsl:variable>
        <mods xmlns="http://www.loc.gov/mods/v3">
            <xsl:apply-templates/>
            
            <relatedItem type="constituent" otherType="work" displayLabel="{$displayLabel}">
                <identifier type="ctsurn">
                    <xsl:value-of select="replace($ctsurn, '^(.*)\..*$', '$1')"/>
                </identifier>
                <relatedItem type="constituent" othertype="manifestation" displayLabel="{$displayLabel}">
                    <identifier type="ctsurn">
                        <xsl:value-of select="concat($ctsurn, '-F3')"/>
                    </identifier>
                </relatedItem>
            </relatedItem>
        </mods>
    </xsl:template>
    
    
    
</xsl:stylesheet>
