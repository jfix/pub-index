xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace ha = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/assets-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $model as node()? external;

declare variable $id as xs:string := ($model//dt:identifier)[1];

let $params := map:map(),
    $void := 
    if($model/oe:status eq "deleted") then (
         map:put($params, "title", "Deleted Content - OECD publications")
        (:,map:put($params, "scripts",( <script src="/assets/js/oecd-display.js"></script> )):)
        ,map:put($params, "content", xdmp:xslt-invoke("/app/views/xslt/deleted.xsl", $model))
    ) else (
         map:put($params, "title", concat(string(($model//dt:title)[1]), " - OECD publications"))
        (:,map:put($params, "scripts", ())  -- no specific js for this page :)
        ,map:put($params, "content", xdmp:xslt-invoke("/app/views/xslt/publication.xsl", $model))
    )

return
  layout:render($params)
