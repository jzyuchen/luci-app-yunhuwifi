module("luci.controller.api.device", package.seeall)

function index()
    local page   = node("api","device")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 500
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "device"}, firstchild(), _(""), 500)
    entry({"api", "device", "request"}, call("tunnelSmartHomeRequest"), _(""), 501)
    entry({"api", "device", "request_smartcontroller"}, call("tunnelSmartControllerRequest"), _(""), 502)
    entry({"api", "device", "request_miio"}, call("tunnelMiioRequest"), _(""), 503)
    entry({"api", "device", "request_mitv"}, call("requestMitv"), _(""), 504)
    entry({"api", "device", "request_yeelink"}, call("tunnelYeelink"), _(""), 505)
    entry({"api", "device", "request_camera"}, call("requestCamera"), _(""), 506)
end

local LuciHttp = require("luci.http")

function getDeviceList()
end