xquery version "1.0-ml";

import module namespace mu = "http://oecd.org/pi/models/utils" at "/app/models/utils.xqy";

declare function local:construct-new($url as xs:string,$pattern as xs:string,$view as xs:string)
as xs:string
{
    let $args := substring-after($url,$pattern)
    return concat("/main.xqy?uri=",replace($args, "\?", "&amp;"),"&amp;view=",$view)
};

let $url := xdmp:get-request-url()

let $home-pattern as xs:string := "^/?$"
let $country-pattern as xs:string := "^/country/([a-z]{2})$"
let $topic-pattern as xs:string := "^/topic/([a-zA-Z+,]+)$"
let $language-pattern as xs:string := "^/language/([a-z]{2})$"
let $pubtype-pattern as xs:string := "^/pubtype/([a-zA-Z+,]+)$"
let $display-pattern as xs:string := "^/display/([-a-z0-9_]+)(.xml|.json)?$"
let $search-pattern as xs:string := "^/search[/]?\?(.*)$"

let $new-url :=
  (: home page :)
  if (fn:matches($url, $home-pattern))
  then  "/app/actions/home.xqy"

(: redirect to country browse page :)
  else if (fn:matches($url, $country-pattern))
  then  fn:replace($url,     $country-pattern,      "/app/actions/search.xqy?in=country:$1&amp;order=date")
  
(: redirect to language browse page :)
  else if (fn:matches($url, $language-pattern))
  then  fn:replace($url,     $language-pattern,      "/app/actions/search.xqy?in=language:$1&amp;order=date")
  
(: redirect to topic browse page :)
  else if (fn:matches($url, $topic-pattern))
  then  fn:replace($url,     $topic-pattern,      "/app/actions/search.xqy?in=topic:$1&amp;order=date")
  
  (: redirect to pubtype browse page :)
  else if (fn:matches($url, $pubtype-pattern))
  then  fn:replace($url,     $pubtype-pattern,      "/app/actions/search.xqy?in=pubtype:$1&amp;order=date")
  
  (: display an item :)
  else if (fn:matches($url, $display-pattern))
  then  fn:replace($url,     $display-pattern,      "/app/actions/display.xqy?id=$1&amp;format=$2")
  
  (: search results :)
  else if(fn:matches($url, $search-pattern))
  then  fn:replace($url,     $search-pattern,       "/app/actions/search.xqy?$1") 
  
  else if (fn:matches($url, "^/opensearch.xml$"))
  then  fn:replace($url, "^/opensearch.xml$",   "/app/actions/osd.xqy")
  
  else if (fn:matches($url, "^/items-by-country$"))
  then "/app/actions/items-by-country.xqy"
  
  else if (fn:matches($url, "^/suggest(\?.*)?$"))
  then fn:replace($url, "^/suggest(\?.*)?$", "/app/actions/suggest.xqy$1")
  
  else if (fn:matches($url, "^/admin(\?.*)?$"))
  then fn:replace($url, "^/admin(\?.*)?$", "/app/actions/admin.xqy$1")
  
  else if (fn:matches($url, "^/api/changed(\?.*)?$"))
  then fn:replace($url, "^/api/changed(\?.*)?$", "/app/api/changed.xqy$1")
  
  else if (fn:matches($url, "^/api/changed/lastday$"))
  then "/app/api/changed.xqy?since=P1D"
  
  else if (fn:matches($url, "^/assets/.*$"))
  then $url
  
  else if (fn:matches($url, "^/xray/?(\?.*)?$"))
  then $url
  
  (: all routes have to be declared :)
  else
    (: redirect to error page with code 404 :)
    (xdmp:set-response-code(404, "Page not found"), "/error.xqy")
  
let $_log := mu:log(concat("REWRITER: ", $new-url))

return $new-url
