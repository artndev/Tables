local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")

local replicaController = require(RS.ReplicaController)
local backpackManagerEvents = RS.Events.BackpackManager
local itemSample = RS.Gamepass

local player = PS.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local backpackGui = playerGui:WaitForChild("BackpackGui")
local items = backpackGui.Container.SubContainer.Popup.Elements.ScrollingFrame.Items


local function swap(button, value)
	if value.IsEquipped then
		button.TextColor3 = Color3.fromRGB(13, 216, 108)
		button.Text = "TAKE OFF"
		return
	end
	
	button.TextColor3 = Color3.fromRGB(216, 35, 35)
	button.Text = "TAKE ON"
end

local connections = {}
replicaController.ReplicaOfClassCreated("token_"..player.UserId, function(replica)
	replica:ListenToChange({"Backpack"}, function(backpack)
		local function makeChangesNew(key, value)
			local sample = itemSample:Clone()
			local content = sample:WaitForChild("Item"):WaitForChild("Content")
			local button = content:WaitForChild("Button")
			
			if not connections[key] then
				connections[key] = {}
			end
			
			for _, connection:RBXScriptConnection in ipairs(connections[key]) do
				connection:Disconnect()
			end

			local PCConnection = button.MouseButton1Click:Connect(function()
				--print(equipped.Dict, equipped.Length, value, equipped.Dict[key])
				local equipped = backpackManagerEvents.GetEquipped:InvokeServer(player)
				if table.find(equipped.Array, key, 1) and equipped.Length == 1 then
					return
				end 
				
				backpackManagerEvents.ChangeState:FireServer(key)
			end)
			table.insert(connections[key], PCConnection)
			
			local mobileConnection = button.TouchTap:Connect(function()
				local equipped = backpackManagerEvents.GetEquipped:InvokeServer(player)
				if table.find(equipped.Array, key, 1) and equipped.Length == 1 then
					return
				end 
				
				backpackManagerEvents.ChangeState:FireServer(key)
			end)
			table.insert(connections[key], mobileConnection)

			swap(button, value)
			content.BackgroundColor3 = Color3.fromRGB(value.Color.R, value.Color.G, value.Color.B)
			sample.LayoutOrder = 2
			sample.Name = key
			sample.Parent = items
		end
		
		local function makeChangesOld(item, value)
			local button = item:WaitForChild("Item"):WaitForChild("Content"):WaitForChild("Button")

			swap(button, value)
		end
		
		for key, value in pairs(backpack) do
			local item = items:FindFirstChild(key) 
			if not item then
				makeChangesNew(key, value)
				continue
			end
			
			makeChangesOld(item, value)
		end
	end)
end)

replicaController.RequestData()