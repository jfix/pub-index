xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";

declare function test:last-publications-number-of ()
(: Test: get-latest() :)
(: Description: To be done :)
{
    let $model :=
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest(8,2,2)}
        </latests>
    let $nbBook := fn:count($model/oe:item[@type='book'])
    let $nbArticle := fn:count($model/oe:item[@type='article'])
    let $nbWP := fn:count($model/oe:item[@type='workingpaper'])
    return 
    (
        (: 10 items have to be returned :)
        assert:equal(fn:count($model/oe:item), 12, "The number of last publications should be 12")
        (: 6 <= Nombre of book <= 8 :)
        ,assert:true($nbBook ge 8 and $nbBook le 12, "There are 8 books minimum and 12 books maximum")
        (: 0 <= Nombre of article <= 2 :)
        ,assert:true($nbArticle ge 0 and $nbArticle le 2, "There are 0 article minimum and 2 articles maximum")
        (: 0 <= Nombre of WorkingPaper <= 2 :)
        ,assert:true($nbWP ge 0 and $nbWP le 2, "There are 0 workingpaper minimum and 2 workingpapers maximum")
    )
};

declare function test:last-publications-article-publication-date ()
(: Test: get-latest() :)
(: Description: All Articles have to be between today and 3 months ago :)
{
    let $model :=
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest(8,2,2)}
        </latests>
    return    
        for $item at $i in $model/oe:item[@type='article']/dt:available
        return assert:true($item lt fn:current-dateTime() and $item gt (fn:current-dateTime() - xs:dayTimeDuration('P90D')),"$i - ???")
};

declare function test:last-publications-workingpaper-publication-date ()
(: Test: get-latest() :)
(: Description: All Working Papers have to be between today and 3 months ago :)
{
    let $model :=         
        <latests xmlns="http://www.oecd.org/metapub/oecdOrg/ns/">
            {ms:get-latest(8,2,2)}
        </latests>
    return
        for $item at $i in $model/oe:item[@type='workingpaper']/dt:available
        return assert:true($item lt fn:current-dateTime() and $item gt (fn:current-dateTime() - xs:dayTimeDuration('P90D')),"$i - ???")
};