module("luci.yunhu.config", package.seeall)

function load(file, name)
	local uci = require "luci.model.uci"
	local uci_real = uci.cursor()
	local sections = {}
	uci_real:foreach("network", "interface",
		function(s)
			sections[#sections+1] = s
		end
	)
	
	return sestions
end