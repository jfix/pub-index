$(function onLoad_Search () {

// make pager works (we should provide working url on buttons...)
$(".pager a").click(function() {
  var start = $(this).data("start");
  if(start) {
    $("#start").val(start);
    $("#searchForm").submit();
  }
});

// make sort dropdown works
$("#sortby").on("change", function onClick_SortBy(event) {
  $("#order").val($(this).val());
  $("#searchForm").submit();
});

});