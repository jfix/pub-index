xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: ========================================================================== :)
(: create the database :)

declare variable $database := xdmp:database($database-name);

let $config := admin:get-configuration()


(: Get all of the existing databases :)

let $existing-databases :=
    for $id in admin:get-database-ids($config)
       return admin:database-get-name($config, $id)

(: Check to see if $database-name already exists. If not, create new database :)

let $config :=
    if ($database-name = $existing-databases) 
    then $config
    else  
      admin:database-create(
        $config, 
        $database-name,
        xdmp:database("Security"),
        xdmp:database("Schemas"))


let $database := admin:database-get-id($config, $database-name)
let $config := admin:database-set-stemmed-searches($config, $database, "off")
let $config := admin:database-set-word-searches( $config, $database, fn:true())


return admin:save-configuration($config);
