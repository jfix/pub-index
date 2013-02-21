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
declare variable $since as xs:dateTime := fn:current-dateTime() - xs:dayTimeDuration("PT2H"); (: FIXME :)

declare function module:build-search-documents()
{
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

declare private function module:build-search-document($id as xs:string) {
  let $item := mi:enhance-item(mi:get-item($id))
  let $checksum := xdmp:hmac-md5('osef', xdmp:quote($item))
  
  let $uri := concat("/searchdoc/", $id, ".xml")
  
  (: FIXME: use checksum :)
  
  let $void := xdmp:document-insert($uri, $item, (), ("searchable"))
  let $void := xdmp:document-set-property($uri, <prop:checksum>{$checksum}</prop:checksum>)
return ()
};

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

declare private function module:check-updated-children($map as map:map, $id as xs:string) {
  if(
    cts:uris((),(),
      cts:and-query((
        cts:document-query(module:get-children-uri($id))
        ,cts:properties-query(
          cts:element-range-query(
            xs:QName("prop:last-modified")
            ,">"
            ,$since
          )
        )
      ))
    )
  )
  then map:put($map, $id, fn:true())
  else ()
};

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

declare private function module:check-updated-relations($map as map:map, $id as xs:string) {
 if(
    cts:uris((),(),
      cts:and-query((
        cts:document-query(module:get-relations-uri($id))
        ,cts:properties-query(
          cts:element-range-query(
            xs:QName("prop:last-modified")
            ,">"
            ,$since
          )
        )
      ))
    )
  )
  then map:put($map, $id, fn:true())
  else ()
};

declare private function module:put-map($map as map:map, $id as xs:string) {
  map:put($map, $id, fn:true())
};

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
            ,">"
            ,$since
          )
        )
      ))
    )
  )
};

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
              ,">"
              ,$since
            )
          )
      ))
    )
  )
};

declare private function module:cleanup-deprecated-search-document($id as xs:string) {
  (: delete doc if it still exists... :)
  let $targetDoc := concat("/searchdoc/", $id, ".xml")
  return 
  if (ut:doc-exists($targetDoc)) then
    xdmp:document-delete($targetDoc)
  else ()
};
