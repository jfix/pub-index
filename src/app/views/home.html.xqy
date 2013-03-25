xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace hf = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/facets-helper.xqy";
import module namespace ha = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/assets-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $model as node()? external;
declare variable $facets as node()? external;

declare function local:render-latests-widget($items as element()*)
{(
  <h4>Latest publications <small> <a href="/search?term=&amp;in=&amp;start=1">browse all</a></small></h4>,
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
    <div class="carousel-inner">
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
                            
                            <div class="right-side gradient">
                                <p class="publication-date"><strong>{format-dateTime($item/dt:available, '[D] [MNn] [Y]')}</strong></p>
                                
                                <h4>{$bbl/dt:title/string()}</h4>
                                <p><strong>{$bbl/oe:subTitle/text()}</strong></p>
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
    <h4>Did you know that OECD publications cover more than <span class="highlight">two-hundred</span> countries? 
    <br/><small>Explore the map below or browse the country list on the left</small></h4>
   ,<div id="map-container-gm"></div>
)};

declare function local:render-content()
{
  <div class="row">
    <div class="span3">
      { hf:render-facets($facets) }
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
(: GMAP 3 :)
(: key=AIzaSyDYNfnz6BXFos2D24stwobss_RD6GYRj0I&amp; :)
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true&amp;language=en"></script>
        ,ha:script("/assets/js/home.js")
      ))

return
  layout:render($params)
