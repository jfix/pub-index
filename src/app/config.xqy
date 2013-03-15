xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/config";

declare variable $version as xs:string := "1.0.0";

(: declare variable $cachebusters containing the cachebusters.xml content :)
declare variable $cachebusters as element(cachebusters) :=  
    if(xdmp:filesystem-file-exists(fn:concat(xdmp:modules-root(), "app/cachebusters.xml"))) then
       xdmp:document-get(fn:concat(xdmp:modules-root(), "app/cachebusters.xml"))/cachebusters
    else
       <cachebusters/>
;
