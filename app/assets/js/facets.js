$(function () {

var $filterString = $("#in");
var currentFacets = deserializeFacets($filterString.val());

$("div.facet ul li a, div.facet a").click(function (event) {
  event.preventDefault();
  
  var facet = $(this).data("facet");
  if(facet) {
    var value = $(this).data("value");
    if(value) {
      var facets = manageFacets(facet, value, currentFacets);
      var filterString = serializeFacets(facets);
      
      $filterString.val(filterString);
      $("#searchForm").submit();
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
function manageFacets(facet, value, currentFacets) {
  key = facet,
  val = value,
  arr = currentFacets[key];
  
  if (arr) {
    var pos = $.inArray(val, arr);
    
    if (arr.length == 1 && pos == 0) {
      delete currentFacets[key];
    } else if (pos >= 0) {
      arr.splice(pos, 1);
      currentFacets[key] = arr;
    } else {
      currentFacets[key].push(val);
    }
  } else {
    currentFacets[key] =[val];
  }
  return currentFacets;
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
  var js = {};
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
        js = manageFacets(facet, value, js);
      }
    }
  }
  
  return js;
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