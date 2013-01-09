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
  <xsl:variable name="thumbnail-url-150">http://images.oecdcode.org/covers/150/</xsl:variable>
  
  <!-- main template, creates page structure -->
  <xsl:template match="oe:item">
    <xsl:variable name="biblio" select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]" />
    <div class="row">
      <xsl:if test="oe:coverImage">
        <!-- thumbnail-->
        <div class="span3">
          <xsl:apply-templates select="oe:coverImage"/>
        </div>
      </xsl:if>
      
      <!-- title + metadata -->
      <div id="metadata" class="span9">
        <xsl:apply-templates select="(oe:parents/oe:item[@type = 'bookseries']/oe:bibliographic[@xml:lang eq 'en'],oe:parents/oe:item[@type = 'bookseries']/oe:bibliographic)[1]"/>
        <xsl:apply-templates select="$biblio/dt:title"/>
        <xsl:apply-templates select="$biblio/oe:subTitle"/>
        
        <div class="languages">
          <xsl:apply-templates select="dt:language"/>
        </div>
        
        <div class="availability">
          <xsl:apply-templates select="dt:available"/>
          <xsl:apply-templates select="oe:upcomingEdition"/>
        </div>
        
        <xsl:apply-templates select="oe:translations"/>
        
        <div class="links">
          <xsl:apply-templates select="oe:freepreview"/>
          <xsl:apply-templates select="oe:parents/oe:item[@type = 'periodical']/oe:doi"/>
          <xsl:apply-templates select="oe:doi"/>
          <xsl:apply-templates select="oe:bookshop"/>
          <xsl:apply-templates select="oe:parents/oe:item[@type = 'periodical']/oe:bookshop"/>
        </div>
      </div>
      
    </div>
    
    <div class="row">
      <div class="span12">
        <!-- abstract -->
        <xsl:apply-templates select="$biblio/dt:abstract"/>
        
        <!-- toc -->
        <xsl:apply-templates select="oe:toc"/>
        
        <!-- multilingual summaries -->
        <xsl:apply-templates select="oe:summaries"/>
        
        <h4>Related links</h4>
        <div id="backlinks"></div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="oe:parents//oe:bibliographic">
    <h4 class="series">
      <a href="{../oe:doi/@rdf:resource}" target="_blank"><xsl:value-of select="dt:title"/></a>
    </h4>  
  </xsl:template>
  
  <xsl:template match="dt:title">
    <h3 class="title">
      <a href="{../../oe:doi/@rdf:resource}" target="_blank"><xsl:value-of select="."/></a>
    </h3>
  </xsl:template>
  
  <xsl:template match="oe:subTitle">
    <h4 class="subtitle">
      <a href="{../../oe:doi/@rdf:resource}" target="_blank"><xsl:value-of select="."/></a>
    </h4>
  </xsl:template>
  
  <xsl:template match="dt:language">
    <xsl:value-of select="string-join( data($languages//oe:language[@id = current()]/oe:label[@xml:lang = 'en']) ,'/')" />
  </xsl:template>
  
  <xsl:template match="dt:available">
    <span>
      <xsl:choose>
        <xsl:when test="xs:dateTime(.) gt current-dateTime()"><i class="icon-time"></i> To be published on </xsl:when>
        <xsl:otherwise>Published on </xsl:otherwise>
      </xsl:choose>
      <span class="pubdate"><xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/></span>
    </span>
  </xsl:template>
  
  <xsl:template match="oe:upcomingEdition">
    <div>
      <span>Next edition: </span><a href="{oe:doi/@rdf:resource}" target="_blank" class="pubdate"><xsl:value-of select="format-dateTime(dt:available, '[D] [MNn] [Y]')"/></a>
    </div>
  </xsl:template>
  
  <xsl:template match="oe:translations">
    <xsl:if test="oe:translation">
      <div class="translations">
        <span>Also available in <xsl:apply-templates select="oe:translation"/></span>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- display a translation link, just one; add a comma if it is not the last -->
  <xsl:template match="oe:translation">
    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
    <a href="{utils:link(@rdf:resource)}">
      <xsl:value-of select="string-join( data($languages//oe:language[@id = current()/dt:language]/oe:label[@xml:lang = 'en']) ,'/')" />
    </a>
  </xsl:template>
  
  <xsl:template match="oe:freepreview">
    <a class="btn" href="{@rdf:resource}" target="_blank">Read</a>
  </xsl:template>
  
  <xsl:template match="oe:bookshop">
    <a class="btn" href="{@rdf:resource}" target="_blank">
      <xsl:choose>
        <xsl:when test="xs:dateTime(../dt:available) gt current-dateTime()">Pre-order this </xsl:when>
        <xsl:otherwise>Buy this </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="../@type"/>
    </a>
  </xsl:template>
  
  <xsl:template match="oe:doi">
    <a class="btn" href="{@rdf:resource}" target="_blank">iLibrary</a>
  </xsl:template>
  
  <xsl:template match="oe:parents//oe:doi">
    <a class="btn" href="{@rdf:resource}" target="_blank">See previous editions</a>
  </xsl:template>
  
  <xsl:template match="oe:parents//oe:bookshop">
    <a class="btn" href="{@rdf:resource}" target="_blank">Subscribe</a>
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
        <xsl:if test="oe:item//dt:abstract"><button class="btn" data-toggle=".toc-abstract"><i class="icon-eye-open"></i> Abstracts</button></xsl:if>
        <xsl:if test="oe:item/oe:item"><button class="btn" data-toggle=".toc-sublist"><i class="icon-eye-open"></i> Tables/Graphs</button></xsl:if>
      </div>
      <h4>Table of Contents</h4>
      <ul id="toc-root" class="toc">
        <xsl:apply-templates select="oe:item"></xsl:apply-templates>
      </ul>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:item">
    <xsl:variable name="biblio" select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]" />
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
        <xsl:value-of select="$biblio/dt:title"/>
        
        <div class="toc-details">
          <xsl:apply-templates select="$biblio/dt:abstract"/>
          
          <xsl:if test="oe:item">
            <ul class="toc toc-sublist">
              <xsl:apply-templates select="oe:item"></xsl:apply-templates>
            </ul>
          </xsl:if>
        </div>
      </div>
    </li>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:freepreview">
    <xsl:call-template name="toc-link">
      <xsl:with-param name="icon">icon-eye-open</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:bookshop">
    <xsl:call-template name="toc-link">
      <xsl:with-param name="icon">icon-shopping-cart</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="oe:toc//oe:doi">
    <xsl:call-template name="toc-link">
      <xsl:with-param name="icon">icon-download-alt</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="toc-link">
    <xsl:param name="icon"/>
    <a href="{@rdf:resource}" target="_blank"><i class="{$icon}"></i></a>
  </xsl:template>
  
  <xsl:template match="oe:toc//dt:abstract">
    <p class="toc-abstract">
      <xsl:value-of select="xdmp:tidy(.)[2]"/>
    </p>
  </xsl:template>
  
  <!-- returns a local link for a given DOI -->
  <xsl:function name="utils:link">
    <xsl:param name="id"/>
    <xsl:value-of select="concat('/display/', $id)"/>
  </xsl:function>
</xsl:stylesheet>
