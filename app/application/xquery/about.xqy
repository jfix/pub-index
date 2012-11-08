xquery version "1.0-ml";

(: $Id: home.xqy 37 2012-05-10 08:39:00Z Fix_J $ :)

import module namespace v = "lib-view" at "lib/view.xqy";
import module namespace b = "lib-browse" at "lib/browse.xqy";
import module namespace s = "lib-search" at "lib/search.xqy";
import module namespace w = "lib-widgets" at "lib/widgets.xqy";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

let $content := 
<div class="row">
  <div class="span12">
    <h3>about</h3>
    <p>This is a catalogue of all OECD publications.</p>
  </div>
</div>

return
v:html-about-page(
  "About OECD publications",
  (),
  $content,
  "","","",1)
    


