xquery version "1.0-ml";

import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";
import module namespace mu = "http://oecd.org/pi/models/utils" at "/app/models/utils.xqy";

declare variable $since := xdmp:get-request-field("since");

declare function local:enhance-uri($uri as xs:string)
as xs:string
{
  concat( 'http://', $mu:host, '/display/', tokenize($uri,'/')[4] )
};

let $duration as xs:dayTimeDuration := 
  if($since) then
    if(matches($since, '^\d+$')) then
      xs:dayTimeDuration( concat('PT', $since, 'M') )
    else if($since ne 'P' and matches($since, '^P(\d+D)?(T(\d+H)?(\d+M)?(\d+S)?)?$')) then
      xs:dayTimeDuration($since)
    else
      error((),'Unsupported format')
  else
    xs:dayTimeDuration('P1D')

return
  for $uri in ms:get-modified-items(fn:true(), current-dateTime() - $duration)
  order by $uri
  return
    local:enhance-uri($uri)