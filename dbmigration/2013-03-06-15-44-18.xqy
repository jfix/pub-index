xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-delete-word-query-included-element($config, $dbid, (
    admin:database-included-element("http://purl.org/dc/terms/", "title", 5.0, "", "", "")
    ,admin:database-included-element("http://www.oecd.org/metapub/oecdOrg/ns/", "subTitle", 4.0, "", "", "")
    ,admin:database-included-element("http://purl.org/dc/terms/", "abstract", 3.0, "", "", "")
))

let $config := admin:database-add-word-query-included-element($config, $dbid, (
    admin:database-included-element("http://purl.org/dc/terms/", "title", 1000.0, "", "", "")
    ,admin:database-included-element("http://www.oecd.org/metapub/oecdOrg/ns/", "subTitle", 500.0, "", "", "")
    ,admin:database-included-element("http://purl.org/dc/terms/", "abstract", 1.0, "", "", "")
))

return admin:save-configuration($config)