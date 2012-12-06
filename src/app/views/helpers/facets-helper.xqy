xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views/helpers";

import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace search = "http://marklogic.com/appservices/search";
declare namespace country = "country-data";
declare namespace lang = "language-data";

declare variable $country-doc := doc("/refs/countries.xml");
declare variable $language-doc := doc("/refs/languages.xml");

declare function module:render-facets($facets as element())
{
  let $qtext := $facets/search:qtext
  
  return
  (
    module:render-subject-facet($qtext, $facets/search:facet[@name = 'subject'])
    ,module:render-country-facet($qtext, $facets/search:facet[@name = 'country'])
    ,module:render-year-facet($qtext, fn:current-date(), fn:current-date())
    ,module:render-language-facet($qtext, $facets/search:facet[@name = 'language'])
    ,module:render-pubtype-facet($qtext, $facets/search:facet[@name = 'pubtype'])
  )
};

declare private function module:render-subject-facet($qtext as xs:string, $all-subject-facets as element(search:facet))
as element(div)
{
  <div class="subject facet">
    <h6>Subjects</h6>
    <ul>
    {
      for $value in $all-subject-facets//search:facet-value
        let $name := data($value/@name)
        let $count := data($value/@count)
        let $css-class := if (contains($qtext, concat('subject:"', $name,'"'))) then 'selected' else ''
        order by $name ascending
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
  </div>
};

declare private function module:render-country-facet($qtext as xs:string, $all-country-facets as element(search:facet))
as element(div)
{
  <div class="country facet">
    <select data-facet="country">
      <option value="">Filter by country</option>
    {
      for $country in $all-country-facets//search:facet-value
        let $code := data($country/@name)
        let $count := data($country/@count)
        let $css-class := if (contains($qtext, concat('country:', $code))) then 'selected' else ''
        (:let $_log := utils:log("about to log information on country name"):)
        (: TODO: create easy-to-use mapping function resolve("country", code) => Name of country :)
        let $name := module:get-ref-description("country",$code)
        (:let $_log := utils:log(concat("COUNTRY-NAME: ", $code, ": ", $name)):)

        order by $name ascending
        return
          if($name) then
            <option value="{$code}">
              {if (contains($qtext, concat('country:"', $code, '"'))) then attribute selected { "selected" } else ()}
              {concat($name," (", $count,")")}
            </option> else ()
    }
    </select>
  </div>
};

declare private function module:render-year-facet($qtext as xs:string, $min as xs:date, $max as xs:date)
as element(div)
{
  <div class="year facet">
    <h6>Publication date</h6>
    <div id="date-range-controls">
      <div id="slider-date-range"></div>
      <span class="input-append">
        <input type="text" id="start-date" data-oldest="{$min}" class="datepicker input-small"/>
        <span class="add-on"><i class="icon-calendar"></i></span>
      </span>
      <span class="input-append pull-right">
        <input type="text" id="end-date" data-newest="{$max}" class="datepicker input-small"/>
        <span class="add-on"><i class="icon-calendar"></i></span>
      </span>
    </div>
  </div>
};

declare private function module:render-language-facet($qtext as xs:string, $all-language-facets as element(search:facet))
as element(div)
{
  <div class="language facet">
    <select data-facet="language">
      <option value="">Filter by language</option>
      {
        for $language in $all-language-facets//search:facet-value
          let $code := data($language/@name)
          let $count := data($language/@count)
          let $name := module:get-ref-description("language",$code)
          order by $name ascending
          return
            if($name) then
              <option value="{$code}">
                {if (contains($qtext, concat('language:"', $code, '"'))) then attribute selected { "selected" } else ()}
                {concat($name," (", $count,")")}
              </option>
            else ()
      }
    </select>
  </div>
};

declare private function module:render-pubtype-facet($qtext as xs:string, $all-pubtype-facets as element(search:facet))
as element(div)
{
  <div class="pubtype facet">
    <h6>Publication types</h6>
    <ul>
    {
      for $value in $all-pubtype-facets//search:facet-value
        let $name := data($value/@name)
        let $count := data($value/@count)
        let $css-class := if (contains($qtext, concat('pubtype:"', $name, '"'))) then 'selected' else ''
        order by $name ascending
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
  </div>
};

declare function module:render-selected-facets($qtext as xs:string)
as element(div)?
{
  let $facets := functx:get-matches($qtext, "[a-z]+:""([^""]+)""")[. ne ""]
  return
    if($facets) then
      <div id="search-results-facets" class="facet selected">
      {
        for $f in functx:get-matches($qtext, "[a-z]+:""([^""]+)""")[. ne ""]
        let $t := fn:substring-before($f,":")
        let $v := fn:replace($f,"[a-z]+:""([^""]+)""", "$1")
        return <span data-facet="{$t}" data-value="{$v}" class="selected-facet">
          <i class="icon-ok"></i>
          {module:get-ref-description($t,$v)}
        </span>
      }
      </div>
    else
      ()
};

declare private function module:get-ref-description($type as xs:string, $code as xs:string)
as xs:string?
{
  if($type eq "country") then
     $country-doc//country:country[country:code eq upper-case($code)]/country:name/country:en[@case="normal"]
  else if ($type eq "language") then
    fn:data($language-doc/lang:*/lang:language[@id = $code])
  else
    $code
};