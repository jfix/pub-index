xquery version "1.0-ml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");

let $model := collection("metadata")//dt:identifier[. = $id]/root()

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