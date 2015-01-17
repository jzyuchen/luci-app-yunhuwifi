module("luci.controller.web.setting", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page

	page = node("web", "setting")
	page.target = firstchild()
	page.title  = _("Network")
	page.order  = 40
	page.index  = true

	-- wifi settings
	page = entry({"web", "setting", "wifi"}, template("web/setting_wifi", nil))
end