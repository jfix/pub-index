xquery version "1.0-ml";

import module namespace mi = "http://oecd.org/pi/models/item" at "/app/models/item.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");

let $model := mi:get-item($id),
    $model := <item xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
      {$model/@*}
      {$model/*}
      {mi:get-item-toc($id,true(),true())}
    </item>
return
  (xdmp:set-response-content-type("text/html")
   ,xdmp:invoke(
      "/app/views/display.html.xqy"
      ,(
        xs:QName("ajax"),fn:false()
        ,xs:QName("model"),$model
      )
    )
  )