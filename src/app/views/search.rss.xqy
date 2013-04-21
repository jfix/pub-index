xquery version "1.0-ml";

import module namespace hs = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/search-helper.xqy";
import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace search = "http://marklogic.com/appservices/search";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $model as node()? external; 
declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];

declare function local:render-opensearch-rss($results)
{
  <rss version="2.0" 
      xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
    <title>{$host} Search: {$ms:term}</title>
    <link>http://{concat($host,xdmp:get-original-url())}</link>
    <description>Search results for "{$ms:term}" at {$host}</description>
    <opensearch:totalResults>{data($results/@total)}</opensearch:totalResults>
    <opensearch:startIndex>{data($results/@start)}</opensearch:startIndex>
    <opensearch:itemsPerPage>10</opensearch:itemsPerPage>
    <atom:link rel="search" type="application/opensearchdescription+xml" href="http://example.com/opensearchdescription.xml"/>
    <opensearch:Query role="request" searchTerms="{$ms:term}" startPage="{$ms:start}"/>
    {
      for $result in $results/search:result
      let $item := $result/oe:item
      let $uri as xs:string :=
        if($item/@type = ('article','workingpaper')) then
          $item/oe:link[@type eq 'doi']/@rdf:resource
        else
          concat('http://',$host, '/display/', data($item/dt:identifier))
      let $biblio := ($item/oe:bibliographic[@xml:lang eq 'en'],$item/oe:bibliographic)[1]
      let $abstract := data($biblio/dt:abstract)
      return
        <item>
          <guid>{ data($item/dt:identifier) }</guid>
          <title>{ fn:data($biblio/dt:title) }</title>
          <link>{ $uri }</link>
          <pubDate>{ data($item/dt:available) }</pubDate>
          <description>{ if(string-length($abstract) > 260) then concat(normalize-space(substring($abstract,1,250)), '...') else $abstract }</description>
        </item>
    }
    </channel>
  </rss>
};

local:render-opensearch-rss($model)