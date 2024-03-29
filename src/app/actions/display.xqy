xquery version "1.0-ml";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace mi = "http://oecd.org/pi/models/item" at "/app/models/item.xqy";
import module namespace mu = "http://oecd.org/pi/models/utils" at "/app/models/utils.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");
declare variable $format as xs:string := mu:get-output-format();

declare variable $supported as xs:string* := ('book','edition','journal','workingpaperseries');

let $model as element(oe:item)? := mi:get-item($id)
let $format := if($model/@type = $supported) then $format else 'xml'

let $model := mi:enhance-item($model)

return
  if(not($model)) then
    (xdmp:set-response-code(404,"Not Found"),xdmp:set-response-content-type("text/plain"),'Not Found')
  else if($format eq 'html') then
    (xdmp:set-response-content-type("text/html")
     ,xdmp:invoke(
        "/app/views/display.html.xqy"
        ,(
          xs:QName("ajax"),fn:false()
          ,xs:QName("model"),$model
        )
      )
    )
  
  else if ($format eq 'xml') then
    (xdmp:set-response-content-type("text/xml")
      ,'<?xml version="1.0" encoding="UTF-8"?>'
     ,$model
    )
  
  else if ($format eq 'json') then
    (xdmp:set-response-content-type("application/json")
     ,json:transform-to-json($model, json:config('full'))
    )
  
  else
    error((),"Unsupported format")

