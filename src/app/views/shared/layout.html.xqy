xquery version "1.0-ml";
module namespace module = "http://oecd.org/pi/views";

import module namespace search-helper = "http://oecd.org/pi/views/helpers" at "/app/views/helpers/search-helper.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function module:render($params as map:map) {
(
'<!DOCTYPE html>'
,<html>
  <head profile="http://a9.com/-/spec/opensearch/1.1/">
    <meta charset="utf-8" />
    <!-- Set the viewport width to device width for mobile -->
    <meta name="viewport" content="width=device-width" />
    <meta name="description" content="{map:get($params,'meta-description')}"/>
    <meta name="author" content="{map:get($params,'meta-author')}"/>
    <title>{(map:get($params,'title'), "OECD Publication Index")[1]}</title>
    
    <!-- Included CSS Files -->
    <link rel="stylesheet" href="/assets/bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="/assets/bootstrap/css/bootstrap-responsive.min.css"/>
    <link rel="stylesheet" href="/assets/css/styles.css"/>
    <link rel="stylesheet" href="/assets/css/oecd.css"/>
    <link rel="stylesheet" href="/assets/css/browser-update.org.custom.css"/>
    <link rel="shortcut icon" href="/assets/images/favicon.ico"/>
    <!-- IE Fix for HTML5 Tags -->
    <!--[if lt IE 9]>
      <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js">//</script>
    <![endif]-->

    {map:get($params,'header')}
    <!-- Opensearch description document -->
    <link rel="search"
       type="application/opensearchdescription+xml"
       href="http://{(xdmp:get-request-header("X-Forwarded-For"),xdmp:get-request-header("HOST"))[1]}/opensearch.xml"
       title="OECD Publication Index" />
  </head>
  <body>
    <!-- top menu -->
    <header class="jumbotron subhead" id="overview">
      <div class="container">
        <div class="row">
          <div class="span7">
            <img class="logo" src="/assets/images/logooecd_en.png"/>
          </div>
          <div class="span5" style="text-align:right">
            {search-helper:render-search-form()}
          </div>
        </div>
        <div id="nav" class="row">
          <div class="span12">
            <ul class="navCtn">
              <li class="navItem">
                <a class="navAct" href="http://www.oecd.org/"><span>OECD Home</span></a>
              </li>
              <li class="navItem">
                <a class="navAct" href="http://www.oecd.org/about"><span>About</span></a>
              </li>
              <li class="navItem">
                <a class="navAct hasPanel" href="#countriesList"><span>Countries</span></a>
                {$countriesList}
              </li>
              <li class="navItem">
                <a class="navAct hasPanel" href="#topicsList"><span>Topics</span></a>
                {$topicsList}
              </li>
              <li class="navItem">
                <a class="navAct" href="http://www.oecd.org/statistics"><span>Statistics</span></a>
              </li>
              <li class="navItem activePage">
                <a class="navAct" href="/"><span>Publications</span></a>
              </li>
              <li class="navItem">
                <a class="navAct" href="http://www.oecd.org/newsroom"><span>Newsroom</span></a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </header>

    <!-- content -->
    <div class="container">
      {map:get($params,'content')}
    </div>

    <!-- footer -->
    <div class="container">
      <div class="row">
        <div id="footer" class="span12">
          <ul class="footerNav">
            <li>© OECD. All rights reserved</li>
            <li><a href="http://www.oecd.org/document/0,3746,en_2649_201185_1899066_1_1_1_1,00.html">Terms &amp; Conditions</a></li>
            <li><a href="http://www.oecd.org/document/0,3746,en_2649_201185_1899048_1_1_1_1,00.html">Privacy Policy</a></li>
            <li><a href="http://www.marklogic.com/">Powered by MarkLogic</a></li>
            <li><a href="http://www.oecd.org/MyOECD/0,3359,en_17642234_17642806_1_1_1_1_1,00.html">MyOECD</a></li>
            <li><a href="http://www.oecd.org/SiteMap/0,3362,en_2649_201185_1_1_1_1_1,00.html">Site Map</a></li>
            <li class="last"><a href="http://www.oecd.org/document/0,3746,en_2649_201185_42516321_1_1_1_1,00.html">Contact Us</a></li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Included JS Files -->
    <script src="/assets/jquery/jquery-1.8.3.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js"></script>
    {map:get($params,'scripts')}
    <script type="text/javascript">
      $(function() {{
        $('#term').typeahead({{
          minLength: 2,
          source: function typehead_source(query, process) {{
            $.post('/suggest', {{ term: query }}, function(data) {{
              process(data);
            }});
          }},
          updater: function typeahead_updater(item) {{
            var oldval = this.$element.val();
            var regex = new RegExp(oldval,'i');
            if(regex.test(item)) {{
              this.$element.val(item);
            }}
            else {{
              item = oldval;
            }}
            $("#in").val(''); // clean facets
            $("#searchForm").submit();
            return item;
          }}
        }});
        // remove facet filters on manual submit
        $('#searchForm').on('submit', function(event) {{
          if(!event.isTrigger)
            $("#in").val('');
        }});
      }});
    </script>
    <script src="/assets/js/oecd-layout.js"></script>
    <script type="text/javascript"> 
        /* normally, one should leave this empty to let "browser-update.org" make the
           choice whether to alert or not. but they consider ie8 ok, but I don't,
           so I have added them here. FIXME: needs regular updates (or maybe can be made
           empty again, after W7 migration at OECD is over.
        */
        var $buoop = {{vs:{{i:8,f:3.6,o:10.6,s:4,n:10}}}};  
        $buoop.ol = window.onload; 
        window.onload=function(){{ 
             try {{ if ($buoop.ol) $buoop.ol();}} catch (e) {{}} 
             var e = document.createElement("script"); 
             e.setAttribute("type", "text/javascript"); 
             e.setAttribute("src", "http://browser-update.org/update.js"); 
             document.body.appendChild(e); 
        }}
    </script>
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-38704931-1']);
        _gaq.push(['_trackPageview']);
        (function() {{
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        }})();
    </script>
    
    <div id="getsat-widget-4541"></div>
    <script type="text/javascript" src="https://loader.engage.gsfn.us/loader.js"></script>
    <script type="text/javascript">if (typeof GSFN !== "undefined"){{ GSFN.loadWidget(4541,{{"containerId":"getsat-widget-4541"}});}}</script>
  </body>
</html>
)
};








