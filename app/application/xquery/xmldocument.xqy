xquery version "1.0-ml";

(: $Id$ :)

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $id as xs:string := xdmp:get-request-field("id");
declare variable $type as xs:string := tokenize($id, '/')[1];
declare variable $doi as xs:string := tokenize($id, '/')[2];

(: simply return the document requested :)
document(concat('/content/', $type, '/', $doi))
