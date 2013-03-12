xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-add-fragment-parent($config, $dbid, (
    admin:database-fragment-parent("http://www.oecd.org/metapub/oecdOrg/ns/", "countries")
    ,admin:database-fragment-parent("http://www.oecd.org/metapub/oecdOrg/ns/", "languages")
    ,admin:database-fragment-parent("http://www.oecd.org/metapub/oecdOrg/ns/", "topics")
    ,admin:database-fragment-parent("http://www.oecd.org/metapub/oecdOrg/ns/", "directorates")
))

let $config := admin:database-add-range-element-attribute-index($config, $dbid, (
    admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "country", "", "id", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "directorate", "", "id", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "language", "", "id", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "topic", "", "id", "http://marklogic.com/collation/", fn:false())
))

return admin:save-configuration($config)