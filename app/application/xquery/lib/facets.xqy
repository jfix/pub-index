xquery version "1.0-ml";

(: $Id$ :)

module namespace f = "lib-facets";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace functx = "http://www.functx.com" 
    at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace utils = "lib-utils"
    at "utils.xqy";
    
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace country = "country-data";
declare namespace lang = "language-data";

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
  let $options := document("/config/search/facets-no-results.xml")/search:options
  let $result as element(search:response) := search:search($term, $options, $start)
  (:let $_log := utils:log(concat("------ START FACETS --------:", xdmp:quote($result), "------ END FACETS --------:")):)
  
  return f:transform-facet-results( $result, $term)
  
};

(:~
 :
 :
 :
 :)
declare function f:transform-facet-results(
  $search-response as element(search:response),
  $term as xs:string
) as element(div)+
{
  let $country-doc := doc("/refs/countries.xml")
  let $language-doc := doc("/refs/languages.xml")
  
  let $all-facets := 
    search:search("",
      document("/config/search/facets-no-results.xml")/search:options
    )
  
  let $all-subject-facets as element(search:facet) := $all-facets/search:facet[@name = 'subject']
  let $all-country-facets as element(search:facet) := $all-facets/search:facet[@name = 'country']
  let $all-pubtype-facets as element(search:facet) := $all-facets/search:facet[@name = 'pubtype']
  let $all-language-facets as element(search:facet) := $all-facets/search:facet[@name = 'language']
  
  let $qtext as xs:string := ($search-response//search:qtext/text(), "")[1]
  
  return (
    <div class="main facet">
      <label><input id="filter-summaries" name="filter-summaries" type="checkbox"></input> Include multilingual summaries</label>
      <label><input id="filter-forthcoming" name="filter-forthcoming" type="checkbox"></input> View forthcoming publications</label>
      <div style="display:none;">{$qtext}</div>
    </div>,
    <div class="subject facet">
      <h6>Subjects</h6>
      <ul>
      {
        for $value in $all-subject-facets//search:facet-value
          let $name := data($value/@name)
          let $count := data($value/@count)
          let $css-class := if (contains($qtext, concat('subject:"', $name,'"'))) then 'selected' else ''
          order by $value/@count descending 
          return 
            <li>
              <a class="{$css-class}" 
                href="/subject/{xdmp:url-encode($value/@name)}"
                data-facet="subject"
                data-value="{$value/@name}"
                >{$name}</a> ({$count})
            </li>
      }
      </ul>
    </div>,
    <div class="country facet">
      <select>
        <option value="">Filter by country</option>
      {
        for $country in $all-country-facets//search:facet-value
          let $code := data($country/@name)
          let $count := data($country/@count)
          let $css-class := if (contains($qtext, concat('country:', $code))) then 'selected' else ''
          let $_log := utils:log("about to log information on country name")
          (: TODO: create easy-to-use mapping function resolve("country", code) => Name of country :)
          let $name := $country-doc//country:country[country:code eq upper-case($code)]/country:name/country:en[@case="normal"]
          let $_log := utils:log(concat("COUNTRY-NAME: ", $code, ": ", $name))

          order by $country/@count descending 
          return
            if($name) then <option value="{$code}">{concat($name," (", $count,")")}</option> else ()
      }
      </select>
    </div>,
    <div class="year facet">
      <select>
        <option value="">Filter by year</option>
        <option value="2012">2012</option>
        <option value="2011">2011</option>
        <option value="2010">2010</option>
        <option value="2009">2009</option>
        <option value="2008">2008</option>
      </select>
    </div>,
    <div class="language facet">
      <select>
        <option value="">Filter by language</option>
        {
          for $language in $all-language-facets//search:facet-value
            let $code := data($language/@name)
            let $count := data($language/@count)
            let $name := fn:data($language-doc/lang:*/lang:language[@id = $code])
            order by $language/@count descending 
            return
              if($name) then <option value="{$code}">{concat($name," (", $count,")")}</option> else ()
        }
      </select>
    </div>,
    <div class="pubtype facet">
      <h6>Publication types</h6>
      <ul>
      {
        for $value in $all-pubtype-facets//search:facet-value
          let $name := data($value/@name)
          let $count := data($value/@count)
          let $css-class := if (contains($qtext, concat('pubtype:"', $name, '"'))) then 'selected' else ''
          order by $value/@count descending 
          return 
            <li>
              <a class="{$css-class}"
                href="/pubtype/{xdmp:url-encode($value/@name)}"
                data-facet="pubtype"
                data-value="{$value/@name}"
                >{$name}</a> ({$count})
            </li>
      }
      </ul>
    </div>)
};
