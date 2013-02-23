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
  <h3>Latest publications <small> <a href="/search?term=&amp;in=&amp;start=1&amp;order=">browse all</a></small></h3>,
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
            <div class="{if ($idx = 1 then 'item active' else 'item'}">                
                {
                    let $uri as xs:string? :=
                      if($item/@type eq ('book')) 
                      then
                        concat('/display/', data($item/dt:identifier))
                      else
                        $item/oe:link[@type eq 'doi']/@rdf:resource
                    
                    let $bbl := ($item/oe:bibliographic[@xml:lang eq 'en'],$item/oe:bibliographic)[1]
                }
                
                <a href="{$uri}">
                    <div class="left-side" style="background-image(http://images.oecdcode.org/covers/340/{($item/oe:coverImage, 'cover_not_yetm.jpg')[1]})">
                    </div>
                    
                    <div class="right-side">
                        <h4>{$bbl/dt:title}</h4>
                        <p>subtitle, pub date, start of abstract to come.</p>
                    </div>
                </a>
(:             <!--<ul>
                {
                  for $item in $items[$idx to $idx+3]
                    let $uri as xs:string? :=
                      if($item/@type eq ('book')) then
                        concat('/display/', data($item/dt:identifier))
                      else
                        $item/oe:link[@type eq 'doi']/@rdf:resource
                    let $bbl := ($item/oe:bibliographic[@xml:lang eq 'en'],$item/oe:bibliographic)[1]
                    return
                      <li><a href="{$uri}" title="{$bbl/dt:title}">
                        <img src="http://images.oecdcode.org/covers/100/{($item/oe:coverImage, 'cover_not_yetm.jpg')[1]}" alt=""/>
                      </a></li>
                }
              </ul>-->
:)
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
  <h3>Browse by country</h3>,
  <div id="map-container">
   
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
      $void := map:put($params, "title", "OECD publications"),
      $void := map:put($params, "content", local:render-content()),
      $void := map:put($params, "scripts", (
        <link rel="stylesheet" href="/assets/jquery/ui/themes/cupertino/jquery-ui-1.9.2.custom.min.css" />
        ,<script src="/assets/jquery/ui/jquery-ui-1.9.2.custom.min.js"></script>
        ,<script src="/assets/js/oecd-facets.js"></script>
        ,<script src="/assets/js/d3.v3.min.js"></script>
        ,<script src="/assets/js/topojson.v0.min.js"></script>
        ,<script src="/assets/js/oecd-map.js"></script>
        
      ))

return
  layout:render($params)
