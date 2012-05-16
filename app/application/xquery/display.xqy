xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib/view.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");
declare variable $type as xs:string := tokenize($id, '/')[1];
declare variable $doi as xs:string := tokenize($id, '/')[2];

(:let $doc as node() := document(xdmp:node-uri(collection("metadata")/*[dt:identifier = $id])):)
try {
  let $doc as node() := collection("metadata")//dt:identifier[. = $id]/root()
  
  let $content := xdmp:xslt-invoke("/application/xslt/publication.xsl", $doc)
  
  return v:html-product-page(
    $doc/oe:*/dt:title,
    (),
    $content,
    "","","",1)
} catch($e) {

}