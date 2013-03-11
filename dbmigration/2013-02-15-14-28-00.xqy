xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-add-range-element-index($config, $dbid, (
    admin:database-range-element-index("dateTime", "http://marklogic.com/xdmp/property", "last-modified", "http://marklogic.com/collation/", fn:false())
))

let $config := admin:database-set-maintain-last-modified($config, $dbid, fn:true())

return admin:save-configuration($config)