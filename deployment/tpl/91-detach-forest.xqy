xquery version "1.0-ml";

(:
  detach a forest from its database
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: -------------------------------------------------------------------------- :)
(: detach forest from database ---------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

let $config := admin:get-configuration()
let $groups := admin:get-group-ids($config)

(: if returns an () empty sequence this gets cast as false() :)
let $config := if (admin:database-exists($config, $database-name) and admin:forest-get-database($config,xdmp:forest($forest-name)))
  then 
    admin:database-detach-forest(
       $config
      ,xdmp:database($database-name)
      ,xdmp:forest($forest-name)
    ) 
  else 
    $config

(: -------------------------------------------------------------------------- :)
(: commit changes ----------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

return admin:save-configuration($config);
