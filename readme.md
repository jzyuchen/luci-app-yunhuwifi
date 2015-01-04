luci.controller.api.system		-- 实现系统基本功能
	detectrouter			-- 检测路由器
	routerinfo			-- 获取路由器基本信息
	checkupgrade			-- 检测是否有可更新的固件
	chpwd				-- 修改管理密码
	reboot				-- 重启路由器
	reset				-- 恢复出厂设置
	
luci.controller.api.device		-- 实现设备管理
	list				-- 获取当前连接的设备列表
	setname				-- 备注设备名称
	blacklist			-- 获取设备黑名单列表
	moveblacklist			-- 将指定的设备添加到黑名单
	removeblacklist			-- 将设备从黑名单中移除
	
luci.controller.api.file		-- 实现文件管理
	list				-- 获取文件列表
	copy				-- 复制文件
	move				-- 移动文件
	rename				-- 文件改名
	upload				-- 上传文件
	download			-- 下载文件
	
luci.controller.api.network		-- 实现网络管理
	lan_info			-- 获取或设置Lan口信息
	wan_info			-- 获取或设置Wan口信息
	is_internet_available	-- 当前是否可以连通互联网
	
luci.controller.api.wireless	-- 实现无线管理
	list				-- 获取所有无线SSID
	enable_wireless			-- 开启或关闭无线
	wireless_info			-- 获取或设置无线信息