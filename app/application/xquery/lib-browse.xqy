xquery version "1.0-ml";

(: $Id$ :)

module namespace browse = "lib-browse";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default collation "http://marklogic.com/collation/";

declare variable $browse-results-xslt := document("/application/xslt/browse-results.xsl");

declare function browse:browse-content()
as element(div)+
{
(
  <div class="row">
    <div class="twelve columns">
      <h3>browsing publications</h3>
    </div>
  </div>,
  <div class="row">
    <div class="three columns">
      { 
        browse:browse-topic(''),
        <hr/>,
        browse:browse-pubtype('book'),
        <hr/>,
        browse:browse-alpha('a')
      }

    </div>
    <div class="nine columns">
      {browse:browse-results(1, 10)}
    </div>
  </div>
)
};

declare function browse:browse-results(
  $start as xs:int,
  $length as xs:int
) as element(div)+
{
  let $options := 
    <search:options xmlns="http://marklogic.com/appservices/search">
      <constraint name="metadata-only">
        <collection prefix="metadata"/>
      </constraint>
        <constraint name="pubtype">
          <range type="xs:string">
            <element name="pubtype" ns="http://www.oecd.org/metapub/oecdOrg/ns/"/>
          </range>
        </constraint>
      <transform-results apply="transformed-result" ns="transformed-search" at="/application/xquery/transform.xqy" />
      <return-facets>true</return-facets>
    </search:options>

  let $result := search:search("", $options, $start, $length)
  return
    <div>
    {
      let $r := xdmp:xslt-eval($browse-results-xslt, $result)
      return ((:
        xdmp:log(
          concat("****** XSLT STYLE: ", xdmp:quote($browse-results-xslt),
                "****** RESULTS: ", xdmp:quote($result),
                "****** XSLT TRANSFORMATION: ", xdmp:quote($r))
        ),:)
        $r
       )
     }
    </div>
};

declare function browse:browse-topic(
  $topic as xs:string?
)
{
  let $options := 
  <search:options xmlns="http://marklogic.com/appservices/search">
   <constraint name="subject">
     <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
        <element ns="http://purl.org/dc/terms/" name="subject"/>
     </range>
   </constraint>
   <return-results>false</return-results>
   <return-facets>true</return-facets>
   <debug>true</debug>
  </search:options>

  let $_check := search:check-options($options)
  let $facets := search:search("", $options)
  (:let $search := search:search($facet):)
  
  return
    <div class="row">
      <strong>topics</strong>
      <ul>
      {
      for $facet in $facets//search:facet-value
        let $name := data($facet/@name)
        let $count := data($facet/@count)
        order by $facet/@count descending 
        return 
          <li style="margin-bottom: 0"><a 
            href="/browse/topic/{xdmp:url-encode($name)}" 
            title="There are {$count} {$name}">{$name}</a> ({$count})
          </li>
      }
      </ul>
    </div>
};

declare function browse:browse-pubtype(
  $pubtype as xs:string?
)
{
  let $options := 
  <search:options xmlns="http://marklogic.com/appservices/search">
   <constraint name="pubtype">
     <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
        <element ns="http://www.oecd.org/metapub/oecdOrg/ns/" name="pubtype"/>
     </range>
   </constraint>
   { if ($pubtype) then () else <return-results>false</return-results>}
   <return-facets>true</return-facets>
   <debug>true</debug>
  </search:options>
  
  let $_check := search:check-options($options)
  let $facets := search:search("", $options)
  (:let $search := search:search($facet):)
  
  return
    <div class="row">
      <strong>publication types</strong>
      <ul>
      {
      for $facet in $facets//search:facet-value
        let $name := data($facet/@name)
        let $count := data($facet/@count)
        order by $facet/@count descending 
        return 
          <li style="margin-bottom: 0"><a 
            href="browse.xqy?facet=title-starts-with:{$name}" 
            title="There are {$count} {$name}">{$name}</a> ({$count})
          </li>
      }
      </ul>
    </div>
};

declare function browse:browse-alpha(
  $facet as xs:string?
)
{
  let $options := 
      <options xmlns="http://marklogic.com/appservices/search">
        <constraint name="title-starts-with">
          <range type="xs:string">
            <element name="title" ns="http://purl.org/dc/terms/"/>
            <bucket name="A" ge="A" lt="B">A</bucket>
            <bucket name="B" ge="B" lt="C">B</bucket>
            <bucket name="C" ge="C" lt="D">C</bucket>
            <bucket name="D" ge="D" lt="E">D</bucket>
            <bucket name="E" ge="E" lt="F">E</bucket>
            <bucket name="F" ge="F" lt="G">F</bucket>
            <bucket name="G" ge="G" lt="H">G</bucket>
            <bucket name="H" ge="H" lt="I">H</bucket>
            <bucket name="I" ge="I" lt="J">I</bucket>
            <bucket name="J" ge="J" lt="K">J</bucket>
            <bucket name="K" ge="K" lt="L">K</bucket>
            <bucket name="L" ge="L" lt="M">L</bucket>
            <bucket name="M" ge="M" lt="N">M</bucket>
            <bucket name="N" ge="N" lt="O">N</bucket>
            <bucket name="O" ge="O" lt="P">O</bucket>
            <bucket name="P" ge="P" lt="Q">P</bucket>
            <bucket name="Q" ge="Q" lt="R">Q</bucket>
            <bucket name="R" ge="R" lt="S">R</bucket>
            <bucket name="S" ge="S" lt="T">S</bucket>
            <bucket name="T" ge="T" lt="U">T</bucket>
            <bucket name="U" ge="U" lt="V">U</bucket>
            <bucket name="V" ge="V" lt="W">V</bucket>
            <bucket name="W" ge="W" lt="X">W</bucket>
            <bucket name="X" ge="X" lt="Y">X</bucket>
            <bucket name="Y" ge="Y" lt="Z">Y</bucket>
            <bucket name="Z" ge="Z">Z</bucket>
          </range>
        </constraint>
        { if ($facet) then () else <return-results>false</return-results>}
      </options>

  let $_check := search:check-options($options)
  let $facets := search:search("", $options)
  let $search := search:search($facet)
  
  return
    <div class="row">
      <dl class="sub-nav">
      <dt>Filter by first letter:</dt>
      {
      for $facet in $facets//search:facet-value
        let $name := data($facet/@name)
        let $count := data($facet/@count)
        return 
          <dd><a 
            href="browse.xqy?facet=title-starts-with:{$name}" 
            title="There are {$count} starting with {$name}">{$name}</a>
          </dd>
      }
      </dl>
    </div>
};
