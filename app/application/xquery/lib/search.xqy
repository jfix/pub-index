xquery version "1.0-ml";

(: $Id$ :)

module namespace lib-search = "lib-search";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace lib-facets = "lib-facets" 
    at "facets.xqy";
import module namespace utils = "lib-utils"
    at "utils.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $in as xs:string := (xdmp:get-request-field("in"), '')[1]; (: serialized filter string :)

declare variable $qtext as xs:string := functx:trim(concat($term, " ", lib-search:deserializeFilter($in)));
declare variable $start as xs:integer := if(functx:is-a-number(xdmp:get-request-field("start"))) then xs:integer(xdmp:get-request-field("start")) else 1;
declare variable $page-length as xs:integer := if(functx:is-a-number(xdmp:get-request-field("page-length"))) then xs:integer(xdmp:get-request-field("page-length")) else 10;

declare variable $lib-search:search-script as element(script) :=
<script type="text/javascript">
  $(document).ready(function() {{
    $(".pager a").click(function() {{
      var start = $(this).data("start");
      if(start) {{
        $("#start").val(start);
        $("#searchForm").submit();
      }}
    }});
  }});
</script>;

declare function lib-search:deserializeFilter($inFilter as xs:string)
as xs:string
{
  let $facet := fn:string-join(
    for $t1 in functx:value-except(fn:tokenize($inFilter, ";"),'')
      let $facet := fn:substring-before($t1, ":")
      let $values := fn:substring-after($t1, ":")
      let $values := fn:string-join(
        for $t2 in functx:value-except(fn:tokenize($values, "\|"),'')
        return fn:concat($facet,':"',$t2,'"')
        ,' OR '
      )
      return fn:concat('(',$values,')')
      ,' '
  )
  return $facet
};

declare function lib-search:search( 
  $qtext as xs:string,
  $start-from as xs:integer
) as element(search:response)
{
  search:search($qtext, document("/config/search/default.xml")/search:options, $start-from)
};

declare function lib-search:search-results( 
  $qtext as xs:string,
  $start-from as xs:integer
) as element(div)+
{
  let $result := lib-search:search($qtext, $start-from)
  let $_log := utils:log(concat("XDMP: ", xdmp:quote($result)))
  
  let $start as xs:integer := data($result/@start)
  let $total as xs:integer := data($result/@total)
  let $time as xs:duration := $result/search:metrics/search:total-time/text()
  let $display-time as xs:double := round-half-to-even(seconds-from-duration($time), 2)
  let $page-length as xs:integer := data($result/@page-length) 
  
  let $end as xs:integer := if ($total < $start + $page-length) 
    then $total 
    else $start + $page-length - 1
    
  return
      (
        let $html := lib-facets:render-selected-facets($qtext)
        return
          if($html) then
            <div class="row">
              <div class="span9">
                {$html}
              </div>
            </div>
          else
            ()
      ,
      lib-search:render-results-header($total, $start, $end)
      ,
      <div class="row">
        <div class="span9">
          {xdmp:xslt-invoke("/application/xslt/search-results.xsl", $result)}
        </div>
      </div>
      ,
      lib-search:render-results-footer($total, $display-time, $start, $page-length, $end)
      )
};

declare private function lib-search:render-results-header(
  $total as xs:integer,
  $start as xs:integer,
  $end as xs:integer
)
as element(div)
{
  <div class="row">
    <div class="span9">
      <div id="search-results-header">
        {
          if ($total < 1) then
            "No results found."
          else
          if ($total = 1) then
            "One result found."
          else
            concat($total, " results found, showing ", $start, " to ", $end, ".")
        }
        <label for="sortby" class="pull-right">Sort by:
          <select id="sortby" class="input-medium">
            <option value="date" selected="selected">Date (latest first)</option>
            <option value="date">Date (oldest first)</option>
            <option value="title">Title (A-Z)</option>
            <option value="title">Title (Z-A)</option>
            <option value="lang">Language (a-z)</option>
            <option value="lang">Language (z-a)</option>
          </select>
        </label>
      </div>
    </div>
  </div>
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
declare function lib-search:render-results-footer(
  $total as xs:integer,
  $display-time as xs:double,
  $start as xs:integer,
  $page-length as xs:integer,
  $end as xs:integer
)
as element(div)
{
  <div class="row" style="margin-bottom: 10px;">
    <div class="span5">
    {
      if ($total < 1) then
        "No results found."
      else
      if ($total = 1) then
        "One result found."
      else
        concat($total, " results found in ", $display-time, " secs, showing ", $start, " to ", $end, ".")
    } 
    </div>
    <div class="span4">
      {lib-search:search-paging($start, $page-length, $total, $term)}
    </div>
  </div>
};

(:~
 : Provides a div that contains the previous / next buttons for search results/browse pages
 :
 : @param $start as xs:integer, the index in the list of results where to start showing results
 : @param $page-length as xs:integer, the number of results to show on one page, default 10
 : @param $total as xs:integer, total numer of results
 : @param $term as xs:string, the actual search expression (as submitted to MarkLogic, may need some
 :                            prettying up
 : @returns element(div) the div containing the buttons
 :)
declare function lib-search:search-paging(
  $start as xs:integer,
  $page-length as xs:integer,
  $total as xs:integer,
  $term as xs:string
) as element(div)
{
  let $next-page := if ($start + $page-length gt $total) then () else $start + $page-length
  let $prev-page := if ($start - $page-length gt 0) then $start - $page-length else ()
  return
  <div style="float: right;">
    <ul class="pager" style="margin: 0;">
      {
        if ($start > 1) then
          <li><a data-start="{number($prev-page)}" href="#">&laquo; Previous</a></li>
        else
          <li class="disabled"><a href="#">&laquo; Previous</a></li>
        ,
        text { '&#160;' }
        ,
        if ($start < $total) then
          <li><a data-start="{number($next-page)}" href="#">Next &raquo;</a></li>
        else
          <li class="disabled"><a href="#">Next &raquo;</a></li>
      }
    </ul>
  </div>
};

declare function lib-search:search-paging-pages(
  $curr-page as xs:integer,
  $total-pages as xs:integer,
  $term as xs:string
) as element(li)
{
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

declare variable $lib-search:page-title as xs:string := if ($qtext) then concat("Searching for ", $qtext) else "Search books.oecd.org";

(:~
 : Provides access to the search form
 :
 :)
declare variable $lib-search:search-form as node() :=
    <form action="/search" method="get" name="searchForm" id="searchForm">
      <input placeholder="Search for publications" type="search" value="{$term}" id="term" name="term" class=""/>
      <input type="hidden" id="in" name="in" value="{$in}"/>
      <input type="hidden" id="start" name="start" value="1"/>
      <input type="hidden" id="page-length" name="page-length" value="10"/>
    </form>;

(:~
 : Returns search results displayable as html
 :
 :)
declare variable $lib-search:search-results as node()+ :=
  <div class="row">
    <div class="span3">
      {lib-facets:facets($qtext, $start, $page-length)}
    </div>
    <div class="span9">
      {lib-search:search-results($qtext, $start)}
    </div>
  </div>;

