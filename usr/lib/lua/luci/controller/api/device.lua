module("luci.controller.api.device", package.seeall)

function index()
    local page   = node("api","device")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 500
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "device"}, firstchild(), _(""), 500)
    entry({"api", "device", "list"}, call("getDeviceList"), _(""), 501).sysauth = false
    entry({"api", "device", "set_name"}, call("setDeviceName"), _(""), 502).sysauth = false
    entry({"api", "device", "black_list"}, call("getBlackList"), _(""), 503)
    entry({"api", "device", "set_device_black_list"}, call("setDeviceToBlackList"), _(""), 504)
    entry({"api", "device", "remove_device_black_list"}, call("removeDeviceFromBlackList"), _(""), 505)
end

local LuciHttp = require("luci.http")
local DeviceUtil = require("yunhuwifi.DeviceUtil")
local CommonUtil = require("yunhuwifi.CommonUtil")

function getDeviceList()
	local result = {}
	result['code'] = 0
	result['info'] = DeviceUtil.getDeviceList()
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end

function setDeviceName()
	local mac = LuciHttp.formvalue("mac")
	local name = LuciHttp.formvalue("name")
	local result = {}
	if CommonUtil.isMac(mac) then
		DeviceUtil.setDeviceName(mac, name)
		result['code'] = 0
		result['info'] = { mac = mac, name = name }
	else
		result['code'] = 1
		result['message'] = "bad argment."
	end
	
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end

function getBlackList()
	LuciHttp.write_json(DeviceUtil.getBlackList())
end

function setDeviceToBlackList()
	local mac = LuciHttp.formvalue("mac")
	
	local result = {}
	if not CommonUtil.isNilOrEmpty(mac) then
		DeviceUtil.setDeviceToBlackList(mac)
		result['code'] = 0
	else
		result['code'] = 1
		result['message'] = _("bad argment.")
	end
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end

function removeDeviceFromBlackList()
	local mac = LuciHttp.formvalue("mac")
	local result = {}
	if not CommonUtil.isNilOrEmpty(mac) then
		DeviceUtil.removeDeviceFromBlackList(mac)
		result['code'] = 0
	else
		result['code'] = 1
		result['message'] = _("bad argment.")
	end
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end