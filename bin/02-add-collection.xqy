xquery version "1.0-ml";

(:
  $Id$
  
  this script should be run from the query console
  it adds a collection name based on the root element's name
  e.g. Article => article, Book => book, ...
  it only applies to documents that have the metadata collection name
  which has been attached to each element via the "infostudio ingestion"
:)
let $md := collection("metadata")
for $doc in $md
  let $uri := xdmp:node-uri($doc)
  let $coll := lower-case(local-name($doc/*))
  return
    xdmp:document-set-collections($uri, (xdmp:document-get-collections($uri), $coll))

