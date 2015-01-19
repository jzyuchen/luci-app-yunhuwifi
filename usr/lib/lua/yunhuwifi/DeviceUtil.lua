module("yunhuwifi.DeviceUtil", package.seeall)

local ouiFile = "/etc/oui.txt"
local CommonUtil = require("yunhuwifi.CommonUtil")

local UCI = require("luci.model.uci").cursor()

function getDHCPList()
    local NixioFs = require("nixio.fs")
    local LuciUci = require("luci.model.uci")
    local uci =  LuciUci.cursor()
    local result = {}
    local leasefile = "/temp/dhcp.leases"
    uci:foreach("dhcp", "dnsmasq",
    function(s)
        if s.leasefile and NixioFs.access(s.leasefile) then
            leasefile = s.leasefile
            return false
        end
    end)
    local dhcp = io.open(leasefile, "r")
    if dhcp then
        for line in dhcp:lines() do
            if line then
                local ts, mac, ip, name = line:match("^(%d+) (%S+) (%S+) (%S+)")
                if name == "*" then
                    name = ""
                end
                if ts and mac and ip and name then
                    result[#result+1] = {
                        mac  = mac,
                        ip   = ip,
                        name = name
                    }
                end
            end
        end
        dhcp:close()
        return result
    else
        return {}
    end
end

function getDeviceList()
	local dhcpList = getDHCPList()
	local list = {}
	for _, item in ipairs(dhcpList) do
		local deviceInfo = {
			['mac'] = CommonUtil.formatMac(item['mac']),
			['ip'] = item['ip'],
			['name'] = "",
			['type'] = "",
			['icon'] = "unknown",
			['factory'] = '',
			['uptime'] = '',
			['online'] = ''
		}
		list[#list+1] = deviceInfo
	end
	return list
end

function getDeviceInfo(mac)
	local deviceInfo = {
		ip = "ip",
		mac = "mac",
		type = "line|wifi",
		icon = "xiaomi.png",
		factory = "xiaomi inc",
		tx = "128kb",
		rx = "128kb",
		uptime = "123123",
		online = true
	}
	
	return deviceInfo
end

function getDeviceIcon(mac)
	local resultIcon = "unknow"
	local NixioFs = require("nixio.fs")
	if not NixioFs.access(ouiFile) then
		return resultIcon
	end
	
	local oui = io.open(ouiFile, "r")
    if oui then
        for line in dhcp:lines() do
            if line then
                local macPrefix, icon, factory = line:match("^(%S+) (%S+) (%S+)")

                if macPrefix and icon and factory then
                    if (mac:len() > 8 and string.sub(0, 8) == macPrefix) then
						resultIcon = icon
						break
					end
                end
            end
        end
        dhcp:close()
    end
	
	return resultIcon
end