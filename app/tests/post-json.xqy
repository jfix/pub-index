xquery version "1.0-ml";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $filter as xs:string := (xdmp:get-request-field("filter"), '')[1]; (: serialized JSON object :)
declare variable $qtext as xs:string := concat($term, " ", $filter);
declare variable $start as xs:integer := xs:integer((xdmp:get-request-field("start"), 1)[1]);
declare variable $page-length as xs:integer := xs:integer((xdmp:get-request-field("page-length"), 10)[1]);

(xdmp:set-response-content-type("text/html"),
<html>
  <head>
    <title>post json</title>
  </head>
  <body>
    <div>
      <form action="/tests/post-json.xqy" method="post" class="nice" name="searchForm" id="searchForm">
        <input type="search" value="{$term}" id="term" name="term" class="medium oversize ui-autocomplete-input align-bottom"/><br/>
        <input type="text" id="filter" name="filter" size="60"/><br/>
        <div id="debug"></div>
        <input type="text" id="start" name="start" value="1"/><br/>
        <input type="text" id="page-length" name="page-length" value="10"/><br/>
        <input type="submit"/>
      </form>
    </div>
    
    <script type="text/javascript" src="/application/js/jquery/jquery-1.7.2.js"></script>
    <script type="text/javascript" src="/application/js/facets.js"></script>
    <script type="text/javascript">
    $(document).ready(function() {{
      
      // create an object and stringify it for transmission
      var facets = {{ subject: ["Blah and foo"], pubtype: ["book", "chapter"] }};
      $("#filter").val(JSON.stringify(facets));

      // take json string and turn it back into an object
      var filter = { if (string-length($filter) > 0) then $filter else '{}' };
      // create the string that is manageable by marklogic
      var str2 = serializeFacets(filter);
      $("div#debug").html(str2);

    }});
    </script>
  </body>
</html>)