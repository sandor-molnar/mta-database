class "Query" ("Object") {
	SORT_DESC = 1,
	SORT_ASC = 2,

	schemaCache = {},
	
	handler = function(self)
		return exports.ssh_mysql
	end,
	--[[
		local q = Query():select()
		q:where({username = 'test'})
		q:one()
	]]
	select = function(self, selects)
		return SelectQuery(selects)
	end,

	--[[
		Query():insert('users', {
			username = 'test',
			password = 'test2'
		})
	]]
	insert = function(self, _table, values)
		assert(values, '[Query] values can\'t be blank.')

		local sql = 'INSERT INTO `'.._table..'` '

		local _args = '('
		local _values = '('

		for i,v in pairs(values) do
			_args = _args..'`'..i..'`, '
			_values = _values..'"'..Database():escape(v)..'", '
		end
		
		_values = string.sub(_values, 0, -3)
		_args = string.sub(_args, 0, -3)

		_args = _args..') VALUES '
		_values = _values..')'

		sql = sql.._args.._values

		outputDebugString(sql)
		outputConsole(sql)
		return self:handler():DBPollQuery(sql)
	end,

	update = function(self, _table, values, condition)
		assert(values, '[Query] values can\'t be blank.')
		assert(condition, '[Query] condition can\'t be blank.')

		local sql = 'UPDATE `'.._table..'` SET '

		local _values = ''
		local _where = ' WHERE '

		local _condition = {}

		for key, value in pairs(condition) do
			if tonumber(key) then
				-- {'NOT IN', 'id', {3,4,5}} => `id` NOT IN (...)
				local _value = value[3]
				if type(value[3]) == 'table' then
					_value = '("'..table.concat(value[3], '","')..'")'
				end
				table.insert(_condition, {_value, 'AND_'..value[1], value[2]})
			else
				if type(value) ~= 'table' then
					table.insert(_condition, {value, 'AND', key})
				else
					table.insert(_condition, {'("'..table.concat(value, '","')..'")', 'AND_IN', key})
				end
			end
		end

		-- TODO: implement orWhere
		
		for key, value in pairs(_condition) do
			if value[2] == 'AND' or value[2] == 'OR' then
				if _where ~= ' WHERE ' then _where = _where..' '..value[2] end
				_where = _where..' `'..value[3]..'` = "'..Database():escape(value[1])..'"'
			else
				local _types = explode('_', value[2])
				if _where ~= ' WHERE ' then _where = _where..' '.._types[1] end
				_where = _where..' `'..value[3]..'` '.._types[2]..' '..value[1]
			end
		end

		if _where == ' WHERE ' then _where = ' WHERE 1=1 ' end

		for key, value in pairs(values) do
			_values = _values..'`'..key..'` = "'..Database():escape(value)..'", '
		end

		_values = string.sub(_values, 0, -3)

		sql = sql.._values.._where

		outputDebugString(sql)
		outputConsole(sql)
		return self:handler():DBExec(sql)
	end,

	delete = function(self, _table, condition)
		assert(condition, '[Query] condition can\'t be blank.')

		local sql = 'DELETE FROM `'.._table..'`'

		local _where = ' WHERE '

		local _condition = {}
		for key, value in pairs(condition) do
			if tonumber(key) then
				-- {'NOT IN', 'id', {3,4,5}} => `id` NOT IN (...)
				local _value = value[3]
				if type(value[3]) == 'table' then
					_value = '("'..table.concat(value[3], '","')..'")'
				end
				table.insert(_condition, {_value, 'AND_'..value[1], value[2]})
			else
				if type(value) ~= 'table' then
					table.insert(_condition, {value, 'AND', key})
				else
					table.insert(_condition, {'("'..table.concat(value, '","')..'")', 'AND_IN', key})
				end
			end
		end

		-- TODO: implement orWhere
		for key, value in pairs(_condition) do
			if value[2] == 'AND' or value[2] == 'OR' then
				if _where ~= ' WHERE ' then _where = _where..' '..value[2] end
				_where = _where..' `'..value[3]..'` = "'..Database():escape(value[1])..'"'
			else
				local _types = explode('_', value[2])
				if _where ~= ' WHERE ' then _where = _where..' '.._types[1] end
				_where = _where..' `'..value[3]..'` '.._types[2]..' '..value[1]
			end
		end

		sql = sql.._where

		outputDebugString(sql)
		outputConsole(sql)
		return self:handler():DBExec(sql)

	end,

	getSchema = function(self, _table)
		if self.schemaCache[_table] then return self.schemaCache[_table] end
		local database = self:handler():DBGetDatabase()
		local data = self:handler():DBPollQuery("SELECT COLUMN_NAME as value FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`='"..database.."' AND `TABLE_NAME`='".._table.."'")
		self.schemaCache[_table] = data
		return data
	end,
}
