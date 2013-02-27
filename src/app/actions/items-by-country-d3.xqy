xquery version "1.0-ml";

import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";

declare namespace oe= "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

(: countries locations are only needed for the d3 map, 
   so they are now in a JSON file together with their name etc.
   
   the only output required for the map for us, from MarkLogic are:
   * country code (needed to make the link with the country lookup table
   * country name (to display, although ... it's also in the country lookup table
   * the count of publications <=== really important
:)

let $model := ms:count-items-by-country()

let $list :=
  for $o in $model
    (: I have the impression it would be better to return the items by biggest count first :)
    order by fn:number($o/@frequency) descending
    return
        let $data := map:map()
           ,$void := map:put($data, 'code', data($o/@ref))
           ,$void := map:put($data, 'count', number($o/@frequency))
        return $data

return (
  xdmp:set-response-content-type("application/json")
  ,xdmp:to-json($list)
)
