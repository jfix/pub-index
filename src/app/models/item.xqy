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
        ,xdmp:xslt-invoke("/app/models/xslt/item-cleanup.xsl", $item)
        ,()
        ,(
          "metadata"
          ,$type
          ,if($type = ("book", "article", "workingpaper", "edition")) then "searchable" else ()
        )
      )
    else
      fn:error((),"Malformed XML input")
};

declare function module:get-item($id as xs:string)
as element(oe:item)?
{
  collection("metadata")[.//dt:identifier = $id]/oe:item
};

declare function module:get-item-type($id as xs:string)
as xs:string?
{
  cts:element-attribute-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","item")
    ,fn:QName("","type")
    ,()
    ,()
    ,cts:element-value-query(fn:QName("http://purl.org/dc/terms/","identifier"), $id)
  )
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

declare function module:get-item-parent($item as element(oe:item))
as element(oe:parents)
{
  <parents xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
  {
    for $parent in collection("metadata")[.//dt:identifier = $item/oe:relation[@type = ('series','periodical')]/@rdf:resource ]/oe:item
    return
      <item type="{$parent/@type}">
        {$parent/dt:identifier}
        {$parent/oe:link}
        {
          for $bbl in $parent/oe:bibliographic
          return
            <bibliographic>
              {$bbl/@*}
              {$bbl/dt:title}
            </bibliographic>
        }
      </item>
    }
  </parents>
};

declare function module:get-item-parent-id($id as xs:string)
as xs:string?
{
  cts:element-attribute-values(
    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
    ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
    ,(),()
    ,cts:and-query((
      cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation"),fn:QName("","type"),"=",("journal","series","completeversion","periodical"))
      ,cts:element-range-query(fn:QName("http://purl.org/dc/terms/","identifier"),"=",$id)
    ))
  )[1]
};

declare function module:get-book-summaries($id as xs:string)
as element(oe:summaries)
{
  let $ids := cts:element-values(fn:QName("http://purl.org/dc/terms/","identifier"), (), (),
                cts:and-query((
                  cts:element-attribute-range-query(
                    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                    ,fn:QName("","type")
                    ,"="
                    ,"completeversion"
                  )
                  ,cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                    ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
                    ,"="
                    ,$id
                  )
                ))
              )
  
  return
    <summaries xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $s in cts:search(collection("summary")/oe:item, cts:element-range-query(fn:QName("http://purl.org/dc/terms/","identifier"), "=", $ids))
      return
      <summary>
        {$s/dt:language}
        {$s/oe:link[@type = 'doi']}
      </summary>
    }
    </summaries>
};

declare function module:get-item-toc($id as xs:string, $showTg as xs:boolean?, $showAbstract as xs:boolean?)
as element(oe:toc)
{
  let $query := cts:and-query((
                  cts:element-attribute-range-query(
                    fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","item")
                    ,fn:QName("","type")
                    ,"!="
                    ,"summary"
                  )
                  ,cts:element-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation"),
                    cts:and-query((
                      cts:element-attribute-range-query(
                        fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                        ,fn:QName("","type")
                        ,"="
                        ,"completeversion"
                      )
                      ,cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                        ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
                        ,"="
                        ,$id
                      )
                    ))
                  )
                  ,cts:not-query(cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation"),fn:QName("","type"),"=","chapter"))
                ))
  let $rootids := cts:element-values(fn:QName("http://purl.org/dc/terms/","identifier"), (), (), $query)

return
  <toc xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $comp in cts:search(collection("metadata")/oe:item, cts:element-range-query(fn:QName("http://purl.org/dc/terms/","identifier"), "=", $rootids))
      order by xs:integer(($comp/oe:relation[@type = "completeversion"])[1]/@order) ascending
      return <item>
        {$comp/@*}
        {$comp/*}
        {
          if ($showTg) then
            for $comp2 in cts:search(collection("metadata")/oe:item,
                            cts:element-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation"),
                              cts:and-query((
                                cts:element-attribute-range-query(
                                  fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                                  ,fn:QName("","type")
                                  ,"="
                                  ,"chapter"
                                )
                                ,cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                                  ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
                                  ,"="
                                  ,$comp/dt:identifier
                                )
                              ))
                            )
                          )
            order by xs:integer(($comp/oe:relation[@type = "completeversion"])[1]/@order) ascending
            return $comp2
          else
            ()
        }
      </item>
    }
  </toc>
};

declare function module:get-serial-toc($id as xs:string, $showAbstract as xs:boolean?)
as element(oe:toc)
{
  let $type := module:get-item-type($id)
  let $rtype := if($type = 'journal') then 'journal' else 'series'
  let $ctype := if($type = 'journal') then 'article' else 'workingpaper'
  return
  <toc xmlns="http://www.oecd.org/metapub/oecdOrg/ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/">
    {
      for $item in cts:search(collection($ctype)/oe:item,
                    cts:element-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation"),
                      cts:and-query((
                        cts:element-attribute-range-query(
                          fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                          ,fn:QName("","type")
                          ,"="
                          ,$rtype
                        )
                        ,cts:element-attribute-range-query(fn:QName("http://www.oecd.org/metapub/oecdOrg/ns/","relation")
                          ,fn:QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#","resource")
                          ,"="
                          ,$id
                        )
                      ))
                    )
                  )
      order by $item/dt:available descending
      return $item
    }
  </toc>
};
