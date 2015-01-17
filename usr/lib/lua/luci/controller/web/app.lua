module("luci.controller.web.app", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page

	page = node("web", "app")
	page.target = firstchild()
	page.title  = _("应用管理")
	page.order  = 30
	page.index  = true

	page = entry({"web", "app"}, template("web/app_list", nil))
end