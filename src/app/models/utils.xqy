xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/utils";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $module:debug as xs:boolean := true();

declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];

declare function module:log(
  $msg as xs:string,
  $level as xs:string
) as empty-sequence()
{
  if ($module:debug) then
    xdmp:log( concat("[BOOKS.OECD.ORG] ", $msg), $level)
  else ()
};

declare function module:log(
  $msg as xs:string
) as empty-sequence()
{
  module:log($msg, 'info')
};

declare function module:get-output-format()
as xs:string
{
  let $param := xdmp:get-request-field('format')
  let $accept := xdmp:get-request-header('Accept')
  return 
    if($param eq '.xml' or $param eq 'xml' or contains($accept, 'text/xml'))
      then 'xml'
     else if($param eq '.json' or $param eq 'json' or contains($accept, 'application/json'))
      then 'json'
     else
      'html'
};