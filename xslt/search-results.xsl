<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:search="http://marklogic.com/appservices/search" xmlns:dt="http://purl.org/dc/terms/">  

  <xsl:variable name="types-doc" select="doc('/assets/mappings/pubtypes.xml')"/>
  
  <xsl:template match="/" as="item()*">
    <xsl:apply-templates select="child::node()"/>
  </xsl:template>
  
  <xsl:template match="search:result" as="item()*">
    <xsl:variable name="url" select="substring-after(substring-before(@uri, '.xml'), '/content')"/>
    <xsl:variable name="type" select="search:snippet/search:type/text()"/>
    <xsl:variable name="title" select="search:snippet/search:title/text()"/>
    <div class="row">
      <h4>
        <span class="pubtype-label round label {data($types-doc//type[./text() eq $type]/@color)}"><xsl:value-of select="$type" disable-output-escaping="no"/></span>
        <a href="{$url}">
          <xsl:value-of select="$title" disable-output-escaping="no"/>
        </a>
      </h4>
      <xsl:apply-templates select="child::node()"/>
    </div>
    <hr/><br/>
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
  
  <xsl:template match="search:metrics|search:qtext|search:title|search:type" as="item()*"/>
</xsl:stylesheet>
