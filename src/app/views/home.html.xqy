xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace fh = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/facets-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace ex = "exhibit";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $model as node()? external;
declare variable $facets as node()? external;

declare function local:render-latests-widget($items as element()*)
{(
  <h3>Latest publications <small> <a href="/search?term=&amp;in=&amp;start=1&amp;order=">browse them all</a></small></h3>,
  <div id="latest" class="carousel slide well">
    <!-- Carousel items -->
    <div class="carousel-inner">
      {
        for $item at $idx in $items
        return
          if($idx mod 4 eq 1) then
            <div>
              { attribute class { if($idx eq 1) then "item active" else "item" } }
              <ul>
                {
                  for $item in $items[$idx to $idx+3]
                    let $uri-id as xs:string :=
                      if($item/@type = ('book','edition')) then
                        data($item/dt:identifier)
                      else
                        ($item/oe:relation[@type=('journal','series')]/@rdf:resource, data($item/dt:identifier))[1]
                    let $bbl := ($item/oe:bibliographic[@xml:lang eq 'en'],$item/oe:bibliographic)[1]
                    return
                      <li><a href="/display/{$uri-id}" title="{$bbl/dt:title}">
                        <img src="http://images.oecdcode.org/covers/100/{$item/oe:coverImage}" alt=""/>
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
    <!-- temporary replacing simile widget with a place holder image -->
    <img src="http://placehold.it/700x500&amp;text=map to select publications by country"/>
    <!--
      (:<div ex:role="coder" 
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
      <div class="map-lens" ex:role="lens" style="display: none;">
          <a ex:href-content=".url">
            <span ex:content=".publications"></span> publication(s) on <b ex:content=".label"></b>
          </a>
      </div>
    </div>:)-->
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
      $void := map:put($params, "content", local:render-content()),
      $void := map:put($params, "scripts", (
        <link rel="stylesheet" href="/assets/jquery/ui/themes/cupertino/jquery-ui-1.9.2.custom.min.css" />
        ,<script src="/assets/jquery/ui/jquery-ui-1.9.2.custom.min.js"></script>
        ,<script src="/assets/js/oecd-facets.js"></script>
      ))

return
  layout:render($params)
