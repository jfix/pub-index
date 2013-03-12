/*globals $*/
$(function onLoad_Search() {

  // make pager works (we should provide working url on buttons...)
  $(".pager a").click(function () {
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

  $(".search-result-item .abstract").on("hover", function (evt) {
    $(this).parents("div.metadata").addClass("show-full-abstract");
  });
  $(".search-result-item").on("hover", function (evt) {
    $(this).toggleClass("highlight").find(".metadata").toggleClass("active").find("h4 a, h5 a").toggleClass("underline");
  });
  $(".search-result-item").on("click", function (evt) {
    location.href = $(this).data('url');
  });
});