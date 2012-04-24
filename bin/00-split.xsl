<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" 
    xmlns:dt="http://purl.org/dc/terms/" 
    xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs xd"
    
    version="2.0">
    <!-- use this stylesheet in oxygen by right-clicking on the "in/" directory 
         in the project pane, and apply "kappa-metadata-split-1" scenario 
         (or similarly named) - this will split items in out/type/...xml
    -->
  
    <!-- 
      this stylesheet splits the big files for each publication type into
      many files, one per object. this makes it easier to load them into
      marklogic (although one could also set the fragment root to the first 
      child elements ...)
    
      it also adds a pubtype element as a child to each root node as this will
      allow faceting by publication type (something that doesn't seem
      easily feasible without an attribute or element value)
      ==> of course, the export could add this, which would make this step
          superfluous.
      ==> the export could also split the big files straight away, but 
          this doesn't really matter at this stage.
    
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- empty dateTimes will throw the range indexes
         ==> for now, insert current dateTime 
         ==> but obviously that's suboptimal -->
    <xsl:template match="dt:available[string-length(.) = 0]">
      <dt:available>
        <xsl:value-of select="fn:current-dateTime()"/>
      </dt:available>
    </xsl:template>
  
    <xsl:template match="/*/*">
      <xsl:variable name="type" select="lower-case(local-name(.))"/>
        <xsl:result-document  href="{concat('../../out/', $type, '/', dt:identifier/text(), '.xml')}">
            <xsl:element name="{local-name(.)}">
              <!--<xsl:attribute name="pubtype" select="$type"/>-->
                <xsl:copy-of select="@*"/>
                <oe:pubtype><xsl:value-of select="$type"/></oe:pubtype>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>