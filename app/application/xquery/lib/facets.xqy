xquery version "1.0-ml";

(: $Id$ :)

module namespace f = "lib-facets";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace country = "country-data";

declare variable $term as xs:string := (xdmp:get-request-field("query"), '')[1];
declare variable $start as xs:integer := xs:integer((xdmp:get-request-field("start"), 1)[1]);
declare variable $page-length as xs:integer := xs:integer((xdmp:get-request-field("page-length"), 10)[1]);

(:~
 :
 :
 :
 :)
declare function f:facets(
  $term as xs:string,
  $start as xs:integer,
  $page-length as xs:integer
)
{
  let $options := document("/application/xquery/options/facets-no-results.xml")/search:options
  let $result as element(search:response) := search:search($term, $options, $start)
  let $_log := xdmp:log(concat("------ START FACETS --------:", xdmp:quote($result), "------ END FACETS --------:"))
  
  return f:transform-facet-results( $result, $term)
  
};

(:~
 :
 :
 :
 :)
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
    (: the following only works because by chance the facets are named in the right descending order ... :)
    order by $facet-name descending
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
                <a href="{f:create-facet-link($term, $facet-name, $code)}">
                    <img class="flag" src="/assets/images/flags/16/{$code}.png" 
                        title="{$name} has {$count} publications"/>
                </a>
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
                href="{f:create-facet-link($term, xs:string($facet-name), $value/@name)}"
                title="There are {$count} {$name}">{$name}</a> ({$count})
              </li>
          }
          </ul>
        </div>
};

(:~
 : Returns URL (its path component) to restrict search to a particular facet
 :
 :
 :)
declare function f:create-facet-link
(
    $term as xs:string, 
    $facet-name as xs:string, 
    $facet-value as xs:string
) as xs:string
{
    let $quoted-value := if (contains($facet-value, ' ')) then concat('"', $facet-value, '"') else $facet-value
    return
        concat("/application/xquery/search.xqy?term=", concat($term, " ", $facet-name, ":", $quoted-value) )
};