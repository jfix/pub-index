xquery version "1.0-ml";

(: $Id$ :)

(:~
 : This module defines functions that can be called to create widgets, such as:
 : * google map (TODO)
 : * slider thingy (TODO)
 : * ...
 :)
module namespace w = "lib-widgets";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace cc = "country-data";

declare default collation "http://marklogic.com/collation/";

declare function w:map-data()
{
  let $doc := document("/refs/countries.xml")
  let $countries := cts:element-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/", "country"),"", ("item-frequency"), 
    cts:collection-query(("metadata")))
  
  let $list := (
    for $country in $countries
    
    let $coords := xs:double($doc//cc:country[cc:code = upper-case($country)]/cc:coords/cc:centred/cc:*)    
    let $freq := cts:frequency($country)
    let $map := map:map()
    let $put := map:put($map, 'center', $coords)
    let $put := map:put($map, 'radius', $freq * 1000)
    let $put := map:put($map, "fillColor", "#018FD1")
    let $put := map:put($map, "strokeColor", "#018FD1")
    let $put := map:put($map, "strokeWeight", "1")
    let $put := map:put($map, "action", "addCircle")
    (:order by $freq descending:)
    return $map
  )
  let $json := xdmp:to-json($list)
  let $length := string-length($json)
  return substring( substring($json, 2), 1, ($length - 2))
};

declare function w:map-scripts()
as element(script)*
{
  (
  )
};