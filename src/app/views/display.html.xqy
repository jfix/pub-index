xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $model as node()? external;

declare variable $id as xs:string := ($model//dt:identifier)[1];

let $params := map:map(),
      $void := map:put($params, "title", string(($model//dt:title)[1])),
      $void := map:put($params, "scripts",(
        <script type="text/javascript">
          $(function() {{
            $('#backlinks').load('/app/actions/backlinks.xqy?id={xdmp:url-encode($id)}');
          }});
        </script>
      )),
      $void := map:put($params, "content", xdmp:xslt-invoke("/app/xslt/publication.xsl", $model))

return
  layout:render($params)