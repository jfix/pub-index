xquery version "1.0-ml";

module namespace lib-search = "lib-search";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace utils = "lib-utils" at "/app/models/utils.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

declare variable $term as xs:string := (xdmp:get-request-field("term"), '')[1];
declare variable $in as xs:string := (xdmp:get-request-field("in"), '')[1]; (: serialized filter string :)

declare variable $qtext as xs:string := functx:trim(concat($term, " ", lib-search:deserializeFilter($in)));
declare variable $start as xs:integer := if(functx:is-a-number(xdmp:get-request-field("start"))) then xs:integer(xdmp:get-request-field("start")) else 1;
declare variable $page-length as xs:integer := if(functx:is-a-number(xdmp:get-request-field("page-length"))) then xs:integer(xdmp:get-request-field("page-length")) else 10;

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
  search:search($qtext
    ,
    <options xmlns="http://marklogic.com/appservices/search">
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
        <sort-order type="xs:dateTime" collation="http://marklogic.com/collation/" direction="descending">
            <element ns="http://purl.org/dc/terms/" name="available"/>
        </sort-order>
        <sort-order type="score" direction="ascending">
            <score/>
        </sort-order>
        <transform-results apply="raw"/>
    </options>
    ,$start-from)
};

declare function lib-search:get-latest-items($qtb as xs:integer, $qta as xs:integer, $qtw as xs:integer)
as element(oe:item)*
{
  let $ia := lib-search:get-latest-items('article', $qta)
  let $iw := lib-search:get-latest-items('workingpaper', $qtw)
  return (
    lib-search:get-latest-items('book', $qtb + ($qta - count($ia)) + ($qtw - count($iw)))
    ,$ia
    ,$iw
  )
};

declare function lib-search:get-latest-items($item as xs:string, $qt as xs:integer)
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
