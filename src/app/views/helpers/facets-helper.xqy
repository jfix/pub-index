xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views/helpers";

import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace search = "http://marklogic.com/appservices/search";

declare function module:render-facets($facets as element())
{
  let $qtext := $facets/search:qtext
  
  return
  (
    module:render-subject-facet($qtext, $facets/search:facet[@name = 'subject'])
    ,module:render-country-facet($qtext, $facets/search:facet[@name = 'country'])
    ,module:render-year-facet($qtext, fn:current-date() - xs:dayTimeDuration('P15000D'), fn:current-date())
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
        let $id := data($value/@name),
            $count := data($value/@count)
        
        let $ref := module:get-ref('subject', $id),
            $label := module:get-ref-label($ref)
        
        let $css-class := if (contains($qtext, concat('subject:"', $id,'"'))) then 'selected' else ''
        
        order by $label ascending
        return 
          <li>
            <a class="{$css-class}" 
              href="/subject/{$id}"
              data-facet="subject"
              data-value="{$id}"
              >{ $label }</a> ({$count})
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
      for $value in $all-country-facets//search:facet-value
        let $id := data($value/@name),
            $count := data($value/@count)
        
        let $ref := module:get-ref('country', $id),
            $label := module:get-ref-label($ref)
        
        let $css-class := if (contains($qtext, concat('country:', $id))) then 'selected' else ''
        
        order by $label ascending
        return
          if($label) then
            <option value="{$id}">
              {if (contains($qtext, concat('country:"', $id, '"'))) then attribute selected { "selected" } else ()}
              {concat($label," (", $count,")")}
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
        <input type="text" id="start-date" data-oldest="{substring(string($min),1,10)}" class="datepicker input-small"/>
        <span class="add-on"><i class="icon-calendar"></i></span>
      </span>
      <span class="input-append pull-right">
        <input type="text" id="end-date" data-newest="{substring(string($max),1,10)}" class="datepicker input-small"/>
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
        for $value in $all-language-facets//search:facet-value
          let $id := data($value/@name),
              $count := data($value/@count)
          
          let $ref := module:get-ref('language', $id),
              $label := module:get-ref-label($ref)
          
          order by $label ascending
          return
            if($label) then
              <option value="{$id}">
                {if (contains($qtext, concat('language:"', $id, '"'))) then attribute selected { "selected" } else ()}
                {concat($label," (", $count,")")}
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
        let $id := data($value/@name),
            $count := data($value/@count)
        
        let $ref := module:get-ref('pubtype', $id),
            $label := module:get-ref-label($ref)
        
        let $css-class := if (contains($qtext, concat('pubtype:"', $id, '"'))) then 'selected' else ''
        
        order by $label ascending
        return 
          <li>
            <a class="{$css-class}"
              href="/pubtype/{$id}"
              data-facet="pubtype"
              data-value="{$id}"
              >{$label}</a> ({$count})
          </li>
    }
    </ul>
  </div>
};

declare function module:render-selected-facets($qtext as xs:string)
as element(div)?
{
  let $facets :=
    for $facet in functx:get-matches($qtext, "[a-z]+:""([^""]+)""")[. ne ""]
      let $type := fn:substring-before($facet,":")
      let $id := fn:replace($facet,"[a-z]+:""([^""]+)""", "$1")
      
      let $ref := module:get-ref($type, $id)
      let $label := data($ref/oe:label[@xml:lang eq 'en'])
      
      return
        <span data-facet="{$type}" data-value="{$id}" class="selected-facet">
          <i class="icon-ok"></i>{$label}
        </span>
  
  return
    if($facets) then
      <div id="search-results-facets" class="facet selected">
        { $facets }
      </div>
    else
      ()
};

declare private function module:get-ref($type as xs:string, $id as xs:string)
as element()?
{
  if($type eq "subject") then
    collection("referential")//oe:topic[@id eq $id]
    
  else if($type eq "country") then
    collection("referential")//oe:country[@id eq $id]
    
  else if ($type eq "language") then
    collection("referential")//oe:language[@id eq $id]
    
  else if ($type eq "pubtype") then
    <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}">
      <label xml:lang="en">{if($id eq 'book') then 'Book' else if($id eq 'edition') then 'Serial' else 'Unknown'}</label>
      <label xml:lang="fr">{$id}</label>
    </itemtype>
    
  else
    ()
};

declare private function module:get-ref-label($ref as element())
as xs:string?
{
  data($ref/oe:label[@xml:lang eq 'en'])
};