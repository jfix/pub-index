xquery version "1.0-ml";

(: $Id$ :)

(:~
 : This module defines functions that can be called to create widgets, such as:
 : * word cloud (implemented)
 : * google map (TODO)
 : * slider thingy (TODO)
 : * ...
 :)
module namespace widgets = "lib-widgets";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
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
declare function widgets:get-word-cloud-data()
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
      let $put := map:put($map, 'url', concat('/browse/topic/', xdmp:url-encode($subject)))
      return $map
  )
  return xdmp:to-json($list)
};

(:~
 : This function needs to be passed to the function that displays
 : a web page (there is a parameter for additional scripts).
 : It also requires the widgets:word-cloud() function to be called a
 : the appropriate place where the word cloud is to be included.
 :)
declare function widgets:word-cloud-scripts()
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
 : to be included.  Also the widgets:word-cloud-scripts() need to be called
 : on that page, so that the script get loaded on that page.
 :
 :)
declare function widgets:word-cloud()
as element(div)
{
  <div class="row">
    <script type='text/javascript'>var word_cloud_list = {widgets:get-word-cloud-data()};</script>
    <div class="twelve columns">
      <div id="wordcloud">
      </div>
    </div>
  </div>
};