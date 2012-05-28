xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib/view.xqy";
import module namespace b = "lib-browse" at "lib/browse.xqy";
import module namespace s = "lib-search" at "lib/search.xqy";
import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $facet as xs:string := (xdmp:get-request-field("by"), '')[1];
declare variable $value as xs:string := (xdmp:url-decode(xdmp:get-request-field("value")), '')[1];

let $quoted-value as xs:string := if (contains($value, ' ')) then concat('"', $value, '"') else $value
let $qtext as xs:string := concat($facet, ":", $quoted-value)

return
v:html-search-page(
  "Browsing OECD publications",
  $s:search-script,
  <div class="row">
    <div class="twelve columns">{
      s:search-results-for($qtext)
    }</div>
  </div>,
  "","","",1)
