module("luci.controller.web.system", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page

	page = node("web", "system")
	page.target = firstchild()
	page.title  = _("Network")
	page.order  = 40
	page.index  = true

	entry({"web", "services"}, firstchild(), _("System"), 30).index = true
	entry({"web", "system", "reboot"}, template("web/system_reboot", nil))
	entry({"web", "system", "upgrade"}, template("web/system_upgrade", nil))
	entry({"web", "system", "reset"}, template("web/system_reset", nil))
end