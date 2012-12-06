xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace fh = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/facets-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace ex = "exhibit";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $model as node()? external;
declare variable $facets as node()? external;

declare function local:render-latests-widget($items as element()*)
{(
  <h3>Latest arrivals</h3>,
  <div id="latest" class="carousel slide well">
    <!-- Carousel items -->
    <div class="carousel-inner">
      {
        for $b at $i in $items
        return
          if($i mod 4 eq 1) then
            <div>
              { attribute class { if($i eq 1) then "item active" else "item" } }
              <ul>
                {
                  for $book in $items[$i to $i+3]
                  return
                    <li><a href="/display/{$book/dt:identifier}" title="{$book/dt:title}">
                      <img src="http://images.oecdcode.org/covers/100/{$book/oe:coverImage}" alt=""/>
                    </a></li>
                }
              </ul>
            </div>
          else
            ()
       }
    </div>
    <!-- Carousel nav -->
    <a class="carousel-control left" href="#latest" data-slide="prev">&lsaquo;</a>
    <a class="carousel-control right" href="#latest" data-slide="next">&rsaquo;</a>
  </div>
)};

declare function local:render-countries-widget()
{(
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
  </div>
)};

declare function local:render-content()
{
  <div class="row">
    <div class="span3">
      { fh:render-facets($facets) }
    </div>
    <div class="span9">
      { local:render-latests-widget($model/*) }
      <hr/>
      { local:render-countries-widget() }
    </div>
  </div>
};

let $params := map:map(),
      $void := map:put($params, "title", "Welcome to OECD publications"),
      $void := map:put($params, "header",(
        <link href="/app/actions/pubs-country.xqy" type="application/json" rel="exhibit/data" />,
        <script src="http://api.simile-widgets.org/exhibit/2.2.0/exhibit-api.js"></script>,
        <script src="http://api.simile-widgets.org/exhibit/2.2.0/extensions/map/map-extension.js?gmapkey=AIzaSyBy0k-I0Xq-QvHvQRQXvmj7cUu6X40cB6Y"></script>
      )),
      $void := map:put($params, "content", local:render-content())

return
  layout:render($params)
