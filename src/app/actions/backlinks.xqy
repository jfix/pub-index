xquery version "1.0-ml";

import module namespace b = "lib-backlinks" at "/app/models/backlinks.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");

let $model :=  b:get-item-backlinks(collection("metadata")[.//dt:identifier = $id]/*)

return
  (xdmp:set-response-content-type("text/html")
   ,xdmp:xslt-invoke("/app/xslt/backlinks.xsl", $model)
  )