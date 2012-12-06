xquery version "1.0-ml";
module namespace m = "lib-backlinks";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace pr = "http://marklogic.com/xdmp/property";

declare variable $cache-expire as xs:dayTimeDuration := xs:dayTimeDuration("P7D");

(:
  Get backlinks for the given oecd item.
:)
declare function m:get-item-backlinks($item as element())
as element()
{
  m:get-backlinks(string-join($item//dt:subject, ' '))
};

(:
  Get backlinks for the given search terms.
  Search results are cached in the marklogic database.
:)
declare function m:get-backlinks($terms as xs:string)
as element()
{
  let $bl := collection("backlinks")[.//dt:identifier = $terms]/*
  
  return
    if($bl) then
      if( xs:dayTimeDuration(current-dateTime() - fn:data(xdmp:document-properties(base-uri($bl))//pr:last-modified)) gt $cache-expire ) then
        let $r := m:query-external-engine($terms),
          $tmp := xdmp:document-insert(base-uri($bl), $r, (), "backlinks")
        return $r
      else
        $bl
    else
      let $r := m:query-external-engine($terms),
        $tmp := xdmp:document-insert(concat("/backlinks/", xdmp:hmac-sha1("oecd", $terms), ".xml" ), $r, (), "backlinks")
      return $r
};

(:
  Query an external search engine for the given terms.
:)
declare private function m:query-external-engine($terms as xs:string)
as element()
{
  <backlinks xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:dt="http://purl.org/dc/terms/">
    <dt:identifier>{$terms}</dt:identifier>
    <items>
      <item>
        <title>Flower - Wikipedia, the free encyclopedia</title>
        <link>http://en.wikipedia.org/wiki/Flower</link>
        <snippet>A flower, sometimes known as a bloom or blossom, #{$terms}# is the reproductive structure found in flowering plants (plants of the division Magnoliophyta, ...</snippet>
      </item>
      <item>
        <title>Flower2 - Wikipedia, the free encyclopedia</title>
        <link>http://en.wikipedia.org/wiki/Flower2</link>
        <snippet>A flower2, sometimes known as a bloom or blossom, #{$terms}# is the reproductive structure found in flowering plants (plants of the division Magnoliophyta, ...</snippet>
      </item>
      <item>
        <title>Flower3 - Wikipedia, the free encyclopedia</title>
        <link>http://en.wikipedia.org/wiki/Flower3</link>
        <snippet>A flower3, sometimes known as a bloom or blossom, #{$terms}# is the reproductive structure found in flowering plants (plants of the division Magnoliophyta, ...</snippet>
      </item>
      <item>
        <title>Flower4 - Wikipedia, the free encyclopedia</title>
        <link>http://en.wikipedia.org/wiki/Flower4</link>
        <snippet>A flower4, sometimes known as a bloom or blossom, #{$terms}# is the reproductive structure found in flowering plants (plants of the division Magnoliophyta, ...</snippet>
      </item>
      <item>
        <title>Flower5 - Wikipedia, the free encyclopedia</title>
        <link>http://en.wikipedia.org/wiki/Flower5</link>
        <snippet>A flower5, sometimes known as a bloom or blossom, #{$terms}# is the reproductive structure found in flowering plants (plants of the division Magnoliophyta, ...</snippet>
      </item>
    </items>
  </backlinks>
};
