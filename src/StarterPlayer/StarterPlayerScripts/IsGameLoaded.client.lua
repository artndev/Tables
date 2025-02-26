local RS = game:GetService("ReplicatedStorage")
local playerEvents = RS.Events.Player


playerEvents.IsGameLoaded.OnClientInvoke = function()
	repeat task.wait()
	until game:IsLoaded()
	
	return true
end