local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local TS = game:GetService("TweenService")
local SS = game:GetService("ServerStorage")

local modules = SS.Modules

local dataManager = require(modules.DataManager)
local config = require(modules.Config)
local liar = require(modules.Liar)
local cards = require(modules.Cards)
local tableV2 = require(modules.TableV2)
local utils = require(RS.Modules.Utils)

local guisEvents = RS.Events.Guis
local playerEvents = RS.Events.Player
local loadingEvents = RS.Events.Loading

local module = {}
module.__index = module


function module.new(lobby)
	local self = {}

	self.lobby = lobby -- lobby
	
	-- instance vars
	self.arrow = self.lobby:WaitForChild("Arrow").Part
	self.spawn = self.lobby:WaitForChild("Spawn")
	self.cardTo = self.lobby:WaitForChild("CardTo")

	-- recent vars
	self.recent = self.lobby:WaitForChild("Recent")
	self.recentCard = nil
	self.recentPlayer = nil

	-- current suit vars
	self.currentSuitPart = self.lobby:WaitForChild("CurrentSuit")
	self.currentSuit = nil
	
	-- time vars
	self.timePart = self.lobby:WaitForChild("Time")
	self.timeLabel = self.timePart.BillboardGui.Frame.TimeLabel

	-- stack vards
	self.stacks = {}
	self.stacksFolder = self.lobby:WaitForChild("Stacks")

	-- player vars
	self.players = {}
	--self.playersSettings = {}
	self.totalPlayers = 0
	self.totalPlayersLabel = self.lobby:WaitForChild("WaitingArea").Gui.BillboardGui.Container.Total
	
	self.connections = {} -- connections store for player events

	-- status vars
	self.isStarted = false
	self.isInitLiarGoing = false

	-- chair vars
	local chairs = self.lobby:WaitForChild("Chairs"):GetChildren()
	table.sort(chairs, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)
	
	self.chairs = {}
	for _, value in ipairs(chairs) do
		table.insert(self.chairs, {
			Model = value,
			Order = value:GetAttribute("Order"),
			IsEmpty = true,
		})
	end

	return setmetatable(self, module)
end


-- ================ CHANGE METHODS ================
function module:changeTime(value : number)
	TS:Create(self.timeLabel, TweenInfo.new(
		.25,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.InOut,
		0,
		true,
		0
		), { 
			Position = self.timeLabel.Position - UDim2.new(0, 0, 0, 10)
	}):Play()

	self.timeLabel.Text = "<"..value..">"
end

function module:changeHearts(player : Player, value : number)
	self.players[player.Name].Hearts = value
	
	local heartsLabel = self.players[player.Name].Chair.Model.InfoLabels.SurfaceGui.Container.HeartsLabel
	TS:Create(heartsLabel, TweenInfo.new(
		.25,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.InOut,
		0,
		true,
		0
		), { 
			TextColor3 = Color3.fromRGB(255, 0, 0),
			Position = heartsLabel.Position + UDim2.new(0, 0, 0, 10),
	}):Play()
	
	heartsLabel.Text = tostring(self.players[player.Name].Hearts)
end

