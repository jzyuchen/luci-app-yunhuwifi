module("luci.controller.web.device", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page

	page = node("web", "device")
	page.target = firstchild()
	page.title  = _("设备管理")
	page.order  = 20
	page.index  = true

	page = entry({"web", "device"}, template("web/device_list", nil))
end