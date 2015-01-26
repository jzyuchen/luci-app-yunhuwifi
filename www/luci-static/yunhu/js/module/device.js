$(function(){
	var dialog;
	$(".device-edit").click(function(){
		var mac = $(this).attr("data-mac");
		var name = $(this).attr("data-name")
		dialog = $("#edit_dialog").modal({
			minHeight : 300,
			minWidth : 400,
			escClose:true,  
			close:true,
			opacity  : 50,
			onShow : function(){
				$("#mac").val(mac);
				$("#name").val(name);
			}
		});
		return false;
	});
	
	$.getJSON("/luci-static/yunhu/js/oui.json", function(data){
		$(".device-icon").each(function(){
			var mac = $(this).attr("data-mac");
			var item = data[mac];
			if (item){
				$(this).attr("src","/luci-static/yunhu/images/deviceicon/" + item.icon);
			}
		})
	});
	
	$("#edit_dialog").ajaxForm(function(data){
		if (data.code == 0){
			if (dialog)
				dialog.close();
			
			var macId = data.info.mac.replace(/:/g, "_");
			$("#mac_" + macId).text(data.info.name);
		}
	});
});