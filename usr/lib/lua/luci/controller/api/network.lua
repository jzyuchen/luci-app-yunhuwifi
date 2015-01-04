module("luci.controller.api.network", package.seeall)

function index()
    local page   = node("api","network")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "network"}, firstchild(), _(""), 300)
	entry({"api", "network", "lan_info"}, call("lanInfo"), _(""), 301)
	entry({"api", "network", "wan_info"}, call("wanInfo"), _(""), 302)
	entry({"api", "network", "dhcp_info"}, call("dhcpInfo"), _(""), 303)
	entry({"api", "network", "is_internet_available"}, call("isInternetAvaliable"), _(""), 304)
end

local LuciHttp = require("luci.http")
local LuciFs = require("luci.fs")
local NixioFs = require("nixio.fs")

function lanInfo()
end

function wanInfo()
end

function dhcpInfo()
end

function isInternetAvaliable()
end