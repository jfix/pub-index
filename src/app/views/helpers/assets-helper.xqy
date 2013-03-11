xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views/helpers";

import module namespace config = "http://oecd.org/pi/config" at "/app/config.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function module:script($asset as xs:string) {
  <script src="{module:cachebust($asset)}"></script>
};

declare function module:style($asset as xs:string) {
  <link rel="stylesheet" href="{module:cachebust($asset)}"/>
};

(: search in cachebust variable, if not found, append version :)
declare function module:cachebust($asset as xs:string) {
	concat($asset, "?", $config:version)
};
