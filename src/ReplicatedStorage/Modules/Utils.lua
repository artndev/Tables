local module = {}


function module:Keys(dict)
	local answer = {}
	
	for key, value in pairs(dict) do
		table.insert(answer, key)	
	end
	
	return answer
end

--function module:checkForKey(_key, _table)
--	for key, _ in pairs(_table) do
--		if key ~= _key then
--			continue
--		end
		
--		return true
--	end
	
--	return false
--end

--function deleteKey(array, key, value) -- by its value
--	local answer = {}
	
--	for _, item in ipairs(array) do
--		if not item[key] then
--			continue
--		end
		
--		if item[key] ~= value then
--			continue
--		end
		
--		table.insert(answer, item)
--	end

--	return answer	
--end

function module:Reverse(a)
	local result = {}
	for i, value in ipairs(a) do
		result[#a + 1 - i] = value
	end

	return result
end

function module:GetBetween(a, min, max)
	if a > max then
		return min
	end
	if a < min then
		return max
	end
		
	return a	
end

return module
