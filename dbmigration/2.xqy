xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-add-range-element-index($config, $dbid, (
    admin:database-range-element-index("string", "http://purl.org/dc/terms/", "identifier", "http://marklogic.com/collation/", fn:false())
))

let $config := admin:database-add-range-element-attribute-index($config, $dbid, (
    admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "isPartOf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "resource", "http://marklogic.com/collation/", fn:false())
))

return admin:save-configuration($config)