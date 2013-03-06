xquery version "1.0-ml";

(:
  creates an http app server on port xxxx
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: -------------------------------------------------------------------------- :)
(: create http app server --------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

let $config := admin:get-configuration()
let $groups := admin:get-group-ids($config)

let $config := if (admin:appserver-exists($config, $groups, $app-server-name))
  then 
    admin:appserver-delete(
     $config,
     admin:appserver-get-id(
       $config
      ,admin:group-get-id($config, $group-id), $app-server-name
     )
    )
  else
    $config

(: -------------------------------------------------------------------------- :)
(: commit changes ----------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

return admin:save-configuration($config);
