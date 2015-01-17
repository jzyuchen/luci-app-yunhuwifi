module("yunhuwifi.WifiUtil", package.seeall)

local LuciNetwork = require("luci.model.network")
local LuciUtil = require("luci.util")
local CommonUtil = require("yunhuwifi.CommonUtil")

local UCI = require("luci.model.uci").cursor()

local wifi24 = {
    ["1"] = {["20"] = "1", ["40"] = "1l"},
    ["2"] = {["20"] = "2", ["40"] = "2l"},
    ["3"] = {["20"] = "3", ["40"] = "3l"},
    ["4"] = {["20"] = "4", ["40"] = "4l"},
    ["5"] = {["20"] = "5", ["40"] = "5l"},
    ["6"] = {["20"] = "6", ["40"] = "6l"},
    ["7"] = {["20"] = "7", ["40"] = "7l"},
    ["8"] = {["20"] = "8", ["40"] = "8u"},
    ["9"] = {["20"] = "9", ["40"] = "9u"},
    ["10"] = {["20"] = "10", ["40"] = "10u"},
    ["11"] = {["20"] = "11", ["40"] = "11u"},
    ["12"] = {["20"] = "12", ["40"] = "12u"},
    ["13"] = {["20"] = "13", ["40"] = "13u"}
}

local wifi50 = {
    ["36"] = {["20"] = "36", ["40"] = "36l", ["80"] = "36/80"},
    ["40"] = {["20"] = "40", ["40"] = "40u", ["80"] = "40/80"},
    ["44"] = {["20"] = "44", ["40"] = "44l", ["80"] = "44/80"},
    ["48"] = {["20"] = "48", ["40"] = "48u", ["80"] = "48/80"},
    ["52"] = {["20"] = "52", ["40"] = "52l", ["80"] = "52/80"},
    ["56"] = {["20"] = "56", ["40"] = "56u", ["80"] = "56/80"},
    ["60"] = {["20"] = "60", ["40"] = "60l", ["80"] = "60/80"},
    ["64"] = {["20"] = "64", ["40"] = "64u", ["80"] = "64/80"},
    ["149"] = {["20"] = "149", ["40"] = "149l", ["80"] = "149/80"},
    ["153"] = {["20"] = "153", ["40"] = "153u", ["80"] = "153/80"},
    ["157"] = {["20"] = "157", ["40"] = "157l", ["80"] = "157/80"},
    ["161"] = {["20"] = "161", ["40"] = "161u", ["80"] = "161/80"},
    ["165"] = {["20"] = "165"}
}

local CHANNELS = {
    ["CN"] = {
        "0 1 2 3 4 5 6 7 8 9 10 11 12 13",
        "0 36 40 44 48 52 56 60 64 149 153 157 161 165"
    },
    ["TW"] = {
        "0 1 2 3 4 5 6 7 8 9 10 11",
        "0 52 56 60 64 149 153 157 161"
    },
    ["HK"] = {
        "0 1 2 3 4 5 6 7 8 9 10 11 12 13",
        "0 36 40 44 48 52 56 60 64 149 153 157 161 165"
    },
    ["US"] = {
        "0 1 2 3 4 5 6 7 8 9 10 11 ",
        "0 36 40 44 48 52 56 60 64 149 153 157 161 165"
    }
}

local BANDWIDTH = {
    {"20"},
    {"20", "40"},
    {"20", "40", "80"}
}

local WIFI_DEVS = {
    'mt7620',
    'mt7612'
}

local WIFI_NETS = {
    "mt7620.network1",
    "mt7612.network1"
}

function _wifiNameForIndex(index)
    return WIFI_NETS[index]
end

function getBandList(channel)
    local channelInfo = {channel = "", bandwidth = ""}
    if channel == nil then
        return channelInfo
    end
    local bandList = {}
    local channelList = wifi24[tostring(channel)] or wifi50[tostring(channel)]
    if channelList and type(channelList) == "table" then
        for key, v in pairs(channelList) do
            table.insert(bandList, key)
        end
    end
    channelInfo["bandList"] = bandList
    return channelInfo
end

