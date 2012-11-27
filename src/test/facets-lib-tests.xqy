xquery version "1.0-ml";

(: $Id$ :)

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" 
    at "/xray/src/assertions.xqy";

import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";

import module namespace f = "lib-facets"
    at "/app/lib/facets.xqy";


declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace x = "http://www.w3.org/2005/xpath-functions";
(:declare namespace country = "country-data";:)
(:declare namespace lang = "language-data";:)

declare function test-facets()
{
    let $f := <search:response snippet-format="transformed-result" total="100" start="1" page-length="10" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="" xmlns:search="http://marklogic.com/appservices/search">
    <search:facet name="metadata-only" type="collection">
        <search:facet-value name="" count="100"/>
    </search:facet>
    <search:facet name="pubtype" type="xs:string">
        <search:facet-value name="article" count="30">article</search:facet-value>
        <search:facet-value name="book" count="70">book</search:facet-value>
    </search:facet>
    <search:facet name="country" type="xs:string">
        <search:facet-value name="ad" count="5">ad</search:facet-value>
        <search:facet-value name="ae" count="95">ae</search:facet-value>
    </search:facet>
    <search:facet name="subject" type="xs:string">
        <search:facet-value name="Agriculture and fisheries" count="33">Agriculture and fisheries</search:facet-value>
        <search:facet-value name="Bribery and corruption" count="67">Bribery and corruption</search:facet-value>
   </search:facet>
    <search:facet name="language" type="xs:string">
        <search:facet-value name="ar" count="40">ar</search:facet-value>
        <search:facet-value name="bg" count="60">bg</search:facet-value>
    </search:facet>
    <search:qtext/>
    </search:response>
    
    let $r := f:facets("", 1, 10)
    return (
        (: six div elements will be returned :)
        assert:equal(x:count($r), 6, "The number of facets (should be 6)"),
        
        (: first element returned should be a 'div' :)
        assert:equal(x:local-name($r[1]), "div", "This function should return 'div' elements"),
        
        (: only div h6 label select and ul elements should be returned :)
        assert:equal(
            functx:sort(x:distinct-values($r/*/x:local-name(.))), 
            ("div", "h6", "label", "select", "ul"), 
            "Function should 'only' return these elements"
        ),
        
        (: namespace uri should be 'http://www.w3.org/1999/xhtml' :)
        assert:equal($r[1]/x:namespace-uri(), 'http://www.w3.org/1999/xhtml'),
        
        assert:equal(x:count($r), 6, "The number of facets (should be 6)")
    )
};

declare function test-transform-facet-results()
{
    let $f := <search:response snippet-format="transformed-result" total="100" start="1" page-length="10" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="" xmlns:search="http://marklogic.com/appservices/search">
    <search:facet name="metadata-only" type="collection">
        <search:facet-value name="" count="100"/>
    </search:facet>
    <search:facet name="pubtype" type="xs:string">
        <search:facet-value name="article" count="30">article</search:facet-value>
        <search:facet-value name="book" count="70">book</search:facet-value>
    </search:facet>
    <search:facet name="country" type="xs:string">
        <search:facet-value name="ad" count="5">ad</search:facet-value>
        <search:facet-value name="ae" count="95">ae</search:facet-value>
    </search:facet>
    <search:facet name="subject" type="xs:string">
        <search:facet-value name="Agriculture and fisheries" count="33">Agriculture and fisheries</search:facet-value>
        <search:facet-value name="Bribery and corruption" count="67">Brib ery and corruption</search:facet-value>
   </search:facet>
    <search:facet name="language" type="xs:string">
        <search:facet-value name="ar" count="40">ar</search:facet-value>
        <search:facet-value name="bg" count="60">bg</search:facet-value>
    </search:facet>
    <search:qtext/>
</search:response>

    let $r := f:transform-facet-results( $f, "")

     return (
        (: six div elements will be returned :)
        assert:equal(x:count($r), 6, "The number of facets (should be 6)"),
        
        (: first element returned should be a 'div' :)
        assert:equal(x:local-name($r[1]), "div", "This function should return 'div' elements"),
        
        (: only div h6 label select and ul elements should be returned :)
        assert:equal(
            functx:sort(x:distinct-values($r/*/x:local-name(.))), 
            ("div", "h6", "label", "select", "ul"), 
            "Function should 'only' return these elements"
        ),
        
        (: namespace uri should be 'http://www.w3.org/1999/xhtml' :)
        assert:equal($r[1]/x:namespace-uri(), 'http://www.w3.org/1999/xhtml')
    )
};