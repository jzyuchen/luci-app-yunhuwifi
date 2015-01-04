--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: rpc.lua 6685 2011-01-02 19:55:21Z jow $
]]--

local require = require
local pairs = pairs
local print = print
local pcall = pcall
local table = table

module "luci.controller.api.index"

function index()
	local function authenticator(validator, accs)
		local auth = luci.http.formvalue("auth", true)
		if auth then -- if authentication token was given
			local sdat = luci.sauth.read(auth)
			if sdat then -- if given token is valid
				if sdat.user and luci.util.contains(accs, sdat.user) then
					return sdat.user, auth
				end
			end
		end
		luci.http.status(403, "Forbidden")
	end
	
	local rpc = node("api")
	rpc.sysauth = "root"
	rpc.sysauth_authenticator = authenticator
	rpc.notemplate = true
	
	entry({"api", "passport"}, call("api_passport")).sysauth = false
	entry({"api", "detect"}, call("api_detect")).sysauth = false
	entry({"api", "device"}, call("api_device"))
	entry({"api", "app"}, call("api_app"))
	entry({"api", "network"}, call("api_network"))
	entry({"api", "wifi"}, call("api_wifi"))
	entry({"api", "system"}, call("api_system"))
end

function api_passport()
	local jsonrpc = require "luci.jsonrpc"
	local sauth   = require "luci.sauth"
	local http    = require "luci.http"
	local sys     = require "luci.sys"
	local ltn12   = require "luci.ltn12"
	local util    = require "luci.util"

	local loginstat

	local server = {}
	server.challenge = function(user, pass)
		local sid, token, secret

		if sys.user.checkpasswd(user, pass) then
			sid = sys.uniqueid(16)
			token = sys.uniqueid(16)
			secret = sys.uniqueid(16)

			http.header("Set-Cookie", "sysauth=" .. sid.."; path=/")
			sauth.reap()
			sauth.write(sid, {
				user=user,
				token=token,
				secret=secret
			})
		end

		return sid and {sid=sid, token=token, secret=secret}
	end

	server.login = function(...)
		local challenge = server.challenge(...)
		return challenge and challenge.sid
	end

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(server, http.source()), http.write)
end

function api_detect()
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"
	
	local server = {}
	server.status = function()
		return true
	end
	
	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(server, http.source()), http.write)
end

function api_network()
	if not pcall(require, "luci.model.yunhu.network") then
		luci.http.status(404, "Not Found")
		return nil
	end
	
	local jsonrpc = require "luci.jsonrpc"
	local network = require "luci.model.yunhu.network"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"
	
	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(network, http.source()), http.write)
end

function api_wifi()
	if not pcall(require, "luci.model.yunhu.wifi") then
		luci.http.status(404, "Not Found")
		return nil
	end
	
	local jsonrpc = require "luci.jsonrpc"
	local wifi = require "luci.model.yunhu.wifi"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"
	
	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(wifi, http.source()), http.write)
end

function api_device()
	if not pcall(require, "luci.model.yunhu.device") then
		luci.http.status(404, "Not Found")
		return nil
	end
	local device     = require "luci.model.yunhu.device"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"
	
	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(device, http.source()), http.write)
end

function api_app()
	if not pcall(require, "luci.model.yunhu.app") then
		luci.http.status(404, "Not Found")
		return nil
	end
	local app    = require "luci.model.yunhu.app"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(app, http.source()), http.write)
end

function api_system()
	local system     = require "luci.model.yunhu.system"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"
	
	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(system, http.source()), http.write)
end