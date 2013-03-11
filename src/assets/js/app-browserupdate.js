/* normally, one should leave this empty to let "browser-update.org" make the
   choice whether to alert or not. but they consider ie8 ok, but I don't,
   so I have added them here. FIXME: needs regular updates (or maybe can be made
   empty again, after W7 migration at OECD is over.
*/
var $buoop = {vs:{i:8,f:3.6,o:10.6,s:4,n:10}};  
$buoop.ol = window.onload; 
window.onload=function(){ 
     try { if ($buoop.ol) $buoop.ol();} catch (e) {} 
     var e = document.createElement("script"); 
     e.setAttribute("type", "text/javascript"); 
     e.setAttribute("src", "http://browser-update.org/update.js"); 
     document.body.appendChild(e); 
};