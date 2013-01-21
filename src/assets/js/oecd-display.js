$(function() {

var id = new RegExp("([^/])+(\\?|$)","").exec(window.location.href)[0];
$('#backlinks').load('/app/actions/backlinks.xqy?id='+id);

$('#toc-root').on('click', '.toc-row-header', function onClick_TocRowHeader(event) { 
  if(event.target.nodeName != 'A') {
    var $target = $(this).find('a.icon-download-alt');
    if($target) {
      $target[0].click();
    }
  }
});

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

});