xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/item";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function module:add($item as element(oe:item))
as empty-sequence()
{
  let $id := $item/dt:identifier
  let $type := $item/@type
  
  return 
    if($id and $type) then
      xdmp:document-insert(
        fn:concat("/metadata/",$type,"/",$id,".xml")
        ,$item
        ,()
        ,(
          "metadata"
          ,$type
          ,if($type = ("book", "article", "workingpaper", "serial")) then "searchable" else ()
        )
      )
    else
      fn:error((),"Malformed XML input")
};

declare function module:get-item($id as xs:string)
as element(oe:item)
{
  collection("metadata")[.//dt:identifier = $id]/oe:item
};

declare function module:get-item-translations($item as element(oe:item))
as element(oe:translations)
{
  <translations xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $trans in collection("metadata")[.//dt:identifier = $item/oe:relation[@type = 'translation']/@rdf:resource]/oe:item
      return
        <translation rdf:resource="{$trans/dt:identifier}">
          {$trans/dt:language}
        </translation>
    }
  </translations>
};

declare function module:get-item-toc($id as xs:string, $showTg as xs:boolean?, $showAbstract as xs:boolean?)
as element(oe:toc)
{
  let $types := ('chapter', if ($showTg) then ('table','graph') else ())
  return
  <toc xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $ipo in collection("metadata")/oe:item[@type = $types]/oe:relation[@type = 'completeversion' and @rdf:resource = $id and not(../oe:relation[@type = 'chapter']) ]
      let $comp := $ipo/..
      order by xs:integer($ipo/@order) ascending
      return <item>
        {attribute type { $comp/@type }}
        {$comp/dt:identifier}
        {
          for $bbl in $comp/oe:bibliographic
          return
            <bibliographic>
              {$bbl/@*}
              {$bbl/dt:title}
              {if ($showAbstract) then $bbl/dt:abstract else ()}
            </bibliographic>
        }
        {$comp/oe:doi}
        {$comp/oe:freepreview}
        {
          if ($showTg) then
            for $ipo2 in collection("metadata")/oe:item[@type = ('table','graph')]/oe:relation[@type = 'chapter' and @rdf:resource = $comp/dt:identifier]
            let $tg  := $ipo2/..
            order by xs:integer($ipo2/@order) ascending
            return
              <item>
                {attribute type { $tg/@type }}
                {$tg/dt:identifier}
                {
                  for $bbl in $tg/oe:bibliographic
                  return
                    <bibliographic>
                      {$bbl/@*}
                      {$bbl/dt:title}
                      {if ($showAbstract) then $bbl/dt:abstract else ()}
                    </bibliographic>
                }
                {$tg/oe:doi}
                {$tg/oe:freepreview}
              </item>
          else
            ()
        }
      </item>
    }
  </toc>
};