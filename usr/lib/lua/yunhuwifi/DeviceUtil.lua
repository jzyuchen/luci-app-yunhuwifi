module("yunhuwifi.DeviceUtil", package.seeall)

local ouiFile = "/etc/oui.txt"
local CommonUtil = require("yunhuwifi.CommonUtil")
local DBUtil = require("yunhuwifi.DBUtil")

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
						ts   = ts,
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

function getCompany(mac)
	if mac:len() < 8 then
		return ""
	end
	
	local NixioFs = require("nixio.fs")
	if not NixioFs.access(ouiFile) then
		return ""
	end
	
	local file = io.open(leasefile, "r")
    if not file then
		return ""
	end
	
	for line in file:lines() do
		if line then
			local ouiMac, ouiCompany, ouiIcon = line:match("^(%S+) (%S+) ICON:(%S+)")
			
			if mac == ouiMac then
				return ouiCompany
			end
		end
	end
	
	return ""
end

function setDeviceName(mac, name)
	return DBUtil.updateDeviceNickname(mac, name)
end

function getDeviceListDict()
	local deviceList = DBUtil.getAllDeviceInfo()
	local list = {}
	for _, deviceInfo in ipairs(deviceList) do
		list[deviceInfo['mac']] = deviceInfo 
	end
	
	return list
end

function getDeviceList()
	local WifiUtil = require("yunhuwifi.WifiUtil")
	local dhcpList = getDHCPList()
	local deviceListDict = getDeviceListDict()
	local wifiList20 = WifiUtil.getWifiConnectList(1)
	local wifiList50 = WifiUtil.getWifiConnectList(2)
	
	local list = {}
	for _, item in ipairs(dhcpList) do
		local mac = CommonUtil.formatMac(item['mac'])
		local name = item['name'] or mac
		local ip = item['ip']
		local uptime = item['ts']
		
		local deviceInfo = deviceListDict[mac]

		local device = {}
		
		if deviceInfo ~= nil then
			device['mac'] = deviceInfo['mac']
			device['ip'] = ip
			device['name'] = deviceInfo['oName']
			device['nickname'] = deviceInfo['nickname']
			device['uptime'] = uptime
			device['online'] = ''
		else
			DBUtil.saveDeviceInfo(mac, item['name'], name)
			device['mac'] = mac
			device['ip'] = ip
			device['name'] = name
			device['nickname'] = name
			device['uptime'] = uptime
			device['online'] = ''
		end
		
		if CommonUtil.isStringInArray(mac, wifiList20) then
			device['type'] = 2
		elseif CommonUtil.isStringInArray(mac, wifiList50) then
			device['type'] = 3
		else
			device['type'] = 1
		end

		list[#list+1] = device
	end
	return list
end