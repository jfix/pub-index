xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: using a HOSTS mapping may cause the server to not be able to resolve itself... using loopback :)
declare variable $host := concat('127.0.0.1', ':' , xdmp:get-request-port()); 

declare function test:should-return-results ()
{
    let $term := 'economy'
    let $errorMsg := fn:concat('This search on &#39;', $term ,'&#39; should return results')
    let $results := xdmp:http-get(fn:concat('http://',$host,'/search?term=', $term,'&amp;in=&amp;start=1&amp;order=&amp;format=rss'))[2]/rss/channel
    
    return assert:true(xs:integer($results/*:totalResults) gt 0, $errorMsg)
};

declare function test:should-not-return-results  ()
{
    let $term := '&#231;aNeRetourneRienCommeR&#233;sultatMaisVraimentRienDuToutMaisEnM&#234;MeTempsC&#39;estCompl&#233;tementLogique'
    let $errorMsg := fn:concat('This search on &#39;', $term ,'&#39; should not return results')
    let $results := xdmp:http-get(fn:concat('http://',$host,'/search?term=', $term,'&amp;in=&amp;start=1&amp;order=&amp;format=rss'))[2]/rss/channel
    
    return assert:equal(xs:integer($results/*:totalResults), 0, $errorMsg)
};


declare function test:should-respect-start-page-index ()
{    
    let $term := 'economy'
    let $expectedStartIndex := 2
    let $errorMsg := 'Start page index should be '
    let $results := xdmp:http-get(fn:concat('http://',$host,'/search?term=', $term,'&amp;in=&amp;start=', $expectedStartIndex, '&amp;order=&amp;format=rss'))[2]/rss/channel
    let $actualStartIndex := xs:integer($results/*:startIndex)
    
    return assert:equal($actualStartIndex, $expectedStartIndex, fn:concat($errorMsg, $expectedStartIndex, ' instead of ', $actualStartIndex))   
};

declare function test:should-respect-equality-between-expected-itemsPerPage-and-actual-itemsPerPage ()
{    
    let $term := 'economy'
    let $errorMsg := 'Number of items per page should be ' 
    let $results := xdmp:http-get(fn:concat('http://',$host,'/search?term=', $term,'&amp;in=&amp;start=1&amp;order=&amp;format=rss'))[2]/rss/channel
    let $expectedItemsPerPage := xs:integer($results/*:itemsPerPage)
    let $actualItemsPerPage := fn:count($results/item)
    
    return assert:equal($actualItemsPerPage, $expectedItemsPerPage, fn:concat($errorMsg, $expectedItemsPerPage, ' instead of ', $actualItemsPerPage))   
};



