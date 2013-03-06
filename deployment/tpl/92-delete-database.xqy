xquery version "1.0-ml";

(:
  creates an http app server on port xxxx
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: -------------------------------------------------------------------------- :)
(: delete database ---------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

let $config := admin:get-configuration()

let $config := if (admin:database-exists($config, $database-name))
  then 
    admin:database-delete($config, (xdmp:database($database-name)))
  else 
    $config

(: -------------------------------------------------------------------------- :)
(: commit changes ----------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

return admin:save-configuration($config);
