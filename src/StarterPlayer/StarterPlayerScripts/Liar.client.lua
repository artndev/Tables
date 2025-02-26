local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")

local guisEvents = RS.Events.Guis
local cardEvents = RS.Events.Card

local player = PS.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local liarGui = playerGui:WaitForChild("LiarGui")
local popup = liarGui.Container.SubContainer.Popup.Elements
local buttons = popup.Buttons


cardEvents.Liar.OnClientInvoke = function(recentPlayer)
	local closeConnection:RBXScriptConnection
	closeConnection = guisEvents.ClosePopups.OnClientEvent:Connect(function()
		closeConnection:Disconnect()
	end)

	local connections = {}
	local ID = false
	for _, value in pairs(buttons:GetChildren()) do
		if not value:IsA("TextButton") then
			continue
		end

		local connection:RBXScriptConnection
		connection = value.MouseButton1Click:Once(function()
			if ID then
				warn(player.Name, " has already clicked button")
				return
			end

			ID = value:GetAttribute("ID")
		end)

		table.insert(connections, connection)
	end

	repeat task.wait()
	until ID or not closeConnection.Connected

	for _, value in pairs(connections) do
		if not value.Connected then
			continue
		end

		value:Disconnect()
	end

	closeConnection:Disconnect()
	return ID
end
