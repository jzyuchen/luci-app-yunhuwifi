module("luci.controller.api.network", package.seeall)

function index()
    local page   = node("api","network")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "root"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "network"}, firstchild(), _(""), 400)
	entry({"api", "network", "get_interfaces"}, call("getInterfaces"), _(""), 401).sysauth = false
	entry({"api", "network", "get_interface"}, call("getInterface"), _(""), 402).sysauth = false
	entry({"api", "network", "lan"}, call("lan"), _(""), 403).sysauth = false
	entry({"api", "network", "wan"}, call("wan"), _(""), 404).sysauth = false
end

local http = require("luci.http")

function getInterfaces()
	local network = require("luci.model.yunhu.network")
	
	local result = {}
	result['code'] = 0
	result['result'] = network:getInterfaces()
	
	luci.http.prepare_content("application/json")
	http.write_json(result)
end

function lan()
	local network = require("luci.model.yunhu.network")
	
	local result = {}
	result['code'] = 0
	result['result'] = network:getLan()
	
	luci.http.prepare_content("application/json")
	http.write_json(result)
end

function wan()
	local network = require("luci.model.yunhu.network")
	
	local result = {}
	result['code'] = 0
	result['result'] = network:getWan()
	
	luci.http.prepare_content("application/json")
	http.write_json(result)
end