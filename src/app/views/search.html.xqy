xquery version "1.0-ml";

import module namespace layout = "http://oecd.org/pi/views" at "/app/views/shared/layout.html.xqy";
import module namespace hs = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/search-helper.xqy";
import module namespace hf = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/facets-helper.xqy";
import module namespace ha = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/assets-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace search = "http://marklogic.com/appservices/search";
declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $model as node()? external;
declare variable $facets as node()? external;
declare variable $term := normalize-space(xdmp:get-request-field("term"));


declare variable $qtext as xs:string := $model/search:qtext;
declare variable $total as xs:integer := $model/@total;
declare variable $start as xs:integer := $model/@start;
declare variable $page-length as xs:integer := $model/@page-length;
declare variable $end as xs:integer := min(($page-length + $start - 1, $total));
declare variable $total-time := round-half-to-even(seconds-from-duration($model/search:metrics/search:total-time), 2);

declare private function local:render-results-selected()
as element(div)?
{
  let $html := hf:render-selected-facets($qtext)
  return
    if($html) then
      <div class="row">
        <div class="span9">
          {$html}
        </div>
      </div>
    else
      ()
};

declare private function local:render-results-header()
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
          <select id="sortby" name="sortby" class="input-medium">
          {
            local:get-sort-option('date', 'Date (latest first)')
            ,local:get-sort-option('date-asc', 'Date (oldest first)')
            ,local:get-sort-option('title', 'Title (A-Z)')
            ,local:get-sort-option('title-desc', 'Title (Z-A)')
            ,local:get-sort-option('relevance', 'Relevance')
          }
          </select>
        </label>
      </div>
    </div>
  </div>
};

declare private function local:get-sort-option($value as xs:string, $label as xs:string)
as element(option)
{
  <option value="{$value}">
    {if($hs:order eq $value) then attribute {'selected'} {'selected'} else ()}
    {$label}
  </option>
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
declare function local:render-results-footer()
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
        concat($total, " results found in ", $total-time, " secs, showing ", $start, " to ", $end, ".")
    } 
    </div>
    <div class="span4">
      {local:render-paging()}
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
declare function local:render-paging()
as element(div)
{
  let $prev-page := max(($start - $page-length, 1))
  let $next-page := $start + $page-length
  return
  <div style="float: right;">
    <ul class="pager" style="margin: 0;">
      {
        if ($start > 1) then (: {concat(replace(xdmp:get-original-url(),"&amp;start=\d+",""), "&amp;start=", $prev-page)} :)
          <li><a data-start="{number($prev-page)}" href="#">&laquo; Previous</a></li>
        else
          <li class="disabled"><a href="#">&laquo; Previous</a></li>
        ,
        text { '&#160;' }
        ,
        if ($next-page <= $total) then
          <li><a data-start="{number($next-page)}" href="#">Next &raquo;</a></li>
        else
          <li class="disabled"><a href="#">Next &raquo;</a></li>
      }
    </ul>
  </div>
};

declare function local:render-content()
as element(div)
{
  <div class="row">
    <div class="span3">
      { hf:render-facets($facets) }
    </div>
    <div class="span9">
      { local:render-results-selected() }
      { local:render-results-header() }
      { xdmp:xslt-invoke("/app/views/xslt/search-results.xsl", $model) }
      { local:render-results-footer() }
    </div>
  </div>
};

let $params := map:map(),
        (: title should display normalized query term  if there is one - related to issue #5348 :)
      $void := map:put($params, "title", concat(if (string-length($term) > 0) then concat("Results for '", $term, "'") else ("Search results"), " - OECD publications")   ),
      (: $void := map:put($params, "scripts",(ha:script("/assets/js/app.js")),  -- no specific js for this page :)
      $void := map:put($params, "content", local:render-content())

return
  layout:render($params)
