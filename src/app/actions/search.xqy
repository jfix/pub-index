xquery version "1.0-ml";

import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";
import module namespace mf = "http://oecd.org/pi/models/facets" at "/app/models/facets.xqy";

declare namespace search = "http://marklogic.com/appservices/search";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];
declare variable $format := xdmp:get-request-field("format");
declare variable $url := fn:concat(
    xdmp:get-request-protocol()
    , '://'
    , xdmp:host-name()
    , ':'
    , xdmp:get-request-port()
    , xdmp:get-original-url());

let $model := ms:search($ms:qtext, $ms:start)

return
  if($format eq "rss") then
    (xdmp:set-response-content-type("text/xml")
    ,xdmp:invoke(
         "/app/views/search.rss.xqy"
        ,(xs:QName("model"), $model)
    ))
    
  else if($format eq "json") then
    (xdmp:set-response-content-type("application/json")
    ,xdmp:invoke(
        "/app/views/search.json.xqy"
        ,(xs:QName("model"), $model
         ,xs:QName("url"), $url)
    ))
  else if ($format eq "xml") then
    (xdmp:set-response-content-type("text/xml")
    ,$model)
    
  else
    (xdmp:set-response-content-type("text/html")
     ,xdmp:invoke(
        "/app/views/search.html.xqy"
        ,(
          xs:QName("ajax"),fn:false()
          ,xs:QName("model"),$model
          ,xs:QName("facets"),mf:facets($ms:qtext)
        )
      )
    )