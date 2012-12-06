xquery version "1.0-ml";
declare variable $host := (xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1];
xdmp:set-response-content-type("text/xml"),
<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
  <ShortName>OECD Publications</ShortName>
  <Description>Find OECD publications quickly on publications.oecd.org</Description>
  <Tags>oecd ocde publications search</Tags>
  <Contact>contact@oecd.org</Contact>
  <SyndicationRight>open</SyndicationRight>
  <Url type="text/html" method="get" template="http://{$host}/search?term={{searchTerms}}"/>
  <Url type="application/rss+xml" template="http://{$host}/search?term={{searchTerms}}&amp;start={{startPage?}}&amp;format=rss"/>
  <Url type="application/opensearchdescription+xml" rel="self" template="http://{$host}/opensearch.xml"/>
</OpenSearchDescription>