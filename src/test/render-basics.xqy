xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare namespace fn = "http://www.w3.org/2005/xpath-functions";
declare namespace http = "xdmp:http";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

(: using a HOSTS mapping may cause the server to not be able to resolve itself... using loopback :)
declare variable $host := fn:concat('127.0.0.1', ':' , xdmp:get-request-port()); 

(: Actions endpoints :)
declare variable $homePath :=  '/app/actions/home.xqy';
declare variable $displayPath :=  '/app/actions/display.xqy';
declare variable $searchResultPath := '/app/actions/search.xqy?term=&amp;in=&amp;start=1&amp;order=';

(: private functions to get and check pages content :)
declare private function get-page($path) {
    let $http_response := xdmp:http-get(fn:concat('http://', $host , $path)) 
    let $responseContentType := fn:tokenize($http_response[1]/http:headers/http:content-type/text(), ';')[1]
    return 
        <GET>
            <path>{$path}</path>
            <code>{$http_response[1]/http:code/text()}</code>
            <content-type>{$responseContentType}</content-type>
            { 
                try {
                    (: try to unparse :)
                    <content>{ xdmp:unquote($http_response[2])}</content>
                } catch($ex) {
                     <content>{ $http_response[2] }</content>
                }                 
           }
        </GET>   
};

declare private function is-html-response($response)  {
    (
        assert:true(($response/code eq '200'), fn:concat('Invalid HTTP Response Code (',$response/code,') when requesting url: ', $response/path)),
        assert:true(($response/content-type eq 'text/html'), fn:concat('Invalid content type (',$response/content-type,') header when requesting url: ', $response/path)),
        assert:true(fn:exists($response/content/xhtml:html) , fn:concat('Invalid root element (',fn:local-name(($response/content/*)[1]),'): ', $response/path))
    )   
};

declare private function is-xml-response($response, $expectedRoot)  {
    (
        assert:true(($response/code eq '200'), fn:concat('Invalid HTTP Response Code (',$response/code,') when requesting url: ', $response/path)),
        assert:true(($response/content-type eq 'text/xml'), fn:concat('Invalid content type (',$response/content-type,') header when requesting url: ', $response/path)),
        (:check root only if provided:)
        if($expectedRoot) then
            assert:true(fn:exists($response/content/*[fn:local-name(.) eq $expectedRoot]) , fn:concat('Invalid root element (',fn:local-name(($response/content/*)[1]),'): ', $response/path))
        else ()
    )  
};

declare private function get-one-item($type as xs:string) {
    get-one-item($type, fn:false())
};

declare private function get-one-item($type as xs:string, $deleted as xs:boolean) as xs:string {
    if($deleted) then
       fn:string((fn:collection("deleted")/oe:item[@type = $type])[1]/dt:identifier)       
    else
       fn:string((fn:collection("metadata")/oe:item[@type = $type])[1]/dt:identifier)
};


(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(::  The tests ! ::)
(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)

(:: Testing homepage ! ::)
declare function test:should-render-homepage () {
    is-html-response(get-page($homePath))    
};

(:: Result page ! ::)
declare function test:should-render-search-result () {
    is-html-response(get-page($searchResultPath))    
};


(::  Testing rendering of 'renderable' items ::)
declare function test:should-render-book-page () {
    let $id := get-one-item('book')
    (: proceed only if an id was found :)    
    return 
        if($id) then
            is-html-response(get-page(fn:concat($displayPath, '?id=', $id )))  
        else ()
};

declare function test:should-render-edition-page () {
    let $id := get-one-item('edition')
    (: proceed only if an id was found :)    
    return 
        if($id) then
            is-html-response(get-page(fn:concat($displayPath, '?id=', $id )))  
        else ()
};

declare function test:should-render-journal-page () {
    let $id := get-one-item('journal')
    (: proceed only if an id was found :)    
    return 
        if($id) then
            is-html-response(get-page(fn:concat($displayPath, '?id=', $id )))  
        else ()
};

declare function test:should-render-workingpaperseries-page () {
    let $id := get-one-item('workingpaperseries')
    (: proceed only if an id was found :)    
    return 
        if($id) then
            is-html-response(get-page(fn:concat($displayPath, '?id=', $id )))  
        else ()
};

(::  Testing renderinf of non-renderable page (returned as XML) ::)
declare function test:should-return-workingpaper-xml-item () {
    let $id := get-one-item('workingpaper')
    (: proceed only if an id was found :)    
    return 
        if($id) then
            is-xml-response(get-page(fn:concat($displayPath, '?id=', $id )), 'item')  
        else ()
};

(:: Deleted content page ::)
declare function test:should-return-deleted-content-page () {
    (: find a deleted book first :)
    let $id := get-one-item('book', fn:true())
    (: proceed only if an id was found :)    
    return 
        if($id) then
            let $page := get-page(fn:concat($displayPath, '?id=', $id ))
            return (
                is-html-response($page),
                (: also check page title :)
                assert:true(fn:contains($page/content/xhtml:html/xhtml:head/xhtml:title, 'Deleted Content'), 'Invalid page title for deleted content')
            )            
        else assert:true(fn:false(), 'No deleted content in DB.')
};

(::  404 page ::)
declare function test:should-return-404-page () {
    let $resp := get-page('/this-page-should-not-exist')
    return
       assert:true($resp/code eq 404, 'Error page is not returned')
};

(:: 404 for invalid expression id ::)
declare function test:should-return-404-page-for-invalid-identifier () {
    let $resp := get-page(fn:concat($displayPath, '?id=', 'this-id-should-not-exist' ))
    return
        (
            assert:true($resp/code eq 404, 'Error page is not returned'),
            assert:true($resp/content eq 'Not Found', 'Error page content is not "Not Found"')
         )
};

