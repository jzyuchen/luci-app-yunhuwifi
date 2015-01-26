module("yunhuwifi.DBUtil", package.seeall)

local SQLite3 = require("lsqlite3")
local dbFile = "/etc/yunhudb"

function getAllDeviceInfo()
	local db = SQLite3.open(dbFile)
	
	local sqlStr = string.format("select * from Device_Info")
    local result = {}
    for row in db:rows(sqlStr) do
        if row then
            table.insert(result,{
                ["mac"] = row[1],
                ["oName"] = row[2],
                ["nickname"] = row[3]
            })
        end
    end
    db:close()
    return result
end

function getDeviceInfo(mac)
	local db = SQLite3.open(dbFile)
    local sqlStr = string.format("select * from DEVICE_INFO where MAC = '%s'",mac)
    local result = {}
    for row in db:rows(sqlStr) do
        if row then
            result = {
                ["mac"] = row[1],
                ["oName"] = row[2],
                ["nickname"] = row[3]
            }
        end
    end
    db:close()
    return result
end

function saveDeviceInfo(mac,oName,nickname)
    local db = SQLite3.open(dbFile)
    local fetch = string.format("select * from DEVICE_INFO where MAC = '%s'",mac)
    local exist = false
    for row in db:rows(fetch) do
        if row then
            exist = true
        end
    end
    local sqlStr
    if not exist then
        sqlStr = string.format("insert into DEVICE_INFO values('%s','%s','%s')",mac,oName,nickname)
    else
        sqlStr = string.format("update DEVICE_INFO set MAC = '%s', ONAME = '%s', NICKNAME = '%s' where MAC = '%s'",mac,oName,nickname,mac)
    end
    db:exec(sqlStr)
    return db:close()
end

function deleteDeviceInfo(mac)
	local db = SQLite3.open(dbFile)
    local sqlStr = string.format("delete from DEVICE_INFO where MAC = '%s'",mac)
    db:exec(sqlStr)
    return db:close()
end

function updateDeviceNickname(mac,nickname)
    local db = SQLite3.open(dbFile)
    local sqlStr = string.format("update DEVICE_INFO set NICKNAME = '%s' where MAC = '%s'",nickname,mac)
    db:exec(sqlStr)
    return db:close()
end