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


class "Object" {
	is_a = function(self, target)
		if not target then return false end
		if not self.__name__ then return false end
		
		return self.__name__ == target.__name__
	end,

	is_object = function(self, target)
		if not target then return false end
		if type(target) ~= 'table' then return false end
		if not target.__name__ then return false end

		return target.__name__ ~= nil
	end,
}
