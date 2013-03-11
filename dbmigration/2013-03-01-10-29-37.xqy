xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-delete-range-element-index($config, $dbid, (
    admin:database-range-element-index("string", "http://purl.org/dc/terms/", "language", "http://marklogic.com/collation/", fn:false())
))

let $config := admin:database-add-path-namespace($config, $dbid,
    admin:database-path-namespace("dt", "http://purl.org/dc/terms/")
)

let $config := admin:database-add-range-path-index($config, $dbid, 
    admin:database-range-path-index($dbid, "string", "/oe:item/dt:language", "http://marklogic.com/collation/", fn:false(), "reject")
)

return admin:save-configuration($config)