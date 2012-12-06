xquery version "1.0-ml";

(:~
 : 
 : Script returns json used by map widget on home page
 :
 :
 :)
import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";

declare namespace cc = "country-data";
declare namespace dt = "http://purl.org/dc/terms/";
 
 let $doc := document("/refs/countries.xml")
  let $countries := cts:element-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/", "country"),"", ("item-frequency"), 
    cts:collection-query(("metadata")))
  
  let $list := (
    for $country in $countries
      let $name :=   data($doc//cc:country[cc:code = upper-case($country)]/cc:name/cc:en[@case="normal"])
      let $map :=
        if($name) then
          let $coords := $doc//cc:country[cc:code = upper-case($country)]/cc:coords/cc:centred/cc:*
          let $freq := cts:frequency($country)
          let $map := map:map()
          let $void := map:put($map, 'latlng', string-join($coords, ','))
          let $void := map:put($map, 'publications', $freq)
          let $void := map:put($map, 'label', $name)
          let $void := map:put($map, 'id', $country)
          let $void := map:put($map, 'url', concat('/country/', $country))
          return $map
        else
          ()
    return $map
  )
  let $json := xdmp:to-json($list)
  let $length := string-length($json)
  return (
    xdmp:set-response-content-type("application/json"),
    concat('{ "items": ', $json, '}')
  )
 