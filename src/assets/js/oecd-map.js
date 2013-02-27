$(function () {
    
    $.getJSON('/app/actions/items-by-country.xqy', function (data) {
        var center = new google.maps.LatLng(22.49, 89.76);

        /* 
           use admin map type, but without any features (oecd-compliant), go here for modifications
           http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
        */
        var mapStyles = [
            {
            "featureType": "administrative",
                "stylers": [
                    { "visibility": "off" }
                ]
            }
        ];
        /* define the options for the map, visible/hidden controls, initial zoom, etc. */
        var options = {
            zoom: 1,
            center: center,
            panControl: false,
            zoomControl: true,
            scaleControl: false,
            mapTypeControl: false,
            streetViewControl: false,
            overviewMapControl: false,
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL
            },
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            styles: mapStyles
        };
        
        /* create the actual map */
        var map = new google.maps.Map(document.getElementById("map-container-gm"), options);
        
        /*  */
        var mcOptions = {
            gridSize: 30, /* modify this to change what's covered by a cluster */
            maxZoom: 15,
            minimumClusterSize: 5,
            imagePath: "/assets/images/m",
            calculator: function(arr, num){ 
                return {
                    "text":"",
                    /*"title": "Click to see countries in detail",*/
                    "index": 2};
            }
        };
        
        /* marker creation here */
        var markers = jQuery.map(data, function(e, i) {
            var count = e.data.count;
            var country = e.data.country;
            var code = e.data.code;
            var infobox = new InfoBox();
            
            var label = ((count == 1) 
                            ? "There is only one publication on " + country
                            : "There are " + count + " publications on " + country
            );
            
            var latlng = new google.maps.LatLng(e.lat, e.lng);
            
            var marker = new google.maps.Marker({
                position: latlng,   /* position on the map*/
                /*title: label,*/       /* There are X publications on YY */
                icon: "/assets/images/small_logo.png"                
            });
            /* on click on a marker takes you to the search page filtered for that country */
            google.maps.event.addListener(marker, 'click', function() {
               location.href = "/country/" + code;
            });
            /* on mouse over display a nice tooltip, a la bootstrap */
            google.maps.event.addListener(marker, 'mouseover', function() {
                infobox.setOptions({
                    content: label, 
                    pixelOffset: new google.maps.Size(-75, 15),
                    closeBoxURL: ""});
                infobox.open(map, marker);
            });
            /* on mouse out remove the nice tooltip */
            google.maps.event.addListener(marker, 'mouseout', function() {
                infobox.close();
            });
            return marker;
        });
                
        var mc = new MarkerClusterer(map, markers, mcOptions);
    });
});

/*        $("#map-container-gm").gmap3({
map: {
options: {
center:[22.49, 89.76],
zoom: 1,
mapTypeId: google.maps.MapTypeId.SATELLITE,
mapTypeControl: false,
navigationControl: true,
scrollwheel: true,
streetViewControl: false, stylers:[ {
visibility: "off"
}]
},
events: {
click: function(evt) {
        var infowindow = $(this).gmap3({get:{name:"infowindow"}});
if (infowindow) {
infowindow.close();
}
}
}
},
marker: {
values: data, options: {
icon: '/assets/images/small_logo.png'
},
cluster: {
radius: 70,
/\*0: {
content: "<div class='cluster cluster-1'>CLUSTER_COUNT</div>",
width: 50,
height: 31
},
/\*20:*\/ 50: {
content: "<div class='cluster cluster-2'>CLUSTER_COUNT</div>",
width: 50,
height: 31
},*\/
/\*50:*\/ 30: {
content: "<div class='cluster cluster-3'>CLUSTER_COUNT</div>",
width: 50,
height: 31
},
events: {
// events trigged by clusters
mouseover: function (cluster) {
},
mouseout: function (cluster) {
}
}
},
events: {
click: function (marker, event, context) {
var map = $(this).gmap3("get"),
infowindow = $(this).gmap3({
get: {
name: "infowindow"
}
});
if (infowindow) {
var country = context.data.country;
var contents = "<a href='/country/" + contxt.data.code  + "'>";
var count = context.data.count;
if (count == 1) {
contents += "There is only one publication on " + country;
} else {
contents += "There are " + count + " publications on " + country;
}
contents += "</a>";

infowindow.open(map, marker);
infowindow.setContent(contents);
} else {
$(this).gmap3({
infowindow: {
anchor: marker,
options: {
content: "<a href='/country/" + context.data.code  + "'>" +
/\*                                        content: "<a href='/search?term=&in=country%3A" + context.data.code + "%3B&start=1&order=" + "'>" +
 *\/                                        (context.data.count == 1
? "There is only one publication on " + context.data.country
: "There are " + context.data.count + " publications on " + context.data.country)

}
}
});
}
},
mouseout: function () {
var infowindow = $(this).gmap3({
get: {
name: "infowindow"
}
});
/\*if (infowindow) {
//infowindow.close();
}*\/
}
}
}

 */