xquery version "1.0-ml";

(: $Id$ :)

(:~
 : This module defines functions that can be called to create widgets, such as:
 : * google map (TODO)
 : * slider thingy (TODO)
 : * ...
 :)
module namespace w = "lib-widgets";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace cc = "country-data";

declare default collation "http://marklogic.com/collation/";

declare function w:get-latest-books($max as xs:integer)
as element(oe:Book)*
{
  let $dl := fn:current-dateTime() - xs:dayTimeDuration("P30D")

  let $books := 
    for $book in collection("metadata")/oe:Book[oe:status = 'available' and dt:available gt $dl and fn:exists(oe:coverImage) ]
    order by $book/dt:available descending
    return $book
  
  return
    for $b in $books[1 to $max]
    return $b
};

declare function w:latest()
as element(div)
{
  <div id="latest" class="carousel slide well">
    <!-- Carousel items -->
    <div class="carousel-inner">
      {
        let $books := w:get-latest-books(12)
        for $b at $i in $books
        return
          if($i mod 4 eq 1) then
            <div>
              { attribute class { if($i eq 1) then "item active" else "item" } }
              <ul>
                {
                  for $book in $books[$i to $i+3]
                  return
                    <li><a href="/display/{$book/dt:identifier}" title="{$book/dt:title}">
                      <img src="http://images.oecdcode.org/covers/100/{$book/oe:coverImage}" alt=""/>
                    </a></li>
                }
              </ul>
            </div>
          else
            ()
       }
    </div>
    <!-- Carousel nav -->
    <a class="carousel-control left" href="#latest" data-slide="prev">&lsaquo;</a>
    <a class="carousel-control right" href="#latest" data-slide="next">&rsaquo;</a>
  </div>
};

declare function w:map-data()
{
  let $doc := document("/refs/countries.xml")
  let $countries := cts:element-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/", "country"),"", ("item-frequency"), 
    cts:collection-query(("metadata")))
  
  let $list := (
    for $country in $countries
    
    let $coords := xs:double($doc//cc:country[cc:code = upper-case($country)]/cc:coords/cc:centred/cc:*)    
    let $freq := cts:frequency($country)
    let $map := map:map()
    let $put := map:put($map, 'center', $coords)
    let $put := map:put($map, 'radius', $freq * 1000)
    let $put := map:put($map, "fillColor", "#018FD1")
    let $put := map:put($map, "strokeColor", "#018FD1")
    let $put := map:put($map, "strokeWeight", "1")
    let $put := map:put($map, "action", "addCircle")
    (:order by $freq descending:)
    return $map
  )
  let $json := xdmp:to-json($list)
  let $length := string-length($json)
  return substring( substring($json, 2), 1, ($length - 2))
};

declare function w:map-scripts()
as element(script)*
{
  (
  )
};