/*globals $:true*/
$(function () {
  $('#term').typeahead({
    minLength: 2,
    source: function typehead_source(query, process) {
      $.post('/suggest', {
        term: query
      }, function (data) {
        process(data);
      });
    },
    updater: function typeahead_updater(item) {
      var oldval = this.$element.val();
      var regex = new RegExp(oldval, 'i');
      if(regex.test(item)) {
        this.$element.val(item);
      } else {
        item = oldval;
      }
      $("#in").val(''); // clean facets
      $("#searchForm").submit();
      return item;
    }
  });
  // remove facet filters on manual submit
  $('#searchForm').on('submit', function (event) {
    if(!event.isTrigger) {
      $("#in").val('');
    }
  });
});