module("yunhuwifi.CommonUtil", package.seeall)

COUNTRY_CODE = {
    {["c"] = "CN", ["n"] = "中国", ["p"] = true},
    {["c"] = "HK", ["n"] = "中国香港", ["p"] = true},
    {["c"] = "TW", ["n"] = "中国台湾", ["p"] = true},
    {["c"] = "US", ["n"] = "美国", ["p"] = true},
    {["c"] = "SG", ["n"] = "新加坡", ["p"] = false},
    {["c"] = "MY", ["n"] = "马来西亚", ["p"] = false},
    {["c"] = "IN", ["n"] = "印度", ["p"] = false},
    {["c"] = "CA", ["n"] = "加拿大", ["p"] = false},
    {["c"] = "FR", ["n"] = "法国", ["p"] = false},
    {["c"] = "DE", ["n"] = "德国", ["p"] = false},
    {["c"] = "IT", ["n"] = "意大利", ["p"] = false},
    {["c"] = "ES", ["n"] = "西班牙", ["p"] = false},
    {["c"] = "PH", ["n"] = "菲律宾", ["p"] = false},
    {["c"] = "ID", ["n"] = "印度尼西亚", ["p"] = false},
    {["c"] = "TH", ["n"] = "泰国", ["p"] = false},
    {["c"] = "VN", ["n"] = "越南", ["p"] = false},
    {["c"] = "BR", ["n"] = "巴西", ["p"] = false},
    {["c"] = "RU", ["n"] = "俄罗斯", ["p"] = false},
    {["c"] = "MX", ["n"] = "墨西哥", ["p"] = false},
    {["c"] = "TR", ["n"] = "土耳其", ["p"] = false}
}

REGION = {
    ["CN"] = {["region"] = 1, ["regionABand"] = 0},
    ["TW"] = {["region"] = 0, ["regionABand"] = 3},
    ["HK"] = {["region"] = 1, ["regionABand"] = 0},
    ["US"] = {["region"] = 0, ["regionABand"] = 0}
}

LANGUAGE = {
    ["CN"] = "zh_cn",
    ["TW"] = "zh_tw",
    ["HK"] = "zh_hk",
    ["US"] = "en"
}

ERROR_Message = {
	['0'] = "",
	['1000'] = "", -- 
	['9999'] = ""
}

function isNilOrEmpty(str)
	return (str == nil or str == "")
end

function formatMac(mac)
	return mac:upper()
end