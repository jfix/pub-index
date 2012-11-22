<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: publication.xsl 75 2012-11-09 17:24:48Z Lerat_T $ -->
<xsl:stylesheet extension-element-prefixes="xdmp" 
  exclude-result-prefixes="#all" version="2.0" 
  default-validation="strip" 
  input-type-annotations="unspecified" 
  xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/" 
  xmlns:dt="http://purl.org/dc/terms/" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xdmp="http://marklogic.com/xdmp" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:lang="language-data" 
  xmlns="http://www.w3.org/1999/xhtml"
  >
  
  <xsl:output method="xhtml"/>
  
  <!-- main template, creates page structure -->
  <xsl:template match="oe:backlinks" as="item()*">
    <dl>
      <xsl:apply-templates select="//oe:item"></xsl:apply-templates>
    </dl>
  </xsl:template>
  
  <xsl:template match="oe:item">
    <dt><a><xsl:attribute name="href"><xsl:value-of select="oe:link"/></xsl:attribute><xsl:value-of select="oe:title"/></a></dt>
    <dd><xsl:value-of select="oe:snippet"/></dd>
  </xsl:template>
  
</xsl:stylesheet>
