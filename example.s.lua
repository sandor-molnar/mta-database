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

--[[EXAMPLE SQL
CREATE TABLE `test` ( `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT , `name` VARCHAR(255) NOT NULL , `value` VARCHAR(255) NOT NULL , `created_at` DATETIME(0) NOT NULL , `updated_at` DATETIME(0) NOT NULL , PRIMARY KEY (`id`)) ENGINE = MyISAM;
]]


-- DATABASE EXAMPLES

-- Insert a row
--[[
    Query():insert('test', {
        name = 'testName',
        value = 'testValue',
        created_at = '2020-01-01 00:00:00',
        updated_at = '2020-01-01 00:00:00',
    })
]]

-- Update a row
Query():update('test', {
    name = "updatedTestName"
}, {
    id = 1
})

-- Select all rows
local test = Query():select():from('test'):all()

if not test[1] then -- all() returns array. If [1] is nil, means it's empty.
    outputDebugString('[Query] The result was empty.')
else
    for i,v in pairs(test) do
        outputDebugString(v['name'])
    end
end

-- Advanced query

local test = Query():select({'id', 'name', 'value'}):from('test'):where({value = 'testValue'})

-- You can separate, or make condition extra querys.
-- For an example, only add :orderBy() when a condition is true
if true then
    test = test:orderBy({
        id = Query.SORT_ASC
    })
end
test = test:one()
if not test then
    outputDebugString('[Query] The result was empty.')
else
    outputDebugString(test['value'])
end


-- ACTIVERECORD EXAMPLES

-- Get a single row

local test = Test():findOne(1)

outputDebugString(test.name..': '..test.value)

-- Change some data

test.value = 'Updated With AR'
test:save() -- If the value is not changed, then it don't do query, just return true.
test = test:refresh()

outputDebugString(test.value)

-- Advanced find

-- You can debug your SQL. If debug true, it will debug the whole SQL query it.
local q = Test():getQuery():debug(true):where({name = 'updatedTestName'})
local test = Test():loadByQuery(q:one())


if test then
    outputDebugString('Advanced find: '..test.id)
    test:testMethod()
else
    outputDebugString('Test data not found.', 1) 
end


tests = Test():findAll({
    {'>=', 'id', '5'}
})

for i,v in pairs(tests) do
    outputDebugString('id: '..v.id)
end