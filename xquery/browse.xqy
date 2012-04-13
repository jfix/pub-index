xquery version "1.0-ml";

import module namespace v = "lib-view" at "lib-view.xqy";
import module namespace b = "lib-browse" at "lib-browse.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $facet as xs:string := (xdmp:get-request-field("facet"), '')[1];

v:html-browse-page(
  "Browse OECD publications", 
  (),
  
  b:browse-content(), 
  
  "",
  "",
  "",
  1
)