
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
