module("luci.model.yunhu.wifi", package.seeall)

function list()
	local wifi_list = {}
	local network = require("luci.model.network").init()
	for _,dev in ipairs(network:get_wifidevs()) do
		for i, net in ipairs(dev:get_wifinets()) do
			wifi_list[#wifi_list+1] = net
		end
	end
	return wifi_list
end

function wifi_details(self, iface)
	local details
	local network = require("luci.model.network").init()
	for _,dev in ipairs(network:get_wifidevs()) do
		for i, net in ipairs(dev:get_wifinets()) do
			if net.netid == iface then
				details = net
				break
			end
		end
	end
	return details
end

function set_wifi(self, iface, ssid, enable, hidden, encryption, key)
	local network = require("luci.model.network").init()

	for _,dev in ipairs(network:get_wifidevs()) do
		for i, net in ipairs(dev:get_wifinets()) do
			if (net.netid == iface) then
				if enable then
					net:set("disable", nil)
				else
					net:set("disable", "1")
				end
				if hidden then
					net:set("hidden", "1")
				else
					net:set("hidden", nil)
				end
				
				net:set("ssid", ssid)
				net:set("encryption", encryption)
				net:set("key", key)
				network:commit("wireless")
				if (net:get("disable") == nil) then
					luci.sys.call("(env -i /sbin/wifi down; env -i /sbin/wifi up) >/dev/null 2>/dev/null")
				else
					luci.sys.call("(env -i /sbin/wifi down) >/dev/null 2>/dev/null")
				end
			end
		end
	end
end