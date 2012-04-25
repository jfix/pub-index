xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib-view.xqy";
import module namespace b = "lib-browse" at "lib-browse.xqy";
import module namespace s = "lib-search" at "lib-search.xqy";
import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $start as xs:integer := xs:integer((xdmp:get-request-field("start"), 1)[1]);

v:html-search-page(
  $s:page-title,
  (),
  <div class="row">
    <div class="twelve columns">{(
      $s:search-results
    )}</div>
  </div>,
  "","","",1)
    


