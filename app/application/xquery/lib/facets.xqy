xquery version "1.0-ml";

(: $Id$ :)

module namespace f = "lib-facets";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace country = "country-data";

declare variable $term as xs:string := (xdmp:get-request-field("query"), '')[1];
declare variable $start as xs:integer := xs:integer((xdmp:get-request-field("start"), 1)[1]);
declare variable $page-length as xs:integer := xs:integer((xdmp:get-request-field("page-length"), 10)[1]);

declare function f:facets(
  $term as xs:string,
  $start as xs:integer,
  $page-length as xs:integer
)
{
  let $options := document("/application/xquery/options/facets-no-results.xml")/search:options
(:    <options xmlns="http://marklogic.com/appservices/search">
      <constraint name="metadata-only">
        <collection prefix="metadata"/>
      </constraint>
      <constraint name="pubtype">
        <range type="xs:string">
          <element name="pubtype" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
        </range>
      </constraint>
      <constraint name="subject">
       <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
          <element ns="http://purl.org/dc/terms/" name="subject"/>
       </range>
     </constraint>
     <return-results>false</return-results>
     <return-facets>true</return-facets>
     <return-metrics>false</return-metrics>
    </options>
:)    
  let $result as element(search:response) := search:search($term, $options, $start)
  let $_log := xdmp:log(concat("------ START FACETS --------:", xdmp:quote($result), "------ END FACETS --------:"))
  
  return f:transform-facet-results( $result, $term)
  
};

declare function f:transform-facet-results(
  $facets as element(search:response),
  $term as xs:string
)
{
  let $country-doc := doc("/assets/mappings/countries.xml")
  let $_log := xdmp:log(concat("------ START country doc --------:", xdmp:quote($country-doc/root()), "------ END country doc --------:"))

  return
  for $facet in $facets/search:facet
    let $facet-name := data($facet/@name)
    return  
      if ($facet-name eq "metadata-only") then ()
      
      (: treat countries by displaying their flag :)
      else if ($facet-name eq "country") then
        <div class="row">
          <strong>countries</strong><br/>
          {
            for $country in $facet//search:facet-value
              let $code := data($country/@name)
              let $count := data($country/@count)
              let $_log := xdmp:log("about to log information on country name")
              let $name := $country-doc//country:country[country:code eq upper-case($code)]/country:name/country:en[@case="normal"]
              let $_log := xdmp:log(concat("COUNTRY-NAME: ", $code, ": ", $name))

              order by $country/@count descending 
              return
                <img class="flag" src="/assets/images/flags/16/{$code}.png"
                  title="{$name} has {$count} publications"/>
          }
        </div>
      else
        <div class="row">
          <strong>{$facet-name}</strong>
          <ul>
          {
          for $value in $facet//search:facet-value
            let $name := data($value/@name)
            let $count := data($value/@count)
            order by $value/@count descending 
            return 
              <li style="margin-bottom: 0"><a 
                href="/application/xquery/search.xqy?term={$term} {$facet-name}:{$value}" 
                title="There are {$count} {$name}">{$name}</a> ({$count})
              </li>
          }
          </ul>
        </div>
};


(:

          let $options := 
<search:options xmlns="http://marklogic.com/appservices/search">
    <sort-order type="xs:dateTime" 	collation="http://marklogic.com/collation/" direction="descending">
      <element ns="http://purl.org/dc/terms/" name="available"/>
    </sort-order>
    <sort-order type="score" direction="ascending">
      <score/>
    </sort-order>
</search:options>
return
search:search("", $options)
:)