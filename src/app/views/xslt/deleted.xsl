<?xml version="1.0" encoding="UTF-8"?>
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
  
  xmlns:utils="books.oecd.org/utils"
  >
  
  <xsl:output method="xhtml"/>
  
  <xsl:variable name="languages" select="doc('/referential/languages.xml')/oe:languages"/>

  <!-- main template, creates page structure -->
  <xsl:template match="oe:item">
    
    <div class="row">
      
      <xsl:variable name="coverImage" select="'cover_not_yetm.jpg'"/>
      <xsl:variable name="thumbnail-url" select="'http://images.oecdcode.org/covers/150/'" />
      <xsl:if test="$coverImage">       
        <!-- thumbnail-->
        <div class="span3">
          <img src="{concat($thumbnail-url, $coverImage)}" class="img-polaroid cover"/>
        </div>
      </xsl:if>
      
      <!-- title + metadata -->
      <div id="metadata" class="span9">
        This content is no longer published.
      </div> 
      
    </div>
    
  </xsl:template>
  
</xsl:stylesheet>
