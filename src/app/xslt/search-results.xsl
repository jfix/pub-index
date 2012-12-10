<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" default-validation="strip" input-type-annotations="unspecified"
  xmlns:functx="http://www.functx.com"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:search="http://marklogic.com/appservices/search"
  xmlns:dt="http://purl.org/dc/terms/"
  xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/"
  xmlns:country="country-data"
  xmlns:lang="language-data">  
  
  <xsl:output omit-xml-declaration="yes" method="xhtml"/>
  <xsl:variable name="types-doc" select="doc('/refs/pubtypes.xml')"/>
  <xsl:variable name="countries" select="doc('/refs/countries.xml')/country:countries"/>
  <xsl:variable name="languages" select="doc('/refs/languages.xml')/lang:languages"/>
  
  <xsl:template match="search:response" as="item()*">
    <xsl:apply-templates select="search:result"/>
  </xsl:template>
  
  <xsl:template match="search:result" as="item()*">
    <xsl:apply-templates select="search:snippet"/>
  </xsl:template>
  
  <xsl:template match="search:snippet" as="item()*">
    <xsl:variable name="url" select="concat('/display/', dt:identifier)"/>
    
    <xsl:variable name="type" select="oe:type/text()"/>
    <xsl:variable name="title" select="(dt:title[xml:lang eq 'en'],dt:title)[1]/text()"/>
    <xsl:variable name="subtitle" select="(oe:subTitle[xml:lang eq 'en'],oe:subTitle)[1]/text()"/>
    <xsl:variable name="date" select="format-dateTime(dt:available/text(), '[D] [MNn] [Y]')"/>
    <xsl:variable name="cover" select="(oe:coverImage/text(),'cover_not_yetm.jpg')[1]"/>
    <xsl:variable name="cover-url" select="concat('http://images.oecdcode.org/covers/60/', $cover)"/>
    <div class="row">
      <div class="span2">
        <h4 style="text-align:right;">
          <span class="pubtype-label label {data($type)}"><xsl:value-of select="$type"/></span>
        </h4>
        <p style="font-size: 0.9em; text-align:right">
          <span><xsl:value-of select="$date"/></span>                  
        </p>
        <p style="font-size: 0.9em; text-align:right">
          <a href=""><xsl:value-of select="$languages/lang:language[@id = current()/dt:language]/text()"/></a>
        </p>
      </div>
      <div class="span7">
        <xsl:if test="$cover">
          <a href="{$url}"><img src="{$cover-url}" alt="Cover image" class="search-result-thumbnail"/></a> 
        </xsl:if>
        <h4><a href="{$url}"><xsl:value-of select="$title"/></a></h4>
        <xsl:if test="$subtitle">
          <h5><a href="{$url}"><xsl:value-of select="$subtitle"/></a></h5>
        </xsl:if>
        <p><xsl:apply-templates select="search:match"/></p>
        <p style="font-size: 0.9em; text-align: right;">
          <span>Covered by this publication: </span>
          <span><xsl:apply-templates select="dt:subject"/></span>
          <xsl:if test="oe:country">
            <span> | <xsl:apply-templates select="oe:country"/></span>
          </xsl:if>
        </p>
        <hr/>
      </div>  
    </div>
  </xsl:template>
  
  <xsl:template match="search:match" as="item()*">
    <xsl:apply-templates select="child::node()"/>
  </xsl:template>
  
  <xsl:template match="search:highlight" as="item()*">
    <span class="search-result-highlight"><xsl:value-of select="."/></span>
  </xsl:template>
  
  <xsl:template match="node()" as="item()*">
    <xsl:value-of select="xdmp:tidy(.)[2]"/>
  </xsl:template>
  
  <xsl:template match="dt:subject" as="item()*">
    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if><a href=""><xsl:value-of select="."/></a>
  </xsl:template>
  
  <xsl:template match="oe:country" as="item()*">
    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if><a href=""><xsl:value-of select="$countries/country:country[country:code eq upper-case(current())]/country:name/country:en[@case='normal']"/></a>
  </xsl:template>
  
</xsl:stylesheet>
