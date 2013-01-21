<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/"
  xmlns:dt="http://purl.org/dc/terms/"
  exclude-result-prefixes="#all">
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dt:abstract">
    <dt:abstract xmlns="http://www.w3.org/1999/xhtml">
      <xsl:copy-of select="xdmp:tidy(.)[2]//*:body/child::node()"/>
    </dt:abstract>
  </xsl:template>
  
</xsl:stylesheet>