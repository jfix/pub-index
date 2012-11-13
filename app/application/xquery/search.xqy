xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib/view.xqy";
import module namespace s = "lib-search" at "lib/search.xqy";
import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

v:html-search-page(
  $s:page-title,
  $s:search-script,
  <div class="row">
    <div class="span12">{(
      $s:search-results
    )}</div>
  </div>,
  "","","",1)