(: should be stored elsewhere... :)
declare private variable $countriesList as element(div) := <div class="mainPane clearfix" id="countriesList">
  <ul class="tabs">
    <li><a href="#" class="current">A-C</a></li>
    <li><a href="#">D-I</a></li>
    <li><a href="#">J-M</a></li>
    <li><a href="#">N-R</a></li>
    <li><a href="#">S-T</a></li>
    <li><a href="#">U-Z</a></li>
  </ul>
  <!-- start of countries list -->
  <div class="cList">
    <!-- navigation object : Countries List -->
      <div class="pane" style="display: block;">
        <div class="li_container" id="li_container1">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/afghanistan/">Afghanistan</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/albania/">Albania</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/algeria/">Algeria</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/americansamoa/">American Samoa</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/andorra/">Andorra</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/angola/">Angola</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/anguilla/">Anguilla</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/antarctica/">Antarctica</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/antiguaandbarbuda/">Antigua and Barbuda</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/argentina/">Argentina</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/armenia/">Armenia</a>
            </li>
            <li class="A li_col1">
              <a href="http://www.oecd.org/countries/aruba/">Aruba</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="A li_col2">
              <a href="http://www.oecd.org/australia/">Australia</a>
            </li>
            <li class="A li_col2">
              <a href="http://www.oecd.org/austria/">Austria</a>
            </li>
            <li class="A li_col2">
              <a href="http://www.oecd.org/countries/azerbaijan/">Azerbaijan</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/bahamas/">Bahamas</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/bahrain/">Bahrain</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/bangladesh/">Bangladesh</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/barbados/">Barbados</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/belarus/">Belarus</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/belgium/">Belgium</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/belize/">Belize</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/benin/">Benin</a>
            </li>
            <li class="B li_col2">
              <a href="http://www.oecd.org/countries/bermuda/">Bermuda</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bhutan/">Bhutan</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bolivia/">Bolivia</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bosniaandherzegovina/">Bosnia and Herzegovina</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/botswana/">Botswana</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bouvetisland/">Bouvet Island</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/brazil/">Brazil</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/britishindianoceanterritory/">British Indian Ocean Territory</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bruneidarussalam/">Brunei Darussalam</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/bulgaria/">Bulgaria</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/burkinafaso/">Burkina Faso</a>
            </li>
            <li class="B li_col3">
              <a href="http://www.oecd.org/countries/burundi/">Burundi</a>
            </li>
            <li class="C li_col3">
              <a href="http://www.oecd.org/countries/cambodia/">Cambodia</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/cameroon/">Cameroon</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/canada/">Canada</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/capeverde/">Cape Verde</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/caymanislands/">Cayman Islands</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/centralafricanrepublic/">Central African Republic</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/chad/">Chad</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/chile/">Chile</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/china/">China (People’s Republic of)</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/chinesetaipei/">Chinese Taipei</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/christmasisland/">Christmas Island</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/cocoskeelingislands/">Cocos (Keeling) Islands</a>
            </li>
            <li class="C li_col4">
              <a href="http://www.oecd.org/countries/colombia/">Colombia</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/comoros/">Comoros</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/congo/">Congo</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/cookislands/">Cook Islands</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/costarica/">Costa Rica</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/croatia/">Croatia</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/cuba/">Cuba</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/cyprus/">Cyprus</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/czech/">Czech Republic</a>
            </li>
            <li class="C li_col5">
              <a href="http://www.oecd.org/countries/cotedivoire/">Côte d'Ivoire</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
      <div class="pane" style="display: none;">
        <div class="li_container" id="li_container2">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="D li_col1">
              <a href="http://www.oecd.org/countries/democraticpeoplesrepublicofkorea/">Democratic People's Republic of
                Korea</a>
            </li>
            <li class="D li_col1">
              <a href="http://www.oecd.org/countries/democraticrepublicofthecongo/">Democratic Republic of the Congo</a>
            </li>
            <li class="D li_col1">
              <a href="http://www.oecd.org/denmark/">Denmark</a>
            </li>
            <li class="D li_col1">
              <a href="http://www.oecd.org/countries/djibouti/">Djibouti</a>
            </li>
            <li class="D li_col1">
              <a href="http://www.oecd.org/countries/dominica/">Dominica</a>
            </li>
            <li class="D li_col1">
              <a href="http://www.oecd.org/countries/dominicanrepublic/">Dominican Republic</a>
            </li>
            <li class="E li_col1">
              <a href="http://www.oecd.org/countries/ecuador/">Ecuador</a>
            </li>
            <li class="E li_col1">
              <a href="http://www.oecd.org/countries/egypt/">Egypt</a>
            </li>
            <li class="E li_col1">
              <a href="http://www.oecd.org/countries/elsalvador/">El Salvador</a>
            </li>
            <li class="E li_col1">
              <a href="http://www.oecd.org/countries/equatorialguinea/">Equatorial Guinea</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="E li_col2">
              <a href="http://www.oecd.org/countries/eritrea/">Eritrea</a>
            </li>
            <li class="E li_col2">
              <a href="http://www.oecd.org/estonia/">Estonia</a>
            </li>
            <li class="E li_col2">
              <a href="http://www.oecd.org/countries/ethiopia/">Ethiopia</a>
            </li>
            <li class="E li_col2">
              <a href="http://www.oecd.org/eu/">European Union</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/countries/faeroeislands/">Faeroe Islands</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/countries/fiji/">Fiji</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/finland/">Finland</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/countries/formeryugoslavrepublicofmacedoniafyrom/">Former Yugoslav Republic of
                Macedonia (FYROM)</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/france/">France</a>
            </li>
            <li class="F li_col2">
              <a href="http://www.oecd.org/countries/frenchguiana/">French Guiana</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="F li_col3">
              <a href="http://www.oecd.org/countries/frenchpolynesia/">French Polynesia</a>
            </li>
            <li class="F li_col3">
              <a href="http://www.oecd.org/countries/frenchsouthernterritories/">French Southern Territories</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/gabon/">Gabon</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/gambia/">Gambia</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/georgia/">Georgia</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/germany/">Germany</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/ghana/">Ghana</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/gibraltar/">Gibraltar</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/greece/">Greece</a>
            </li>
            <li class="G li_col3">
              <a href="http://www.oecd.org/countries/greenland/">Greenland</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/grenada/">Grenada</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guam/">Guam</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guatemala/">Guatemala</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guernsey/">Guernsey</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guinea/">Guinea</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guinea-bissau/">Guinea-Bissau</a>
            </li>
            <li class="G li_col4">
              <a href="http://www.oecd.org/countries/guyana/">Guyana</a>
            </li>
            <li class="H li_col4">
              <a href="http://www.oecd.org/countries/haiti/">Haiti</a>
            </li>
            <li class="H li_col4">
              <a href="http://www.oecd.org/countries/honduras/">Honduras</a>
            </li>
            <li class="H li_col4">
              <a href="http://www.oecd.org/countries/hongkongchina/">Hong Kong, China</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="H li_col5">
              <a href="http://www.oecd.org/hungary/">Hungary</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/iceland/">Iceland</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/india/">India</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/indonesia/">Indonesia</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/countries/iraq/">Iraq</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/ireland/">Ireland</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/countries/islamicrepublicofiran/">Islamic Republic of Iran</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/countries/isleofman/">Isle of Man</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/israel/">Israel</a>
            </li>
            <li class="I li_col5">
              <a href="http://www.oecd.org/italy/">Italy</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
      <div class="pane" style="display: none;">
        <div class="li_container" id="li_container3">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="J li_col1">
              <a href="http://www.oecd.org/countries/jamaica/">Jamaica</a>
            </li>
            <li class="J li_col1">
              <a href="http://www.oecd.org/japan/">Japan</a>
            </li>
            <li class="J li_col1">
              <a href="http://www.oecd.org/countries/jersey/">Jersey</a>
            </li>
            <li class="J li_col1">
              <a href="http://www.oecd.org/countries/jordan/">Jordan</a>
            </li>
            <li class="K li_col1">
              <a href="http://www.oecd.org/countries/kazakhstan/">Kazakhstan</a>
            </li>
            <li class="K li_col1">
              <a href="http://www.oecd.org/countries/kenya/">Kenya</a>
            </li>
            <li class="K li_col1">
              <a href="http://www.oecd.org/countries/kiribati/">Kiribati</a>
            </li>
            <li class="K li_col1">
              <a href="http://www.oecd.org/korea/">Korea</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="K li_col2">
              <a href="http://www.oecd.org/countries/kuwait/">Kuwait</a>
            </li>
            <li class="K li_col2">
              <a href="http://www.oecd.org/countries/kyrgyzstan/">Kyrgyzstan</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/laopeoplesdemocraticrepublic/">Lao People's Democratic Republic</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/latvia/">Latvia</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/lebanon/">Lebanon</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/lesotho/">Lesotho</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/liberia/">Liberia</a>
            </li>
            <li class="L li_col2">
              <a href="http://www.oecd.org/countries/libya/">Libya</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="L li_col3">
              <a href="http://www.oecd.org/countries/liechtenstein/">Liechtenstein</a>
            </li>
            <li class="L li_col3">
              <a href="http://www.oecd.org/countries/lithuania/">Lithuania</a>
            </li>
            <li class="L li_col3">
              <a href="http://www.oecd.org/luxembourg/">Luxembourg</a>
            </li>
            <li class="M li_col3">
              <a href="http://www.oecd.org/countries/macaochina/">Macao (China)</a>
            </li>
            <li class="M li_col3">
              <a href="http://www.oecd.org/countries/madagascar/">Madagascar</a>
            </li>
            <li class="M li_col3">
              <a href="http://www.oecd.org/countries/malawi/">Malawi</a>
            </li>
            <li class="M li_col3">
              <a href="http://www.oecd.org/countries/malaysia/">Malaysia</a>
            </li>
            <li class="M li_col3">
              <a href="http://www.oecd.org/countries/maldives/">Maldives</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/mali/">Mali</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/malta/">Malta</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/marshallislands/">Marshall Islands</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/mauritania/">Mauritania</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/mauritius/">Mauritius</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/mayotte/">Mayotte</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/mexico/">Mexico</a>
            </li>
            <li class="M li_col4">
              <a href="http://www.oecd.org/countries/micronesiafederatedstatesof/">Micronesia (Federated States of)</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/moldova/">Moldova</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/monaco/">Monaco</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/mongolia/">Mongolia</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/montenegro/">Montenegro</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/montserrat/">Montserrat</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/morocco/">Morocco</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/mozambique/">Mozambique</a>
            </li>
            <li class="M li_col5">
              <a href="http://www.oecd.org/countries/myanmar/">Myanmar</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
      <div class="pane" style="display: none;">
        <div class="li_container" id="li_container4">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="N li_col1">
              <a href="http://www.oecd.org/countries/namibia/">Namibia</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/countries/nauru/">Nauru</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/countries/nepal/">Nepal</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/netherlands/">Netherlands</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/countries/netherlandsantilles/">Netherlands Antilles</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/countries/newcaledonia/">New Caledonia</a>
            </li>
            <li class="N li_col1">
              <a href="http://www.oecd.org/newzealand/">New Zealand</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/nicaragua/">Nicaragua</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/niger/">Niger</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/nigeria/">Nigeria</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/niue/">Niue</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/norfolkisland/">Norfolk Island</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/countries/northernmarianasislands/">Northern Marianas Islands</a>
            </li>
            <li class="N li_col2">
              <a href="http://www.oecd.org/norway/">Norway</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="O li_col3">
              <a href="http://www.oecd.org/countries/oman/">Oman</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/pakistan/">Pakistan</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/palau/">Palau</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/palestinianadministeredareas/">Palestinian Administered Areas</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/panama/">Panama</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/papuanewguinea/">Papua New Guinea</a>
            </li>
            <li class="P li_col3">
              <a href="http://www.oecd.org/countries/paraguay/">Paraguay</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="P li_col4">
              <a href="http://www.oecd.org/countries/peru/">Peru</a>
            </li>
            <li class="P li_col4">
              <a href="http://www.oecd.org/countries/philippines/">Philippines</a>
            </li>
            <li class="P li_col4">
              <a href="http://www.oecd.org/countries/pitcairn/">Pitcairn</a>
            </li>
            <li class="P li_col4">
              <a href="http://www.oecd.org/poland/">Poland</a>
            </li>
            <li class="P li_col4">
              <a href="http://www.oecd.org/portugal/">Portugal</a>
            </li>
            <li class="P li_col4">
              <a href="http://www.oecd.org/countries/puertorico/">Puerto Rico</a>
            </li>
            <li class="Q li_col4">
              <a href="http://www.oecd.org/countries/qatar/">Qatar</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="R li_col5">
              <a href="http://www.oecd.org/countries/romania/">Romania</a>
            </li>
            <li class="R li_col5">
              <a href="http://www.oecd.org/russia/">Russian Federation</a>
            </li>
            <li class="R li_col5">
              <a href="http://www.oecd.org/countries/rwanda/">Rwanda</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
      <div class="pane" style="display: none;">
        <div class="li_container" id="li_container5">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/sainthelena/">Saint Helena</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/saintkittsandnevis/">Saint Kitts and Nevis</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/saintlucia/">Saint Lucia</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/saintvincentandthegrenadines/">Saint Vincent and the Grenadines</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/samoa/">Samoa</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/sanmarino/">San Marino</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/saotomeandprincipe/">Sao Tome and Principe</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/saudiarabia/">Saudi Arabia</a>
            </li>
            <li class="S li_col1">
              <a href="http://www.oecd.org/countries/senegal/">Senegal</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/serbia/">Serbia</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/serbiaandmontenegropre-june2006/">Serbia and Montenegro (pre-June
                2006)</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/seychelles/">Seychelles</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/sierraleone/">Sierra Leone</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/singapore/">Singapore</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/slovakia/">Slovak Republic</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/slovenia/">Slovenia</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/solomonislands/">Solomon Islands</a>
            </li>
            <li class="S li_col2">
              <a href="http://www.oecd.org/countries/somalia/">Somalia</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="S li_col3">
              <a href="http://www.oecd.org/southafrica/">South Africa</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/southgeorgiaandthesouthsandwichislands/">South Georgia and the South
                Sandwich Islands</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/southsudan/">South Sudan</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/spain/">Spain</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/srilanka/">Sri Lanka</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/stpierreandmiquelon/">St. Pierre and Miquelon</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/sudan/">Sudan</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/suriname/">Suriname</a>
            </li>
            <li class="S li_col3">
              <a href="http://www.oecd.org/countries/svalbardandjanmayenislands/">Svalbard and Jan Mayen Islands</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="S li_col4">
              <a href="http://www.oecd.org/countries/swaziland/">Swaziland</a>
            </li>
            <li class="S li_col4">
              <a href="http://www.oecd.org/sweden/">Sweden</a>
            </li>
            <li class="S li_col4">
              <a href="http://www.oecd.org/switzerland/">Switzerland</a>
            </li>
            <li class="S li_col4">
              <a href="http://www.oecd.org/countries/syrianarabrepublic/">Syrian Arab Republic</a>
            </li>
            <li class="T li_col4">
              <a href="http://www.oecd.org/countries/tajikistan/">Tajikistan</a>
            </li>
            <li class="T li_col4">
              <a href="http://www.oecd.org/countries/tanzania/">Tanzania</a>
            </li>
            <li class="T li_col4">
              <a href="http://www.oecd.org/countries/thailand/">Thailand</a>
            </li>
            <li class="T li_col4">
              <a href="http://www.oecd.org/countries/timor-leste/">Timor-Leste</a>
            </li>
            <li class="T li_col4">
              <a href="http://www.oecd.org/countries/togo/">Togo</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/tokelau/">Tokelau</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/tonga/">Tonga</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/trinidadandtobago/">Trinidad and Tobago</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/tunisia/">Tunisia</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/turkey/">Turkey</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/turkmenistan/">Turkmenistan</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/turksandcaicosislands/">Turks and Caicos Islands</a>
            </li>
            <li class="T li_col5">
              <a href="http://www.oecd.org/countries/tuvalu/">Tuvalu</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
      <div class="pane" style="display: none;">
        <div class="li_container" id="li_container6">
          <ul class="li_cont1" style="float: left; width: 173px;">
            <li class="U li_col1">
              <a href="http://www.oecd.org/countries/uganda/">Uganda</a>
            </li>
            <li class="U li_col1">
              <a href="http://www.oecd.org/countries/ukraine/">Ukraine</a>
            </li>
            <li class="U li_col1">
              <a href="http://www.oecd.org/countries/unitedarabemirates/">United Arab Emirates</a>
            </li>
            <li class="U li_col1">
              <a href="http://www.oecd.org/unitedkingdom/">United Kingdom</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont2 ">
            <li class="U li_col2">
              <a href="http://www.oecd.org/unitedstates/">United States</a>
            </li>
            <li class="U li_col2">
              <a href="http://www.oecd.org/countries/unitedstatesminoroutlyingislands/">United States Minor Outlying
                Islands</a>
            </li>
            <li class="U li_col2">
              <a href="http://www.oecd.org/countries/unitedstatesvirginislands/">United States Virgin Islands</a>
            </li>
            <li class="U li_col2">
              <a href="http://www.oecd.org/countries/uruguay/">Uruguay</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont3 ">
            <li class="U li_col3">
              <a href="http://www.oecd.org/countries/uzbekistan/">Uzbekistan</a>
            </li>
            <li class="V li_col3">
              <a href="http://www.oecd.org/countries/vanuatu/">Vanuatu</a>
            </li>
            <li class="V li_col3">
              <a href="http://www.oecd.org/countries/vaticancitystateholysee/">Vatican City State (Holy See)</a>
            </li>
            <li class="V li_col3">
              <a href="http://www.oecd.org/countries/venezuela/">Venezuela</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont4 ">
            <li class="V li_col4">
              <a href="http://www.oecd.org/countries/vietnam/">Vietnam</a>
            </li>
            <li class="V li_col4">
              <a href="http://www.oecd.org/countries/virginislandsuk/">Virgin Islands (UK)</a>
            </li>
            <li class="W li_col4">
              <a href="http://www.oecd.org/countries/wallisandfutunaislands/">Wallis and Futuna Islands</a>
            </li>
            <li class="W li_col4">
              <a href="http://www.oecd.org/countries/westernsahara/">Western Sahara</a>
            </li>
          </ul>
          <ul style="float:left; width: 173px;" class="li_cont5 ">
            <li class="Y li_col5">
              <a href="http://www.oecd.org/countries/yemen/">Yemen</a>
            </li>
            <li class="Z li_col5">
              <a href="http://www.oecd.org/countries/zambia/">Zambia</a>
            </li>
            <li class="Z li_col5">
              <a href="http://www.oecd.org/countries/zimbabwe/">Zimbabwe</a>
            </li>
          </ul>
          <div style="clear:both; overflow:hidden; height:0px;"/>
        </div>
      </div>
  </div>
  <!-- end of countries list -->
