xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: ========================================================================== :)
(: 3) atttach database to forest :)

declare variable $database := xdmp:database($database-name);

let $config := admin:get-configuration()

let $attached-forests :=
    admin:forest-get-name( 
       $config, 
       (admin:database-get-attached-forests(
          $config, 
          $database) ))

let $config :=
    if ($forest-name = $attached-forests) 
    then $config
    else
       admin:database-attach-forest(
          $config,
          $database,
          xdmp:forest($forest-name))

return admin:save-configuration($config);
