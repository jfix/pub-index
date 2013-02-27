xquery version "1.0-ml";

import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";
import module namespace mf = "http://oecd.org/pi/models/facets" at "/app/models/facets.xqy";

let $model := <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
  { 
  (: How many: book, article, wp :)
  ms:get-latest(6,2,2) }
</latests>

return
  (xdmp:set-response-content-type("text/html")
   ,xdmp:invoke(
      "/app/views/home.html.xqy"
      ,(
        xs:QName("ajax"),fn:false()
        ,xs:QName("model"),$model
        ,xs:QName("facets"),mf:facets("")
      )
    )
  )