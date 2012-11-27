xquery version "1.0-ml";

(: TODO: take on the role of an Error document in the sense of Apache :)

declare variable $error:errors as node()* external;

xdmp:set-response-content-type("text/plain"),
xdmp:get-response-code(),
$error:errors

