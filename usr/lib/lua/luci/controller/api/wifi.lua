module("luci.controller.api.wifi", package.seeall)

local LuciNetwork = require("luci.model.network")
local LuciUtil = require("luci.util")
local LuciHttp = require("luci.http")

local UCI = require("luci.model.uci").cursor()

function index()
    local page   = node("api","wifi")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "root"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "wifi"}, firstchild(), _(""), 300)
	entry({"api", "wifi", "list"}, call("getAllWifiInfo"), _(""), 301).sysauth = false
	entry({"api", "wifi", "detail"}, call("getWifiInfo"), (""), 302).sysauth = false
	entry({"api", "wifi", "edit"}, call("setAllWifiInfo"), (""), 302).sysauth = false
	entry({"api", "wifi", "set_region"}, call("setRegion"), (""), 302).sysauth = false
end

function getAllWifiInfo()
    local wifiUtil = require("yunhuwifi.WifiUtil")
    local result = {}
    local code = 0
    result["info"] = wifiUtil.getAllWifiInfo()
    result["code"] = code
	LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function getWifiInfo()
    local wifiUtil = require("yunhuwifi.WifiUtil")
    local result = {}
    local code = 0
    local index = tonumber(LuciHttp.formvalue("wifiIndex"))
    if index and index < 3 then
        result["info"] = wifiUtil.getAllWifiInfo()[index]
    else
        code = 1523
    end
    if code ~= 0 then
       --result["msg"] = XQErrorUtil.getErrorMessage(code)
    end
    result["code"] = code
	LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function setAllWifiInfo()
    -- 2.4g
	local wifi2g = {
		ssid = LuciHttp.formvalue("wifi1_ssid"),
		hidden = LuciHttp.formvalue("wifi1_hidden"),
		encryption = LuciHttp.formvalue("wifi1_encryption"),
		password = LuciHttp.formvalue("wifi1_password"),
		channel = LuciHttp.formvalue("wifi1_channel"),
		bandwith = LuciHttp.formvalue("wifi1_bandwith")
	}
	
	-- 5g
	local wifi5g = {
		ssid = LuciHttp.formvalue("wifi2_ssid"),
		hidden = LuciHttp.formvalue("wifi2_hidden"),
		encryption = LuciHttp.formvalue("wifi2_encryption"),
		password = LuciHttp.formvalue("wifi2_password"),
		channel = LuciHttp.formvalue("wifi2_channel"),
		bandwith = LuciHttp.formvalue("wifi2_bandwith")
	}

	local wifiUtil = require("yunhuwifi.WifiUtil")
	local success2g = wifiUtil.setWifiBasicInfo(1, wifi2g.ssid, wifi2g.password, wifi2g.encryption, wifi2g.channel, "", wifi2g.hidden, 1, wifi2g.bandwith)
	local success5g = wifiUtil.setWifiBasicInfo(2, wifi5g.ssid, wifi5g.password, wifi5g.encryption, wifi5g.channel, "", wifi5g.hidden, 1, wifi5g.bandwith)
	
	local result = {}
	if success2g and success5g then
		result["code"] = 0
	else
		result["code"] = 1001
	end
	LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function setRegion()
	local country = LuciHttp.formvalue("countryCode")
	
	local wifiUtil = require("yunhuwifi.WifiUtil")
	local success = wifiUtil.setWifiRegion(country)
	
	local result = {}
	if success then
		result['code'] = 0
	else
		result['code'] = 1510
	end
	LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end