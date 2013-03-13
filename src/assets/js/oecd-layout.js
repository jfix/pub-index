/*
 * jQuery outside events - v1.1 - 3/16/2010
 * http://benalman.com/projects/jquery-outside-events-plugin/
 *
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
(function ($, c, b) {
    $.map("click dblclick mousemove mousedown mouseup mouseover mouseout change select submit keydown keypress keyup".split(" "), function (d) {
        a(d)
    });
    a("focusin", "focus" + b);
    a("focusout", "blur" + b);
    $.addOutsideEvent = a; function a(g, e) {
        e = e || g + b; var d = $(), h = g + "." + e + "-special-event"; $.event.special[e] = {
            setup: function () {
                d = d.add(this);
                if (d.length === 1) {
                    $(c).bind(h, f)
                }
            },
            teardown: function () {
                d = d.not(this);
                if (d.length === 0) {
                    $(c).unbind(h)
                }
            },
            add: function (i) {
                var j = i.handler; i.handler = function (l, k) {
                    l.target = k; j.apply(this, arguments)
                }
            }
        };
        function f(i) {
            $(d).each(function () {
                var j = $(this);
                if (this !== i.target && ! j.has(i.target).length) {
                    j.triggerHandler(e,[i.target])
                }
            })
        }
    }
})(jQuery, document, "outside");

/* OECD nav bar */
$(function () {
    
    /* start the carousel on the home page, each slide is displayed for five seconds */
    $('div#latest').carousel({
        interval: 5000
    })
    
    /* define actions for dropdown menus */
    $("#nav a.hasPanel").click(function (e) {
        e.preventDefault ();
        $($(e.target).closest('li')).toggleClass('active').siblings().removeClass('active');
        $($(e.target).closest('ul')).bind("mouseoveroutside", function (event) {
            $(this).children('.active').removeClass('active').unbind();
        });
    });
    
    /* define A-Z tabs behavior
    $("#countriesList .tabs").tabs("#countriesList .pane", {event:'mouseover'});*/
    
    var selected = 1;
    var $selectedTab = undefined;
    $("#countriesList .tabs li").each(function (i, tab) {
        var idx = i + 1;
        var $tab = $(tab);
        var $target = $('#li_container' + idx).parent();
        
        if (idx == 1) {
            $selectedTab = $tab;
        }
        
        $tab.mouseenter(function () {
            if (selected != idx) {
                $tab.children("a").addClass("current");
                $selectedTab.children("a").removeClass("current");
                
                $target.show();
                $('#li_container' + selected).parent().hide();
                
                selected = idx;
                $selectedTab = $tab;
            }
        });
    });
});