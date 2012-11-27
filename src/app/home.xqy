xquery version "1.0-ml";

(: $Id$ :)

import module namespace v = "lib-view" at "lib/view.xqy";
import module namespace s = "lib-search" at "lib/search.xqy";
import module namespace w = "lib-widgets" at "lib/widgets.xqy";
import module namespace f = "lib-facets" at "lib/facets.xqy";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace ex = "exhibit";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $homepage-scripts as element(script)* :=
  (w:map-scripts())
;

declare function local:slider-thingy()
{
  <h3>Latest arrivals</h3>,
  <a href="/latest">
    <img style="border: 0" src="http://placehold.it/980x400&amp;text=slider thingy here"/>
  </a>
  ,<hr/>
};

declare function local:google-map()
{
  <h3>Browse by country</h3>,
  <div id="map-container">
      <div ex:role="coder" 
        ex:coderClass="SizeGradient" 
        id="pub-coder"
        ex:color="green"
        ex:gradientPoints="1, 10; 1000, 100" >
      </div>
      <div ex:role="view"
        ex:viewClass="Map"
        ex:type="satellite"
        ex:label="Cities"
        ex:latlng=".latlng"
        ex:sizeKey=".publications"
        ex:sizeCoder="pub-coder"
        ex:sizeLegendLabel="publications"
        ex:zoom="2"
        ex:mapHeight="500"
        ex:showHeader="false"
        ex:showFooter="false"
        ex:showSummary="false"
        ex:showToolbox="false"
        >
        <!-- custom popup when circle clicked -->
        <div class="map-lens" ex:role="lens" style="display: none;">
            <a ex:href-content=".url">
              <span ex:content=".publications"></span> publication(s) on <b ex:content=".label"></b>
            </a>
        </div>
      </div>
    </div>,
    <hr/>
};

let $content := 
<div class="row">
  <div class="span3">
    {f:facets("", 1, 10)}
  </div>
  <div class="span9">
    <h3>Latest arrivals</h3>
    {w:latest()}
    <hr/>
    {local:google-map()}
  </div>
</div>

return
v:html-home-page(
  "Welcome to OECD publications",
  (
    <link href="/app/pubs-country.xqy" type="application/json" rel="exhibit/data" />,
    <script src="http://api.simile-widgets.org/exhibit/2.2.0/exhibit-api.js"></script>,
    <script src="http://api.simile-widgets.org/exhibit/2.2.0/extensions/map/map-extension.js?gmapkey=AIzaSyBy0k-I0Xq-QvHvQRQXvmj7cUu6X40cB6Y"></script>
  ),
  $homepage-scripts,
  $content,
  "","","",1)

