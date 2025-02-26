local RS = game:GetService("ReplicatedStorage")
local utils = require(RS.Modules.Utils)

local module = {}
module.__index = module


function module.new(default)	
	local self = default or {}	
		
	return setmetatable(self, module)
end

function module:Find(dict)
	assert(typeof(dict) == "table", "[TablesV2] > First argument must be TABLE.")
	
	local answer = {}
	for i, value in ipairs(self) do
		if typeof(value) ~= "table" then
			continue
		end
		
		local state = true
		for key, value2 in pairs(dict) do
			if value[key] and value[key] == value2 then
				continue
			end
			
			state = false
			break
		end
		
		if not state then
			continue
		end
		
		table.insert(answer, {
			Value = value,
			Index = i,
		})
	end

	return answer
end

function module:Insert(value)
	assert(typeof(value) ~= "nil", "[TablesV2] > First argument mustn't be NIL.")
	
	table.insert(self, value)
end

function module:Remove(index)
	assert(typeof(index) == "number", "[TablesV2] > First argument must be NUMBER.")
	
	if #self == 0 then
		warn("[TablesV2] > SELF is empty. Nothing was deleted.")
		return
	end
	
	table.remove(self, index)
end

function module:At(index)
	assert(typeof(index) == "number", "[TablesV2] > First argument must be NUMBER.")

	if #self == 0 then
		warn("[TablesV2] > SELF is empty. Nothing was got.")
		return nil
	end

	return self[math.clamp(index, 1, #self)]
end

function module:Back()
	if #self == 0 then
		warn("[TablesV2] > SELF is empty. Nothing was got.")
		return nil
	end

	return self[#self]
end

function module:Clear()
	table.clear(self)
end

function module:Length()
	return #self
end

function module:All()
	return self
end

return module
