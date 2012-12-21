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
  xmlns="http://www.w3.org/1999/xhtml">  
  
  <xsl:output omit-xml-declaration="yes" method="xhtml"/>
  <xsl:variable name="topics" select="doc('/referential/topics.xml')/oe:topics"/>
  <xsl:variable name="countries" select="doc('/referential/countries.xml')/oe:countries"/>
  <xsl:variable name="languages" select="doc('/referential/languages.xml')/oe:languages"/>
  
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
    <xsl:variable name="cover" select="(oe:coverImage/text(),'cover_not_yetm.jpg')[1]"/>
    <xsl:variable name="cover-url" select="concat('http://images.oecdcode.org/covers/60/', $cover)"/>
    <div class="row">
      <div class="span2">
        <h4 style="text-align:right;">
          <span class="pubtype-label label {data($type)}"><xsl:value-of select="$type"/></span>
        </h4>
        <p style="font-size: 0.9em; text-align:right">
          <xsl:apply-templates select="dt:available"/>
        </p>
        <p style="font-size: 0.9em; text-align:right">
          <xsl:apply-templates select="dt:language"/>
        </p>
      </div>
      <div class="span7">
        <xsl:if test="$cover">
          <a href="{$url}"><img src="{$cover-url}" alt="Cover image" class="search-result-thumbnail"/></a> 
        </xsl:if>
        <xsl:apply-templates select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]"></xsl:apply-templates>
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
  
  <xsl:template match="oe:bibliographic">
    <h4>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="concat('/display/', ../dt:identifier)"></xsl:value-of></xsl:attribute>
        <xsl:value-of select="dt:title"/>
      </a>
    </h4>
    <xsl:if test="oe:subTitle">
      <h5>
        <a>
          <xsl:attribute name="href"><xsl:value-of select="concat('/display/', ../dt:identifier)"></xsl:value-of></xsl:attribute>
          <xsl:value-of select="oe:subTitle"/>
        </a>
      </h5>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="dt:available">
    <span class="availability">
      <xsl:if test="xs:dateTime(.) gt current-dateTime()"><i class="icon-time"></i></xsl:if>
      <xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/>
    </span>
  </xsl:template>
  
  <xsl:template match="dt:language">
    <xsl:if test="position() > 1"><xsl:text>/</xsl:text></xsl:if>
    <span data-facet="language" data-value="{.}" class="facet-value">
      <xsl:value-of select="data($languages/oe:language[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>
  
  <xsl:template match="dt:subject" as="item()*">
    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
    <span data-facet="subject" data-value="{.}" class="facet-value">
      <xsl:value-of select="data($topics/oe:topic[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>
  
  <xsl:template match="oe:country" as="item()*">
    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
    <span data-facet="country" data-value="{.}" class="facet-value">
      <xsl:value-of select="data($countries/oe:country[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>
  
</xsl:stylesheet>
