class "Database" ("Object") {
	handler = nil,

	setHandler = function(self, handler)
		self.handler = handler
	end,

	query = function(self, sql)
		self:validateHandler()
		assert(sql, "SQL is not found.")
		return dbQuery(self.handler, dbPrepareString(self.handler, sql))
	end,

	free = function(self, query)
		self:validateHandler()
		assert(query, "Query is not found.")
		return dbFree(query)
	end,

	exec = function(self, sql)
		self:validateHandler()
		assert(sql, "SQL is not found.")
		return dbExec(self.handler, sql)
	end,

	pollQuery = function(self, sql, time)
		self:validateHandler()
		assert(sql, "SQL is not found.")
		if type(time) ~= "number" then time = -1 end
		return dbPoll(self:query(sql), time)
	end,

	validateHandler = function(self)
		assert(self.handler, 'Database handler not set. Restart mysql setter resource.')
	end,

	escape = function(self, value, delimeter)
		if type(value) ~= 'string' then return value end
		if not delimeter then delimeter = '"' end
		return string.gsub(value, delimeter, '\\'..delimeter) 
	end,

	generateSaveTable = function(self, datas, esceptTable)
		local saveTable = {}
		if not esceptTable then exceptTable = {} end
		for i,_ in pairs(datas) do
			if not saveTable[i] and not exceptTable[i] then
				saveTable[i] = true
			end
		end

		return saveTable
	end,
}