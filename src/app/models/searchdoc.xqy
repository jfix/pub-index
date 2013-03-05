xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/searchdoc";

(: Module powered by Alarache Unlimited ™ :)

import module namespace mi = "http://oecd.org/pi/models/item" at "/app/models/item.xqy";
import module namespace ut = "http://oecd.org/pi/models/utils" at "/app/models/utils.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace prop = "http://marklogic.com/xdmp/property";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $searchable-query := cts:and-query((
  cts:collection-query(("book","edition","article","workingpaper","journal","workingpaperseries"))
  ,cts:not-query(cts:collection-query("deleted"))
));

(: determine the reference date from wich the modified documents will be gathered :)
declare variable $since as xs:dateTime :=
  let $tmp as xs:dateTime? := cts:max(cts:element-reference(xs:QName("prop:last-modified")),("properties"),cts:collection-query("searchable"))
  return
    if($tmp instance of xs:dateTime) then
      $tmp
    else
      cts:min(cts:element-reference(xs:QName("prop:last-modified")),("properties"),cts:collection-query("metadata"))
;

(:
  Build search documents used by the search api.
:)
declare function module:build-search-documents()
{
  (: get all identifiers for searchable candidate :)
  let $ids :=
    cts:element-values(fn:QName("http://purl.org/dc/terms/","identifier"), (), (),
      $searchable-query
    )
  let $map := map:map()
  
  return (
    module:check-updated-item($map)
    ,module:check-updated-children($map, $ids)
    ,module:check-updated-relations($map, $ids)
    ,module:build-search-document(map:keys($map))
    
    ,module:cleanup-deprecated-search-documents()
  )
};

(:
  Build a search document for the provided identifier which will be used by the search api.
:)
declare private function module:build-search-document($id as xs:string) {
  let $item := mi:enhance-item(mi:get-item($id))
  let $checksum := xdmp:hmac-md5('osef', xdmp:quote($item))
  
  let $uri := concat("/searchdoc/", $id, ".xml")
  
  (: FIXME: use checksum :)
  
  let $void := xdmp:document-insert($uri, $item, (), ("searchable"))
  let $void := xdmp:document-set-property($uri, <prop:checksum>{$checksum}</prop:checksum>)
return ()
};

(:
  List all items related to the provided identifier (aka children).
:)
declare private function module:get-children-uri($id as xs:string) {
  cts:uris((),(),
    cts:and-query((
      cts:element-attribute-range-query(
        fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
        ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
        ,"="
        ,$id
      )
    ))
  )
};

(:
  Check if the provided identifier has updated items related to itself (aka children).
  It set this identifier to fn:true in the map if updated.
:)
declare private function module:check-updated-children($map as map:map, $id as xs:string) {
  if(
    cts:uris((),(),
      cts:and-query((
        cts:document-query(module:get-children-uri($id))
        ,cts:properties-query(
          cts:element-range-query(
            xs:QName("prop:last-modified")
            ,">="
            ,$since
          )
        )
      ))
    )
  )
  then map:put($map, $id, fn:true())
  else ()
};

(:
  List all items the provided identifier has relation to.
:)
declare private function module:get-relations-uri($id as xs:string) {
  cts:uris((),(),
    cts:element-range-query(
      fn:QName("http://purl.org/dc/terms/","identifier")
      ,"="
      ,cts:element-attribute-values(
        fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
        ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
        ,()
        ,()
        ,cts:element-range-query(
          fn:QName("http://purl.org/dc/terms/","identifier")
          ,"="
          ,$id
        )
      )
    )
  )
};

(:
  Check if the provided identifier has relation to updated items.
  It set this identifier to fn:true in the map if updated.
:)
declare private function module:check-updated-relations($map as map:map, $id as xs:string) {
 if(
    cts:uris((),(),
      cts:and-query((
        cts:document-query(module:get-relations-uri($id))
        ,cts:properties-query(
          cts:element-range-query(
            xs:QName("prop:last-modified")
            ,">="
            ,$since
          )
        )
      ))
    )
  )
  then map:put($map, $id, fn:true())
  else ()
};

(: map map helper :)
declare private function module:put-map($map as map:map, $id as xs:string) {
  map:put($map, $id, fn:true())
};

(:
  Fill the map with true for all updated searchable items identifiers.
:)
declare private function module:check-updated-item($map as map:map) {
    module:put-map(
    $map
    ,cts:element-values(fn:QName("http://purl.org/dc/terms/","identifier"),
      (),(),
      cts:and-query((
        $searchable-query
        ,cts:properties-query(
          cts:element-range-query(
            xs:QName("prop:last-modified")
            ,">="
            ,$since
          )
        )
      ))
    )
  )
};

(:
  Delete search documents for all new deleted items.
:)
declare private function module:cleanup-deprecated-search-documents() {
  module:cleanup-deprecated-search-document(
    cts:element-values(
      fn:QName("http://purl.org/dc/terms/","identifier")
      ,(),()
      ,cts:and-query((
        cts:collection-query("deleted")
        ,cts:properties-query(
            cts:element-range-query(
              xs:QName("prop:last-modified")
              ,">="
              ,$since
            )
          )
      ))
    )
  )
};

(:
  Delete the search document for the provided identifier.
:)
declare private function module:cleanup-deprecated-search-document($id as xs:string) {
  (: delete doc if it still exists... :)
  let $targetDoc := concat("/searchdoc/", $id, ".xml")
  return
  try { xdmp:document-delete($targetDoc) } catch ($ex) {}
};
