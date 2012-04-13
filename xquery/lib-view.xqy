xquery version "1.0-ml";

module namespace view = "lib-view";

import module namespace s = "lib-search" at "lib-search.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function view:html-page(
    $title as xs:string,
    $script as node()*,
    $html as node()*,
    $meta-description as xs:string?,
    $meta-content as xs:string?,
    $google-analytics-id as xs:string?,
    $cache-version as xs:double?
)
{
  (xdmp:set-response-content-type("text/html"),
  '<!doctype html>',
  <!-- Conditional comment for mobile ie7 http://blogs.msdn.com/b/iemobile/ -->,
  <!--[if IEMobile 7 ]>    <html class="no-js iem7"> <![endif]-->,
  <!--[if (gt IEMobile 7)|!(IEMobile)]><!-->, <html class="no-js"> <!--<![endif]-->
  
      {view:html-head($title, $meta-description, $meta-content)}
      
      <body>
        <div class="container">
        
          <!-- header -->
          {view:html-header()}
          
          <!-- content -->
          {$html}
          
          <!-- footer -->
          {view:html-footer()}
        </div>
        
        <!-- Included JS Files -->
        <script src="/application/foundation/javascripts/jquery.min.js">//</script>
        <script src="/application/foundation/javascripts/modernizr.foundation.js">//</script>
        <script src="/application/foundation/javascripts/foundation.js">//</script>
        <script src="/application/foundation/javascripts/app.js">//</script>
        <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/jquery-ui.min.js">//</script>
        <script src="/application/jquery/jquery.ui.core.js"></script>
      	<script src="/application/jquery/jquery.ui.widget.js"></script>
      	<script src="/application/jquery/jquery.ui.position.js"></script>
      	<script src="/application/jquery/jquery.ui.autocomplete.js"></script>
        {$script}
	</body>
  </html>
  )  
};

declare function view:html-home-page(
    $title as xs:string,
    $script as node()*,
    $html as node()*,
    $meta-description as xs:string?,
    $meta-content as xs:string?,
    $google-analytics-id as xs:string?,
    $cache-version as xs:double?
)
{
  (: for the time being simply return the basic HTML page :)
  view:html-page(
    $title,
    $script,
    $html,
    $meta-description,
    $meta-content,
    $google-analytics-id,
    $cache-version
  )
};



declare function view:html-browse-page(
    $title as xs:string,
    $script as node()*,
    $html as node()*,
    $meta-description as xs:string?,
    $meta-content as xs:string?,
    $google-analytics-id as xs:string?,
    $cache-version as xs:double?
)
{
  (: for the time being simply return the basic HTML page :)
  view:html-page(
    $title,
    $script,
    $html,
    $meta-description,
    $meta-content,
    $google-analytics-id,
    $cache-version
  )
};


declare function view:html-product-page(
    $title as xs:string,
    $script as node()*,
    $html as node()*,
    $meta-description as xs:string?,
    $meta-content as xs:string?,
    $google-analytics-id as xs:string?,
    $cache-version as xs:double?
)
{
  (: for the time being simply return the basic HTML page :)
  view:html-page(
    $title,
    $script,
    $html,
    $meta-description,
    $meta-content,
    $google-analytics-id,
    $cache-version
  )
};

declare function view:html-search-page(
    $title as xs:string,
    $script as node()*,
    $html as node()*,
    $meta-description as xs:string?,
    $meta-content as xs:string?,
    $google-analytics-id as xs:string?,
    $cache-version as xs:double?
)
{
  let $suggest := <script type="text/javascript">
    
    $(document).ready(function() {{  
      $( "#term" ).autocomplete({{
  			source: "/application/xquery/suggest.xqy",
  			
  			select: function( event, ui ) {{
  				
  			}}
  		}});
		}});
		</script>

  return
  (: for the time being simply return the basic HTML page :)
  view:html-page(
    $title,
    $suggest,
    $html,
    $meta-description,
    $meta-content,
    $google-analytics-id,
    $cache-version
  )
};


