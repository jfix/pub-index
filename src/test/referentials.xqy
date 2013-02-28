xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(::  The referentials must exists ! ::)
(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)

(:: Countries ::)
declare function test:referential-country-exists () {

    let $r as xs:string* := collection("referential")/oe:countries/oe:country/string(@id)
    let $m as xs:string* := distinct-values(collection("metadata")//oe:country/text())
    
    (: find countries defined in Metdata, but not in referential :)
    let $no_def := (for $c in $m where not($c eq $r) order by $c return $c )
    
    return
    (
         assert:true(count($no_def) eq 0, concat('Country code(s) ',string-join($no_def, ', '),' are not declared in referential'))   
    )
    
};

(:: Languages ::)
declare function test:referential-language-exists () {

    let $r as xs:string* := collection("referential")/oe:languages/oe:language/string(@id)
    let $m as xs:string* := distinct-values(collection("metadata")//dt:language/text())
    
    (: find countries defined in Metdata, but not in referential :)
    let $no_def := (for $c in $m where not($c eq $r) order by $c return $c )
    
    return
    (
         assert:true(count($no_def) eq 0, concat('Language code(s) ',string-join($no_def, ', '),' are not declared in referential'))   
    )
    
};

(:: Topics ::)
declare function test:referential-topic-exists () {

    let $r as xs:string* := collection("referential")/oe:topics/oe:topic/string(@id)
    let $m as xs:string* := distinct-values(collection("metadata")//dt:subject/text())
    
    (: find countries defined in Metdata, but not in referential :)
    let $no_def := (for $c in $m where not($c eq $r) order by $c return $c )
    
    return
    (
         assert:true(count($no_def) eq 0, concat('Topics code(s) ',string-join($no_def, ', '),' are not declared in referential'))   
    )
    
};