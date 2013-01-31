xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search"  at "/MarkLogic/appservices/search/search.xqy";

declare variable $term := xdmp:get-request-field("term");

let $options := 
  <options xmlns="http://marklogic.com/appservices/search">
    <additional-query>{cts:collection-query("searchable")}</additional-query>
    <default-suggestion-source>
      <word>
        <!-- this searches title and abstract -->
        <field name="suggest-field" collation="http://marklogic.com/collation//S1"/>
      </word>
    </default-suggestion-source>
  </options>

let $model := search:suggest($term, $options, 10)

return
  (xdmp:set-response-content-type("application/json")
   ,
      if (count($model) > 1)
      then
        xdmp:to-json($model)
      else
        concat("[&quot;", $model[1], "&quot;]")
  )