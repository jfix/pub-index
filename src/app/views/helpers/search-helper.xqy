xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views/helpers";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $term as xs:string := normalize-space(xdmp:get-request-field("term"));
declare variable $in as xs:string := normalize-space(xdmp:get-request-field("in")); (: serialized filter string :)

(: same logic as models/search.xqy :)
declare variable $order as xs:string :=
  let $tmporder := normalize-space(xdmp:get-request-field("order"))
  return
    if($tmporder = ('date', 'date-asc', 'title', 'title-desc', 'relevance')) then
      $tmporder
    else if(string-length($term) > 0 and not(contains($in,'from:') or contains($in,'to:'))) then
      'relevance'
    else
      'date'
;

declare function module:render-search-form()
{
  <form action="/search" method="get" name="searchForm" id="searchForm">
  <div class="input-append">
    <input placeholder="Search for publications" type="search" value="{$term}" id="term" name="term" class="" autocomplete="off"/>
      <button class="btn" type="submit"><i class="icon-search"></i></button>
    </div>
    <input type="hidden" id="in" name="in" value="{$in}"/>
    <input type="hidden" id="start" name="start" value="1"/>
    <input type="hidden" id="order" name="order" value="{normalize-space(xdmp:get-request-field("order"))}"/>
  </form>
};

declare function module:render-pager()
{
  <div></div>
};