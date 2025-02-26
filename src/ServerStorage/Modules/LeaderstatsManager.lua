-- Use of setdata in methods due to that they cant be reached without leaderstats
local SS = game:GetService("ServerStorage")

local dataManager = require(SS.Modules.DataManager)

local module = {}


function module:InitLeaderstats(player)
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	
	local money = Instance.new("IntValue", leaderstats)
	money.Value = dataManager:GetData(player).Data.Money
	money.Name = "Money"
end

function module:AddMoney(player, value)
	local leaderstats = player:WaitForChild("leaderstats")
	local money = leaderstats.Money
	
	money.Value = money.Value + value
	dataManager:SetData(player, "Money", money.Value)
end

function module:RemoveMoney(player, value)
	local leaderstats = player:WaitForChild("leaderstats")
	local money = leaderstats.Money
	
	money.Value = math.max(0, money.Value - value)
	dataManager:SetData(player, "Money", money.Value)
end

function module:WithdrawMoney(player)
	local leaderstats = player:WaitForChild("leaderstats")
	local money = leaderstats.Money

	money.Value = 0
	dataManager:SetData(player, "Money", money.Value)
end

function module:GetMoney(player)
	local leaderstats = player:WaitForChild("leaderstats")
	
	return leaderstats.Money.Value
end

return module
