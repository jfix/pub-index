xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib/view.xqy";
import module namespace b = "lib-browse" at "lib/browse.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $error:errors as node()* external;

v:html-browse-page(
  concat("Error - ", xs:string(xdmp:get-response-code()[1]), " ", xdmp:get-response-code()[2]), 
  (),
  
  <div>
  {
    xdmp:get-response-code()
    ,
    xdmp:log(concat("XXX", xdmp:quote($error:errors)))
  }
  </div>,
  
  "",
  "",
  "",
  1
)
(:$error:errors:)