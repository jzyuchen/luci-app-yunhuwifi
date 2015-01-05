module("luci.model.yunhu.network", package.seeall)

function get_interfaces()
	local netm = require "luci.model.network".init()
	
	local list = {}
	for _, device in ipairs(netm:get_interfaces()) do
		list[#list+1] = {
			name = device:name(),
			macaddr = device:mac()
		}
	end
	return list
end

function get_lan()
	local uci = require("luci.model.uci").cursor()
	
	local lan = {}
	uci:foreach("dhcp", "dhcp", function(s)
		if (s[".name"] == "lan") then
			lan.enable = (s.ignore == nil)
			lan.start = s.start
			lan.limit = s.limit
			return
		end
	end)
	
	uci:foreach("network", "interface", function(s)
		if (s[".name"] == "lan") then
			lan.proto = s.proto
			lan.ipaddr = s.ipaddr
			lan.netmask = s.netmask
			if s.dns ~= nil then
				lan.dns = luci.util.split(s.dns, " ")
			end
			return
		end
	end)
	
	return lan
end

function set_dhcp(self, enable, start, limit)
	local uci = require("luci.model.uci").cursor()
	
	uci:foreach("dhcp", "dhcp", function(s)
		if (s[".name"] == "lan") then
			uci.set("dhcp", "lan", "start", start)
			uci.set("dhcp", "lan", "limit", limit)
			if (enable) then
				uci.delete("dhcp", "lan", "ignore")
			else
				uci.set("dhcp", "lan", "ignore", "1")
			end
			uci.commit("dhcp")
		end
	end)
	
	return true
end

function set_lan(self, ipaddr, netmask, dns)
	local uci = require("luci.model.uci").cursor()
	local dnslist = ""

	uci:foreach("network", "interface",
		function(s)
			if s[".name"] == "lan" then
				uci:set("network", "lan", "proto", "static")
				uci:set("network", "lan", "ipaddr", ipaddr)
				uci:set("network", "lan", "netmask", netmask)
				for _,e in ipairs(dns) do
					if string.len(e) > 0 then
						if string.len(dnslist) > 0 then
							dnslist = dnslist .. " "
						end
						dnslist = dnslist .. e
					end
					
					if string.len(dnslist) > 0 then
						uci:set("network", "lan", "dns", dnslist)
					else
						uci:delete("network", "lan", "dns")
					end
				end
			end
		end
	)
	
	uci:commit("network")
	
	return true
end

function get_wan()
	local uci = require("luci.model.uci").cursor()
	local wan
	uci:foreach("network", "interface", function(s)
		if (s[".name"] == "wan") then
			wan = s
			return
		end
	end)
	return wan
end

function set_wan_pppoe(self, username, password)
	local uci = require("luci.model.uci").cursor()
	
	uci:foreach("network", "interface", function(s)
		if (s[".name"] == "wan") then
			uci:set("network", "wan", "proto", "pppoe")
			uci:set("network", "wan", "username", username)
			uci:set("network", "wan", "password", password)
		end
	end)
	uci:commit("network")
end

function set_wan_dhcp(self)
	local uci = require("luci.model.uci").cursor()
	
	uci:foreach("network", "interface", function(s)
		if (s[".name"] == "wan") then
			uci:set("network", "wan", "proto", "dhcp")
		end
	end)
	uci:commit("network")
end

function set_wan_static(self, ipaddr, netmask, gwaddr, dns)
	local dnslist = ""
	uci:foreach("network", "interface", function(s)
		if (s[".name"] == "wan") then
			uci:set("network", "wan", "proto", "static")
			uci:set("network", "wan", "ipaddr", ipaddr)
			uci:set("network", "wan", "netmask", netmask)
			uci:set("network", "wan", "gwaddr", gwaddr)
			for _, e in ipairs(dns) do
				if string.len(dnslist) > 0 then
					dnslist = dnslist .. " "
				end
				dnslist = dnslist .. e
			end
			local dnslist = ""
			for _, e in ipairs(dns) do
				if string.len(dnslist) > 0 then
					dnslist = dnslist .. " "
				end
				dnslist = dnslist .. e
			end
		end
	end)
	uci:commit("network")
end

function speed_status()
	local iface = "br-lan"

	local bwc = io.popen("luci-bwc -i %q 2>/dev/null" % iface)
	local list = {}
	if bwc then
		while true do
			local ln = bwc:read("*l")
			if not ln then break end
			
			list[#list+1] = string.sub(ln, 3, -4)
		end
		bwc:close()
	end
	
	local result = {
		rxs = 0,
		txs = 0
	}
	
	if #list > 1 then
		local i = luci.util.split(list[#list], ",")
		local k = luci.util.split(list[#list-1], ",")
		
		local time_delta = luci.util.trim(i[1]) - luci.util.trim(k[1])
		result.rxs = (luci.util.trim(i[2]) - luci.util.trim(k[2])) / time_delta
		result.txs = (luci.util.trim(i[4]) - luci.util.trim(k[4])) / time_delta
	end
	
	return result;
end
