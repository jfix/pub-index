$(function () {

var $filterString = $("#in");
var currentFacets = {};

deserializeFacets($filterString.val());

$("div.facet ul li a, div.facet a, div.facet span").click(function (event) {
  event.preventDefault();
  
  var facet = $(this).data("facet");
  if(facet) {
    var value = $(this).data("value");
    if(value) {
      manageFacets(facet, value);
      var filterString = serializeFacets(currentFacets);
      
      $filterString.val(filterString);
      $("#searchForm").submit();
    }
  }
});

$("div.facet select").change(function(event) {
  var facet = $(this).data("facet");
  var value = $(this).val();
  
  if(currentFacets[facet]) {
    var oldValue = currentFacets[facet][0];
    if(oldValue) {
      manageFacets(facet, oldValue);
    }
  }
  
  if(value != "") {
    manageFacets(facet, value);
  }
  
  var filterString = serializeFacets(currentFacets);
  
  $filterString.val(filterString);
  $("#searchForm").submit();
});

(function() {
  var $startDate = $('#start-date');
  var $endDate = $('#end-date');
  var $slider = $('#slider-date-range');
  
  var oldest = $startDate.data('oldest');
  oldest = new Date(oldest + "T00:00:00");
  
  var newest = $endDate.data('newest');
  newest = new Date(newest + "T00:00:00");
  
  var nbdays = (newest - oldest)/86400000;
  
  var converSliderIndexToDate = function(index) {
    var time = oldest.getTime() + (index*86400000);
    return new Date(time);
  };
  
  var converDateToSliderIndex = function(date) {
    var index  = (date - oldest)/86400000;
    return index;
  };
  
  var submitForm = function() {
    /*
    manageFacets("startDate", $startDate.datepicker("getDate").toISOString().substr(0,10), currentFacets);
    manageFacets("endDate", $endDate.datepicker("getDate").toISOString().substr(0,10), currentFacets);
    
    var filterString = serializeFacets(currentFacets);
    $filterString.val(filterString);
    $("#searchForm").submit();
    */
  };
  
  $(".facet .datepicker").datepicker({
    dateFormat: 'd M yy',
    changeMonth: true,
    changeYear: true
  });
  
  $startDate.datepicker( "setDate", oldest );
  $endDate.datepicker( "setDate", newest );
  
  $startDate.change(function(event) {
    var newDate = $startDate.datepicker("getDate");
    if(newDate) {
      $slider.slider("values", 0, converDateToSliderIndex(newDate));
    }
    else {
      $startDate.datepicker( "setDate", oldest );
      $slider.slider("values", 0, 0);
    }
    submitForm();
  });
  
  $endDate.change(function(event) {
    var newDate = $endDate.datepicker("getDate");
    if(newDate) {
      $slider.slider("values", 1, converDateToSliderIndex(newDate));
    }
    else {
      $endDate.datepicker( "setDate", newest );
      $slider.slider("values", 1, nbdays);
    }
    submitForm();
  });
  
  $slider.slider({
    range: true,
    min: 0,
    max: nbdays,
    values: [0, nbdays],
    slide: function( event, ui ) {
      $startDate.datepicker( "setDate", converSliderIndexToDate(ui.values[0]) );
      $endDate.datepicker( "setDate", converSliderIndexToDate(ui.values[1]) );
    },
    change: function( event, ui) {
      submitForm();
    }
  });

})();

// manage facet values in search result
$(".facet-value").click(function (event) {
  event.preventDefault();
  
  var facet = $(this).data("facet");
  if(facet) {
    var value = $(this).data("value");
    if(value) {
      if(manageFacets(facet, value, true)) {
        var filterString = serializeFacets(currentFacets);
        
        $filterString.val(filterString);
        $("#searchForm").submit();
      }
    }
  }
});

/**
* ( pubtype:book OR pubtype:article ) subject:"Development"
*
* {
*   pubtype: ['book', 'chapter'],
*   subject: ['Tax', 'Sustainable development']
* }
* values with spaces must be surrounded with double quotes
*
*/
function manageFacets(facet, value, addonly) {
  key = facet,
  val = value+'',
  arr = currentFacets[key];
  
  if (arr) {
    var pos = $.inArray(val, arr);
    
    if (arr.length == 1 && pos == 0) {
      if(addonly) return false;
      delete currentFacets[key];
    } else if (pos >= 0) {
      if(addonly) return false;
      arr.splice(pos, 1);
      currentFacets[key] = arr;
    } else {
      currentFacets[key].push(val);
    }
  } else {
    currentFacets[key] = [val];
  }
  
  return true;
}

function serializeFacets(currentFacets) {
  var serialized = "";
  for (key in currentFacets) {
    var values = currentFacets[key];
    if (values.length > 0) {
      serialized += key + ":";
      for (var i = 0; values.length > i; i++) {
        if (i > 0)
          serialized += "|";
        
        serialized += values[i];
      }
      serialized += ";";
    }
  }
  return $.trim(serialized);
}

function deserializeFacets(filterString) {
  var facets = filterString.split(";");
  for(var i = 0; i < facets.length; i++) {
    var facetString = facets[i];
    if(facetString != "") {
      var arr = facetString.split(":");
      var facet = arr[0];
      var values = arr[1];
      arr = values.split("|");
      for(var j = 0; j < arr.length; j++) {
        var value = arr[j];
        manageFacets(facet, value);
      }
    }
  }
}

/**
* Takes facet object and creates a string that MarkLogic understands.
*
*
function serializeFacets(currentFacets) {
  var serialized = "";
  
  for (key in currentFacets) {
    var values = currentFacets[key];
    if (values.length > 1) {
      serialized += "(";
      for (var i = 0; values.length > i; i++) {
        var needsQuotes = (values[i].search(" ") >= 0);
        
        if (i > 0) serialized += " OR ";
        
        if (needsQuotes) {
          serialized += key + ":" + '"' + values[i] + '"';
        } else {
          serialized += key + ":" + values[i];
        }
      }
      serialized += ")";
    } else {
      if (values[0].search(" ") >= 0) {
        serialized += key + ":" + '"' + values[0] + '"';
      } else {
        serialized += key + ":" + values[0];
      }
    }
    serialized += " ";
  }
  return $.trim(serialized);
}
*/

});