</div>;

declare private variable $topicsList := <div class="mainPane clearfix" id="topicsList">
  <div class="pane">
    <!-- navigation object : Topics List -->
    <div class="li_container" id="li_container7">
      <ul class="li_cont1" style="float: left; width: 217px;">
        <li class="li_col1">
          <a href="http://www.oecd.org/agriculture/">Agriculture and fisheries</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/corruption/">Bribery and corruption</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/chemicalsafety/">Chemical safety and biosafety</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/competition/">Competition</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/corporate/">Corporate governance</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/development/">Development</a>
        </li>
        <li class="li_col1">
          <a href="http://www.oecd.org/economy/">Economy</a>
        </li>
      </ul>
      <ul style="float:left; width: 217px;" class="li_cont2 ">
        <li class="li_col2">
          <a href="http://www.oecd.org/education/">Education</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/employment/">Employment</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/environment/">Environment</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/finance/">Finance</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/greengrowth/">Green growth and sustainable development</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/health/">Health</a>
        </li>
        <li class="li_col2">
          <a href="http://www.oecd.org/industry/">Industry and entrepreneurship</a>
        </li>
      </ul>
      <ul style="float:left; width: 217px;" class="li_cont3 ">
        <li class="li_col3">
          <a href="http://www.oecd.org/innovation/">Innovation</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/insurance/">Insurance and pensions</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/migration/">International migration</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/internet/">Internet</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/investment/">Investment</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/governance/">Public governance</a>
        </li>
        <li class="li_col3">
          <a href="http://www.oecd.org/regional/">Regional, rural and urban development</a>
        </li>
      </ul>
      <ul style="float:left; width: 217px;" class="li_cont4 ">
        <li class="li_col4">
          <a href="http://www.oecd.org/regreform/">Regulatory reform</a>
        </li>
        <li class="li_col4">
          <a href="http://www.oecd.org/science/">Science and technology</a>
        </li>
        <li class="li_col4">
          <a href="http://www.oecd.org/social/">Social and welfare issues</a>
        </li>
        <li class="li_col4">
          <a href="http://www.oecd.org/tax/">Tax</a>
        </li>
        <li class="li_col4">
          <a href="http://www.oecd.org/trade/">Trade</a>
        </li>
      </ul>
      <div style="clear:both; overflow:hidden; height:0px;"/>
    </div>
  </div>
</div>;
