--[[
                                       _ 
                                      | |
  _ __   _____      _____ _ __ ___  __| |
 | '_ \ / _ \ \ /\ / / _ \ '__/ _ \/ _` |
 | |_) | (_) \ V  V /  __/ | |  __/ (_| |
 | .__/ \___/ \_/\_/ \___|_|  \___|\__,_|
 | |                                                                              
 | |__  _   _   
 | '_ \| | | |  https://github.com/sanyisasha
 | |_) | |_| |  @Author SaSha <Molnár Sándor>
 |_.__/ \__, |
     _____/  /   _____  _           
    / ______/   / _____| |          
   | (___   __ _| (___ | |__   __ _ 
    \___ \ / _` |\___ \| '_ \ / _` |
    ____) | (_| |____) | | | | (_| |
   |_____/ \__,_|_____/|_| |_|\__,_|
]]



class "SelectQuery" ("Object") {
	SORT_DESC = 1,
	SORT_ASC = 2,

	_where = {},
	_limit = nil,
	_orderBy = {},
	_select = {},
	_from = nil,
	_groupBy = {},

	_debug = false,

	__init__ = function(self, selects)
		self._where = {}
		self._orderBy = {}
		self._groupBy = {}
		self._select = {}
		if not selects then selects = {'*'} end
		self:select(selects)
		return self
	end,

	handler = function(self)
		return exports['mta-mysql']
	end,

	limit = function(self, value)
		self._limit = value
		return self
	end,

	where = function(self, conditions)
		for key, value in pairs(conditions) do
			if tonumber(key) then
				-- {'NOT IN', 'id', {3,4,5}} => `id` NOT IN (...)
				local _value = value[3]
				if type(value[3]) == 'table' then
					_value = '("'..table.concat(value[3], '","')..'")'
				end
				table.insert(self._where, {_value, 'AND_'..value[1], value[2]})
			else
				if type(value) ~= 'table' then
					table.insert(self._where, {value, 'AND', key})
				else
					table.insert(self._where, {'("'..table.concat(value, '","')..'")', 'AND_IN', key})
				end
			end
		end
		return self
	end,

	andWhere = function(self, conditions)
		self:where(self, conditions)
		return self
	end,

	orWhere = function(self, conditions)
		for key, value in pairs(conditions) do
			if tonumber(key) then
				-- {'NOT IN', 'id', {3,4,5}} => `id` NOT IN (...)
				local _value = value[3]
				if type(value[3]) == 'table' then
					_value = '("'..table.concat(value[3], '","')..'")'
				end
				table.insert(self._where, {_value, 'OR_'..value[1], value[2]})
			else
				if type(value) ~= 'table' then
					table.insert(self._where, {value, 'OR', key})
				else
					table.insert(self._where, {'("'..table.concat(value, '","')..'")', 'OR_IN', key})
				end
			end
		end
		return self
	end,

	orderBy = function(self, orders)
		for col,sort in pairs(orders) do
			self._orderBy[col] = sort
		end
		return self
	end,

	select = function(self, selects)
		for key,value in pairs(selects) do
			table.insert(self._select, value)
		end
		return self
	end,

	from = function(self, from)
		self._from = from
		return self
	end,

	groupBy = function(self, groups)
		if type(groups) == 'table' then
			for i,v in pairs(groups) do
				table.insert(self._groupBy, v)
			end
		else
			table.insert(self._groupBy, groups)
		end
		return self
	end,

	build = function(self)
		local sql = 'SELECT '

		local whereSql = ''
		local orderBySql = ''
		local selectSql = ''
		local groupBySql = ''

		-- Build sql strings

		for key, values in pairs(self._where) do
			if values[2] == 'AND' or values[2] == 'OR' then
				if whereSql ~= '' then whereSql = whereSql..' '..values[2] end
				whereSql = whereSql..' `'..values[3]..'` = "'..self:handler():DBEscape(values[1])..'"'
			else
				local _types = explode('_', values[2])
				if whereSql ~= '' then whereSql = whereSql..' '.._types[1] end
				whereSql = whereSql..' `'..values[3]..'` '.._types[2]..' '..values[1]
			end
		end

		for key, value in pairs(self._orderBy) do
			if orderBySql ~= '' then orderBySql = orderBySql..', ' end
			orderBySql = orderBySql..key..' '..self:getOrderBy(value)
		end

		for _, value in pairs(self._select) do
			if selectSql ~= '' then selectSql = selectSql..', ' end
			selectSql = selectSql..''..value..''
			--[[
				if value ~= '*' then
					selectSql = selectSql..'`'..value..'`'
				else
					selectSql = selectSql..''..value..''
				end
			]]
		end

		for _, value in pairs(self._groupBy) do
			if groupBySql ~= '' then groupBySql = groupBySql..', ' end
			groupBySql = groupBySql..value
		end

		-- Adding them to the main sql

		if selectSql ~= '' then
			sql = sql..selectSql
		else
			sql = sql..'*'
		end

		sql = sql..' FROM `'..self._from..'`'

		if whereSql ~= '' then
			sql = sql..' WHERE '..whereSql
		end

		if self._limit ~= nil then
			sql = sql..' LIMIT '..self._limit
		end

		if orderBySql ~= '' then
			sql = sql..' ORDER BY '..orderBySql
		end

		if groupBySql ~= '' then
			sql = sql..' GROUP BY '..groupBySql
		end

		if self._debug then
			outputDebugString(sql)
			outputConsole(sql)
		end

		return sql
	end,

	all = function(self)
		local sql = self:build()

		if not sql then return nil end

		return self:handler():DBPollQuery(sql)
	end,

	one = function(self)
		local sql = self:build()

		if not sql then return nil end

		local result, affected, lastid = self:handler():DBPollQuery(sql)

		result = result[1]
		
		return result, affected, lastid
	end,

	poll = function(self)
		local sql = self:build()
		return self:handler():DBPollQuery(sql)
	end,


	getOrderBy = function(self, key)
		if key == self.SORT_DESC then
			return 'DESC'
		end
		if key == self.SORT_ASC then
			return 'ASC'
		end
		return ''
	end,
	

	debug = function(self, mode)
		self._debug = mode
		return self
	end
}

--[[

local q = Query()

q:where({'username' = 'test'})
q:limit(1)
q:orderBy(['username' = Query.SORT_DESC])
q:select({'username','password'})
q:poll()

]]