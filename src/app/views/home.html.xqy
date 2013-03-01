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
  <h3>Latest publications <small> <a href="/search?term=&amp;in=&amp;start=1">browse all</a></small></h3>,
  <div id="latest" class="carousel slide">
  
    <!-- the list of little circles to indicate the available carousel items -->
    <ol class="carousel-indicators">
    {
        for $i in (1 to count($items)) 
        return
            <li data-target="#latest" data-slide-to="{$i}"></li>
    }
    </ol>
    
    <!-- Carousel items -->
    <div class="carousel-inner with-border">
      {
        for $item at $idx in $items
        return
            <div class="{if ($idx eq 1) then 'item active' else 'item'}">                
                {
                    let $uri as xs:string? :=
                      if($item/@type eq ('book')) 
                      then
                        concat('/display/', data($item/dt:identifier))
                      else
                        $item/oe:link[@type eq 'doi']/@rdf:resource
                    
                    let $bbl := ($item/oe:bibliographic[@xml:lang eq 'en'],$item/oe:bibliographic)[1]
                    return 
                    
                        <a href="{$uri}">
                            <div class="left-side" style="background-image: url(http://images.oecdcode.org/covers/340/{($item/oe:coverImage, 'cover_not_yetm.jpg')[1]})">
                            </div>
                            
                            <div class="right-side">
                                <h4>{$bbl/dt:title/string()}</h4>
                                <p><strong>{$bbl/oe:subTitle/text()}</strong></p>
                                <br/>
                                <p>{format-dateTime($item/dt:available, '[D] [MNn] [Y]')}</p>
                                <br/>
                                <p class="abstract">{
                                    let $abstract := $bbl/dt:abstract/string()
                                    return
                                        if (string-length($abstract) gt 380)
                                        then
                                            concat(substring($abstract, 1, 380), " ...")
                                        else
                                            $abstract
                                }</p>
                            </div>
                        </a>

                }
                
        </div>
       }
    </div>
    <!-- Carousel nav -->
    <a class="carousel-control left" href="#latest" data-slide="prev">&lsaquo;</a>
    <a class="carousel-control right" href="#latest" data-slide="next">&rsaquo;</a>
  </div>
)};

declare function local:render-countries-widget()
{(
  <h3>Browse by country <small>click on an icon to see related publications</small></h3>,
  <div id="map-container-gm"></div>,
  <!--<div id="map-container"></div>-->
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
      $void := map:put($params, "title", "OECD publications"),
      $void := map:put($params, "content", local:render-content()),
      $void := map:put($params, "scripts", (
        <link rel="stylesheet" href="/assets/jquery/ui/themes/cupertino/jquery-ui-1.9.2.custom.min.css" />
        ,<script type="text/javascript" src="/assets/jquery/ui/jquery-ui-1.9.2.custom.min.js"></script>

        ,<link rel="stylesheet" href="/assets/js/qtip/jquery.qtip.css" />

        ,<script type="text/javascript" src="/assets/js/oecd-facets.js"></script>

(: D3 MAP :)
        (:,<script type="text/javascript" src="/assets/js/qtip/jquery.qtip.js"></script>
        ,<link rel="stylesheet" href="/assets/css/map.css" />
        ,<script type="text/javascript" src="/assets/js/map/d3.v3.js"></script>
        ,<script type="text/javascript" src="/assets/js/map/d3.geo.projection.v0.min.js"></script>
        ,<script type="text/javascript" src="/assets/js/map/topojson.v0.min.js"></script>
        ,<script type="text/javascript" src="/assets/js/map/underscore.js"></script>
        ,<script type="text/javascript" src="/assets/js/map/watch.js"></script>
        ,<script type="text/javascript" src="/assets/js/map/chart-component.js"></script>:)

(: GMAP 3 :)
(: key=AIzaSyDYNfnz6BXFos2D24stwobss_RD6GYRj0I&amp; :)
        ,<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true&amp;language=en"></script>
        (:,<script type="text/javascript" src="/assets/js/gmap3.js"></script>:)
        ,<script type="text/javascript" src="https://google-maps-utility-library-v3.googlecode.com/svn/trunk/infobox/src/infobox_packed.js"></script>
        ,<script type="text/javascript" src="https://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclustererplus/src/markerclusterer_packed.js"></script>
        ,<script type="text/javascript" src="/assets/js/oecd-map.js"></script>


        
      ))

return
  layout:render($params)
