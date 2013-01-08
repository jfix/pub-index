xquery version "1.0-ml";

module namespace module = "lib-facets";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace utils = "lib-utils" at "/app/models/utils.xqy";
    
declare default function namespace "http://www.w3.org/2005/xpath-functions";

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
    <searchable-expression>collection("searchable")</searchable-expression>
    <return-results>false</return-results>
    <return-facets>true</return-facets>
    <return-metrics>false</return-metrics>
  </options>;

declare function module:facets($qtext as xs:string)
as element(search:response)
{
  let $query := search:parse($qtext, $facets-options)
  let $all-facets := search:search("", $facets-options)
  
  return
    <response xmlns="http://marklogic.com/appservices/search">
      <qtext>{$qtext}</qtext>
      {module:get-filtered-facet($query, 'subject')}
      {module:get-filtered-facet($query, 'country')}
      {module:get-filtered-facet($query, 'language')}
      {module:get-filtered-facet($query, 'pubtype')}
    </response>
};

declare private function module:get-filtered-facet($query as element(), $facet as xs:string)
as element(search:facet)
{
  let $query := (module:transform-query($query, concat($facet,':')),<cts:and-query qtextempty="1" xmlns:cts="http://marklogic.com/cts"/>)[1]
  return search:resolve($query, $facets-options)/search:facet[@name = $facet]
};

declare private function module:transform-query($element as element(), $filter as xs:string)
as element()?
{
  let $sub as element()* := for $el in $element/*[not(@qtextpre = $filter)] return module:transform-query($el, $filter)
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
};

