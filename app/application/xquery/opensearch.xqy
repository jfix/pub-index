xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace s = "lib-search" at "lib/search.xqy";

declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];

let $result := s:search($s:term, $s:start)

return
<rss version="2.0" 
      xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
  <title>{$host} Search: {$s:term}</title>
  <link>http://{concat($host,xdmp:get-original-url())}</link>
  <description>Search results for "{$s:term}" at {$host}</description>
  <opensearch:totalResults>{data($result/@total)}</opensearch:totalResults>
  <opensearch:startIndex>{data($result/@start)}</opensearch:startIndex>
  <opensearch:itemsPerPage>10</opensearch:itemsPerPage>
  <atom:link rel="search" type="application/opensearchdescription+xml" href="http://example.com/opensearchdescription.xml"/>
  <opensearch:Query role="request" searchTerms="{$s:term}" startPage="{$s:start}"/>
  {
    for $item in $result/search:result
    return
      <item>
        <title>{ fn:data($item/search:snippet/search:title) }</title>
        <link>{ concat('http://',$host, '/display/', functx:substring-after-last-match(substring-before($item/@uri, '.xml'), '[/]')) }</link>
        <description>{ fn:data($item/search:snippet/search:match) }</description>
      </item>
  }
  </channel>
</rss>