function module:changeSuit()
	self.currentSuit = config.Suits[math.random(1, #config.Suits)]
	
	TS:Create(self.currentSuitPart, TweenInfo.new(
		.5,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.InOut,
		0,
		true,
		0
		), { 
			Size = Vector3.new(
				self.currentSuitPart.Size.X + .2,
				self.currentSuitPart.Size.Y + .2,
				self.currentSuitPart.Size.Z + .2
			),
	}):Play()
	
	TS:Create(self.currentSuitPart, TweenInfo.new(
		1,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
		), { 
			Color = config.Cards[self.currentSuit].Color,
	}):Play()
end

-- ================ UTILS METHODS ================
function module:getEmptyChair()
	for _, value in ipairs(self.chairs) do
		if not value.IsEmpty then
			continue
		end

		value.IsEmpty = false
		return value
	end

	return nil
end

function module:ClosePopups(player : Player)
	for _, value in ipairs(guisEvents:GetChildren()) do
		if not value:IsA("Folder") then
			continue
		end
		
		local closeEvent = value:FindFirstChild("Close")
		if not closeEvent then
			continue
		end
		
		if closeEvent:IsA("RemoteEvent") then
			closeEvent:FireClient(player)
			continue
		end
		
		closeEvent:InvokeClient(player)
	end
end


-- ================ STACK METHODS ================
function module:addStackItem(player : Player, origin : Part)
	table.insert(self.stacks[player.Name].Stack, {
		Item = origin:Clone(),
		IsDisplayed = false,
	})
end


function module:displayStack(player : Player, gap : number)
	for _, stackItem in ipairs(self.stacks[player.Name].Stack) do
		self:displayStackItem(player, stackItem)
		task.wait(gap or 1)
	end
end

function module:destroyStack(player : Player, gap : number)
	for _, stackItem in ipairs(utils:Reverse(self.stacks[player.Name].Stack)) do
		stackItem.Item:Destroy()
		task.wait(gap or 1)
	end
	
	self.stacks[player.Name].Latest = nil
	table.clear(self.stacks[player.Name].Stack)
end

-- change origin part to model later
function module:displayStackItem(player : Player, stackItem : {
	Item : Part, -- <-- here
	IsDisplayed : boolean
})
	if stackItem.IsDisplayed then
		return
	end
	
	if not self.stacks[player.Name].Latest then
		self.stacks[player.Name].Latest = player.Character.Head
	end
	
	local weld = Instance.new("WeldConstraint", stackItem["Item"])
	weld.Part0 = self.stacks[player.Name].Latest
	weld.Part1 = stackItem.Item
	
	stackItem.Item.Position = Vector3.new(
		self.stacks[player.Name].Latest.Position.X, 
		self.stacks[player.Name].Latest.Position.Y + stackItem.Item.Size.Y + 0.5, 
		self.stacks[player.Name].Latest.Position.Z
	)
	stackItem.Item.Parent = self.stacks[player.Name].StackFolder

	stackItem.IsDisplayed = true
	self.stacks[player.Name].Latest = stackItem.Item
end


function module:stackWrapper(player : Player, origin : Part)
	if not player:IsDescendantOf(PS) then
		return
	end
	
	self:addStackItem(player, origin)
	self:displayStack(player)
	if #self.stacks[player.Name].Stack < config.StackLimit then
		return
	end
	
	self:destroyStack(player)
	self:damagePlayer(player, config.StackLimit)
	self:changeSuit()
end


-- ================ PLAYER METHODS ================
function module:addPlayer(player)
	if self.isStarted then
		return
	end

	local params = self.players[player.Name]
	if params then
		return
	end

	local chair = self:getEmptyChair()
	if not chair then
		return
	end

	self.players[player.Name] = {
		Chair = self:getEmptyChair(),
		Hearts = config.DefaultHearts,
		IsOut = false,
		Inventory = tableV2.new(),
	}
	self.stacks[player.Name] = {
		Stack = {},
		StackFolder = (function()
			local folder = Instance.new("Folder", self.stacksFolder)
			folder.Name = player.Name
			
			return folder
		end)(),
		Latest = nil,
		Suit = nil,
	}
	self.totalPlayers += 1
end

function module:removePlayer(player)
	if not self.isStarted then
		return
	end

	local params = self.players[player.Name]
	if not params then
		return
	end

	self.players[player.Name] = nil
	
	self:destroyStack(player, 0)
	self.stacks[player.Name] = nil
	
	self.totalPlayers -= 1
end

function module:outPlayer(player)
	if not self.isStarted then
		return
	end

	local params = self.players[player.Name]
	if not params then
		return
	end

	if params.IsOut then
		return
	end

	self.players[player.Name].IsOut = true
	self.totalPlayers -= 1
end

function module:damagePlayer(player, value)
	if not self.isStarted then
		return
	end

	local params = self.players[player.Name]
	if not params then
		return
	end

	if params.IsOut then
		return
	end

	self:changeHearts(player, math.max(0, params.Hearts - value))
	
	if self.players[player.Name].Hearts > 0 then
		return
	end
	
	self:outPlayer(player)
end


-- ================ GAME METHODS ================
function module:endGame()
	-- check for status of game
	if not self.isStarted then
		return
	end

	for key, value in pairs(self.players) do
		print(key, value)
		if value.IsOut then
			continue
		end

		print(key.." won!")
		break
	end

	for key, _ in pairs(self.players) do
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end

		loadingEvents.SizeBlur:InvokeClient(player, 100)
	end

	for key, _ in pairs(self.players) do
		-- check for player
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end
		
		print(player, 1111)
		-- delete deck of cards
		cards.deleteAllServer(self, player)
		print(2222)

		-- reset game settings
		local character = player.Character
		local humanoid = character.Humanoid
		for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid.BreakJointsOnDeath = true
		humanoid.Sit = false

		-- wait until humanoid stand
		repeat task.wait(1) -- seat problem
		until humanoid.Sit == false

		-- teleport player
		local humanoidRootPart = character.HumanoidRootPart
		humanoidRootPart.CFrame = self.spawn.CFrame + Vector3.new(0, 10, 0)
	end
	
	for key, _ in pairs(self.players) do
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end

		loadingEvents.SizeBlur:InvokeClient(player, 0)
	end

	-- clear chairs
	for _, value in ipairs(self.chairs) do
		value.IsEmpty = true
		value.Model.InfoLabels.SurfaceGui.Container.HeartsLabel.Text = tostring(config.DefaultHearts)
	end

	-- clear variables
	
	
	self.isStarted = false
	self.currentSuit = nil
	
	self.stacksFolder:ClearAllChildren()
	self.recent:ClearAllChildren()
	self.recentCard = nil
	self.recentPlayer = nil
	
	self.totalPlayers = 0
	self.totalPlayersLabel.Text = "Waiting for 0/4..."

	for _, value in ipairs(self.connections) do
		value:Disconnect()
	end
	
	table.clear(self.connections)
	table.clear(self.players)
	table.clear(self.stacks)
end

function module:startGame()
	-- check for status of game
	if self.isStarted then
		return
	end

	local connection = playerEvents.OnPlayerRemoving.Event:Connect(function(player)
		if not (self.isStarted and self.players[player.Name]) then
			return
		end

		self:removePlayer(player)
	end)
	table.insert(self.connections, connection)

	-- set variables
	self.isStarted = true
	self:changeSuit()
	
	for key, _ in pairs(self.players) do
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end
		
		loadingEvents.SizeBlur:InvokeClient(player, 100)
	end

	for key, value in pairs(self.players) do
		-- check for player
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end

		--module:addStack(player, )
		-- create deck of cards for each player
		cards.createDefaultDeckServer(self, player)

		-- game settings
		local character = player.Character
		local humanoid = character.Humanoid
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		humanoid.BreakJointsOnDeath = false -- for animations
		value.Chair.Model.Seat:Sit(humanoid)
	end
	
	for key, _ in pairs(self.players) do
		local player = PS:FindFirstChild(key)
		if not player then
			continue
		end

		loadingEvents.SizeBlur:InvokeClient(player, 0)
	end

	-- start round
	local i = 1
	local keys = utils:Keys(self.players)
	while self.totalPlayers > 1 do
		-- ОБНОВЛЕНИЕ НА КАЖДОМ 4ОМ ХОРОШО РАБОТАЕТ ТОЛЬКО С ЛОББИ НА 4ЫХ
		i = utils:GetBetween(i + 1, 1, #keys)

		-- player variables
		local playerName = keys[i]
		local playerSettings = self.players[playerName]
		local chair = playerSettings.Chair.Model.Chair

		-- tween arrow
		local tween = TS:Create(self.arrow, TweenInfo.new(
			2,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.InOut,
			0,
			false,
			0
			), { 
				CFrame = CFrame.lookAt(
					self.arrow.Position, 
					Vector3.new(chair.Position.X, self.arrow.Position.Y, chair.Position.Z)
				) 
			}
		)
		tween:Play()
		tween.Completed:Wait()	

		-- check for player
		local player = PS:FindFirstChild(playerName)	
		if not player or playerSettings.IsOut then -- mean wait for end of game
			continue
		end

		-- reset timer state
		self.isInitLiarGoing = false
		
		local timeCoroutine = coroutine.create(function()
			for j = 1, config.TurnLength, 1 do
				self:changeTime(j)
				task.wait(1)
			end 
			
			if self.isInitLiarGoing then
				return
			end
			
			-- close popups
			guisEvents.ClosePopups:FireClient(player)
			
			-- dagame player
			self:damagePlayer(player, 10)
			
			-- clear recent variables
			self.recentCard = nil
			self.recent:ClearAllChildren()
			self.recentPlayer = nil
		end)

		-- start coroutine
		coroutine.resume(timeCoroutine)
		
		local success, err = pcall(function() -- for soft quit at middle of game
			liar.init(self, player)
		end)

		if not success then
			warn("Player quitted during round: ", err)
		end

		-- stop coroutine
		coroutine.close(timeCoroutine)
		
		-- reset time
		self:changeTime(0)
	end

	self:endGame()
end

return module