declare function view:html-head(
  $title as xs:string,
  $meta-description as xs:string?,
  $meta-content as xs:string?
)
{
      <head profile="http://a9.com/-/spec/opensearch/1.1/">
        <meta charset="utf-8" />
      
      	<!-- Set the viewport width to device width for mobile -->
      	<meta name="viewport" content="width=device-width" />
        <meta name="description" content="{$meta-description}"/>
        <meta name="author" content="{$meta-content}"/>
        <title>{$title}</title>
        
      	<!-- Included CSS Files -->
      	<link rel="stylesheet" href="/application/foundation/stylesheets/foundation.css"/>
      	<link rel="stylesheet" href="/application/foundation/stylesheets/app.css"/>
      	<link rel="stylesheet" href="/application/jquery/css/jquery.ui.theme.css"/>
      	<link rel="stylesheet" href="/application/jquery/css/jquery.ui.autocomplete.css"/>
      	<link rel="stylesheet" href="/application/jquery/css/jqcloud.css"/>
      	<link rel="stylesheet" href="/application/css/styles.css"/>
      	<link rel="stylesheet" href="/application/css/nav.css"/>
      	<!--[if lt IE 9]>
      		<link rel="stylesheet" href="/application/foundation/stylesheets/ie.css"/>
      	<![endif]-->
      
      
      	<!-- IE Fix for HTML5 Tags -->
      	<!--[if lt IE 9]>
      		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js">//</script>
      	<![endif]-->
        
        <!-- Opensearch description document -->
        <link rel="search"
           type="application/opensearchdescription+xml"
           href="http://localhost:60045/application/opensearch.xml"
           title="OECDbooks" />
      </head>
};

declare function view:html-header(

)
{
    <div class="row page-header">
      <div class="seven columns">
        <img src="/assets/images/logooecd_en.png"/>
        <span class="slogan">BETTER BOOKS FOR BETTER LIVES</span>
      </div>
      <div class="five columns" style="text-align:right">
        <img src="http://placehold.it/1x85/ffffff"/>
        {$s:search-form}
      </div>
    </div>
    ,
    <div class="row">
      <div id="nav" class="twelve columns">
        <ul class="navCtn">
          <li class="navItem bFirst">
            <a class="navAct" href="http://www.oecd.org/"><span>OECD Home</span></a>
          </li>
          <li class="navItem activePage">
            <a class="navAct" href="/"><span>Books</span></a>
          </li>
          <li class="navItem">
            <a class="navAct" href="http://www.oecd.org/media"><span>About</span></a>
          </li>
          <li class="navItem bLast">
            <a class="navAct" href="http://www.oecd.org/media"><span>Newsroom</span></a>
          </li>
        </ul>
      </div>
    </div>
};

declare function view:html-footer(

)
{
  <div class="row">
    <div id="footer" class="twelve columns">
			<ul class="footerNav">
				<li>© OECD. All rights reserved</li>
				<li><a href="http://www.oecd.org/document/0,3746,en_2649_201185_1899066_1_1_1_1,00.html">Terms &amp; Conditions</a></li>
				<li><a href="http://www.oecd.org/document/0,3746,en_2649_201185_1899048_1_1_1_1,00.html">Privacy Policy</a></li>
				<li><a href="http://www.marklogic.com/">Powered by MarkLogic</a></li>
				<li><a href="http://www.oecd.org/MyOECD/0,3359,en_17642234_17642806_1_1_1_1_1,00.html">MyOECD</a></li>
				<li><a href="http://www.oecd.org/SiteMap/0,3362,en_2649_201185_1_1_1_1_1,00.html">Site Map</a></li>
				<li><a href="http://www.oecd.org/document/0,3746,en_2649_201185_42516321_1_1_1_1,00.html">Contact Us</a></li>
			</ul>
		</div>
  </div>
};
