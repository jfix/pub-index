xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/models/item";

declare namespace oe = "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function module:get-item($id as xs:string)
as element(oe:item)
{
  collection("metadata")[.//dt:identifier = $id]/oe:item
};

declare function module:get-item-toc($id as xs:string, $showTg as xs:boolean?, $showAbstract as xs:boolean?)
as element(oe:toc)
{
  let $types := ('chapter', if ($showTg) then ('table','graph') else ())
  return
  <toc xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $ipo in collection("metadata")/oe:item[@type = $types]/oe:isPartOf[@rdf:resource = $id and not(following-sibling::isPartOf) ]
      let $comp := $ipo/..
      order by xs:integer($ipo/@order) ascending
      return <item>
        {attribute type { $comp/@type }}
        {$comp/dt:identifier}
        {$comp/dt:title}
        {$comp/oe:doi}
        {if ($showAbstract) then $comp/dt:abstract else ()}
        {
          if ($showTg) then
            for $ipo2 in collection("metadata")/oe:item[@type = ('table','graph')]/oe:isPartOf[@rdf:resource = $comp/dt:identifier]
            let $tg  := $ipo2/..
            order by xs:integer($ipo2/@order) ascending
            return
              <item>
                {attribute type { $tg/@type }}
                {$tg/dt:identifier}
                {$tg/dt:title}
                {$tg/oe:doi}
                {if ($showAbstract) then $tg/dt:abstract else ()}
              </item>
          else
            ()
        }
      </item>
    }
  </toc>
};