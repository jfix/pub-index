xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace hs = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/search-helper.xqy";
import module namespace hf = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/facets-helper.xqy";
import module namespace ha = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/assets-helper.xqy";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace search = "http://marklogic.com/appservices/search";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $model as node()? external;
declare variable $url external;

let $params := map:map()
let $_put := map:put($params, xdmp:key-from-QName(fn:QName("", "url")), $url)
let $simple-xml := xdmp:xslt-invoke(
    "/app/views/xslt/search2json.xsl"
    , $model
    , $params)


let $custom := 
    let $config := json:config("custom")
    return 
       (map:put($config, 
            "array-element-names", 
            ("root", (:"results",:) "result", "country", (:"topics",:) "topic"))
            
        (:,
        map:put($config, "element-namespace", "http://marklogic.com/appservices/search"),
        map:put($config, "element-prefix", "search"),
        map:put($config, "attribute-names",("warning","name")),
        map:put($config, "full-element-names",
                 ("query","and-query","near-query","or-query")),
        map:put($config, "json-children","queries"):)
        
        ,$config) 

let $check := json:check-config($custom)

return (  
    (:$simple-xml, :)
    xdmp:log(concat("********** JSON CONFIG CHECK: ", $check))
    ,
    json:transform-to-json($simple-xml, $custom) 
)