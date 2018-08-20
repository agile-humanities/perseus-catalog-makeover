<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="#all"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 11, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"></xsl:output>
    
    <xsl:template match="mods:mods">
        <mods>
        <xsl:apply-templates select="mods:relatedItem[@type='constituent']" />
        </mods>
    </xsl:template>
    
    <xsl:template match="mods:relatedItem[@type='constituent']">
        <relatedItem type='constituent' otherType='work'>
            <xsl:attribute name="displayLabel">
                <xsl:value-of select="mods:titleInfo/mods:title"/>
            </xsl:attribute>
            <xsl:if test="mods:identifier[@type='ctsurn']">
                <identifier type='ctsurn'>
                    <xsl:value-of select="replace(mods:identifier[@type='ctsurn'], '^(.*)\..*$', '$1')"/>
                </identifier>     
            </xsl:if>
            <xsl:if test="mods:identifier[@type='tlg']">
                <identifier type='tlg'>
                    <xsl:value-of select="mods:identifier[@type='tlg']" />
                </identifier>  
            </xsl:if>
            <xsl:if test="mods:identifier[@type='phi']">
                <identifier type='phi'>
                    <xsl:value-of select="mods:identifier[@type='phi']" />
                </identifier>  
            </xsl:if>
            
            <relatedItem type='constituent' otherType='expression'>
                <xsl:if test="mods:identifier[@type='ctsurn']">
                    <identifier type='ctsurn'>
                        <xsl:value-of select="mods:identifier[@type='ctsurn']"/>
                   </identifier>
                </xsl:if>
                
                <xsl:copy-of select="mods:part" />
                <xsl:copy-of select="mods:location" exclude-result-prefixes="#all" />
            </relatedItem>
        </relatedItem>
    </xsl:template>
</xsl:stylesheet>