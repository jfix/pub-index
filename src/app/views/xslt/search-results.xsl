<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" default-validation="strip"
  input-type-annotations="unspecified" xmlns:functx="http://www.functx.com"
  xmlns:xdmp="http://marklogic.com/xdmp" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:search="http://marklogic.com/appservices/search" xmlns:dt="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output omit-xml-declaration="yes" method="xhtml"/>
  <xsl:variable name="topics" select="doc('/referential/topics.xml')/oe:topics"/>
  <xsl:variable name="countries" select="doc('/referential/countries.xml')/oe:countries"/>
  <xsl:variable name="languages" select="doc('/referential/languages.xml')/oe:languages"/>

  <xsl:template match="search:response" as="item()*">
    <div class="search-results">
      <xsl:apply-templates select="search:result"/>
    </div>
  </xsl:template>

  <xsl:template match="search:result" as="item()*">
    <xsl:apply-templates select="oe:item"/>
  </xsl:template>

  <xsl:template match="oe:item">
    <xsl:variable name="url" select="oe:get-display-url(.)"/>

    <xsl:variable name="type" select="@type"/>
    <xsl:variable name="title" select="(dt:title[xml:lang eq 'en'],dt:title)[1]/text()"/>
    <xsl:variable name="subtitle" select="(oe:subTitle[xml:lang eq 'en'],oe:subTitle)[1]/text()"/>
    <xsl:variable name="cover-url" select="concat('http://images.oecdcode.org/covers/100/', oe:coverimage(.))"/>

    <div class="search-result-item" data-url="{$url}">
      <div class="row">
        <div class="span2">
          <h4 style="text-align:right;">
            <span class="pubtype-label label {$type}" data-facet="pubtype" data-value="{$type}">
              <xsl:choose>
                <xsl:when test="$type eq 'book'">Book</xsl:when>
                <xsl:when test="$type eq 'edition'">Periodical book</xsl:when>
                <xsl:when test="$type eq 'article'">Article</xsl:when>
                <xsl:when test="$type eq 'workingpaper'">Working Paper</xsl:when>
                <xsl:when test="$type eq 'workingpaperseries'">Working Paper series</xsl:when>
                <xsl:when test="$type eq 'journal'">Journal</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$type"/>
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </h4>
          <p style="font-size: 0.9em; text-align:right">
            <xsl:apply-templates select="(.//dt:available)[1]"/>
          </p>
          <p style="font-size: 0.9em; text-align:right">
            <xsl:apply-templates select="dt:language"/>
          </p>
        </div>
        <div class="span7">
          <xsl:if test="$cover-url">
            <a href="{$url}">
              <img src="{$cover-url}" alt="Cover image" class="search-result-thumbnail"/>
            </a>
          </xsl:if>
          <div class="metadata">
            <xsl:apply-templates select="(oe:bibliographic[@xml:lang eq 'en'],oe:bibliographic)[1]"/>
          </div>
        </div>
      </div>
      <xsl:if test="dt:subject or oe:country">
      <div class="row">
        <div class="span7 offset2">
          <div class="related-stuff">
            <xsl:variable name="related-topic-phrase">
              <xsl:choose>
                <xsl:when test="count(dt:subject)>1">Related topics</xsl:when>
                <xsl:otherwise>Related topic</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <span>
              <xsl:value-of select="$related-topic-phrase"/>: 
              <xsl:apply-templates select="dt:subject"/>
            </span>
            <xsl:if test="oe:country">
              <xsl:variable name="related-country-phrase">
                <xsl:choose>
                  <xsl:when test="count(oe:country)>1">Related countries:</xsl:when>
                  <xsl:otherwise>Related country</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              &#160; 
              <span>
                <xsl:value-of select="$related-country-phrase"/>:
                <xsl:apply-templates select="oe:country"/>
              </span>
            </xsl:if>
          </div>
        </div>
      </div>
      </xsl:if>
    </div>
    <hr/>
  </xsl:template>

  <xsl:template match="oe:bibliographic">
    <xsl:variable name="url" select="oe:get-display-url(..)"/>
    <h4>
      <a href="{$url}">
        <xsl:value-of select="dt:title"/>
      </a>
    </h4>
    <xsl:if test="oe:subTitle">
      <h5>
        <a href="{$url}">
          <xsl:value-of select="oe:subTitle"/>
        </a>
      </h5>
    </xsl:if>
    <xsl:if test="dt:abstract">
      <xsl:variable name="abstract" select="data(dt:abstract)" as="xs:string?"/>
      <div class="abstract">
        <xsl:value-of select="$abstract"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dt:available">
    <span class="availability">
      <xsl:if test="xs:dateTime(.) gt current-dateTime()">
        <i class="icon-time"/>
      </xsl:if>
      <span class="date" data-date="{.}">
        <xsl:value-of select="format-dateTime(., '[D] [MNn] [Y]')"/>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="dt:language">
    <xsl:if test="position() > 1">
      <xsl:text>/</xsl:text>
    </xsl:if>
    <span data-facet="language" data-value="{.}" class="facet-value">
      <xsl:value-of
        select="data($languages/oe:language[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>

  <xsl:template match="dt:subject" as="item()*">
    <xsl:if test="position() > 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span data-facet="topic" data-value="{.}" class="facet-value">
      <xsl:value-of
        select="data($topics/oe:topic[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>

  <xsl:template match="oe:country" as="item()*">
    <xsl:if test="position() > 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span data-facet="country" data-value="{.}" class="facet-value">
      <xsl:value-of
        select="data($countries/oe:country[@id = data(current())]/oe:label[@xml:lang = 'en'])"/>
    </span>
  </xsl:template>

  <xsl:template match="node()" as="item()*"/>

  <xsl:function name="oe:get-display-url" as="xs:string?">
    <xsl:param name="item" as="node()"/>
    <xsl:choose>
      <xsl:when test="$item/@type = ('article','workingpaper')">
        <xsl:value-of select="$item/oe:link[@type eq 'doi']/@rdf:resource"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('/display/', $item/dt:identifier)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="oe:coverimage">
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
