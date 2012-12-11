xquery version "1.0-ml";

module namespace f = "lib-facets";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace utils = "lib-utils" at "/app/models/utils.xqy";
    
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function f:facets($qtext as xs:string)
as element(search:response)
{
  let $all-facets := search:search("", <options xmlns="http://marklogic.com/appservices/search">
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
    </options>)
  
  return
    <response xmlns="http://marklogic.com/appservices/search">
      <qtext>{$qtext}</qtext>
      {$all-facets/search:facet[@name = 'subject']}
      {$all-facets/search:facet[@name = 'country']}
      {$all-facets/search:facet[@name = 'language']}
      {$all-facets/search:facet[@name = 'pubtype']}
    </response>
};
