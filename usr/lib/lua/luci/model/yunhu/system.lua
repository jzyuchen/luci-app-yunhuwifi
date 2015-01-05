module("luci.model.yunhu.system", package.seeall)

-- 获取路由器信息
function info()
	local network = require "luci.model.yunhu.network"
	local routerInfo = {}
	
	routerInfo.hostname = luci.sys.hostname()
	routerInfo.firmwareVersion = luci.version.distversion
	routerInfo.hardwareVersion = luci.sys.sysinfo()
	routerInfo.interfaces = network:get_interfaces()
	
	return routerInfo
end

-- 获取路由器状态
function status()
	local ntm = require "luci.model.network".init()
	local sys = require "luci.sys"
	local version = require "luci.version"
	local dr4 = luci.sys.net.defaultroute()
	local lan, wan
	
	if dr4 and dr4.device then
		wan = ntm:get_interface(dr4.device)
		wan = wan and wan:get_network()
	end

	lan = luci.model.network:get_interface("lan")
	
	local result = {}
	
	result.device = require "luci.sys".sysinfo()
	result.osversion = version.distversion
	
	if lan then
		result.lanipaddr = lan.ipaddr
		result.macaddr = lan:mac()
	end
	
	if wan then
		result.wanipaddr = wan:ipaddr()
	end
	
	return result
end

function reboot()
	luci.sys:reboot()
end

function uptime()
	return luci.sys.uptime()
end