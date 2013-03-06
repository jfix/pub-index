xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: ========================================================================== :)
(: 1) create the forest, or don't if it exists already :)

let $config := admin:get-configuration()

let $existing-forests :=
    for $id in admin:get-forest-ids($config)
       return admin:forest-get-name($config, $id)

let $config :=
    if ($forest-name = $existing-forests) 
    then $config
    else  
      admin:forest-create(
         $config
        ,$forest-name
        ,xdmp:host()
        ,$forest-data-directory
        ,()
        ,()
      )
return admin:save-configuration($config);
