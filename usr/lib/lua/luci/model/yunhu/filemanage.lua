module("luci.model.yunhu.filemanage", package.seeall)

function getExternalDiskInfo()
	local diskInfo = {
		
	}
end
function list(path)
	if path == nil then
		path = "/"
	end
	
	local fs = require "luci.fs"
	
	local file_list = {}
	for _, e in ipairs(fs.dir(path)) do
		if e == '/' then
			fullname = path .. e
		else
			fullname = path .. '/' .. e
		end
		isdir = fs.isdirectory(fullname)
		isfile = fs.isfile(fullname)
		fstat = fs.stat(fullname)
		file = { name = e, path = fullname, dir = isdir, file = isfile }
		if isfile then
			file.size = fstat.size
			file.ctime = fstat.ctime
			file.mtime = fstat.mtime
		end
		
		file_list[#file_list+1] = file
		
	end
	
	return file_list
end

function mkdir(path)
	local fs = require "luci.fs"
	fs.mkdir(path, true)
end

function rmdir(path)

	local fs = require "luci.fs"
	fs.rmdir(path)
end

function delete(file)

	return nixio.fs.remove(file)
end

function rename(src, dst)
	
	return nixio.fs.rename(src,dst)
	
end

function copy(src, dst)
	return nixio.fs.copy(src, dst)
end

function move(src, dst)
	return nixio.fs.move(src,dst)
end