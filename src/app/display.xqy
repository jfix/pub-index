xquery version "1.0-ml";

import module namespace v = "lib-view" at "lib/view.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");

try {
  let $doc as node() := collection("metadata")//dt:identifier[. = $id]/root()
  
  let $content := xdmp:xslt-invoke("/app/xslt/publication.xsl", $doc)
  
  let $script := <script type="text/javascript">
    $(function() {{
      $('#backlinks').load('/app/backlinks.xqy?id={xdmp:url-encode($id)}');
    }});
  </script>
  
  return v:html-product-page(
    $doc/oe:*/dt:title,
    $script,
    $content,
    "","","",1)
} catch($e) {

}