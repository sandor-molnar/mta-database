
--[[
    @param id integer
    @param name string
    @param value string
    @param created_at string
    @param updated_at string
]]
class 'Test' ('ActiveRecord') {
    table = 'test',


    testMethod = function(self)
        outputDebugString('Test method. My id is: '..self.id)
    end,
}

Test.__class = Test