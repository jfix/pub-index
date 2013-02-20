$(function() {

/* load backlinks/related links */
var id = new RegExp("([^/])+(\\?|$)","").exec(window.location.href)[0];
$('#backlinks').load('/app/actions/backlinks.xqy?id='+id);

/* make TOC rows clickable: show/hide abstract */
$('#toc-root').on('click', '.toc-row-header', function onClick_TocRowHeader(event) { 
  if(event.target.nodeName != 'A') {
    var $target = $(this).find('a.icon-download-alt');
    if($target) {
      var $row = $(this).parent('.toc-row');
      var $target = $row.find('.toc-abstract');
      $target.fadeToggle();
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
      var visible = $btn.hasClass('active');
      
      $btn.toggleClass('active');
      if(visible) {
        $targets.fadeOut();
      }
      else {
        $targets.fadeIn();
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

});