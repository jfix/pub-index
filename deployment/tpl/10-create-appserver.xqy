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
let $database := xdmp:database($database-name)
let $groups := admin:get-group-ids($config)

let $config := if (admin:appserver-exists($config, $groups, $app-server-name)) 
  then $config 
  else 
    admin:http-server-create(
       $config
      ,$groups
      ,$app-server-name 
      ,$root
      ,$app-server-port
      ,$module-location
      ,$database
    )

let $http-app-server := admin:appserver-get-id($config, $groups, $app-server-name)

(: set url rewriter --------------------------------------------------------- :)

let $config := admin:appserver-set-url-rewriter(
   $config
  ,$http-app-server
  ,$rewrite-handler
)

(: set error handler -------------------------------------------------------- :)

let $config := admin:appserver-set-error-handler(
   $config
  ,$http-app-server
  ,$error-handler
)

(: set default user --------------------------------------------------------- :)
let $config := admin:appserver-set-default-user(
    $config
   ,$http-app-server
   ,xdmp:eval('
      xquery version "1.0-ml";
      import module "http://marklogic.com/xdmp/security" 
      at "/MarkLogic/security.xqy"; 
      sec:uid-for-name("admin")', (),
  	   <options xmlns="xdmp:eval">
  		 <database>{xdmp:security-database()}</database>
  	   </options>
     )
  )

(: set authentication method to "application-level" ------------------------- :)
let $config := admin:appserver-set-authentication(
    $config
   ,$http-app-server
   ,"application-level"
)


(: -------------------------------------------------------------------------- :)
(: commit changes ----------------------------------------------------------- :)
(: -------------------------------------------------------------------------- :)

return admin:save-configuration($config);
