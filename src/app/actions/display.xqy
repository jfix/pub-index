xquery version "1.0-ml";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace mi = "http://oecd.org/pi/models/item" at "/app/models/item.xqy";
import module namespace mu = "http://oecd.org/pi/models/utils" at "/app/models/utils.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");
declare variable $format as xs:string := mu:get-output-format();

declare variable $supported as xs:string* := ('book','edition','journal','workingpaperseries');

let $model := mi:get-item($id)
let $format := if($model/@type = $supported) then $format else 'xml'

let $model :=
    if($format eq 'html') then
      <item xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
        {$model/@*}
        {$model/*}
        {mi:get-item-translations($model)}
        {
          if($model/@type = ('book','edition')) then (
            mi:get-item-parent($model)
            ,mi:get-item-toc($id,true(),true())
          )
          else (
            mi:get-serial-toc($id,true())
          )
        }
      </item>
    else
      $model

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
     ,$model
    )
  
  else if ($format eq 'json') then
    (xdmp:set-response-content-type("application/json")
     ,json:transform-to-json($model, json:config('full'))
    )
  
  else
    error((),"Unsupported format")

