$(function () {
    
    $.getJSON('/items-by-country', function (data) {
        /*var center = new google.maps.LatLng(22.49, 89.76);*/
        
        var center;
        
        var cltLoc = function (pos) {
		    center = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
		}

        if (0 /*navigator.geolocation*/) 
		{
			navigator.geolocation.getCurrentPosition( cltLoc );
		} else {
		    center = new google.maps.LatLng(25, 18);
		}        

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
            zoom: 2,
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
                    "title": "Click to see countries represented by this cluster",
                    "index": 2
                    };
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
        
        /* TODO: have nice tooltips on mouseover on cluster icons
        var infoboxForCluster = new InfoBox();
        google.maps.event.addListener(mc, 'mouseover', function(c) {
            var label = "Click here to see the " + c.getSize() + " countries represented by this cluster";
            infoboxForCluster.setOptions({
                content: label,
                pixelOffset: new google.maps.Size(-75, 15),
                closeBoxURL: ""
            });
            infoboxForCluster.open(map, c.getCenter());
        });
        google.maps.event.addListener(mc, 'mouseout', function(c) {
            infoboxForCluster.close();
        });*/
        
    });
});