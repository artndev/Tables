local HS = game:GetService("HttpService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local PS = game:GetService("Players")

local modules = SS.Modules
local cards = require(modules.Cards)
local config = require(modules.Config)

local liarGuiEvents = RS.Events.Guis.LiarGui
local cardsGuiEvents = RS.Events.Guis.CardsGui
local cardEvents = RS.Events.Card
local itemSample = SS.Item

local module = {}


function module.liarBad(self, player)
	-- change status
	self.isInitLiarGoing = true
	
	-- damage player
	local origin = itemSample:Clone()
	local color = config.BackpackItems[self.recentCard.ItemName].Color
	origin.Color = Color3.fromRGB(color.R, color.G, color.B)
	self:stackWrapper(player, origin)

	-- clear recent variables
	self.recentCard = nil
	self.recent:ClearAllChildren()
	self.recentPlayer = nil

	return false
end

function module.liarGood(self, player)
	-- Get ID of choosed card and move it
	cardsGuiEvents.Open:InvokeClient(player)
	local cardFrameAttrs : {
		ID : number,
		ItemName : string,
		Suit : string,	
	} = cardsGuiEvents.GetCurrent:InvokeClient(player)
	cardsGuiEvents.Close:InvokeClient(player)
	
	-- change status
	self.isInitLiarGoing = true

	--print(cardFrame)
	if not cardFrameAttrs then
		return nil
	end

	-- add card to previous players stack
	if self.recentPlayer and self.recentCard then
		local origin = itemSample:Clone()
		local color = config.BackpackItems[self.recentCard.ItemName].Color
		origin.Color = Color3.fromRGB(color.R, color.G, color.B)
		self:stackWrapper(player, origin)
	end

	self.recentCard = cardFrameAttrs
	self.recent:ClearAllChildren()
	self.recentPlayer = player

	-- Move and create card on server
	cards.moveServer(self, player, self.recentCard.ID)
	cards.createServer(self, player, self.currentSuit)

	return true
end

function module.init(self, player)
	-- ask question about liar  opne liad menu
	local isLiar = nil
	if not self.recentPlayer then
		isLiar = 1
	else
		liarGuiEvents.Open:InvokeClient(player, self.recentPlayer.Name)
		isLiar = cardEvents.Liar:InvokeClient(player, self.recentPlayer)
		liarGuiEvents.Close:InvokeClient(player)
	end
	if isLiar == false then
		return
	end

	-- check for recent card suit
	local status = 0
	if self.recentCard and self.recentCard.Suit == self.currentSuit then
		status = 1
	end

	--print(isLiar, status)
	-- isLiar status
	-- 1      0     good
	-- 0      1     good
	-- 1      1     bad
	-- 0      0     bad
	if bit32.bxor(isLiar, status) == 1 then
		module.liarGood(self, player)
	else
		module.liarBad(self, player)
	end
end

return module
