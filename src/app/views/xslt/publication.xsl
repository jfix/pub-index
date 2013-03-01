<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet extension-element-prefixes="xdmp" exclude-result-prefixes="#all" version="2.0"
  default-validation="strip" input-type-annotations="unspecified"
  xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:dt="http://purl.org/dc/terms/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:lang="language-data"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:utils="books.oecd.org/utils">

  <xsl:output method="xhtml"/>

  <xsl:variable name="languages" select="doc('/referential/languages.xml')/oe:languages"/>

  <!-- main template, creates page structure -->
  <xsl:template match="oe:item">
    <xsl:variable name="biblio" select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]"/>
    <div class="row">
      <xsl:variable name="coverImage" select="utils:coverimage(.)"/>
      <xsl:if test="$coverImage">
        <!-- thumbnail-->
        <div class="span3">
          <img src="{concat('http://images.oecdcode.org/covers/150/', $coverImage)}" alt="cover image of the publication" class="img-polaroid cover"/>
        </div>
      </xsl:if>

      <!-- title + metadata -->
      <div id="metadata" class="span9">
        <xsl:apply-templates
          select="(oe:parents/oe:item[@type = 'bookseries']/oe:bibliographic[@xml:lang eq 'en'],oe:parents/oe:item[@type = 'bookseries']/oe:bibliographic)[1]"/>
        <xsl:apply-templates select="$biblio/dt:title"/>
        <xsl:apply-templates select="$biblio/oe:subTitle"/>

        <div class="languages">
          <xsl:value-of
            select="string-join( data($languages//oe:language[@id = current()/dt:language]/oe:label[@xml:lang = 'en']) ,'/')"
          />
        </div>

        <div class="availability">
          <xsl:apply-templates select="dt:available"/>
          <xsl:apply-templates select="oe:upcomingEdition"/>
        </div>

        <xsl:apply-templates select="oe:translations"/>

        <div class="links">
          <xsl:apply-templates select="oe:link[@type = 'freepreview']"/>
          <xsl:apply-templates select="oe:link[@type = 'doi']"/>
          <xsl:apply-templates select="oe:link[@type = 'bookshop']"/>
          <xsl:apply-templates
            select="oe:parents/oe:item[@type = 'periodical']/oe:link[@type = 'bookshop']"/>
        </div>
      </div>

    </div>

    <div class="row">
      <div class="span12">
        <!-- abstract -->
        <xsl:apply-templates select="$biblio/dt:abstract"/>

        <!-- multilingual summaries -->
        <xsl:apply-templates select="oe:summaries"/>
        
        <br/>
        
        <!-- toc -->
        <xsl:apply-templates select="oe:toc"/>

        <!-- TODO: for version:v2.0 - see issue #4919 back links
        <br/>

        <h4>Related links</h4>
        <div id="backlinks"/>
        -->
      </div>
    </div>
  </xsl:template>

  <xsl:template match="oe:parents//oe:bibliographic">
    <h4 class="series">
      <a href="{../oe:link[@type = 'doi']/@rdf:resource}" target="_blank">
        <xsl:value-of select="dt:title"/>
      </a>
    </h4>
  </xsl:template>

  <xsl:template match="dt:title">
    <h3 class="title">
      <a href="{../../oe:link[@type = 'doi']/@rdf:resource}" target="_blank">
        <xsl:value-of select="."/>
      </a>
    </h3>
  </xsl:template>

  <xsl:template match="oe:subTitle">
    <h4 class="subtitle">
      <a href="{../../oe:link[@type = 'doi']/@rdf:resource}" target="_blank">
        <xsl:value-of select="."/>
      </a>
    </h4>
  </xsl:template>

  <xsl:template match="dt:available">
    <span>
      <xsl:choose>
        <xsl:when test="xs:dateTime(.) gt current-dateTime()"><i class="icon-time"/> To be published
          on </xsl:when>
        <xsl:otherwise>Published on </xsl:otherwise>
      </xsl:choose>
      <span class="pubdate" data-date="{.}">
        <xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="oe:upcomingEdition">
    <div>
      <span>Next edition: </span>
      <a href="{oe:link[@type = 'doi']/@rdf:resource}" target="_blank" class="pubdate"
        data-date="{.}">
        <xsl:value-of select="format-dateTime(oe:nextEditionDate, '[D] [MNn] [Y]')"/>
      </a>
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
    <xsl:if test="position() > 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <a href="{utils:link(@rdf:resource)}">
      <xsl:value-of
        select="string-join( data($languages//oe:language[@id = current()/dt:language]/oe:label[@xml:lang = 'en']) ,'/')"
      />
    </a>
  </xsl:template>

  <xsl:template match="oe:link[@type = 'freepreview']">
    <a class="btn" href="{@rdf:resource}" target="_blank">Read</a>
  </xsl:template>

  <xsl:template match="oe:link[@type = 'doi']">
    <a class="btn" href="{@rdf:resource}" target="_blank">iLibrary</a>
  </xsl:template>

  <xsl:template match="oe:item[@type != ('periodical','journal')]/oe:link[@type = 'bookshop']">
    <a class="btn" href="{@rdf:resource}" target="_blank">
      <xsl:choose>
        <xsl:when test="xs:dateTime(../dt:available) gt current-dateTime()">Pre-order this </xsl:when>
        <xsl:otherwise>Buy this </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="../@type"/>
    </a>
  </xsl:template>

  <xsl:template match="oe:item[@type = ('periodical','journal')]/oe:link[@type = 'bookshop']">
    <a class="btn" href="{@rdf:resource}" target="_blank">Subscribe</a>
  </xsl:template>

  <!-- display the abstract -->
  <xsl:template match="dt:abstract">
    <div class="abstract">
      <xsl:copy-of select="child::node()" copy-namespaces="no"/>
    </div>
  </xsl:template>

  <xsl:template match="dt:identifier"/>

  <xsl:template match="oe:summaries">
    <xsl:variable name="nbsummaries" select="count(oe:summary)"/>
    <xsl:if test="$nbsummaries > 0">
      <div class="summaries well well-small">
        <xsl:choose>
          <xsl:when test="$nbsummaries = 1">
            <xsl:variable name="summary" select="oe:summary"/> This publication has been summarised
            in <a href="{$summary/oe:link[@type = 'doi']/@rdf:resource}">
              <xsl:value-of
                select="string-join( data($languages//oe:language[@id = $summary/dt:language]/oe:label[@xml:lang = 'en']) ,'/')"
              />
            </a>. </xsl:when>
          <xsl:when test="$nbsummaries gt 1"> This publication has been summarised in
                <span><xsl:value-of select="$nbsummaries"/></span> languages: <select id="summaries"
              class="input-medium">
              <option value="">Please select one</option>
              <xsl:apply-templates select="oe:summary">
                <xsl:sort
                  select="data($languages//oe:language[@id = current()/dt:language]/oe:label[@xml:lang = 'en'])"
                  data-type="string"/>
              </xsl:apply-templates>
            </select>
          </xsl:when>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="oe:summary">
    <option value="{oe:link[@type = 'doi']/@rdf:resource}">
      <xsl:value-of
        select="data($languages//oe:language[@id = current()/dt:language]/oe:label[@xml:lang = 'en'])"
      />
    </option>
  </xsl:template>

  <xsl:template match="oe:toc">
    <xsl:if test="oe:item">
      <div class="row">
        <div id="toc-actions" class="btn-group pull-right">
          <xsl:if test="oe:item//dt:abstract">
            <a class="btn btn-small" data-toggle=".toc-abstract">Abstracts</a>
          </xsl:if>
          <xsl:if test="oe:item/oe:item">
            <a class="btn btn-small" data-toggle=".toc-sublist">Tables &amp; Graphs</a>
          </xsl:if>
          <a id="toc-expander" class="btn btn-small">
            <i class="icon-chevron-down"/>
            <span class="button-label">Expand table of contents</span>
          </a>
        </div>
      </div>
      <div class="row">
        <div id="toc-box" class="row toc-box-condensed">
        <ul id="toc-root" class="toc" >
          <xsl:apply-templates select="oe:item"/>
        </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="oe:toc//oe:item">
    <xsl:variable name="biblio" select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]"/>
    <li class="toc-row">
      <!-- only provide title attribute for tooltip if there is an abstract - toh! -->
      <!--<xsl:if test="$biblio/dt:abstract">
        <xsl:attribute name="title">Click to view abstract</xsl:attribute>
      </xsl:if>-->
      <div class="toc-row-header">
        <!-- only change cursor to pointer if there is an abstract - re-toh! -->
        <xsl:if test="$biblio/dt:abstract">
          <!-- need to repeat class because xsl:attribute will not append, but replace  -->
          <xsl:attribute name="class">toc-row-header toc-row-clickable</xsl:attribute>
        </xsl:if>
        <div class="links pull-right">
          <xsl:call-template name="toc-link">
            <xsl:with-param name="link" select="oe:link[@type = 'freepreview']"/>
          </xsl:call-template>
          <xsl:call-template name="toc-link">
            <xsl:with-param name="link" select="oe:link[@type = 'bookshop']"/>
          </xsl:call-template>
          <xsl:call-template name="toc-link">
            <xsl:with-param name="link" select="oe:link[@type = 'doi']"/>
          </xsl:call-template>
        </div>
        <xsl:choose>
          <xsl:when test="@type eq 'chapter'"><!-- no icon for chapters --></xsl:when>
          <xsl:when test="@type eq 'table'">
            <span class="toc-icon">
              <i class="icon-th-list"/>
            </span>
          </xsl:when>
          <xsl:when test="@type eq 'graph'">
            <span class="toc-icon">
              <i class="icon-signal"/>
            </span>
          </xsl:when>
          <xsl:when test="@type eq 'workingpaper'">
            <xsl:variable name="labelOrderNumber">
              <xsl:choose>
                <xsl:when test="oe:orderNumber">
                  <xsl:value-of select="concat('#',oe:orderNumber)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(year-from-dateTime(xs:dateTime(dt:available)),'-',oe:yearNumber)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <span class="toc-ordernumber">
              <xsl:value-of select="$labelOrderNumber"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="dt:available">
              <span class="toc-pubdate" data-date="{dt:available}"><xsl:value-of select="format-dateTime(dt:available, '[D] [MNn,*-3] [Y]')"></xsl:value-of></span>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <span class="toc-title">
          <xsl:value-of select="$biblio/dt:title"/>
        </span>
      </div>
      <div class="toc-details">
        <xsl:apply-templates select="$biblio/dt:abstract"/>

        <xsl:if test="oe:item">
          <ul class="toc toc-sublist">
            <xsl:apply-templates select="oe:item"/>
          </ul>
        </xsl:if>
      </div>
    </li>
  </xsl:template>

  <xsl:template name="toc-link">
    <xsl:param name="link"/>
    <xsl:if test="$link">
      <xsl:variable name="icon">
        <xsl:choose>
          <xsl:when test="$link/@type eq 'freepreview'">icon-eye-open</xsl:when>
          <xsl:when test="$link/@type eq 'bookshop'">icon-shopping-cart</xsl:when>
          <xsl:when test="$link/@type eq 'doi'">icon-download-alt</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="title">
        <xsl:choose>
          <xsl:when test="$link/@type eq 'freepreview'">Read online</xsl:when>
          <xsl:when test="$link/@type eq 'bookshop'">Buy</xsl:when>
          <!-- download of working papers from ilibrary is free -->
          <xsl:when test="$link/@type eq 'doi' and $link/parent::oe:item/@type eq 'workingpaper'">Download</xsl:when>
          <!-- other objects need ilibrary subscription -->
          <xsl:when test="$link/@type eq 'doi'">Download (OECD iLibrary subscribers)</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <a href="{$link/@rdf:resource}" target="_blank" class="btn btn-mini" title="{$title}"><i class="{$icon}" ></i>&#160;<span><xsl:value-of select="$title"/></span></a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="oe:toc//dt:abstract">
    <p class="toc-abstract">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <!-- returns a local link for a given DOI -->
  <xsl:function name="utils:link">
    <xsl:param name="id"/>
    <xsl:value-of select="concat('/display/', $id)"/>
  </xsl:function>
  
  <xsl:function name="utils:coverimage">
    <xsl:param name="item"/>
    <xsl:choose>
      <xsl:when test="($item//oe:coverImage)[1]">
        <xsl:value-of select="($item//oe:coverImage)[1]"/>
      </xsl:when>
      <xsl:when test="$item/dt:available and xs:dateTime($item/dt:available) gt current-dateTime()">
        <xsl:text>cover_not_yetm.jpg</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="language" select="$item/dt:language"/>
        <xsl:value-of select="if (count($language) > 1 or $language = 'en') then 'publications_oecdm.jpg' else 'publications_ocdem.jpg' "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
