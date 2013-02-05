xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/search";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $in as xs:string := (xdmp:get-request-field("in"), '')[1]; (: serialized filter string :)

declare variable $qtext as xs:string := functx:trim(concat($term, " ", module:deserializeFilter($in)));
declare variable $start as xs:integer := if(functx:is-a-number(xdmp:get-request-field("start"))) then xs:integer(xdmp:get-request-field("start")) else 1;
declare variable $page-length as xs:integer := if(functx:is-a-number(xdmp:get-request-field("page-length"))) then xs:integer(xdmp:get-request-field("page-length")) else 10;
declare variable $order as xs:string := xdmp:get-request-field("order");

declare variable $search-options := <options xmlns="http://marklogic.com/appservices/search">
    <constraint name="pubtype">
      <range type="xs:string">
        <element name="item" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
        <attribute ns="" name="type"/>
      </range>
    </constraint>
    <constraint name="country">
      <range type="xs:string">
        <element name="country" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
      </range>
    </constraint>
    <constraint name="subject">
      <range type="xs:string">
        <element name="subject" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <constraint name="language">
      <range type="xs:string">
        <element name="language" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <searchable-expression>collection("searchable")</searchable-expression>
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

declare function module:search($qtext as xs:string, $start-from as xs:integer)
as element(search:response)
{
  search:search($qtext, $search-options, $start-from)
};

declare function module:search-order-options()
{
  if($order eq "date-asc") then
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
    (
      <search:sort-order type="xs:dateTime" collation="http://marklogic.com/collation/" direction="descending">
        <search:element ns="http://purl.org/dc/terms/" name="available"/>
      </search:sort-order>
      ,<search:sort-order type="score" direction="descending">
        <search:score/>
      </search:sort-order>
    )
};

declare function module:get-latest-items($qtb as xs:integer, $qta as xs:integer, $qtw as xs:integer)
as element(oe:item)*
{
  let $ia := module:get-latest-items('article', $qta)
  let $iw := module:get-latest-items('workingpaper', $qtw)
  return (
    module:get-latest-items('book', $qtb + ($qta - count($ia)) + ($qtw - count($iw)))
    ,$ia
    ,$iw
  )
};

declare function module:get-latest-items($item as xs:string, $qt as xs:integer)
as element(oe:item)*
{
  (
    for $item in collection($item)/oe:item[
        oe:status = 'available'
        and dt:available lt fn:current-dateTime()
        and dt:available gt (fn:current-dateTime() - xs:dayTimeDuration('P30D'))
        and fn:exists(oe:coverImage)
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

