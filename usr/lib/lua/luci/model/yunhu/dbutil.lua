module("luci.model.yunhu.dbutil", package.seeall)

require "luasql.sqlite3"

local dbname = "/etc/yunhu.db"

local env, db

function connect()
	env = assert(luasql.sqlite3())
	db = assert(env:connect(dbname))
end

function disconnect(self)
end

function execute(self, sql)
	return assert(self.db:execute(sql))
end