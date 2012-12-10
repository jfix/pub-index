xquery version "1.0-ml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $key := xdmp:get-request-field("key");
declare variable $action := xdmp:get-request-field("action");

declare private function local:add-item()
{
  let $item := xdmp:get-request-body()/node()
  
  let $id := $item/dt:identifier
  let $type := $item/@type
  
  return 
    if($id and $type) then
      xdmp:document-insert(
        fn:concat("/metadata/",$type,"/",$id,".xml")
        ,$item
        ,()
        ,(
          "metadata"
          ,$type
          ,if($type = ("book", "article", "workingpaper", "serial", "summary")) then "searchable" else ()
        )
      )
    else
      fn:error((),"Malformed XML input")
};

(: actions handler :)

if(not($key)) then
  xdmp:set-response-code(401,"Unauthorized")
else if ($key ne xdmp:hmac-sha256('pacps', xs:string(xdmp:server()))) then
  xdmp:set-response-code(403,"Forbidden")
else if ($action eq "add-item") then
  local:add-item()
else
  xdmp:set-response-code(400,"Bad Request")
