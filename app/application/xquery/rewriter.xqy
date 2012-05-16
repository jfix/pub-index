xquery version "1.0-ml";

(: $Id$ :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";
(:
  /[type]/[doi] => /application.xqy?id=[type]/[doi]
:)


declare function local:construct-new($url as xs:string,$pattern as xs:string,$view as xs:string)
as xs:string
{
    let $args := substring-after($url,$pattern)
    return concat("/main.xqy?uri=",replace($args, "\?", "&amp;"),"&amp;view=",$view)
};

let $url := xdmp:get-request-url()

let $home-pattern as xs:string := "^/?$"
let $browse-pattern as xs:string := "^/browse/([a-z]+)/([-a-zA-Z\s,+]+)$"
let $display-pattern as xs:string := "^/display/([-a-z0-9_]+)$"
let $xmldocument-pattern as xs:string := "^/display/([-a-z0-9_]+)\.xml$"
let $search-pattern as xs:string := "^/search/([^/]+)(/([0-9]+))?$"
let $opensearch-pattern as xs:string := "^/opensearch\?q=([a-zA-Z0-9 ]+)(&amp;start=([0-9]+))?"

let $new-url :=
  (: home page :)
  if (fn:matches($url, $home-pattern))
  then
    "/application/xquery/home.xqy"
  
  (: redirect to browse page :)
  else if (fn:matches($url, $browse-pattern))
  then
    fn:replace($url,
     $browse-pattern,
       "/application/xquery/search.xqy?term=$1:&quot;$2&quot;")
  
  (: return XML document :)
  else if (fn:matches($url, $xmldocument-pattern))
  then
    fn:replace($url,
     $xmldocument-pattern,
       "/application/xquery/xmldocument.xqy?id=$1")
  
  (: display a product :)
  else if (fn:matches($url, $display-pattern))
  then
    fn:replace($url,
      $display-pattern,
       "/application/xquery/display.xqy?id=$1")
  
  (: search results :)
  else if(fn:matches($url, $search-pattern))
  then
    fn:replace($url,
      $search-pattern,
       "/application/xquery/search.xqy?term=$1&amp;start=$3") 
  
  (: opensearch results :)
  else if (fn:matches($url, $opensearch-pattern))
  then
    fn:replace($url,
      $opensearch-pattern,
      "/application/xquery/opensearch.xqy?term=$1&amp;start=$3")
  
  (: by default try to resolve url passed in :)
  else $url
  
let $_log := xdmp:log(concat("REWRITER: ", $new-url))

return $new-url
