xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

(: forest & database must be created first! :)

declare variable $dbid := xdmp:database("PublicationIndex");

let $config := admin:get-configuration()

let $config := admin:database-set-uri-lexicon($config, $dbid, fn:true())
let $config := admin:database-set-collection-lexicon($config, $dbid, fn:true())
let $config := admin:database-set-fast-diacritic-sensitive-searches($config, $dbid, fn:true())

let $config := admin:database-add-range-element-index($config, $dbid, (
    admin:database-range-element-index("dateTime", "http://purl.org/dc/terms/", "available", "", fn:false())
    ,admin:database-range-element-index("string", "http://purl.org/dc/terms/", "subject", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-index("string", "http://purl.org/dc/terms/", "language", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "status", "http://marklogic.com/collation/", fn:false())
    ,admin:database-range-element-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "country", "http://marklogic.com/collation/", fn:false())
))

let $config := admin:database-add-range-element-attribute-index($config, $dbid, (
    admin:database-range-element-attribute-index("string", "http://www.oecd.org/metapub/oecdOrg/ns/", "item", "", "type", "http://marklogic.com/collation/", fn:false())
))

let $config := admin:database-add-element-word-lexicon($config, $dbid, (
    admin:database-element-word-lexicon("http://purl.org/dc/terms/", "title", "http://marklogic.com/collation/")
    ,admin:database-element-word-lexicon("http://purl.org/dc/terms/", "abstract", "http://marklogic.com/collation/")
))

let $config := admin:database-set-word-query-word-searches($config, $dbid, fn:true())
let $config := admin:database-set-word-query-include-document-root($config, $dbid, fn:false())

let $config := admin:database-add-word-query-included-element($config, $dbid, (
    admin:database-included-element("http://purl.org/dc/terms/", "title", 1.0, "", "", "")
    ,admin:database-included-element("http://www.oecd.org/metapub/oecdOrg/ns/", "subTitle", 1.0, "", "", "")
    ,admin:database-included-element("http://purl.org/dc/terms/", "abstract", 1.0, "", "", "")
))

let $config := admin:database-add-word-query-excluded-element($config, $dbid, (
    admin:database-excluded-element("http://purl.org/dc/terms/", "identifier")
    ,admin:database-excluded-element("http://www.oecd.org/metapub/oecdOrg/ns/", "summaries")
    ,admin:database-excluded-element("http://www.oecd.org/metapub/oecdOrg/ns/", "summary")
))

(:
This field is necessary to provide fast results for type-ahead in the search
box.  Right now, it is based on the words in the title and the abstract.

> Note: in order for this "field" to work, we need also "element word lexicons"
> for title and abstract to be created
:)

let $field := "suggest-field"
let $config := admin:database-add-field($config, $dbid, admin:database-field($field, fn:false()))
let $config := admin:database-set-field-fast-diacritic-sensitive-searches($config, $dbid, $field, fn:true())
let $config := admin:database-set-field-one-character-searches($config, $dbid, $field, fn:true())
let $config := admin:database-set-field-two-character-searches($config, $dbid, $field, fn:true())
let $config := admin:database-set-field-three-character-searches($config, $dbid, $field, fn:true())
let $config := admin:database-set-field-value-searches($config, $dbid, $field, fn:true())
let $config := admin:database-add-field-word-lexicon($config, $dbid, $field, admin:database-word-lexicon("http://marklogic.com/collation//S1"))
let $config := admin:database-add-field-included-element($config, $dbid, $field, (
    admin:database-included-element("http://purl.org/dc/terms/", "title", 1.0, "", "", "")
    ,admin:database-included-element("http://www.oecd.org/metapub/oecdOrg/ns/", "subTitle", 1.0, "", "", "")
    ,admin:database-included-element("http://purl.org/dc/terms/", "abstract", 1.0, "", "", "")
))

return admin:save-configuration($config)
