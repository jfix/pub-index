xquery version "1.0-ml";

import module namespace ms = "http://oecd.org/pi/models/search" at "/app/models/search.xqy";

declare namespace oe= "http://www.oecd.org/metapub/oecdOrg/ns/";
declare namespace dt = "http://purl.org/dc/terms/";

(: countries locations, to be moved somewhere else :)
let $locations := map:map()
  ,$void := map:put($locations, 'af', <location lat='33.00' long='65.00'/>)
  ,$void := map:put($locations, 'za', <location lat='-29.00' long='24.00'/>)
  ,$void := map:put($locations, 'al', <location lat='41.00' long='20.00'/>)
  ,$void := map:put($locations, 'dz', <location lat='28.00' long='3.00'/>)
  ,$void := map:put($locations, 'de', <location lat='51.00' long='9.00'/>)
  ,$void := map:put($locations, 'ad', <location lat='42.30' long='1.30'/>)
  ,$void := map:put($locations, 'ao', <location lat='-12.30' long='18.30'/>)
  ,$void := map:put($locations, 'ai', <location lat='18.15' long='-63.10'/>)
  ,$void := map:put($locations, 'aq', <location lat='-90.00' long='0.00'/>)
  ,$void := map:put($locations, 'ag', <location lat='17.03' long='-61.48'/>)
  ,$void := map:put($locations, 'an', <location lat='12.15' long='-68.45'/>)
  ,$void := map:put($locations, 'sa', <location lat='25.00' long='45.00'/>)
  ,$void := map:put($locations, 'ar', <location lat='-34.00' long='-64.00'/>)
  ,$void := map:put($locations, 'am', <location lat='40.00' long='45.00'/>)
  ,$void := map:put($locations, 'aw', <location lat='12.30' long='-69.58'/>)
  ,$void := map:put($locations, 'au', <location lat='-27.00' long='133.00'/>)
  ,$void := map:put($locations, 'at', <location lat='47.20' long='13.20'/>)
  ,$void := map:put($locations, 'az', <location lat='40.30' long='47.30'/>)
  ,$void := map:put($locations, 'bs', <location lat='24.15' long='-76.00'/>)
  ,$void := map:put($locations, 'bh', <location lat='26.00' long='50.33'/>)
  ,$void := map:put($locations, 'bd', <location lat='24.00' long='90.00'/>)
  ,$void := map:put($locations, 'bb', <location lat='13.10' long='-59.32'/>)
  ,$void := map:put($locations, 'by', <location lat='53.00' long='28.00'/>)
  ,$void := map:put($locations, 'be', <location lat='50.50' long='4.00'/>)
  ,$void := map:put($locations, 'bz', <location lat='17.15' long='-88.45'/>)
  ,$void := map:put($locations, 'bj', <location lat='9.30' long='2.15'/>)
  ,$void := map:put($locations, 'bm', <location lat='32.20' long='-64.45'/>)
  ,$void := map:put($locations, 'bt', <location lat='27.30' long='90.30'/>)
  ,$void := map:put($locations, 'bo', <location lat='-17.00' long='-65.00'/>)
  ,$void := map:put($locations, 'ba', <location lat='44.00' long='18.00'/>)
  ,$void := map:put($locations, 'bw', <location lat='-22.00' long='24.00'/>)
  ,$void := map:put($locations, 'bv', <location lat='-54.26' long='3.24'/>)
  ,$void := map:put($locations, 'br', <location lat='-10.00' long='-55.00'/>)
  ,$void := map:put($locations, 'bn', <location lat='4.30' long='114.40'/>)
  ,$void := map:put($locations, 'bg', <location lat='43.00' long='25.00'/>)
  ,$void := map:put($locations, 'bf', <location lat='13.00' long='-2.00'/>)
  ,$void := map:put($locations, 'bi', <location lat='-3.30' long='30.00'/>)
  ,$void := map:put($locations, 'ky', <location lat='19.30' long='-80.30'/>)
  ,$void := map:put($locations, 'kh', <location lat='13.00' long='105.00'/>)
  ,$void := map:put($locations, 'cm', <location lat='6.00' long='12.00'/>)
  ,$void := map:put($locations, 'ca', <location lat='60.00' long='-95.00'/>)
  ,$void := map:put($locations, 'cv', <location lat='16.00' long='-24.00'/>)
  ,$void := map:put($locations, 'cf', <location lat='7.00' long='21.00'/>)
  ,$void := map:put($locations, 'cl', <location lat='-30.00' long='-71.00'/>)
  ,$void := map:put($locations, 'cn', <location lat='35.00' long='105.00'/>)
  ,$void := map:put($locations, 'cx', <location lat='-10.30' long='105.40'/>)
  ,$void := map:put($locations, 'cy', <location lat='35.00' long='33.00'/>)
  ,$void := map:put($locations, 'cc', <location lat='-12.30' long='96.50'/>)
  ,$void := map:put($locations, 'co', <location lat='4.00' long='-72.00'/>)
  ,$void := map:put($locations, 'km', <location lat='-12.10' long='44.15'/>)
  ,$void := map:put($locations, 'cg', <location lat='-1.00' long='15.00'/>)
  ,$void := map:put($locations, 'cd', <location lat='0.00' long='25.00'/>)
  ,$void := map:put($locations, 'ck', <location lat='-21.14' long='-159.46'/>)
  ,$void := map:put($locations, 'kr', <location lat='37.00' long='127.30'/>)
  ,$void := map:put($locations, 'kp', <location lat='40.00' long='127.00'/>)
  ,$void := map:put($locations, 'cr', <location lat='10.00' long='-84.00'/>)
  ,$void := map:put($locations, 'ci', <location lat='8.00' long='-5.00'/>)
  ,$void := map:put($locations, 'hr', <location lat='45.10' long='15.30'/>)
  ,$void := map:put($locations, 'cu', <location lat='21.30' long='-80.00'/>)
  ,$void := map:put($locations, 'dk', <location lat='56.00' long='10.00'/>)
  ,$void := map:put($locations, 'dj', <location lat='11.30' long='43.00'/>)
  ,$void := map:put($locations, 'do', <location lat='19.00' long='-70.40'/>)
  ,$void := map:put($locations, 'dm', <location lat='15.25' long='-61.20'/>)
  ,$void := map:put($locations, 'eg', <location lat='27.00' long='30.00'/>)
  ,$void := map:put($locations, 'sv', <location lat='13.50' long='-88.55'/>)
  ,$void := map:put($locations, 'ae', <location lat='24.00' long='54.00'/>)
  ,$void := map:put($locations, 'ec', <location lat='-2.00' long='-77.30'/>)
  ,$void := map:put($locations, 'er', <location lat='15.00' long='39.00'/>)
  ,$void := map:put($locations, 'es', <location lat='40.00' long='-4.00'/>)
  ,$void := map:put($locations, 'ee', <location lat='59.00' long='26.00'/>)
  ,$void := map:put($locations, 'us', <location lat='38.00' long='-97.00'/>)
  ,$void := map:put($locations, 'et', <location lat='8.00' long='38.00'/>)
  ,$void := map:put($locations, 'fk', <location lat='-51.45' long='-59.00'/>)
  ,$void := map:put($locations, 'fo', <location lat='62.00' long='-7.00'/>)
  ,$void := map:put($locations, 'fj', <location lat='-18.00' long='175.00'/>)
  ,$void := map:put($locations, 'fi', <location lat='64.00' long='26.00'/>)
  ,$void := map:put($locations, 'fr', <location lat='46.53' long='2.43'/>)
  ,$void := map:put($locations, 'ga', <location lat='-1.00' long='11.45'/>)
  ,$void := map:put($locations, 'gm', <location lat='13.28' long='-16.34'/>)
  ,$void := map:put($locations, 'ge', <location lat='42.00' long='43.30'/>)
  ,$void := map:put($locations, 'gs', <location lat='-54.30' long='-37.00'/>)
  ,$void := map:put($locations, 'gh', <location lat='8.00' long='-2.00'/>)
  ,$void := map:put($locations, 'gi', <location lat='36.08' long='-5.21'/>)
  ,$void := map:put($locations, 'gr', <location lat='39.00' long='22.00'/>)
  ,$void := map:put($locations, 'gd', <location lat='12.07' long='-61.40'/>)
  ,$void := map:put($locations, 'gl', <location lat='72.00' long='-40.00'/>)
  ,$void := map:put($locations, 'gp', <location lat='16.15' long='-61.35'/>)
  ,$void := map:put($locations, 'gu', <location lat='13.28' long='144.47'/>)
  ,$void := map:put($locations, 'gt', <location lat='15.30' long='-90.15'/>)
  ,$void := map:put($locations, 'gg', <location lat='49.28' long='-2.35'/>)
  ,$void := map:put($locations, 'gn', <location lat='11.00' long='-10.00'/>)
  ,$void := map:put($locations, 'gw', <location lat='12.00' long='-15.00'/>)
  ,$void := map:put($locations, 'gq', <location lat='2.00' long='10.00'/>)
  ,$void := map:put($locations, 'gy', <location lat='5.00' long='-59.00'/>)
  ,$void := map:put($locations, 'gf', <location lat='4.00' long='-53.00'/>)
  ,$void := map:put($locations, 'ht', <location lat='19.00' long='-72.25'/>)
  ,$void := map:put($locations, 'hm', <location lat='-53.06' long='72.31'/>)
  ,$void := map:put($locations, 'hn', <location lat='15.00' long='-86.30'/>)
  ,$void := map:put($locations, 'hk', <location lat='22.15' long='114.10'/>)
  ,$void := map:put($locations, 'hu', <location lat='47.00' long='20.00'/>)
  ,$void := map:put($locations, 'im', <location lat='54.15' long='-4.30'/>)
  ,$void := map:put($locations, 'vg', <location lat='18.30' long='-64.30'/>)
  ,$void := map:put($locations, 'vi', <location lat='18.20' long='-64.50'/>)
  ,$void := map:put($locations, 'in', <location lat='20.00' long='77.00'/>)
  ,$void := map:put($locations, 'id', <location lat='-5.00' long='120.00'/>)
  ,$void := map:put($locations, 'ir', <location lat='32.00' long='53.00'/>)
  ,$void := map:put($locations, 'iq', <location lat='33.00' long='44.00'/>)
  ,$void := map:put($locations, 'ie', <location lat='53.00' long='-8.00'/>)
  ,$void := map:put($locations, 'is', <location lat='65.00' long='-18.00'/>)
  ,$void := map:put($locations, 'il', <location lat='31.30' long='34.45'/>)
  ,$void := map:put($locations, 'it', <location lat='42.50' long='12.50'/>)
  ,$void := map:put($locations, 'jm', <location lat='18.15' long='-77.30'/>)
  ,$void := map:put($locations, 'jp', <location lat='36.00' long='138.00'/>)
  ,$void := map:put($locations, 'je', <location lat='49.15' long='-2.10'/>)
  ,$void := map:put($locations, 'jo', <location lat='31.00' long='36.00'/>)
  ,$void := map:put($locations, 'kz', <location lat='48.00' long='68.00'/>)
  ,$void := map:put($locations, 'ke', <location lat='1.00' long='38.00'/>)
  ,$void := map:put($locations, 'kg', <location lat='41.00' long='75.00'/>)
  ,$void := map:put($locations, 'ki', <location lat='1.25' long='173.00'/>)
  ,$void := map:put($locations, 'kw', <location lat='29.30' long='45.45'/>)
  ,$void := map:put($locations, 'la', <location lat='18.00' long='105.00'/>)
  ,$void := map:put($locations, 'ls', <location lat='-29.30' long='28.30'/>)
  ,$void := map:put($locations, 'lv', <location lat='57.00' long='25.00'/>)
  ,$void := map:put($locations, 'lb', <location lat='33.50' long='35.50'/>)
  ,$void := map:put($locations, 'lr', <location lat='6.30' long='-9.30'/>)
  ,$void := map:put($locations, 'ly', <location lat='25.00' long='17.00'/>)
  ,$void := map:put($locations, 'li', <location lat='47.16' long='9.32'/>)
  ,$void := map:put($locations, 'lt', <location lat='56.00' long='24.00'/>)
  ,$void := map:put($locations, 'lu', <location lat='49.45' long='6.10'/>)
  ,$void := map:put($locations, 'mo', <location lat='22.10' long='113.33'/>)
  ,$void := map:put($locations, 'mk', <location lat='41.50' long='22.00'/>)
  ,$void := map:put($locations, 'mg', <location lat='-20.00' long='47.00'/>)
  ,$void := map:put($locations, 'my', <location lat='2.30' long='112.30'/>)
  ,$void := map:put($locations, 'mw', <location lat='-13.30' long='34.00'/>)
  ,$void := map:put($locations, 'mv', <location lat='3.15' long='73.00'/>)
  ,$void := map:put($locations, 'ml', <location lat='17.00' long='-4.00'/>)
  ,$void := map:put($locations, 'mt', <location lat='35.50' long='14.35'/>)
  ,$void := map:put($locations, 'mp', <location lat='15.12' long='145.45'/>)
  ,$void := map:put($locations, 'ma', <location lat='32.00' long='-5.00'/>)
  ,$void := map:put($locations, 'mh', <location lat='9.00' long='168.00'/>)
  ,$void := map:put($locations, 'mq', <location lat='14.40' long='-61.00'/>)
  ,$void := map:put($locations, 'mu', <location lat='-20.17' long='57.33'/>)
  ,$void := map:put($locations, 'mr', <location lat='20.00' long='-12.00'/>)
  ,$void := map:put($locations, 'yt', <location lat='-12.50' long='45.10'/>)
  ,$void := map:put($locations, 'mx', <location lat='23.00' long='-102.00'/>)
  ,$void := map:put($locations, 'fm', <location lat='6.55' long='158.15'/>)
  ,$void := map:put($locations, 'md', <location lat='47.00' long='29.00'/>)
  ,$void := map:put($locations, 'mc', <location lat='43.44' long='7.24'/>)
  ,$void := map:put($locations, 'mn', <location lat='46.00' long='105.00'/>)
  ,$void := map:put($locations, 'me', <location lat='42.30' long='19.18'/>)
  ,$void := map:put($locations, 'ms', <location lat='16.45' long='-62.12'/>)
  ,$void := map:put($locations, 'mz', <location lat='-18.15' long='35.00'/>)
  ,$void := map:put($locations, 'mm', <location lat='22.00' long='98.00'/>)
  ,$void := map:put($locations, 'na', <location lat='-22.00' long='17.00'/>)
  ,$void := map:put($locations, 'nr', <location lat='-0.32' long='166.55'/>)
  ,$void := map:put($locations, 'np', <location lat='28.00' long='84.00'/>)
  ,$void := map:put($locations, 'ni', <location lat='13.00' long='-85.00'/>)
  ,$void := map:put($locations, 'ne', <location lat='16.00' long='8.00'/>)
  ,$void := map:put($locations, 'ng', <location lat='10.00' long='8.00'/>)
  ,$void := map:put($locations, 'nu', <location lat='-19.02' long='-169.52'/>)
  ,$void := map:put($locations, 'nf', <location lat='-29.02' long='167.57'/>)
  ,$void := map:put($locations, 'no', <location lat='62.00' long='10.00'/>)
  ,$void := map:put($locations, 'nc', <location lat='-21.30' long='165.30'/>)
  ,$void := map:put($locations, 'nz', <location lat='-41.00' long='174.00'/>)
  ,$void := map:put($locations, 'io', <location lat='-6.00' long='71.30'/>)
  ,$void := map:put($locations, 'om', <location lat='21.00' long='57.00'/>)
  ,$void := map:put($locations, 'ug', <location lat='1.00' long='32.00'/>)
  ,$void := map:put($locations, 'uz', <location lat='41.00' long='64.00'/>)
  ,$void := map:put($locations, 'pk', <location lat='30.00' long='70.00'/>)
  ,$void := map:put($locations, 'pw', <location lat='7.30' long='134.30'/>)
  ,$void := map:put($locations, 'pa', <location lat='9.00' long='-80.00'/>)
  ,$void := map:put($locations, 'pg', <location lat='-6.00' long='147.00'/>)
  ,$void := map:put($locations, 'py', <location lat='-23.00' long='-58.00'/>)
  ,$void := map:put($locations, 'nl', <location lat='52.30' long='5.45'/>)
  ,$void := map:put($locations, 'pe', <location lat='-10.00' long='-76.00'/>)
  ,$void := map:put($locations, 'ph', <location lat='13.00' long='122.00'/>)
  ,$void := map:put($locations, 'pn', <location lat='-25.04' long='-130.06'/>)
  ,$void := map:put($locations, 'pl', <location lat='52.00' long='20.00'/>)
  ,$void := map:put($locations, 'pf', <location lat='-15.00' long='-140.00'/>)
  ,$void := map:put($locations, 'pr', <location lat='18.15' long='-66.30'/>)
  ,$void := map:put($locations, 'pt', <location lat='39.30' long='-8.00'/>)
  ,$void := map:put($locations, 'qa', <location lat='25.30' long='51.15'/>)
  ,$void := map:put($locations, 're', <location lat='-21.06' long='55.36'/>)
  ,$void := map:put($locations, 'ro', <location lat='46.00' long='25.00'/>)
  ,$void := map:put($locations, 'gb', <location lat='54.00' long='-2.00'/>)
  ,$void := map:put($locations, 'ru', <location lat='60.00' long='100.00'/>)
  ,$void := map:put($locations, 'rw', <location lat='-2.00' long='30.00'/>)
  ,$void := map:put($locations, 'eh', <location lat='24.30' long='-13.00'/>)
  ,$void := map:put($locations, 'bl', <location lat='17.90' long='-62.85'/>)
  ,$void := map:put($locations, 'sh', <location lat='-15.56' long='-5.42'/>)
  ,$void := map:put($locations, 'lc', <location lat='13.53' long='-60.58'/>)
  ,$void := map:put($locations, 'kn', <location lat='17.20' long='-62.45'/>)
  ,$void := map:put($locations, 'sm', <location lat='43.46' long='12.25'/>)
  ,$void := map:put($locations, 'mf', <location lat='18.05' long='-63.57'/>)
  ,$void := map:put($locations, 'pm', <location lat='46.50' long='-56.20'/>)
  ,$void := map:put($locations, 'va', <location lat='41.54' long='12.27'/>)
  ,$void := map:put($locations, 'vc', <location lat='13.15' long='-61.12'/>)
  ,$void := map:put($locations, 'sb', <location lat='-8.00' long='159.00'/>)
  ,$void := map:put($locations, 'ws', <location lat='-13.35' long='-172.20'/>)
  ,$void := map:put($locations, 'as', <location lat='-14.20' long='-170.00'/>)
  ,$void := map:put($locations, 'st', <location lat='1.00' long='7.00'/>)
  ,$void := map:put($locations, 'sn', <location lat='14.00' long='-14.00'/>)
  ,$void := map:put($locations, 'rs', <location lat='44.00' long='21.00'/>)
  ,$void := map:put($locations, 'sc', <location lat='-4.35' long='55.40'/>)
  ,$void := map:put($locations, 'sl', <location lat='8.30' long='-11.30'/>)
  ,$void := map:put($locations, 'sg', <location lat='1.22' long='103.48'/>)
  ,$void := map:put($locations, 'sk', <location lat='48.40' long='19.30'/>)
  ,$void := map:put($locations, 'si', <location lat='46.07' long='14.49'/>)
  ,$void := map:put($locations, 'so', <location lat='10.00' long='49.00'/>)
  ,$void := map:put($locations, 'sd', <location lat='15.00' long='30.00'/>)
  ,$void := map:put($locations, 'lk', <location lat='7.00' long='81.00'/>)
  ,$void := map:put($locations, 'se', <location lat='62.00' long='15.00'/>)
  ,$void := map:put($locations, 'ch', <location lat='47.00' long='8.00'/>)
  ,$void := map:put($locations, 'sr', <location lat='4.00' long='-56.00'/>)
  ,$void := map:put($locations, 'sz', <location lat='-26.30' long='31.30'/>)
  ,$void := map:put($locations, 'sy', <location lat='35.00' long='38.00'/>)
  ,$void := map:put($locations, 'tj', <location lat='39.00' long='71.00'/>)
  ,$void := map:put($locations, 'tw', <location lat='23.30' long='121.00'/>)
  ,$void := map:put($locations, 'tz', <location lat='-6.00' long='35.00'/>)
  ,$void := map:put($locations, 'td', <location lat='15.00' long='19.00'/>)
  ,$void := map:put($locations, 'cz', <location lat='49.45' long='15.30'/>)
  ,$void := map:put($locations, 'th', <location lat='15.00' long='100.00'/>)
  ,$void := map:put($locations, 'tl', <location lat='-8.50' long='125.55'/>)
  ,$void := map:put($locations, 'tg', <location lat='8.00' long='1.10'/>)
  ,$void := map:put($locations, 'tk', <location lat='-9.00' long='-172.00'/>)
  ,$void := map:put($locations, 'to', <location lat='-20.00' long='-175.00'/>)
  ,$void := map:put($locations, 'tt', <location lat='11.00' long='-61.00'/>)
  ,$void := map:put($locations, 'tn', <location lat='34.00' long='9.00'/>)
  ,$void := map:put($locations, 'tm', <location lat='40.00' long='60.00'/>)
  ,$void := map:put($locations, 'tc', <location lat='21.45' long='-71.35'/>)
  ,$void := map:put($locations, 'tr', <location lat='39.00' long='35.00'/>)
  ,$void := map:put($locations, 'tv', <location lat='-8.00' long='178.00'/>)
  ,$void := map:put($locations, 'ua', <location lat='49.00' long='32.00'/>)
  ,$void := map:put($locations, 'uy', <location lat='-33.00' long='-56.00'/>)
  ,$void := map:put($locations, 'vu', <location lat='-16.00' long='167.00'/>)
  ,$void := map:put($locations, 've', <location lat='8.00' long='-66.00'/>)
  ,$void := map:put($locations, 'vn', <location lat='16.00' long='106.00'/>)
  ,$void := map:put($locations, 'wf', <location lat='-13.18' long='-176.12'/>)
  ,$void := map:put($locations, 'ye', <location lat='15.00' long='48.00'/>)
  ,$void := map:put($locations, 'zm', <location lat='-15.00' long='30.00'/>)
  ,$void := map:put($locations, 'zw', <location lat='-20.00' long='30.00'/>)

let $model := ms:count-items-by-country()

let $list :=
  for $o in $model
    let $country := collection("referential")//oe:country[@id = $o/@ref]
    let $location := map:get($locations, $o/@ref)
    return
      if($country and $location) then
        let $data := map:map()
           ,$void := map:put($data, 'code', data($o/@ref))
           ,$void := map:put($data, 'country', data($country/oe:label[@xml:lang eq 'en']))
           ,$void := map:put($data, 'count', number($o/@frequency))
        let $map := map:map()
           ,$void := map:put($map, 'lat', number($location/@lat))
           ,$void := map:put($map, 'lng', number($location/@long))
           ,$void := map:put($map, 'data', $data)
        return $map
      else
        ()

return (
  xdmp:set-response-content-type("application/json")
  ,xdmp:to-json($list)
)