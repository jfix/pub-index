<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:o="http://www.oecd.org/metapub/oecdOrg/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dt="http://purl.org/dc/terms/"
    xmlns:search="http://marklogic.com/appservices/search"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    <xsl:param name="url"/>
    <xsl:param name="image-server">http://images.oecdcode.org/covers/</xsl:param>
    
    <xsl:template match="*"/>
    
    <xsl:template match="search:response">
        <root>
            <meta>
                <xsl:call-template name="meta"/>
            </meta>
            <results>
                <xsl:apply-templates select="search:result"/>
            </results>
        </root>
    </xsl:template>
    
    <xsl:template match="search:result|o:bibliographic">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="search:result/o:item">
        <result>
            <publication-type><xsl:value-of select="@type"/></publication-type>
            <xsl:apply-templates select="
                *[not(local-name() = 'subject') and not(local-name() = 'country')] 
                "/>
            
            <xsl:if test="dt:subject">
                <topics>
                    <xsl:apply-templates select="dt:subject"/>
                </topics>
            </xsl:if>
            <xsl:if test="o:country">
                <countries>
                    <xsl:apply-templates select="o:country"/>
                </countries>
            </xsl:if>
        </result>
    </xsl:template>
    
    <xsl:template match="dt:subject">
        <topic><xsl:apply-templates/></topic>
    </xsl:template>

    <xsl:template match="o:country">
        <country><xsl:apply-templates/></country>
    </xsl:template>
    
    <xsl:template match="o:coverImage">
        <thumbnails>
            <xsmall><xsl:value-of select="concat($image-server, '75/', .)"/></xsmall>
            <small><xsl:value-of select="concat($image-server, '100/', .)"/></small>
            <medium><xsl:value-of select="concat($image-server, '150/', .)"/></medium>
<!--            <large><xsl:value-of select="concat($image-server, '200/', .)"/></large>-->            <xlarge><xsl:value-of select="concat($image-server, '340/', .)"/></xlarge>
        </thumbnails>
    </xsl:template>
    <xsl:template match="dt:language">
        <language><xsl:apply-templates/></language>
    </xsl:template>
    
    <xsl:template match="dt:title">
        <title><xsl:apply-templates/></title>
    </xsl:template>
    
    <xsl:template match="o:subTitle">
        <subtitle><xsl:apply-templates/></subtitle>
    </xsl:template>
    
    <xsl:template match="dt:available">
        <publication-date><xsl:apply-templates/></publication-date>
    </xsl:template>
    
    <xsl:template match="o:link">
        <xsl:element name="{@type}">
            <xsl:value-of select="@rdf:resource"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="meta">
        <query><xsl:value-of select="//search:qtext"/></query>
        <total-results><xsl:value-of select="@total"/></total-results>
        <start-index><xsl:value-of select="@start"/></start-index>
        <page-length><xsl:value-of select="@page-length"/></page-length>
        <original-url><xsl:value-of select="$url"/></original-url>
    </xsl:template>
</xsl:stylesheet>