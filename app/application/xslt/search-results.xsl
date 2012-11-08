<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" default-validation="strip" input-type-annotations="unspecified" xmlns:functx="http://www.functx.com" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:search="http://marklogic.com/appservices/search" xmlns:dt="http://purl.org/dc/terms/">  
  
  <xsl:output omit-xml-declaration="yes" method="xhtml"/>
  <xsl:variable name="types-doc" select="doc('/refs/pubtypes.xml')"/>
  
  <xsl:template match="/" as="item()*">
    <xsl:apply-templates select="child::node()"/>
  </xsl:template>
  
  <xsl:template match="search:result" as="item()*">
    <xsl:variable name="url" select="concat('/display/', functx:substring-after-last-match(substring-before(@uri, '.xml'), '[/]'))"/>
    
    <xsl:variable name="type" select="search:snippet/search:type/text()"/>
    <xsl:variable name="title" select="search:snippet/search:title/text()"/>
    <xsl:variable name="date" select="format-dateTime(search:snippet/search:date/text(), '[D] [MNn] [Y]')"/>
    <xsl:variable name="cover" select="search:snippet/search:cover/text()"/>
    <xsl:variable name="cover-url" select="concat('http://images.oecdcode.org/covers/60/', $cover)"/>
    <div class="row">
      <div class="span2">
        <h4 style="text-align:right;">
          <span class="pubtype-label label {data($type)}"><xsl:value-of select="$type"/></span>
        </h4>
        <p style="font-size: smaller; text-align:right">
          <span><xsl:value-of select="$date"/></span>                  
        </p>
        
      </div>
      <div class="span7">
        <xsl:if test="$cover">
            <a href="{$url}">
                <img src="{$cover-url}" alt="Cover image" class="search-result-thumbnail"/>
            </a>          
        </xsl:if>
        <h4>
          <a href="{$url}">
            <xsl:value-of select="$title"/>
          </a>
        </h4>
        <xsl:apply-templates select="child::node()"/>
        <hr/>
      </div>  
    </div>
    
  </xsl:template>
  
  <xsl:template match="search:snippet" as="item()*">
    <div>
      <xsl:apply-templates select="child::node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="search:highlight" as="item()*">
    <span class="search-result-highlight">
      <xsl:apply-templates select="child::node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="search:metrics|search:qtext|search:title|search:type|search:facet|search:cover|search:date" as="item()*"/>
  
  <xsl:function name="functx:substring-after-last-match" as="xs:string">
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:param name="regex" as="xs:string"/> 
    
    <xsl:sequence select="        replace($arg,concat('^.*',$regex),'')       "/>
    
  </xsl:function>
</xsl:stylesheet>
