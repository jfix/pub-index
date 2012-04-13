xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";
  
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $term := xdmp:get-request-field("term");

(:

<!--
 <default-suggestion-source>
   <range collation="http://marklogic.com/collation/" 
          type="xs:string" facet="true">
      <element ns="http://purl.org/dc/terms/" name="title"/>
   </range>
 </default-suggestion-source>
 -->
:)

let $options := 
<search:options xmlns="http://marklogic.com/appservices/search">
  <default-suggestion-source>
    <word>
      <!-- this searches title and abstract -->
      <field name="suggest-field" collation="http://marklogic.com/collation//S1"/>
    </word>
  </default-suggestion-source>
  <term>
    <term-option>case-sensitive</term-option>
  </term>
</search:options>
return
 (xdmp:set-response-content-type("application/json"),
    let $suggestions := search:suggest($term, $options, 10)
    return
      if (count($suggestions) > 1)
      then
        xdmp:to-json($suggestions)
      else
        concat("[&quot;", $suggestions[1], "&quot;]")
  
  (:  concat(
      '[&quot;', 
      string-join(
        search:suggest($term, $options, 10), '&quot;,&quot;'
      ),
      '&quot;]'):)
 )