<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet extension-element-prefixes="xdmp" exclude-result-prefixes="#all" version="2.0" default-validation="strip" input-type-annotations="unspecified" xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:dt="http://purl.org/dc/terms/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xhtml"/>
  
  <xsl:variable name="lang-doc" select="doc('/assets/mappings/languages.xml')"/>
  <xsl:variable name="root" select="/*[1]"/>
  <xsl:variable name="title" select="/*/dt:title"/>
  <xsl:variable name="pub-type" select="lower-case(local-name($root))"/>
  
  <!-- main template, creates page structure -->
  <xsl:template match="/" as="item()*">
    <div class="row" style="margin-top: 3em;">
      <!-- thumbnail-->
      <div class="three columns">
        <xsl:apply-templates select="//oe:coverImage"/>
      </div>

      <!-- title + metadata -->
      <div class="nine columns">
        <xsl:apply-templates select="/*/oe:parent" mode="metadata"/>
        <xsl:apply-templates select="/*/dt:title" mode="metadata"/>
        <xsl:apply-templates select="/*/dt:available" mode="metadata"/>
        <xsl:apply-templates select="/*/oe:translations" mode="metadata"/>
        
        <xsl:call-template name="tpl.consumer-box">
          <xsl:with-param name="buy-link" select="(/*/oe:bookshop/text(), '')[1]"/>
          <xsl:with-param name="read-link" select="(/*/oe:doi/@rdf:resource, '')[1]"/>
        </xsl:call-template>
      </div>
    
    </div>
    
    <!-- abstract -->
    <xsl:apply-templates select="/*/dt:abstract"/>
       
    <!-- toc, lof, lot -->
    <xsl:call-template name="tpl.toc-header"/>
    <ul class="tabs-content">
      <xsl:apply-templates select="//oe:chapters"/>
      <xsl:apply-templates select="//oe:tables"/>
      <xsl:apply-templates select="//oe:graphs"/>
    </ul>
    
    <!-- multilingual summaries -->
    <xsl:apply-templates select="//oe:summaries" mode="metadata"/>
    
    
  </xsl:template>
  
  <xsl:template match="oe:parent" mode="metadata" as="item()*">
    <h4>
      <a href="/book/{tokenize(oe:doi/@rdf:resource, '/')[last()]}"><xsl:value-of select="dt:title" disable-output-escaping="no"/></a>
    </h4>  
  </xsl:template>
  
  <xsl:template match="dt:title" mode="metadata" as="item()*">
    <h2><xsl:value-of select="." disable-output-escaping="no"/></h2>
  </xsl:template>
  
  <xsl:template match="dt:available" mode="metadata" as="item()*">
    <div>
      <span>
        Published on 
        <span class="pubdate"><xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')" disable-output-escaping="no"/></span>
      </span>
    </div>  
  </xsl:template>
  
  <xsl:template match="oe:translations" mode="metadata" as="item()*">
    <div>
      <span>Also available in </span>
      <xsl:apply-templates mode="metadata" select="child::node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="oe:translation" mode="metadata" as="item()*">
    <xsl:variable name="link">
      <xsl:value-of select="concat('/', lower-case(local-name($root)), '/', tokenize(./oe:doi/@rdf:resource, '/')[last()])" disable-output-escaping="no"/>
    </xsl:variable>
    <xsl:variable name="lang-id" select="dt:language/text()"/>
    
    <strong>
      <a href="{$link}">
      <xsl:value-of select="$lang-doc//language[@id eq $lang-id]/text()" disable-output-escaping="no"/>
      </a>
    </strong>
    <xsl:if test="following-sibling::oe:translation[1]">, </xsl:if>
  </xsl:template>
  
  <xsl:template match="oe:summaries" mode="metadata" as="item()*">
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
  
  <xsl:template match="oe:summary" mode="metadata" as="item()*">
    <xsl:variable name="lang-id" select="dt:language/text()"/>
    <xsl:variable name="lang-label" select="($lang-doc//language[@id eq $lang-id]/text(), $lang-id)[1]"/>
    <xsl:variable name="link" select="concat('/summary/', tokenize(./oe:doi/@rdf:resource, '/')[last()]                )"/>
    <a href="{$link}">
      <xsl:value-of select="$lang-label" disable-output-escaping="no"/>
    </a>
    <xsl:if test="following-sibling::oe:summary[1]">, </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="dt:status" as="item()*">
    <span class="status"><strong>Status:</strong> <span><xsl:value-of select="." disable-output-escaping="no"/></span></span>  
  </xsl:template>
  
  <xsl:template match="oe:coverImage" as="item()*">
    <img src="/thumbnails/150/{.}" class="thumbnail"/>
  </xsl:template>
  
  <xsl:template match="dt:abstract" as="item()*">
    <div class="row">
      <div class="twelve columns">
        <div class="panel abstract">
          <h3><xsl:choose>
            <xsl:when test="@xml:lang = 'en'">Abstract</xsl:when>
            <xsl:when test="@xml:lang = 'fr'">Résumé</xsl:when>
            <xsl:otherwise>Abstract (fallback)</xsl:otherwise>
          </xsl:choose></h3>
          <div>
            <!--<xsl:value-of select="."/>-->
            <xsl:value-of select="xdmp:tidy(.)[2]" disable-output-escaping="no"/>
          </div>
          <br/>
        </div>
      </div>
    </div>    
  </xsl:template>
    
  <xsl:template match="dt:identifier" as="item()*"/>

  <xsl:template match="oe:chapters|oe:graphs|oe:tables" as="item()*">
    <li id="{local-name(.)}Tab">
      <xsl:if test="local-name(.) = 'chapters'">
        <xsl:attribute name="class">active</xsl:attribute>
      </xsl:if>
      <div class="row">
        <div class="twelve columns">            
              <ul class="toc-list">
                <xsl:apply-templates select="child::node()"/>
              </ul>
        </div>
      </div>
    </li>
    <li id="readTab">
      <div class="row">
        <div class="twelve columns flex-video" style="height:400px">
          <div style="clear:both;display:block;" id="flashPlayer">
            <object id="DocumentPlayer" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab" width="100%" height="400px">
              <param name="flashVars" value="SwfFile=http://www.keepeek.com/oecd/oecdswf?m=/domain21/media672/108098-gl6gsnm7l5.swf&amp;Scale=0.6&amp;ZoomTransition=easeOut&amp;ZoomTime=0.5&amp;ZoomInterval=0.1&amp;FitPageOnLoad=true&amp;FitWidthOnLoad=false&amp;PrintEnabled=false&amp;FullScreenAsMaxWindow=false&amp;ProgressiveLoading=true&amp;localeChain=en_US" valuetype="data"/>
              <param name="allowFullScreen" value="true" valuetype="data"/>
              <param name="movie" value="http://www.keepeek.com:80/oecd/flash/paperviewer.swf" valuetype="data"/>
              <param name="quality" value="best" valuetype="data"/>
              <param name="bgcolor" value="#333333" valuetype="data"/>
              <param name="allowScriptAccess" value="always" valuetype="data"/>
              <embed width="100%" height="400px" flashvars="SwfFile=http://www.keepeek.com/oecd/oecdswf?m=/domain21/media672/108098-gl6gsnm7l5.swf&amp;Scale=0.6&amp;ZoomTransition=easeOut&amp;ZoomTime=0.5&amp;ZoomInterval=0.1&amp;FitPageOnLoad=true&amp;FitWidthOnLoad=false&amp;PrintEnabled=false&amp;FullScreenAsMaxWindow=false&amp;ProgressiveLoading=true&amp;localeChain=en_US" allowscriptaccess="sameDomain" allowfullscreen="true" quality="best" bgcolor="#333333" src="http://www.keepeek.com:80/oecd/flash/paperviewer.swf"></embed></object>
          </div>
            <div style="clear:both;display:none;" id="noflashPlayer">
              <img src="http://www.keepeek.com/oecd/images/dummyPlayerPicture.jpg"/>
            </div>
        </div>
      </div>
    </li>
    <li id="citeTab">
      <div class="row">
        <div class="twelve columns">            
          <h4>How to cite this <xsl:value-of select="$pub-type" disable-output-escaping="no"/></h4>
          <p>Here would be the official citation, with links to download ...</p>
        </div>
      </div>
    </li>
  </xsl:template>
  
  <xsl:template match="oe:chapter|oe:graph|oe:table" as="item()*">
    <li>
      <a href="{oe:doi/@rdf:resource}">
        <xsl:value-of select="dt:title" disable-output-escaping="no"/>
        <xsl:if test="oe:subTitle">
          <xsl:text disable-output-escaping="no">: </xsl:text>
          <span class="subtitle">
            <xsl:value-of select="oe:subTitle" disable-output-escaping="no"/>
          </span>
        </xsl:if>
      </a>
    </li>
  </xsl:template>
  
  
  <xsl:template name="tpl.consumer-box" as="item()*">
    <xsl:param name="buy-link" as="xs:string"/>
    <xsl:param name="read-link" as="xs:string"/>
    <br/>
    <div>
      <xsl:choose>
        <xsl:when test="$read-link = ''">
          <a class="nice small radius white button disabled" href="#">Unavailable</a>
        </xsl:when>
        <xsl:otherwise>
          <a class="nice small radius white button" href="{$read-link}">Read this <xsl:value-of select="$pub-type" disable-output-escaping="no"/></a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text disable-output-escaping="no"> </xsl:text>
      <xsl:choose>
        <xsl:when test="$buy-link = ''">
          <a class="nice small radius white button disabled" href="#">Unavailable for purchase</a>          
        </xsl:when>
        <xsl:otherwise>
          <a class="nice small radius white button" href="{$buy-link}">Buy this <xsl:value-of select="$pub-type" disable-output-escaping="no"/></a>
        </xsl:otherwise>
      </xsl:choose>       
    </div>
  </xsl:template>

  <xsl:template name="tpl.toc-header" as="item()*">
    <xsl:if test="//oe:chapters|//oe:tables|//oe:graphs">
      <div class="row">
        <h3>Table of Contents</h3>
        <br/>
        <dl class="nice tabs">
          <xsl:if test="//oe:chapters">
            <dd><a href="#chapters" class="active">Chapters</a></dd>          
          </xsl:if>
          <xsl:if test="//oe:tables">
            <dd><a href="#tables">Tables</a></dd>          
          </xsl:if>
          <xsl:if test="//oe:graphs">
            <dd><a href="#graphs">Graphs</a></dd>          
          </xsl:if>
          <dd><a href="#read">Read</a></dd>
          <dd><a href="#cite">Cite!</a></dd>
        </dl>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
