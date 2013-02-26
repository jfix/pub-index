// Raureif/Stefaner code for DDP - reused with permission -- Jakob Fix

(function() {
  var $, DEBUG, FULL, REDUCED, SMALL, addClickArea, adjustToDimensions, attachClick, attachHover, attachPointAnnotation, attachTip, cleanData, collide, createSVG, createTitle, getYearString, log, pretty, renderMap, renderRanking, renderTimeSeries, renderTimeSeriesMultiples, setSizeClass, toggleCountrySelection,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.DEFAULT_YEARS = [2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011];

  DEBUG = false;

  FULL = 2;

  REDUCED = 1;

  SMALL = 0;

  $ = jQuery;

  log = function() {
    var arg, args, _i, _len, _results;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (DEBUG) {
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        _results.push(typeof console !== "undefined" && console !== null ? console.log(arg) : void 0);
      }
      return _results;
    }
  };

  $.fn.extend({
    renderDiagram: function() {
      var _this = this;
      $(this).html("<i class=\"icon-spinner icon-spin\"></i>");
      return $.when(
        $.getJSON("/app/actions/items-by-country.xqy"), 
        $.getJSON("/assets/data/country-coords.json"), 
        $.getJSON("/assets/data/world-110m.json")).done(function(data, countries, map) {
        log("data loaded");
        window.DATA = data[0];
        window.COUNTRIES = countries[0];
        window.MAP_DATA = map[0];
        return _this.each(function() {
          var $el, a, byline, indicatorID, render, showOecdAverage, subtitle, svg, title, type, yearString, years, _i, _ref, _ref1, _ref2, _ref3, _results;
          data = window.DATA.slice();
          $el = $(this);
          type = $el.attr("data-type");
          title = $el.attr("title");
          subtitle = $el.attr("data-subtitle");
          byline = $el.attr("data-byline");
          years = $el.attr("data-years");
          indicatorID = $el.attr("data-indicatorID");
          showOecdAverage = $el.attr("data-showOecdAverage") === "true";
          countries = (_ref = $el.attr("data-countries")) != null ? _ref.split(",") : void 0;
          yearString = years;
          if ((years != null ? years.indexOf("-") : void 0) > -1) {
            a = years.split("-");
            years = (function() {
              _results = [];
              for (var _i = _ref1 = Number(a[0]), _ref2 = Number(a[1]); _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; _ref1 <= _ref2 ? _i++ : _i--){ _results.push(_i); }
              return _results;
            }).apply(this);
          } else if ((years != null ? years.indexOf(",") : void 0) > -1) {
            years = years.split(",");
          } else if (Number(years)) {
            years = [Number(years)];
          } else {
            years = null;
          }
          data = _.filter(data, function(d) {
            return d.indicatorCode === indicatorID;
          });
          if (years == null) {
            years = window.DEFAULT_YEARS;
          }
          if (title == null) {
            title = data[0].indicator;
          }
          if (subtitle == null) {
            subtitle = data[0].dataUnit + ", " + getYearString(years);
          }
          _ref3 = cleanData(data, years), data = _ref3[0], years = _ref3[1];
          if (countries == null) {
            countries = [];
          }
          countries = _.filter(countries, function(x) {
            return _.find(data, function(y) {
              return y.countryCode === x;
            });
          });
          $el.addClass("chart");
          $el.empty();
          svg = createSVG($el);
          render = function() {
            return window.renderDiagram(svg, type, $el, data, title, subtitle, byline, years, countries, showOecdAverage);
          };
          render();
          return $el.watch(["data-years", "data-type", "data-indicatorID", "data-byline", "data-countries", "data-showOecdAverage", "width", "height"], function() {
            return $el.renderDiagram();
          });
        });
      });
    }
  });

  window.renderDiagram = function(svg, type, $el, data, title, subtitle, byline, years, countries, showOecdAverage) {
    var numHighlights, size;
    log("+ + + ");
    log("render chart " + [type, $el, title, years, countries, showOecdAverage]);
    size = adjustToDimensions($el);
    if (type === "map") {
      renderMap($el, svg, data, title, years, countries, showOecdAverage, size);
    } else if ((years != null ? years.length : void 0) === 1) {
      if ((countries != null ? countries.length : void 0) === 1) {
        renderRanking($el, svg, data, title, years, countries, showOecdAverage, size);
      } else {
        renderRanking($el, svg, data, title, years, countries, showOecdAverage, size);
      }
    } else {
      numHighlights = countries.length;
      if (showOecdAverage) {
        numHighlights++;
      }
      if (numHighlights < 4) {
        renderTimeSeries($el, svg, data, title, years, countries, showOecdAverage, size);
      } else {
        renderTimeSeriesMultiples($el, svg, data, title, years, countries, showOecdAverage, size);
      }
    }
    addClickArea($el, svg, title, subtitle);
    return createTitle($el, svg, title, subtitle, byline, size);
  };

  createSVG = function($el) {
    return d3.select($el[0]).append('svg').attr('width', '100%').attr('height', '100%');
  };

  createTitle = function($el, svg, title, subtitle, byline, size) {
    if (size > SMALL) {
      svg.append("text").classed("title", true).text(title).attr("y", 20 + (size - 1) * 5).attr("x", 5);
    }
    if (size === FULL) {
      svg.append("text").classed("subtitle", true).text(subtitle).attr("y", 40).attr("x", 5);
      return svg.append("text").classed("byline", true).text(byline).attr("y", $el.height() - 10).attr("x", 5);
    }
  };

  adjustToDimensions = function($el, w, h) {
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

  pretty = function(value) {
    return "" + ((value * 100).toFixed(1)) + "%";
  };

  getYearString = function(a) {
    if (!(a != null ? a.length : void 0)) {
      return "";
    }
    if (a.length === 1) {
      return a[0];
    }
    return "" + a[0] + "-" + a[a.length - 1];
  };

  attachPointAnnotation = function(selection, my, at, xx, yy) {
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
    this.each(function() {
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

  attachTip = function(selection, target, my, at, xx, yy) {
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
    this.each(function() {
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

  attachHover = function(selection, $el) {
    return selection.on("mouseover", function() {
      return d3.select(this).classed("highlight", true);
    }).on("mouseout", function() {
      return d3.select(this).classed("highlight", d3.select(this).classed("annotated"));
    });
  };

  attachClick = function(selection, $el) {
    return selection.on("click", function(d) {
      return toggleCountrySelection($el, d.countryCode);
    });
  };

  cleanData = function(_data, years) {
    var countryCode, d, dict, i, index, x, y, yearIndex, _i, _j, _len, _len1;
    dict = {};
    yearIndex = {};
    years = _.filter(years, function(x) {
      return _.find(_data, function(d) {
        return d.year === x;
      });
    });
    for (i = _i = 0, _len = years.length; _i < _len; i = ++_i) {
      y = years[i];
      yearIndex[y] = i;
    }
    for (_j = 0, _len1 = _data.length; _j < _len1; _j++) {
      d = _data[_j];
      countryCode = d.code;
      if (!dict[countryCode]) {
        dict[countryCode] = {
          "country": d.country,
          "countryCode": d.code,
          "isOECDAvg": d.code === "OTO",
          "values": []
        };
      }
      index = yearIndex[d.year];
      if (index != null) {
        dict[countryCode].values[index] = d.value / 100.0;
      }
    }
    _data = (function() {
      var _results;
      _results = [];
      for (x in dict) {
        _results.push(dict[x]);
      }
      return _results;
    })();
    _data = _.filter(_data, function(x) {
      var _k, _len2;
      for (i = _k = 0, _len2 = years.length; _k < _len2; i = ++_k) {
        y = years[i];
        if (!(x.values[i] != null)) {
          return false;
        }
      }
      return true;
    });
    return [_data, years];
  };

  setSizeClass = function($el, className) {
    $el.removeClass("fullSize");
    $el.removeClass("mediumSize");
    $el.removeClass("smallSize");
    return $el.addClass(className);
  };

  addClickArea = function($el, svg, title, subtitle) {
    return svg.append("rect").classed("clickArea", true).attr("width", $el.width()).attr("height", $el.height()).attr("title", "<strong>" + title + "</strong><br/>\n" + subtitle).on("mouseover", function() {
      return d3.select(this).style("opacity", .2);
    }).on("mouseout", function() {
      return d3.select(this).style("opacity", 0);
    }).call(attachTip);
  };

  collide = function(node) {
    var nx1, nx2, ny1, ny2, r;
    r = node.radius + 16;
    nx1 = node.x - r;
    nx2 = node.x + r;
    ny1 = node.y - r;
    ny2 = node.y + r;
    return function(quad, x1, y1, x2, y2) {
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

  renderMap = function($el, svg, data, indicator, years, _countries, showOecdAverage, size) {
    var NUM_ITERATIONS, a, allValues, c, countries, d, dataLayer, equalSize, globalMax, globalMin, graticule, h, hasHighlight, highlightedCountries, i, map, n, num, o, path, projection, q, radius, scale, value, valueScale, w, x, y, _i, _j, _len, _ref;
    log("renderMap");
    $el.addClass("map");
    w = $el.width();
    h = $el.height();
    allValues = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        a = data[_i];
        _results.push(a.values[0]);
      }
      return _results;
    })();
    globalMin = d3.min(allValues);
    globalMax = d3.max(allValues);
    valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([0, Math.max(15, Math.sqrt(w) / 1.5)]);
    equalSize = $el.attr("data-equalSize") === "true";
    scale = Math.min(w / 600, h / 300);
    projection = d3.geo.robinson().translate([w / 2.2, h / 1.66]).scale(110 * scale);
    path = d3.geo.path().projection(projection);
    graticule = d3.geo.graticule();
    map = svg.append("g").classed("worldmap", true);
    "map.append(\"path\")\n	.datum(graticule) \n	.classed(\"graticule\", true) \n	.attr(\"d\", path)\n\nmap.append(\"path\")\n	.datum(graticule.outline)\n	.classed(\"graticule outline\", true)\n	.attr(\"d\", path)";

    countries = topojson.object(window.MAP_DATA, window.MAP_DATA.objects.countries).geometries;
    map.selectAll(".country").data(countries).enter().insert("path", ".graticule").classed("country", true).attr("d", path);
    dataLayer = svg.append("g").classed("mapDataLayer", true);
    countries = [];
    _ref = window.COUNTRIES.features;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      d = _ref[i];
      o = data.filter(function(x) {
        return d.id === x.country;
      });
      if (o != null ? o.length : void 0) {
        value = o[0].values[0] || o[0].values[1];
        if (equalSize) {
          radius = w / 100;
        } else {
          radius = Math.max(.33, scale) * (valueScale(value) + 1);
        }
        x = projection(d.geometry.coordinates)[0];
        y = projection(d.geometry.coordinates)[1];
        countries.push({
          label: d.id,
          country: d.id,
          countryCode: o[0].countryCode,
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
    NUM_ITERATIONS = 50;
    for (num = _j = NUM_ITERATIONS; NUM_ITERATIONS <= 0 ? _j <= 0 : _j >= 0; num = NUM_ITERATIONS <= 0 ? ++_j : --_j) {
      q = d3.geom.quadtree(countries);
      i = 0;
      n = countries.length;
      while (++i < n) {
        c = countries[i];
        c.x += (c.targetX - c.x) * .1 * (num / NUM_ITERATIONS);
        c.y += (c.targetY - c.y) * .1 * (num / NUM_ITERATIONS);
        q.visit(collide(c));
      }
    }
    highlightedCountries = _countries.slice();
    hasHighlight = (highlightedCountries != null ? highlightedCountries.length : void 0) > 0;
    if (showOecdAverage) {
      highlightedCountries.push("OTO");
    }
    c = dataLayer.selectAll("g.countryMark").data(countries).enter().append("g").classed("countryMark", true).classed("oecdAvg", function(d, i) {
      return d.isOECDAvg;
    }).classed("highlight annotated", function(d, i) {
      var _ref1;
      return _ref1 = d.countryCode, __indexOf.call(highlightedCountries, _ref1) >= 0;
    }).attr("transform", function(d, i) {
      return "translate(" + d.x + "," + d.y + ")";
    }).attr("title", function(d, i) {
      return "" + d.country + ": " + (pretty(d.value));
    });
    c.append("circle").attr("r", function(d, i) {
      return d.radius - scale;
    });
    c.call(attachTip);
    c.call(attachHover);
    c.call(attachClick, $el);
    if (size > SMALL) {
      return dataLayer.selectAll("g.highlight").call(attachPointAnnotation);
    }
  };

  renderTimeSeriesMultiples = function($el, svg, data, indicator, years, countries, showOecdAverage, size) {
    var a, allValues, cell, cellHeight, cellPadding, cellSpacing, cellWidth, chart, chartAreaHeight, chartAreaWidth, countryMark, globalMax, globalMin, h, highlight, i, line, numCols, numRows, paddingBottom, paddingLeft, paddingRight, paddingTop, panelContainer, rangeBand, val, valueScale, w, x, yearScale, _i, _j, _len, _len1, _ref;
    log("renderTimeSeriesMultiples");
    allValues = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      a = data[_i];
      _ref = a.values;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        val = _ref[_j];
        allValues.push(val);
      }
    }
    globalMin = d3.min(allValues);
    globalMax = d3.max(allValues);
    w = $el.width();
    h = $el.height();
    numCols = Math.ceil(Math.sqrt(countries.length));
    numRows = Math.ceil(countries.length / numCols);
    log("" + numRows + " x " + numCols);
    size = REDUCED;
    paddingRight = 20;
    paddingBottom = 30;
    paddingTop = 60;
    paddingLeft = 10;
    cellSpacing = 10;
    cellPadding = 10;
    chartAreaWidth = w + cellSpacing - paddingRight - paddingLeft;
    chartAreaHeight = h + cellSpacing - paddingBottom - paddingTop;
    cellWidth = chartAreaWidth / numCols - cellSpacing;
    cellHeight = chartAreaHeight / numRows - cellSpacing;
    valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([cellHeight - cellPadding * 2, cellPadding]);
    rangeBand = (cellWidth - cellPadding * 2) / (years.length - 1);
    yearScale = d3.scale.ordinal().domain(years).range((function() {
      var _k, _len2, _results;
      _results = [];
      for (i = _k = 0, _len2 = years.length; _k < _len2; i = ++_k) {
        x = years[i];
        _results.push(cellPadding + i * rangeBand);
      }
      return _results;
    })());
    line = d3.svg.line().x(function(d, i) {
      return yearScale(years[i]);
    }).y(function(d, i) {
      return valueScale(d);
    });
    panelContainer = svg.append("g").attr("transform", "translate(" + paddingLeft + ", " + paddingTop + ")").classed("lineChart", true);
    cell = panelContainer.selectAll(".panel").data(countries).enter().append("g").classed("panel", true).attr("transform", function(d, i) {
      return "translate(" + ((i % numCols) * (cellWidth + cellSpacing)) + ", " + (Math.floor(i / numCols) * (cellHeight + cellSpacing)) + ")";
    });
    cell.append("rect").attr("width", cellWidth).attr("height", cellHeight);
    cell.append("text").classed("title", true).text(function(d) {
      return (_.find(data, function(x) {
        return x.countryCode === d;
      })).country;
    }).attr("dy", 15).attr("dx", 5);
    chart = cell.append("g").classed("lineChart", true);
    countryMark = chart.selectAll('g.countryMark').data(function(d, i) {
      return _.map(data, function(x) {
        return {
          highlighted: x.countryCode === d || (x.countryCode === "OTO" && showOecdAverage),
          data: x
        };
      });
    }).enter().append("g").classed("countryMark", true).attr("title", function(d, i) {
      return d.data.country;
    });
    countryMark.append("path").style("stroke-width", 10).attr("d", function(d, i) {
      return line(d.data.values);
    }).style("opacity", 0);
    countryMark.append("path").style("stroke-width", 1).attr("d", function(d, i) {
      return line(d.data.values);
    });
    countryMark.call(attachTip, "mouse", null, null, 0, -10);
    countryMark.on("mouseover", function() {
      return d3.select(this).select(".highlight").attr("visibility", "visible");
    }).on("mouseout", function() {
      return d3.select(this).select(".highlight").attr("visibility", function(d, i) {
        if (d.highlighted) {
          return "visible";
        } else {
          return "hidden";
        }
      });
    }).on("click", function(d) {
      return toggleCountrySelection($el, d.data.countryCode);
    });
    highlight = countryMark.append("g").classed("highlight", true).classed("oecdAvg", function(d, i) {
      return d.isOECDAvg;
    }).classed("annotated", function(d, i) {
      return d.highlighted;
    }).attr("title", function(d, i) {
      return "" + d.data.country + ": " + (pretty(d.data.values[d.data.values.length - 1]));
    }).attr("visibility", function(d, i) {
      if (d.highlighted) {
        return "visible";
      } else {
        return "hidden";
      }
    });
    highlight.append("path").attr("d", function(d, i) {
      return line(d.data.values);
    }).style("stroke-width", 6).style("stroke", "#FFF");
    highlight.append("path").attr("d", function(d, i) {
      return line(d.data.values);
    }).style("stroke-dasharray", function(d, i) {
      if (d.data.isOECDAvg && size > 0) {
        return "2,1";
      } else {
        return "";
      }
    });
    highlight.selectAll("circle").data(function(d, i) {
      return d.data.values;
    }).enter().append("circle").attr("cx", function(d, i) {
      return yearScale(years[i]);
    }).attr("cy", function(d, i) {
      return valueScale(d);
    }).attr("r", function(d, i) {
      if (size > 0) {
        return 4;
      } else {
        return 2;
      }
    });
    return highlight.each(function() {
      var t, _this;
      _this = this;
      if ((d3.select(this)).classed("annotated")) {
        t = d3.select(this).selectAll("circle").filter(function(d, i) {
          return i === years.length - 1;
        }).attr("title", "" + (d3.select(this).attr("title")));
        if (size === REDUCED) {
          return t.call(attachPointAnnotation, "bottom right", "top center");
        } else {
          return t.call(attachPointAnnotation, "center left", "center right");
        }
      }
    });
  };

  renderRanking = function($el, svg, data, indicator, years, countries, showOecdAverage, size) {
    var a, allValues, chart, chartAreaHeight, chartAreaWidth, chartElement, countryMark, globalMax, globalMin, h, highlightedCountries, i, mode, paddingBottom, paddingLeft, paddingRight, paddingTop, rangeBand, rankScale, valueAxis, valueScale, w, x, _i, _j, _k, _len, _ref, _ref1, _results, _results1;
    log("renderRanking " + years);
    allValues = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      a = data[_i];
      allValues.push(a.values[0]);
    }
    globalMin = d3.min(allValues);
    globalMax = d3.max(allValues);
    w = $el.width();
    h = $el.height();
    mode = w * 1.2 > h ? "horizontal" : "vertical";
    if (size === FULL) {
      paddingRight = 20;
      paddingBottom = 100;
      paddingTop = 70;
      paddingLeft = 50;
      if (mode === "vertical") {
        paddingLeft = 100;
        paddingBottom = 60;
      }
    } else if (size === REDUCED) {
      paddingRight = 0;
      paddingBottom = 20;
      paddingTop = 80;
      paddingLeft = 10;
      if (mode === "vertical") {
        paddingLeft = 120;
        paddingRight = 20;
      }
    } else {
      paddingRight = 0;
      paddingBottom = 0;
      paddingTop = 0;
      paddingLeft = 0;
    }
    chartAreaWidth = w - paddingRight - paddingLeft;
    chartAreaHeight = h - paddingBottom - paddingTop;
    if (mode === "horizontal") {
      valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([0, chartAreaHeight]);
      rangeBand = chartAreaWidth / data.length;
      if (size === SMALL) {
        rangeBand = 3;
      }
      rankScale = d3.scale.ordinal().domain((function() {
        _results = [];
        for (var _j = 0, _ref = data.length; 0 <= _ref ? _j <= _ref : _j >= _ref; 0 <= _ref ? _j++ : _j--){ _results.push(_j); }
        return _results;
      }).apply(this)).range((function() {
        var _j, _len1, _results;
        _results = [];
        for (i = _j = 0, _len1 = data.length; _j < _len1; i = ++_j) {
          x = data[i];
          _results.push(i * rangeBand);
        }
        return _results;
      })());
    } else {
      valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([0, chartAreaWidth]);
      rangeBand = chartAreaHeight / data.length;
      rankScale = d3.scale.ordinal().domain((function() {
        _results1 = [];
        for (var _k = 0, _ref1 = data.length; 0 <= _ref1 ? _k <= _ref1 : _k >= _ref1; 0 <= _ref1 ? _k++ : _k--){ _results1.push(_k); }
        return _results1;
      }).apply(this)).range((function() {
        var _k, _len1, _results1;
        _results1 = [];
        for (i = _k = 0, _len1 = data.length; _k < _len1; i = ++_k) {
          x = data[i];
          _results1.push(i * rangeBand);
        }
        return _results1;
      })());
    }
    chart = svg.append("g").classed("rankChart " + mode, true).attr("transform", "translate(" + paddingLeft + ", " + paddingTop + ")");
    if (size > SMALL) {
      valueAxis = d3.svg.axis().scale(valueScale).tickSize(-5, 0, 0).ticks(6).orient("left").tickFormat(function(d, i) {
        return "" + (Math.floor(d * 100)) + "%";
      });
      if (mode === "horizontal") {
        if (size > REDUCED) {
          chart.append("g").classed("axisLegend y", true).attr("transform", "translate(-20, 0)").call(valueAxis);
        }
      } else {
        chart.append("g").classed("axisLegend x", true).attr("transform", "translate(0," + chartAreaHeight + ")").call(valueAxis.orient("bottom"));
      }
    }
    data.sort(function(a, b) {
      return -(b.values[0] - a.values[0]);
    });
    highlightedCountries = countries.slice();
    if (showOecdAverage) {
      highlightedCountries.push("OTO");
    }
    countryMark = chart.selectAll('g.countryMark').data(data).enter().append("g").classed("countryMark", true).classed("highlight", function(d, i) {
      var _ref2;
      return _ref2 = d.countryCode, __indexOf.call(highlightedCountries, _ref2) >= 0;
    }).attr("title", function(d, i) {
      return "" + d.country + "<br/>" + (pretty(d.values[0]));
    });
    chartElement = countryMark.append("g").attr("title", function(d, i) {
      return "" + d.country + "<br/>" + (pretty(d.values[0]));
    }).classed("chartElement", true);
    chartElement.call(attachTip);
    countryMark.on("mouseover", function() {
      d3.select(this).selectAll("line").style("stroke", "#000").style("stroke-width", 2);
      d3.select(this).selectAll(".hoverMarker").style("stroke-width", rangeBand);
      d3.select(this).selectAll("text").style("fill", "#000");
      return d3.select(this).selectAll("circle").style("fill", "#000");
    }).on("mouseout", function() {
      d3.select(this).selectAll("line").style("stroke", null).style("stroke-width", null);
      d3.select(this).selectAll(".hoverMarker").style("stroke-width", rangeBand);
      d3.select(this).selectAll("text").style("fill", null);
      return d3.select(this).selectAll("circle").style("fill", null);
    });
    chartElement.call(attachClick, $el);
    if (mode === "horizontal") {
      countryMark.attr("transform", function(d, i) {
        return "translate(" + (rankScale(i)) + ", " + chartAreaHeight + ")";
      });
      chartElement.append("line").classed("hoverMarker", true).attr("x1", 0).attr("x2", 0).attr("y1", 0).attr("y2", function(d, i) {
        return -valueScale(d.values[0]);
      }).style("stroke-width", rangeBand).style("opacity", .0);
      chartElement.append("line").attr("x1", 0).attr("x2", 0).attr("y1", 0).attr("y2", function(d, i) {
        return -valueScale(d.values[0]);
      }).style("stroke-dasharray", function(d, i) {
        if (d.isOECDAvg) {
          return "2,1";
        } else {
          return "";
        }
      });
      if (size > SMALL) {
        chartElement.append("circle").attr("cx", 0).attr("cy", 0).attr("r", size > REDUCED ? Math.sqrt(w / 50) : 3).attr("transform", function(d, i) {
          return "translate(0, " + (-valueScale(d.values[0])) + ")";
        });
      }
      if (size > REDUCED) {
        countryMark.append("text").text(function(d, i) {
          return d.country;
        }).attr("text-anchor", "end").attr("transform", function(d, i) {
          return "rotate(-45)translate(-3,10)";
        });
      }
    } else {
      countryMark.attr("transform", function(d, i) {
        return "translate(0, " + (rankScale(i)) + ")";
      });
      chartElement.append("line").attr("y1", 0).attr("y2", 0).attr("x1", 0).attr("x2", function(d, i) {
        return valueScale(d.values[0]);
      }).style("stroke-width", rangeBand).style("opacity", 0);
      chartElement.append("line").attr("y1", 0).attr("y2", 0).attr("x1", 0).attr("x2", function(d, i) {
        return valueScale(d.values[0]);
      }).style("stroke-dasharray", function(d, i) {
        if (d.isOECDAvg) {
          return "3,2";
        } else {
          return "";
        }
      });
      chartElement.append("circle").attr("cx", 0).attr("cy", 0).attr("r", size > REDUCED ? 4 : 3).attr("transform", function(d, i) {
        return "translate(" + (valueScale(d.values[0])) + ", 0)";
      });
      countryMark.append("text").text(function(d, i) {
        return d.country;
      }).attr("text-anchor", "end").attr("transform", function(d, i) {
        return "translate(-5,5)";
      });
    }
    if (size === REDUCED) {
      countryMark.selectAll("circle").style("stroke-width", 1);
    }
    if (size > SMALL) {
      if (mode === "horizontal") {
        return chart.selectAll("g.highlight").selectAll(".chartElement").call(attachPointAnnotation);
      } else {
        return chart.selectAll("g.highlight").selectAll(".chartElement").call(attachPointAnnotation, "left center", "right center");
      }
    }
  };

  renderTimeSeries = function($el, svg, data, indicator, years, countries, showOecdAverage, size) {
    var a, allValues, chart, chartAreaHeight, chartAreaWidth, count, countryMark, globalMax, globalMin, h, highlight, highlightedCountries, i, line, paddingBottom, paddingLeft, paddingRight, paddingTop, rangeBand, val, valueScale, w, x, xAxis, yAxis, yearScale, _i, _j, _len, _len1, _ref;
    log("renderTimeSeries " + years + " " + size);
    if (size === SMALL && !(countries != null ? countries.length : void 0)) {
      showOecdAverage = true;
    }
    data.sort(function(a, b) {
      return b.values[b.values.length - 1] - a.values[a.values.length - 1];
    });
    allValues = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      a = data[_i];
      _ref = a.values;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        val = _ref[_j];
        allValues.push(val);
      }
    }
    globalMin = d3.min(allValues);
    globalMax = d3.max(allValues);
    w = $el.width();
    h = $el.height();
    if (size === FULL) {
      paddingRight = Math.max(80, w * .1);
      paddingBottom = 60;
      paddingTop = 60;
      paddingLeft = 50;
    } else if (size === REDUCED) {
      paddingRight = 20;
      paddingBottom = 20;
      paddingTop = 40;
      paddingLeft = 45;
    } else {
      paddingRight = 2;
      paddingBottom = 2;
      paddingTop = 2;
      paddingLeft = 2;
    }
    chartAreaWidth = w - paddingRight - paddingLeft;
    chartAreaHeight = h - paddingBottom - paddingTop;
    valueScale = d3.scale.linear().domain([0, globalMax]).nice().range([chartAreaHeight, 0]);
    rangeBand = chartAreaWidth / (years.length - 1);
    yearScale = d3.scale.ordinal().domain(years).range((function() {
      var _k, _len2, _results;
      _results = [];
      for (i = _k = 0, _len2 = years.length; _k < _len2; i = ++_k) {
        x = years[i];
        _results.push(i * rangeBand);
      }
      return _results;
    })());
    line = d3.svg.line().x(function(d, i) {
      return yearScale(years[i]);
    }).y(function(d, i) {
      return valueScale(d);
    });
    chart = svg.append("g").classed("lineChart", true).attr("transform", "translate(" + paddingLeft + ", " + paddingTop + ")");
    if (size === FULL) {
      xAxis = d3.svg.axis().scale(yearScale).tickSize(-5, 0, 0);
      chart.append("g").classed("axisLegend x", true).attr("transform", "translate(0, " + (chartAreaHeight + 5) + ")").call(xAxis);
    }
    if (size > SMALL) {
      yAxis = d3.svg.axis().scale(valueScale).tickSize(-5, 0, 0).ticks(6).orient("left").tickFormat(function(d, i) {
        return "" + (Math.floor(d * 100)) + "%";
      });
      chart.append("g").classed("axisLegend y", true).attr("transform", "translate(-15, 0)").call(yAxis);
    }
    countryMark = chart.selectAll('g.countryMark').data(data).enter().append("g").classed("countryMark", true).attr("title", function(d, i) {
      return d.country;
    });
    countryMark.append("path").style("stroke-width", 10).attr("d", function(d, i) {
      return line(d.values);
    }).style("opacity", 0);
    countryMark.append("path").style("stroke-width", 1).attr("d", function(d, i) {
      return line(d.values);
    });
    countryMark.call(attachTip, "mouse", null, null, 0, -10);
    countryMark.call(attachClick, $el);
    countryMark.on("mouseover", function() {
      return d3.select(this).select(".highlight").attr("visibility", "visible");
    }).on("mouseout", function() {
      return d3.select(this).select(".highlight").attr("visibility", function(d, i) {
        var _ref1;
        if (_ref1 = d.countryCode, __indexOf.call(highlightedCountries, _ref1) >= 0) {
          return "visible";
        } else {
          return "hidden";
        }
      });
    });
    highlightedCountries = countries.slice();
    if (showOecdAverage) {
      highlightedCountries.push("OTO");
    }
    highlight = countryMark.append("g").classed("highlight", true).classed("annotated", function(d, i) {
      var _ref1;
      return _ref1 = d.countryCode, __indexOf.call(highlightedCountries, _ref1) >= 0;
    }).classed("oecdAvg", function(d, i) {
      return d.isOECDAvg && !(__indexOf.call(countries, "OTO") >= 0);
    }).attr("title", function(d, i) {
      return "" + d.country + ": " + (pretty(d.values[d.values.length - 1]));
    }).attr("visibility", function(d, i) {
      var _ref1;
      if (_ref1 = d.countryCode, __indexOf.call(highlightedCountries, _ref1) >= 0) {
        return "visible";
      } else {
        return "hidden";
      }
    });
    highlight.append("path").attr("d", function(d, i) {
      return line(d.values);
    }).style("stroke-width", 6).style("stroke", "#FFF");
    highlight.append("path").attr("d", function(d, i) {
      return line(d.values);
    }).style("stroke-dasharray", function(d, i) {
      if (d.isOECDAvg && size > 0) {
        return "3,2";
      } else {
        return "";
      }
    });
    highlight.selectAll("circle").data(function(d, i) {
      return d.values;
    }).enter().append("circle").attr("cx", function(d, i) {
      return yearScale(years[i]);
    }).attr("cy", function(d, i) {
      return valueScale(d);
    }).attr("r", function(d, i) {
      if (size > 0) {
        return 4;
      } else {
        return 2;
      }
    });
    if (size > SMALL) {
      count = 0;
      return highlight.filter(function(d) {
        var _ref1;
        return _ref1 = d.countryCode, __indexOf.call(highlightedCountries, _ref1) >= 0;
      }).each(function(d, i) {
        var t, _this;
        _this = this;
        t = d3.select(this).selectAll("circle").filter(function(d, i) {
          return i === years.length - 1;
        }).attr("title", "" + (d3.select(this).attr("title")));
        if (size === REDUCED) {
          if (count === 0) {
            t.call(attachPointAnnotation, "top right", "bottom center");
          } else {
            t.call(attachPointAnnotation, "bottom right", "top center");
          }
        } else {
          if (count === 0) {
            t.call(attachPointAnnotation, "bottom left", "top right");
          } else if (count === 1) {
            t.call(attachPointAnnotation, "center left", "center right");
          } else {
            t.call(attachPointAnnotation, "top left", "bottom right");
          }
        }
        return count++;
      });
    }
  };

  toggleCountrySelection = function($el, countryCode) {
    var selectedCountries, _ref;
    selectedCountries = (_ref = $el.attr("data-countries")) != null ? _ref.split(",") : void 0;
    if (selectedCountries == null) {
      selectedCountries = [];
    }
    log(selectedCountries);
    if (__indexOf.call(selectedCountries, countryCode) >= 0) {
      selectedCountries = _.without(selectedCountries, countryCode);
    } else {
      selectedCountries.push(countryCode);
    }
    return $el.attr("data-countries", selectedCountries.join(","));
  };

}).call(this);

$(document).ready(function(){
	$("#map-container").renderDiagram();
});