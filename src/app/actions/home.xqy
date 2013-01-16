xquery version "1.0-ml";

import module namespace s = "lib-search" at "/app/models/search.xqy";
import module namespace f = "lib-facets" at "/app/models/facets.xqy";

let $model := <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
  {s:get-latest-items(8,2,2)}
</latests>

return
  (xdmp:set-response-content-type("text/html")
   ,xdmp:invoke(
      "/app/views/home.html.xqy"
      ,(
        xs:QName("ajax"),fn:false()
        ,xs:QName("model"),$model
        ,xs:QName("facets"),f:facets("")
      )
    )
  )