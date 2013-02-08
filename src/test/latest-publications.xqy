xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";

declare function test:last-publications-number-of ()
{
    let $model :=         
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest-items(8,2,2)}
        </latests>
    return
        (: 8 items have to be returned :)
        assert:equal(fn:count($model/oe:latests/oe:item), 8, "The number of last publications (should be 8)")
};

declare function test:last-publications-article-publication-date ()
{
    let $model :=         
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest-items(8,2,2)}
        </latests>
    return    
        (: All Articles have to be  between today and 3 months ago :)
        for $item in $model/oe:latests/oe:item[@type='article']/dt:available
        return assert:true($item lt fn:current-dateTime() and $item gt (fn:current-dateTime() - xs:dayTimeDuration('P90D')),"???")
};

declare function test:last-publications-workingpaper-publication-date ()
{
    let $model :=         
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest-items(8,2,2)}
        </latests>
    return
        (: All Working Papers have to be  between today and 3 months ago :)
        for $item in $model/oe:latests/oe:item[@type='workingpaper']/dt:available
        return assert:true($item lt fn:current-dateTime() and $item gt (fn:current-dateTime() - xs:dayTimeDuration('P90D')),"???")
};

declare function test:last-publications-book-if-exist ()
{
    (: a book exists if less than 8 articles and WP are in the last publications list :)
    let $model := "Yes"
    return assert:equal($model, "No","Test to be done ! if a book exists...")
};