module("luci.controller.api.system", package.seeall)

local LuciUtil = require("luci.util")
local LuciHttp = require("luci.http")
local CommonUtil = require("yunhuwifi.CommonUtil")
local LuciSys = require("luci.sys")

function index()
    local page   = node("api","system")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "root"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "system"}, firstchild(), _(""), 300)
	entry({"api", "system", "login"}, call("login"), _(""), 301).sysauth = false
	entry({"api", "system", "password"}, call("changePassword"), _(""), 301)
end

function login()
	local username = "root"
	local password = LuciHttp.formvalue("password")
	local result = {}
	if LuciSys.user.checkpasswd(username, password) then
		result['code'] = 0
		result['info'] = {
			url = luci.dispatcher.build_url("web/home")
		}
	else
		result['code'] = 1001
		result['message'] = CommonUtil.ERROR_Message[result['code']]
	end
	
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end

function changePassword()
	local password = LuciHttp.formvalue("password")
	
	if LuciSys.user.checkpasswd(username, password) then
		LuciSys.user.setpasswd(password)
		result['code'] = 0
	else
		result['code'] = 1003
		result['message'] = CommonUtil.ERROR_Message[result['code']]
	end
	
	LuciHttp.prepare_content("application/json")
	LuciHttp.write_json(result)
end