xquery version "1.0-ml";

import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace s = "lib-search" at "/app/models/search.xqy";
import module namespace f = "lib-facets" at "/app/models/facets.xqy";

declare namespace search = "http://marklogic.com/appservices/search";

declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];
declare variable $format := xdmp:get-request-field("format");

declare function local:render-opensearch-rss($result)
{
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
};

let $model := s:search($s:qtext, $s:start)

return
  if($format eq "rss") then
    local:render-opensearch-rss($model)
  else
    (xdmp:set-response-content-type("text/html")
     ,xdmp:invoke(
        "/app/views/search.html.xqy"
        ,(
          xs:QName("ajax"),fn:false()
          ,xs:QName("model"),$model
          ,xs:QName("facets"),f:facets($s:qtext)
        )
      )
    )