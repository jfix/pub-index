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
        <xsl:apply-templates select="oe:parent"/>
        <xsl:apply-templates select="(dt:title[xml:lang='en'],dt:title)[1]"/>
        <xsl:apply-templates select="(oe:subTitle[xml:lang='en'],oe:subTitle)[1]"/>
        <xsl:apply-templates select="dt:available"/>
        <xsl:apply-templates select="oe:translations"/>
        
        <xsl:call-template name="tpl.consumer-box">
          <xsl:with-param name="type" select="@type"/>
          <xsl:with-param name="buy-link" select="(oe:bookshop/text(), '')[1]"/>
          <xsl:with-param name="read-link" select="(oe:doi/@rdf:resource, '')[1]"/>
        </xsl:call-template>
      </div>
      
    </div>
    
    <div class="row">
      <div class="span12">
        <!-- abstract -->
        <xsl:apply-templates select="(dt:abstract[xml:lang='en'],dt:abstract)[1]"/>
        
        <!-- toc -->
        <xsl:apply-templates select="oe:toc"/>
        
        <!-- multilingual summaries -->
        <xsl:apply-templates select="oe:summaries"/>
        
        <h4>Related links</h4>
        <div id="backlinks"></div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="oe:parent">
    <h4>
      <a href="{utils:link(oe:doi/@rdf:resource)}"><xsl:value-of select="dt:title"/></a>
    </h4>  
  </xsl:template>
  
  <xsl:template match="dt:title">
    <h3><xsl:value-of select="."/></h3>
  </xsl:template>
  
  <xsl:template match="oe:subTitle">
    <h4><xsl:value-of select="."/></h4>
  </xsl:template>
  
  <xsl:template match="dt:available">
    <div>
      <span>
        Published on 
        <span class="pubdate"><xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/></span>
      </span>
    </div>  
  </xsl:template>
  
  <xsl:template match="oe:translations">
    <div>
      <span>Also available in </span>
      <xsl:apply-templates select="child::node()"/>
    </div>
  </xsl:template>
  
  <!-- display a translation link, just one; add a comma if it is not the last -->
  <xsl:template match="oe:translation">
    <strong>
      <a href="{utils:link(oe:doi/@rdf:resource)}">
        <xsl:value-of select="string-join($lang-doc//lang:language[@id = current()/dt:language],'/')" />
      </a>
    </strong>
    <xsl:if test="following-sibling::oe:translation[1]">, </xsl:if>
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
    <p class="abstract">
      <xsl:value-of select="xdmp:tidy(.)[2]"/>
    </p>
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
      <div>
        <div class="links pull-right">
          <xsl:apply-templates select="oe:freepreview"/>
          <xsl:apply-templates select="oe:bookshop"/>
          <xsl:apply-templates select="oe:doi"/>
        </div>
        
        <xsl:choose>
          <xsl:when test="@type eq 'chapter'"><i class="icon-file"></i></xsl:when>
          <xsl:when test="@type eq 'table'"><i class="icon-th-list"></i></xsl:when>
          <xsl:when test="@type eq 'graph'"><i class="icon-signal"></i></xsl:when>
        </xsl:choose>
        <xsl:value-of select="dt:title"/>
        
        <div class="toc-details">
          <xsl:if test="dt:abstract"><p class="toc-abstract"><xsl:value-of select="xdmp:tidy(dt:abstract/text())[2]"></xsl:value-of></p></xsl:if>
          
          <xsl:if test="oe:item">
            <ul class="toc toc-sublist">
              <xsl:apply-templates select="oe:item"></xsl:apply-templates>
            </ul>
          </xsl:if>
        </div>
      </div>
    </li>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:item//oe:freepreview">
    <a target="_blank">
      <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"></xsl:value-of></xsl:attribute>
      <i class="icon-eye-open"></i>
    </a>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:item//oe:bookshop">
    <a target="_blank">
      <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"></xsl:value-of></xsl:attribute>
      <i class="icon-shopping-cart"></i>
    </a>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:item//oe:doi">
    <a target="_blank">
      <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"></xsl:value-of></xsl:attribute>
      <i class="icon-download-alt"></i>
    </a>
  </xsl:template>
  
  <!-- display the Read and Buy buttons -->
  <xsl:template name="tpl.consumer-box">
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="buy-link" as="xs:string"/>
    <xsl:param name="read-link" as="xs:string"/>
    <br/>
    <div>
      <xsl:choose>
        <xsl:when test="$read-link = ''">
          <a class="btn disabled" href="#">Unavailable</a>
        </xsl:when>
        <xsl:otherwise>
          <a class="btn" href="{$read-link}">Read this <xsl:value-of select="$type"/></a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="$buy-link = ''">
          <a class="btn disabled" href="#">Unavailable for purchase</a>          
        </xsl:when>
        <xsl:otherwise>
          <a class="btn" href="{$buy-link}">Buy this <xsl:value-of select="$type"/></a>
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
