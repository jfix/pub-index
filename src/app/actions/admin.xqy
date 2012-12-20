xquery version "1.0-ml";

import module namespace mi = "http://oecd.org/pi/models/item" at "/app/models/item.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $key := xdmp:get-request-field("key");
declare variable $action := xdmp:get-request-field("action");

declare private function local:add()
{
  let $node := xdmp:get-request-body()/node()
  let $name := lower-case(local-name($node))
  
  return
    if($name) then
      if ($name eq 'item') then
        mi:add($node)
      else
        xdmp:document-insert(
          fn:concat("/referential/",$name,".xml")
          ,$node
          ,()
          ,("referential")
        )
    else
      fn:error((),"Malformed XML input")
};

(: actions handler :)

if(not($key)) then
  xdmp:set-response-code(401,"Unauthorized")
else if ($key ne xdmp:hmac-sha256('pacps', xs:string(xdmp:server()))) then
  xdmp:set-response-code(403,"Forbidden")
else if ($action eq "add") then
  local:add()
else
  xdmp:set-response-code(400,"Bad Request")
