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

(: This function attempts to clear all forests for the current database.
 : Yes, this is very dangerous! Don't use unless you know what you are doing.
 : You have been warned! Double-warned!!
 :)
declare private function local:clear-forests()
{
    let $dbid := xdmp:database()
    let $dbname := xdmp:database-name($dbid)
    let $forests := xdmp:database-forests($dbid)
    return
        if(fn:empty($forests)) then
            fn:error((), fn:concat("No forests found for database: ", $dbname))
        else
            (xdmp:forest-clear($forests)
            ,xdmp:log(fn:concat("********* Cleared forests ", fn:string-join(xs:string($forests), ", "), " for database: ", $dbname)))
};

(: action handlers :)

if(not($key)) then
  xdmp:set-response-code(401,"Unauthorized")
else if ($key ne xdmp:hmac-sha256('pacps', xs:string(xdmp:server()))) then
  xdmp:set-response-code(403,"Forbidden")
else if ($action eq "add") then
  local:add()
else if ($action eq "clear-forests") then
  local:clear-forests()
else
  xdmp:set-response-code(400,"Bad Request")
