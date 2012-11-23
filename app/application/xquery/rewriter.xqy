xquery version "1.0-ml";

(: $Id$ :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";
(:
  /[type]/[doi] => /application.xqy?id=[type]/[doi]
:)

import module namespace utils = "lib-utils"
    at "lib/utils.xqy";

declare function local:construct-new($url as xs:string,$pattern as xs:string,$view as xs:string)
as xs:string
{
    let $args := substring-after($url,$pattern)
    return concat("/main.xqy?uri=",replace($args, "\?", "&amp;"),"&amp;view=",$view)
};

let $url := xdmp:get-request-url()

let $home-pattern as xs:string := "^/?$"
let $about-pattern as xs:string := "^/about$"
let $country-pattern as xs:string := "^/country/([a-z]{2})$"
let $subject-pattern as xs:string := "^/subject/([a-zA-Z+,]+)$"
let $display-pattern as xs:string := "^/display/([-a-z0-9_]+)$"
let $xmldocument-pattern as xs:string := "^/display/([-a-z0-9_]+)\.xml$"
let $search-pattern as xs:string := "^/search[/]?\?(.*)$"
let $opensearch-pattern as xs:string := "^/opensearch[/]?\?(.*)?"

let $new-url :=
  (: home page :)
  if (fn:matches($url, $home-pattern))
  then  "/application/xquery/home.xqy"
  
  (: redirect to about page :)
  else if (fn:matches($url, $about-pattern))
  then  fn:replace($url,     $about-pattern,        "/application/xquery/about.xqy")
  
(: redirect to country browse page :)
  else if (fn:matches($url, $country-pattern))
  then  fn:replace($url,     $country-pattern,      "/application/xquery/search.xqy?in=country:$1")
  
(: redirect to subject browse page :)
  else if (fn:matches($url, $subject-pattern))
  then  fn:replace($url,     $subject-pattern,      "/application/xquery/search.xqy?in=subject:$1")
  
  (: return XML document :)
  else if (fn:matches($url, $xmldocument-pattern))
  then  fn:replace($url,     $xmldocument-pattern,  "/application/xquery/xmldocument.xqy?id=$1")
  
  (: display a product :)
  else if (fn:matches($url, $display-pattern))
  then  fn:replace($url,     $display-pattern,      "/application/xquery/display.xqy?id=$1")
  
  (: search results :)
  else if(fn:matches($url, $search-pattern))
  then  fn:replace($url,     $search-pattern,       "/application/xquery/search.xqy?$1") 
  
  (: opensearch results :)
  else if (fn:matches($url, $opensearch-pattern))
  then  fn:replace($url,     $opensearch-pattern,   "/application/xquery/opensearch.xqy?$1")
  
  else if (fn:matches($url, "^/opensearch.xml$"))
  then  fn:replace($url, "^/opensearch.xml$",   "/application/xquery/opensearchdescriptor.xqy")
  
  (: by default try to resolve url passed in :)
  else $url
  
let $_log := utils:log(concat("REWRITER: ", $new-url))

return $new-url
