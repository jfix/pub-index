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

(function init_dateslider() {
  var $startDate = $('#start-date');
  var $endDate = $('#end-date');
  var $slider = $('#slider-date-range');
  
  var oldest = new Date($startDate.data('oldest') + "T00:00:00");
  var newest = new Date($endDate.data('newest') + "T00:00:00");
  
  var from;
  if(currentFacets.from) {
    from =  new Date(currentFacets.from[0] + "T00:00:00");
  }
  
  var to;
  if(currentFacets.to) {
    to =  new Date(currentFacets.to[0] + "T00:00:00");
  }
  else {
    to = new Date();
    to.setHours(0,0,0,0);
  }
  
  var nbdays = (newest - oldest)/86400000;
  
  var converSliderIndexToDate = function converSliderIndexToDate(index) {
    var time = oldest.getTime() + (index*86400000);
    return new Date(time);
  };
  
  var converDateToSliderIndex = function converDateToSliderIndex(date) {
    var index  = (date - oldest)/86400000;
    return index;
  };
  
  var submitForm = function submitForm() {
    if(currentFacets.from) delete currentFacets.from;
    manageFacets("from", formatDate($startDate.datepicker("getDate")), currentFacets);
    if(currentFacets.to) delete currentFacets.to;
    manageFacets("to", formatDate($endDate.datepicker("getDate")), currentFacets);
    
    var filterString = serializeFacets(currentFacets);
    $filterString.val(filterString);
    $("#searchForm").submit();
  };
  
  var formatDate = function formatDate(date) {
    var dd = date.getDate();
    var mm = date.getMonth()+1; //January is 0!
    var yyyy = date.getFullYear();
    
    if(dd<10){dd='0'+dd}
    if(mm<10){mm='0'+mm}
    return yyyy + '-' + mm + '-' + dd;
  }
  
  var maxDate = function maxDate(d1,d2) {
    if(!d1)
      return d2;
    if(!d2)
      return d1;
    return d1 > d2 ? d1 : d2;
  }
  
  var minDate = function minDate(d1,d2) {
    if(!d1)
      return d2;
    if(!d2)
      return d1;
    return d1 < d2 ? d1 : d2;
  }
  
  $(".facet .datepicker").datepicker({
    dateFormat: 'd M yy',
    changeMonth: true,
    changeYear: true
  });
  
  $startDate.datepicker( "setDate", maxDate(from,oldest) );
  $endDate.datepicker( "setDate", minDate(to,newest) );
  
  var timeoutHandle;
  
  $startDate.change(function(event) {
    var newDate = $startDate.datepicker("getDate");
    if(newDate) {
      $slider.slider("values", 0, converDateToSliderIndex(newDate));
    }
    else {
      $startDate.datepicker( "setDate", oldest );
      $slider.slider("values", 0, 0);
    }
    
    if(timeoutHandle) clearTimeout(timeoutHandle);
    timeoutHandle = setTimeout(submitForm,2000);
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
    
    if(timeoutHandle) clearTimeout(timeoutHandle);
    timeoutHandle = setTimeout(submitForm,2000);
  });
  
  $slider.slider({
    range: true,
    min: 0,
    max: nbdays,
    values: [converDateToSliderIndex($startDate.datepicker("getDate")), converDateToSliderIndex($endDate.datepicker("getDate"))],
    slide: function( event, ui ) {
      if(timeoutHandle) clearTimeout(timeoutHandle);
      $startDate.datepicker( "setDate", converSliderIndexToDate(ui.values[0]) );
      $endDate.datepicker( "setDate", converSliderIndexToDate(ui.values[1]) );
    },
    change: function( event, ui) {
      timeoutHandle = setTimeout(submitForm,2000);
    }
  });
  
})();

$("span#clear-facets").click( function (evt) {
    location.href="/search?term=&in=&start=1&order=";
});
$("span.selected-facet").on("hover", function (evt) {
     $(this).find("i").toggleClass("icon-ok").toggleClass("icon-remove");
     $(this).toggleClass("delete-facet");
});

// manage facet values in search result
$(".facet-value, .pubtype-label").click(function (event) {
  event.preventDefault(); /* not sure why this is needed, there is no default action on span elements */
  event.stopPropagation(); /* otherwise click event bubbles up to search-result-item parent which will display publication page */

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

});