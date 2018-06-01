<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 20, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p>For cleaning up Lyra Graeca</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" />
    
    <xsl:template match="mods:relatedItem[@otherType='section'][mods:relatedItem[@otherType='expression']]">
        <xsl:variable name="workid">
            
        </xsl:variable>
        <relatedItem xmlns="http://www.loc.gov/mods/v3">
            <xsl:copy-of select="@*" />
            <relatedItem type='constituent' otherType='work'>
                <xsl:analyze-string select="mods:relatedItem[@otherType='expression'][1]/mods:identifier" regex="^(.*)\..*$">
                    <xsl:matching-substring>
                        <identifier type='ctsurn'>
                            <xsl:value-of select="regex-group(1)"/>
                        </identifier>
                    </xsl:matching-substring>   
                    
                </xsl:analyze-string>
                <xsl:apply-templates />
            </relatedItem>
        </relatedItem>
    </xsl:template>
 
</xsl:stylesheet>