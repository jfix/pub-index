xquery version "1.0-ml";

(: $Id$ :)

module namespace lib-search = "lib-search";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $start as xs:integer := xs:integer((xdmp:get-request-field("start"), 1)[1]);

declare function lib-search:search-results( 
  $term,
  $start-from
)
{
  let $options :=
  <options xmlns="http://marklogic.com/appservices/search">
    <constraint name="metadata-only">
      <collection prefix="metadata"/>
    </constraint>
    <constraint name="pubtype">
      <range type="xs:string">
        <element name="pubtype" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
      </range>
    </constraint>
    <constraint name="subject">
     <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
        <element ns="http://purl.org/dc/terms/" name="subject"/>
     </range>
   </constraint>
    <transform-results apply="transformed-result" ns="transformed-search" at="/application/xquery/transform.xqy" />
    <return-facets>true</return-facets>
  </options>
  
  let $xslt := document("/application/xslt/search-results.xsl")
  
  let $result := search:search($term, $options, $start-from)
  
  let $_log := xdmp:log(concat("XDMP: ", xdmp:quote($result)))
  
  let $start as xs:integer := data($result/@start)
  let $total as xs:integer := data($result/@total)
  let $time as xs:duration := $result/search:metrics/search:total-time/text()
  let $display-time as xs:double := round-half-to-even(seconds-from-duration($time), 2)
  let $page-length as xs:integer := data($result/@page-length)
  
  (:let $_log := xdmp:log(concat("TOTAL ???? ", $total, " START: ", $start, " PAGE-LENGTH: ", $page-length)):)
  
  let $end as xs:integer := if ($total < $start * $page-length) 
    then $total 
    else $start * $page-length
    
  return if ($term eq "")
    then
      <div class="six columns centered">
        <br/>
        <div class="alert-box">
          Please enter a search term
          <a href="" class="close">&times;</a>
        </div>
      </div>
    else
      (
      lib-search:search-meta($total, $display-time, $start, $page-length, $end)
      ,
      <div class="row">
        <br/>
        {xdmp:xslt-eval($xslt, $result)}
        <br/>
      </div>
      ,
      lib-search:search-meta($total, $display-time, $start, $page-length, $end)
      )
};

(:~
 : Responsible for the display on top and bottom of search results of 
 : some kind of summary information (total, time. paging)
 :
 : @param $total as xs:integer total number of hits
 : @param $display-time as xs:double number of seconds required for search
 : @param $start as xs:integer where current page starts, for example 11 or 21
 : @param $page-length as xs:integer how many items to display (by default: 10)
 : @param $end as xs:integer last item of current page (usually $start + 10, but sometimes also $total)
 : @returns a div element containing the information
 :)
declare function lib-search:search-meta(
  $total as xs:integer,
  $display-time as xs:double,
  $start as xs:integer,
  $page-length as xs:integer,
  $end as xs:integer
)
as element(div)
{
  <div class="row">
    <div class="eight columns">
      {$total} results found in {$display-time} secs, showing {$start} to {$end}. 
    </div>
    <div class="four columns">
      {lib-search:search-paging($start, $page-length, $total, $term)}
    </div>
  </div>

};

declare function lib-search:search-paging(
  $start as xs:integer,
  $page-length as xs:integer,
  $total as xs:integer,
  $term as xs:string
)
{
  let $total-pages := ceiling( $total div $page-length)
  let $next-page := if ($start + $page-length gt $total) then () else $start + $page-length
  let $prev-page := if ($start - $page-length gt 0) then $start - $page-length else ()
  let $curr-page := $start
  return
  
  <div style="float:right;">
      {
        if ($start > 1) then
          <a class="nice small radius blue button" href="/search/{$term}/{number($prev-page)}">&laquo; Previous</a>
        else
          <a class="disabled nice small radius blue button" href="#">&laquo; Previous</a>
        ,
        text { '&#160;' }
        ,
        if ($curr-page < $total-pages) then
          <a class="nice small radius blue button" href="/search/{$term}/{number($next-page)}">Next &raquo;</a>
        else
          <a class="disabled nice small radius blue button" href="#">Next &raquo;</a>
      }
  </div>
};

declare function lib-search:search-paging-pages(
  $curr-page as xs:integer,
  $total-pages as xs:integer,
  $term as xs:string
)
{
  (:different behaviour for different total-pages:
    if <= 10 total pages, display all of them,
    if > 10 total pages, show current plus four on each side 
    
    << [1] 2 3 4 >> 
    << 1 2 3 4 [5] 6 7 8 9 10 >>
    << 1 2 [3] 4 5 ... 23 24 >> 
    << 1 2 3 4 5 ... 21 22 [23] 24  >>
    
    currently just basic paging irrespective of total number:
    :)
    let $from as xs:int :=
      if ($curr-page >= $total-pages - 10)
      then $total-pages - 7
      else

        if ($total-pages > 10) 
        then 
          if ($curr-page <= 4) 
          then 1 
          else $curr-page - 3 
        else 1
      
    let $to as xs:int :=
      if ($curr-page < 10)
      then 9
      else 
      if ($total-pages > 10) 
      then 
        if ($curr-page + 3 >= $total-pages)
        then $total-pages
        else $curr-page + 3 
      else $total-pages
        
    for $i in (1 to $to)
    return 
      if ($i eq $curr-page) then
        <li class='unavailable'><a href='#'>{$i}</a></li>
      else 
        <li><a href="/search/{$term}/{$i}">{$i}</a></li>
};
declare variable $lib-search:page-title as xs:string := if ($term) then concat("Searching for ", $term) else "Search books.oecd.org";
declare variable $lib-search:search-form as node() :=
  <div>
    <form action="/application/xquery/search.xqy" class="nice">
      <input placeholder="Search for publications" type="search" value="{$term}" id="term" name="term" class="medium oversize ui-autocomplete-input align-bottom"/>
    </form>
  </div>;

declare variable $lib-search:search-results as node()+ :=
  <div class="row">
    <div class="twelve columns">
      <h3>searching for '{$term}'</h3>
    </div>
  </div>,
  <div class="row">
    <div class="three columns">
      here go facets
    </div>
    <div class="nine columns">
      {lib-search:search-results($term, $start)}
    </div>
  </div>;

