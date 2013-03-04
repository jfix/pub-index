xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace error = "http://marklogic.com/xdmp/error";

declare variable $error:errors as node()* external;

(:
 : TODO: extend to support more errors.
 :)

declare function local:render-content()
as element(div)
{
    let $response-codes := xdmp:get-response-code()
    let $code as xs:integer := $response-codes[1]
    let $response as xs:string := $response-codes[2]
    
    return
        <div class="row">
            <div class="span10 offset1">
                <div class="hero-unit">
                    { if ($code eq 404) 
                        then 
                        (
                            <h1 style="text-shadow: 2px 2px white;">{$response-codes}</h1>
                            ,<p>For some reason the page you were trying to access is not available.<br/>It could also be an external stale link, or a typo.</p>
                            ,<br/>
                            ,<p>Go back to the <a class="btn btn-large btn-primary" href="/">Publications home page.</a></p>
                        ) 
                        else if ($code ge 500) 
                        then
                        (
                            xdmp:log(concat("************ ERROR.XQY: ", $code, " error: ", $code, ": ", $response, " ****************", xdmp:quote($error:errors)))
                            ,<h1 style="text-shadow: 2px 2px white;">{$response-codes}</h1>
                            ,<p>Ah oh! That's real bad. Nothing you can do. This should definitely not have happened.<br/>You may want to get in touch via the Contact Us link.</p>
                            ,<p>Here is some information for the geeks:</p>
                            (: https://github.com/robwhitby/xray/pull/11 :)
                            ,<pre>{concat( 
                                $error:errors//error:code[1], ': ', 
                                string-join($error:errors//error:data/error:datum/text(), " "), "'"
                             )}</pre>
                            ,<br/>
                            ,<p>For the time being, have a look here: <a class="btn btn-large btn-primary" href="http://www.oecd.org/">OECD.org</a></p>
                        )
                        else 
                            xdmp:log(concat("************ ERROR.XQY: unhandled error: ", $code, ": ", $response ))
                        
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
