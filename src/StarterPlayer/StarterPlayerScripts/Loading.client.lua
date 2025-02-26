local RS = game:GetService("ReplicatedStorage")

local loading = require(RS.Modules.Loading).new()

local loadingEvents = RS.Events.Loading


loadingEvents.Start.OnClientInvoke = function()
	loading:Start()
end

loadingEvents.Stop.OnClientInvoke = function()
	loading:Stop()
end

loadingEvents.SizeBlur.OnClientInvoke = function(value)
	loading:SizeBlur(value)
end