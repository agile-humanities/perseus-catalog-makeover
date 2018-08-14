<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="#all" version="3.0">
    <xsl:output indent="yes"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 16, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="/">
        <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink">
            <titleInfo>
                <title>Fragmenta historicorum graecorum</title>
            </titleInfo>
            <name authority="naf" type="personal"
                xlink:href="http://errol.oclc.org/laf/nr95-8185.html">
                <namePart>Müller, Karl</namePart>
                <namePart type="termsOfAddress">of Paris</namePart>
                <role>
                    <roleTerm authority="marcrelator" type="text">creator</roleTerm>
                </role>
            </name>
            <originInfo>
                <place>
                    <placeTerm type="text">Parisiis</placeTerm>
                </place>
                <publisher>Editore Ambrosio Firmin Didot</publisher>
                <dateIssued>1849</dateIssued>
                <dateIssued encoding="marc">1849</dateIssued>
                <issuance>monographic</issuance>
            </originInfo>
            <identifier type="lccn">none for this manifestation</identifier>
            <identifier type="oclc">221365708</identifier>
            <identifier type="oca">fragmentahistori03mueluoft</identifier>
            <classification authority="lcc">PA3490 M84</classification>
            <subject authority="lcsh">
                <topic>History, Ancient</topic>
                <topic>Collections</topic>
            </subject>
            <subject authority="lcsh">
                <topic>Historians</topic>
                <topic>Greece</topic>
            </subject>
            <subject authority="lcsh">
                <topic>Greece</topic>
                <topic>History</topic>
                <topic>Sources</topic>
            </subject>
            <location>
                <url displayLabel="WorldCat">http://worldcat.org/oclc/221365708</url>
            </location>
            <location>
                <url displayLabel="Open Content Alliance"
                    >http://www.archive.org/details/fragmentahistori03mueluoft</url>
            </location>
            <location>
                <url displayLabel="Open Library"
                    >http://www.openlibrary.org/details/fragmentahistori03mueluoft</url>
            </location>
            <location>
                <url displayLabel="GoogleBooks">http://books.google.com/books?id=oqcKAAAAYAAJ</url>
            </location>

            <xsl:apply-templates select="volumes/volume"/>
        </mods>
    </xsl:template>

    <xsl:template match="volume">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" otherType="volume"
            displayLabel="{@n}">
            <part type="volume">
                <detail type="volume">
                    <title>
                        <xsl:value-of select="@n"/>
                    </title>
                </detail>
            </part>
            <xsl:apply-templates/>
        </relatedItem>
    </xsl:template>

    <xsl:template match="group">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" otherType="section" displayLabel="{@name}">
            <xsl:apply-templates/>
        </relatedItem>
    </xsl:template>

    <xsl:template match="work">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" otherType="work">
            <xsl:attribute name="displayLabel">
                <xsl:apply-templates select="title"/>
            </xsl:attribute>
            <identifier type="ctsurn">
                <xsl:value-of select="@ctsurn"/>
            </identifier>
            <titleInfo>
                <title>
                    <xsl:apply-templates select="title"/>
                </title>
            </titleInfo>
            <name>
                <namePart>
                    <xsl:value-of select="ancestor::group/@name"/>
                </namePart>
                <nameIdentifier type="ctsurn">
                    <xsl:value-of select="ancestor::group/@urn"/>
                </nameIdentifier>
                <role>
                    <roleTerm type="text" authority="marcrelator">creator</roleTerm>
                </role>
            </name>
            <xsl:apply-templates select="expression"/>
        </relatedItem>
    </xsl:template>

    <xsl:template match="expression">
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" otherType="expression">
            <identifier type="ctsurn">
                <xsl:value-of select="@ctsurn"/>
            </identifier>
        </relatedItem>
    </xsl:template>

</xsl:stylesheet>
