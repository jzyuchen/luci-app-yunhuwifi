module("yunhuwifi.CommonUtil", package.seeall)

COUNTRY_CODE = {
    {["c"] = "CN", ["n"] = _("中国"), ["p"] = true},
    {["c"] = "HK", ["n"] = _("中国香港"), ["p"] = true},
    {["c"] = "TW", ["n"] = _("中国台湾"), ["p"] = true},
    {["c"] = "US", ["n"] = _("美国"), ["p"] = true},
    {["c"] = "SG", ["n"] = _("新加坡"), ["p"] = false},
    {["c"] = "MY", ["n"] = _("马来西亚"), ["p"] = false},
    {["c"] = "IN", ["n"] = _("印度"), ["p"] = false},
    {["c"] = "CA", ["n"] = _("加拿大"), ["p"] = false},
    {["c"] = "FR", ["n"] = _("法国"), ["p"] = false},
    {["c"] = "DE", ["n"] = _("德国"), ["p"] = false},
    {["c"] = "IT", ["n"] = _("意大利"), ["p"] = false},
    {["c"] = "ES", ["n"] = _("西班牙"), ["p"] = false},
    {["c"] = "PH", ["n"] = _("菲律宾"), ["p"] = false},
    {["c"] = "ID", ["n"] = _("印度尼西亚"), ["p"] = false},
    {["c"] = "TH", ["n"] = _("泰国"), ["p"] = false},
    {["c"] = "VN", ["n"] = _("越南"), ["p"] = false},
    {["c"] = "BR", ["n"] = _("巴西"), ["p"] = false},
    {["c"] = "RU", ["n"] = _("俄罗斯"), ["p"] = false},
    {["c"] = "MX", ["n"] = _("墨西哥"), ["p"] = false},
    {["c"] = "TR", ["n"] = _("土耳其"), ["p"] = false}
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

function isNilOrEmpty(str)
	if (str ~= nil and str ~= "") then
		return true;
	end
	return false;
end