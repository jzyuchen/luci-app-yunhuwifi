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
end