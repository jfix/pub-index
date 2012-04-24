xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";

(:
  $Id$
  
  this is just an example of how one can tidy up an XML fragment
  
  needs more tweaking for use in production.
  
:)


xdmp:tidy(
  xdmp:quote(
    document("/content/book/9783905822007-de.xml")//*:abstract/text()),
  
  <options xmlns="xdmp:tidy">
    <add-xml-decl>no</add-xml-decl>
    <break-before-br>yes</break-before-br>
    <enclose-block-text>yes</enclose-block-text>
  </options>)[2]
  
  //html:body/*
