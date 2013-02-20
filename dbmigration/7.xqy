xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-add-path-namespace($config, $dbid,
    admin:database-path-namespace("oe", "http://www.oecd.org/metapub/oecdOrg/ns/")
)

let $config := admin:database-add-range-path-index($config, $dbid, 
    admin:database-range-path-index($dbid, "string", "/oe:item/@type", "http://marklogic.com/collation/", fn:false(), "reject")
)

return admin:save-configuration($config)