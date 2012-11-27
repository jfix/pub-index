xquery version "1.0-ml";

import module namespace b = "lib-backlinks" at "lib/backlinks.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");

xdmp:xslt-invoke("/application/xslt/backlinks.xsl", b:get-item-backlinks(collection("metadata")[.//dt:identifier = $id]/*) )