xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $error:errors as node()* external;

(:
 : TODO: extend to support more errors.
 :)

declare function local:render-content()
as element(div)
{
    let $code as xs:integer := xdmp:get-response-code()[1]
    return
        <div class="row">
            <div class="span10 offset1">
                <div class="hero-unit">
                    { if ($code eq 404) 
                        then 
                        (
                            <h1 style="text-shadow: 1px 1px white;">{xdmp:get-response-code()}</h1>
                            ,<p>For some reason the page you were trying to access is not available.<br/>It could also be an external stale link, or a typo.</p>
                            ,<br/>
                            ,<p>Go back to the <a class="btn btn-large btn-primary" href="/">Publications home page.</a></p>
                        ) 
                        else
                            xdmp:log(concat("************ ERROR.XQY: unhandled error: ", string-join(xdmp:get-response-code(), " ")))
                    }
                </div>
            </div>
      </div>
};

let $params := map:map(),
      $void := map:put($params, "title", "Oh no! - OECD publications"),
      $void := map:put($params, "content", local:render-content()),
      $void := map:put($params, "scripts", (
        <link rel="stylesheet" href="/assets/jquery/ui/themes/cupertino/jquery-ui-1.9.2.custom.min.css" />
        ,<script type="text/javascript" src="/assets/jquery/ui/jquery-ui-1.9.2.custom.min.js"></script>
      ))

return (
    xdmp:set-response-content-type("text/html"),
    layout:render($params)
    )
