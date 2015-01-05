module("luci.model.yunhu.cloud", package.seeall)

-- 绑定路由器
function bind(name, username, password)
	local url = "http://cloud.yunhuwifi.com/api/router/bind"
end