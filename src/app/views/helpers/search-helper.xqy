xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views/helpers";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $in as xs:string := (xdmp:get-request-field("in"), '')[1]; (: serialized filter string :)

declare function module:render-search-form()
{
  <form action="/search" method="get" name="searchForm" id="searchForm">
    <input placeholder="Search for publications" type="search" value="{$term}" id="term" name="term" class=""/>
    <input type="hidden" id="in" name="in" value="{$in}"/>
    <input type="hidden" id="start" name="start" value="1"/>
  </form>
};

declare function module:render-pager()
{
  <div></div>
};