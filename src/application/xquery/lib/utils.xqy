xquery version "1.0-ml";

(: $Id$ :)

module namespace u = "lib-utils";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $u:debug as xs:boolean := true();


declare function u:log(
  $msg as xs:string,
  $level as xs:string
) as empty-sequence()
{
  if ($u:debug) then
    xdmp:log( concat("[BOOKS.OECD.ORG] ", $msg), $level)
  else ()
};

declare function u:log(
  $msg as xs:string
) as empty-sequence()
{
  u:log($msg, 'info')
};
