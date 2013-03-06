xquery version "1.0-ml";

(:
  delete a forest and all its data
  
  TODO: This doesn't actually delete an existing forest. 
        If you call this from within qconsole it works, though ...
        I don't understand!
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" 
  at "/MarkLogic/admin.xqy";

(: -------------------------------------------------------------------------- :)
(: delete forest ------------------------------------------------------------ :)
(: -------------------------------------------------------------------------- :)

let $config := admin:get-configuration()

let $config := if (admin:forest-exists($config, $forest-name))
  then
    admin:forest-delete(
       $config
      ,(admin:forest-get-id($config, $forest-name))
      ,fn:true() (: force data deletion :)
    )
  else
    $config

(: -------------------------------------------------------------------------- :)
(: commit changes ----------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

return admin:save-configuration($config);
