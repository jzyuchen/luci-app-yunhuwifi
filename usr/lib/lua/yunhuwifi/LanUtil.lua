module("yunhuwifi.LanUtil", package.seeall)

local CommonUtil = require("yunhuwifi.CommonUtil")

function getLanLinkList()
    local LuciUtil = require("luci.util")
    local lanLink = {}
    local cmd = "ethstt"
    for _, line in ipairs(LuciUtil.execl(cmd)) do
        local port,link = line:match('port (%d) (%S+)')
        if link then
            if tonumber(port) == 0 then
                lanLink[1] = link == 'up' and 1 or 0
            end
            if tonumber(port) == 1 then
                lanLink[2] = link == 'up' and 1 or 0
            end
        end
    end
    return lanLink
end

function getIPv6Addrs()
    local LuciIp = require("luci.ip")
    local LuciUtil = require("luci.util")
    local cmd = "ifconfig|grep inet6"
    local ipv6List = LuciUtil.execi(cmd)
    local result = {}
    for line in ipv6List do
        line = luci.util.trim(line)
        local ipv6,mask,ipType = line:match('inet6 addr: ([^%s]+)/([^%s]+)%s+Scope:([^%s]+)')
        if ipv6 then
            ipv6 = LuciIp.IPv6(ipv6,"ffff:ffff:ffff:ffff::")
            ipv6 = ipv6:host():string()
            result[ipv6] = {}
            result[ipv6]['ip'] = ipv6
            result[ipv6]['mask'] = mask
            result[ipv6]['type'] = ipType
        end
    end
    return result
end

function getLanWanInfo(interface)
    if interface ~= "lan" and interface ~= "wan" then
        return interface
    end
    local LuciUtil = require("luci.util")
    local LuciNetwork = require("luci.model.network").init()
    local info = {}
    local ipv6Dict = getIPv6Addrs()
    local network = LuciNetwork:get_network(interface)

    if network then
        local device = network:get_interface()
        local ipAddrs = device:ipaddrs()
        local ip6Addrs = device:ip6addrs()
        if interface == "wan" then
            local mtuvalue = network:get_option_value("mtu")
            if XQFunction.isStrNil(mtuvalue) then
                mtuvalue = "1480"
            end
            local special = network:get_option_value("special")
            if XQFunction.isStrNil(special) then
                special = 0
            end
            info["mtu"] = tostring(mtuvalue)
            info["special"] = tostring(special)
            info["details"] = getWanDetails()
            -- ÊÇ·ñ²åÁËÍøÏß
            local cmd = 'ethstt'
            local data = LuciUtil.exec(cmd)
            if not CommonUtil.isNilOrEmpty(data) then
                local linkStat = string.match(data, 'port 4 ([^%s]+)')
                info["link"] = linkStat == 'up' and 1 or 0;
            end
        end
        if device and #ipAddrs > 0 then
            local ipAddress = {}
            for _,ip in ipairs(ipAddrs) do
                ipAddress[#ipAddress+1] = {}
                ipAddress[#ipAddress]["ip"] = ip:host():string()
                ipAddress[#ipAddress]["mask"] = ip:mask():string()
            end
            info["ipv4"] = ipAddress
        end
        if device and #ip6Addrs > 0 then
            local ipAddress = {}
            for _,ip in ipairs(ip6Addrs) do
                ipAddress[#ipAddress+1] = {}
                ipAddress[#ipAddress]["ip"] = ip:host():string()
                ipAddress[#ipAddress]["mask"] = ip:mask():string()
                if ipv6Dict[ip] then
                    ipAddress[#ipAddress]["type"] = ipv6Dict[ip].type
                end
        end
            info["ipv6"] = ipAddress
        end
        info["gateWay"] = network:gwaddr()
        if network:dnsaddrs() then
            info["dnsAddrs"] = network:dnsaddrs()[1] or ""
            info["dnsAddrs1"] = network:dnsaddrs()[2] or ""
        else
            info["dnsAddrs"] = ""
            info["dnsAddrs1"] = ""
        end
        if device and device:mac() ~= "00:00:00:00:00:00" then
            info["mac"] = device:mac()
        end
        if info["mac"] == nil then
            info["mac"] = getWanMac()
        end
        if network:uptime() > 0 then
            info["uptime"] = network:uptime()
        else
            info["uptime"] = 0
        end
        local status = network:status()
        if status=="down" then
            info["status"] = 0
        elseif status=="up" then
            info["status"] = 1
            if info.details and info.details.wanType == "pppoe" then
                wanMonitor = getWanMonitorStat()
                if wanMonitor.WANLINKSTAT ~= "UP" then
                    info["status"] = 0
                end
            end
        elseif status=="connection" then
            info["status"] = 2
        end
    end
    return info
end

function getLanWanIp(interface)
    if interface ~= "lan" and interface ~= "wan" then
        return false
    end
    local LuciNetwork = require("luci.model.network").init()
    local ipv4 = {}
    local network = LuciNetwork:get_network(interface)
    if network then
        local device = network:get_interface()
        local ipAddrs = device:ipaddrs()
        if device and #ipAddrs > 0 then
            for _,ip in ipairs(ipAddrs) do
                ipv4[#ipv4+1] = {}
                ipv4[#ipv4]["ip"] = ip:host():string()
                ipv4[#ipv4]["mask"] = ip:mask():string()
            end
        end
    end
    return ipv4
end

function getLanDHCPService()
    local LuciUci = require "luci.model.uci"
    local lanDhcpStatus = {}
    local uciCursor  = LuciUci.cursor()
    local ignore = uciCursor:get("dhcp", "lan", "ignore")
    local leasetime = uciCursor:get("dhcp", "lan", "leasetime")
    if ignore ~= "1" then
        ignore = "0"
    end
    local leasetimeNum,leasetimeUnit = leasetime:match("^(%d+)([^%d]+)")
    lanDhcpStatus["lanIp"] = getLanWanIp("lan")
    lanDhcpStatus["start"] = uciCursor:get("dhcp", "lan", "start")
    lanDhcpStatus["limit"] = uciCursor:get("dhcp", "lan", "limit")
    lanDhcpStatus["leasetime"] = leasetime
    lanDhcpStatus["leasetimeNum"] = leasetimeNum
    lanDhcpStatus["leasetimeUnit"] = leasetimeUnit
    lanDhcpStatus["ignore"] = ignore
    return lanDhcpStatus
end

function setLanDHCPService(startReq,endReq,leasetime,ignore)
    local LuciUci = require("luci.model.uci")
    local LuciUtil = require("luci.util")
    local uciCursor  = LuciUci.cursor()
    if ignore == "1" then
        uciCursor:set("dhcp", "lan", "ignore", tonumber(ignore))
    else
        local limit = tonumber(endReq) - tonumber(startReq) + 1
        if limit < 0 then
            return false
        end
        uciCursor:set("dhcp", "lan", "start", tonumber(startReq))
        uciCursor:set("dhcp", "lan", "limit", tonumber(limit))
        uciCursor:set("dhcp", "lan", "leasetime", leasetime)
        uciCursor:delete("dhcp", "lan", "ignore")
    end
    uciCursor:save("dhcp")
    uciCursor:load("dhcp")
    uciCursor:commit("dhcp")
    uciCursor:load("dhcp")
    LuciUtil.exec("/etc/init.d/dnsmasq restart > /dev/null")
    return true
end