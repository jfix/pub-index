xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/search";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $term as xs:string := normalize-space(xdmp:get-request-field("term"));
declare variable $in as xs:string := normalize-space(xdmp:get-request-field("in")); (: serialized filter string :)

declare variable $qtext as xs:string := module:build-qtext($term, $in);
declare variable $start as xs:integer := if(functx:is-a-number(xdmp:get-request-field("start"))) then xs:integer(xdmp:get-request-field("start")) else 1;
declare variable $page-length as xs:integer := if(functx:is-a-number(xdmp:get-request-field("page-length"))) then xs:integer(xdmp:get-request-field("page-length")) else 10;

declare variable $order as xs:string :=
  let $tmporder := normalize-space(xdmp:get-request-field("order"))
  return
    if($tmporder = ('date', 'date-asc', 'title', 'title-desc', 'relevance')) then
      $tmporder
    else if(contains($in,'from:') or contains($in,'to:')) then
      'date'
    else
      'relevance'
;

declare variable $search-options := <options xmlns="http://marklogic.com/appservices/search">
    <constraint name="pubtype">
      <range type="xs:string">
        <path-index xmlns:oe="http://www.oecd.org/metapub/oecdOrg/ns/">/oe:item/@type</path-index>
      </range>
    </constraint>
    <constraint name="country">
      <range type="xs:string">
        <element name="country" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
      </range>
    </constraint>
    <constraint name="topic">
      <range type="xs:string">
        <element name="subject" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <constraint name="language">
      <range type="xs:string">
        <element name="language" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <constraint name="date">
      <range type="xs:dateTime" facet="false">
        <element name="available" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <searchable-expression>collection("searchable")</searchable-expression>
    <term>
      <term-option>unstemmed</term-option>
      <term-option>case-insensitive</term-option>
    </term>
    {
      module:search-order-options()
    }
    <transform-results apply="raw"/>
    <return-facets>false</return-facets>
  </options>;

declare function module:deserializeFilter($inFilter as xs:string)
as xs:string
{
  let $facet := fn:string-join(
    for $t1 in functx:value-except(fn:tokenize($inFilter, ";"),'')
      let $facet := fn:substring-before($t1, ":")
      let $values := fn:substring-after($t1, ":")
      let $values :=
        if($facet eq "from") then
          concat("date GE ", $values, "T23:59:59")
        else if ($facet eq "to") then
          concat("date LE ", $values, "T23:59:59")
        else
          fn:string-join(
            for $t2 in functx:value-except(fn:tokenize($values, "\|"),'')
            return fn:concat($facet,':"',$t2,'"')
            ,' OR '
          )
      return fn:concat('(',$values,')')
      ,' '
  )
  return $facet
};

declare private function module:build-qtext($term, $in)
as xs:string
{
  let $qtext := functx:trim(concat($term, " ", module:deserializeFilter($in)))
  return
    if(contains($qtext, 'date LE ')) then
      $qtext
    else
      concat($qtext, ' ', '(date LE ', current-dateTime(), ')')
};

declare function module:search($qtext as xs:string, $start-from as xs:integer)
as element(search:response)
{
  search:search($qtext, $search-options, $start-from)
};

declare function module:search-order-options()
{
  if($order eq "date") then
    (
      <search:sort-order type="xs:dateTime" direction="descending">
        <search:element ns="http://purl.org/dc/terms/" name="available"/>
      </search:sort-order>
      ,<search:sort-order type="score" direction="descending">
        <search:score/>
      </search:sort-order>
    )
  else if($order eq "date-asc") then
    (
      <search:sort-order type="xs:dateTime" direction="ascending">
        <search:element ns="http://purl.org/dc/terms/" name="available"/>
      </search:sort-order>
      ,<search:sort-order type="score" direction="descending">
        <search:score/>
      </search:sort-order>
    )
  else if ($order eq "title-desc") then
    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending">
      <search:element ns="http://purl.org/dc/terms/" name="title"/>
    </search:sort-order>
  else if ($order eq "title") then
    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending">
      <search:element ns="http://purl.org/dc/terms/" name="title"/>
    </search:sort-order>
  else if ($order eq "relevance") then
    () (: default search:search behavior :)
  else
    fn:error((),"Unsupported order method")
};

declare function module:get-latest($qtb as xs:integer, $qta as xs:integer, $qtw as xs:integer)
as element(oe:item)*
{
    (: Articles: 30 days old max :)
    let $latestArticles := module:get-latest-items('article', $qta, fn:current-dateTime() - xs:dayTimeDuration('P90D') )
    
    (: WP: 30 days old max :)
    let $latestWorkingpapers := module:get-latest-items('workingpaper', $qtw, fn:current-dateTime() - xs:dayTimeDuration('P90D'))
    
    (: Books: no real max date, setting it to 1 year :)
    let $latestBooks := module:get-latest-items(
                            'book', 
                            $qtb + ($qta - count($latestArticles)) + ($qtw - count($latestWorkingpapers)),
                            fn:current-dateTime() - xs:dayTimeDuration('P365D'))
                            
    return (
        $latestBooks
        ,$latestArticles
        ,$latestWorkingpapers
    )
};

declare function module:get-latest-items($item as xs:string, $qt as xs:integer, $maxDate as xs:dateTime)
as element(oe:item)*
{
  (
    for $item in collection($item)/oe:item[
        oe:status = 'available'
        and dt:available lt fn:current-dateTime()               
        and dt:available gt ($maxDate)
      ]
    order by $item/dt:available descending
    return $item
  )[1 to $qt]
};

declare function module:count-items-by-country()
as element(item-frequency)*
{
  for $id in cts:element-values(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/", "country"), "", ("item-frequency"), cts:collection-query(("searchable")))
  return
    <item-frequency ref="{$id}" frequency="{cts:frequency($id)}" />
};

declare function module:get-modified-items($searchable as xs:boolean, $since as xs:dateTime)
as xs:string*
{
  cts:uris((),(),
    cts:and-query((
      if($searchable) then cts:collection-query("searchable") else cts:collection-query("metadata")
      ,cts:properties-query(
        cts:element-range-query(
          xs:QName("prop:last-modified")
          ,">"
          ,$since
        )
      ))
    )
  )
};