xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib-view.xqy";
import module namespace b = "lib-browse" at "lib-browse.xqy";
import module namespace s = "lib-search" at "lib-search.xqy";
import module namespace w = "lib-widgets" at "lib-widgets.xqy";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";


declare function local:slider-thingy()
{
  <h3>latest arrivals</h3>,
  <img src="http://placehold.it/980x400&amp;text=slider thingy here"/>
  ,<hr/>
};

declare function local:word-cloud()
{
  <h3>browse by theme</h3>,
  w:word-cloud(),
  <hr/>
};

declare function local:google-map()
{
  <h3>browse by country (google map)</h3>,
  <img src="http://placehold.it/980x500&amp;text=map to select publications by country"/>,
  <hr/>
};



let $content := 
<div class="row">
  <div class="twelve columns">
    {local:slider-thingy()}
    {local:word-cloud()}
     {local:google-map()}
  </div>
</div>

return
v:html-home-page(
  "OECD publications",
  w:word-cloud-scripts(),
  $content,
  "","","",1)
    


