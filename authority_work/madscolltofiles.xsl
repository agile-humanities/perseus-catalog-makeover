<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mads="http://www.loc.gov/mads/v2"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
    xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:local="http://cewconsulting.com"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 10, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p>Given a madsCollection generated from AAE spreadsheet
            data, generates files for each mads and for each rdf extension.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"/>
    
    <xsl:variable name="root">/tmp</xsl:variable>
    
    <xsl:function name="local:filepath">
        <xsl:param name="ctsurn" />
        
        <xsl:sequence select="string-join(($root, replace($ctsurn, '[:.]', '/')), '/')" />
    </xsl:function>
    
    <xsl:function name="local:madsFilePath">
        <xsl:param name="ctsurn" />
        <xsl:variable name="basename">
            <xsl:value-of select="tokenize($ctsurn, ':')[4]"/>
        </xsl:variable>
        <xsl:sequence select="string-join((string-join((local:filepath($ctsurn), $basename), '/'), 'mads', 'xml'), '.')"></xsl:sequence>
    </xsl:function>
    
    <xsl:template match="mads:madsCollection" exclude-result-prefixes="#all">
        <xsl:comment>Works generated from AAE Greek Authors</xsl:comment>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:dcterms="http://purl.org/dc/terms"
            xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
            
            <xsl:apply-templates select="mads:mads" mode="rdf" exclude-result-prefixes="#all"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="mads:mads" mode="mads">
        <xsl:variable name="filepath" select="local:madsFilePath(mads:identifier[@type='ctsurn'])"/>
        <xsl:result-document method="xml" href="{$filepath}">
            <xsl:copy-of select="." />
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="mads:mads" mode="rdf" exclude-result-prefixes="#all">
        <xsl:copy-of select="mads:extension/rdf:RDF/child::*" exclude-result-prefixes="#all" />
    </xsl:template>
    
</xsl:stylesheet>