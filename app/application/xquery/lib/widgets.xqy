xquery version "1.0-ml";

(: $Id: lib-widgets.xqy 33 2012-05-06 22:18:09Z Fix_J $ :)

(:~
 : This module defines functions that can be called to create widgets, such as:
 : * word cloud (implemented)
 : * google map (TODO)
 : * slider thingy (TODO)
 : * ...
 :)
module namespace w = "lib-widgets";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace cc = "country-data";

declare default collation "http://marklogic.com/collation/";

(:~
 : This function queries the database and returns a json list of objects that can 
 : be used directly by jqcloud.
 :
 : Right now this is not generic, but queries only for subjects.
 :
 : need to return a json structure like this:
 : {text: "Ipsum", weight: 9, url: "http://jquery.com/", title: "I can haz URL"},
 : {text: "Ipsum", weight: 9, url: "http://jquery.com/", title: "I can haz URL"},
 :
 :)
declare function w:get-word-cloud-data()
{
  let $subjects := cts:element-values(
    fn:QName("http://purl.org/dc/terms/", "subject"),"", ("item-frequency"), 
    cts:collection-query(("metadata"))
  )

  let $list := (
    for $subject in $subjects
      let $freq := cts:frequency($subject)
      let $map := map:map()
      let $put := map:put($map, 'weight', $freq)
      let $put := map:put($map, 'text', $subject)
      let $put := map:put($map, 'title', concat("There are ", $freq, " publications on ", $subject))
      let $put := map:put($map, 'url', concat('/browse/subject/', xdmp:url-encode($subject)))
      (:let $put := map:put($map, 'url', concat('/application/xquery/search.xqy?term=subject:&quot;', xdmp:url-encode($subject), "&quot;")):)
      return $map
  )
  return xdmp:to-json($list)
};


(:~
 : This function needs to be passed to the function that displays
 : a web page (there is a parameter for additional scripts).
 : It also requires the w:word-cloud() function to be called a
 : the appropriate place where the word cloud is to be included.
 :)
declare function w:word-cloud-scripts()
as element(script)+
{
  (
  <script type="text/javascript" src="/application/jquery/jqcloud-0.2.10.min.js"/>,
  <script type="text/javascript">
    $(document).ready(function() {{
        $("#wordcloud").jQCloud(word_cloud_list, {{delayedMode: true, shape: "elliptic"}});
      }});
  </script>
  )
};

(:~
 : This function needs to be called on the page where you want the word cloud
 : to be included.  Also the w:word-cloud-scripts() need to be called
 : on that page, so that the script get loaded on that page.
 :
 :)
declare function w:word-cloud()
as element(div)
{
  <div class="row">
    <script type='text/javascript'>var word_cloud_list = {w:get-word-cloud-data()};</script>
    <div class="twelve columns">
      <div id="wordcloud">
      </div>
    </div>
  </div>
};

declare function w:map-data()
{
  let $doc := document("/assets/mappings/countries.xml")
  let $countries := cts:element-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/", "country"),"", ("item-frequency"), 
    cts:collection-query(("metadata")))
  
  let $list := (
    for $country in $countries
    
    let $coords := xs:double($doc//cc:country[cc:code = upper-case($country)]/cc:coords/cc:centred/cc:*)    
    let $freq := cts:frequency($country)
    let $map := map:map()
    let $put := map:put($map, 'center', $coords)
    let $put := map:put($map, 'radius', $freq * 1000)
    let $put := map:put($map, "fillColor", "#018FD1")
    let $put := map:put($map, "strokeColor", "#018FD1")
    let $put := map:put($map, "strokeWeight", "1")
    let $put := map:put($map, "action", "addCircle")
    (:order by $freq descending:)
    return $map
  )
  let $json := xdmp:to-json($list)
  let $length := string-length($json)
  return substring( substring($json, 2), 1, ($length - 2))
};

declare function w:map-scripts()
as element(script)+
{
  (
  <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>,
  <script type="text/javascript" src="/application/jquery/gmap3.min.js"></script>,
  <script type="text/javascript">
    $(document).ready(function() 
    {{
        $("#map").gmap3(
          {{
            action: 'init',
            options: {{
              mapTypeId: google.maps.MapTypeId.TERRAIN
             }}
          }},

        {w:map-data()}
        );
    }});
  </script>
  )
};