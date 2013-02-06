xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/facets";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";

declare variable $facets-options as element() :=
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
    <constraint name="date">
      <range type="xs:dateTime" facet="false">
        <element name="available" ns="http://purl.org/dc/terms/"/>
      </range>
    </constraint>
    <searchable-expression>collection("searchable")</searchable-expression>
    <return-results>false</return-results>
    <return-facets>true</return-facets>
    <return-metrics>false</return-metrics>
  </options>;

declare function module:facets($qtext as xs:string)
as element(search:response)
{
  let $query := search:parse($qtext, $facets-options)
  
  return
    <response xmlns="http://marklogic.com/appservices/search">
      <qtext>{$qtext}</qtext>
      {module:get-filtered-facet($query, 'subject')}
      {module:get-filtered-facet($query, 'country')}
      {module:get-filtered-facet($query, 'language')}
      {module:get-filtered-facet($query, 'pubtype')}
      {module:get-dates-facet($query)}
    </response>
};

declare private function module:get-filtered-facet($query as element(), $facet as xs:string)
as element(search:facet)
{
  let $query := (module:transform-query($query, concat($facet,':')),<cts:and-query qtextempty="1" xmlns:cts="http://marklogic.com/cts"/>)[1]
  return search:resolve($query, $facets-options)/search:facet[@name = $facet]
};

declare function module:transform-query($elements as element()*, $filter as xs:string)
as element()*
{
  for $element in $elements
  return
    if($element[@qtextempty eq '1']) then
      $element
    else if($element[not(@qtextpre eq $filter)]) then
      let $sub as element()* := module:transform-query($element/*, $filter)
      let $limit as xs:integer := if(local-name($element) = ('and-query','or-query')) then 1 else 0
      return
         if(count($sub) > $limit) then
           element {fn:name($element)} {
           $element/@*,
           $sub
         }
         else if($limit eq 1) then
           $sub
         else
           $element
    else
      ()
};

declare private function module:get-dates-facet($query as element())
{
  (:] good to know, range indexes don't hold time zone value ... AH AH AH AH! >:)
  <search:facet name="date" type="xs:dateTime">
    <search:facet-value name="min">
    {
      cts:min(
        cts:element-reference(fn:QName("http://purl.org/dc/terms/","available"))
        ,()
        ,cts:query(module:transform-query($query, 'date GE '))
        )
    }
    </search:facet-value>
    <search:facet-value name="max">
    {
      cts:max(
        cts:element-reference(fn:QName("http://purl.org/dc/terms/","available"))
        ,()
        ,cts:query(module:transform-query($query, 'date LE '))
        )
    }
    </search:facet-value>
  </search:facet>
};
