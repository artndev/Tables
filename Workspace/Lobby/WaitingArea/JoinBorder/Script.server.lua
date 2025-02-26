local SS = game:GetService("ServerStorage")
local PS = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local lobby = script.Parent.Parent.Parent
local lobbyModule = require(SS.Modules.Lobby).new(lobby)

local waitingAreaEvents = RS.Events.WaitingArea
local waitingAreaGuiEvents = RS.Events.Guis.WaitingAreaGui

local waitingArea = lobby.WaitingArea
local joinBorder = waitingArea.JoinBorder
local totalLabel = waitingArea.Gui.BillboardGui.Container.Total
local spawn1 = waitingArea.Spawn1
local spawn2 = waitingArea.Spawn2

local players = {}


local function startGame()
	if #players < 2 then
		return
	end
	
	for _, value in ipairs(players) do
		waitingAreaGuiEvents.Close:FireClient(value)
		task.wait(.1)
		lobbyModule:addPlayer(value)
	end
	
	task.wait(3)
	table.clear(players)
	lobbyModule:startGame()
end

joinBorder.Touched:Connect(function(hit)
	if lobbyModule.isStarted then
		return
	end
	
	local character = hit.Parent
	if not character:FindFirstChild("Humanoid") then
		return
	end
	
	local player = PS:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	
	local i = table.find(players, player, 1)
	if i then
		return
	end
	
	table.insert(players, player)
	waitingAreaGuiEvents.Open:FireClient(player)
	totalLabel.Text = "Waiting for "..tostring(#players).."/4..."
	character.HumanoidRootPart.CFrame = spawn2.CFrame + Vector3.new(0, 5, 0) -- set postion make different position on client and server
	
	startGame()
end)

waitingAreaEvents.Quit.OnServerEvent:Connect(function(player)
	local i = table.find(players, player, 1)
	if not i then
		return
	end
	
	table.remove(players, i)
	waitingAreaGuiEvents.Close:FireClient(player)
	totalLabel.Text = "Waiting for "..tostring(#players).."/4..."
	player.Character.HumanoidRootPart.CFrame = spawn1.CFrame + Vector3.new(0, 5, 0) -- set postion make different position on client and server
end)