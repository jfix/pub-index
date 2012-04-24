xquery version "1.0-ml";

(:
    $Id$

    this script replaces existing dt:subject elements with random ones
    taken from the topics.xml file
    
    needs to be run in the context of the database,
    usually via the query console.  so just copy'n'paste.
:)

declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

let $pub-docs := collection("metadata")
let $topics-doc := document("/assets/mappings/topics.xml")
let $topics := $topics-doc//topic

for $pub-doc in ($pub-docs)
  let $random as xs:int := xdmp:random(count($topics)-1) + 1 
  let $topic as xs:string := $topics[$random]/text()
  let $existing-subject := $pub-doc//dt:subject/text()
  return xdmp:node-replace($existing-subject, text {$topic} )
