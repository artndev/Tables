local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")

local backpackManagerEvents = RS.Events.BackpackManager

local player = PS.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local backpackGui = playerGui:WaitForChild("BackpackGui")
local items = backpackGui.Container.SubContainer.Popup.Elements.ScrollingFrame.Items


backpackManagerEvents.ClearGamepasses.OnClientInvoke = function(backpack)
	for _, value in ipairs(items:GetChildren()) do
		if not value:IsA("Frame") then
			continue
		end
		
		if not backpack[value.Name] then
			continue
		end
		
		value:Destroy()
	end 
end