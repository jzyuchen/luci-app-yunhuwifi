module("luci.model.yunhu.device", package.seeall)

function getDeviceCount()
	local status = require "luci.tools.status"
	local dhcpList = status:dhcp_leases()
	
	return #dhcpList
end

function getDeviceList()
end

function getDeviceIcon(mac)
end

function setDeviceName(mac, name)
end

function getDeviceName(mac)
end

function list()
	local tools = require "luci.tools.status"
	local wifilist = wifi_client_list()
	local dhcplist = luci.tools.status.dhcp_leases()
	local remarklist = remark_list()
	local clientlist = { }
	for _, e in ipairs(luci.sys.net.arptable()) do
		local conntype = "cable"
		for k, v in ipairs(wifilist) do
			if e["HW address"]:upper() == v:upper() then
				conntype = "wireless"
				break
			end
		end
		local hostname = ""
		for _, item in ipairs(dhcplist) do
			if item.macaddr:upper() == e["HW address"]:upper() then
				if item.hostname ~= false then
					hostname = item.hostname
				end
				break
			end
		end
		local remarkname = ""
		for _, item in ipairs(remarklist) do
			if item.macaddr:upper() == e["HW address"]:upper() then
				remarkname = item.name
				break
			end
		end
		
		local item = {
			hostname = hostname,
			brand = e["HW address"],
			remark = remarkname,
			ipaddr = e["IP address"],
			macaddr = e["HW address"]:upper(),
			conntype = conntype,
			isonline = (e["Flags"]=="0x2")
		}
		clientlist[#clientlist+1] = item
	end
	
	return clientlist
end

function wifi_client_list()
	local ntm = require "luci.model.network".init()
	local clientlist = {}
	for _, dev in ipairs(ntm:get_wifidevs()) do
		for _, net in ipairs(dev:get_wifinets()) do	
			for mac, assoc in pairs(net:assoclist()) do
				clientlist[#clientlist+1] = mac
			end
		end
	end
	return clientlist
end

local remark_file = "/etc/device_name"

function remark_list()
	local list = {}
	local fd = io.open(remark_file, "r")
	if fd then
		while true do
			local content = fd:read("*l")
			if content == nil then
				break
			end
			list[#list+1] = { macaddr = string.sub(content, 1, 17), name = string.sub(content, 18) }
		end
		fd:close()
	end
	
	return list
end

function remark(mac,name)
	local list = {}
	local fd = io.open(remark_file, "r")
	if fd then
		while true do
			local content = fd:read("*l")
			if content == nil then
				break
			end
			if string.sub(content, 1, 17) ~= mac then
				list[#list+1] = content
			end
		end
		fd:close()
	end
	
	local writeHandler = io.open(remark_file, "w")
	for _,e in ipairs(list) do
		writeHandler:write(e.."\n")
	end
	writeHandler:write(mac..name.."\n")
	writeHandler:close()
end

-- 获取所有连接的客户端的上下行速度
function speed()
	-- 获取arp列表
	local arplist = luci.sys.net.arptable()
	for _,e in ipairs(arplist) do
		
	end
	local content = luci.util.exec("/etc/flow 2>/dev/null")
	local list = luci.tools.util.split(list, "=====")
	local upload = list[1]
	local download = list[2]
	local uploadList = luci.tools.util.split(upload, "\n")
	local downloadList = luci.tools.util.split(upload, "\n")
	local result = {}
	for _,e in ipairs(uploadList) do
		local item = { ipaddr = "", rxs = "", txs = "" }
		result[#result+1] = item
	end
	return result
end

function disconnect(mac)
	
end

function utfstrlen(str)
	local len = #str
	local left = len
	local cnt = 0
	local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
	while left ~= 0 do
		local tmp=string.byte(str,-left)
		local i=#arr
		while arr[i] do
			if tmp>=arr[i] then left=left-i break end
				i=i-1
		end
		cnt=cnt+1
	end
	return cnt
end