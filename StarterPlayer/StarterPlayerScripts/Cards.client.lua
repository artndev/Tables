local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")

local cardEvents = RS.Events.Card
local create = cardEvents.Create
local move = cardEvents.Move
local deleteAll = cardEvents.DeleteAll

local player = PS.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local cardsGui = playerGui:WaitForChild("CardsGui")
local cards = cardsGui.Container.SubContainer.Elements.Cards
local template = RS.Card


create.OnClientInvoke = function(origin)
	print(origin)
	local card = template:Clone()
	local button = card.Content.Button
	
	card:SetAttribute("ID", origin.ID)
	card:SetAttribute("Suit", origin.Suit)
	card:SetAttribute("ItemName", origin.ItemName)
	button.Text = origin.Suit -- Здеся
	card.Parent = cards
end

deleteAll.OnClientInvoke = function()
	for _, value in pairs(cards:GetChildren()) do
		if not value:IsA("Frame") then
			continue
		end

		value:Destroy()
	end
end

move.OnClientInvoke = function(ID)
	local card = nil
	
	for _, value in pairs(cards:GetChildren()) do
		if value:GetAttribute("ID") ~= ID then
			continue
		end

		card = value
		break
	end
	
	if not card then
		return false
	end
	
	card:Destroy()
	return true
end