function wifiNetworks()
    local result = {}
    local network = LuciNetwork.init()
    local dev
    for _, dev in ipairs(network:get_wifidevs()) do
        local rd = {
            up       = dev:is_up(),
            device   = dev:name(),
            name     = dev:get_i18n(),
            networks = {}
        }
        local wifiNet
        for _, wifiNet in ipairs(dev:get_wifinets()) do
            rd.networks[#rd.networks+1] = {
                name       = wifiNet:shortname(),
                up         = wifiNet:is_up(),
                mode       = wifiNet:active_mode(),
                ssid       = wifiNet:active_ssid(),
                bssid      = wifiNet:active_bssid(),
                encryption = wifiNet:active_encryption(),
                frequency  = wifiNet:frequency(),
                channel    = wifiNet:channel(),
                cchannel   = wifiNet:confchannel(),
                bw         = wifiNet:bw(),
                cbw        = wifiNet:confbw(),
                signal     = wifiNet:signal(),
                quality    = wifiNet:signal_percent(),
                noise      = wifiNet:noise(),
                bitrate    = wifiNet:bitrate(),
                ifname     = wifiNet:ifname(),
                assoclist  = wifiNet:assoclist(),
                country    = wifiNet:country(),
                txpower    = wifiNet:txpower(),
                txpoweroff = wifiNet:txpower_offset(),
                key	   	   = wifiNet:get("key"),
                key1	   = wifiNet:get("key1"),
                encryption_src = wifiNet:get("encryption"),
                hidden = wifiNet:get("hidden")
            }
        end
        result[#result+1] = rd
    end
    return result
end

function getAllWifiInfo()
    local infoList = {}
    local wifis = wifiNetworks()
    for i,wifiNet in ipairs(wifis) do
        local item = {}
        local index = 1
        if wifiNet["up"] then
            item["status"] = "1"
        else
            item["status"] = "0"
        end
        local encryption = wifiNet.networks[index].encryption_src
        local key = wifiNet.networks[index].key
        if encryption == "wep-open" then
            key = wifiNet.networks[index].key1
            if key:len()>4 and key:sub(0,2)=="s:" then
                key = key:sub(3)
            end
        end
        local channel = wifiNet.networks[index].cchannel
        item["ifname"] = wifiNet.networks[index].ifname
        item["device"] = wifiNet.device..".network"..index
        item["ssid"] = wifiNet.networks[index].ssid
        item["channel"] = channel
        item["bandwidth"] = wifiNet.networks[index].cbw
        item["channelInfo"] = getBandList(channel)
        item["channelInfo"]["channel"] = wifiNet.networks[index].channel
        item["channelInfo"]["bandwidth"] = wifiNet.networks[index].bw
        item["mode"] = wifiNet.networks[index].mode
        item["hidden"] = wifiNet.networks[index].hidden or 0
        item["signal"] = wifiNet.networks[index].signal
        item["password"] = key
        item["encryption"] = encryption
        infoList[#wifis+1-i] = item
    end
    return infoList
end

function checkWifiPasswd(passwd,encryption)
    if encryption ~= nil or (encryption and encryption ~= "none" and passwd ~= nil and passwd ~= "") then
        return 1502
    end
    if encryption == "psk" or encryption == "psk2" then
        if  passwd:len() < 8 then
            return 1520
        end
    elseif encryption == "mixed-psk" then
        if  passwd:len()<8 or passwd:len()>63 then
            return 1521
        end
    elseif encryption == "wep-open" then
        if  passwd:len()~=5 and passwd:len()~=13 then
            return 1522
        end
    end
    return 0
end

function setWifiBasicInfo(wifiIndex, ssid, password, encryption, channel, txpwr, hidden, on, bandwidth)
    local network = LuciNetwork.init()
    local wifiNet = network:get_wifinet(_wifiNameForIndex(wifiIndex))
    local wifiDev = network:get_wifidev(LuciUtil.split(_wifiNameForIndex(wifiIndex),".")[1])
    if wifiNet == nil then
        return false
    end
    if wifiDev then
        if channel ~= nil and chanel ~= "" then
            wifiDev:set("channel",channel)
            if channel == "0" then
                wifiDev:set("autoch","2")
            else
                wifiDev:set("autoch","0")
            end
        end
        if bandwidth ~= nil and bandwidth ~= "" then
            wifiDev:set("bw",bandwidth)
        end
        if txpwr ~= nil and txpwr ~= "" then
            wifiDev:set("txpwr",txpwr);
        end
        if on == 1 then
            wifiDev:set("disabled", "0")
        elseif on == 0 then
            wifiDev:set("disabled", "1")
        end
    end
    wifiNet:set("disabled", nil)
    if ssid ~= nil and ssid ~= "" then
        wifiNet:set("ssid",ssid)
    end
    local code = checkWifiPasswd(password,encryption)
    if code == 0 then
        wifiNet:set("encryption",encryption)
        wifiNet:set("key",password)
        if encryption == "none" then
            wifiNet:set("key","")
        elseif encryption == "wep-open" then
            wifiNet:set("key1","s:"..password)
            wifiNet:set("key",1)
        end
    elseif code > 1502 then
        return false
    end
    if hidden == "1" then
        wifiNet:set("hidden","1")
    end
    if hidden == "0" then
        wifiNet:set("hidden","0")
    end
    network:save("wireless")
    network:commit("wireless")
    return true
end

function setWifiRegion(country)
	if CommonUtil.isNilOrEmpty(country) then
        return false
    end
	for _, k in ipairs(CommonUtil.COUNTRY_CODE) do
		if (k.c == country and k.p == true) then
			local network = LuciNetwork.init()
			local wifiDev1 = network:get_wifidev(LuciUtil.split(_wifiNameForIndex(1),".")[1])
			local wifiDev2 = network:get_wifidev(LuciUtil.split(_wifiNameForIndex(2),".")[1])
			if wifiDev1 then
				wifiDev1:set("country", k.c)
				wifiDev1:set("region", CommonUtil.REGION[k.c].region)
				wifiDev1:set("aregion", CommonUtil.REGION[k.c].regionABand)
			end
			if wifiDev2 then
				wifiDev2:set("country", k[c])
				wifiDev2:set("region", CommonUtil.REGION[k.c].region)
				wifiDev2:set("aregion", CommonUtil.REGION[k.c].regionABand)
			end
			network:commit("wireless")
			network:save("wireless")
			return true
		end
	end
    return false
end

function getWifiRegion()
	local network = LuciNetwork.init()
    local wifiDev1 = network:get_wifidev(LuciUtil.split(_wifiNameForIndex(1),".")[1])
    local wifiDev2 = network:get_wifidev(LuciUtil.split(_wifiNameForIndex(2),".")[1])
	
	local list = {}
	if (wifiDev1)
		list[#list+1] = {
			['country'] = wifiDev1:get("country"),
			['region'] = wifiDev1:get("region"),
			["aregion"] = wifiDev1:get("aregion")
		}
	end
	
	if (wifiDev2)
		list[#list+1] = {
			['country'] = wifiDev1:get("country"),
			['region'] = wifiDev1:get("region"),
			["aregion"] = wifiDev1:get("aregion")
		}
	end
	
	return list
end