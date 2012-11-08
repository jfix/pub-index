/* $Id$ */

$(document).ready(function () {
  
  $("div.facet ul li a, div.facet a").click(function () {
    var facet = $(this).attr("href");
    var facets = manageFacets(facet, __currentFacets);
    var filterString = serializeFacets(facets);
    var filterJson = JSON.stringify(facets);
    event.preventDefault();
    $("#filter-string").val(filterString); // used for marklogic
    $("#filter-json").val(filterJson);     // used by javascript
    $("#searchForm").submit();
  });
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
function manageFacets(facet, currentFacets) {
  var facetTokenized = facet.split(":"),
  key = facetTokenized[0],
  val = facetTokenized[1],
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
  return currentFacets
  serializeFacets(currentFacets);
}

/**
* Takes facet object and creates a string that MarkLogic understands.
*
*
*/
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