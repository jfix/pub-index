xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare function test:home-page()
{
    let $html-page := xdmp:unquote(xdmp:http-get(fn:concat("http://", xdmp:host-name(xdmp:host()), ":20001/"))[2]
                        ,"http://www.w3.org/1999/xhtml"
                        ,("repair-full")
                        )
    
    (: just add tests :)
    return (
        assert:equal(
            fn:data($html-page/html/head/link[@rel/string()='profile']/@href/string()), 
            "http://a9.com/-/spec/opensearch/1.1/", 
            "opensearch namespace must be available")
        , assert:equal(
            fn:data($html-page/html/head/link/@type),
            "application/opensearchdescription+xml",
            "opensearch link element with correct type attribute")
        , assert:equal(
            fn:count($html-page//div[@class = "facet"]),
            5, (: topic + language + country + language + pubtype = 5 :)
            "make sure we have all facet divs")
        , assert:equal(
            fn:count($html-page//div[@class="facet"]//a[contains(@data-facet/string(), "topic")]),
            26,
            "we have 26 topics and we should find them all")
        , assert:equal(
            fn:count(
(:                $html-page//div[contains(@class/string(), "topic")]//option[matches(@value/string(), '[a-z]{2}')]:)
                $html-page//select[@data-facet="country"]//option[matches(@value/string(), '[a-z]{2}')]
            ),
            207, (: count(//option[matches(@value, '[a-z]{2}')]):)
            "we have 207 countries and we should find them all")
       ) 
};