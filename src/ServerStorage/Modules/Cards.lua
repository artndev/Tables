local HS = game:GetService("HttpService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local modules = SS.Modules
local config = require(modules.Config)
local dataManager = require(modules.DataManager)
local utils = require(RS.Modules.Utils)

local cardEvents = RS.Events.Card
local create = cardEvents.Create
local move = cardEvents.Move
local deleteAll = cardEvents.DeleteAll

local module = {}


function module.moveServer(self, player, ID)
	-- wait for answer of client
	if not move:InvokeClient(player, ID) then
		return
	end
	
	-- variables of player settings
	local playerSettings = self.players[player.Name]
	local inventory = playerSettings.Inventory
	local chair = playerSettings.Chair.Model
	
	-- find card by its id in player inventory
	local origin = inventory:Find({ ID = ID })
	if not origin then
		return
	end
	
	-- get clone of found card
	print(origin[1])
	local card = config.Cards[origin[1].Value.Suit].Path:Clone()
	card.CFrame = 
		CFrame.new(
			chair.CardFrom.CFrame.Position.X,
			chair.CardFrom.CFrame.Position.Y,
			chair.CardFrom.CFrame.Position.Z
		) 
		* CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))
	card.Parent = self.recent
	
	-- tween
	local tween = TS:Create(card, TweenInfo.new(
		2,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
		), { 
			CFrame =
				CFrame.new(
					self.cardTo.CFrame.Position.X,
					self.cardTo.CFrame.Position.Y,
					self.cardTo.CFrame.Position.Z
				) 
				* CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)) 
		}
	)
	tween:Play()
	tween.Completed:Wait()
	
	-- remove card
	inventory:Remove(origin[1].Index)
end

function module.deleteAllServer(self, player)
	-- delete all cards on server and client
	self.players[player.Name].Inventory:Clear()
	deleteAll:InvokeClient(player)
end

function module.createServer(self, player, suit, amount)
	for i = 1, amount or 1, 1 do
		local equipped = dataManager:GetEquipped(player)
		if not equipped then
			continue
		end
		
		local suit = config.Suits[math.random(1, #config.Suits)]
		print(equipped)
		local itemName = equipped.Array[math.random(1, #equipped.Array)]
		local card = {
			ID = HS:GenerateGUID(true):gsub("[{}]", ""),
			Suit = suit, -- used by client
			ItemName = itemName,
		}
		
		-- create card on server and client
		self.players[player.Name].Inventory:Insert(card)
		create:InvokeClient(player, card)
	end
end

function module.createDefaultDeckServer(self, player)
	for _, value in ipairs(config.DefaultDeck) do
		module.createServer(self, player, value)
	end
end

return module
