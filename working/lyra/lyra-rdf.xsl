<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 28, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p>Apply to lyra_items2.xml</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"></xsl:output>
    
    <xsl:template match="items">
        <rdf:RDF  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:dcterms="http://purl.org/dc/terms"
            xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:owl="http://www.w3.org/2002/07/owl#">
            
            <xsl:apply-templates select="man"/>
            
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template match="man">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="item">
        <xsl:variable name="workid">
            <xsl:value-of select="replace(meta/ctsurn, '^(.*)\..*$', '$1')"/> 
        </xsl:variable>
        <xsl:variable name="lang">
            <xsl:value-of select="replace(meta/ctsurn, '^.*-(.*)\d$', '$1')"/>
        </xsl:variable>
        
        <rdf:Description about="{meta/ctsurn}-F22">
            <rdf:type rdf:resource="efrbroo:F22_Self_Contained_Expression"/>
            <rdfs:label><xsl:value-of select="meta/title"/></rdfs:label>
            <efrbroo:P72_has_language rdf:resource="http://id.loc.gov/vocabulary/languages/{$lang}"/>
            <efrbroo:R3i_realises rdf:resource="{$workid}"/>
        </rdf:Description>
        
        <rdf:Description about="{meta/ctsurn}-F3">
            <rdf:type rdf:resource="efrbroo:F3_Manifestation_Product_Type"/>
            <rdfs:label><xsl:value-of select="meta/title"/></rdfs:label>
            <efrbroo:CLR6_should_carry>
                <efrbroo:F24_Publication_Expression>
                    <efrbroo:R3i_realises rdf:resource="{meta/ctsurn}-F22"/>
                </efrbroo:F24_Publication_Expression>
            </efrbroo:CLR6_should_carry>
        </rdf:Description>
        
    </xsl:template>
    
</xsl:stylesheet>