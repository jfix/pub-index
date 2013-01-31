$(function() {

/* load backlinks/related links */
var id = new RegExp("([^/])+(\\?|$)","").exec(window.location.href)[0];
$('#backlinks').load('/app/actions/backlinks.xqy?id='+id);

/* make TOC rows clickable */
$('#toc-root').on('click', '.toc-row-header', function onClick_TocRowHeader(event) { 
  if(event.target.nodeName != 'A') {
    var $target = $(this).find('a.icon-download-alt');
    if($target) {
      var anchor = $target[0];
      if(anchor.click) {
        anchor.click();
      }
      else {
        var href = anchor.href;
        if(href) {
          window.open(href);
        }
      }
    }
  }
});

/* add logic to "show abstracts" & "show tables/graphs" action buttons */
$('#toc-actions .btn').each(function() {
  var $btn = $(this);
  var toggle = $btn.data('toggle');
  if(toggle) {
    var $targets = $('#toc-root').find(toggle);
    var $icon = $btn.children('i');
    $btn.click(function() {
      $targets.fadeToggle();
      $btn.toggleClass('active');
      if($icon.hasClass('icon-eye-open')) {
        $icon.removeClass('icon-eye-open');
        $icon.addClass('icon-eye-close');
      }
      else {
        $icon.removeClass('icon-eye-close');
        $icon.addClass('icon-eye-open');
      }
    });
  }
});

/* add logic to summaries dropdown */
$('#summaries').on('change', function onChange_Summaries() {
  var url = $(this).val();
  if(url) {
    window.open(url);
  }
});

/* enable tooltips on links in TOC */
$('#toc-root').find('div.links > a').tooltip();

/* trigger tooltip on iLibrary links when hovering TOC rows */
$('#toc-root').on('hover','div.toc-row-header',function onHover_TocRowHeader(event){
  if(event.target.nodeName != 'A') {
    var $target = $(this).find('a.icon-download-alt');
    if($target) {
      if(event.type == 'mouseenter') {
        $target.tooltip('show');
      }
      else {
        $target.tooltip('hide');
      }
    }
  }
});
$('#toc-root').on('hover','div.links',function onHover_TocLinks(event){
  if(event.target.nodeName != 'A' && event.type == 'mouseenter') {
    var $target = $(this).find('a.icon-download-alt');
    if($target) {
      $target.tooltip('hide');
    }
  }
});

});