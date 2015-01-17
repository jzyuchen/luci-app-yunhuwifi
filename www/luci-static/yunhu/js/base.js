$(function(){
	$(".nav").height($(window).height());
	$(window).resize(function(){
		$(".nav").top(0);
	})
})