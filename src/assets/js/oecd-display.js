/*globals $*/
$(function () {

    /* load backlinks/related links */
    //var id = new RegExp("([^/])+(\\?|$)", "").exec(window.location.href)[0];
    //$('#backlinks').load('/app/actions/backlinks.xqy?id=' + id);
    /* make TOC rows clickable: show/hide abstract */
    $('#toc-root').on('click', '.toc-row-header', function onClick_TocRowHeader(event) {
        if(event.target.nodeName !== 'A') {
            var $target = $(this).find('a.icon-download-alt');
            if($target) {
                var $row = $(this).parent('.toc-row');
                $target = $row.find('.toc-abstract');
                $target.fadeToggle();
            }
        }
    });

    /* add logic to "show abstracts" & "show tables/graphs" action buttons */
    $('#toc-actions .btn').each(function () {
        var $btn = $(this);
        var toggle = $btn.data('toggle');
        if(toggle) {
            var $targets = $('#toc-root').find(toggle);
            var $icon = $btn.children('i');
            $btn.click(function () {
                var visible = $btn.hasClass('active');

                $btn.toggleClass('active');
                if(visible) {
                    $targets.fadeOut();
                } else {
                    $targets.fadeIn();
                }
            });
        }
    });

    // don't show the big/small toc toggle button if there is no need
    if($("ul#toc-root").height() <= 400) {
        $("#toc-expander").remove();
        $("#toc-box").removeClass("toc-box-condensed");
    }
    $("#toc-expander").on("click", function (evt) {
        var $btn = $(this);
        var $icn = $btn.find("i");
        var $lbl = $btn.find("span");

        $("#toc-box").toggleClass("toc-box-condensed");

        if($icn.hasClass("icon-chevron-down")) {
            $icn.removeClass("icon-chevron-down");
            $icn.addClass("icon-chevron-up");
            $lbl.text("Reduce table of contents");
        } else {
            $icn.addClass("icon-chevron-down");
            $icn.removeClass("icon-chevron-up");
            $lbl.text("Expand table of contents");
        }
    });

    /* add logic to summaries dropdown */
    $('#summaries').on('change', function onChange_Summaries() {
        var url = $(this).val();
        if(url) {
            window.open(url);
        }
    });
    // show tooltip on mouseover to click to see abstract
    // FIXME: use .filter() instead, apparently faster
    //$("li.toc-row span.toc-title")
      //  .tooltip({"delay": 100, "placement": "right", title: "Click to view abstract"});
    /* .toc-row:has(p.toc-abstract:hidden) */
    
    $("ul#toc-root>li").has( "p.toc-abstract:hidden" ).hover(
        function() {
            $(this).find("div.toc-row-clickable>span.toc-title").append("<strong class='click-abstract text-info'> Click to view abstract</strong>");
        },
        function() {
            $(this).find(".click-abstract").remove();
        });

    /* enable tooltips on links in TOC */
    //$('#toc-root').find('div.links > a').tooltip();
});