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
  
  <xsl:variable name="lang-doc" select="doc('/refs/languages.xml')"/>
  <xsl:variable name="root" select="/*[1]"/>
  <xsl:variable name="title" select="/*/dt:title"/>
  <xsl:variable name="pub-type" select="lower-case(local-name($root))"/>
  <xsl:variable name="thumbnail-url-150">http://images.oecdcode.org/covers/150/</xsl:variable>
  
  <!-- main template, creates page structure -->
  <xsl:template match="oe:item">
    <div class="row">
      <xsl:if test="oe:coverImage">
        <!-- thumbnail-->
        <div class="span3">
          <xsl:apply-templates select="oe:coverImage"/>
        </div>
       </xsl:if>
      
      <!-- title + metadata -->
      <div class="span9">
        <xsl:apply-templates select="oe:parent" mode="metadata"/>
        <xsl:apply-templates select="dt:title" mode="metadata"/>
        <xsl:apply-templates select="dt:available" mode="metadata"/>
        <xsl:apply-templates select="oe:translations" mode="metadata"/>
        
        <xsl:call-template name="tpl.consumer-box">
          <xsl:with-param name="buy-link" select="(oe:bookshop/text(), '')[1]"/>
          <xsl:with-param name="read-link" select="(oe:doi/@rdf:resource, '')[1]"/>
        </xsl:call-template>
      </div>
      
    </div>
    
    <!-- abstract -->
    <xsl:apply-templates select="dt:abstract"/>
    
    <!-- toc -->
    <xsl:apply-templates select="oe:toc"/>
    
    <!-- multilingual summaries -->
    <xsl:apply-templates select="oe:summaries" mode="metadata"/>
    
    <h3>Related links</h3>
    <div id="backlinks"></div>
  </xsl:template>
  
  <xsl:template match="oe:parent" mode="metadata">
    <h4>
      <a href="{utils:link(oe:doi/@rdf:resource)}"><xsl:value-of select="dt:title"/></a>
    </h4>  
  </xsl:template>
  
  <xsl:template match="dt:title" mode="metadata">
    <h2><xsl:value-of select="."/></h2>
  </xsl:template>
  
  <xsl:template match="dt:available" mode="metadata">
    <div>
      <span>
        Published on 
        <span class="pubdate"><xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/></span>
      </span>
    </div>  
  </xsl:template>
  
  <xsl:template match="oe:translations" mode="metadata">
    <div>
      <span>Also available in </span>
      <xsl:apply-templates mode="metadata" select="child::node()"/>
    </div>
  </xsl:template>
  
  <!-- display a translation link, just one; add a comma if it is not the last -->
  <xsl:template match="oe:translation" mode="metadata">
    <xsl:variable name="lang-id" select="dt:language/text()"/>
    <strong>
      <a href="{utils:link(oe:doi/@rdf:resource)}">
        <xsl:value-of select="$lang-doc//lang:language[@id eq $lang-id]/text()" />
      </a>
    </strong>
    <xsl:if test="following-sibling::oe:translation[1]">, </xsl:if>
  </xsl:template>
  
  <!-- display the div that contains the list of multilingual summaries, if any -->
  <xsl:template match="oe:summaries" mode="metadata">
    <div class="row">
      <hr/>
      <h3>Multilingual summaries</h3>
      <br/>
      <xsl:choose>
        <xsl:when test="count(oe:summary) &gt; 1">
          The following languages are available:          
        </xsl:when>
        <xsl:otherwise>
          The following language is available:
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="metadata" select="child::node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="oe:summary" mode="metadata">
    <xsl:variable name="lang-id" select="dt:language/text()"/>
    <xsl:variable name="lang-label" select="($lang-doc//lang:language[@id eq $lang-id]/text(), $lang-id)[1]"/>
    <a href="{utils:link(oe:doi/@rdf:resource)}">
      <xsl:value-of select="$lang-label"/>
    </a>
    <xsl:if test="following-sibling::oe:summary[1]">, </xsl:if>
  </xsl:template>
  
  <xsl:template match="dt:status">
    <span class="status"><strong>Status:</strong> <span><xsl:value-of select="."/></span></span>  
  </xsl:template>
  
  <!-- display the cover images if there is one -->
  <xsl:template match="oe:coverImage">
    <img src="{concat($thumbnail-url-150, .)}" class="img-polaroid cover"/>
  </xsl:template>
  
  <!-- display the abstract -->
  <xsl:template match="dt:abstract">
    <div class="row">
      <div class="span12">
        <div class="well well-small abstract">
          <h3><xsl:choose>
            <xsl:when test="@xml:lang = 'en'">Abstract</xsl:when>
            <xsl:when test="@xml:lang = 'fr'">Résumé</xsl:when>
            <xsl:otherwise>Abstract (fallback)</xsl:otherwise>
          </xsl:choose></h3>
          <div>
            <!--<xsl:value-of select="."/>-->
            <xsl:value-of select="xdmp:tidy(.)[2]"/>
          </div>
          <br/>
        </div>
      </div>
    </div>    
  </xsl:template>
  
  <xsl:template match="dt:identifier"/>
  
  <xsl:template match="oe:toc">
    <xsl:if test="oe:item">
      <div id="toc-actions" class="btn-group pull-right">
        <xsl:if test="oe:item/dt:abstract"><button class="btn" data-toggle=".toc-abstract"><i class="icon-eye-open"></i> Abstracts</button></xsl:if>
        <xsl:if test="oe:item/oe:item"><button class="btn" data-toggle=".toc-sublist"><i class="icon-eye-open"></i> Tables/Graphs</button></xsl:if>
      </div>
      <h4>Table of Contents</h4>
      <ul id="toc-root" class="toc">
        <xsl:apply-templates select="oe:item"></xsl:apply-templates>
      </ul>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:item">
    <li>
      <xsl:if test="oe:item"><xsl:attribute name="class">open</xsl:attribute></xsl:if>
      <div>
        <div class="links pull-right">
          <a href=""><i class="icon-eye-open"></i></a>
          <a href=""><i class="icon-shopping-cart"></i></a>
          <xsl:if test="oe:doi">
            <a>
              <xsl:attribute name="href"><xsl:value-of select="oe:doi/@rdf:resource"></xsl:value-of></xsl:attribute>
              <i class="icon-download-alt"></i>
            </a>
          </xsl:if>
        </div>
        
        <xsl:choose>
          <xsl:when test="@type eq 'chapter'"><i class="icon-file"></i></xsl:when>
          <xsl:when test="@type eq 'table'"><i class="icon-th-list"></i></xsl:when>
          <xsl:when test="@type eq 'graph'"><i class="icon-signal"></i></xsl:when>
        </xsl:choose>
        
        <xsl:value-of select="dt:title"/>
        <xsl:if test="dt:abstract"><p class="toc-abstract"><xsl:value-of select="xdmp:tidy(dt:abstract/text())[2]"></xsl:value-of></p></xsl:if>
        
        <xsl:if test="oe:item">
          <ul class="toc toc-sublist">
            <xsl:apply-templates select="oe:item"></xsl:apply-templates>
          </ul>
        </xsl:if>
      </div>
    </li>
  </xsl:template>
  
  <!-- display the Read and Buy buttons -->
  <xsl:template name="tpl.consumer-box">
    <xsl:param name="buy-link" as="xs:string"/>
    <xsl:param name="read-link" as="xs:string"/>
    <br/>
    <div>
      <xsl:choose>
        <xsl:when test="$read-link = ''">
          <a class="btn disabled" href="#">Unavailable</a>
        </xsl:when>
        <xsl:otherwise>
          <a class="btn" href="{$read-link}">Read this <xsl:value-of select="$pub-type"/></a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="$buy-link = ''">
          <a class="btn disabled" href="#">Unavailable for purchase</a>          
        </xsl:when>
        <xsl:otherwise>
          <a class="btn" href="{$buy-link}">Buy this <xsl:value-of select="$pub-type"/></a>
        </xsl:otherwise>
      </xsl:choose>       
    </div>
  </xsl:template>
  
  <!-- returns a local link for a given DOI -->
  <xsl:function name="utils:link">
    <xsl:param name="doi"/>
    <xsl:value-of select="concat('/display/', tokenize($doi, '/')[last()])"/>
  </xsl:function>
</xsl:stylesheet>
