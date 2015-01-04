module("luci.controller.api.file", package.seeall)

function index()
    local page   = node("api","file")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    entry({"api", "file"}, firstchild(), _(""), 300)
    entry({"api", "file", "check_file_exists"}, call("checkFileExists"), _(""), 301)
	entry({"api", "file", "upload"}, call("upload"), _(""), 302)
	entry({"api", "file", "download"}, call("download"), _(""), 303)
end

local LuciHttp = require("luci.http")
local LuciFs = require("luci.fs")
local NixioFs = require("nixio.fs")

function copy()
	local source = LuciHttp.formvalue("source")
	local target = LuciHttp.formvalue("target")
	
	local sourceStat = NixioFs.stat(source)
	if sourceStat == nil then
		LuciHttp.status(404, _("no Such file"))
        return
	end
	
	NixioFs.copy(source, target)
	result['code'] = 0
	LuciHttp.write_json(result)
end

function move()
	local source = LuciHttp.formvalue("source")
	local target = LuciHttp.formvalue("target")
	
	local sourceStat = NixioFs.stat(source)
	if sourceStat == nil then
		LuciHttp.status(404, _("no Such file"))
        return
	end
	
	NixioFs.move(source, target)
	result['code'] = 0
	LuciHttp.write_json(result)
end

function rename()
	local source = LuciHttp.formvalue("source")
	local target = LuciHttp.formvalue("target")
	
	local sourceStat = NixioFs.stat(source)
	if sourceStat == nil then
		LuciHttp.status(404, _("no Such file"))
        return
	end
	
	local targetStat = NixioFs.stat(target)
	if sourceStat then
		LuciHttp.status(404, _("file exists"))
        return
	end
	
	NixioFs.rename(source, target)
	result['code'] = 0
	LuciHttp.write_json(result)
end

function checkFileExists()
	local exists = false
	local path = LuciHttp.formvalue("filePath")
	local state = NixioFs.stat(path)
	if state then
		exists = true;
	end
	local result = {}
	result['code'] = 0
	result['exists'] = exists
	LuciHttp.write_json(result)
end

function download()
    local fs = require("nixio.fs")
    local mime = require("luci.http.protocol.mime")
    local ltn12 = require("luci.ltn12")
    
    local path = LuciHttp.formvalue("path")
    if XQFunction.isStrNil(path) then
        LuciHttp.status(404, _("no Such file"))
        return
    end

    local constPrefix1 = "/userdisk/data/"
    local constPrefix2 = "/extdisks/"
    local constPrefix3 = "/userdisk/privacyData/"
    if (string.sub(path, 1, string.len(constPrefix1)) ~= constPrefix1) and (string.sub(path, 1, string.len(constPrefix2)) ~= constPrefix2) and (string.sub(path, 1, string.len(constPrefix3)) ~= constPrefix3) then
        LuciHttp.status(403, _("no permission"))
        return
    end

    local stat = fs.stat(path)
    if not stat then
        LuciHttp.status(404, _("no Such file"))
        return
    end

    LuciHttp.header("Accept-Ranges", "bytes")
    LuciHttp.header("Content-Type", mime.to_mime(path))
    local range = LuciHttp.getenv("HTTP_RANGE")
    -- format: bytes=123-
    if range then
        LuciHttp.status(206)
        range = string.gsub(range, "bytes=", "")
        range = string.gsub(range, "-", "")
    else
        range = 0
    end

    -- format: bytes 123-456/457
    local contentRange = "bytes " .. range .. "-" .. (stat.size - 1) .. "/" .. stat.size
    LuciHttp.header("Content-Length", stat.size - range)
    LuciHttp.header("Content-Range", contentRange)
    LuciHttp.header("Content-Disposition", "attachment; filename=" .. fs.basename(path))

    if string.sub(path, 1, string.len(constPrefix1)) == constPrefix1 then
        LuciHttp.header("X-Accel-Redirect", "/download-userdisk/" .. string.sub(path, string.len(constPrefix1) + 1, string.len(path)))
    elseif string.sub(path, 1, string.len(constPrefix2)) == constPrefix2 then
        LuciHttp.header("X-Accel-Redirect", "/download-extdisks/" .. string.sub(path, string.len(constPrefix2) + 1, string.len(path)))
    elseif string.sub(path, 1, string.len(constPrefix3)) == constPrefix3 then
        LuciHttp.header("X-Accel-Redirect", "/download-pridisk/" .. string.sub(path, string.len(constPrefix3) + 1, string.len(path)))
    end

    --local file = io.open(path, "r")
    --local position = file:seek("set", range)
    --log.log(3, "=============position = " .. position)
    --ltn12.pump.all(ltn12.source.file(file), LuciHttp.write)
end

function upload()
    local fp
    local fs = require("luci.fs")
    local tmpfile = "/tmp/upload.tmp"
    if fs.isfile(tmpfile) then
        fs.unlink(tmpfile)
    end
    local filename
    LuciHttp.setfilehandler(
        function(meta, chunk, eof)
            if not fp then
                if meta and meta.name == "file" then
                    fp = io.open(tmpfile, "w")
                    filename = meta.file
                    filename = string.gsub(filename, "+", " ")
                    filename = string.gsub(filename, "%%(%x%x)",
                        function(h)
                            return string.char(tonumber(h, 16))
                        end)
                    filename = filename.gsub(filename, "\r\n", "\n")
                end
            end
            if chunk then
                fp:write(chunk)
            end
            if eof then
                fp:close()
            end
        end
    )

    local path = LuciHttp.formvalue("target")
    if string.match(path, "\/$") == nil then
        path = path .. "/"
    end
    fs.mkdir(path, true)

    local savename = filename
    if fs.isfile(path .. savename) then
        local basename = savename
        local index = basename:match(".+()%.%w+$")
        if index then
            basename = basename:sub(1, index - 1)
        end
        local extension = savename:match(".+%.(%w+)$")
        for i = 1, 100, 1 do
            local tmpname = basename .. "(" .. i .. ")"
            if extension then
                tmpname = tmpname .. "." .. extension
            end
            if not fs.isfile(path .. tmpname) then
                savename = tmpname
                break
            end
        end
    end

    local dest = path .. savename
    fs.rename(tmpfile, dest)

    local result = {}
    result["code"] = 0
    LuciHttp.write_json(result)
end