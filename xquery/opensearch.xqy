xquery version "1.0-ml";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $start as xs:integer := xs:integer(
  if (string-length(xdmp:get-request-field("start")) < 1) 
  then 1 
  else xdmp:get-request-field("start")
  );

(:
  TODO
  actually execute a search
  and return RSS to client
:)

fn:concat("HERE BE OPENSEARCH FOR: ", $term, " -- ", $start)