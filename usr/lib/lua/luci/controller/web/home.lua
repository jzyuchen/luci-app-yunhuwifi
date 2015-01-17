module("luci.controller.web.home", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page

	page = node("web", "home")
	page.target = firstchild()
	page.title  = _("Â·ÓÉ×´Ì¬")
	page.order  = 10
	page.index  = true

	page = entry({"web", "home"}, template("web/home", nil))
end