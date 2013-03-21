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
     module:render-topic-facet($qtext, $facets/search:facet[@name = 'topic'])
    ,module:render-country-facet($qtext, $facets/search:facet[@name = 'country'])
    ,module:render-year-facet($qtext, $facets/search:facet[@name = 'date'])
    ,module:render-language-facet($qtext, $facets/search:facet[@name = 'language'])
    ,module:render-pubtype-facet($qtext, $facets/search:facet[@name = 'pubtype'])
  )
};

declare private function module:render-topic-facet($qtext as xs:string, $all-topic-facets as element(search:facet))
as element(div)
{
  <div class="topic facet">
    <h5>Publications by topics</h5>
    <ul>
    {
      for $value in $all-topic-facets//search:facet-value
        let $id := data($value/@name),
            $count := data($value/@count)
        
        let $ref := module:get-ref('topic', $id),
            $label := module:get-ref-label($ref)
        
        let $css-class := if (contains($qtext, concat('topic:"', $id,'"'))) then 'selected' else ''
        
        order by $label ascending
        return 
          <li>
            <a class="{$css-class}" 
              href="/topic/{$id}"
              data-facet="topic"
              data-value="{$id}"
              >{ $label }</a> ({$count})
          </li>
    }
    </ul>
    <hr/>
  </div>
};

declare private function module:render-country-facet($qtext as xs:string, $all-country-facets as element(search:facet))
as element(div)
{
  <div class="country facet">
    <h5>Browse by country</h5>
    <select data-facet="country" class="span3">
      <option value="">Select a country</option>
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
    <hr/>
  </div>
};

declare private function module:render-year-facet($qtext as xs:string, $pubdate-facets as element(search:facet))
as element(div)
{
  let $min := xs:date(substring(string($pubdate-facets//search:facet-value[@name eq 'min']),1,10))
  let $max := xs:date(substring(string($pubdate-facets//search:facet-value[@name eq 'max']),1,10))
  return
  <div class="year facet">
    <h5>Publication date</h5>
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
      {
        if($max gt current-date()) then
          <a id="btn-forthcoming" class="pull-right btn btn-mini disabled">Exclude forthcoming publications</a>
        else
          ()
      }
    </div>
    <hr/>
  </div>
};

declare private function module:render-language-facet($qtext as xs:string, $all-language-facets as element(search:facet))
as element(div)
{
  <div class="language facet">
    <select data-facet="language" class="span3">
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
    <hr/>
  </div>
};

declare private function module:render-pubtype-facet($qtext as xs:string, $all-pubtype-facets as element(search:facet))
as element(div)
{
  <div class="pubtype facet">
    <h5>Publication types</h5>
    <ul>
    {
      for $value in $all-pubtype-facets//search:facet-value
        let $id := data($value/@name),
            $count := data($value/@count)
        
        let $ref := module:get-ref('pubtype', $id),
            $label := module:get-ref-label($ref)
            
        
        let $css-class := if (contains($qtext, concat('pubtype:"', $id, '"'))) then 'selected' else ''
        
        order by $ref/@order ascending
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
  let $known-facets as xs:string+ := ("topic", "country", "language", "pubtype", "from", "to")
  
  let $facets :=
    for $facet in functx:get-matches($qtext, "[a-z]+:""([^""]+)""")[. ne ""]
      let $type := fn:substring-before($facet,":")
      let $id := fn:replace($facet,"[a-z]+:""([^""]+)""", "$1")
      
      let $ref := module:get-ref($type, $id)
      let $label := data($ref/oe:label[@xml:lang eq 'en'])
      
      return
        if ($known-facets = $type)
        then
        <span data-facet="{$type}" data-value="{$id}" class="selected-facet">
          <i class="icon-ok"></i>{$label}
        </span>
        else 
            (: https://github.com/robwhitby/xray/pull/11 :)
            fn:error((), 'PI-INVALIDFACETTYPE', concat( 'The value "', $type, '" is not a valid facet type.'))
  let $facet := functx:get-matches($qtext, "\(date GE .*?\)")[. ne ""][1]
  let $facets :=
    if($facet) then
    (
      $facets
      ,let $value := xs:date(substring(fn:replace($facet,"\(date GE (.*?)\)", "$1"),1,10))
       return
        <span data-facet="from" data-value="{$value}" class="selected-facet">
          <i class="icon-ok"></i>From {format-date($value, '[D] [MNn,*-3] [Y]')}
        </span>
    )
    else
      $facets
  
  let $facet := functx:get-matches($qtext, "\(date LE .*?\)")[. ne ""][1]
  let $facets :=
    if($facet) then
    (
      $facets
      ,let $value := xs:date(substring(fn:replace($facet,"\(date LE (.*?)\)", "$1"),1,10))
       return
        <span data-facet="to" data-value="{$value}" class="selected-facet">
          <i class="icon-ok"></i>Until {format-date($value, '[D] [MNn,*-3] [Y]')}
        </span>
    )
    else
      $facets
  
  return
    if($facets) then
      <div id="search-results-facets" class="facet selected">
        { $facets }
        {
          if (fn:count($facets) > 1) then
            <span id="clear-facets"><i class="icon-remove"></i>Clear all</span>
          else ()
        }
      </div>
    else
      ()
};

(:~
 : based on a $type string value and an identifier $id, return a 
 : label for a facet value. 
 : Typically, this will be "Book" for $type "pubtype" and $id "book"
 :)
declare private function module:get-ref($type as xs:string, $id as xs:string)
as element()?
{
  if($type eq "topic") then
    collection("referential")//oe:topic[@id eq $id]
    
  else if($type eq "country") then
    collection("referential")//oe:country[@id eq $id]
    
  else if ($type eq "language") then
    collection("referential")//oe:language[@id eq $id]
    
    (:
    see #5298 for order
    1. Periodical book (new label for serial)
    2. Book
    3. Article
    4. Journal
    5. Working Paper
    6. Working Paper series

    FIXME: this is a huge repetition of code, but once again, this is quickest.  
           Probably the order (and the labels) should/could be maintained in a 
           lookup file.
    :)
  else if ($type eq "pubtype") then
        if($id eq 'book') then 
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="2"><label xml:lang="en">Book</label><label xml:lang="fr">{$id}</label></itemtype>
        else if($id eq 'edition') then 
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="1"><label xml:lang="en">Periodical book</label><label xml:lang="fr">{$id}</label></itemtype>
        else if($id eq 'article') then
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="3"><label xml:lang="en">Article</label><label xml:lang="fr">{$id}</label></itemtype>
        else if($id eq 'journal') then
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="4"><label xml:lang="en">Journal</label><label xml:lang="fr">{$id}</label></itemtype>
        else if($id eq 'workingpaperseries') then
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="6"><label xml:lang="en">Working Paper series</label><label xml:lang="fr">{$id}</label></itemtype>
        else if($id eq 'workingpaper') then 
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="5"><label xml:lang="en">Working Paper</label><label xml:lang="fr">{$id}</label></itemtype>
        else 
        <itemtype xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" id="{$id}" order="99"><label xml:lang="en">{$type}</label><label xml:lang="fr">{$id}</label></itemtype>
  else
    ()
};

declare private function module:get-ref-label($ref as element())
as xs:string?
{
  data($ref/oe:label[@xml:lang eq 'en'])
};