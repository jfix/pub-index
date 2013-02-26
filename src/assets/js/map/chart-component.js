// Raureif/Stefaner code for DDP - reused with permission -- Jakob Fix

(function () {
    var $, DEBUG, FULL, REDUCED, SMALL
    , addClickArea, adjustToDimensions, attachClick, attachHover, attachPointAnnotation, attachTip
    , cleanData, collide, createSVG, createTitle, getYearString, log, pretty
    , redraw, renderMap, renderRanking, renderTimeSeries, renderTimeSeriesMultiples
    , setSizeClass, toggleCountrySelection,
    __slice =[].slice,
    __indexOf =[].indexOf || function (item) {
        for (var i = 0, l = this.length; i < l; i++) {
            if (i in this && this[i] === item) return i;
        }
        return -1;
    };
    
    //window.DEFAULT_YEARS =[2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011];
    
    DEBUG = true;    
    FULL = 2;
    REDUCED = 1;
    SMALL = 0;
    $ = jQuery;
    
    redraw = function() {
      $(this).attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
      $(this).attr("font-size", (nodeFontSize / d3.event.scale) + "px");
      $(this).selectAll("line.link").style("stroke-width", getStrokeWidth); // Function so it runs for each element individually
    }
    
    log = function () {
        var arg, args, _i, _len, _results;
        args = 1 <= arguments.length ? __slice.call(arguments, 0):[];
        if (DEBUG) {
            _results =[];
            for (_i = 0, _len = args.length; _i < _len; _i++) {
                arg = args[_i];
                _results.push(typeof console !== "undefined" && console !== null ? console.log(arg): void 0);
            }
            return _results;
        }
    };
    
    $.fn.extend({
        renderDiagram: function () {
            var _this = this;
            $(this).html("<i class=\"icon-spinner icon-spin\"></i>");
            return $.when(
                $.getJSON("/app/actions/items-by-country.xqy"), 
                $.getJSON("/assets/data/country-coords.json"), 
                $.getJSON("/assets/data/world-110m.json")).done(function (data, countries, map) {
                
                    log("data loaded");
                    window.DATA = data[0]; // makes it available globally
                    window.COUNTRIES = countries[0];
                    window.MAP_DATA = map[0];
                    
                    return _this.each(function () {
                        var $el, a, byline, indicatorID, render, showOecdAverage, subtitle, svg, title, type, yearString, years, _i, _ref, _ref1, _ref2, _ref3, _results;

                        data = window.DATA.slice(); // no idea what this is doing
                        $el = $(this);
                        countries = _.filter(countries, function (x) {
                            return _.find(data, function (y) {
                                return y.countryCode === x;
                            });
                        });
                        
                        $el.addClass("chart");
                        $el.empty();
                        svg = createSVG($el);
                        // ***************************************************
                        render = function () {
                            return window.renderDiagram(svg, $el, data, "No title", "No subtitle", "No byline", years, countries, showOecdAverage);
                        };
                        render();
                    });
            });
        }
    });
    
    window.renderDiagram = function (svg, $el, data, title, subtitle, byline, years, countries, showOecdAverage) {
        var numHighlights, size;
        log("+ + + ");
        log("render chart " +[$el, title, years, countries, showOecdAverage]);
        size = adjustToDimensions($el);

        renderMap($el, svg, data, title, years, countries, showOecdAverage, size);
        
        addClickArea($el, svg, title, subtitle);
    };
    
    createSVG = function ($el) {
        return d3.select($el[0]).append('svg').attr('width', '100%').attr('height', '100%');
    };
        
    adjustToDimensions = function ($el, w, h) {
        var size;
        w = $el.width();
        h = $el.height();
        if ((w > 400 && h > 250) || h > 400) {
            size = FULL;
            setSizeClass($el, "fullSize");
        } else if (w > 120) {
            size = REDUCED;
            setSizeClass($el, "mediumSize");
        } else {
            size = SMALL;
            setSizeClass($el, "smallSize");
        }
        return size;
    };
    
    attachPointAnnotation = function (selection, my, at, xx, yy) {
        if (my == null) {
            my = 'bottom center';
        }
        if (at == null) {
            at = 'top center';
        }
        if (xx == null) {
            xx = 0;
        }
        if (yy == null) {
            yy = 0;
        }
        this.each(function () {
            return $(this).qtip({
                content: true,
                position: {
                    my: my,
                    at: at,
                    adjust: {
                        x: xx,
                        y: xx
                    }
                },
                style: {
                    classes: 'qtip-tipsy'
                },
                show: {
                    event: false,
                    ready: true
                },
                hide: false
            }).show();
        });
        return this;
    };
    
    attachTip = function (selection, target, my, at, xx, yy) {
        if (my == null) {
            my = 'bottom center';
        }
        if (at == null) {
            at = 'top center';
        }
        if (xx == null) {
            xx = 0;
        }
        if (yy == null) {
            yy = 0;
        }
        this.each(function () {
            return $(this).qtip({
                content: true,
                position: {
                    my: my,
                    at: at,
                    target: target,
                    adjust: {
                        x: xx,
                        y: yy
                    }
                },
                style: {
                    classes: 'qtip-tipsy'
                }
            });
        });
        return this;
    };
    
    attachHover = function (selection, $el) {
        return selection.on("mouseover", function () {
            return d3.select(this).classed("highlight", true);
        }).on("mouseout", function () {
            return d3.select(this).classed("highlight", d3.select(this).classed("annotated"));
        });
    };
    
    attachClick = function (selection, $el) {
        return selection.on("click", function (d) {
            location.href="/search?term=&in=country%3A" + d.countryCode + "%3B&start=1&order=";
        });
    };
    
    setSizeClass = function ($el, className) {
        $el.removeClass("fullSize");
        $el.removeClass("mediumSize");
        $el.removeClass("smallSize");
        return $el.addClass(className);
    };
    
    addClickArea = function ($el, svg, title, subtitle) {
        return svg
            .append("rect")
            .classed("clickArea", true)
            .attr("width", $el.width())
            .attr("height", $el.height())
            .attr("title", "<strong>" + title + "</strong><br/>\n" + subtitle)
            .on("mouseover", function () {
                return d3.select(this).style("opacity", .2);
            })
            .on("mouseout", function () {
                return d3.select(this).style("opacity", 0);
            })
            .call(attachTip);
    };
    
    collide = function (node) {
        var nx1, nx2, ny1, ny2, r;
        r = node.radius + 16;
        nx1 = node.x - r;
        nx2 = node.x + r;
        ny1 = node.y - r;
        ny2 = node.y + r;
        return function (quad, x1, y1, x2, y2) {
            var l, x, y;
            if (quad.point && quad.point !== node) {
                x = node.x - quad.point.x;
                y = node.y - quad.point.y;
                l = Math.sqrt(x * x + y * y);
                r = node.radius + quad.point.radius;
                if (l < r) {
                    l = (l - r) / l * .5;
                    node.x -= x *= l;
                    node.y -= y *= l;
                    quad.point.x += x;
                    quad.point.y += y;
                }
            }
            return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
        };
    };
    
    renderMap = function ($el, svg, data, indicator, years, _countries, showOecdAverage, size) {
        var NUM_ITERATIONS, a, allValues, c, countries, d, dataLayer, equalSize, globalMax, globalMin, graticule, h, hasHighlight, highlightedCountries, i, map, n, num, o, path, projection, q, radius, scale, value, valueScale, w, x, y, _i, _j, _len, _ref;
        log("renderMap");
        $el.addClass("map");
        w = $el.width();
        h = $el.height();
        
        // as the data field is ordered by marklogic by most pubs first, we can make this faster
        globalMax = data[0].count;
        globalMin = data[data.length-1].count;
        
        valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([0, Math.max(15, Math.sqrt(w) / 3)]);
        
        equalSize = $el.attr("data-equalSize") === "true";
        scale = Math.min(w / 600, h / 300);
        
        projection = d3.geo.robinson().translate([w / 2.2, h / 1.66]).scale(110 * scale);
        path = d3.geo.path().projection(projection);
        graticule = d3.geo.graticule();
        map = svg.append("g").classed("worldmap", true);
        
        countries = topojson.object(window.MAP_DATA, window.MAP_DATA.objects.countries).geometries;
        map.selectAll(".country")
            .data(countries)
            .enter()
            .insert("path", ".graticule")
            .classed("country", true)
            .attr("d", path);
            
        dataLayer = svg.append("g").classed("mapDataLayer", true);
        
        countries =[];
        _ref = window.COUNTRIES.features;
        for (i = _i = 0, _len = _ref.length; _i < _len; i =++ _i) {
            d = _ref[i];
            
            // filter data to only contain that of the countries available
            o = data.filter(function (x) {
                return d.id === x.code;
            });
            if (o != null ? o.length: void 0) {
                value = o[0].count;
                if (equalSize) {
                    radius = w / 100;
                } else {
                    radius = Math.max(.33, scale) * (valueScale(value) + 1);
                }
                x = projection(d.geometry.coordinates)[0];
                y = projection(d.geometry.coordinates)[1];
                countries.push({
                    label: d.properties.name,
                    country: d.id,
                    countryCode: o[0].code,
                    targetX: x,
                    targetY: y,
                    value: value,
                    radius: radius,
                    x: x,
                    y: y,
                    data: o
                });
            }
        }
        NUM_ITERATIONS = 250;
        for (num = _j = NUM_ITERATIONS; NUM_ITERATIONS <= 0 ? _j <= 0: _j >= 0; num = NUM_ITERATIONS <= 0 ?++ _j:-- _j) {
            q = d3.geom.quadtree(countries);
            i = 0;
            n = countries.length;
            while (++ i < n) {
                c = countries[i];
                c.x += (c.targetX - c.x) * .1 * (num / NUM_ITERATIONS);
                c.y += (c.targetY - c.y) * .1 * (num / NUM_ITERATIONS);
                q.visit(collide(c));
            }
        }

        c = dataLayer
            .selectAll("g.countryMark")
            .data(countries)
            .enter()
            .append("g")
            .classed("countryMark", true)
            .attr("transform", function (d, i) {
                return "translate(" + d.x + "," + d.y + ")";
            }).attr("title", function (d, i) {
                if (d.value == 1) {
                    return "There is only one publication on " + d.label;
                } else {
                    return "There are " + d.value + " publications on " + d.label;                
                }
            });
            
        c.append("circle").attr("r", function (d, i) {
            var radius =  d.radius - (scale * 2);
            if (radius < 3) {
                return 3;
            }
            return radius;
        });
        c.call(attachTip);
        c.call(attachHover);
        c.call(attachClick, $el);
        if (size > SMALL) {
            return dataLayer.selectAll("g.highlight").call(attachPointAnnotation);
        }
    };
}).call(this);

$(document).ready(function(){
	d3.select("#map-container").call(d3.behavior.zoom().on("zoom",  function() {
      $(this).attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
    }));
	$("#map-container").renderDiagram();
});