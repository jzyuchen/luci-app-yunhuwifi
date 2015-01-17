$(function(){
	$(".navbar > li.active > .navbar-sub").show();
	initLayout();
	$(window).resize(initLayout);
	$(".navbar > li > a").click(function(){
		if ($(this).parent().find(".navbar-sub").length > 0)
		{
			$(".navbar > li > .navbar-sub").hide();
			$(this).parent().find(".navbar-sub").show();
			return false;
		}
	});
})

function initLayout(){
	var winHeight = $(window).height();
	var hdHeight = $(".header").height();
	var contentHeight = $(".content").height();
	if (winHeight > (hdHeight + contentHeight))
	{
		$(".content").height(winHeight - hdHeight);
	}
	$(".nav").height(contentHeight);
}